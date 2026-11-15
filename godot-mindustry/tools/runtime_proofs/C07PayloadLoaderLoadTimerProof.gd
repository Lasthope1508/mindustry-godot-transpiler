extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_loader_build_state := preload("res://src/game/SourcePayloadLoaderBuildState.gd")
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

	# --- Pure load timer (N2319): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:69-80). The Java gate is `if(efficiency >
	# 0.01f && timer(timerLoad, loadTime / efficiency)){`
	# (PayloadLoader.java:157) with `public final int
	# timerLoad = timers++;` (:20) and `public float
	# loadTime = 2f;` (:22): elapsed += source_delta
	# unconditionally (source_delta is the UNSCALED
	# Time.delta in ticks, so the frame clock mirrors the
	# global Time.time); load_tick = (eff > 0.01) and
	# (elapsed >= loadTime / eff) -- the threshold divides
	# by EFFICIENCY, not timeScale (the N2290 lesson);
	# the Java short-circuit order means eff <= 0.01 never
	# resets (but the clock still accumulates, so a
	# recovered efficiency fires at once); a non-positive
	# time_scale is a defensive guard (never fires -- the
	# clock still accumulates); elapsed_after RESETS to
	# 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator). The gate `efficiency > 0.01
	# and load_tick` already lives in the N2231 advance
	# pure (:446); the timer pure only computes load_tick.
	var timer := func(elapsed: float, source_delta: float, time_scale: float, efficiency: float, load_time: float) -> Dictionary:
		return payload_loader_build_state.source_payload_loader_load_timer_state(elapsed, source_delta, time_scale, efficiency, load_time)
	var load_time: float = payload_loader_build_state.SOURCE_PAYLOAD_LOADER_LOAD_TIME

	# Fire at loadTime / efficiency: eff 1.0 fires at 2
	# ticks (1 + 1 hits the threshold; a single 2-tick
	# delta fires at once); eff 0.5 fires at 4 ticks
	# (3 + 1 hits the 2f/0.5 threshold). Each fire resets
	# the elapsed clock to 0.0.
	var fire_full: Dictionary = timer.call(1.0, 1.0, 1.0, 1.0, load_time)
	var fire_full_delta: Dictionary = timer.call(0.0, 2.0, 1.0, 1.0, load_time)
	var fire_half: Dictionary = timer.call(3.0, 1.0, 1.0, 0.5, load_time)
	proof["timer_fires_at_load_time_over_efficiency"] = is_equal_approx(load_time, 2.0) and bool(fire_full.get("load_tick", false)) and is_equal_approx(float(fire_full.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_full_delta.get("load_tick", false)) and is_equal_approx(float(fire_full_delta.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_half.get("load_tick", false)) and is_equal_approx(float(fire_half.get("timer_elapsed_after", -1.0)), 0.0)

	# No fire below the threshold: 0 + 1 = 1 and 1 + 0.5 =
	# 1.5 keep accumulating at eff 1.0; at eff 0.5 the
	# threshold is 4, so 2 + 1 = 3 does not fire either.
	var below_one: Dictionary = timer.call(0.0, 1.0, 1.0, 1.0, load_time)
	var below_two: Dictionary = timer.call(1.0, 0.5, 1.0, 1.0, load_time)
	var below_half: Dictionary = timer.call(2.0, 1.0, 1.0, 0.5, load_time)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("load_tick", true)) == false and is_equal_approx(float(below_one.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_two.get("load_tick", true)) == false and is_equal_approx(float(below_two.get("timer_elapsed_after", -1.0)), 1.5) and bool(below_half.get("load_tick", true)) == false and is_equal_approx(float(below_half.get("timer_elapsed_after", -1.0)), 3.0)

	# No fire when efficiency is low (the Java
	# short-circuit: eff <= 0.01 means timer() is never
	# called, so no reset -- but the clock still
	# accumulates): eff 0.01 is NOT > 0.01, so 19 + 1 =
	# 20 does not fire; eff 0.0 and eff 0.005 likewise.
	var low_boundary: Dictionary = timer.call(19.0, 1.0, 1.0, 0.01, load_time)
	var low_zero: Dictionary = timer.call(19.0, 1.0, 1.0, 0.0, load_time)
	var low_small: Dictionary = timer.call(1.0, 1.0, 1.0, 0.005, load_time)
	proof["timer_no_fire_when_efficiency_low"] = bool(low_boundary.get("load_tick", true)) == false and is_equal_approx(float(low_boundary.get("timer_elapsed_after", -1.0)), 20.0) and bool(low_zero.get("load_tick", true)) == false and is_equal_approx(float(low_zero.get("timer_elapsed_after", -1.0)), 20.0) and bool(low_small.get("load_tick", true)) == false and is_equal_approx(float(low_small.get("timer_elapsed_after", -1.0)), 2.0)

	# Fire at once when efficiency recovers: while eff is
	# 0 the clock accumulates without firing (1 + 1 = 2,
	# no fire), and the very next tick at eff 1.0 fires
	# immediately -- even with a zero delta, because the
	# accumulated 2.0 already meets the threshold. The
	# long-suppressed case likewise: 19 + 1 = 20 at eff
	# 0.005 does not fire, then 20 + 1 at eff 1.0 fires.
	var suppressed: Dictionary = timer.call(1.0, 1.0, 1.0, 0.0, load_time)
	var recovered: Dictionary = timer.call(float(suppressed.get("timer_elapsed_after", -1.0)), 0.0, 1.0, 1.0, load_time)
	var suppressed_long: Dictionary = timer.call(19.0, 1.0, 1.0, 0.005, load_time)
	var recovered_long: Dictionary = timer.call(float(suppressed_long.get("timer_elapsed_after", -1.0)), 1.0, 1.0, 1.0, load_time)
	proof["timer_fires_when_efficiency_recovers"] = bool(suppressed.get("load_tick", true)) == false and is_equal_approx(float(suppressed.get("timer_elapsed_after", -1.0)), 2.0) and bool(recovered.get("load_tick", false)) and is_equal_approx(float(recovered.get("timer_elapsed_after", -1.0)), 0.0) and bool(suppressed_long.get("load_tick", true)) == false and is_equal_approx(float(suppressed_long.get("timer_elapsed_after", -1.0)), 20.0) and bool(recovered_long.get("load_tick", false)) and is_equal_approx(float(recovered_long.get("timer_elapsed_after", -1.0)), 0.0)

	# No fire on a non-positive time_scale (a defensive port
	# guard -- Java timeScale is always positive in practice,
	# BuildingComp.java:98/461-478/2265-2266, so the guard is
	# unreachable in Java-exact play): the clock still
	# accumulates -- 19 + 1 = 20 -- it just never fires and
	# never resets.
	var zero_scale: Dictionary = timer.call(19.0, 1.0, 0.0, 1.0, load_time)
	var negative_scale: Dictionary = timer.call(19.0, 1.0, -1.0, 1.0, load_time)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("load_tick", true)) == false and is_equal_approx(float(zero_scale.get("timer_elapsed_after", -1.0)), 20.0) and bool(negative_scale.get("load_tick", true)) == false and is_equal_approx(float(negative_scale.get("timer_elapsed_after", -1.0)), 20.0)

	# --- Live tick: two payload-loaders placed live; the tick
	# driver is called directly (as the N2278/N2295 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142, and the fold itself
	# by N2162 (power_status 0.5 folds efficiency 0.5). Both
	# loaders hold the N2231 storage payload (an item
	# container, accept_item_open) already arrived at the
	# center (pay_vector (0, 0)) with 5 copper in the store.
	# Loader A (cell (28, 20)) has its clock at 1.0, so one
	# 1.0-tick step fires the timer (1 + 1 = 2 at eff 1.0)
	# and the load_tick reaches the N2231 advance: all 5
	# copper load into the payload (itemsLoaded 8 per tick)
	# and the clock resets to 0.0. Loader B (cell (20, 10))
	# has its clock at 0.0, so one step does not fire: the
	# copper stays in the store, the payload stays empty,
	# and the clock reads 1.0.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var storage_payload: Dictionary = {"block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": true, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}

	var loader_a_cell := Vector2i(28, 20)
	var loader_a := Sprite2D.new()
	game.add_child(loader_a)
	game.call("record_placed_block", loader_a, blocks_by_id["payload-loader"], loader_a_cell)
	payload_loader_build_state.source_payload_loader_bind_frame_state(loader_a, blocks_by_id["payload-loader"])
	var loader_a_frame: Dictionary = loader_a.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	loader_a_frame["timer_load_elapsed"] = 1.0
	loader_a_frame["payload"] = storage_payload.duplicate(true)
	loader_a_frame["items"] = {"copper": 5}

	var loader_b_cell := Vector2i(20, 10)
	var loader_b := Sprite2D.new()
	game.add_child(loader_b)
	game.call("record_placed_block", loader_b, blocks_by_id["payload-loader"], loader_b_cell)
	payload_loader_build_state.source_payload_loader_bind_frame_state(loader_b, blocks_by_id["payload-loader"])
	var loader_b_frame: Dictionary = loader_b.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	loader_b_frame["timer_load_elapsed"] = 0.0
	loader_b_frame["payload"] = storage_payload.duplicate(true)
	loader_b_frame["items"] = {"copper": 5}

	loader_a_frame["power_status"] = 1.0
	loader_b_frame["power_status"] = 1.0
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	loader_a_frame = loader_a.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	loader_b_frame = loader_b.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var live_a_items: Dictionary = loader_a_frame.get("items", {})
	var live_a_payload: Dictionary = loader_a_frame.get("payload", {})
	var live_a_payload_items: Dictionary = live_a_payload.get("build_items", {})
	var live_b_items: Dictionary = loader_b_frame.get("items", {})
	var live_b_payload: Dictionary = loader_b_frame.get("payload", {})
	var live_b_payload_items: Dictionary = live_b_payload.get("build_items", {})
	proof["live_tick_passes_load_tick_on_fire"] = is_equal_approx(float(loader_a_frame.get("timer_load_elapsed", -1.0)), 0.0) and int(live_a_items.get("copper", -1)) == 0 and int(live_a_payload_items.get("copper", -1)) == 5 and is_equal_approx(float(loader_b_frame.get("timer_load_elapsed", -1.0)), 1.0) and int(live_b_items.get("copper", -1)) == 5 and int(live_b_payload_items.get("copper", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderLoadTimerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
