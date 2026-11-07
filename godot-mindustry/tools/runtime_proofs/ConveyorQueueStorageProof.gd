extends Node

const main_scene := preload("res://scenes/Main.tscn")
const geometry_state := preload("res://src/game/SourceBlockGeometry.gd")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
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

	# --- read: an empty belt, a missing sprite, and a non-conveyor sprite. ---
	var read_empty: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(9, 8))
	proof["queue_storage_read_empty"] = read_empty.get("ids") == [] and read_empty.get("xs") == [] and read_empty.get("ys") == [] and read_empty.get("len") == 0 and read_empty.get("found") == true and read_empty.get("reason") == "no_queue"
	var read_missing: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(7, 7))
	proof["queue_storage_read_missing"] = read_missing.get("len") == 0 and read_missing.get("found") == false and read_missing.get("reason") == "no_sprite"
	var read_drill: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(7, 8))
	proof["queue_storage_read_other_sprite"] = read_drill.get("len") == 0 and read_drill.get("found") == true and read_drill.get("reason") == "no_queue"

	# --- write then read back, and the missing-sprite refusal. ---
	var write_belt: Dictionary = conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(9, 8), {"ids": ["lead"], "xs": [0.0], "ys": [0.8], "len": 1})
	var read_back: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(9, 8))
	proof["queue_storage_write_read_back"] = write_belt.get("stored") == true and write_belt.get("reason") == "stored" and read_back.get("ids") == ["lead"] and read_back.get("xs") == [0.0] and read_back.get("ys") == [0.8] and read_back.get("len") == 1 and read_back.get("found") == true and read_back.get("reason") == "queue"
	var write_missing: Dictionary = conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(7, 7), {"ids": ["lead"], "xs": [0.0], "ys": [0.0], "len": 1})
	var read_missing_after: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(7, 7))
	proof["queue_storage_write_missing"] = write_missing.get("stored") == false and write_missing.get("reason") == "no_sprite" and read_missing_after.get("found") == false and read_missing_after.get("reason") == "no_sprite"

	# --- resolve the drill's ring plus a second belt, and the all-air case. ---
	var ring: Array = geometry_state.source_block_proximity_cells_state(2, 7, 8).get("cells", [])
	conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(10, 8), {"ids": [], "xs": [], "ys": [], "len": 0})
	var resolved: Dictionary = conveyor_state.source_conveyor_queues_for_cells_state(game, ring + [Vector2i(10, 8)])
	var queues_by_cell: Dictionary = resolved.get("queues_by_cell", {})
	proof["queue_storage_resolve_ring"] = resolved.get("found_count") == 2 and resolved.get("reason") == "resolved" and queues_by_cell.keys() == [Vector2i(9, 8), Vector2i(10, 8)] and queues_by_cell[Vector2i(9, 8)]["ids"] == ["lead"] and queues_by_cell[Vector2i(9, 8)]["len"] == 1 and queues_by_cell[Vector2i(10, 8)]["len"] == 0
	var resolved_none: Dictionary = conveyor_state.source_conveyor_queues_for_cells_state(game, [Vector2i(7, 7), Vector2i(6, 8)])
	proof["queue_storage_resolve_none"] = resolved_none.get("queues_by_cell") == {} and resolved_none.get("found_count") == 0 and resolved_none.get("reason") == "none_found"

	# --- round trip: resolve the ring, run the dump step, write the belt back. ---
	var conveyor_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(9, 8))
	var scene_rotation := 0
	if conveyor_sprite != null:
		scene_rotation = int(conveyor_sprite.get_meta("rotation", 0))
	var ring_queues: Dictionary = conveyor_state.source_conveyor_queues_for_cells_state(game, ring)
	var dump: Dictionary = dump_state.source_drill_dump_step_state({"lead": 3}, ring, "lead", 0, true, ring_queues.get("queues_by_cell", {}), 3, 0.4, {Vector2i(9, 8): scene_rotation}, false, false, Vector2i(7, 8), 2)
	var write_after_dump: Dictionary = conveyor_state.source_conveyor_set_queue_for_cell_state(game, Vector2i(9, 8), dump.get("queues_after", {}).get(Vector2i(9, 8), {}))
	var read_after_dump: Dictionary = conveyor_state.source_conveyor_queue_for_cell_state(game, Vector2i(9, 8))
	proof["queue_storage_dump_round_trip"] = dump.get("dumped") == true and dump.get("receiver_cell") == Vector2i(9, 8) and write_after_dump.get("stored") == true and read_after_dump.get("ids") == ["lead", "lead"] and read_after_dump.get("len") == 2 and read_after_dump.get("reason") == "queue"

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ConveyorQueueStorageProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
