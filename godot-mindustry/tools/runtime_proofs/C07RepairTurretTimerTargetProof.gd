extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- Pure timer-target (N2280): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:69-80). The Java call is `if(timer(
	# timerTarget, 20)){` (RepairTurret.java:214-216) with
	# `public int timerTarget = timers++;` (:29) and
	# `public float repairRadius = 50f;` (:32): elapsed +=
	# source_delta unconditionally; fired = elapsed >=
	# duration / time_scale; a non-positive time_scale is
	# the infinite-time branch (fired false); elapsed_after
	# RESETS to 0.0 on fire (a reset, not a subtraction like
	# the Fracker accumulator). NOTE the threshold deviation:
	# Java passes a LITERAL 20 -- no timeScale division,
	# unlike the MendProjector / WallCrafter / ImpactReactor
	# timers -- so the port's 20/time_scale threshold is
	# Java-exact at time_scale 1f and diverges only under
	# overdrive / slowdown; the time_scale 2.0 case below
	# pins the PORT behavior (threshold 10), not Java.
	var timer := func(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
		return repair_turret_build_state.source_repair_turret_timer_target_state(elapsed, source_delta, time_scale, duration)
	var duration: float = repair_turret_build_state.SOURCE_REPAIR_TURRET_TIMER_TARGET_DURATION

	# Fire at twenty ticks: 19 + 1 hits the threshold; a
	# single 20-tick delta fires at once; at time_scale 2.0
	# the threshold is 20/2 = 10, so 9 + 1 fires.
	var fire_at_twenty: Dictionary = timer.call(19.0, 1.0, 1.0, duration)
	var fire_full_delta: Dictionary = timer.call(0.0, 20.0, 1.0, duration)
	var fire_overdrive: Dictionary = timer.call(9.0, 1.0, 2.0, duration)
	proof["timer_fires_at_twenty_ticks"] = is_equal_approx(duration, 20.0) and bool(fire_at_twenty.get("fired", false)) and is_equal_approx(float(fire_at_twenty.get("elapsed_after", -1.0)), 0.0) and bool(fire_full_delta.get("fired", false)) and is_equal_approx(float(fire_full_delta.get("elapsed_after", -1.0)), 0.0) and bool(fire_overdrive.get("fired", false))

	# No fire below the threshold: 18 + 1 = 19 keeps
	# accumulating; 0 + 1 = 1; at time_scale 0.5 the
	# threshold is 40, so 0 + 1 does not fire either.
	var below_one: Dictionary = timer.call(18.0, 1.0, 1.0, duration)
	var below_two: Dictionary = timer.call(0.0, 1.0, 1.0, duration)
	var below_slowed: Dictionary = timer.call(0.0, 1.0, 0.5, duration)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("fired", true)) == false and is_equal_approx(float(below_one.get("elapsed_after", -1.0)), 19.0) and bool(below_two.get("fired", true)) == false and is_equal_approx(float(below_two.get("elapsed_after", -1.0)), 1.0) and bool(below_slowed.get("fired", true)) == false and is_equal_approx(float(below_slowed.get("elapsed_after", -1.0)), 1.0)

	# No fire on a non-positive time_scale (the infinite-time
	# branch, TimerComp.java:11): the clock still accumulates
	# -- 19 + 1 = 20 -- it just never fires and never resets.
	var zero_scale: Dictionary = timer.call(19.0, 1.0, 0.0, duration)
	var negative_scale: Dictionary = timer.call(19.0, 1.0, -1.0, duration)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("fired", true)) == false and is_equal_approx(float(zero_scale.get("elapsed_after", -1.0)), 20.0) and bool(negative_scale.get("fired", true)) == false and is_equal_approx(float(negative_scale.get("elapsed_after", -1.0)), 20.0)

	# Elapsed resets on fire (pure half; the live half is
	# checked after the tick below): an already-past clock
	# (25 + 1) fires and resets to 0.0.
	var past_threshold: Dictionary = timer.call(25.0, 1.0, 1.0, duration)
	var reset_pure: bool = bool(past_threshold.get("fired", false)) and is_equal_approx(float(past_threshold.get("elapsed_after", -1.0)), 0.0)

	# --- Advance frame fallback (N2280): the N2226 test pins
	# the advance call text with a [] literal, so the
	# candidates ride the frame (the coolant_multiplier N2259
	# precedent) -- the advance falls back to frame["unit_
	# candidates"] when its explicit list is empty, and an
	# explicit non-empty list still wins. The selection logic
	# itself is untouched (N2226). Building at (224, 168)
	# (cell (28, 21), size-1 repair-point, offset 0);
	# repairRadius 60f, repairSpeed 0.45f.
	var frame_candidate: Dictionary = {"x": 234.0, "y": 168.0, "hit_size": 8.0, "valid": true, "damaged": true}
	var explicit_candidate: Dictionary = {"x": 244.0, "y": 168.0, "hit_size": 8.0, "valid": true, "damaged": true}
	var fallback_frame: Dictionary = {"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0, "unit_candidates": [frame_candidate]}
	var fallback_result: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state(fallback_frame, 1.0, 1.0, 0.45, 60.0, 224.0, 168.0, [])
	var fallback_target: Dictionary = fallback_result.get("target", {})
	var fallback_ok: bool = fallback_target is Dictionary and is_equal_approx(float(fallback_target.get("x", -1.0)), 234.0)
	var explicit_frame: Dictionary = {"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0, "unit_candidates": [frame_candidate]}
	var explicit_result: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state(explicit_frame, 1.0, 1.0, 0.45, 60.0, 224.0, 168.0, [explicit_candidate])
	var explicit_target: Dictionary = explicit_result.get("target", {})
	var explicit_wins: bool = explicit_target is Dictionary and is_equal_approx(float(explicit_target.get("x", -1.0)), 244.0)
	# Empty list AND empty frame key: the timer did not fire,
	# so the existing target is untouched (N2226 semantics).
	var untouched_frame: Dictionary = {"efficiency": 0.0, "target": {"x": 234.0, "y": 168.0, "distance": 10.0, "dead": false, "health": 50.0, "max_health": 100.0}, "strength": 0.0, "rotation": 90.0, "unit_candidates": []}
	var untouched_result: Dictionary = repair_turret_build_state.source_repair_turret_update_tile_advance_state(untouched_frame, 1.0, 1.0, 0.45, 60.0, 224.0, 168.0, [])
	var untouched_target: Dictionary = untouched_result.get("target", {})
	var untouched_ok: bool = untouched_target is Dictionary and is_equal_approx(float(untouched_target.get("x", -1.0)), 234.0)

	# --- Live tick: two repair-points placed live; the tick
	# driver is called directly (as the N2174 / N2250 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Point A (cell
	# (28, 21), building at (224, 168)) has its clock at 19.0
	# with a damaged candidate 10 units east, so one 1.0-tick
	# step fires the timer (19 + 1 = 20) and the candidate
	# reaches the advance: the frame target becomes the
	# candidate and the clock resets to 0.0. Point B (cell
	# (20, 10), building at (160, 80)) has its clock at 0.0
	# with a damaged candidate 10 units east, so one step
	# does not fire: the target stays null, the clock reads
	# 1.0, and frame["unit_candidates"] is stamped [].
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var point_a_cell := Vector2i(28, 21)
	var point_a := Sprite2D.new()
	game.add_child(point_a)
	game.call("record_placed_block", point_a, blocks_by_id["repair-point"], point_a_cell)
	repair_turret_build_state.source_repair_turret_bind_frame_state(point_a, blocks_by_id["repair-point"])
	var point_a_frame: Dictionary = point_a.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	point_a_frame["timer_target_elapsed"] = 19.0
	point_a_frame["unit_candidates"] = [{"x": 234.0, "y": 168.0, "hit_size": 8.0, "valid": true, "damaged": true}]

	var point_b_cell := Vector2i(20, 10)
	var point_b := Sprite2D.new()
	game.add_child(point_b)
	game.call("record_placed_block", point_b, blocks_by_id["repair-point"], point_b_cell)
	repair_turret_build_state.source_repair_turret_bind_frame_state(point_b, blocks_by_id["repair-point"])
	var point_b_frame: Dictionary = point_b.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	point_b_frame["timer_target_elapsed"] = 0.0
	point_b_frame["unit_candidates"] = [{"x": 170.0, "y": 80.0, "hit_size": 8.0, "valid": true, "damaged": true}]

	point_a_frame["power_status"] = 1.0
	point_b_frame["power_status"] = 1.0
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	point_a_frame = point_a.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	point_b_frame = point_b.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	var live_a_target: Dictionary = point_a_frame.get("target", {})
	var live_a_candidates: Array = point_a_frame.get("unit_candidates", [])
	proof["timer_passes_candidates_on_fire"] = fallback_ok and explicit_wins and live_a_target is Dictionary and is_equal_approx(float(live_a_target.get("x", -1.0)), 234.0) and is_equal_approx(float(live_a_target.get("y", -1.0)), 168.0) and live_a_candidates.size() == 1
	var live_b_target: Variant = point_b_frame.get("target", null)
	var live_b_candidates: Array = point_b_frame.get("unit_candidates", [{}])
	proof["timer_passes_empty_when_not_fired"] = untouched_ok and live_b_target == null and live_b_candidates.is_empty()
	proof["timer_resets_elapsed_on_fire"] = reset_pure and is_equal_approx(float(point_a_frame.get("timer_target_elapsed", -1.0)), 0.0) and is_equal_approx(float(point_b_frame.get("timer_target_elapsed", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretTimerTargetProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
