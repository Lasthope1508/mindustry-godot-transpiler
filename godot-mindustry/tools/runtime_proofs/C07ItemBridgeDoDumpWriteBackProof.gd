extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
const building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
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

	# --- The doDump advance exposes its deliveries (N2362):
	# N2288 ported the unlinked-branch doDump
	# (ItemBridge.java:335-337, dumpAccumulate() at
	# :350-353, dump(null) through the shared
	# dump_item_state routing, BuildingComp.java:
	# 1072-1113) -- but the dumped item left the bridge
	# without landing in any neighbour store. Java hands
	# it over for real (`other.handleItem(self(), item);`,
	# BuildingComp.java:1089), and handleItem is
	# `items.add(item, 1);` (BuildingComp.java:860-862).
	# dumpAccumulate can dump MULTIPLE times per frame
	# ("allow dumping multiple times per frame",
	# ItemBridge.java:351), so the advance returns
	# dump_deliveries -- one {"neighbour_index": ...,
	# "item": ...} dict per successful attempt, in attempt
	# order (empty when nothing dumped) -- and the tick
	# lands each one through the shared N2353 helper.
	# Index i is ring cell i (the N2353 convention): the
	# helper resolves the index through the
	# source_block_proximity_cells_state ring. Content
	# items here are ["copper", "lead"] in catalog order;
	# the dump takes the first held item in that order.
	var item_ids: Array = ["copper", "lead"]
	var one_accepting: Array = [true]
	var one_can_dump: Array = [true]

	# A single dump delivers one item to neighbour 0: the
	# accumulator fires once (0.0 + 1.0), copper 3 -> 2,
	# the cursor stays 0 over the single neighbour, and
	# the single delivery is {neighbour_index 0, copper}.
	var single_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var single: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(single_frame, false, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var single_items: Dictionary = single.get("items_after", {})
	var single_deliveries: Array = single.get("dump_deliveries", [])
	var single_delivery: Dictionary = single_deliveries[0] if single_deliveries.size() == 1 else {}

	# A large delta dumps multiple times per frame: 0.0 +
	# 3.0 fires 3 attempts (copper 5 -> 2, remainder 0.0)
	# and delivers 3 coppers, all to neighbour 0 -- a
	# scalar routed index would have dropped two of them.
	var multi_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var multi: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(multi_frame, false, 3.0, 1.0, item_ids, one_accepting, one_can_dump)
	var multi_items: Dictionary = multi.get("items_after", {})
	var multi_deliveries: Array = multi.get("dump_deliveries", [])
	var multi_all_copper_to_zero := multi_deliveries.size() == 3
	for delivery in multi_deliveries:
		var entry: Dictionary = delivery
		multi_all_copper_to_zero = multi_all_copper_to_zero and int(entry.get("neighbour_index", -9)) == 0 and str(entry.get("item", "")) == "copper"

	# The second neighbour takes the delivery when the
	# first rejects: accepts [false, true] routes to
	# index 1 (the cursor wraps back to 0 after the
	# two-neighbour scan) and copper 3 -> 2.
	var second_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var second: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(second_frame, false, 1.0, 1.0, item_ids, [false, true], [true, true])
	var second_items: Dictionary = second.get("items_after", {})
	var second_deliveries: Array = second.get("dump_deliveries", [])
	var second_delivery: Dictionary = second_deliveries[0] if second_deliveries.size() == 1 else {}

	# No dump means no deliveries: linked (0 attempts,
	# the store untouched), a rejecting neighbour (1
	# attempt, dumped false, the store untouched), and an
	# empty store (1 attempt, dumped false, the
	# accumulator still spends its 1f).
	var linked_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var linked: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(linked_frame, true, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var rejected_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var rejected: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(rejected_frame, false, 1.0, 1.0, item_ids, [false], one_can_dump)
	var empty_frame: Dictionary = {"items": {}, "dump_accum": 0.0, "cdump": 0}
	var empty: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(empty_frame, false, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	proof["advance_exposes_dump_deliveries"] = int(single.get("dump_attempts", -1)) == 1 and bool(single.get("dumped", false)) and int(single_items.get("copper", -1)) == 2 and int(single.get("cursor_after", -1)) == 0 and single_deliveries.size() == 1 and int(single_delivery.get("neighbour_index", -9)) == 0 and str(single_delivery.get("item", "")) == "copper" and int(multi.get("dump_attempts", -1)) == 3 and bool(multi.get("dumped", false)) and int(multi_items.get("copper", -1)) == 2 and multi_all_copper_to_zero and bool(second.get("dumped", false)) and int(second_items.get("copper", -1)) == 2 and int(second.get("cursor_after", -1)) == 0 and second_deliveries.size() == 1 and int(second_delivery.get("neighbour_index", -9)) == 1 and str(second_delivery.get("item", "")) == "copper" and int(linked.get("dump_attempts", -1)) == 0 and not bool(linked.get("dumped", true)) and (linked.get("dump_deliveries", [1]) as Array).is_empty() and int(rejected.get("dump_attempts", -1)) == 1 and not bool(rejected.get("dumped", true)) and (rejected.get("dump_deliveries", [1]) as Array).is_empty() and int(empty.get("dump_attempts", -1)) == 1 and not bool(empty.get("dumped", true)) and (empty.get("dump_deliveries", [1]) as Array).is_empty()

	# --- Live tick: two unlinked phase-conveyors dump in
	# one tick (the N2288 live setup: link -1,
	# had_valid_link false, 3 copper in the frame items,
	# one accepting neighbour stamped as frame inputs).
	# The first dumps to ring 0 -- the neighbour
	# phase-conveyor at (28, 20) -- and the copper lands
	# in its frame items (+1). The second dumps to ring
	# 0 -- a copper wall with no store -- and the copper
	# still leaves the bridge (3 -> 2), dropping with
	# reason no_frame. The size-1 ring is angle-sorted:
	# ring 0 is north (x, y-1), then east, south, west.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(1, 28, 21).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var item_bridge_cell := Vector2i(28, 21)
	var item_bridge := Sprite2D.new()
	game.add_child(item_bridge)
	game.call("record_placed_block", item_bridge, blocks_by_id["phase-conveyor"], item_bridge_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(item_bridge, blocks_by_id["phase-conveyor"])
	var item_bridge_frame: Dictionary = item_bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["phase-conveyor"], live_neighbour_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(live_neighbour, blocks_by_id["phase-conveyor"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	item_bridge_frame["power_status"] = 0.5
	item_bridge_frame["items"] = {"copper": 3}
	item_bridge_frame["dump_neighbour_accepts"] = [true]
	item_bridge_frame["dump_neighbour_can_dump"] = [true]

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(1, 50, 30).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_bridge_cell := Vector2i(50, 30)
	var bare_bridge := Sprite2D.new()
	game.add_child(bare_bridge)
	game.call("record_placed_block", bare_bridge, blocks_by_id["phase-conveyor"], bare_bridge_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(bare_bridge, blocks_by_id["phase-conveyor"])
	var bare_frame: Dictionary = bare_bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["power_status"] = 0.5
	bare_frame["items"] = {"copper": 3}
	bare_frame["dump_neighbour_accepts"] = [true]
	bare_frame["dump_neighbour_can_dump"] = [true]

	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	item_bridge_frame = item_bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bare_frame = bare_bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	var live_items: Dictionary = item_bridge_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_dumped_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(28, 20) and is_equal_approx(float(item_bridge_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(item_bridge_frame.get("potential_efficiency", -1.0)), 0.5) and is_equal_approx(float(item_bridge_frame.get("warmup", -1.0)), 0.0) and bool(item_bridge_frame.get("had_valid_link", true)) == false and int(live_items.get("copper", -1)) == 2 and is_equal_approx(float(item_bridge_frame.get("dump_accum", -1.0)), 0.0) and int(item_bridge_frame.get("cdump", -1)) == 0 and int(live_neighbour_items.get("copper", -1)) == 1
	proof["live_tick_dumped_item_leaves_bridge_without_frame"] = bare_cell == Vector2i(50, 29) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(bare_frame.get("potential_efficiency", -1.0)), 0.5) and is_equal_approx(float(bare_frame.get("warmup", -1.0)), 0.0) and bool(bare_frame.get("had_valid_link", true)) == false and int(bare_items.get("copper", -1)) == 2 and is_equal_approx(float(bare_frame.get("dump_accum", -1.0)), 0.0) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not bare_wall.has_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeDoDumpWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
