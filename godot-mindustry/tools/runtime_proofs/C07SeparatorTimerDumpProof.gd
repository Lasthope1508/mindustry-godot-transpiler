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

	# --- Pure timer-dump (N2281): the timerDump dump at the
	# END of updateTile (`if(timer(timerDump, dumpTime /
	# timeScale)){ dump(); }`, Separator.java:165-166) -- after
	# the progress/offload block (:140-163), so the dump sees
	# the store the advance just offloaded into. dumpTime 5
	# (Block.java:438, no override in upstream), timerDump =
	# timers++ (Block.java:436). The pure function is the
	# frame-local Interval-equivalent of TimerComp.timer
	# (TimerComp.java:10-13, `if(Float.isInfinite(time))
	# return false;` / `return timer.get(index, time);`;
	# Interval.get resets times[id] = Time.time on fire, arc
	# Interval.java:20-26; check compares Time.time -
	# times[id] >= time, arc Interval.java:28-30; Time.time
	# counts TICKS, arc Time.java:69-80): elapsed +=
	# source_delta unconditionally; fired = elapsed >= 5f /
	# time_scale; a non-positive time_scale is the
	# infinite-time branch (fired false); elapsed_after RESETS
	# to 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator). Unlike the N2280 RepairTurret
	# literal-20 timer, this Java call DOES divide by
	# timeScale, so the port threshold is Java-exact at every
	# time_scale. When the timer fires the dump runs dump(null)
	# (BuildingComp.java:1072-1113): neighbours outer, content
	# items inner -- for each neighbour from the cdump cursor,
	# the first held item in content order an accepting
	# neighbour takes is handed over, 1 leaves the store, and
	# the cursor advances once per neighbour checked
	# (incrementDump, BuildingComp.java:1116-1120, guarded on
	# prox != 0). The content item order here is [copper,
	# lead], the catalog order Java iterates
	# (content.items()). First-fire deviation: Java fires
	# (nearly) immediately after placement; the frame-local
	# clock delays the first fire by a full interval (5
	# ticks).
	var content_item_ids: Array = ["copper", "lead"]
	var accepting: Array = [true]
	var can_dump: Array = [true]

	# Fire at five ticks: 4 + 1 hits the threshold; a single
	# 5-tick delta fires at once; at time_scale 2.0 the
	# threshold is 5/2 = 2.5, so 2 + 1 fires. The fired timer
	# dumps one copper to the accepting neighbour and the
	# clock resets to 0.0.
	var fire_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var fire_at_five: Dictionary = separator_build_state.source_separator_timer_dump_state(fire_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var fire_at_five_items: Dictionary = fire_at_five.get("items_after", {})
	var fire_full_delta: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 0.0, "cdump": 0}, 5.0, 1.0, content_item_ids, accepting, can_dump)
	var fire_overdrive: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 2.0, "cdump": 0}, 1.0, 2.0, content_item_ids, accepting, can_dump)
	proof["timer_fires_at_five_ticks"] = is_equal_approx(separator_build_state.SOURCE_SEPARATOR_DUMP_TIME, 5.0) and bool(fire_at_five.get("fired", false)) and is_equal_approx(float(fire_at_five.get("elapsed_after", -1.0)), 0.0) and bool(fire_at_five.get("dumped", false)) and int(fire_at_five_items.get("copper", -1)) == 4 and bool(fire_full_delta.get("fired", false)) and is_equal_approx(float(fire_full_delta.get("elapsed_after", -1.0)), 0.0) and bool(fire_overdrive.get("fired", false))

	# No fire below the threshold: 3 + 1 = 4 keeps
	# accumulating and dumps nothing even with an accepting
	# neighbour; 0 + 1 = 1; at time_scale 0.5 the threshold
	# is 10, so 0 + 1 does not fire either. No fire on a
	# non-positive time_scale (the infinite-time branch,
	# TimerComp.java:11): the clock still accumulates -- 4 +
	# 1 = 5 -- it just never fires and never resets.
	var below_one: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 3.0, "cdump": 0}, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var below_one_items: Dictionary = below_one.get("items_after", {})
	var below_two: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 0.0, "cdump": 0}, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var below_slowed: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 0.0, "cdump": 0}, 1.0, 0.5, content_item_ids, accepting, can_dump)
	var zero_scale: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}, 1.0, 0.0, content_item_ids, accepting, can_dump)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("fired", true)) == false and is_equal_approx(float(below_one.get("elapsed_after", -1.0)), 4.0) and bool(below_one.get("dumped", true)) == false and int(below_one_items.get("copper", -1)) == 5 and int(below_one.get("cursor_after", -1)) == 0 and bool(below_two.get("fired", true)) == false and is_equal_approx(float(below_two.get("elapsed_after", -1.0)), 1.0) and bool(below_slowed.get("fired", true)) == false and is_equal_approx(float(below_slowed.get("elapsed_after", -1.0)), 1.0) and bool(zero_scale.get("fired", true)) == false and is_equal_approx(float(zero_scale.get("elapsed_after", -1.0)), 5.0)

	# Removes from the store: the dump takes the first held
	# item in CONTENT order, so with copper and lead held it
	# drains copper 5 -> 4 and leaves lead at 2. When the
	# timer has not fired, nothing dumps even with an
	# accepting neighbour.
	var store_frame: Dictionary = {"items": {"copper": 5, "lead": 2}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var stored: Dictionary = separator_build_state.source_separator_timer_dump_state(store_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var stored_items: Dictionary = stored.get("items_after", {})
	var not_fired: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5, "lead": 2}, "timer_dump_elapsed": 0.0, "cdump": 0}, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var not_fired_items: Dictionary = not_fired.get("items_after", {})
	proof["dump_removes_item_from_store"] = bool(stored.get("dumped", false)) and int(stored_items.get("copper", -1)) == 4 and int(stored_items.get("lead", -1)) == 2 and bool(not_fired.get("dumped", true)) == false and int(not_fired_items.get("copper", -1)) == 5 and int(not_fired_items.get("lead", -1)) == 2

	# Cursor advances: with 3 neighbours where only neighbour
	# 1 accepts, the dump checks neighbour 0 (refused, cursor
	# 0 -> 1) then neighbour 1 (dumped, cursor 1 -> 2). A
	# neighbour that accepts but canDump-blocks takes nothing:
	# with canDump false on the single neighbour, nothing
	# dumps and the cursor stays 0 over the single-neighbour
	# proximity ((0 + 1) % 1 == 0).
	var cursor_frame: Dictionary = {"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var cursor: Dictionary = separator_build_state.source_separator_timer_dump_state(cursor_frame, 1.0, 1.0, content_item_ids, [false, true, false], [true, true, true])
	var cursor_items: Dictionary = cursor.get("items_after", {})
	var blocked: Dictionary = separator_build_state.source_separator_timer_dump_state(cursor_frame, 1.0, 1.0, content_item_ids, [true], [false])
	var blocked_items: Dictionary = blocked.get("items_after", {})
	proof["dump_cursor_advances"] = bool(cursor.get("dumped", false)) and int(cursor_items.get("copper", -1)) == 4 and int(cursor.get("cursor_after", -1)) == 2 and bool(blocked.get("dumped", true)) == false and int(blocked_items.get("copper", -1)) == 5 and int(blocked.get("cursor_after", -1)) == 0

	# Empty store: the timer still fires (timer() is called
	# unconditionally in Java) and the clock resets, but
	# dump() guards on the empty store and dumps nothing --
	# the cursor stays 2. A store holding only a zero count
	# is empty the same way. No neighbours at all (the
	# default [] frame inputs): the timer fires and resets,
	# the proximity guard blocks the dump, and the store and
	# the cursor are untouched.
	var empty_frame: Dictionary = {"items": {}, "timer_dump_elapsed": 4.0, "cdump": 2}
	var emptied: Dictionary = separator_build_state.source_separator_timer_dump_state(empty_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var zero_frame: Dictionary = {"items": {"copper": 0}, "timer_dump_elapsed": 4.0, "cdump": 2}
	var zeroed: Dictionary = separator_build_state.source_separator_timer_dump_state(zero_frame, 1.0, 1.0, content_item_ids, accepting, can_dump)
	var no_neighbour: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 2}, 1.0, 1.0, content_item_ids, [], [])
	var no_neighbour_items: Dictionary = no_neighbour.get("items_after", {})
	proof["no_dump_when_items_empty"] = bool(emptied.get("fired", false)) and is_equal_approx(float(emptied.get("elapsed_after", -1.0)), 0.0) and bool(emptied.get("dumped", true)) == false and (emptied.get("items_after", {}) as Dictionary).is_empty() and int(emptied.get("cursor_after", -1)) == 2 and bool(zeroed.get("dumped", true)) == false and is_equal_approx(float(zeroed.get("elapsed_after", -1.0)), 0.0) and bool(no_neighbour.get("fired", false)) and bool(no_neighbour.get("dumped", true)) == false and int(no_neighbour_items.get("copper", -1)) == 5 and int(no_neighbour.get("cursor_after", -1)) == 2

	# --- Live tick: the separator is a Separator build with a
	# power consumer (consumePower 1.1f) and a slag consumer
	# (consumeLiquid slag 4f/60f), placed live; the tick driver
	# is called directly (as the N2147/N2148/N2149/N2150/N2153/
	# N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/N2162/
	# N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2200/N2222/
	# N2252 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick: efficiency folds the
	# power min 1.0 (slag-full, so the liquid row folds 1.0
	# too), the advance moves progress 1/35 with no craft
	# (progress < 1f, no offload), and the dump runs AFTER the
	# advance (Java order: Separator.java:165-166 after
	# :140-163) -- the clock at 4.0 fires (4 + 1 = 5), so one
	# copper leaves the store (5 -> 4) to the first accepting
	# neighbour, the cursor advances 0 -> 1 over the two
	# neighbours, and the clock resets to 0.0. The neighbour
	# arrays are frame inputs (default []), stamped here like
	# the N2228 targets precedent; the slag is set on the
	# sprite liquids meta store (the live LiquidModule), which
	# the driver syncs into the frame each tick before the
	# fold (the N2252 precedent).
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
	# the dump inputs on it).
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 1.0)

	separator_frame["items"] = {"copper": 5}
	separator_frame["timer_dump_elapsed"] = 4.0
	separator_frame["dump_neighbour_accepts"] = [true, true]
	separator_frame["dump_neighbour_can_dump"] = [true, true]
	separator_frame["power_status"] = 1.0
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = separator_frame.get("items", {})
	proof["live_tick_dumps_item"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(separator_frame.get("progress", -1.0)), 1.0 / 35.0) and int(live_items.get("copper", -1)) == 4 and int(separator_frame.get("cdump", -1)) == 1 and is_equal_approx(float(separator_frame.get("timer_dump_elapsed", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorTimerDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
