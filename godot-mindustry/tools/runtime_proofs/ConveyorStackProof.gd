extends Node

const main_scene := preload("res://scenes/Main.tscn")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
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

	# --- removeStack: first match per iteration, from the front. ---
	var remove_one: Dictionary = conveyor_state.source_conveyor_remove_stack_state(["copper", "lead", "copper"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, "copper", 1, 5)
	proof["conveyor_stack_remove_one"] = remove_one.get("ids_after") == ["lead", "copper"] and remove_one.get("ys_after") == [0.8, 0.9] and remove_one.get("len_after") == 2 and remove_one.get("removed") == 1 and remove_one.get("item_count_after") == 4 and remove_one.get("no_sleep_called") == true
	var remove_two: Dictionary = conveyor_state.source_conveyor_remove_stack_state(["copper", "lead", "copper"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, "copper", 2, 5)
	proof["conveyor_stack_remove_two"] = remove_two.get("ids_after") == ["lead"] and remove_two.get("len_after") == 1 and remove_two.get("removed") == 2 and remove_two.get("item_count_after") == 3 and remove_two.get("no_sleep_called") == true
	var remove_more_than_held: Dictionary = conveyor_state.source_conveyor_remove_stack_state(["copper", "lead", "copper"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, "copper", 5, 3)
	proof["conveyor_stack_remove_more_than_held"] = remove_more_than_held.get("ids_after") == ["lead"] and remove_more_than_held.get("len_after") == 1 and remove_more_than_held.get("removed") == 2 and remove_more_than_held.get("item_count_after") == 1
	var remove_other: Dictionary = conveyor_state.source_conveyor_remove_stack_state(["copper", "lead"], [0.0, 0.5], [0.2, 0.8], 2, "lead", 1, 1)
	proof["conveyor_stack_remove_other"] = remove_other.get("ids_after") == ["copper"] and remove_other.get("len_after") == 1 and remove_other.get("removed") == 1 and remove_other.get("item_count_after") == 0
	var remove_absent: Dictionary = conveyor_state.source_conveyor_remove_stack_state(["copper", "lead"], [0.0, 0.5], [0.2, 0.8], 2, "silicon", 2, 0)
	proof["conveyor_stack_remove_absent"] = remove_absent.get("ids_after") == ["copper", "lead"] and remove_absent.get("len_after") == 2 and remove_absent.get("removed") == 0 and remove_absent.get("item_count_after") == 0
	var remove_zero: Dictionary = conveyor_state.source_conveyor_remove_stack_state(["copper", "lead"], [0.0, 0.5], [0.2, 0.8], 2, "copper", 0, 5)
	proof["conveyor_stack_remove_zero"] = remove_zero.get("ids_after") == ["copper", "lead"] and remove_zero.get("len_after") == 2 and remove_zero.get("removed") == 0 and remove_zero.get("item_count_after") == 5

	# --- acceptStack: free slots in item-space units, capped by the request. ---
	var accept_free: Dictionary = conveyor_state.source_conveyor_accept_stack_state(1.0, 0.4, 5)
	proof["conveyor_stack_accept_free"] = accept_free.get("accepted") == 2 and accept_free.get("free_slots") == 2 and accept_free.get("reason") == "accepted"
	var accept_capped: Dictionary = conveyor_state.source_conveyor_accept_stack_state(0.8, 0.4, 1)
	proof["conveyor_stack_accept_capped"] = accept_capped.get("accepted") == 1 and accept_capped.get("free_slots") == 2 and accept_capped.get("reason") == "accepted"
	var accept_none: Dictionary = conveyor_state.source_conveyor_accept_stack_state(0.3, 0.4, 5)
	proof["conveyor_stack_accept_none"] = accept_none.get("accepted") == 0 and accept_none.get("free_slots") == 0 and accept_none.get("reason") == "accepted"
	var accept_invalid: Dictionary = conveyor_state.source_conveyor_accept_stack_state(1.0, 0.0, 5)
	proof["conveyor_stack_accept_invalid"] = accept_invalid.get("accepted") == 0 and accept_invalid.get("free_slots") == 0 and accept_invalid.get("reason") == "invalid_item_space"

	# --- handleStack: insert a spaced stack at the front, clamped by free capacity. ---
	var handle_empty: Dictionary = conveyor_state.source_conveyor_handle_stack_state([], [], [], 0, 3, "copper", 2, 0.4, 0)
	proof["conveyor_stack_handle_empty"] = handle_empty.get("ids_after") == ["copper", "copper"] and handle_empty.get("xs_after") == [0.0, 0.0] and handle_empty.get("ys_after") == [0.0, 0.4] and handle_empty.get("len_after") == 2 and handle_empty.get("inserted") == 2 and handle_empty.get("item_count_after") == 2 and handle_empty.get("no_sleep_called") == true and handle_empty.get("reason") == "inserted"
	var handle_onto: Dictionary = conveyor_state.source_conveyor_handle_stack_state(["lead"], [0.5], [0.8], 1, 3, "copper", 2, 0.4, 0)
	proof["conveyor_stack_handle_onto"] = handle_onto.get("ids_after") == ["copper", "copper", "lead"] and handle_onto.get("ys_after") == [0.0, 0.4, 0.8] and handle_onto.get("len_after") == 3 and handle_onto.get("inserted") == 2 and handle_onto.get("item_count_after") == 2
	var handle_clamped: Dictionary = conveyor_state.source_conveyor_handle_stack_state(["lead", "silicon"], [0.5, -0.5], [0.6, 0.9], 2, 3, "copper", 5, 0.4, 1)
	proof["conveyor_stack_handle_clamped"] = handle_clamped.get("ids_after") == ["copper", "lead", "silicon"] and handle_clamped.get("ys_after") == [0.0, 0.6, 0.9] and handle_clamped.get("len_after") == 3 and handle_clamped.get("inserted") == 1 and handle_clamped.get("item_count_after") == 2
	var handle_full: Dictionary = conveyor_state.source_conveyor_handle_stack_state(["lead", "silicon", "copper"], [0.5, -0.5, 0.0], [0.6, 0.9, 0.95], 3, 3, "copper", 2, 0.4, 3)
	proof["conveyor_stack_handle_full"] = handle_full.get("ids_after") == ["lead", "silicon", "copper"] and handle_full.get("len_after") == 3 and handle_full.get("inserted") == 0 and handle_full.get("item_count_after") == 3 and handle_full.get("reason") == "at_capacity"

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConveyorStackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
