extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- The dump advance exposes its deliveries (N2368):
	# N2276 ported the updateTile dump block
	# (PayloadDeconstructor.java:111-115, dumpRate 4 x
	# dumpAccumulate() when items.total() > 0, dump(null)
	# through the shared dump_item_state routing,
	# BuildingComp.java:1072-1113) -- but the dumped item
	# left the deconstructor without landing in any
	# neighbour store. Java hands it over for real
	# (`other.handleItem(self(), item);`,
	# BuildingComp.java:1089), and handleItem is
	# `items.add(item, 1);` (BuildingComp.java:860-862).
	# dumpAccumulate can dump MULTIPLE times per frame
	# ("May dump multiple times per frame. Use with
	# care.", BuildingComp.java:1052, and dumpRate 4 runs
	# it 4 times per tick), so the advance returns
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

	# A single dump delivers one item to neighbour 0: at
	# delta 0.25 only the fourth dumpAccumulate call
	# reaches 1f (0.25 + 0.25 + 0.25 + 0.25), copper 3 ->
	# 2, the accum ends at 0.0, the cursor stays 0 over
	# the single neighbour, and the single delivery is
	# {neighbour_index 0, copper}.
	var single_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var single: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(single_frame, 0.25, 1.0, item_ids, one_accepting, one_can_dump)
	var single_items: Dictionary = single.get("items_after", {})
	var single_deliveries: Array = single.get("dump_deliveries", [])
	var single_delivery: Dictionary = single_deliveries[0] if single_deliveries.size() == 1 else {}

	# A full-rate tick dumps four times: at delta 1.0
	# each of the 4 dumpAccumulate calls reaches exactly
	# 1f, copper 5 -> 1, the accum ends at 0.0, and all 4
	# deliveries go to neighbour 0 as copper -- a scalar
	# routed index would have dropped three of them.
	var multi_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var multi: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(multi_frame, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
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
	var second_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var second: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(second_frame, 0.25, 1.0, item_ids, [false, true], [true, true])
	var second_items: Dictionary = second.get("items_after", {})
	var second_deliveries: Array = second.get("dump_deliveries", [])
	var second_delivery: Dictionary = second_deliveries[0] if second_deliveries.size() == 1 else {}

	# No dump means no deliveries: a rejecting neighbour
	# (4 attempts, dumped false, the store untouched, the
	# accum still spends its 1f per call), a canDump
	# block (same, the gate is acceptItem AND canDump),
	# and an empty store (the whole block is skipped, so
	# the accum stays 0.9 and the cursor stays 2).
	var rejected_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var rejected: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(rejected_frame, 1.0, 1.0, item_ids, [false], one_can_dump)
	var rejected_items: Dictionary = rejected.get("items_after", {})
	var blocked: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(rejected_frame, 1.0, 1.0, item_ids, one_accepting, [false])
	var blocked_items: Dictionary = blocked.get("items_after", {})
	var empty_frame: Dictionary = {"items": {}, "dump_accum": 0.9, "cdump": 2}
	var empty: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_state(empty_frame, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	proof["advance_exposes_dump_deliveries"] = bool(single.get("dumped", false)) and int(single_items.get("copper", -1)) == 2 and is_equal_approx(float(single.get("dump_accum_after", -1.0)), 0.0) and int(single.get("cursor_after", -1)) == 0 and single_deliveries.size() == 1 and int(single_delivery.get("neighbour_index", -9)) == 0 and str(single_delivery.get("item", "")) == "copper" and bool(multi.get("dumped", false)) and int(multi_items.get("copper", -1)) == 1 and is_equal_approx(float(multi.get("dump_accum_after", -1.0)), 0.0) and multi_all_copper_to_zero and bool(second.get("dumped", false)) and int(second_items.get("copper", -1)) == 2 and int(second.get("cursor_after", -1)) == 0 and second_deliveries.size() == 1 and int(second_delivery.get("neighbour_index", -9)) == 1 and str(second_delivery.get("item", "")) == "copper" and not bool(rejected.get("dumped", true)) and int(rejected_items.get("copper", -1)) == 5 and is_equal_approx(float(rejected.get("dump_accum_after", -1.0)), 0.0) and (rejected.get("dump_deliveries", [1]) as Array).is_empty() and not bool(blocked.get("dumped", true)) and int(blocked_items.get("copper", -1)) == 5 and (blocked.get("dump_deliveries", [1]) as Array).is_empty() and not bool(empty.get("dumped", true)) and is_equal_approx(float(empty.get("dump_accum_after", -1.0)), 0.9) and int(empty.get("cursor_after", -1)) == 2 and (empty.get("dump_deliveries", [1]) as Array).is_empty()

	# --- Live tick: two deconstructors dump in one tick
	# (the N2276 live setup: consumePower 3f, 5 copper in
	# the frame items, an accum of 0.9, one accepting
	# neighbour stamped as frame inputs, power_status
	# 0.5). The first dumps 4 copper to ring 0 -- the
	# phase-conveyor at (25, 20) -- and all 4 land in its
	# frame items. The second dumps 4 copper to ring 0 --
	# a copper wall with no store -- and the copper still
	# leaves the deconstructor (5 -> 1), dropping with
	# reason no_frame. The size-5 ring is angle-sorted:
	# ring 0 is offset (-3, -1) from the origin cell.
	# The neighbour is a size-1 phase-conveyor (the N2363
	# cross-family precedent): its single-cell footprint
	# cannot overlap the size-5 deconstructor, and the
	# N2353 helper writes to the first
	# SOURCE_CONSUMER_FRAME_META_KEYS frame on the sprite
	# -- the item-bridge frame, stamped with an empty
	# items store here.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(5, 28, 21).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var payload_deconstructor_cell := Vector2i(28, 21)
	var payload_deconstructor := Sprite2D.new()
	game.add_child(payload_deconstructor)
	game.call("record_placed_block", payload_deconstructor, blocks_by_id["deconstructor"], payload_deconstructor_cell)
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(payload_deconstructor, blocks_by_id["deconstructor"])
	var payload_deconstructor_frame: Dictionary = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["phase-conveyor"], live_neighbour_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(live_neighbour, blocks_by_id["phase-conveyor"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	# Seed an active deconstruction so the existing shouldConsume gate permits this dump.
	payload_deconstructor_frame["deconstructing"] = {"block": "conveyor"}
	payload_deconstructor_frame["items"] = {"copper": 5}
	payload_deconstructor_frame["dump_accum"] = 0.9
	payload_deconstructor_frame["dump_neighbour_accepts"] = [true]
	payload_deconstructor_frame["dump_neighbour_can_dump"] = [true]
	payload_deconstructor_frame["power_status"] = 0.5

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(5, 50, 30).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_deconstructor_cell := Vector2i(50, 30)
	var bare_deconstructor := Sprite2D.new()
	game.add_child(bare_deconstructor)
	game.call("record_placed_block", bare_deconstructor, blocks_by_id["deconstructor"], bare_deconstructor_cell)
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(bare_deconstructor, blocks_by_id["deconstructor"])
	var bare_frame: Dictionary = bare_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	# Seed an active deconstruction so the existing shouldConsume gate permits this dump.
	bare_frame["deconstructing"] = {"block": "conveyor"}
	bare_frame["items"] = {"copper": 5}
	bare_frame["dump_accum"] = 0.9
	bare_frame["dump_neighbour_accepts"] = [true]
	bare_frame["dump_neighbour_can_dump"] = [true]
	bare_frame["power_status"] = 0.5

	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bare_frame = bare_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = payload_deconstructor_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_dumped_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(25, 20) and is_equal_approx(float(payload_deconstructor_frame.get("efficiency", -1.0)), 0.5) and int(live_items.get("copper", -1)) == 1 and is_equal_approx(float(payload_deconstructor_frame.get("dump_accum", -1.0)), 0.9) and int(payload_deconstructor_frame.get("cdump", -1)) == 0 and int(live_neighbour_items.get("copper", -1)) == 4
	proof["live_tick_dumped_item_leaves_deconstructor_without_frame"] = bare_cell == Vector2i(47, 29) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 0.5) and int(bare_items.get("copper", -1)) == 1 and is_equal_approx(float(bare_frame.get("dump_accum", -1.0)), 0.9) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not bare_wall.has_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY) and not bare_wall.has_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorDumpWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
