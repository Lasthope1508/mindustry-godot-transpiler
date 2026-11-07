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

	# --- add(o): shift right from the insertion index, len++. ---
	var add_zero: Dictionary = conveyor_state.source_conveyor_queue_add_state(["copper", "lead"], [0.0, 0.5], [0.2, 0.8], 2, 0)
	proof["conveyor_queue_add_zero"] = add_zero.get("ids_after") == ["copper", "copper", "lead"] and add_zero.get("xs_after") == [0.0, 0.0, 0.5] and add_zero.get("ys_after") == [0.2, 0.2, 0.8] and add_zero.get("len_before") == 2 and add_zero.get("len_after") == 3 and add_zero.get("shifted") == 2 and add_zero.get("reason") == "shifted"
	var add_mid: Dictionary = conveyor_state.source_conveyor_queue_add_state(["copper", "lead"], [0.0, 0.5], [0.2, 0.8], 2, 1)
	proof["conveyor_queue_add_mid"] = add_mid.get("ids_after") == ["copper", "lead", "lead"] and add_mid.get("ys_after") == [0.2, 0.8, 0.8] and add_mid.get("len_after") == 3 and add_mid.get("shifted") == 1 and add_mid.get("reason") == "shifted"
	var add_end: Dictionary = conveyor_state.source_conveyor_queue_add_state(["copper", "lead"], [0.0, 0.5], [0.2, 0.8], 2, 2)
	proof["conveyor_queue_add_end"] = add_end.get("ids_after") == ["copper", "lead", null] and add_end.get("len_after") == 3 and add_end.get("shifted") == 0 and add_end.get("reason") == "shifted"
	var add_invalid: Dictionary = conveyor_state.source_conveyor_queue_add_state(["copper", "lead"], [0.0, 0.5], [0.2, 0.8], 2, 5)
	proof["conveyor_queue_add_invalid"] = add_invalid.get("ids_after") == ["copper", "lead"] and add_invalid.get("len_after") == 2 and add_invalid.get("shifted") == 0 and add_invalid.get("reason") == "invalid_index"
	var add_empty: Dictionary = conveyor_state.source_conveyor_queue_add_state([], [], [], 0, 0)
	proof["conveyor_queue_add_empty"] = add_empty.get("ids_after") == [null] and add_empty.get("len_after") == 1 and add_empty.get("shifted") == 0 and add_empty.get("reason") == "shifted"

	# --- remove(o): shift left from the removal index, len--. ---
	var remove_zero: Dictionary = conveyor_state.source_conveyor_queue_remove_state(["copper", "lead", "silicon"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, 0)
	proof["conveyor_queue_remove_zero"] = remove_zero.get("ids_after") == ["lead", "silicon"] and remove_zero.get("xs_after") == [0.5, -0.5] and remove_zero.get("ys_after") == [0.8, 0.9] and remove_zero.get("len_after") == 2 and remove_zero.get("shifted") == 2 and remove_zero.get("reason") == "shifted"
	var remove_mid: Dictionary = conveyor_state.source_conveyor_queue_remove_state(["copper", "lead", "silicon"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, 1)
	proof["conveyor_queue_remove_mid"] = remove_mid.get("ids_after") == ["copper", "silicon"] and remove_mid.get("len_after") == 2 and remove_mid.get("shifted") == 1 and remove_mid.get("reason") == "shifted"
	var remove_last: Dictionary = conveyor_state.source_conveyor_queue_remove_state(["copper", "lead", "silicon"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, 2)
	proof["conveyor_queue_remove_last"] = remove_last.get("ids_after") == ["copper", "lead"] and remove_last.get("len_after") == 2 and remove_last.get("shifted") == 0 and remove_last.get("reason") == "shifted"
	var remove_invalid: Dictionary = conveyor_state.source_conveyor_queue_remove_state(["copper", "lead", "silicon"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, 3)
	proof["conveyor_queue_remove_invalid"] = remove_invalid.get("ids_after") == ["copper", "lead", "silicon"] and remove_invalid.get("len_after") == 3 and remove_invalid.get("shifted") == 0 and remove_invalid.get("reason") == "invalid_index"
	var remove_single: Dictionary = conveyor_state.source_conveyor_queue_remove_state(["copper"], [0.0], [0.2], 1, 0)
	proof["conveyor_queue_remove_single"] = remove_single.get("ids_after") == [] and remove_single.get("len_after") == 0 and remove_single.get("shifted") == 0 and remove_single.get("reason") == "shifted"

	# --- scan: mid from the ys array, minitem skips passed items. ---
	var scan_basic: Dictionary = conveyor_state.source_conveyor_queue_scan_state([0.2, 0.8, 0.9], [false, false, false])
	proof["conveyor_queue_scan_basic"] = scan_basic.get("mid") == 0 and scan_basic.get("minitem") == 0.2
	var scan_mid_one: Dictionary = conveyor_state.source_conveyor_queue_scan_state([0.1, 0.3, 0.8], [false, false, false])
	proof["conveyor_queue_scan_mid_one"] = scan_mid_one.get("mid") == 1 and scan_mid_one.get("minitem") == 0.1
	var scan_passed_skip: Dictionary = conveyor_state.source_conveyor_queue_scan_state([0.9, 0.05, 0.02], [false, false, true])
	proof["conveyor_queue_scan_passed_skip"] = scan_passed_skip.get("mid") == 0 and scan_passed_skip.get("minitem") == 0.05
	var scan_empty: Dictionary = conveyor_state.source_conveyor_queue_scan_state([], [])
	proof["conveyor_queue_scan_empty"] = scan_empty.get("mid") == 0 and scan_empty.get("minitem") == 1.0
	var scan_two: Dictionary = conveyor_state.source_conveyor_queue_scan_state([0.9, 0.6], [false, false])
	proof["conveyor_queue_scan_two"] = scan_two.get("mid") == 0 and scan_two.get("minitem") == 0.6

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConveyorQueueProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
