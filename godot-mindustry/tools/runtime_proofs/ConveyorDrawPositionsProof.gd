extends Node

const main_scene := preload("res://scenes/Main.tscn")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
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

	var queue := {"ids": ["copper", "lead"], "xs": [0.0, 0.5], "ys": [0.0, 0.5], "len": 2}
	var center := Vector2(100.0, 100.0)

	# --- rotation 0 (east): ys runs west to east, xs runs south. ---
	var east: Dictionary = conveyor_state.source_conveyor_item_draw_positions_state(queue, center, 0, 8.0)
	proof["draw_positions_east"] = east.get("count") == 2 and east["positions"][0]["item_id"] == "copper" and is_equal_approx(float(east["positions"][0]["x"]), 96.0) and is_equal_approx(float(east["positions"][0]["y"]), 100.0) and east["positions"][1]["item_id"] == "lead" and is_equal_approx(float(east["positions"][1]["x"]), 100.0) and is_equal_approx(float(east["positions"][1]["y"]), 102.0)

	# --- rotation 1 (north): ys runs south to north, xs runs east. ---
	var north: Dictionary = conveyor_state.source_conveyor_item_draw_positions_state(queue, center, 1, 8.0)
	proof["draw_positions_north"] = north.get("count") == 2 and north["positions"][0]["item_id"] == "copper" and is_equal_approx(float(north["positions"][0]["x"]), 100.0) and is_equal_approx(float(north["positions"][0]["y"]), 104.0) and north["positions"][1]["item_id"] == "lead" and is_equal_approx(float(north["positions"][1]["x"]), 102.0) and is_equal_approx(float(north["positions"][1]["y"]), 100.0)

	# --- rotation 2 (west): the entry edge is east of center. ---
	var west: Dictionary = conveyor_state.source_conveyor_item_draw_positions_state(queue, center, 2, 8.0)
	proof["draw_positions_west"] = west.get("count") == 2 and is_equal_approx(float(west["positions"][0]["x"]), 104.0) and is_equal_approx(float(west["positions"][0]["y"]), 100.0)

	# --- an empty queue positions nothing. ---
	var empty: Dictionary = conveyor_state.source_conveyor_item_draw_positions_state({"ids": [], "xs": [], "ys": [], "len": 0}, center, 0, 8.0)
	proof["draw_positions_empty"] = empty.get("count") == 0 and empty.get("positions") == []

	# --- the real (9,8) belt: queue-derived positions from its sprite center. ---
	var belt_cell := Vector2i(9, 8)
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, belt_cell, queue)
	var live_queue: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, belt_cell)
	var belt: Sprite2D = game.call("block_sprite_at_cell", belt_cell)
	var live: Dictionary = conveyor_state.source_conveyor_item_draw_positions_state(live_queue, belt.position, int(belt.get_meta("rotation", 0)), 8.0)
	proof["draw_positions_live_belt"] = live.get("count") == 2 and live["positions"][0]["item_id"] == "copper" and is_equal_approx(float(live["positions"][0]["x"]), belt.position.x - 4.0) and is_equal_approx(float(live["positions"][0]["y"]), belt.position.y) and live["positions"][1]["item_id"] == "lead" and is_equal_approx(float(live["positions"][1]["x"]), belt.position.x) and is_equal_approx(float(live["positions"][1]["y"]), belt.position.y + 2.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConveyorDrawPositionsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
