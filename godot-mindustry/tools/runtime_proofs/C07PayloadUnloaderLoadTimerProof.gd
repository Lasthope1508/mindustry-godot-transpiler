extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _payload_block(has_items: bool, has_liquids: bool, instant: bool, cap: Variant, buffered: bool) -> Dictionary:
	return {"has_items": has_items, "has_liquids": has_liquids, "instant_deconstruct": instant, "cons_power_capacity": cap, "cons_power_buffered": buffered}


func _payload(block: Dictionary, items: Dictionary, liquids: Dictionary, power_status: float) -> Dictionary:
	return {"block": block, "build": {"items": items, "liquids": liquids, "power_status": power_status}}


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

	# --- Pure load timer (N2320): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:69-80). The Java call is `if(efficiency >
	# 0.01f && timer(timerLoad, loadTime / efficiency)){`
	# (PayloadUnloader.java:69) with `public final int
	# timerLoad = timers++;` (PayloadLoader.java:20) and
	# `public float loadTime = 2f;` (PayloadLoader.java:22,
	# inherited): elapsed += source_delta unconditionally
	# (source_delta is the UNSCALED Time.delta in ticks, so
	# the frame clock mirrors the global Time.time);
	# load_tick = (efficiency > 0.01) and (elapsed >=
	# loadTime / efficiency) -- the threshold divides by
	# EFFICIENCY, not timeScale (the N2290 lesson);
	# efficiency <= 0 is the TimerComp infinite rule
	# (threshold +inf, no fire) and the divide-by-zero guard;
	# a non-positive time_scale is the same defensive guard
	# (never fires -- the clock still accumulates);
	# timer_elapsed_after RESETS to 0.0 only when load_tick
	# is true (a reset, not a subtraction like the Fracker
	# accumulator). The Java short-circuit order matters:
	# efficiency <= 0.01 means Java never calls timer(), so
	# the clock keeps accumulating and a recovered efficiency
	# fires at once. The Unloader has NO dynamic power
	# consumer (`loadPowerDynamic = false;`,
	# PayloadUnloader.java:18), so the folded efficiency the
	# timer reads is the power-only fold, exact.
	var timer := func(elapsed: float, source_delta: float, time_scale: float, efficiency: float, load_time: float) -> Dictionary:
		return payload_unloader_build_state.source_payload_unloader_load_timer_state(elapsed, source_delta, time_scale, efficiency, load_time)
	var load_time: float = payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_LOAD_TIME

	# Fire at loadTime / efficiency: eff 1.0 fires at 2
	# ticks (1 + 1); eff 0.5 fires at 4 ticks (3 + 1); eff
	# 0.25 fires at 8 ticks (7 + 1); a single 2-tick delta
	# fires at once at eff 1.0. Every fire resets the clock
	# to 0.0.
	var fire_eff_one: Dictionary = timer.call(1.0, 1.0, 1.0, 1.0, load_time)
	var fire_eff_half: Dictionary = timer.call(3.0, 1.0, 1.0, 0.5, load_time)
	var fire_eff_quarter: Dictionary = timer.call(7.0, 1.0, 1.0, 0.25, load_time)
	var fire_full_delta: Dictionary = timer.call(0.0, 2.0, 1.0, 1.0, load_time)
	proof["timer_fires_at_load_time_over_efficiency"] = is_equal_approx(load_time, 2.0) and bool(fire_eff_one.get("load_tick", false)) and is_equal_approx(float(fire_eff_one.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_eff_half.get("load_tick", false)) and is_equal_approx(float(fire_eff_half.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_eff_quarter.get("load_tick", false)) and is_equal_approx(float(fire_eff_quarter.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_full_delta.get("load_tick", false)) and is_equal_approx(float(fire_full_delta.get("timer_elapsed_after", -1.0)), 0.0)

	# No fire below the threshold: 0 + 1 = 1 keeps
	# accumulating at eff 1.0 (threshold 2); 2 + 1 = 3 keeps
	# accumulating at eff 0.5 (threshold 4); 0 + 1 = 1 at
	# eff 0.25 (threshold 8) is nowhere near.
	var below_one: Dictionary = timer.call(0.0, 1.0, 1.0, 1.0, load_time)
	var below_half: Dictionary = timer.call(2.0, 1.0, 1.0, 0.5, load_time)
	var below_quarter: Dictionary = timer.call(0.0, 1.0, 1.0, 0.25, load_time)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("load_tick", true)) == false and is_equal_approx(float(below_one.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_half.get("load_tick", true)) == false and is_equal_approx(float(below_half.get("timer_elapsed_after", -1.0)), 3.0) and bool(below_quarter.get("load_tick", true)) == false and is_equal_approx(float(below_quarter.get("timer_elapsed_after", -1.0)), 1.0)

	# No fire when efficiency is low -- but the clock still
	# accumulates (the Java short-circuit: efficiency <=
	# 0.01 means timer() is never called, so no reset, while
	# Time.time keeps growing). At eff 0.01 exactly the gate
	# is strict (Java `efficiency > 0.01f`): 1 + 1 = 2
	# accumulates without firing. At eff 0.0 the threshold
	# is infinite (the TimerComp infinite rule + the
	# divide-by-zero guard): 5 + 1 = 6 accumulates without
	# firing. A negative efficiency is the same infinite
	# rule: 5 + 1 = 6.
	var low_gate: Dictionary = timer.call(1.0, 1.0, 1.0, 0.01, load_time)
	var low_zero: Dictionary = timer.call(5.0, 1.0, 1.0, 0.0, load_time)
	var low_negative: Dictionary = timer.call(5.0, 1.0, 1.0, -1.0, load_time)
	proof["timer_no_fire_when_efficiency_low"] = bool(low_gate.get("load_tick", true)) == false and is_equal_approx(float(low_gate.get("timer_elapsed_after", -1.0)), 2.0) and bool(low_zero.get("load_tick", true)) == false and is_equal_approx(float(low_zero.get("timer_elapsed_after", -1.0)), 6.0) and bool(low_negative.get("load_tick", true)) == false and is_equal_approx(float(low_negative.get("timer_elapsed_after", -1.0)), 6.0)

	# Fire at once when efficiency recovers: the clock
	# accumulated to 2.0 while efficiency was 0 (no fire, no
	# reset), so the very next tick at eff 1.0 fires
	# immediately (2 + 1 = 3 >= 2) and resets to 0.0. The
	# same shape holds from the strict gate: 1 + 1 = 2
	# accumulated at eff 0.01, then eff 1.0 fires at once.
	var stalled: Dictionary = timer.call(1.0, 1.0, 1.0, 0.0, load_time)
	var recovered: Dictionary = timer.call(float(stalled.get("timer_elapsed_after", -1.0)), 1.0, 1.0, 1.0, load_time)
	var stalled_gate: Dictionary = timer.call(1.0, 1.0, 1.0, 0.01, load_time)
	var recovered_gate: Dictionary = timer.call(float(stalled_gate.get("timer_elapsed_after", -1.0)), 1.0, 1.0, 1.0, load_time)
	proof["timer_fires_when_efficiency_recovers"] = bool(stalled.get("load_tick", true)) == false and is_equal_approx(float(stalled.get("timer_elapsed_after", -1.0)), 2.0) and bool(recovered.get("load_tick", false)) and is_equal_approx(float(recovered.get("timer_elapsed_after", -1.0)), 0.0) and bool(stalled_gate.get("load_tick", true)) == false and is_equal_approx(float(stalled_gate.get("timer_elapsed_after", -1.0)), 2.0) and bool(recovered_gate.get("load_tick", false)) and is_equal_approx(float(recovered_gate.get("timer_elapsed_after", -1.0)), 0.0)

	# No fire on a non-positive time_scale (a defensive port
	# guard -- Java timeScale is always positive in practice,
	# BuildingComp.java:98/461-478/2265-2266, so the guard is
	# unreachable in Java-exact play): the clock still
	# accumulates -- 1 + 1 = 2 -- it just never fires and
	# never resets. A negative time_scale is the same guard.
	var zero_scale: Dictionary = timer.call(1.0, 1.0, 0.0, 1.0, load_time)
	var negative_scale: Dictionary = timer.call(1.0, 1.0, -1.0, 1.0, load_time)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("load_tick", true)) == false and is_equal_approx(float(zero_scale.get("timer_elapsed_after", -1.0)), 2.0) and bool(negative_scale.get("load_tick", true)) == false and is_equal_approx(float(negative_scale.get("timer_elapsed_after", -1.0)), 2.0)

	# --- Live tick: two payload-unloaders placed live; the
	# tick driver is called directly (as the N2163/N2209/
	# N2232/N2279/N2293 proofs do), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. Each holds an arrived payload (pay_vector
	# (0, 0), moved_in) with 5 copper and no liquids / no
	# battery, so the advance's only live branch is the item
	# unload (PayloadUnloader.java:68-80). Unloader A (cell
	# (28, 20)) has its clock at 1.0, so one 1.0-tick step
	# fires the timer (1 + 1 = 2 >= 2/1.0) and the computed
	# load_tick reaches the advance: all 5 copper unload
	# (itemsLoaded 8 per tick, PayloadLoader.java:23), the
	# clock resets to 0.0, and efficiency folds to 1.0.
	# Unloader B (cell (20, 10)) has its clock at 0.0, so
	# one step does not fire (0 + 1 = 1 < 2): nothing
	# unloads, the clock reads 1.0, and efficiency still
	# folds to 1.0 (the gate is the timer, not the power).
	# The dump rows run after the advance (N2293) but with
	# no neighbours nothing leaves the store, so the
	# unloaded copper stays on the frame.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_block: Dictionary = _payload_block(true, false, false, null, false)
	var empty_liquids: Dictionary = {"liquids": [0.0], "current": 0, "flow": null}

	var unloader_a_cell := Vector2i(28, 20)
	var unloader_a := Sprite2D.new()
	game.add_child(unloader_a)
	game.call("record_placed_block", unloader_a, blocks_by_id["payload-unloader"], unloader_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and seed
	# the payload + timer clock on it).
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader_a, blocks_by_id["payload-unloader"])
	var unloader_a_frame: Dictionary = unloader_a.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	# A freshly bound frame carries the timer clock at its
	# Java Interval default (times[] init 0, Interval.java:9).
	var fresh_clock: bool = unloader_a_frame.has("timer_load_elapsed") and is_equal_approx(float(unloader_a_frame["timer_load_elapsed"]), 0.0)
	unloader_a_frame["payload"] = _payload(live_block, {"copper": 5}, empty_liquids, 0.0)
	unloader_a_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	unloader_a_frame["timer_load_elapsed"] = 1.0
	unloader_a_frame["power_status"] = 1.0

	var unloader_b_cell := Vector2i(20, 10)
	var unloader_b := Sprite2D.new()
	game.add_child(unloader_b)
	game.call("record_placed_block", unloader_b, blocks_by_id["payload-unloader"], unloader_b_cell)
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader_b, blocks_by_id["payload-unloader"])
	var unloader_b_frame: Dictionary = unloader_b.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	unloader_b_frame["payload"] = _payload(live_block, {"copper": 5}, empty_liquids, 0.0)
	unloader_b_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	unloader_b_frame["timer_load_elapsed"] = 0.0
	unloader_b_frame["power_status"] = 1.0

	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_a_frame = unloader_a.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	unloader_b_frame = unloader_b.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var live_a_items: Dictionary = unloader_a_frame.get("items", {})
	var live_b_items: Dictionary = unloader_b_frame.get("items", {})
	proof["live_tick_passes_load_tick_on_fire"] = fresh_clock and is_equal_approx(float(unloader_a_frame.get("efficiency", -1.0)), 1.0) and bool(unloader_a_frame.get("moved_in", false)) and int(unloader_a_frame.get("items_unloaded", -1)) == 5 and int(live_a_items.get("copper", -1)) == 5 and is_equal_approx(float(unloader_a_frame.get("timer_load_elapsed", -1.0)), 0.0) and is_equal_approx(float(unloader_b_frame.get("efficiency", -1.0)), 1.0) and bool(unloader_b_frame.get("moved_in", false)) and int(unloader_b_frame.get("items_unloaded", -1)) == 0 and int(live_b_items.get("copper", 0)) == 0 and is_equal_approx(float(unloader_b_frame.get("timer_load_elapsed", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderLoadTimerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
