extends Node

const main_scene := preload("res://scenes/Main.tscn")
const geometry_state := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- facing edge: the multiblock clamp from Edges.getFacingEdge. ---
	var edge_east: Dictionary = geometry_state.source_block_facing_edge_state(2, 7, 8, 9, 8)
	proof["drill_conveyor_edge_east"] = edge_east.get("edge_x") == 8 and edge_east.get("edge_y") == 8 and edge_east.get("is_multiblock") == true and edge_east.get("reason") == "facing_edge"
	var edge_west: Dictionary = geometry_state.source_block_facing_edge_state(2, 7, 8, 6, 8)
	proof["drill_conveyor_edge_west"] = edge_west.get("edge_x") == 7 and edge_west.get("edge_y") == 8 and edge_west.get("is_multiblock") == true and edge_west.get("reason") == "facing_edge"
	var edge_north: Dictionary = geometry_state.source_block_facing_edge_state(2, 7, 8, 7, 7)
	proof["drill_conveyor_edge_north"] = edge_north.get("edge_x") == 7 and edge_north.get("edge_y") == 8 and edge_north.get("is_multiblock") == true
	var edge_corner: Dictionary = geometry_state.source_block_facing_edge_state(2, 7, 8, 9, 9)
	proof["drill_conveyor_edge_corner"] = edge_corner.get("edge_x") == 8 and edge_corner.get("edge_y") == 9 and edge_corner.get("is_multiblock") == true
	var edge_single: Dictionary = geometry_state.source_block_facing_edge_state(1, 7, 8, 9, 8)
	proof["drill_conveyor_edge_single"] = edge_single.get("edge_x") == 7 and edge_single.get("edge_y") == 8 and edge_single.get("is_multiblock") == false and edge_single.get("reason") == "tile"
	var edge_size_three: Dictionary = geometry_state.source_block_facing_edge_state(3, 10, 10, 12, 10)
	proof["drill_conveyor_edge_size_three"] = edge_size_three.get("edge_x") == 11 and edge_size_three.get("edge_y") == 10 and edge_size_three.get("is_multiblock") == true

	# --- accept for a real neighbor cell, from the drill's facing edge. ---
	var accept_straight: Dictionary = conveyor_state.source_conveyor_accept_for_cell_state([], [], [], 0, 3, 0.4, Vector2i(8, 8), Vector2i(9, 8), 0, false, false)
	proof["drill_conveyor_accept_straight"] = accept_straight.get("accepted") == true and accept_straight.get("direction") == 0 and accept_straight.get("facing_direction") == 0 and accept_straight.get("minitem") == 1.0 and accept_straight.get("reason") == "accepted"
	var accept_side: Dictionary = conveyor_state.source_conveyor_accept_for_cell_state([], [], [], 0, 3, 0.4, Vector2i(9, 7), Vector2i(9, 8), 0, false, false)
	proof["drill_conveyor_accept_side"] = accept_side.get("accepted") == true and accept_side.get("direction") == 1 and accept_side.get("facing_direction") == 1 and accept_side.get("minitem") == 1.0 and accept_side.get("reason") == "accepted"
	var accept_full: Dictionary = conveyor_state.source_conveyor_accept_for_cell_state(["copper", "lead", "silicon"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, 3, 0.4, Vector2i(8, 8), Vector2i(9, 8), 0, false, false)
	proof["drill_conveyor_accept_full"] = accept_full.get("accepted") == false and accept_full.get("reason") == "at_capacity"
	var accept_wrong: Dictionary = conveyor_state.source_conveyor_accept_for_cell_state([], [], [], 0, 3, 0.4, Vector2i(10, 8), Vector2i(9, 8), 0, false, false)
	proof["drill_conveyor_accept_wrong"] = accept_wrong.get("accepted") == false and accept_wrong.get("direction") == 2 and accept_wrong.get("facing_direction") == 2 and accept_wrong.get("reason") == "wrong_direction"
	var accept_loop: Dictionary = conveyor_state.source_conveyor_accept_for_cell_state([], [], [], 0, 3, 0.4, Vector2i(8, 8), Vector2i(9, 8), 0, true, true)
	proof["drill_conveyor_accept_loop"] = accept_loop.get("accepted") == false and accept_loop.get("reason") == "rotate_loop"
	var conveyor_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(9, 8))
	var scene_rotation := 0
	if conveyor_sprite != null:
		scene_rotation = int(conveyor_sprite.get_meta("rotation", 0))
	var accept_scene: Dictionary = conveyor_state.source_conveyor_accept_for_cell_state([], [], [], 0, 3, 0.4, Vector2i(int(edge_east.get("edge_x", 8)), int(edge_east.get("edge_y", 8))), Vector2i(9, 8), scene_rotation, false, false)
	proof["drill_conveyor_accept_scene"] = accept_scene.get("facing_direction") == 0 and accept_scene.get("direction") == abs(0 - scene_rotation) and accept_scene.get("accepted") == true

	# --- handle for a real neighbor cell, from the drill's facing edge. ---
	var handle_straight: Dictionary = conveyor_state.source_conveyor_handle_for_cell_state([], [], [], 0, 3, 0.4, Vector2i(8, 8), Vector2i(9, 8), 0, "lead", 0)
	proof["drill_conveyor_handle_straight"] = handle_straight.get("ids_after") == ["lead"] and handle_straight.get("xs_after") == [0.0] and handle_straight.get("ys_after") == [0.0] and handle_straight.get("len_after") == 1 and handle_straight.get("index") == 0 and handle_straight.get("x") == 0.0 and handle_straight.get("y") == 0.0 and handle_straight.get("item_count_after") == 1 and handle_straight.get("no_sleep_called") == true and handle_straight.get("reason") == "accepted"
	var handle_side: Dictionary = conveyor_state.source_conveyor_handle_for_cell_state(["copper", "lead", "silicon"], [0.0, 0.5, -0.5], [0.1, 0.3, 0.8], 3, 5, 0.4, Vector2i(9, 7), Vector2i(9, 8), 0, "lead", 1)
	proof["drill_conveyor_handle_side"] = handle_side.get("ids_after") == ["copper", "lead", "lead", "silicon"] and handle_side.get("ys_after") == [0.1, 0.5, 0.3, 0.8] and handle_side.get("len_after") == 4 and handle_side.get("index") == 1 and handle_side.get("x") == -1.0 and handle_side.get("y") == 0.5 and handle_side.get("item_count_after") == 2 and handle_side.get("no_sleep_called") == true
	var handle_full: Dictionary = conveyor_state.source_conveyor_handle_for_cell_state(["copper", "lead", "silicon"], [0.0, 0.5, -0.5], [0.2, 0.8, 0.9], 3, 3, 0.4, Vector2i(8, 8), Vector2i(9, 8), 0, "lead", 1)
	proof["drill_conveyor_handle_full"] = handle_full.get("ids_after") == ["copper", "lead", "silicon"] and handle_full.get("len_after") == 3 and handle_full.get("index") == -1 and handle_full.get("item_count_after") == 1 and handle_full.get("no_sleep_called") == false and handle_full.get("reason") == "at_capacity"
	var handle_scene: Dictionary = conveyor_state.source_conveyor_handle_for_cell_state([], [], [], 0, 3, 0.4, Vector2i(int(edge_east.get("edge_x", 8)), int(edge_east.get("edge_y", 8))), Vector2i(9, 8), scene_rotation, "lead", 0)
	proof["drill_conveyor_handle_scene"] = handle_scene.get("ids_after") == ["lead"] and handle_scene.get("len_after") == 1 and handle_scene.get("index") == 0 and handle_scene.get("no_sleep_called") == true

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillConveyorDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
