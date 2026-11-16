extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
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

	# --- The timerDump advance exposes the routed neighbour
	# index + the dumped item (N2360): the N2282 advance ran
	# the shared dump_item_state routing but returned only
	# {fired, elapsed_after, dumped, items_after,
	# cursor_after}, so the dumped item left the burst drill
	# without landing in any neighbour store. Java hands it
	# over for real -- `other.handleItem(self(), item);`
	# (BuildingComp.java:1089, the dump(null) branch) and
	# `other.handleItem(self(), todump);` (:1103, the
	# specific branch) -- and handleItem is `items.add(item,
	# 1);` (BuildingComp.java:860-862). The handled index is
	# the dump_item_state result key
	# SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY
	# ("handled_index"); the dumped item is the port's
	# handled_item -- the dominant item (todump) on the
	# specific branch and the first held item in content
	# order on the dump(null) branch. The content item order
	# here is [copper, lead], the catalog order Java
	# iterates (content.items()).
	var content_item_ids: Array = ["copper", "lead"]

	# Routed: with 3 neighbours where only neighbour 1
	# accepts, the dump checks neighbour 0 (refused, cursor
	# 0 -> 1) then neighbour 1 (dumped, cursor 1 -> 2), the
	# dominant copper drops 5 -> 4, the exposed index is 1
	# and the exposed item is copper. Dump(null) fallback:
	# with copper and lead held and beryllium dominant but
	# NOT held, the dump is dump(null) -- the
	# neighbour-outer / item-inner scan takes the first held
	# item in content order, copper (5 -> 4), so the exposed
	# item is copper, not the unheld dominant. No fire: an
	# elapsed of 3.0 plus delta 1.0 reaches only 4.0 < 5f,
	# so nothing fires and the exposed index is -1 with an
	# empty dumped item. Blocked: a neighbour that accepts
	# but canDump-blocks takes nothing -- the timer still
	# fired and reset (Interval.get resets on fire whether
	# or not the dump succeeded), but dumped is false and
	# the exposed index is -1 with an empty dumped item.
	var routed_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var routed: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(routed_frame, 1.0, 1.0, "copper", content_item_ids, [false, true, false], [true, true, true])
	var routed_items: Dictionary = routed.get("items_after", {})
	var fallback_frame: Dictionary = {"items": {"copper": 5, "lead": 2}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var fallback: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(fallback_frame, 1.0, 1.0, "beryllium", content_item_ids, [true], [true])
	var fallback_items: Dictionary = fallback.get("items_after", {})
	var below_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 3.0, "cdump": 0}
	var below: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(below_frame, 1.0, 1.0, "copper", content_item_ids, [true], [true])
	var blocked_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var blocked: Dictionary = burst_drill_build_state.source_burst_drill_timer_dump_state(blocked_frame, 1.0, 1.0, "copper", content_item_ids, [true], [false])
	var blocked_items: Dictionary = blocked.get("items_after", {})
	proof["advance_exposes_dumped_neighbour_index"] = bool(routed.get("dumped", false)) and int(routed.get("dump_neighbour_index", -9)) == 1 and str(routed.get("dumped_item", "")) == "copper" and int(routed_items.get("copper", -1)) == 4 and int(routed.get("cursor_after", -1)) == 2 and bool(fallback.get("dumped", false)) and int(fallback.get("dump_neighbour_index", -9)) == 0 and str(fallback.get("dumped_item", "")) == "copper" and int(fallback_items.get("copper", -1)) == 4 and int(fallback_items.get("lead", -1)) == 2 and bool(below.get("fired", true)) == false and bool(below.get("dumped", true)) == false and int(below.get("dump_neighbour_index", -9)) == -1 and str(below.get("dumped_item", "x")) == "" and bool(blocked.get("fired", false)) and is_equal_approx(float(blocked.get("elapsed_after", -1.0)), 0.0) and bool(blocked.get("dumped", true)) == false and int(blocked.get("dump_neighbour_index", -9)) == -1 and str(blocked.get("dumped_item", "x")) == "" and int(blocked_items.get("copper", -1)) == 5 and int(blocked.get("cursor_after", -1)) == 0

	# --- Live tick: two eruption-drills dump in one tick
	# (the N2282 live setup: placed live on copper ore, the
	# tick driver called directly, power_status stamped
	# 0.5). The first routes to ring 14 -- the neighbour
	# separator at (28, 23) -- and the dumped copper lands
	# in its frame items (+1) through the shared helper
	# (other.handleItem(self(), todump),
	# BuildingComp.java:1103). The second routes to ring 0
	# -- a copper wall with no store -- and the dumped
	# copper still leaves the drill (own store 5 -> 4,
	# cursor advances): the write-back drops with reason
	# no_frame (the helper's no_frame exit, proven by
	# N2353), but the Java dump itself still happens.
	# Index i is ring cell i (the N2353 convention): the
	# size-5 ring around (28, 20) has 20 cells, ring 14 is
	# the (0, +3) offset (28, 23) -- a top-edge cell, so
	# the size-2 separator footprint (28..29, 23..24) clears
	# the drill footprint (26..30, 18..22); ring 0 is the
	# (-3, -1) offset. The neighbour accept arrays carry
	# all 20 ring entries, ring-ordered.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(5, 28, 20).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[14]
	var eruption_cell := Vector2i(28, 20)
	var eruption := Sprite2D.new()
	game.add_child(eruption)
	for occupied in game.call("occupied_cells", eruption_cell, blocks_by_id["eruption-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", eruption, blocks_by_id["eruption-drill"], eruption_cell)
	drill_build_state.source_on_proximity_update_state(game, eruption, blocks_by_id["eruption-drill"])
	var eruption_frame: Dictionary = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})

	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell)
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	var live_accepts: Array = []
	var live_can_dump: Array = []
	for ring_index in range(20):
		live_accepts.append(ring_index == 14)
		live_can_dump.append(true)
	eruption_frame["items"] = {"copper": 5}
	eruption_frame["timer_dump_elapsed"] = 4.0
	eruption_frame["dump_neighbour_accepts"] = live_accepts
	eruption_frame["dump_neighbour_can_dump"] = live_can_dump
	eruption_frame["power_status"] = 0.5

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(5, 50, 40).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_eruption_cell := Vector2i(50, 40)
	var bare_eruption := Sprite2D.new()
	game.add_child(bare_eruption)
	for occupied in game.call("occupied_cells", bare_eruption_cell, blocks_by_id["eruption-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", bare_eruption, blocks_by_id["eruption-drill"], bare_eruption_cell)
	drill_build_state.source_on_proximity_update_state(game, bare_eruption, blocks_by_id["eruption-drill"])
	var bare_frame: Dictionary = bare_eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})

	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	var bare_accepts: Array = []
	var bare_can_dump: Array = []
	for ring_index in range(20):
		bare_accepts.append(ring_index == 0)
		bare_can_dump.append(true)
	bare_frame["items"] = {"copper": 5}
	bare_frame["timer_dump_elapsed"] = 4.0
	bare_frame["dump_neighbour_accepts"] = bare_accepts
	bare_frame["dump_neighbour_can_dump"] = bare_can_dump
	bare_frame["power_status"] = 0.5

	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	var live_items: Dictionary = eruption_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_dumped_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(28, 23) and int(live_items.get("copper", -1)) == 4 and is_equal_approx(float(eruption_frame.get("timer_dump_elapsed", -1.0)), 0.0) and int(eruption_frame.get("cdump", -1)) == 15 and int(eruption_frame.get("dominant_items", 0)) > 0 and int(live_neighbour_items.get("copper", -1)) == 1
	proof["live_tick_dumped_item_leaves_drill_without_frame"] = bare_cell == Vector2i(47, 39) and int(bare_items.get("copper", -1)) == 4 and is_equal_approx(float(bare_frame.get("timer_dump_elapsed", -1.0)), 0.0) and int(bare_frame.get("cdump", -1)) == 1 and int(bare_frame.get("dominant_items", 0)) > 0 and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillTimerDumpWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
