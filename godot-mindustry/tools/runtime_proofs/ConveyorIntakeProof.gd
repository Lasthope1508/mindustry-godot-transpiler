extends Node

const main_scene := preload("res://scenes/Main.tscn")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

var next_accept_result := true
var next_handled: Array = []


func _next_accepts(item_id: Variant) -> bool:
	return next_accept_result


func _next_handle(item_id: Variant) -> void:
	next_handled.append(item_id)


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

	# --- acceptItem: capacity, facing, direction arms, rotate loop. ---
	var accept_straight: Dictionary = conveyor_state.source_conveyor_accept_item_state(0, 3, 2, 2, 1.0, 0.4, false, false)
	proof["conveyor_accept_straight"] = accept_straight.get("accepted") == true and accept_straight.get("direction") == 0 and accept_straight.get("reason") == "accepted"
	var accept_straight_blocked: Dictionary = conveyor_state.source_conveyor_accept_item_state(0, 3, 2, 2, 0.3, 0.4, false, false)
	proof["conveyor_accept_straight_needs_space"] = accept_straight_blocked.get("accepted") == false and accept_straight_blocked.get("reason") == "wrong_direction"
	var accept_side: Dictionary = conveyor_state.source_conveyor_accept_item_state(1, 3, 1, 2, 0.8, 0.4, false, false)
	proof["conveyor_accept_side"] = accept_side.get("accepted") == true and accept_side.get("direction") == 1 and accept_side.get("reason") == "accepted"
	var accept_side_blocked: Dictionary = conveyor_state.source_conveyor_accept_item_state(1, 3, 1, 2, 0.7, 0.4, false, false)
	proof["conveyor_accept_side_needs_gap"] = accept_side_blocked.get("accepted") == false and accept_side_blocked.get("reason") == "wrong_direction"
	var accept_opposite: Dictionary = conveyor_state.source_conveyor_accept_item_state(0, 3, 0, 2, 1.0, 0.4, false, false)
	proof["conveyor_accept_opposite_refused"] = accept_opposite.get("accepted") == false and accept_opposite.get("direction") == 2 and accept_opposite.get("reason") == "wrong_direction"
	var accept_full: Dictionary = conveyor_state.source_conveyor_accept_item_state(3, 3, 2, 2, 1.0, 0.4, false, false)
	proof["conveyor_accept_at_capacity"] = accept_full.get("accepted") == false and accept_full.get("reason") == "at_capacity"
	var accept_no_facing: Dictionary = conveyor_state.source_conveyor_accept_item_state(0, 3, -1, 2, 1.0, 0.4, false, false)
	proof["conveyor_accept_no_facing"] = accept_no_facing.get("accepted") == false and accept_no_facing.get("reason") == "no_facing"
	var accept_rotate_loop: Dictionary = conveyor_state.source_conveyor_accept_item_state(0, 3, 2, 2, 1.0, 0.4, true, true)
	proof["conveyor_accept_rotate_loop"] = accept_rotate_loop.get("accepted") == false and accept_rotate_loop.get("reason") == "rotate_loop"
	var accept_side_other: Dictionary = conveyor_state.source_conveyor_accept_item_state(0, 3, 3, 2, 0.9, 0.4, false, false)
	proof["conveyor_accept_side_other_direction"] = accept_side_other.get("accepted") == true and accept_side_other.get("direction") == 1 and accept_side_other.get("reason") == "accepted"

	# --- handleItem: straight inserts at 0, side inserts at mid, capacity refuses. ---
	var handle_straight: Dictionary = conveyor_state.source_conveyor_handle_item_state(0, 3, 2, 2, 0, "copper", 0)
	proof["conveyor_handle_straight"] = handle_straight.get("accepted") == true and handle_straight.get("index") == 0 and handle_straight.get("x") == 0.0 and handle_straight.get("y") == 0.0 and handle_straight.get("len_after") == 1 and handle_straight.get("item_count_after") == 1 and handle_straight.get("no_sleep_called") == true and handle_straight.get("reason") == "accepted"
	var handle_side_left: Dictionary = conveyor_state.source_conveyor_handle_item_state(1, 3, 1, 2, 1, "lead", 1)
	proof["conveyor_handle_side_left"] = handle_side_left.get("accepted") == true and handle_side_left.get("index") == 1 and handle_side_left.get("x") == 1.0 and handle_side_left.get("y") == 0.5 and handle_side_left.get("len_after") == 2 and handle_side_left.get("item_count_after") == 2
	var handle_side_right: Dictionary = conveyor_state.source_conveyor_handle_item_state(1, 3, 3, 2, 1, "lead", 1)
	proof["conveyor_handle_side_right"] = handle_side_right.get("accepted") == true and handle_side_right.get("index") == 1 and handle_side_right.get("x") == -1.0 and handle_side_right.get("y") == 0.5 and handle_side_right.get("len_after") == 2
	var handle_side_flat: Dictionary = conveyor_state.source_conveyor_handle_item_state(1, 3, 0, 2, 1, "lead", 1)
	proof["conveyor_handle_side_flat"] = handle_side_flat.get("accepted") == true and handle_side_flat.get("index") == 1 and handle_side_flat.get("x") == 0.0 and handle_side_flat.get("y") == 0.5 and handle_side_flat.get("len_after") == 2
	var handle_full: Dictionary = conveyor_state.source_conveyor_handle_item_state(3, 3, 2, 2, 0, "copper", 3)
	proof["conveyor_handle_at_capacity"] = handle_full.get("accepted") == false and handle_full.get("index") == -1 and handle_full.get("len_after") == 3 and handle_full.get("item_count_after") == 3 and handle_full.get("no_sleep_called") == false and handle_full.get("reason") == "at_capacity"

	# --- pass: forwards to the next building when it accepts. ---
	var accept_hook := Callable(self, "_next_accepts")
	var handle_hook := Callable(self, "_next_handle")
	next_accept_result = true
	next_handled = []
	var pass_ok: Dictionary = conveyor_state.source_conveyor_pass_state("copper", true, true, accept_hook, handle_hook)
	proof["conveyor_pass_forwards"] = pass_ok.get("passed") == true and pass_ok.get("item_id") == "copper" and pass_ok.get("handle_called") == true and pass_ok.get("reason") == "passed" and next_handled == ["copper"]
	var pass_null: Dictionary = conveyor_state.source_conveyor_pass_state(null, true, true, accept_hook, handle_hook)
	proof["conveyor_pass_null_item"] = pass_null.get("passed") == false and pass_null.get("reason") == "null_item" and pass_null.get("handle_called") == false
	var pass_no_next: Dictionary = conveyor_state.source_conveyor_pass_state("copper", false, true, accept_hook, handle_hook)
	proof["conveyor_pass_no_next"] = pass_no_next.get("passed") == false and pass_no_next.get("reason") == "no_next"
	var pass_wrong_team: Dictionary = conveyor_state.source_conveyor_pass_state("copper", true, false, accept_hook, handle_hook)
	proof["conveyor_pass_wrong_team"] = pass_wrong_team.get("passed") == false and pass_wrong_team.get("reason") == "wrong_team"
	next_accept_result = false
	next_handled = []
	var pass_rejected: Dictionary = conveyor_state.source_conveyor_pass_state("copper", true, true, accept_hook, handle_hook)
	proof["conveyor_pass_next_rejects"] = pass_rejected.get("passed") == false and pass_rejected.get("reason") == "next_rejects" and pass_rejected.get("handle_called") == false and next_handled.is_empty()
	next_accept_result = true
	var pass_no_handle: Dictionary = conveyor_state.source_conveyor_pass_state("copper", true, true, accept_hook, Callable())
	proof["conveyor_pass_no_handle_hook"] = pass_no_handle.get("passed") == false and pass_no_handle.get("reason") == "no_handle" and pass_no_handle.get("handle_called") == false

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConveyorIntakeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
