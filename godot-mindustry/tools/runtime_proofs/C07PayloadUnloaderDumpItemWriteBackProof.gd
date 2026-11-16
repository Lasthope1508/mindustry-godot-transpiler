extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
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

	# --- The dump advance exposes its item deliveries (N2386,
	# the ITEM half of DEFERRED #304): N2293 ported the dump
	# rows (dumpLiquid(current) 2f + offloadSpeed x
	# dumpAccumulate() at the end of updateTile,
	# PayloadUnloader.java:105-108) -- but the dumped
	# liquid/item left the store without landing in any
	# neighbour store. Java hands the item over for real
	# (`other.handleItem(self(), item);`,
	# BuildingComp.java:1089), and handleItem is
	# `items.add(item, 1);` (BuildingComp.java:860-862).
	# N2380 wired the LIQUID half (dump_neighbour_index +
	# dumped_liquid_name + the N2371 helper); this slice
	# wires the ITEM half (the N2368/N2369 pattern).
	# dumpAccumulate can dump MULTIPLE times per frame
	# ("May dump multiple times per frame. Use with
	# care.", BuildingComp.java:1052, and offloadSpeed 4
	# runs it 4 times per tick), so the advance returns
	# dump_deliveries -- one {"neighbour_index": ...,
	# "item": ...} dict per successful attempt, in attempt
	# order (empty when nothing dumped) -- and the tick
	# lands each one through the shared N2353 helper.
	# Index i is ring cell i (the N2353 convention): the
	# helper resolves the index through the
	# source_block_proximity_cells_state ring. KEY
	# COLLISION: dump_neighbour_index is ALREADY the
	# liquid half's scalar key (N2380) -- the item half
	# does NOT reuse it; the deliveries array carries the
	# item routing instead, and the liquid keys stay
	# untouched (the fixtures below carry no liquids, so
	# the liquid index reads -1 and the liquid name reads
	# ""). Content items here are ["copper", "lead"] in
	# catalog order; the dump takes the first held item in
	# that order.
	var item_ids: Array = ["copper", "lead"]
	var one_accepting: Array = [true]
	var one_can_dump: Array = [true]

	# A single dump delivers one item to neighbour 0: at
	# delta 0.25 only the fourth dumpAccumulate call
	# reaches 1f (0.25 + 0.25 + 0.25 + 0.25), copper 3 ->
	# 2, the accum ends at 0.0, the cursor stays 0 over
	# the single neighbour, and the single delivery is
	# {neighbour_index 0, copper}.
	var single_frame: Dictionary = {"liquids": {}, "items": {"copper": 3}, "cdump": 0, "dump_accum": 0.0}
	var single: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state(single_frame, 0.25, 1.0, item_ids, [], [], [], [], one_accepting, one_can_dump)
	var single_items: Dictionary = single.get("items_after", {})
	var single_deliveries: Array = single.get("dump_deliveries", [])
	var single_delivery: Dictionary = single_deliveries[0] if single_deliveries.size() == 1 else {}

	# A full-rate tick dumps four times: at delta 1.0
	# each of the 4 dumpAccumulate calls reaches exactly
	# 1f, copper 5 -> 1, the accum ends at 0.0, and all 4
	# deliveries go to neighbour 0 as copper -- a scalar
	# routed index would have dropped three of them.
	var multi_frame: Dictionary = {"liquids": {}, "items": {"copper": 5}, "cdump": 0, "dump_accum": 0.0}
	var multi: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state(multi_frame, 1.0, 1.0, item_ids, [], [], [], [], one_accepting, one_can_dump)
	var multi_items: Dictionary = multi.get("items_after", {})
	var multi_deliveries: Array = multi.get("dump_deliveries", [])
	var multi_all_copper_to_zero := multi_deliveries.size() == 4
	for delivery in multi_deliveries:
		var entry: Dictionary = delivery
		multi_all_copper_to_zero = multi_all_copper_to_zero and int(entry.get("neighbour_index", -9)) == 0 and str(entry.get("item", "")) == "copper"

	# The second neighbour takes the delivery when the
	# first rejects: accepts [false, true] routes to
	# index 1 (the cursor wraps back to 0 after the
	# two-neighbour scan: refused 0 -> 1, dumped 1 -> 0)
	# and copper 3 -> 2.
	var second_frame: Dictionary = {"liquids": {}, "items": {"copper": 3}, "cdump": 0, "dump_accum": 0.0}
	var second: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state(second_frame, 0.25, 1.0, item_ids, [], [], [], [], [false, true], [true, true])
	var second_items: Dictionary = second.get("items_after", {})
	var second_deliveries: Array = second.get("dump_deliveries", [])
	var second_delivery: Dictionary = second_deliveries[0] if second_deliveries.size() == 1 else {}

	# No dump means no deliveries: a rejecting neighbour
	# (4 attempts, dumped_items 0, the store untouched,
	# the accum still spends its 1f per call), a canDump
	# block (same, the gate is acceptItem AND canDump),
	# and an empty store (the attempts run but the shared
	# routing guards on items.total() == 0, so the accum
	# still ends at 0.9 and the cursor stays 2).
	var rejected_frame: Dictionary = {"liquids": {}, "items": {"copper": 5}, "cdump": 0, "dump_accum": 0.0}
	var rejected: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state(rejected_frame, 1.0, 1.0, item_ids, [], [], [], [], [false], one_can_dump)
	var rejected_items: Dictionary = rejected.get("items_after", {})
	var blocked: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state(rejected_frame, 1.0, 1.0, item_ids, [], [], [], [], one_accepting, [false])
	var blocked_items: Dictionary = blocked.get("items_after", {})
	var empty_frame: Dictionary = {"liquids": {}, "items": {}, "cdump": 2, "dump_accum": 0.9}
	var empty: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state(empty_frame, 1.0, 1.0, item_ids, [], [], [], [], one_accepting, one_can_dump)
	proof["advance_exposes_dump_deliveries"] = int(single.get("dumped_items", -1)) == 1 and int(single_items.get("copper", -1)) == 2 and is_equal_approx(float(single.get("dump_accum_after", -1.0)), 0.0) and int(single.get("cursor_after", -1)) == 0 and single_deliveries.size() == 1 and int(single_delivery.get("neighbour_index", -9)) == 0 and str(single_delivery.get("item", "")) == "copper" and int(single.get("dump_neighbour_index", -9)) == -1 and str(single.get("dumped_liquid_name", "missing")) == "" and is_equal_approx(float(single.get("dumped_liquid", -1.0)), 0.0) and int(multi.get("dumped_items", -1)) == 4 and int(multi_items.get("copper", -1)) == 1 and is_equal_approx(float(multi.get("dump_accum_after", -1.0)), 0.0) and multi_all_copper_to_zero and int(second.get("dumped_items", -1)) == 1 and int(second_items.get("copper", -1)) == 2 and int(second.get("cursor_after", -1)) == 0 and second_deliveries.size() == 1 and int(second_delivery.get("neighbour_index", -9)) == 1 and str(second_delivery.get("item", "")) == "copper" and int(rejected.get("dumped_items", -1)) == 0 and int(rejected_items.get("copper", -1)) == 5 and is_equal_approx(float(rejected.get("dump_accum_after", -1.0)), 0.0) and (rejected.get("dump_deliveries", [1]) as Array).is_empty() and int(blocked.get("dumped_items", -1)) == 0 and int(blocked_items.get("copper", -1)) == 5 and (blocked.get("dump_deliveries", [1]) as Array).is_empty() and int(empty.get("dumped_items", -1)) == 0 and is_equal_approx(float(empty.get("dump_accum_after", -1.0)), 0.9) and int(empty.get("cursor_after", -1)) == 2 and (empty.get("dump_deliveries", [1]) as Array).is_empty()

	# --- Live tick: two payload-unloaders placed live with
	# NO payload (the N2293 live setup: the shouldConsume
	# gate is false, so efficiency folds to 0.0 -- and the
	# dump STILL runs, because the dump rows are
	# unconditional, PayloadUnloader.java:105-108). The first
	# dumps 4 copper to ring 0 -- the phase-conveyor at
	# (26, 19) -- and all 4 land in its frame items. The
	# second dumps 4 copper to ring 0 -- a copper wall with
	# no store -- and the copper still leaves the unloader
	# (5 -> 1), dropping with reason no_frame. The size-3
	# ring 0 is the (-2, -1) offset (the angle-sorted ring),
	# so the (28, 20) unloader's ring 0 is (26, 19) and the
	# (20, 10) unloader's is (18, 9) (the N2380 precedent).
	# The neighbour is a size-1 phase-conveyor (the N2368
	# cross-family precedent): its single-cell footprint
	# cannot overlap the size-3 unloader, and the N2353
	# helper writes to the first
	# SOURCE_CONSUMER_FRAME_META_KEYS frame on the sprite
	# -- the item-bridge frame, stamped with an empty
	# items store here.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(3, 28, 20).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var unloader_cell := Vector2i(28, 20)
	var unloader := Sprite2D.new()
	game.add_child(unloader)
	game.call("record_placed_block", unloader, blocks_by_id["payload-unloader"], unloader_cell)
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["phase-conveyor"], live_neighbour_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(live_neighbour, blocks_by_id["phase-conveyor"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	unloader_frame["power_status"] = 1.0
	unloader_frame["items"] = {"copper": 5}
	unloader_frame["dump_accum"] = 0.9
	unloader_frame["dump_neighbour_accepts_item"] = [true]
	unloader_frame["dump_neighbour_can_dump_item"] = [true]

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(3, 20, 10).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_unloader_cell := Vector2i(20, 10)
	var bare_unloader := Sprite2D.new()
	game.add_child(bare_unloader)
	game.call("record_placed_block", bare_unloader, blocks_by_id["payload-unloader"], bare_unloader_cell)
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(bare_unloader, blocks_by_id["payload-unloader"])
	var bare_frame: Dictionary = bare_unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["power_status"] = 1.0
	bare_frame["items"] = {"copper": 5}
	bare_frame["dump_accum"] = 0.9
	bare_frame["dump_neighbour_accepts_item"] = [true]
	bare_frame["dump_neighbour_can_dump_item"] = [true]

	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bare_frame = bare_unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var live_items: Dictionary = unloader_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_dumped_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(26, 19) and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 0.0) and int(live_items.get("copper", -1)) == 1 and int(unloader_frame.get("dumped_items", -1)) == 4 and is_equal_approx(float(unloader_frame.get("dump_accum", -1.0)), 0.9) and int(unloader_frame.get("cdump", -1)) == 0 and int(live_neighbour_items.get("copper", -1)) == 4
	proof["live_tick_dumped_item_leaves_unloader_without_frame"] = bare_cell == Vector2i(18, 9) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 0.0) and int(bare_items.get("copper", -1)) == 1 and int(bare_frame.get("dumped_items", -1)) == 4 and is_equal_approx(float(bare_frame.get("dump_accum", -1.0)), 0.9) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not bare_wall.has_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY) and not bare_wall.has_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderDumpItemWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
