extends Node

const main_scene := preload("res://scenes/Main.tscn")
const tractor_beam_turret_build_state := preload("res://src/game/SourceTractorBeamTurretBuildState.gd")
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

	# --- Pure retarget timer (N2317): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:69-80). The Java call is `if(timer(
	# timerTarget, retargetTime)){` (TractorBeamTurret.java:
	# 87-88) with `public final int timerTarget = timers++;`
	# (:20) and `public float retargetTime = 5f;` (:21):
	# elapsed += source_delta unconditionally (source_delta
	# is the UNSCALED Time.delta in ticks, so the frame clock
	# mirrors the global Time.time); retarget_tick = elapsed
	# >= duration (the LITERAL duration -- no timeScale
	# division, the N2290 lesson: Java passes retargetTime
	# straight to timer()); a non-positive time_scale is a
	# defensive guard (retarget_tick false -- the clock still
	# accumulates); timer_elapsed_after RESETS to 0.0 on fire
	# (a reset, not a subtraction like the Fracker
	# accumulator). Java retargets every 5 ticks at EVERY
	# time_scale; the time_scale 2.0 case below pins the JAVA
	# behavior (threshold 5, not 2.5), and the 2 + 1 overdrive
	# case pins that it does NOT fire early.
	var timer := func(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
		return tractor_beam_turret_build_state.source_tractor_beam_turret_retarget_timer_state(elapsed, source_delta, time_scale, duration)
	var duration: float = tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_RETARGET_DURATION

	# Fire at five ticks: 4 + 1 hits the threshold; a
	# single 5-tick delta fires at once; at time_scale 2.0
	# the threshold is still the literal 5, so 4 + 1 fires
	# (and 2 + 1 does NOT -- see the no-fire cases below).
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
	var below_pure: bool = bool(below_one.get("retarget_tick", true)) == false and is_equal_approx(float(below_one.get("timer_elapsed_after", -1.0)), 4.0) and bool(below_two.get("retarget_tick", true)) == false and is_equal_approx(float(below_two.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_slowed.get("retarget_tick", true)) == false and is_equal_approx(float(below_slowed.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_overdrive.get("retarget_tick", true)) == false and is_equal_approx(float(below_overdrive.get("timer_elapsed_after", -1.0)), 3.0)

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
	# (7 + 1) fires and resets to 0.0.
	var past_threshold: Dictionary = timer.call(7.0, 1.0, 1.0, duration)
	var reset_pure: bool = bool(past_threshold.get("retarget_tick", false)) and is_equal_approx(float(past_threshold.get("timer_elapsed_after", -1.0)), 0.0)

	# --- Pure advance retarget (N2230 selection, N2317
	# wiring): retarget_tick true with an empty list
	# overwrites the target to null (Java's unconditional
	# assignment, TractorBeamTurret.java:88); retarget_tick
	# false leaves the target untouched even with
	# candidates; retarget_tick true with a flying enemy
	# picks it. Building at (0, 0), team 1; the candidate is
	# a flying enemy at (50, 0), team 2.
	var seeded_target: Dictionary = {"x": 100.0, "y": 0.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}
	var pure_candidate: Dictionary = {"x": 50.0, "y": 0.0, "hit_size": 8.0, "flying": true, "grounded": false, "team": 2}
	var empty_tick: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": seeded_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var empty_tick_ok: bool = empty_tick.get("target", {}) == null
	var no_tick: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": seeded_target, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [pure_candidate], false, false, 0.0, 0.0, 0.0, 1.0, false)
	var no_tick_target: Dictionary = no_tick.get("target", {})
	var no_tick_ok: bool = no_tick_target is Dictionary and is_equal_approx(float(no_tick_target.get("x", -1.0)), 100.0)
	var pure_pick: Dictionary = tractor_beam_turret_build_state.source_tractor_beam_turret_update_tile_advance_state({"efficiency": 0.0, "target": null, "strength": 0.0, "rotation": 90.0}, 1.0, 1.0, 0.0, 0.0, 1, [pure_candidate], true, false, 0.0, 0.0, 0.0, 1.0, false)
	var pure_pick_target: Dictionary = pure_pick.get("target", {})
	var pure_pick_ok: bool = pure_pick_target is Dictionary and is_equal_approx(float(pure_pick_target.get("x", -1.0)), 50.0)

	# --- Live tick: three parallaxes placed live; the tick
	# driver is called directly (as the N2174 / N2250 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Parallax A (cell
	# (28, 21), building at (228, 172)) has its clock at 4.0
	# with a flying enemy 10 units east in frame["unit_
	# candidates"], so one 1.0-tick step fires the timer
	# (4 + 1 = 5) and the retarget reaches the advance: the
	# frame target becomes the candidate and the clock resets
	# to 0.0. Parallax B (cell (20, 10), building at (164,
	# 84)) has its clock at 4.0 with an empty candidate list
	# and a seeded target, so one step fires and the empty
	# retarget clears the target to null (Java's
	# unconditional assignment) and the clock resets to 0.0.
	# Parallax C (cell (12, 30), building at (100, 244)) has
	# its clock at 0.0 with a flying enemy 10 units east in
	# frame["unit_candidates"], so one step does not fire:
	# the target stays null and the clock reads 1.0.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var parallax_a_cell := Vector2i(28, 21)
	var parallax_a := Sprite2D.new()
	game.add_child(parallax_a)
	game.call("record_placed_block", parallax_a, blocks_by_id["parallax"], parallax_a_cell)
	tractor_beam_turret_build_state.source_tractor_beam_turret_bind_frame_state(parallax_a, blocks_by_id["parallax"])
	var parallax_a_frame: Dictionary = parallax_a.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	parallax_a_frame["timer_retarget_elapsed"] = 4.0
	parallax_a_frame["unit_candidates"] = [{"x": 238.0, "y": 172.0, "hit_size": 8.0, "flying": true, "grounded": false, "team": 2}]

	var parallax_b_cell := Vector2i(20, 10)
	var parallax_b := Sprite2D.new()
	game.add_child(parallax_b)
	game.call("record_placed_block", parallax_b, blocks_by_id["parallax"], parallax_b_cell)
	tractor_beam_turret_build_state.source_tractor_beam_turret_bind_frame_state(parallax_b, blocks_by_id["parallax"])
	var parallax_b_frame: Dictionary = parallax_b.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	parallax_b_frame["timer_retarget_elapsed"] = 4.0
	parallax_b_frame["unit_candidates"] = []
	parallax_b_frame["target"] = {"x": 164.0, "y": 114.0, "hit_size": 0.0, "flying": true, "grounded": false, "team": 2}

	var parallax_c_cell := Vector2i(12, 30)
	var parallax_c := Sprite2D.new()
	game.add_child(parallax_c)
	game.call("record_placed_block", parallax_c, blocks_by_id["parallax"], parallax_c_cell)
	tractor_beam_turret_build_state.source_tractor_beam_turret_bind_frame_state(parallax_c, blocks_by_id["parallax"])
	var parallax_c_frame: Dictionary = parallax_c.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	parallax_c_frame["timer_retarget_elapsed"] = 0.0
	parallax_c_frame["unit_candidates"] = [{"x": 110.0, "y": 244.0, "hit_size": 8.0, "flying": true, "grounded": false, "team": 2}]

	parallax_a_frame["power_status"] = 1.0
	parallax_b_frame["power_status"] = 1.0
	parallax_c_frame["power_status"] = 1.0
	tractor_beam_turret_build_state.source_tractor_beam_turret_tick_buildings_state(game, 1.0 / 60.0)
	parallax_a_frame = parallax_a.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	parallax_b_frame = parallax_b.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	parallax_c_frame = parallax_c.get_meta(tractor_beam_turret_build_state.SOURCE_TRACTOR_BEAM_TURRET_BUILDING_META_KEY, {})
	var live_a_target: Dictionary = parallax_a_frame.get("target", {})
	proof["live_tick_passes_retarget_on_fire"] = pure_pick_ok and live_a_target is Dictionary and is_equal_approx(float(live_a_target.get("x", -1.0)), 238.0) and is_equal_approx(float(live_a_target.get("y", -1.0)), 172.0)
	proof["fire_with_empty_candidates_clears_target"] = empty_tick_ok and no_tick_ok and parallax_b_frame.get("target", {}) == null
	proof["timer_no_fire_below_threshold"] = below_pure and parallax_c_frame.get("target", {}) == null
	proof["timer_resets_elapsed_on_fire"] = reset_pure and is_equal_approx(float(parallax_a_frame.get("timer_retarget_elapsed", -1.0)), 0.0) and is_equal_approx(float(parallax_b_frame.get("timer_retarget_elapsed", -1.0)), 0.0) and is_equal_approx(float(parallax_c_frame.get("timer_retarget_elapsed", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TractorBeamTurretRetargetCadenceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
