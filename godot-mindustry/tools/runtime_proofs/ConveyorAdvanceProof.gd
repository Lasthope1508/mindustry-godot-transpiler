extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
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

	# --- the advance moves items, capped by the item ahead, and scans mid/minitem. ---
	var moved: Dictionary = conveyor_state.source_conveyor_advance_state(["lead", "copper"], [0.2, -0.3], [0.0, 0.5], 2, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0)
	proof["conveyor_advance_move"] = moved.get("ys_after") == [0.03, 0.53] and is_equal_approx(float(moved.get("xs_after")[0]), 0.14) and is_equal_approx(float(moved.get("xs_after")[1]), -0.24) and moved.get("mid") == 0 and is_equal_approx(float(moved.get("minitem")), 0.03) and moved.get("pass_ready") == false and moved.get("no_sleep_called") == true and is_equal_approx(float(moved.get("clog_heat")), 1.0 / 60.0) and moved.get("reason") == "advanced"

	# --- the front item reaches the exit and is ready to pass. ---
	var ready: Dictionary = conveyor_state.source_conveyor_advance_state(["lead"], [0.0], [0.98], 1, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0)
	proof["conveyor_advance_ready"] = ready.get("ys_after") == [1.0] and ready.get("pass_ready") == true and ready.get("pass_item_id") == "lead" and is_equal_approx(float(ready.get("minitem")), 1.0) and is_equal_approx(float(ready.get("clog_heat")), 0.0)

	# --- an aligned next belt caps the exit below 1. ---
	var capped: Dictionary = conveyor_state.source_conveyor_advance_state(["lead"], [0.0], [0.95], 1, 0.03, 1.0, 1.0, true, 0.1, 0, 0.0)
	proof["conveyor_advance_capped"] = capped.get("ys_after") == [0.7] and capped.get("pass_ready") == false

	# --- an empty belt at time scale 1 sleeps. ---
	var empty: Dictionary = conveyor_state.source_conveyor_advance_state([], [], [], 0, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0)
	proof["conveyor_advance_empty"] = empty.get("len_after") == 0 and empty.get("reason") == "empty_sleep" and empty.get("no_sleep_called") == false and is_equal_approx(float(empty.get("clog_heat")), 0.0)

	var line: Array = []
	for x in range(15, 8, -1):
		line.append(Vector2i(x, 8))

	# --- the wrapper passes a ready item to the next belt. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(9, 8), {"ids": ["lead"], "xs": [0.0], "ys": [0.98], "len": 1})
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(10, 8), {"ids": [], "xs": [], "ys": [], "len": 0})
	var belt_pass: Dictionary = factory_state.source_factory_advance_conveyors_state(game, line, 1.0)
	var belt_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(10, 8))
	var belt_from: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(9, 8))
	proof["conveyor_advance_belt_pass"] = belt_pass.get("passed_count") == 1 and belt_after.get("ids") == ["lead"] and belt_after.get("ys") == [0.0] and belt_after.get("len") == 1 and belt_from.get("len") == 0 and belt_pass.get("results_by_cell")[Vector2i(9, 8)]["passed"] == true and belt_pass.get("results_by_cell")[Vector2i(9, 8)]["passed_to"] == "next_belt"

	# --- the wrapper passes a ready item from the last belt into the core. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(15, 8), {"ids": ["lead"], "xs": [0.0], "ys": [0.98], "len": 1})
	var core_before: int = game.core_item_count("lead")
	var core_pass: Dictionary = factory_state.source_factory_advance_conveyors_state(game, line, 1.0)
	var core_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(15, 8))
	proof["conveyor_advance_core_pass"] = core_pass.get("passed_count") == 1 and core_after.get("len") == 0 and core_pass.get("results_by_cell")[Vector2i(15, 8)]["passed"] == true and core_pass.get("results_by_cell")[Vector2i(15, 8)]["passed_to"] == "core" and game.core_item_count("lead") == core_before + 1

	# --- a full next belt caps the exit below 1, so the item never reaches it. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(10, 8), {"ids": ["copper", "lead", "silicon"], "xs": [0.0, 0.5, -0.5], "ys": [0.2, 0.8, 0.9], "len": 3})
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(9, 8), {"ids": ["lead"], "xs": [0.0], "ys": [0.98], "len": 1})
	var full_pass: Dictionary = factory_state.source_factory_advance_conveyors_state(game, line, 1.0)
	var full_from: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(9, 8))
	proof["conveyor_advance_full_refusal"] = full_pass.get("passed_count") == 0 and full_from.get("ids") == ["lead"] and full_from.get("ys") == [0.83] and full_from.get("len") == 1 and full_pass.get("results_by_cell")[Vector2i(9, 8)]["passed"] == false and full_pass.get("results_by_cell")[Vector2i(9, 8)]["pass_ready"] == false

	# --- the live loop itself advances the belts. ---
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(10, 8), {"ids": [], "xs": [], "ys": [], "len": 0})
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(9, 8), {"ids": ["lead"], "xs": [0.0], "ys": [0.98], "len": 1})
	factory_state.simulate_factory(game, 1.0)
	var live_next: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(10, 8))
	proof["conveyor_advance_live_loop"] = live_next.get("ids") == ["lead"] and live_next.get("len") == 1

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConveyorAdvanceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
