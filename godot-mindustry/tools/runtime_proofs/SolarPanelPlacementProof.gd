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

	# --- the placement itself: solar-panel at (21, 7), 0.12 production. ---
	var placement: Dictionary = build_state.source_solar_panel_placement_state(8)
	proof["solar_panel_placement"] = str(placement.get("block_id", "")) == "solar-panel" and str(placement.get("role", "")) == "solar-panel" and placement.get("cell", Vector2i.ZERO) == Vector2i(21, 7) and is_equal_approx(float(placement.get("power_production", -1.0)), 0.12)

	# --- the real Main scene has the panel sprite at (21, 7). ---
	var panel: Variant = game.call("block_sprite_at_cell", Vector2i(21, 7))
	proof["solar_panel_placement_live_sprite"] = panel != null and str(panel.get_meta("source_block_id", "")) == "solar-panel"

	# --- the placed power graph now has one producer, producing 0.12/delta.
	# The 19 consumers are the placed buildings (drill, core, 7
	# conveyors, duo, lancer, pump, 7 conduits); the lancer needs 6.0/delta (counted
	# once per building, N2081), the others' usage is 0, so the graph
	# needs 0.1. ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	proof["solar_panel_placement_live_graph"] = int(step.get("producer_count", -1)) == 1 and int(step.get("consumer_count", -1)) == 19 and is_equal_approx(float(step.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(step.get("power_needed", -1.0)), 6.0 / 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("SolarPanelPlacementProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
