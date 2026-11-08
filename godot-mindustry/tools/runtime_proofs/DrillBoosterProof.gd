extends Node

const main_scene := preload("res://scenes/Main.tscn")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const pump_state := preload("res://src/game/SourcePumpRuntimeState.gd")
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
	var drill_cell := Vector2i(7, 8)

	# --- before water: the drill runs unboosted (speed 1.0). ---
	var before: Dictionary = drill_consumption_state.source_drill_booster_state(game, drill_cell)
	proof["drill_booster_unboosted"] = is_equal_approx(float(before.get("speed", -1.0)), 1.0) and not bool(before.get("boosted", true))

	# --- drive 15 seconds of game time through the live loop: the
	# pump (7.0 water/sec) fills the line, the conduits push it
	# forward once per second, and it reaches the drill. ---
	for iteration in range(900):
		game.call("simulate_factory", 1.0 / 60.0)
	var after: Dictionary = drill_consumption_state.source_drill_booster_state(game, drill_cell)
	proof["drill_booster_water"] = float(after.get("water", -1.0)) > 0.0
	proof["drill_booster_engaged"] = bool(after.get("boosted", false)) and float(after.get("optional_efficiency", -1.0)) > 0.0
	proof["drill_booster_speed"] = is_equal_approx(float(after.get("speed", -1.0)), 1.6)

	# --- the pump fix: it produces 7.0 water per second (7/60 per
	# frame), so after 15s the pump + first conduit hold far more
	# than the old 0.117/sec rate could supply. ---
	var pump: Variant = game.call("block_sprite_at_cell", Vector2i(5, 14))
	var pump_liquids: Dictionary = pump.get_meta("source_building_liquids", {})
	var pump_water: float = float(liquid_module_state.source_get_state(pump_liquids, water_id).get("amount", -1.0))
	var first: Variant = game.call("block_sprite_at_cell", Vector2i(5, 13))
	var first_liquids: Dictionary = first.get_meta("source_building_liquids", {})
	var first_water: float = float(liquid_module_state.source_get_state(first_liquids, water_id).get("amount", -1.0))
	proof["pump_produces_java_rate"] = pump_water + first_water > 5.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillBoosterProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
