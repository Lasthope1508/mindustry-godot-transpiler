extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
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

	# --- Pure timer-dump (N2283): the frame-local Interval-
	# equivalent for the timerDump dump (TimerComp.timer,
	# TimerComp.java:10-13, `if(Float.isInfinite(time))
	# return false;` / `return timer.get(index, time);`;
	# Interval.get resets times[id] = Time.time on fire, arc
	# Interval.java:20-26; Time.time counts TICKS, arc
	# Time.java:69-80): threshold = dumpTime / time_scale
	# (5f / time_scale, `public int dumpTime = 5;`,
	# Block.java:438, no def overrides it); a non-positive
	# time_scale is the infinite-time branch (fired false);
	# fired = elapsed >= threshold; elapsed_after RESETS to
	# 0.0 on fire -- even when the dump itself fails,
	# because Java resets the Interval on timer() returning
	# true, whatever dump() then does. On fire it dumps 1
	# output item -- sand (`public Item output =
	# Items.sand;`, WallCrafter.java:43, set explicitly by
	# both defs, `output = Items.sand;`, Blocks.java:
	# 3009/:3023) -- through the shared dump(output) port
	# (SourceBuildingItemDumpState.dump_item_state,
	# BuildingComp.java:1072-1113, the todump branch:
	# `if(other.acceptItem(self(), todump) && canDump(
	# other, todump)){` / `other.handleItem(self(),
	# todump);` / `items.remove(todump, 1);` /
	# `incrementDump(proximity.size);`), with the cursor
	# advancing once per neighbour checked (`cdump =
	# ((cdump + 1) % prox);`, BuildingComp.java:1119).
	var item_ids: Array = ["sand", "graphite"]
	var accepts_one: Array = [true]
	var can_dump_one: Array = [true]
	var fires_at_threshold: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, 1.0, {"items": {"sand": 2}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	var fires_above_threshold: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.5, 1.0, {"items": {"sand": 2}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	var fires_scaled: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(2.5, 2.0, {"items": {"sand": 2}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	proof["timer_fires_at_five_ticks"] = bool(fires_at_threshold.get("fired", false)) and is_equal_approx(float(fires_at_threshold.get("elapsed_after", -1.0)), 0.0) and bool(fires_at_threshold.get("dumped", false)) and int(fires_at_threshold.get("items_after", {}).get("sand", -1)) == 1 and int(fires_at_threshold.get("cursor_after", -1)) == 1 and bool(fires_above_threshold.get("fired", false)) and bool(fires_scaled.get("fired", false))

	var below_threshold: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(4.9, 1.0, {"items": {"sand": 2}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	var zero_scale: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, 0.0, {"items": {"sand": 2}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	var negative_scale: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, -1.0, {"items": {"sand": 2}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	proof["timer_no_fire_below_threshold"] = bool(below_threshold.get("fired", true)) == false and is_equal_approx(float(below_threshold.get("elapsed_after", -1.0)), 4.9) and bool(below_threshold.get("dumped", true)) == false and int(below_threshold.get("items_after", {}).get("sand", -1)) == 2 and int(below_threshold.get("cursor_after", -1)) == 0 and bool(zero_scale.get("fired", true)) == false and is_equal_approx(float(zero_scale.get("elapsed_after", -1.0)), 5.0) and bool(negative_scale.get("fired", true)) == false

	var removes_output: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, 1.0, {"items": {"sand": 2, "graphite": 3}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	proof["dump_removes_output_item"] = bool(removes_output.get("dumped", false)) and int(removes_output.get("items_after", {}).get("sand", -1)) == 1 and int(removes_output.get("items_after", {}).get("graphite", -1)) == 3

	var cursor_first: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, 1.0, {"items": {"sand": 2}, "cdump": 0}, "sand", ["sand"], [true, false], [true, true])
	var cursor_skip: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, 1.0, {"items": {"sand": 2}, "cdump": 0}, "sand", ["sand"], [false, true], [true, true])
	proof["dump_cursor_advances"] = bool(cursor_first.get("dumped", false)) and int(cursor_first.get("cursor_after", -1)) == 1 and bool(cursor_skip.get("dumped", false)) and int(cursor_skip.get("cursor_after", -1)) == 0

	var absent_empty: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, 1.0, {"items": {}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	var absent_other: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_dump_state(5.0, 1.0, {"items": {"graphite": 2}, "cdump": 0}, "sand", item_ids, accepts_one, can_dump_one)
	proof["no_dump_when_output_absent"] = bool(absent_empty.get("fired", false)) and bool(absent_empty.get("dumped", true)) == false and int(absent_empty.get("items_after", {}).size()) == 0 and int(absent_empty.get("cursor_after", -1)) == 0 and is_equal_approx(float(absent_empty.get("elapsed_after", -1.0)), 0.0) and bool(absent_other.get("fired", false)) and bool(absent_other.get("dumped", true)) == false and int(absent_other.get("items_after", {}).get("graphite", -1)) == 2 and int(absent_other.get("cursor_after", -1)) == 0

	# --- Live tick: two cliff-crushers placed live; the
	# tick driver is called directly (as the N2170/N2201/
	# N2223/N2264/N2273 proofs do), not simulate_factory,
	# so the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already
	# proven by N2142. The timerDump dump runs after the
	# N2223 advance and the N2273 timerUse consume (the
	# Java order, :207-209 then :220-221): when the timer
	# fires at 5f/time_scale it dumps 1 sand to an
	# accepting neighbour through the shared dump_item_state
	# routing; the neighbour acceptItem / canDump arrays
	# are frame inputs (seeded here -- no live proximity
	# fill yet, the N2276 precedent), and the sand is
	# seeded on the frame directly (no live intake fills
	# it yet, like the N2223 proof seeds
	# efficiency_factor). The two timers are independent
	# frame-local clocks: the dump clock resets to 0.0 on
	# fire while the use clock keeps accumulating.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# A: cliff-crusher, sand held (2), full power,
	# efficiency_factor 1.0, dump timer at the 5-tick
	# threshold, one accepting neighbour: the tick
	# accumulates one more tick (1.0/60.0s = 1 tick), the
	# timer fires, dump() removes 1 sand, the cursor
	# advances 0 -> 1 and the dump clock resets to 0.0,
	# while the use clock (seeded 0.0) accumulates to 1.0.
	var dump_cell := Vector2i(28, 20)
	var dump_crusher := Sprite2D.new()
	game.add_child(dump_crusher)
	game.call("record_placed_block", dump_crusher, blocks_by_id["cliff-crusher"], dump_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(dump_crusher, blocks_by_id["cliff-crusher"])
	var dump_frame: Dictionary = dump_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	dump_frame["items"] = {"sand": 2}
	dump_frame["power_status"] = 1.0
	dump_frame["efficiency_factor"] = 1.0
	dump_frame["timer_dump_elapsed"] = 5.0
	dump_frame["timer_use_elapsed"] = 0.0
	dump_frame["dump_neighbour_accepts"] = [true]
	dump_frame["dump_neighbour_can_dump"] = [true]
	dump_frame["cdump"] = 0

	# B: cliff-crusher, NO sand, full power,
	# efficiency_factor 1.0, dump timer at the threshold,
	# one accepting neighbour: the timer still fires (the
	# elapsed clock resets to 0.0 -- Java resets the
	# Interval on timer() returning true, whatever dump()
	# then does) but the dump fails the items.has guard,
	# so nothing is removed and the cursor stays 0.
	var no_sand_cell := Vector2i(22, 20)
	var no_sand_crusher := Sprite2D.new()
	game.add_child(no_sand_crusher)
	game.call("record_placed_block", no_sand_crusher, blocks_by_id["cliff-crusher"], no_sand_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(no_sand_crusher, blocks_by_id["cliff-crusher"])
	var no_sand_frame: Dictionary = no_sand_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	no_sand_frame["items"] = {}
	no_sand_frame["power_status"] = 1.0
	no_sand_frame["efficiency_factor"] = 1.0
	no_sand_frame["timer_dump_elapsed"] = 5.0
	no_sand_frame["dump_neighbour_accepts"] = [true]
	no_sand_frame["dump_neighbour_can_dump"] = [true]
	no_sand_frame["cdump"] = 0

	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	dump_frame = dump_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	no_sand_frame = no_sand_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["live_tick_dumps_output"] = int(dump_frame.get("items", {}).get("sand", -1)) == 1 and int(dump_frame.get("cdump", -1)) == 1 and is_equal_approx(float(dump_frame.get("timer_dump_elapsed", -1.0)), 0.0) and is_equal_approx(float(dump_frame.get("timer_use_elapsed", -1.0)), 1.0) and is_equal_approx(float(dump_frame.get("efficiency", -1.0)), 1.0) and int(no_sand_frame.get("items", {}).size()) == 0 and int(no_sand_frame.get("cdump", -1)) == 0 and is_equal_approx(float(no_sand_frame.get("timer_dump_elapsed", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterTimerDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
