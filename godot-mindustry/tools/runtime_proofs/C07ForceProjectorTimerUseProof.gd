extends Node

const main_scene := preload("res://scenes/Main.tscn")
const force_projector_build_state := preload("res://src/game/SourceForceProjectorBuildState.gd")
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

	# --- Pure timer-use (N2326): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:75). The Java call is
	# `if(phaseValid && !broken && timer(timerUse,
	# phaseUseTime / timeScale) && efficiency > 0){`
	# (ForceProjector.java:211-213) with `public final int
	# timerUse = timers++;` (:31) and `public float
	# phaseUseTime = 350f;` (:32): elapsed += source_delta
	# unconditionally (source_delta is the UNSCALED
	# Time.delta in ticks, so the frame clock mirrors the
	# global Time.time); consume_tick = elapsed >= threshold,
	# where the threshold is duration / time_scale -- Java
	# DIVIDES phaseUseTime by timeScale here, unlike the
	# advances-12 literal timers; a non-positive time_scale
	# is a defensive guard (consume_tick false, threshold INF
	# -- the clock still accumulates); timer_elapsed_after
	# RESETS to 0.0 on fire (a reset, not a subtraction like
	# the Fracker accumulator). The timer ONLY supplies
	# consume_tick -- the gate (phaseValid / !broken /
	# efficiency > 0) stays INSIDE the N2235 advance, so a
	# timer fire alone never consumes. consume() itself
	# (`for(Consume cons : block.consumers){` /
	# `cons.trigger(self());`, BuildingComp.java:1911-1915)
	# removes 1 phaseFabric on the single def only:
	# `itemConsumer = consumeItem(Items.phaseFabric).boost();`
	# (Blocks.java:1974; consumeItem(item) is a stack of 1,
	# Block.java:1167-1168) via ConsumeItems.trigger
	# (ConsumeItems.java:44-48), clamped by ItemModule.remove
	# (ItemModule.java:258-263).
	var timer := func(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
		return force_projector_build_state.source_force_projector_timer_use_state(elapsed, source_delta, time_scale, duration)
	var duration: float = force_projector_build_state.SOURCE_FORCE_PROJECTOR_PHASE_USE_TIME

	# Fire at 350f / time_scale: 349 + 1 hits the threshold
	# at time_scale 1.0 (threshold 350); a single 350-tick
	# delta fires at once; at time_scale 2.0 the threshold
	# is 175, so 174 + 1 fires -- a literal-350 threshold
	# would NOT fire there (see the no-fire cases below).
	var fire_at_use_time: Dictionary = timer.call(349.0, 1.0, 1.0, duration)
	var fire_full_delta: Dictionary = timer.call(0.0, 350.0, 1.0, duration)
	var fire_overdrive: Dictionary = timer.call(174.0, 1.0, 2.0, duration)
	proof["timer_fires_at_use_time_over_time_scale"] = is_equal_approx(duration, 350.0) and bool(fire_at_use_time.get("consume_tick", false)) and is_equal_approx(float(fire_at_use_time.get("timer_elapsed_after", -1.0)), 0.0) and is_equal_approx(float(fire_at_use_time.get("threshold", -1.0)), 350.0) and bool(fire_full_delta.get("consume_tick", false)) and is_equal_approx(float(fire_full_delta.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_overdrive.get("consume_tick", false)) and is_equal_approx(float(fire_overdrive.get("threshold", -1.0)), 175.0) and is_equal_approx(float(fire_overdrive.get("timer_elapsed_after", -1.0)), 0.0)

	# No fire below the threshold: 348 + 1 = 349 keeps
	# accumulating; 0 + 1 = 1; at time_scale 0.5 the
	# threshold is 700, so 349 + 1 = 350 does NOT fire -- a
	# literal-350 threshold WOULD fire there.
	var below_one: Dictionary = timer.call(348.0, 1.0, 1.0, duration)
	var below_two: Dictionary = timer.call(0.0, 1.0, 1.0, duration)
	var below_slowed: Dictionary = timer.call(349.0, 1.0, 0.5, duration)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("consume_tick", true)) == false and is_equal_approx(float(below_one.get("timer_elapsed_after", -1.0)), 349.0) and bool(below_two.get("consume_tick", true)) == false and is_equal_approx(float(below_two.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_slowed.get("consume_tick", true)) == false and is_equal_approx(float(below_slowed.get("timer_elapsed_after", -1.0)), 350.0) and is_equal_approx(float(below_slowed.get("threshold", -1.0)), 700.0)

	# No fire on a non-positive time_scale (a defensive port
	# guard -- Java timeScale is always positive in practice,
	# BuildingComp.java:98/461-478/2265-2266, so the guard is
	# unreachable in Java-exact play): the clock still
	# accumulates -- 349 + 1 = 350 -- it just never fires and
	# never resets, and the threshold reads INF.
	var zero_scale: Dictionary = timer.call(349.0, 1.0, 0.0, duration)
	var negative_scale: Dictionary = timer.call(349.0, 1.0, -1.0, duration)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("consume_tick", true)) == false and is_equal_approx(float(zero_scale.get("timer_elapsed_after", -1.0)), 350.0) and is_inf(float(zero_scale.get("threshold", 0.0))) and bool(negative_scale.get("consume_tick", true)) == false and is_equal_approx(float(negative_scale.get("timer_elapsed_after", -1.0)), 350.0) and is_inf(float(negative_scale.get("threshold", 0.0)))

	# Elapsed resets on fire (pure half; the live half is
	# checked after the tick below): an already-past clock
	# (400 + 1) fires and resets to 0.0.
	var past_threshold: Dictionary = timer.call(400.0, 1.0, 1.0, duration)
	var reset_pure: bool = bool(past_threshold.get("consume_tick", false)) and is_equal_approx(float(past_threshold.get("timer_elapsed_after", -1.0)), 0.0)

	# --- Consume_tick alone does not consume (pure half):
	# the timer fires (349 + 1 = 350) and its consume_tick
	# reaches the N2235 advance, but the gate still needs
	# phaseValid && !broken && efficiency > 0: no item
	# consumer efficiency, a broken shield (the INCOMING
	# broken, before the clear), or no power all leave
	# consumed false. The positive control (all gates open)
	# reports consumed true, and no tick reports false even
	# with the gates open.
	var base_frame := {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var gate_open: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], true, true, 1.0)
	var gate_no_item: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], true, true, 0.0)
	var gate_broken: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 10.0, "broken": true, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], true, true, 1.0)
	var gate_no_power: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state({"efficiency": 0.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}, 1.0, 1.0, 0.0, 0.0, [], true, true, 1.0)
	var gate_no_tick: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(base_frame, 1.0, 1.0, 0.0, 0.0, [], false, true, 1.0)
	var consume_alone_pure: bool = bool(gate_open.get("consumed", false)) and bool(gate_no_item.get("consumed", true)) == false and bool(gate_broken.get("consumed", true)) == false and bool(gate_no_power.get("consumed", true)) == false and bool(gate_no_tick.get("consumed", true)) == false

	# --- Live tick: three force-projectors placed live; the
	# tick driver is called directly (as the N2235 / N2261
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142.
	# Projector A (cell (28, 21)) holds 2 phaseFabric, is
	# unbroken, and has its clock at 349.0, so one 1.0-tick
	# step fires the timer (349 + 1 = 350): consume_tick
	# reaches the advance, the gate passes (phaseValid from
	# the live item row, !broken, efficiency 1.0), the
	# advance reports consumed, and the driver removes
	# exactly 1 phaseFabric (2 -> 1); the clock resets to
	# 0.0. Projector B (cell (20, 10)) holds 2 phaseFabric
	# and is unbroken, but its clock is at 0.0, so one step
	# does not fire: nothing is consumed, the fabric stays
	# at 2, and the clock reads 1.0. Projector C (cell
	# (12, 10)) has its clock at 349.0 but holds NO
	# phaseFabric, so the timer fires but the advance gate
	# fails (phaseValid false): nothing is consumed, and the
	# clock still resets to 0.0 -- the documented
	# gate-closed-reset deviation (Java short-circuits before
	# timer() and keeps its old stamp).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_a_cell := Vector2i(28, 21)
	var projector_a := Sprite2D.new()
	game.add_child(projector_a)
	game.call("record_placed_block", projector_a, blocks_by_id["force-projector"], projector_a_cell)
	force_projector_build_state.source_force_projector_bind_frame_state(projector_a, blocks_by_id["force-projector"])
	var projector_a_frame: Dictionary = projector_a.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	projector_a_frame["timer_use_elapsed"] = 349.0
	projector_a_frame["items"] = {"phase-fabric": 2}
	projector_a_frame["broken"] = false
	projector_a_frame["power_status"] = 1.0

	var projector_b_cell := Vector2i(20, 10)
	var projector_b := Sprite2D.new()
	game.add_child(projector_b)
	game.call("record_placed_block", projector_b, blocks_by_id["force-projector"], projector_b_cell)
	force_projector_build_state.source_force_projector_bind_frame_state(projector_b, blocks_by_id["force-projector"])
	var projector_b_frame: Dictionary = projector_b.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	projector_b_frame["timer_use_elapsed"] = 0.0
	projector_b_frame["items"] = {"phase-fabric": 2}
	projector_b_frame["broken"] = false
	projector_b_frame["power_status"] = 1.0

	var projector_c_cell := Vector2i(12, 10)
	var projector_c := Sprite2D.new()
	game.add_child(projector_c)
	game.call("record_placed_block", projector_c, blocks_by_id["force-projector"], projector_c_cell)
	force_projector_build_state.source_force_projector_bind_frame_state(projector_c, blocks_by_id["force-projector"])
	var projector_c_frame: Dictionary = projector_c.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	projector_c_frame["timer_use_elapsed"] = 349.0
	projector_c_frame["items"] = {}
	projector_c_frame["broken"] = false
	projector_c_frame["power_status"] = 1.0

	force_projector_build_state.source_force_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_a_frame = projector_a.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	projector_b_frame = projector_b.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	projector_c_frame = projector_c.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	var live_a_items: Dictionary = projector_a_frame.get("items", {})
	var live_b_items: Dictionary = projector_b_frame.get("items", {})
	var live_c_items: Dictionary = projector_c_frame.get("items", {})
	proof["live_tick_consumes_phase_fabric_on_fire"] = bool(projector_a_frame.get("consumed", false)) and int(live_a_items.get("phase-fabric", -1)) == 1 and is_equal_approx(float(projector_a_frame.get("timer_use_elapsed", -1.0)), 0.0) and bool(projector_b_frame.get("consumed", true)) == false and int(live_b_items.get("phase-fabric", -1)) == 2 and is_equal_approx(float(projector_b_frame.get("timer_use_elapsed", -1.0)), 1.0)
	proof["timer_resets_elapsed_on_fire"] = reset_pure and is_equal_approx(float(projector_a_frame.get("timer_use_elapsed", -1.0)), 0.0) and is_equal_approx(float(projector_b_frame.get("timer_use_elapsed", -1.0)), 1.0)
	proof["consume_tick_alone_does_not_consume"] = consume_alone_pure and bool(projector_c_frame.get("consumed", true)) == false and int(live_c_items.get("phase-fabric", 0)) == 0 and is_equal_approx(float(projector_c_frame.get("timer_use_elapsed", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ForceProjectorTimerUseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
