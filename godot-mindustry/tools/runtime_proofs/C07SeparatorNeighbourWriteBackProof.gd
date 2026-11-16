extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- The shared neighbour write-back helper (N2353):
	# offload() (BuildingComp.java:1001-1016) hands the item
	# to the first accepting neighbour via
	# `other.handleItem(self(), item);` (:1009), and
	# handleItem is `items.add(item, 1);`
	# (BuildingComp.java:860-862). N2343 routed the pick but
	# only bumped the ephemeral neighbour dict; the helper
	# lands the item for real. Index i is ring cell i (the
	# source_block_proximity_cells_state ring, angle-sorted):
	# for a size-2 source at (60, 40) ring 0 is (60, 39) and
	# ring 2 is (62, 40) -- the live fill must fill the frame
	# neighbour inputs in ring order.
	var direct_ring: Array = block_geometry.source_block_proximity_cells_state(2, 60, 40).get("cells", [])
	var direct_cell: Vector2i = direct_ring[0]

	# Frame neighbour: a separator at ring 0 with a bound
	# frame takes 1 copper, then 2 more -- the frame items
	# land through the shared inventory add_item_state and
	# the frame is written back with set_meta (the N2142
	# precedent).
	var frame_neighbour := Sprite2D.new()
	game.add_child(frame_neighbour)
	game.call("record_placed_block", frame_neighbour, blocks_by_id["separator"], direct_cell)
	separator_build_state.source_separator_bind_frame_state(frame_neighbour, blocks_by_id["separator"])
	var frame_write: Dictionary = building_item_state.source_neighbour_item_write_back_state(game, Vector2i(60, 40), 2, 0, "copper", 1)
	var frame_write_two: Dictionary = building_item_state.source_neighbour_item_write_back_state(game, Vector2i(60, 40), 2, 0, "copper", 2)
	var frame_neighbour_frame: Dictionary = frame_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var frame_neighbour_items: Dictionary = frame_neighbour_frame.get("items", {})
	proof["write_back_frame_neighbour_lands_item"] = direct_cell == Vector2i(60, 39) and bool(frame_write.get("written", false)) and str(frame_write.get("reason", "")) == "live_frame" and frame_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(60, 39) and bool(frame_write_two.get("written", false)) and int(frame_neighbour_items.get("copper", -1)) == 3

	# Belt neighbour: a rotation-0 conveyor at ring 0 with an
	# empty queue takes 1 lead through
	# ConveyorBuild.handleItem (Conveyor.java:362-376,
	# `if(len >= capacity) return;`, itemSpace 0.4f /
	# capacity 3, :27-28) -- the queue lands back through
	# source_conveyor_set_queue_for_cell_state. The belt is
	# told from a building neighbour by the conveyor queue
	# meta key on the sprite (checked first: a conveyor's
	# handleItem goes to its belt queue, never to a frame).
	var belt_ring: Array = block_geometry.source_block_proximity_cells_state(2, 70, 40).get("cells", [])
	var belt_cell: Vector2i = belt_ring[0]
	var belt_sprite := Sprite2D.new()
	game.add_child(belt_sprite)
	game.call("record_placed_block", belt_sprite, blocks_by_id["conveyor"], belt_cell)
	belt_sprite.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0)
	conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(game, belt_cell, {"ids": [], "xs": [], "ys": [], "len": 0})
	var belt_write: Dictionary = building_item_state.source_neighbour_item_write_back_state(game, Vector2i(70, 40), 2, 0, "lead", 1)
	var belt_queues: Dictionary = conveyor_runtime_state.source_conveyor_queues_for_cells_state(game, [belt_cell]).get("queues_by_cell", {})
	var belt_queue: Dictionary = belt_queues.get(belt_cell, {})
	var belt_ids: Array = belt_queue.get("ids", [])
	proof["write_back_belt_neighbour_queues_item"] = belt_cell == Vector2i(70, 39) and bool(belt_write.get("written", false)) and str(belt_write.get("reason", "")) == "belt" and belt_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(70, 39) and int(belt_queue.get("len", -1)) == 1 and belt_ids.size() == 1 and String(belt_ids[0]) == "lead"

	# Storeless neighbour: a copper wall at ring 0 carries
	# neither a conveyor queue nor a family frame, so the
	# write reports no_frame -- the item is already routed
	# away, so there is no fallback to the source store.
	# (Core / conduit neighbours are the same shape: no frame
	# in SOURCE_CONSUMER_FRAME_META_KEYS.)
	var wall_ring: Array = block_geometry.source_block_proximity_cells_state(2, 80, 40).get("cells", [])
	var wall_cell: Vector2i = wall_ring[0]
	var wall_sprite := Sprite2D.new()
	game.add_child(wall_sprite)
	game.call("record_placed_block", wall_sprite, blocks_by_id["copper-wall"], wall_cell)
	var wall_write: Dictionary = building_item_state.source_neighbour_item_write_back_state(game, Vector2i(80, 40), 2, 0, "copper", 1)
	proof["write_back_no_frame_reports_no_frame"] = wall_cell == Vector2i(80, 39) and bool(wall_write.get("written", true)) == false and str(wall_write.get("reason", "")) == "no_frame" and wall_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(80, 39) and not wall_sprite.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not wall_sprite.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	# Empty cell: no sprite at ring 0 reports no_sprite.
	# Guards: an out-of-range index reports invalid_index
	# (the size-2 ring has 8 cells, so index 8 is out), and
	# a non-positive amount reports invalid_amount.
	var empty_ring: Array = block_geometry.source_block_proximity_cells_state(2, 90, 40).get("cells", [])
	var empty_cell: Vector2i = empty_ring[0]
	var empty_write: Dictionary = building_item_state.source_neighbour_item_write_back_state(game, Vector2i(90, 40), 2, 0, "copper", 1)
	var index_write: Dictionary = building_item_state.source_neighbour_item_write_back_state(game, Vector2i(90, 40), 2, 8, "copper", 1)
	var amount_write: Dictionary = building_item_state.source_neighbour_item_write_back_state(game, Vector2i(90, 40), 2, 0, "copper", 0)
	proof["write_back_no_sprite_reports_no_sprite"] = empty_cell == Vector2i(90, 39) and bool(empty_write.get("written", true)) == false and str(empty_write.get("reason", "")) == "no_sprite" and empty_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(90, 39) and bool(index_write.get("written", true)) == false and str(index_write.get("reason", "")) == "invalid_index" and bool(amount_write.get("written", true)) == false and str(amount_write.get("reason", "")) == "invalid_amount"

	# --- The advance exposes the offload outcome: the
	# routed neighbour index is the handled index from
	# offload_item_state (SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY,
	# -1 when no offload ran or it fell back) and
	# offload_routed is the routed flag. The craft values
	# are the N2222 proof values: seed 1 over sum 12 gives
	# index 11, the titanium window [10, 12).
	var separator_results: Array = [{"item": "copper", "amount": 5}, {"item": "lead", "amount": 3}, {"item": "graphite", "amount": 2}, {"item": "titanium", "amount": 2}]
	var route_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 0}
	var route_context: Dictionary = {"neighbors": [{"accepts_item": false, "can_dump": true, "item_count": 0}, {"accepts_item": true, "can_dump": true, "item_count": 0}, {"accepts_item": false, "can_dump": true, "item_count": 0}], "dump_cursor": 0}
	var routed: Dictionary = separator_build_state.source_separator_update_tile_advance_state(route_frame, 1.0, 1.0, 35.0, separator_results, [], 10, route_context)
	var routed_items: Dictionary = routed.get("items", {})
	var fallback_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 0}
	var fallback_context: Dictionary = {"neighbors": [{"accepts_item": false, "can_dump": true, "item_count": 0}, {"accepts_item": false, "can_dump": true, "item_count": 0}], "dump_cursor": 0}
	var fell_back: Dictionary = separator_build_state.source_separator_update_tile_advance_state(fallback_frame, 1.0, 1.0, 35.0, separator_results, [], 10, fallback_context)
	var fell_back_items: Dictionary = fell_back.get("items", {})
	var full_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {"titanium": 10}, "cdump": 0}
	var full_context: Dictionary = {"neighbors": [{"accepts_item": true, "can_dump": true, "item_count": 0}], "dump_cursor": 0}
	var full: Dictionary = separator_build_state.source_separator_update_tile_advance_state(full_frame, 1.0, 1.0, 35.0, separator_results, [], 10, full_context)
	var idle_frame: Dictionary = {"efficiency": 1.0, "progress": 0.5, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 0}
	var idle: Dictionary = separator_build_state.source_separator_update_tile_advance_state(idle_frame, 1.0, 1.0, 35.0, separator_results, [], 10, route_context)
	proof["advance_exposes_routed_neighbour_index"] = bool(routed.get("crafted", false)) and str(routed.get("picked_item", "")) == "titanium" and bool(routed.get("offload_routed", false)) and int(routed.get("offload_neighbour_index", -9)) == 1 and int(routed_items.get("titanium", 0)) == 0 and int(routed.get("cdump", -1)) == 2 and bool(fell_back.get("offload_routed", true)) == false and int(fell_back.get("offload_neighbour_index", -9)) == -1 and int(fell_back_items.get("titanium", -1)) == 1 and bool(full.get("offload_routed", true)) == false and int(full.get("offload_neighbour_index", -9)) == -1 and int(full.get("cdump", -1)) == 0 and bool(idle.get("crafted", true)) == false and bool(idle.get("offload_routed", true)) == false and int(idle.get("offload_neighbour_index", -9)) == -1

	# --- Live tick: two source separators craft in one tick
	# (the N2343 live setup: progress 0.99 at full efficiency
	# with seed 1 picks titanium, slag-full so the liquid row
	# folds 1.0, timerDump clock at 0.0 so the dump does not
	# fire). The first routes to ring 2 -- the neighbour
	# separator at (30, 21) -- and the titanium lands in its
	# frame items. The second routes to ring 0 -- a copper
	# wall with no store -- and the titanium still leaves the
	# separator (own store stays empty, cursor advances),
	# dropping with reason no_frame.
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 21).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[2]
	var separator_cell := Vector2i(28, 21)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 1.0)
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell)
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	separator_frame["items"] = {}
	separator_frame["progress"] = 0.99
	separator_frame["seed"] = 1
	separator_frame["cdump"] = 0
	separator_frame["timer_dump_elapsed"] = 0.0
	separator_frame["dump_neighbour_accepts"] = [false, false, true, false, false, false, false, false]
	separator_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	separator_frame["power_status"] = 1.0

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(2, 50, 30).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_separator_cell := Vector2i(50, 30)
	var bare_separator := Sprite2D.new()
	game.add_child(bare_separator)
	game.call("record_placed_block", bare_separator, blocks_by_id["separator"], bare_separator_cell)
	separator_build_state.source_separator_bind_frame_state(bare_separator, blocks_by_id["separator"])
	var bare_frame: Dictionary = bare_separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var bare_liquids: Dictionary = bare_separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(bare_liquids, slag_id, 1.0)
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["items"] = {}
	bare_frame["progress"] = 0.99
	bare_frame["seed"] = 1
	bare_frame["cdump"] = 0
	bare_frame["timer_dump_elapsed"] = 0.0
	bare_frame["dump_neighbour_accepts"] = [true, false, false, false, false, false, false, false]
	bare_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	bare_frame["power_status"] = 1.0

	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = separator_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_offloaded_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(30, 21) and is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(separator_frame.get("progress", -1.0)), 0.99 + 1.0 / 35.0 - 1.0) and is_equal_approx(float(separator_frame.get("warmup", -1.0)), 0.02) and int(separator_frame.get("seed", -1)) == 2 and int(live_items.get("titanium", 0)) == 0 and int(separator_frame.get("cdump", -1)) == 3 and is_equal_approx(float(separator_frame.get("timer_dump_elapsed", -1.0)), 1.0) and int(live_neighbour_items.get("titanium", -1)) == 1
	proof["live_tick_routed_item_leaves_separator_without_frame"] = bare_cell == Vector2i(50, 29) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 1.0) and int(bare_frame.get("seed", -1)) == 2 and int(bare_items.get("titanium", 0)) == 0 and int(bare_frame.get("cdump", -1)) == 1 and is_equal_approx(float(bare_frame.get("timer_dump_elapsed", -1.0)), 1.0) and not bare_wall.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorNeighbourWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
