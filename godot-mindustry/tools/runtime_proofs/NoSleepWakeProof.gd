extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_state := preload("res://src/game/SourceBuildingItemState.gd")
const access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")


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

	# --- handleStack wakes a sleeping Building, then adds the stack. ---
	var handle_sleeping: Dictionary = item_state.source_handle_stack_wake_state(5, 3, 12.5, true, 3)
	proof["no_sleep_handle_stack_wakes_sleeping"] = handle_sleeping.get("count_before") == 5 and handle_sleeping.get("count_after") == 8 and handle_sleeping.get("sleep_time_before") == 12.5 and handle_sleeping.get("sleep_time_after") == 0.0 and handle_sleeping.get("sleeping_before") == true and handle_sleeping.get("sleeping_after") == false and handle_sleeping.get("sleeping_entities_before") == 3 and handle_sleeping.get("sleeping_entities_after") == 2 and handle_sleeping.get("woke") == true and handle_sleeping.get("add_called") == true
	var handle_awake: Dictionary = item_state.source_handle_stack_wake_state(5, 3, 4.0, false, 3)
	proof["no_sleep_handle_stack_awake_keeps_count"] = handle_awake.get("count_after") == 8 and handle_awake.get("sleep_time_after") == 0.0 and handle_awake.get("sleeping_after") == false and handle_awake.get("sleeping_entities_after") == 3 and handle_awake.get("woke") == false and handle_awake.get("add_called") == false

	# --- removeStack wakes, then removes the clamped stack; without an
	# items module the null guard returns before noSleep, so sleep state
	# is untouched. ---
	var remove_sleeping: Dictionary = item_state.source_remove_stack_wake_state(true, 10, 3, 9.0, true, 2)
	proof["no_sleep_remove_stack_wakes_sleeping"] = remove_sleeping.get("removed") == 3 and remove_sleeping.get("remaining") == 7 and remove_sleeping.get("return_value") == 3 and remove_sleeping.get("sleep_time_after") == 0.0 and remove_sleeping.get("sleeping_after") == false and remove_sleeping.get("sleeping_entities_after") == 1 and remove_sleeping.get("woke") == true and remove_sleeping.get("add_called") == true
	var remove_clamped: Dictionary = item_state.source_remove_stack_wake_state(true, 10, 15, 9.0, true, 2)
	proof["no_sleep_remove_stack_clamps_amount"] = remove_clamped.get("removed") == 10 and remove_clamped.get("remaining") == 0 and remove_clamped.get("return_value") == 10 and remove_clamped.get("woke") == true
	var remove_no_items: Dictionary = item_state.source_remove_stack_wake_state(false, 10, 3, 9.0, true, 2)
	proof["no_sleep_remove_stack_no_items_keeps_sleep"] = remove_no_items.get("removed") == 0 and remove_no_items.get("remaining") == 10 and remove_no_items.get("return_value") == 0 and remove_no_items.get("sleep_time_after") == 9.0 and remove_no_items.get("sleeping_after") == true and remove_no_items.get("sleeping_entities_after") == 2 and remove_no_items.get("woke") == false and remove_no_items.get("add_called") == false

	# --- onProximityUpdate is just noSleep. ---
	var proximity_sleeping: Dictionary = access_state.source_on_proximity_update_wake_state(7.0, true, 5)
	proof["no_sleep_proximity_update_wakes_sleeping"] = proximity_sleeping.get("sleep_time_before") == 7.0 and proximity_sleeping.get("sleep_time_after") == 0.0 and proximity_sleeping.get("sleeping_before") == true and proximity_sleeping.get("sleeping_after") == false and proximity_sleeping.get("sleeping_entities_before") == 5 and proximity_sleeping.get("sleeping_entities_after") == 4 and proximity_sleeping.get("woke") == true and proximity_sleeping.get("add_called") == true
	var proximity_awake: Dictionary = access_state.source_on_proximity_update_wake_state(7.0, false, 5)
	proof["no_sleep_proximity_update_awake_keeps_count"] = proximity_awake.get("sleep_time_after") == 0.0 and proximity_awake.get("sleeping_after") == false and proximity_awake.get("sleeping_entities_after") == 5 and proximity_awake.get("woke") == false and proximity_awake.get("add_called") == false

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("NoSleepWakeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
