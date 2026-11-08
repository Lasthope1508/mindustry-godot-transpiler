extends Node

const main_scene := preload("res://scenes/Main.tscn")
const conduit_state := preload("res://src/game/SourceConduitRuntimeState.gd")
const pump_state := preload("res://src/game/SourcePumpRuntimeState.gd")
const initial_build_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	var catalog: Dictionary = content_registry_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(catalog["liquid_id_by_name"].get("water", -1))

	# --- the conduit rotations (Conduit.java:48, rotate = true): the 5
	# north-running conduits point north (1) and the 2 east-running
	# conduits point east (0), so nearby(rotation) reaches the drill. ---
	var rotations: Dictionary = initial_build_state.source_conduit_rotation_state(8)
	var rotation_map: Dictionary = rotations.get("rotations", {})
	proof["conduit_rotations"] = str(rotations.get("block_id", "")) == "conduit" and int(rotations.get("count", -1)) == 7 and int(rotation_map.get(Vector2i(5, 13), -1)) == 1 and int(rotation_map.get(Vector2i(5, 9), -1)) == 1 and int(rotation_map.get(Vector2i(5, 8), -1)) == 0 and int(rotation_map.get(Vector2i(6, 8), -1)) == 0
	var live_rotations_ok := true
	for cell in rotation_map:
		var sprite: Variant = game.call("block_sprite_at_cell", cell)
		if sprite == null or int(sprite.get_meta("rotation", -1)) != int(rotation_map[cell]):
			live_rotations_ok = false
	proof["conduit_rotations_live"] = live_rotations_ok

	# --- the conduit update (Conduit.java:249-255): one second of
	# pumping fills 7.0 water, the pump dumps half to (5,13), and
	# the conduit's flow timer (1s) then pushes (pump - next) to
	# (5,12), so the two conduits swap amounts. ---
	var update: Dictionary = pump_state.source_pump_update_state(game, Vector2i(5, 14), 1.0)
	var dump: Dictionary = pump_state.source_pump_dump_liquid_state(game, Vector2i(5, 14))
	var first: Variant = game.call("block_sprite_at_cell", Vector2i(5, 13))
	var second: Variant = game.call("block_sprite_at_cell", Vector2i(5, 12))
	var first_liquids: Dictionary = first.get_meta("source_building_liquids", {})
	var second_liquids: Dictionary = second.get_meta("source_building_liquids", {})
	var first_before: float = float(liquid_module_state.source_get_state(first_liquids, water_id).get("amount", 0.0))
	var second_before: float = float(liquid_module_state.source_get_state(second_liquids, water_id).get("amount", 0.0))
	var flow: Dictionary = conduit_state.source_conduit_update_state(game, Vector2i(5, 13), 1.0)
	var expected_flow: float = first_before - second_before
	proof["conduit_update_flows"] = int(flow.get("liquid", -1)) == water_id
	proof["conduit_update_amount"] = is_equal_approx(float(flow.get("flowed", -1.0)), expected_flow) and is_equal_approx(float(liquid_module_state.source_get_state(first_liquids, water_id).get("amount", -1.0)), second_before) and is_equal_approx(float(liquid_module_state.source_get_state(second_liquids, water_id).get("amount", -1.0)), first_before)
	proof["conduit_update_timer"] = float(flow.get("flow_timer", -1.0)) < 1.0

	# --- a small delta does not fire the flow timer: no water moves. ---
	var first_after: float = float(liquid_module_state.source_get_state(first_liquids, water_id).get("amount", 0.0))
	var small: Dictionary = conduit_state.source_conduit_update_state(game, Vector2i(5, 13), 0.1)
	proof["conduit_update_small_delta_no_flow"] = is_equal_approx(float(small.get("flowed", -1.0)), 0.0) and is_equal_approx(float(liquid_module_state.source_get_state(first_liquids, water_id).get("amount", -1.0)), first_after)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConduitUpdateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
