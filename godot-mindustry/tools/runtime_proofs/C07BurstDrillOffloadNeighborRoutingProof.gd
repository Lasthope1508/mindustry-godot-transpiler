extends Node

const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
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

	# --- The offload neighbour routing (N2476, DEFERRED
	# #89 routing half): offload() (BuildingComp.
	# java:1001-1015) hands the produced item to the
	# first accepting neighbour -- `produced(item, 1);`
	# (:1002), `int dump = this.cdump;` (:1003), then
	# `for(int i = 0; i < proximity.size; i++){` (:1005)
	# with `incrementDump(proximity.size);` BEFORE the
	# check (:1006) and `Building other = proximity.get(
	# (i + dump) % proximity.size);` (:1007) -- rotate
	# the cursor, then inspect from its saved value --
	# where `if(other.acceptItem(self(), item) &&
	# canDump(other, item)){` (:1008) holds, via `other.
	# handleItem(self(), item);` (:1009), and falling
	# back to `handleItem(self(), item);` (:1014) when
	# no neighbour takes it. The pure
	# source_burst_drill_offload_route_state routes ONE
	# offloaded item and returns the routed neighbour
	# index (-1 = the fallback verdict) + the new
	# cdump; the N2219 advance loops it once per
	# dominant item (BurstDrill.java:107-109,
	# `for(int i = 0; i < dominantItems; i++){` /
	# `offload(dominantItem);`) with the cdump threaded
	# across items, and the tick lands each routed item
	# in its neighbour store through the shared N2353
	# helper. The gate arrays are in proximity order
	# (index i is ring cell i, the N2353 convention)
	# and answer for the offloaded item.

	# --- First accepting: with 3 neighbours where only
	# neighbour 1 accepts, the scan checks neighbour 0
	# (refused, cursor 0 -> 1) then neighbour 1 (routed,
	# cursor 1 -> 2) -- the cursor advances once per
	# scanned neighbour INCLUDING the handling one.
	var first: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([false, true, false], [true, true, true], 0, "copper")
	proof["route_first_accepting"] = int(first.get("routed_index", -9)) == 1 and int(first.get("cdump_after", -9)) == 2

	# --- Skips rejecting: a neighbour that accepts but
	# canDump-blocks takes nothing (index 0), a
	# neighbour that rejects takes nothing (index 1),
	# so the item routes to index 2 -- 3 scanned, the
	# cursor wraps 0 -> 0. Wrap-around: from cdump 2
	# the scan order is 2, 0, 1, so the accepting
	# neighbour 0 routes after one refused check and
	# the cursor stops at 1.
	var skipped: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([true, false, true], [false, true, true], 0, "copper")
	var wrapped: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([true, false, false], [true, true, true], 2, "copper")
	proof["route_skips_rejecting"] = int(skipped.get("routed_index", -9)) == 2 and int(skipped.get("cdump_after", -9)) == 0 and int(wrapped.get("routed_index", -9)) == 0 and int(wrapped.get("cdump_after", -9)) == 1

	# --- Fallback: with no accepting neighbour the
	# verdict is -1 and the cursor returns to its
	# start (a full refused scan is one full cycle --
	# the N2286 invariant). An empty proximity routes
	# nowhere and leaves the cursor untouched (the
	# incrementDump prox != 0 guard). A mismatched
	# pair scans the longer proximity with the missing
	# side refusing (the N2343 bounds-checked
	# precedent): one accepting answer with no canDump
	# answer still falls back.
	var refused: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([false, false, false], [true, true, true], 1, "copper")
	var empty: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([], [], 3, "copper")
	var mismatched: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([true], [], 0, "copper")
	proof["route_fallback"] = int(refused.get("routed_index", -9)) == -1 and int(refused.get("cdump_after", -9)) == 1 and int(empty.get("routed_index", -9)) == -1 and int(empty.get("cdump_after", -9)) == 3 and int(mismatched.get("routed_index", -9)) == -1 and int(mismatched.get("cdump_after", -9)) == 0

	# --- Cdumps advances: the cursor advances once per
	# scanned iteration -- with the first accepting
	# neighbour at scan position 2 (of 4), the cursor
	# moves 0 -> 3. The scan starts at the cdump
	# SNAPSHOT, not at 0: from cdump 1 with only
	# neighbour 0 accepting, the scan order is 1, 2, 0
	# (3 scanned) and the cursor stops at (1 + 3) % 3
	# = 1 -- a scan from 0 would have stopped at 2.
	var advanced_cursor: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([false, false, true, false], [true, true, true, true], 0, "copper")
	var snapshot: Dictionary = burst_drill_build_state.source_burst_drill_offload_route_state([true, false, false], [true, true, true], 1, "copper")
	proof["route_cdump_advances"] = int(advanced_cursor.get("routed_index", -9)) == 2 and int(advanced_cursor.get("cdump_after", -9)) == 3 and int(snapshot.get("routed_index", -9)) == 0 and int(snapshot.get("cdump_after", -9)) == 1

	# --- Loop cdump: the advance threads the cdump
	# across the dominantItems loop -- 3 copper offload
	# from a drill at cycle-complete (progress 281.0
	# + 1 tick at speed 1 = 282.0 >= drillTime 281.25)
	# with neighbours [accept, accept, reject] and
	# cdump 0: item 1 routes to 0 (cursor 1), item 2
	# routes to 1 (cursor 2), item 3 scans 2 (refused,
	# cursor 0) then 0 (accepted, cursor 1) -- the
	# routed indices are [0, 1, 0], nothing falls back,
	# the store stays empty, progress wraps to 0.75 and
	# invertTime sets to 1f. Mixed: with no accepting
	# neighbour both items fall back (2 copper land in
	# the own store) and the cursor returns to 0 (2
	# items x 3 scanned = 6 increments, a full number
	# of cycles).
	var loop_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 3, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {"copper": 0}, "progress": 281.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "smooth_progress": 0.0, "invert_time": 0.0, "dump_neighbour_accepts": [true, true, false], "dump_neighbour_can_dump": [true, true, true], "cdump": 0}
	var looped: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(loop_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	var looped_items: Dictionary = looped.get("items", {})
	var looped_indices: Array = looped.get("offload_routed_indices", [])
	var mixed_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 2, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {"copper": 0}, "progress": 281.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "smooth_progress": 0.0, "invert_time": 0.0, "dump_neighbour_accepts": [false, false, false], "dump_neighbour_can_dump": [true, true, true], "cdump": 0}
	var mixed: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(mixed_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	var mixed_items: Dictionary = mixed.get("items", {})
	var mixed_indices: Array = mixed.get("offload_routed_indices", [])
	proof["route_loop_cdump"] = looped_indices == [0, 1, 0] and int(looped.get("offload_fallback_count", -1)) == 0 and int(looped.get("offloaded", -1)) == 3 and int(looped.get("cdump", -1)) == 1 and int(looped_items.get("copper", -1)) == 0 and is_equal_approx(float(looped.get("progress", -1.0)), 0.75) and is_equal_approx(float(looped.get("invert_time", -1.0)), 1.0) and mixed_indices == [] and int(mixed.get("offload_fallback_count", -1)) == 2 and int(mixed.get("offloaded", -1)) == 2 and int(mixed.get("cdump", -1)) == 0 and int(mixed_items.get("copper", -1)) == 2

	# --- Live tick: the eruption-drill placed live on
	# copper ore (the N2403 live setup, power_status
	# stamped 0.5) with NO seeded dump arrays -- the
	# tick fills them live and refreshes them for the
	# dominant item before the advance. The drill
	# holds 5 copper with the timer at 0.0 (no dump
	# fires: 0.0 + 1.0 < 5f) and progress at 281.0,
	# so one tick at speed 0.75 takes progress to
	# 281.75 >= drillTime 281.25 and the offload
	# branch fires with dominant_items 2 (seeded --
	# the natural 25-tile count would overshoot the
	# smelter's 20 capacity through the snapshot
	# gates, the documented deviation). The
	# surge-smelter (the only catalog def that
	# consumes copper, itemCapacity 20) accepts at
	# ring 12, 13 and 14, the melter at ring 0
	# rejects copper (it consumes scrap), so item 1
	# routes to ring 12 (cursor 13) and item 2 to
	# ring 13 (cursor 14) -- both land in the
	# surge-smelter frame through the shared N2353
	# helper, the drill store stays at 5 copper,
	# progress wraps to 0.5 and invertTime sets.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
	var ring: Array = block_geometry.source_block_proximity_cells_state(5, 28, 20).get("cells", [])
	var drill_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var surge_cell: Vector2i = ring[14]
	var eruption := Sprite2D.new()
	game.add_child(eruption)
	for occupied in game.call("occupied_cells", drill_cell, blocks_by_id["eruption-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", eruption, blocks_by_id["eruption-drill"], drill_cell)
	drill_build_state.source_on_proximity_update_state(game, eruption, blocks_by_id["eruption-drill"])
	var eruption_frame: Dictionary = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	# Supply the required hydrogen (Blocks.java:3119) for the live offload scenario.
	liquid_module_state.source_set_state(eruption.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY), int(liquid_catalog["liquid_id_by_name"]["hydrogen"]), 1.0)
	# This scenario expects boosted speed 0.75 at half power: cyanogen booster (Blocks.java:3120).
	liquid_module_state.source_set_state(eruption.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY), int(liquid_catalog["liquid_id_by_name"]["cyanogen"]), 1.0)
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var melter_frame: Dictionary = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame["items"] = {}
	var surge := Sprite2D.new()
	game.add_child(surge)
	# Keep the contact cell on the ring while placing a non-overlapping neighbour footprint.
	game.call("record_placed_block", surge, blocks_by_id["surge-smelter"], surge_cell + Vector2i(1, 1))
	factory_build_state.source_factory_bind_frame_state(surge, blocks_by_id["surge-smelter"])
	var surge_frame: Dictionary = surge.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	surge_frame["items"] = {}
	eruption_frame["items"] = {"copper": 5}
	eruption_frame["timer_dump_elapsed"] = 0.0
	eruption_frame["power_status"] = 0.5
	eruption_frame["progress"] = 281.0
	eruption_frame["dominant_items"] = 2

	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	surge_frame = surge.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var live_items: Dictionary = eruption_frame.get("items", {})
	var surge_items: Dictionary = surge_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var live_accepts: Array = eruption_frame.get("dump_neighbour_accepts", [])
	proof["route_live_tick"] = ring.size() == 20 and melter_cell == Vector2i(25, 19) and surge_cell == Vector2i(28, 23) and int(live_items.get("copper", -1)) == 5 and int(surge_items.get("copper", -1)) == 2 and int(melter_items.get("copper", 0)) == 0 and int(eruption_frame.get("cdump", -1)) == 14 and is_equal_approx(float(eruption_frame.get("timer_dump_elapsed", -1.0)), 1.0) and is_equal_approx(float(eruption_frame.get("progress", -1.0)), 0.5) and is_equal_approx(float(eruption_frame.get("invert_time", -1.0)), 1.0) and int(eruption_frame.get("dominant_items", 0)) == 2 and bool(eruption_frame.get("dump_neighbour_live", false)) and bool(live_accepts[12]) and bool(live_accepts[13]) and not bool(live_accepts[0])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillOffloadNeighborRoutingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
