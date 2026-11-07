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

	# --- the placement itself: lancer at (25, 7), power usage 6.0. ---
	var placement: Dictionary = build_state.source_lancer_placement_state(8)
	proof["lancer_placement"] = str(placement.get("block_id", "")) == "lancer" and str(placement.get("role", "")) == "lancer" and placement.get("cell", Vector2i.ZERO) == Vector2i(25, 7) and is_equal_approx(float(placement.get("power_usage", -1.0)), 6.0)

	# --- the real Main scene has the lancer sprite at (25, 7). ---
	var lancer: Variant = game.call("block_sprite_at_cell", Vector2i(25, 7))
	proof["lancer_placement_live_sprite"] = lancer != null and str(lancer.get_meta("source_block_id", "")) == "lancer"

	# --- the placed power graph now has a real consumer: the lancer
	# adds 1 consumer per building (11 total: drill, core, 7
	# conveyors, duo, lancer; N2081), and its usage is counted once,
	# so the graph needs 6.0/60 = 0.1 against 0.12/60 produced —
	# coverage 0.02 (partial power, the Java value). The empty
	# battery cannot charge (a deficit). ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	var update: Dictionary = step.get("update", {})
	var distribute: Dictionary = update.get("battery_distribute_state", {})
	proof["lancer_placement_live_graph"] = int(step.get("consumer_count", -1)) == 11 and int(step.get("producer_count", -1)) == 1 and int(step.get("battery_count", -1)) == 1 and is_equal_approx(float(step.get("power_needed", -1.0)), 6.0 / 60.0) and is_equal_approx(float(step.get("power_produced", -1.0)), 0.12 / 60.0) and is_equal_approx(float(distribute.get("coverage", -1.0)), 0.02) and not bool(distribute.get("charged", true)) and is_equal_approx(float(distribute.get("power_battery_charged", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("LancerPlacementProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
