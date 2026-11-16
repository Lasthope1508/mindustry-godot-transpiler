extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure routing-context builder (N2343): offload()
	# (BuildingComp.java:1001-1016) scans proximity from the
	# saved cdump -- `produced(item, 1);` (:1002), `int dump
	# = this.cdump;` (:1003), then for each neighbour
	# `incrementDump(proximity.size);` BEFORE the check
	# (:1006) and `Building other = proximity.get((i + dump)
	# % proximity.size);` (:1007) -- handing the item to the
	# first neighbour where `if(other.acceptItem(self(),
	# item) && canDump(other, item)){` (:1008) holds, via
	# `other.handleItem(self(), item);` (:1009), and falling
	# back to `handleItem(self(), item);` (:1014) when no
	# neighbour takes it. The builder turns the frame
	# neighbour inputs into the context the shared
	# offload_item_state port reads: the neighbors array
	# [{accepts_item, can_dump, item_count}] plus the dump
	# cursor. The frame inputs are the SAME arrays the N2281
	# dump reads (dump_neighbour_accepts /
	# dump_neighbour_can_dump, default []): Java has ONE
	# proximity list, and offload() and dump() scan the same
	# neighbours with the same acceptItem/canDump answers.
	# A missing answer in one array reads false (the
	# dump_item_state bounds-checked precedent), so a
	# mismatched pair still scans the longer proximity with
	# the missing side refusing. The cursor passes through
	# unchanged -- offload_item_state normalizes it via
	# modulo, like incrementDump (BuildingComp.java:
	# 1116-1120, `cdump = ((cdump + 1) % prox);`).
	var built: Dictionary = separator_build_state.source_separator_offload_routing_context_state([true, false, true], [true, true, false], 2)
	var built_neighbors: Array = built.get("neighbors", [])
	var built_first: Dictionary = built_neighbors[0] as Dictionary
	var built_second: Dictionary = built_neighbors[1] as Dictionary
	var built_third: Dictionary = built_neighbors[2] as Dictionary
	var mismatched: Dictionary = separator_build_state.source_separator_offload_routing_context_state([true, true], [false], 0)
	var mismatched_neighbors: Array = mismatched.get("neighbors", [])
	var mismatched_first: Dictionary = mismatched_neighbors[0] as Dictionary
	var mismatched_second: Dictionary = mismatched_neighbors[1] as Dictionary
	proof["routing_context_builds_neighbors"] = built_neighbors.size() == 3 and int(built.get("dump_cursor", -1)) == 2 and bool(built_first.get("accepts_item", false)) and bool(built_first.get("can_dump", false)) and int(built_first.get("item_count", -1)) == 0 and bool(built_second.get("accepts_item", true)) == false and bool(built_second.get("can_dump", false)) and int(built_second.get("item_count", -1)) == 0 and bool(built_third.get("accepts_item", false)) and bool(built_third.get("can_dump", true)) == false and int(built_third.get("item_count", -1)) == 0 and mismatched_neighbors.size() == 2 and bool(mismatched_first.get("accepts_item", false)) and bool(mismatched_first.get("can_dump", true)) == false and bool(mismatched_second.get("accepts_item", false)) and bool(mismatched_second.get("can_dump", true)) == false

	# Empty inputs: no neighbours, the Java
	# proximity.size == 0 outcome -- the context carries an
	# empty neighbors array and the cursor passes through,
	# so the offload falls back to the building's own items
	# with the cursor untouched.
	var emptied: Dictionary = separator_build_state.source_separator_offload_routing_context_state([], [], 1)
	var emptied_zero: Dictionary = separator_build_state.source_separator_offload_routing_context_state([], [], 0)
	proof["routing_context_empty_neighbors"] = (emptied.get("neighbors", [0]) as Array).is_empty() and int(emptied.get("dump_cursor", -1)) == 1 and (emptied_zero.get("neighbors", [0]) as Array).is_empty() and int(emptied_zero.get("dump_cursor", -1)) == 0

	# --- Advance through the routing context: the weighted
	# pick + offload on the separator (the N2222 proof
	# values): seed 1 over sum 12 gives index 11, the
	# titanium window [10, 12), so the crafted titanium is
	# the item the offload routes. The craft frame carries
	# progress 0.99 at full efficiency, so one tick crosses
	# 1f and crafts.
	var separator_results: Array = [{"item": "copper", "amount": 5}, {"item": "lead", "amount": 3}, {"item": "graphite", "amount": 2}, {"item": "titanium", "amount": 2}]

	# Routes to the first accepting neighbour from the saved
	# cursor: with neighbours [refuse, accept, refuse] and
	# cursor 0, the scan checks neighbour 0 (refused, cursor
	# 0 -> 1) then neighbour 1 (accepted, cursor 1 -> 2), so
	# the titanium leaves the separator (own items stay
	# empty) and the cursor ends at 2. The scan inspects
	# from the SAVED cursor value: with neighbours [accept,
	# refuse] and cursor 1, the first check is neighbour 1
	# (refused, cursor 1 -> 0), the second is neighbour 0
	# (accepted, cursor 0 -> 1) -- the accepting neighbour 0
	# is checked second, and the cursor ends at 1.
	var route_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 0}
	var route_context: Dictionary = {"neighbors": [{"accepts_item": false, "can_dump": true, "item_count": 0}, {"accepts_item": true, "can_dump": true, "item_count": 0}, {"accepts_item": false, "can_dump": true, "item_count": 0}], "dump_cursor": 0}
	var routed: Dictionary = separator_build_state.source_separator_update_tile_advance_state(route_frame, 1.0, 1.0, 35.0, separator_results, [], 10, route_context)
	var routed_items: Dictionary = routed.get("items", {})
	var saved_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 1}
	var saved_context: Dictionary = {"neighbors": [{"accepts_item": true, "can_dump": true, "item_count": 0}, {"accepts_item": false, "can_dump": true, "item_count": 0}], "dump_cursor": 1}
	var saved: Dictionary = separator_build_state.source_separator_update_tile_advance_state(saved_frame, 1.0, 1.0, 35.0, separator_results, [], 10, saved_context)
	var saved_items: Dictionary = saved.get("items", {})
	proof["offload_routes_to_accepting_neighbor"] = bool(routed.get("crafted", false)) and str(routed.get("picked_item", "")) == "titanium" and int(routed_items.get("titanium", 0)) == 0 and int(routed.get("cdump", -1)) == 2 and int(routed.get("seed", -1)) == 2 and bool(saved.get("crafted", false)) and int(saved_items.get("titanium", 0)) == 0 and int(saved.get("cdump", -1)) == 1

	# Falls back when no neighbour accepts: with two
	# refusing neighbours the titanium lands in the
	# separator's own items (count 1) and the cursor returns
	# to its start (the full-cycle invariant: two checks over
	# two neighbours rotate the cursor exactly once around).
	# With three refusing neighbours from cursor 1 the
	# fallback keeps the cursor at 1 the same way. A
	# context-less craft (the default {} routing context)
	# still falls back -- and the frame cursor is preserved
	# (2 stays 2): the advance defaults a missing cursor
	# from the frame cdump (offload() reads `this.cdump`,
	# BuildingComp.java:1003) instead of clobbering it to 0.
	var fallback_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 0}
	var fallback_context: Dictionary = {"neighbors": [{"accepts_item": false, "can_dump": true, "item_count": 0}, {"accepts_item": true, "can_dump": false, "item_count": 0}], "dump_cursor": 0}
	var fell_back: Dictionary = separator_build_state.source_separator_update_tile_advance_state(fallback_frame, 1.0, 1.0, 35.0, separator_results, [], 10, fallback_context)
	var fell_back_items: Dictionary = fell_back.get("items", {})
	var cycle_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 1}
	var cycle_context: Dictionary = {"neighbors": [{"accepts_item": false, "can_dump": true, "item_count": 0}, {"accepts_item": false, "can_dump": true, "item_count": 0}, {"accepts_item": false, "can_dump": true, "item_count": 0}], "dump_cursor": 1}
	var cycled: Dictionary = separator_build_state.source_separator_update_tile_advance_state(cycle_frame, 1.0, 1.0, 35.0, separator_results, [], 10, cycle_context)
	var cycled_items: Dictionary = cycled.get("items", {})
	var bare_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {}, "cdump": 2}
	var bare: Dictionary = separator_build_state.source_separator_update_tile_advance_state(bare_frame, 1.0, 1.0, 35.0, separator_results, [], 10)
	var bare_items: Dictionary = bare.get("items", {})
	proof["offload_falls_back_without_accepting_neighbor"] = bool(fell_back.get("crafted", false)) and int(fell_back_items.get("titanium", -1)) == 1 and int(fell_back.get("cdump", -1)) == 0 and int(cycled_items.get("titanium", -1)) == 1 and int(cycled.get("cdump", -1)) == 1 and int(bare_items.get("titanium", -1)) == 1 and int(bare.get("cdump", -1)) == 2

	# The itemCapacity gate still precedes the offload
	# (Separator.java:160, `if(item != null && items.get(item)
	# < itemCapacity){`): with titanium already at 10, the
	# craft completes and the seed increments, but no offload
	# runs even with an accepting neighbour -- the store
	# stays at 10 and the cursor stays 0.
	var full_frame: Dictionary = {"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 1, "items": {"titanium": 10}, "cdump": 0}
	var full_context: Dictionary = {"neighbors": [{"accepts_item": true, "can_dump": true, "item_count": 0}], "dump_cursor": 0}
	var full: Dictionary = separator_build_state.source_separator_update_tile_advance_state(full_frame, 1.0, 1.0, 35.0, separator_results, [], 10, full_context)
	var full_items: Dictionary = full.get("items", {})
	proof["offload_respects_item_capacity"] = bool(full.get("crafted", false)) and str(full.get("picked_item", "")) == "titanium" and int(full_items.get("titanium", -1)) == 10 and int(full.get("seed", -1)) == 2 and int(full.get("cdump", -1)) == 0

	# --- Live tick: the separator is a Separator build with a
	# power consumer (consumePower 1.1f) and a slag consumer
	# (consumeLiquid slag 4f/60f), placed live; the tick driver
	# is called directly (as the N2147/N2148/N2149/N2150/N2153/
	# N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/N2162/
	# N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2200/N2222/
	# N2252/N2281 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick: efficiency folds the
	# power min 1.0 (slag-full, so the liquid row folds 1.0
	# too), the advance crafts (progress 0.99 + 1/35 crosses
	# 1f, seed 1 picks titanium) and the offload routes the
	# titanium to neighbour 1 ([refuse, accept, refuse] from
	# cursor 0, so the cursor ends at 2) -- the own store
	# stays empty. The timerDump clock sits at 0.0, so the
	# dump does not fire this tick (0 + 1 < 5) and the dump
	# path cannot touch the store or the cursor. The
	# neighbour arrays are frame inputs (default []), stamped
	# here like the N2228 targets precedent; the slag is set
	# on the sprite liquids meta store (the live
	# LiquidModule), which the driver syncs into the frame
	# each tick before the fold (the N2252 precedent).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var separator_cell := Vector2i(28, 21)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the routing inputs on it).
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 1.0)

	separator_frame["items"] = {}
	separator_frame["progress"] = 0.99
	separator_frame["seed"] = 1
	separator_frame["cdump"] = 0
	separator_frame["timer_dump_elapsed"] = 0.0
	separator_frame["dump_neighbour_accepts"] = [false, true, false]
	separator_frame["dump_neighbour_can_dump"] = [true, true, true]
	separator_frame["power_status"] = 1.0
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = separator_frame.get("items", {})
	proof["live_tick_routes_offloaded_item"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(separator_frame.get("progress", -1.0)), 0.99 + 1.0 / 35.0 - 1.0) and is_equal_approx(float(separator_frame.get("warmup", -1.0)), 0.02) and int(separator_frame.get("seed", -1)) == 2 and int(live_items.get("titanium", 0)) == 0 and int(separator_frame.get("cdump", -1)) == 2 and is_equal_approx(float(separator_frame.get("timer_dump_elapsed", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorOffloadRoutingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
