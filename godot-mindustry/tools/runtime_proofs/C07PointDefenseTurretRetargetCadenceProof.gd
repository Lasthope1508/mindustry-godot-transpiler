extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- Pure retarget timer (N2316): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:69-80). The Java call is `if(timer(
	# timerTarget, retargetTime)){` (PointDefenseTurret.java:
	# 65-67) with `public final int timerTarget = timers++;`
	# (:20) and `public float retargetTime = 5f;` (:21):
	# elapsed += source_delta unconditionally (source_delta is
	# the UNSCALED Time.delta in ticks, so the frame clock
	# mirrors the global Time.time); retarget_tick = elapsed
	# >= duration (the LITERAL duration -- no timeScale
	# division, the N2290 lesson); a non-positive time_scale
	# is a defensive guard (retarget_tick false -- the clock
	# still accumulates); timer_elapsed_after RESETS to 0.0
	# on fire (a reset, not a subtraction like the Fracker
	# accumulator). Java passes retargetTime straight to
	# timer() -- no timeScale division, unlike the
	# MendProjector / WallCrafter / ImpactReactor timers --
	# so the timer fires every 5 ticks at EVERY time_scale;
	# the time_scale 2.0 case below pins the JAVA behavior
	# (threshold 5, not 2.5), and the 2 + 1 overdrive case
	# pins that it does NOT fire early.
	var timer := func(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
		return point_defense_turret_build_state.source_point_defense_turret_retarget_timer_state(elapsed, source_delta, time_scale, duration)
	var duration: float = point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_RETARGET_TIME

	# Fire at five ticks: 4 + 1 hits the threshold; a single
	# 5-tick delta fires at once; at time_scale 2.0 the
	# threshold is still the literal 5, so 4 + 1 fires (and
	# 2 + 1 does NOT -- see the no-fire cases below).
	var fire_at_five: Dictionary = timer.call(4.0, 1.0, 1.0, duration)
	var fire_full_delta: Dictionary = timer.call(0.0, 5.0, 1.0, duration)
	var fire_overdrive: Dictionary = timer.call(4.0, 1.0, 2.0, duration)
	proof["timer_fires_at_five_ticks"] = is_equal_approx(duration, 5.0) and bool(fire_at_five.get("retarget_tick", false)) and is_equal_approx(float(fire_at_five.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_full_delta.get("retarget_tick", false)) and is_equal_approx(float(fire_full_delta.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_overdrive.get("retarget_tick", false))

	# No fire below the threshold: 3 + 1 = 4 keeps
	# accumulating; 0 + 1 = 1; at time_scale 0.5 the
	# threshold is still the literal 5, so 0 + 1 does not
	# fire either; and at time_scale 2.0 (overdrive) 2 + 1
	# = 3 does NOT fire -- a 5/time_scale deviation would
	# fire here (threshold 2.5), the literal-5 threshold
	# does not.
	var below_one: Dictionary = timer.call(3.0, 1.0, 1.0, duration)
	var below_two: Dictionary = timer.call(0.0, 1.0, 1.0, duration)
	var below_slowed: Dictionary = timer.call(0.0, 1.0, 0.5, duration)
	var below_overdrive: Dictionary = timer.call(2.0, 1.0, 2.0, duration)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("retarget_tick", true)) == false and is_equal_approx(float(below_one.get("timer_elapsed_after", -1.0)), 4.0) and bool(below_two.get("retarget_tick", true)) == false and is_equal_approx(float(below_two.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_slowed.get("retarget_tick", true)) == false and is_equal_approx(float(below_slowed.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_overdrive.get("retarget_tick", true)) == false and is_equal_approx(float(below_overdrive.get("timer_elapsed_after", -1.0)), 3.0)

	# No fire on a non-positive time_scale (a defensive port
	# guard -- Java timeScale is always positive in practice,
	# BuildingComp.java:98/461-478/2265-2266, so the guard is
	# unreachable in Java-exact play): the clock still
	# accumulates -- 4 + 1 = 5 -- it just never fires and
	# never resets.
	var zero_scale: Dictionary = timer.call(4.0, 1.0, 0.0, duration)
	var negative_scale: Dictionary = timer.call(4.0, 1.0, -1.0, duration)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("retarget_tick", true)) == false and is_equal_approx(float(zero_scale.get("timer_elapsed_after", -1.0)), 5.0) and bool(negative_scale.get("retarget_tick", true)) == false and is_equal_approx(float(negative_scale.get("timer_elapsed_after", -1.0)), 5.0)

	# Elapsed resets on fire (pure half; the live half is
	# checked after the tick below): an already-past clock
	# (9 + 1) fires and resets to 0.0.
	var past_threshold: Dictionary = timer.call(9.0, 1.0, 1.0, duration)
	var reset_pure: bool = bool(past_threshold.get("retarget_tick", false)) and is_equal_approx(float(past_threshold.get("timer_elapsed_after", -1.0)), 0.0)

	# --- Fire with empty bullets clears the target (pure
	# half; the live half is segment A below): Java overwrites
	# the target UNCONDITIONALLY on a timer tick
	# (PointDefenseTurret.java:66), so a retarget tick with no
	# qualifying bullet clears the target to null -- and the
	# driver passes the empty list, so a live fire with no
	# bullets clears it too. With retarget_tick false the
	# target is untouched (the timer did not fire).
	var held_bullet := {"x": 10.0, "y": 0.0, "team": 1, "type": "bullet", "hittable": true, "added": true, "damage": 100.0}
	var empty_fire: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": held_bullet, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], true)
	var no_tick_kept: Dictionary = point_defense_turret_build_state.source_point_defense_turret_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "target": held_bullet, "rotation": 90.0, "reload_counter": 0.0}, 1.0, 1.0, 180.0, 30.0, 8.0, 0.0, 0.0, [], false)
	var empty_fire_ok: bool = empty_fire.get("target", {}) == null and no_tick_kept.get("target", null) != null

	# --- Live tick: two segments placed live; the tick driver
	# is called directly (as the N2151 / N2217 / N2229 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Segment A (cell
	# (28, 20), building at (228, 164)) has its clock at 4.0
	# with a bullet seeded directly above it at (228, 194),
	# so one 1.0-tick step fires the timer (4 + 1 = 5) and the
	# retarget_tick reaches the advance: with the empty bullet
	# list the target clears to null and the clock resets to
	# 0.0. Segment B (cell (20, 10), building at (164, 84))
	# has its clock at 0.0 with a bullet seeded directly above
	# it at (164, 114), so one step does not fire: the target
	# stays set, the clock reads 1.0, and the reload counter
	# charges 0 -> 0.5 at the folded 0.5 efficiency. Both
	# placed segments are sharded (team 1, the
	# record_placed_block default), so the bullets are crux
	# (team 2, Team.java:35) -- enemy bullets.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var segment_a_cell := Vector2i(28, 20)
	var segment_a := Sprite2D.new()
	game.add_child(segment_a)
	game.call("record_placed_block", segment_a, blocks_by_id["segment"], segment_a_cell)
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment_a, blocks_by_id["segment"])
	var segment_a_frame: Dictionary = segment_a.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	segment_a_frame["target"] = {"x": 228.0, "y": 194.0, "team": 2, "type": "bullet", "hittable": true, "added": true, "damage": 20.0}
	segment_a_frame["timer_retarget_elapsed"] = 4.0
	segment_a_frame["power_status"] = 0.5

	var segment_b_cell := Vector2i(20, 10)
	var segment_b := Sprite2D.new()
	game.add_child(segment_b)
	game.call("record_placed_block", segment_b, blocks_by_id["segment"], segment_b_cell)
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment_b, blocks_by_id["segment"])
	var segment_b_frame: Dictionary = segment_b.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	segment_b_frame["target"] = {"x": 164.0, "y": 114.0, "team": 2, "type": "bullet", "hittable": true, "added": true, "damage": 20.0}
	segment_b_frame["timer_retarget_elapsed"] = 0.0
	segment_b_frame["power_status"] = 0.5

	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	segment_a_frame = segment_a.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	segment_b_frame = segment_b.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["live_tick_passes_retarget_on_fire"] = is_equal_approx(float(segment_a_frame.get("timer_retarget_elapsed", -1.0)), 0.0) and segment_a_frame.get("target", {}) == null and is_equal_approx(float(segment_b_frame.get("timer_retarget_elapsed", -1.0)), 1.0) and segment_b_frame.get("target", null) != null and is_equal_approx(float(segment_b_frame.get("reload_counter", -1.0)), 0.5)
	proof["fire_with_empty_bullets_clears_target"] = empty_fire_ok and segment_a_frame.get("target", {}) == null
	proof["timer_resets_elapsed_on_fire"] = reset_pure and is_equal_approx(float(segment_a_frame.get("timer_retarget_elapsed", -1.0)), 0.0) and is_equal_approx(float(segment_b_frame.get("timer_retarget_elapsed", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretRetargetCadenceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
