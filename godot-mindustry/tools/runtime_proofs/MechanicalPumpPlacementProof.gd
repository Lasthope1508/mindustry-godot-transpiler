extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
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

	# --- the placement itself: mechanical pump at (5, 14), on the
	# water region, pump amount 7/60 and liquid capacity 20. ---
	var placement: Dictionary = build_state.source_mechanical_pump_placement_state(8)
	proof["mechanical_pump_placement"] = str(placement.get("block_id", "")) == "mechanical-pump" and str(placement.get("role", "")) == "mechanical-pump" and placement.get("cell", Vector2i.ZERO) == Vector2i(5, 14) and is_equal_approx(float(placement.get("pump_amount", -1.0)), 7.0 / 60.0) and is_equal_approx(float(placement.get("liquid_capacity", -1.0)), 20.0)

	# --- the real Main scene has the pump sprite at (5, 14), on the
	# shallow-water floor (the pump is floating, so it sits on water). ---
	var pump: Variant = game.call("block_sprite_at_cell", Vector2i(5, 14))
	proof["mechanical_pump_live_sprite"] = pump != null and str(pump.get_meta("source_block_id", "")) == "mechanical-pump"
	var pump_tile: Dictionary = game.call("source_world_tile", 5, 14)
	proof["mechanical_pump_live_water"] = str(pump_tile.get("floor").id) == "shallow-water"

	# --- the pump is a usage-0 power consumer in the runtime's
	# classification (hasPower and consumesPower are set in the
	# registry, like the drill/core/conveyors/duo), so the placed
	# graph now has 12 consumers (11 + the pump); the usage stays
	# 6.0/60 and coverage stays 0.02 (partial power). ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	var update: Dictionary = step.get("update", {})
	var distribute: Dictionary = update.get("battery_distribute_state", {})
	proof["mechanical_pump_live_graph"] = int(step.get("consumer_count", -1)) == 12 and int(step.get("producer_count", -1)) == 1 and int(step.get("battery_count", -1)) == 1 and is_equal_approx(float(step.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(step.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(distribute.get("coverage", -1.0)), 0.02)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("MechanicalPumpPlacementProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
