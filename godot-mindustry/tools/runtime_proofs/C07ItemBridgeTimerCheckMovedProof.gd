extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
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

	# --- Pure timer-check-moved (N2321): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:69-80). The Java call is `if(timer(
	# timerCheckMoved, 30f)){ wasMoved = moved; moved =
	# false; }` (ItemBridge.java:320-323) with `public final
	# int timerCheckMoved = timers ++;` (:25) and `public
	# boolean wasMoved, moved, hadValidLink;` (:202):
	# elapsed += source_delta unconditionally (source_delta
	# is the UNSCALED Time.delta in ticks, so the frame clock
	# mirrors the global Time.time); fired = elapsed >=
	# duration (the LITERAL duration -- no timeScale
	# division, the N2290 literal-20 lesson: Java passes a
	# literal 30f, unlike the dump timers); a non-positive
	# time_scale is a defensive guard (fired false -- the
	# clock still accumulates); timer_elapsed_after RESETS
	# to 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator). When the timer fires the
	# snapshot runs: was_moved takes the OLD moved and moved
	# resets to false; when it does not fire both keep their
	# values. The snapshot runs BEFORE the timeSpeed advance
	# (`timeSpeed = Mathf.approachDelta(timeSpeed, wasMoved ?
	# 1f : 0f, 1f / 60f);`, ItemBridge.java:326) and transport
	# (ItemBridge.java:356, with `moved = true;` on handoff,
	# :361), so the driver runs the timer pure BEFORE the
	# N2225 advance call -- the live tick below proves the
	# advance reads the snapshotted was_moved.
	var timer := func(elapsed: float, was_moved: bool, moved: bool, source_delta: float, time_scale: float, duration: float) -> Dictionary:
		return item_bridge_build_state.source_item_bridge_timer_check_moved_state(elapsed, was_moved, moved, source_delta, time_scale, duration)
	var duration: float = item_bridge_build_state.SOURCE_ITEM_BRIDGE_TIMER_CHECK_MOVED_DURATION

	# Fire at thirty ticks: 29 + 1 hits the threshold; a
	# single 30-tick delta fires at once; at time_scale 2.0
	# the threshold is still the literal 30, so 29 + 1 fires
	# (and 9 + 1 does NOT -- see the no-fire cases below).
	var fire_at_thirty: Dictionary = timer.call(29.0, false, true, 1.0, 1.0, duration)
	var fire_full_delta: Dictionary = timer.call(0.0, true, false, 30.0, 1.0, duration)
	var fire_overdrive: Dictionary = timer.call(29.0, false, true, 1.0, 2.0, duration)
	proof["timer_fires_at_thirty_ticks"] = is_equal_approx(duration, 30.0) and bool(fire_at_thirty.get("fired", false)) and is_equal_approx(float(fire_at_thirty.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_full_delta.get("fired", false)) and is_equal_approx(float(fire_full_delta.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_overdrive.get("fired", false))

	# No fire below the threshold: 28 + 1 = 29 keeps
	# accumulating; 0 + 1 = 1; at time_scale 0.5 the
	# threshold is still the literal 30, so 0 + 1 does not
	# fire either; and at time_scale 2.0 (overdrive) 9 + 1
	# = 10 does NOT fire -- a 30/time_scale deviation would
	# fire here (threshold 15), the literal-30 threshold
	# does not. Both flags keep their values when the timer
	# does not fire.
	var below_one: Dictionary = timer.call(28.0, false, true, 1.0, 1.0, duration)
	var below_two: Dictionary = timer.call(0.0, true, false, 1.0, 1.0, duration)
	var below_slowed: Dictionary = timer.call(0.0, false, true, 1.0, 0.5, duration)
	var below_overdrive: Dictionary = timer.call(9.0, false, true, 1.0, 2.0, duration)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("fired", true)) == false and is_equal_approx(float(below_one.get("timer_elapsed_after", -1.0)), 29.0) and bool(below_one.get("was_moved", true)) == false and bool(below_one.get("moved", false)) == true and bool(below_two.get("fired", true)) == false and is_equal_approx(float(below_two.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_two.get("was_moved", false)) == true and bool(below_two.get("moved", true)) == false and bool(below_slowed.get("fired", true)) == false and is_equal_approx(float(below_slowed.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_overdrive.get("fired", true)) == false and is_equal_approx(float(below_overdrive.get("timer_elapsed_after", -1.0)), 10.0)

	# No fire on a non-positive time_scale (a defensive port
	# guard -- Java timeScale is always positive in practice,
	# BuildingComp.java:98/461-478/2265-2266, so the guard is
	# unreachable in Java-exact play): the clock still
	# accumulates -- 29 + 1 = 30 -- it just never fires, never
	# resets, and never snapshots (both flags keep theirs).
	var zero_scale: Dictionary = timer.call(29.0, false, true, 1.0, 0.0, duration)
	var negative_scale: Dictionary = timer.call(29.0, true, false, 1.0, -1.0, duration)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("fired", true)) == false and is_equal_approx(float(zero_scale.get("timer_elapsed_after", -1.0)), 30.0) and bool(zero_scale.get("was_moved", true)) == false and bool(zero_scale.get("moved", false)) == true and bool(negative_scale.get("fired", true)) == false and is_equal_approx(float(negative_scale.get("timer_elapsed_after", -1.0)), 30.0) and bool(negative_scale.get("was_moved", false)) == true and bool(negative_scale.get("moved", true)) == false

	# The snapshot copies the OLD moved into was_moved on
	# fire: moved true -> was_moved true (fire_at_thirty
	# above), moved false -> was_moved false even when the
	# old was_moved was true (the copy overwrites, it does
	# not OR). A past-threshold clock (35 + 1) fires too.
	var copy_false: Dictionary = timer.call(29.0, true, false, 1.0, 1.0, duration)
	var past_threshold: Dictionary = timer.call(35.0, false, true, 1.0, 1.0, duration)
	proof["snapshot_copies_moved_to_was_moved"] = bool(fire_at_thirty.get("was_moved", false)) == true and bool(copy_false.get("fired", false)) and bool(copy_false.get("was_moved", true)) == false and is_equal_approx(float(copy_false.get("timer_elapsed_after", -1.0)), 0.0) and bool(past_threshold.get("fired", false)) and bool(past_threshold.get("was_moved", false)) == true

	# The snapshot clears moved on fire (fire_at_thirty,
	# fire_full_delta, past_threshold above all report moved
	# false), while a non-fire keeps moved true (below_one
	# above) and a non-fire keeps moved false (below_two).
	proof["snapshot_clears_moved_on_fire"] = bool(fire_at_thirty.get("moved", true)) == false and bool(fire_full_delta.get("moved", true)) == false and bool(past_threshold.get("moved", true)) == false and is_equal_approx(float(past_threshold.get("timer_elapsed_after", -1.0)), 0.0) and bool(below_one.get("moved", false)) == true and bool(below_two.get("moved", true)) == false

	# --- Live tick: two unlinked phase-conveyors placed
	# live; the tick driver is called directly (as the
	# N2288 proof does), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142.
	# Bridge A (cell (28, 21)) has its clock at 29.0 with
	# moved true and was_moved false, so one 1.0-tick step
	# fires the timer (29 + 1 = 30): was_moved becomes true,
	# moved clears to false, the clock resets to 0.0 -- and
	# because the snapshot runs BEFORE the advance, the
	# advance reads the snapshotted was_moved=true and
	# timeSpeed approaches 1.0 (0 -> 1/60, ItemBridge.java:
	# 326), moving time -8 -> -8 + 1/60. Bridge B (cell
	# (20, 10)) has its clock at 0.0 with moved true, so one
	# step does not fire: was_moved stays false, moved stays
	# true (the advance never clears it -- only the snapshot
	# does), the clock reads 1.0, and timeSpeed stays 0.0
	# because the advance read was_moved=false.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var bridge_a_cell := Vector2i(28, 21)
	var bridge_a := Sprite2D.new()
	game.add_child(bridge_a)
	game.call("record_placed_block", bridge_a, blocks_by_id["phase-conveyor"], bridge_a_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(bridge_a, blocks_by_id["phase-conveyor"])
	var bridge_a_frame: Dictionary = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bridge_a_frame["timer_check_moved_elapsed"] = 29.0
	bridge_a_frame["moved"] = true
	bridge_a_frame["was_moved"] = false
	bridge_a_frame["time"] = -8.0
	bridge_a_frame["time_speed"] = 0.0

	var bridge_b_cell := Vector2i(20, 10)
	var bridge_b := Sprite2D.new()
	game.add_child(bridge_b)
	game.call("record_placed_block", bridge_b, blocks_by_id["phase-conveyor"], bridge_b_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(bridge_b, blocks_by_id["phase-conveyor"])
	var bridge_b_frame: Dictionary = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bridge_b_frame["timer_check_moved_elapsed"] = 0.0
	bridge_b_frame["moved"] = true
	bridge_b_frame["was_moved"] = false
	bridge_b_frame["time"] = -8.0
	bridge_b_frame["time_speed"] = 0.0

	bridge_a_frame["power_status"] = 1.0
	bridge_b_frame["power_status"] = 1.0
	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	bridge_a_frame = bridge_a.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bridge_b_frame = bridge_b.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	proof["live_tick_snapshots_before_advance"] = bool(bridge_a_frame.get("was_moved", false)) == true and bool(bridge_a_frame.get("moved", true)) == false and is_equal_approx(float(bridge_a_frame.get("timer_check_moved_elapsed", -1.0)), 0.0) and is_equal_approx(float(bridge_a_frame.get("time_speed", -1.0)), 1.0 / 60.0) and is_equal_approx(float(bridge_a_frame.get("time", -1.0)), -8.0 + 1.0 / 60.0) and bool(bridge_b_frame.get("was_moved", true)) == false and bool(bridge_b_frame.get("moved", false)) == true and is_equal_approx(float(bridge_b_frame.get("timer_check_moved_elapsed", -1.0)), 1.0) and is_equal_approx(float(bridge_b_frame.get("time_speed", -1.0)), 0.0) and is_equal_approx(float(bridge_b_frame.get("time", -1.0)), -8.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeTimerCheckMovedProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
