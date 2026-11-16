extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- Pure advance (N2398): offload() (BuildingComp.
	# java:1001-1014) scans proximity from the saved cdump
	# (`int dump = this.cdump;`, `incrementDump(proximity.
	# size);` before each check) and hands the produced item
	# to the first neighbour where `other.acceptItem(self(),
	# item) && canDump(other, item)` holds
	# (`other.handleItem(self(), item);`, :1009), falling
	# back to `handleItem(self(), item);` (:1014) when no
	# neighbour takes it. The port routes the produced
	# output through the shared dump_item_state routing (the
	# N2283 timerDump pattern) over the SAME neighbour
	# acceptItem/canDump frame inputs and the SAME cdump
	# cursor, and exposes the routing as ONE scalar key
	# (offload_neighbour_index, -1 when it stayed home) plus
	# the post-offload cdump. The large-def values are the
	# N2223 proof values (drillTime 48f, sand, capacity 20).
	var routed: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 47.0, "items": {}, "cdump": 0, "dump_neighbour_accepts": [false, true], "dump_neighbour_can_dump": [true, true]}, 1.0, 1.0, 48.0, "sand", 20)
	var routed_items: Dictionary = routed.get("items", {})
	var wrapped: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 47.0, "items": {}, "cdump": 1, "dump_neighbour_accepts": [true, false], "dump_neighbour_can_dump": [true, true]}, 1.0, 1.0, 48.0, "sand", 20)
	var wrapped_items: Dictionary = wrapped.get("items", {})
	var refused: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 47.0, "items": {}, "cdump": 0, "dump_neighbour_accepts": [false, false], "dump_neighbour_can_dump": [true, true]}, 1.0, 1.0, 48.0, "sand", 20)
	var refused_items: Dictionary = refused.get("items", {})
	var cannot_dump: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 47.0, "items": {}, "cdump": 0, "dump_neighbour_accepts": [true], "dump_neighbour_can_dump": [false]}, 1.0, 1.0, 48.0, "sand", 20)
	var cannot_dump_items: Dictionary = cannot_dump.get("items", {})
	var no_neighbours: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 47.0, "items": {}, "cdump": 0, "dump_neighbour_accepts": [], "dump_neighbour_can_dump": []}, 1.0, 1.0, 48.0, "sand", 20)
	var no_neighbours_items: Dictionary = no_neighbours.get("items", {})
	var idle: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 10.0, "items": {}, "cdump": 5, "dump_neighbour_accepts": [true], "dump_neighbour_can_dump": [true]}, 1.0, 1.0, 48.0, "sand", 20)
	var idle_items: Dictionary = idle.get("items", {})
	proof["advance_exposes_offload_neighbour_index"] = is_equal_approx(float(routed.get("time", -1.0)), 0.0) and bool(routed.get("offloaded", false)) and int(routed.get("offload_neighbour_index", -9)) == 1 and int(routed.get("cdump", -1)) == 2 and int(routed_items.get("sand", -1)) == 0 and int(wrapped.get("offload_neighbour_index", -9)) == 0 and int(wrapped.get("cdump", -1)) == 1 and int(wrapped_items.get("sand", -1)) == 0 and bool(refused.get("offloaded", false)) and int(refused.get("offload_neighbour_index", -9)) == -1 and int(refused.get("cdump", -1)) == 0 and int(refused_items.get("sand", -1)) == 1 and int(cannot_dump.get("offload_neighbour_index", -9)) == -1 and int(cannot_dump.get("cdump", -1)) == 0 and int(cannot_dump_items.get("sand", -1)) == 1 and int(no_neighbours.get("offload_neighbour_index", -9)) == -1 and int(no_neighbours.get("cdump", -1)) == 0 and int(no_neighbours_items.get("sand", -1)) == 1 and bool(idle.get("offloaded", true)) == false and int(idle.get("offload_neighbour_index", -9)) == -1 and int(idle.get("cdump", -1)) == 5 and int(idle_items.get("sand", 0)) == 0

	# --- Live tick: three cliff-crushers offload in one tick
	# (the N2223 live setup: two solid edge tiles at 0.5 each
	# sum to efficiency_factor 1.0, power_status 1.0 folds
	# efficiency 1.0, time 109.0 reaches the 110f drillTime
	# in one 1/60s tick; the timerDump clock starts at 0.0 so
	# the dump does not fire). The first routes to ring 2 --
	# the neighbour cliff-crusher at (30, 21) -- and the sand
	# lands in its frame items. The second routes to ring 0 --
	# a copper wall with no store -- and the sand still leaves
	# the crafter (own store stays empty, cursor advances),
	# dropping with reason no_frame. The third has no
	# accepting neighbour and falls back to its own inventory.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 21).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[2]
	var crusher_cell := Vector2i(28, 21)
	var crusher := Sprite2D.new()
	game.add_child(crusher)
	game.call("record_placed_block", crusher, blocks_by_id["cliff-crusher"], crusher_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(crusher, blocks_by_id["cliff-crusher"])
	var crusher_frame: Dictionary = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["cliff-crusher"], live_neighbour_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(live_neighbour, blocks_by_id["cliff-crusher"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	crusher_frame["items"] = {}
	crusher_frame["power_status"] = 1.0
	crusher_frame["time"] = 109.0
	crusher_frame["cdump"] = 0
	crusher_frame["timer_dump_elapsed"] = 0.0
	crusher_frame["dump_neighbour_accepts"] = [false, false, true, false, false, false, false, false]
	crusher_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	crusher_frame["wall_edge_tiles"] = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.5},
	]

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(2, 50, 30).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_crusher_cell := Vector2i(50, 30)
	var bare_crusher := Sprite2D.new()
	game.add_child(bare_crusher)
	game.call("record_placed_block", bare_crusher, blocks_by_id["cliff-crusher"], bare_crusher_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(bare_crusher, blocks_by_id["cliff-crusher"])
	var bare_frame: Dictionary = bare_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["items"] = {}
	bare_frame["power_status"] = 1.0
	bare_frame["time"] = 109.0
	bare_frame["cdump"] = 0
	bare_frame["timer_dump_elapsed"] = 0.0
	bare_frame["dump_neighbour_accepts"] = [true, false, false, false, false, false, false, false]
	bare_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	bare_frame["wall_edge_tiles"] = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.5},
	]

	var fallback_crusher_cell := Vector2i(70, 40)
	var fallback_crusher := Sprite2D.new()
	game.add_child(fallback_crusher)
	game.call("record_placed_block", fallback_crusher, blocks_by_id["cliff-crusher"], fallback_crusher_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(fallback_crusher, blocks_by_id["cliff-crusher"])
	var fallback_frame: Dictionary = fallback_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})

	fallback_frame["items"] = {}
	fallback_frame["power_status"] = 1.0
	fallback_frame["time"] = 109.0
	fallback_frame["cdump"] = 0
	fallback_frame["timer_dump_elapsed"] = 0.0
	fallback_frame["dump_neighbour_accepts"] = [false, false, false, false, false, false, false, false]
	fallback_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	fallback_frame["wall_edge_tiles"] = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.5},
	]

	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	crusher_frame = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	bare_frame = bare_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	fallback_frame = fallback_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var live_items: Dictionary = crusher_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	var fallback_items: Dictionary = fallback_frame.get("items", {})
	proof["live_tick_routes_offloaded_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(30, 21) and is_equal_approx(float(crusher_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("time", -1.0)), 0.0) and bool(crusher_frame.get("offloaded", false)) and int(live_items.get("sand", 0)) == 0 and int(crusher_frame.get("offload_neighbour_index", -9)) == 2 and int(crusher_frame.get("cdump", -1)) == 3 and is_equal_approx(float(crusher_frame.get("timer_dump_elapsed", -1.0)), 1.0) and int(live_neighbour_items.get("sand", -1)) == 1
	proof["live_tick_routed_item_leaves_crafter_without_frame"] = bare_cell == Vector2i(50, 29) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(bare_frame.get("time", -1.0)), 0.0) and bool(bare_frame.get("offloaded", false)) and int(bare_items.get("sand", 0)) == 0 and int(bare_frame.get("offload_neighbour_index", -9)) == 0 and int(bare_frame.get("cdump", -1)) == 1 and not bare_wall.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not bare_wall.has_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY)
	proof["live_tick_offload_falls_back_to_inventory"] = is_equal_approx(float(fallback_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(fallback_frame.get("time", -1.0)), 0.0) and bool(fallback_frame.get("offloaded", false)) and int(fallback_items.get("sand", -1)) == 1 and int(fallback_frame.get("offload_neighbour_index", -9)) == -1 and int(fallback_frame.get("cdump", -1)) == 0 and is_equal_approx(float(fallback_frame.get("timer_dump_elapsed", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterOffloadRoutingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
