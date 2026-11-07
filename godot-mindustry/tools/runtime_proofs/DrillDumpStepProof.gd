extends Node

const main_scene := preload("res://scenes/Main.tscn")
const geometry_state := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- proximity ring in Java angle order. ---
	var ring_two: Dictionary = geometry_state.source_block_proximity_cells_state(2, 7, 8)
	proof["drill_dump_ring_two"] = ring_two.get("cells") == [Vector2i(7, 7), Vector2i(8, 7), Vector2i(9, 8), Vector2i(9, 9), Vector2i(8, 10), Vector2i(7, 10), Vector2i(6, 9), Vector2i(6, 8)] and ring_two.get("count") == 8 and ring_two.get("reason") == "ring"
	var ring_one: Dictionary = geometry_state.source_block_proximity_cells_state(1, 10, 10)
	proof["drill_dump_ring_one"] = ring_one.get("cells") == [Vector2i(10, 9), Vector2i(11, 10), Vector2i(10, 11), Vector2i(9, 10)] and ring_one.get("count") == 4 and ring_one.get("reason") == "ring"
	var ring_three: Dictionary = geometry_state.source_block_proximity_cells_state(3, 10, 10)
	proof["drill_dump_ring_three"] = ring_three.get("cells") == [Vector2i(8, 9), Vector2i(9, 8), Vector2i(10, 8), Vector2i(11, 8), Vector2i(12, 9), Vector2i(12, 10), Vector2i(12, 11), Vector2i(11, 12), Vector2i(10, 12), Vector2i(9, 12), Vector2i(8, 11), Vector2i(8, 10)] and ring_three.get("count") == 12 and ring_three.get("reason") == "ring"
	var ring_invalid: Dictionary = geometry_state.source_block_proximity_cells_state(0, 10, 10)
	proof["drill_dump_ring_invalid"] = ring_invalid.get("cells") == [] and ring_invalid.get("count") == 0 and ring_invalid.get("reason") == "invalid_size"

	var ring: Array = ring_two.get("cells", [])
	var conveyor_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(9, 8))
	var scene_rotation := 0
	if conveyor_sprite != null:
		scene_rotation = int(conveyor_sprite.get_meta("rotation", 0))
	var rotations := {Vector2i(9, 8): scene_rotation}
	var empty_queues := {Vector2i(9, 8): {"ids": [], "xs": [], "ys": [], "len": 0}}

	# --- specific dump step: the drill's dominant item to the first accepting belt. ---
	var dump_first: Dictionary = dump_state.source_drill_dump_step_state({"lead": 3}, ring, "lead", 0, true, empty_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_step_first"] = dump_first.get("dumped") == true and dump_first.get("item_id") == "lead" and dump_first.get("receiver_index") == 2 and dump_first.get("receiver_cell") == Vector2i(9, 8) and dump_first.get("cdump_before") == 0 and dump_first.get("cdump_after") == 3 and dump_first.get("items_after") == {"lead": 2} and dump_first.get("queues_after")[Vector2i(9, 8)]["len"] == 1 and dump_first.get("queues_after")[Vector2i(9, 8)]["ids"] == ["lead"] and dump_first.get("removed") == 1 and dump_first.get("destination") == "conveyor" and dump_first.get("reason") == "dumped"
	var dump_cursor: Dictionary = dump_state.source_drill_dump_step_state({"lead": 2}, ring, "lead", 2, true, empty_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_step_cursor"] = dump_cursor.get("dumped") == true and dump_cursor.get("receiver_index") == 2 and dump_cursor.get("cdump_before") == 2 and dump_cursor.get("cdump_after") == 3 and dump_cursor.get("items_after") == {"lead": 1}
	var full_queues := {Vector2i(9, 8): {"ids": ["copper", "lead", "silicon"], "xs": [0.0, 0.5, -0.5], "ys": [0.2, 0.8, 0.9], "len": 3}}
	var dump_full: Dictionary = dump_state.source_drill_dump_step_state({"lead": 3}, ring, "lead", 0, true, full_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_step_full"] = dump_full.get("dumped") == false and dump_full.get("receiver_index") == -1 and dump_full.get("cdump_after") == 0 and dump_full.get("items_after") == {"lead": 3} and dump_full.get("destination") == "none" and dump_full.get("reason") == "no_receiver"
	var dump_empty: Dictionary = dump_state.source_drill_dump_step_state({}, ring, "lead", 0, true, empty_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_step_empty"] = dump_empty.get("dumped") == false and dump_empty.get("cdump_after") == 0 and dump_empty.get("reason") == "empty_items"
	var dump_not_held: Dictionary = dump_state.source_drill_dump_step_state({"copper": 2}, ring, "lead", 0, true, empty_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_step_not_held"] = dump_not_held.get("dumped") == false and dump_not_held.get("reason") == "item_not_held"

	# --- any dump step: dump(null) tries items in content order per neighbor. ---
	var dump_any_first: Dictionary = dump_state.source_drill_dump_any_step_state({"lead": 2, "copper": 1}, ring, 0, true, ["copper", "lead"], empty_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_any_first"] = dump_any_first.get("dumped") == true and dump_any_first.get("item_id") == "copper" and dump_any_first.get("receiver_cell") == Vector2i(9, 8) and dump_any_first.get("items_after") == {"lead": 2, "copper": 0} and dump_any_first.get("queues_after")[Vector2i(9, 8)]["ids"] == ["copper"]
	var dump_any_skip: Dictionary = dump_state.source_drill_dump_any_step_state({"lead": 2}, ring, 0, true, ["copper", "lead"], empty_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_any_skip"] = dump_any_skip.get("dumped") == true and dump_any_skip.get("item_id") == "lead" and dump_any_skip.get("items_after") == {"lead": 1}
	var dump_any_full: Dictionary = dump_state.source_drill_dump_any_step_state({"lead": 2}, ring, 0, true, ["copper", "lead"], full_queues, 3, 0.4, rotations, false, false, Vector2i(7, 8), 2)
	proof["drill_dump_any_full"] = dump_any_full.get("dumped") == false and dump_any_full.get("items_after") == {"lead": 2} and dump_any_full.get("reason") == "no_receiver"

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillDumpStepProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
