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

	# --- the placement itself: battery at (23, 7), capacity 4000. ---
	var placement: Dictionary = build_state.source_battery_placement_state(8)
	proof["battery_placement"] = str(placement.get("block_id", "")) == "battery" and str(placement.get("role", "")) == "battery" and placement.get("cell", Vector2i.ZERO) == Vector2i(23, 7) and is_equal_approx(float(placement.get("power_capacity", -1.0)), 4000.0)

	# --- the real Main scene has the battery sprite at (23, 7). ---
	var battery: Variant = game.call("block_sprite_at_cell", Vector2i(23, 7))
	proof["battery_placement_live_sprite"] = battery != null and str(battery.get_meta("source_block_id", "")) == "battery"

	# --- the placed power graph now has one battery, one producer, and
	# 21 consumers per origin cell (drill 4 + core 9 + conveyors 7 +
	# duo 1); the panel is a producer, not a consumer. The panel's
	# surplus (0.12 produced, 0 needed) charges the battery each frame. ---
	var step: Dictionary = factory_state.source_factory_update_power_graph_state(game, 1.0 / 60.0)
	var update: Dictionary = step.get("update", {})
	var distribute: Dictionary = update.get("battery_distribute_state", {})
	var batteries: Array = distribute.get("batteries", [])
	var battery_status := 0.0
	if not batteries.is_empty() and batteries[0] is Dictionary:
		battery_status = float(batteries[0].get("power_status", 0.0))
	proof["battery_placement_live_graph"] = int(step.get("battery_count", -1)) == 1 and int(step.get("producer_count", -1)) == 1 and int(step.get("consumer_count", -1)) == 21 and bool(distribute.get("charged", false)) and is_equal_approx(float(distribute.get("power_battery_charged", -1.0)), 0.12 / 60.0) and battery_status > 0.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("BatteryPlacementProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
