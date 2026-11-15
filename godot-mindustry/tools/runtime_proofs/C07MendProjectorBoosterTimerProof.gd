extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	# --- Pure timer (N2269): the frame-local Interval-
	# equivalent of TimerComp.timer (TimerComp.java:10-13,
	# `if(Float.isInfinite(time)) return false;` /
	# `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:
	# 20-26; Time.time counts TICKS, arc Time.java:69-80):
	# threshold = duration / time_scale; a non-positive
	# time_scale is the infinite-time branch (fired false);
	# fired = elapsed >= threshold; elapsed_after RESETS
	# to 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator). The Java gate is
	# `if(optionalEfficiency > 0 && timer(timerUse, useTime
	# / timeScale) && canHeal){` (MendProjector.java:102,
	# `public float useTime = 400f;`, MendProjector.
	# java:31, no def overrides it).
	var fires_at_threshold: Dictionary = mend_projector_build_state.source_mend_projector_timer_use_state(400.0, 400.0, 1.0)
	var fires_above_threshold: Dictionary = mend_projector_build_state.source_mend_projector_timer_use_state(401.0, 400.0, 1.0)
	var fires_scaled: Dictionary = mend_projector_build_state.source_mend_projector_timer_use_state(200.0, 400.0, 2.0)
	proof["timer_fires_at_use_time"] = bool(fires_at_threshold.get("fired", false)) and is_equal_approx(float(fires_at_threshold.get("elapsed_after", -1.0)), 0.0) and is_equal_approx(float(fires_at_threshold.get("threshold", -1.0)), 400.0) and bool(fires_above_threshold.get("fired", false)) and bool(fires_scaled.get("fired", false)) and is_equal_approx(float(fires_scaled.get("threshold", -1.0)), 200.0)

	var below_threshold: Dictionary = mend_projector_build_state.source_mend_projector_timer_use_state(399.9, 400.0, 1.0)
	var below_scaled: Dictionary = mend_projector_build_state.source_mend_projector_timer_use_state(199.9, 400.0, 2.0)
	proof["timer_no_fire_below_threshold"] = bool(below_threshold.get("fired", true)) == false and is_equal_approx(float(below_threshold.get("elapsed_after", -1.0)), 399.9) and bool(below_scaled.get("fired", true)) == false and is_equal_approx(float(below_scaled.get("elapsed_after", -1.0)), 199.9)

	var zero_scale: Dictionary = mend_projector_build_state.source_mend_projector_timer_use_state(400.0, 400.0, 0.0)
	var negative_scale: Dictionary = mend_projector_build_state.source_mend_projector_timer_use_state(400.0, 400.0, -1.0)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("fired", true)) == false and is_equal_approx(float(zero_scale.get("elapsed_after", -1.0)), 400.0) and is_inf(float(zero_scale.get("threshold", 0.0))) and bool(negative_scale.get("fired", true)) == false

	# --- Live tick: the mender is a MendProjector with a power
	# consumer (consumePower 0.3f) and a silicon booster row,
	# placed live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155 proofs do),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The timer consume
	# runs between the advance and the heal scan (Java order,
	# MendProjector.java:102-104 before :106+): when the
	# folded optionalEfficiency is positive and the timer
	# fires and canHeal holds (the documented default true),
	# consume() removes 1 booster item per def
	# (ConsumeItems.trigger, ConsumeItems.java:44-48,
	# clamped by ItemModule.remove, ItemModule.java:
	# 258-263) and the elapsed clock resets to 0.0.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["mender"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	mend_projector_build_state.source_mend_projector_bind_frame_state(projector, blocks_by_id["mender"])
	var projector_frame: Dictionary = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})

	# Full power, silicon held, timer at the threshold: the
	# tick accumulates one more tick (1.0/60.0s = 1 tick),
	# the timer fires, consume() removes 1 silicon and the
	# elapsed clock resets to 0.0.
	projector_frame["power_status"] = 1.0
	projector_frame["items"] = {"silicon": 2}
	projector_frame["timer_use_elapsed"] = 400.0
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	proof["timer_consume_removes_booster_item"] = int(projector_frame.get("items", {}).get("silicon", -1)) == 1 and is_equal_approx(float(projector_frame.get("timer_use_elapsed", -1.0)), 0.0) and is_equal_approx(float(projector_frame.get("optional_efficiency", -1.0)), 1.0)

	# Full power, no silicon, timer at the threshold: the
	# booster row folds optionalEfficiency 0, so the gate is
	# closed -- no removal and NO elapsed reset (Java
	# short-circuits before calling timer(), so the Interval
	# keeps its old stamp and fires at once when the gate
	# reopens).
	projector_frame["power_status"] = 1.0
	projector_frame["items"] = {}
	projector_frame["timer_use_elapsed"] = 400.0
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	proof["timer_requires_positive_optional"] = is_equal_approx(float(projector_frame.get("optional_efficiency", -1.0)), 0.0) and float(projector_frame.get("timer_use_elapsed", 0.0)) >= 400.0 and int(projector_frame.get("items", {}).get("silicon", 0)) == 0

	# Per-def stacks: the mend-projector consumes phaseFabric,
	# not silicon (Blocks.java:1941 vs :1929) -- with both
	# held, only the phaseFabric count drops.
	var big_cell := Vector2i(32, 20)
	var big_projector := Sprite2D.new()
	game.add_child(big_projector)
	game.call("record_placed_block", big_projector, blocks_by_id["mend-projector"], big_cell)
	mend_projector_build_state.source_mend_projector_bind_frame_state(big_projector, blocks_by_id["mend-projector"])
	var big_frame: Dictionary = big_projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	big_frame["power_status"] = 1.0
	big_frame["items"] = {"phase-fabric": 1, "silicon": 5}
	big_frame["timer_use_elapsed"] = 400.0
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	big_frame = big_projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	proof["timer_uses_per_def_stack"] = int(big_frame.get("items", {}).get("phase-fabric", -1)) == 0 and int(big_frame.get("items", {}).get("silicon", -1)) == 5 and is_equal_approx(float(big_frame.get("timer_use_elapsed", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorBoosterTimerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
