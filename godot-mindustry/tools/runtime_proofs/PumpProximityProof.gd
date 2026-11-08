extends Node

const main_scene := preload("res://scenes/Main.tscn")
const terrain_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const pump_state := preload("res://src/game/SourcePumpRuntimeState.gd")
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

	# --- the floor -> liquidDrop mapping (Blocks.java floor defs):
	# shallow-water drops water (multiplier 1.0), deep-water drops
	# water (multiplier 1.5), tar drops oil, stone drops nothing. ---
	var shallow: Dictionary = terrain_state.source_floor_liquid_drop_state("shallow-water")
	proof["floor_liquid_drop_water"] = str(shallow.get("liquid_drop", "")) == "water" and is_equal_approx(float(shallow.get("liquid_multiplier", -1.0)), 1.0) and bool(shallow.get("is_liquid", false))
	var deep: Dictionary = terrain_state.source_floor_liquid_drop_state("deep-water")
	proof["floor_liquid_drop_deep"] = str(deep.get("liquid_drop", "")) == "water" and is_equal_approx(float(deep.get("liquid_multiplier", -1.0)), 1.5) and bool(deep.get("is_liquid", false))
	var tar: Dictionary = terrain_state.source_floor_liquid_drop_state("tar")
	proof["floor_liquid_drop_oil"] = str(tar.get("liquid_drop", "")) == "oil" and is_equal_approx(float(tar.get("liquid_multiplier", -1.0)), 1.0) and bool(tar.get("is_liquid", false))
	var stone: Dictionary = terrain_state.source_floor_liquid_drop_state("stone")
	proof["floor_liquid_drop_none"] = stone.get("liquid_drop", "x") == null and is_equal_approx(float(stone.get("liquid_multiplier", -1.0)), 0.0) and not bool(stone.get("is_liquid", true))

	# --- the pump at (5, 14) sits on shallow-water, so its
	# proximity scan finds liquidDrop water with amount 1.0 (its
	# own tile's multiplier), and stores it on its sprite frame. ---
	var scan: Dictionary = pump_state.source_pump_proximity_state(game, Vector2i(5, 14))
	proof["pump_proximity"] = str(scan.get("liquid_drop", "")) == "water" and is_equal_approx(float(scan.get("amount", -1.0)), 1.0) and bool(scan.get("stored", false))
	var pump: Variant = game.call("block_sprite_at_cell", Vector2i(5, 14))
	var frame: Dictionary = pump.get_meta(pump_state.SOURCE_PUMP_BUILDING_META_KEY, {})
	proof["pump_proximity_frame"] = str(frame.get("liquid_drop", "")) == "water" and is_equal_approx(float(frame.get("amount", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("PumpProximityProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
