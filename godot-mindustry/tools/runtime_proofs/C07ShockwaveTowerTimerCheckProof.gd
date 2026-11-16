extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Pure timer-check (N2318): the frame-local
	# Interval-equivalent of TimerComp.timer (TimerComp.
	# java:10-13, `if(Float.isInfinite(time)) return false;`
	# / `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:20-26;
	# check compares Time.time - times[id] >= time, arc
	# Interval.java:28-30; Time.time counts TICKS, arc
	# Time.java:69-80). The Java call is
	# `if(potentialEfficiency > 0 && (reloadCounter +=
	# edelta()) >= reload && timer(timerCheck, checkInterval)){`
	# (ShockwaveTower.java:73) with `public int timerCheck =
	# timers ++;` (:23) and `public float checkInterval = 8f;`
	# (:31): elapsed += source_delta unconditionally
	# (source_delta is the UNSCALED Time.delta in ticks, so
	# the frame clock mirrors the global Time.time);
	# check_ready = elapsed >= threshold (the LITERAL
	# duration -- Java passes checkInterval with NO timeScale
	# division, the N2290 lesson); a non-positive time_scale
	# is a defensive guard (check_ready false, threshold INF
	# -- the clock still accumulates); timer_elapsed_after
	# RESETS to 0.0 on fire (a reset, not a subtraction like
	# the Fracker accumulator). The timer ONLY supplies
	# check_ready -- the fire gate still needs
	# potentialEfficiency > 0 and counter >= reload (the
	# N2247 advance gates on all three), so a timer fire
	# alone never fires the wave. Java passes a LITERAL 8 --
	# no timeScale division, unlike the MendProjector /
	# WallCrafter / ImpactReactor timers -- so the timer
	# fires every 8 ticks at EVERY time_scale; the
	# time_scale 2.0 case below pins the JAVA behavior
	# (threshold 8, not 4), and the 3 + 1 overdrive case
	# pins that it does NOT fire early.
	var timer := func(elapsed: float, source_delta: float, time_scale: float, duration: float) -> Dictionary:
		return shockwave_tower_build_state.source_shockwave_tower_timer_check_state(elapsed, source_delta, time_scale, duration)
	var duration: float = shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_CHECK_INTERVAL

	# Fire at eight ticks: 7 + 1 hits the threshold; a
	# single 8-tick delta fires at once; at time_scale 2.0
	# the threshold is still the literal 8, so 7 + 1 fires
	# (and 3 + 1 does NOT -- see the no-fire cases below).
	# The threshold output is the literal duration at a
	# positive time_scale.
	var fire_at_eight: Dictionary = timer.call(7.0, 1.0, 1.0, duration)
	var fire_full_delta: Dictionary = timer.call(0.0, 8.0, 1.0, duration)
	var fire_overdrive: Dictionary = timer.call(7.0, 1.0, 2.0, duration)
	proof["timer_fires_at_eight_ticks"] = is_equal_approx(duration, 8.0) and bool(fire_at_eight.get("check_ready", false)) and is_equal_approx(float(fire_at_eight.get("timer_elapsed_after", -1.0)), 0.0) and is_equal_approx(float(fire_at_eight.get("threshold", -1.0)), 8.0) and bool(fire_full_delta.get("check_ready", false)) and is_equal_approx(float(fire_full_delta.get("timer_elapsed_after", -1.0)), 0.0) and bool(fire_overdrive.get("check_ready", false))

	# No fire below the threshold: 6 + 1 = 7 keeps
	# accumulating; 0 + 1 = 1; at time_scale 0.5 the
	# threshold is still the literal 8, so 0 + 1 does not
	# fire either; and at time_scale 2.0 (overdrive) 3 + 1
	# = 4 does NOT fire -- a checkInterval / time_scale
	# deviation would fire here (threshold 4), the literal-8
	# threshold does not.
	var below_one: Dictionary = timer.call(6.0, 1.0, 1.0, duration)
	var below_two: Dictionary = timer.call(0.0, 1.0, 1.0, duration)
	var below_slowed: Dictionary = timer.call(0.0, 1.0, 0.5, duration)
	var below_overdrive: Dictionary = timer.call(3.0, 1.0, 2.0, duration)
	proof["timer_no_fire_below_threshold"] = bool(below_one.get("check_ready", true)) == false and is_equal_approx(float(below_one.get("timer_elapsed_after", -1.0)), 7.0) and bool(below_two.get("check_ready", true)) == false and is_equal_approx(float(below_two.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_slowed.get("check_ready", true)) == false and is_equal_approx(float(below_slowed.get("timer_elapsed_after", -1.0)), 1.0) and bool(below_overdrive.get("check_ready", true)) == false and is_equal_approx(float(below_overdrive.get("timer_elapsed_after", -1.0)), 4.0)

	# No fire on a non-positive time_scale (a defensive port
	# guard -- Java timeScale is always positive in practice,
	# BuildingComp.java:98/461-478/2265-2266, so the guard is
	# unreachable in Java-exact play): the clock still
	# accumulates -- 7 + 1 = 8 -- it just never fires and
	# never resets, and the threshold reads INF.
	var zero_scale: Dictionary = timer.call(7.0, 1.0, 0.0, duration)
	var negative_scale: Dictionary = timer.call(7.0, 1.0, -1.0, duration)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("check_ready", true)) == false and is_equal_approx(float(zero_scale.get("timer_elapsed_after", -1.0)), 8.0) and is_inf(float(zero_scale.get("threshold", 0.0))) and bool(negative_scale.get("check_ready", true)) == false and is_equal_approx(float(negative_scale.get("timer_elapsed_after", -1.0)), 8.0) and is_inf(float(negative_scale.get("threshold", 0.0)))

	# Elapsed resets on fire (pure half; the live half is
	# checked after the tick below): an already-past clock
	# (25 + 1) fires and resets to 0.0.
	var past_threshold: Dictionary = timer.call(25.0, 1.0, 1.0, duration)
	var reset_pure: bool = bool(past_threshold.get("check_ready", false)) and is_equal_approx(float(past_threshold.get("timer_elapsed_after", -1.0)), 0.0)

	# --- Timer fire alone does not fire the wave (pure
	# half): the timer fires (7 + 1 = 8) and its check_ready
	# reaches the N2247 advance, but the counter is only 40
	# (< reload 80), so the gate fails: no fire, the counter
	# is untouched, heat only decays.
	var fire_check: Dictionary = timer.call(7.0, 1.0, 1.0, duration)
	var uncharged: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state({"team_id": 1, "potential_efficiency": 1.0, "reload_counter": 40.0, "heat": 0.5}, 1.0, 80.0, 160.0, 20.0, 1.0, [{"team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}], bool(fire_check.get("check_ready", false)))
	var fire_alone_pure: bool = bool(fire_check.get("check_ready", false)) and bool(uncharged.get("fired", true)) == false and is_equal_approx(float(uncharged.get("reload_counter", -1.0)), 40.0) and is_equal_approx(float(uncharged.get("heat", -1.0)), 0.4875)

	# --- Live tick: two shockwave-towers placed live; the
	# tick driver is called directly (as the N2247 / N2280
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Both
	# towers seed counter 79.0 (one charge short of reload
	# 80, so the N2187 shouldConsume gate stays open and the
	# charge lands at 80.0), heat 0.5 and a stale target in
	# frame["targets"]. Tower A (cell (28, 21)) has its
	# clock at 7.0, so one 1.0-tick step fires the timer
	# (7 + 1 = 8): check_ready reaches the advance, the gate
	# passes (potentialEfficiency 1.0, counter 80 >= 80),
	# targets.clear() runs -- the stale target is gone --
	# but with no live bullet candidates nothing fires and
	# the counter is NOT reset (the `if(targets.size > 0){`
	# guard, ShockwaveTower.java:81); the clock resets to
	# 0.0. Tower B (cell (20, 10)) has its clock at 0.0, so
	# one step does not fire: the gate fails, the stale
	# target is PRESERVED (targets.clear() runs INSIDE the
	# gate), and the clock reads 1.0. Both towers are seeded
	# with 1.0 cyanogen on their sprite liquids meta before
	# the tick (the N2331 pattern, N2341 fix): the first pass
	# folds the required cyanogen row since N2331
	# (ConsumeLiquids 1.5f / 60f, Blocks.java:2041), and
	# PortGame never binds that store for a shockwave tower
	# (the catalog carries no consumeLiquids property), so
	# the proof initializes it explicitly and the driver
	# syncs it into the frame each tick. One tick at eff 1.0
	# removes 0.025 * 1.0 = 0.025 cyanogen per tower, so the
	# 1.0 seed is a 40x margin and the row stays capped at
	# 1.0 (it needs >= 0.025 at the first pass) -- the
	# counter charges by the full edelta 1.0.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cyanogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("cyanogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var stale_target: Dictionary = {"team": 2, "hittable": true, "damage": 500.0, "x": 0.0, "y": 0.0}

	var tower_a_cell := Vector2i(28, 21)
	var tower_a := Sprite2D.new()
	game.add_child(tower_a)
	game.call("record_placed_block", tower_a, blocks_by_id["shockwave-tower"], tower_a_cell)
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(tower_a, blocks_by_id["shockwave-tower"])
	var tower_a_frame: Dictionary = tower_a.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	# Seed cyanogen 1.0 on the sprite liquids meta (the
	# N2331 pattern, N2341 fix): the store is initialized
	# explicitly first -- PortGame never binds it for a
	# shockwave tower -- and the driver syncs this same
	# reference into the frame each tick, so the live liquid
	# row folds 1.0 and the counter charges by the full
	# edelta.
	placed_block_state.source_initialize_building_liquids_state(tower_a, true, catalog)
	var tower_a_liquids: Dictionary = tower_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(tower_a_liquids, cyanogen_id, 1.0)
	tower_a_frame["timer_check_elapsed"] = 7.0
	tower_a_frame["reload_counter"] = 79.0
	tower_a_frame["heat"] = 0.5
	tower_a_frame["targets"] = [stale_target.duplicate(true)]

	var tower_b_cell := Vector2i(20, 10)
	var tower_b := Sprite2D.new()
	game.add_child(tower_b)
	game.call("record_placed_block", tower_b, blocks_by_id["shockwave-tower"], tower_b_cell)
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(tower_b, blocks_by_id["shockwave-tower"])
	var tower_b_frame: Dictionary = tower_b.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	# Seed cyanogen 1.0 on tower B's sprite liquids meta
	# too (same N2341 fix -- each tower has its own store).
	placed_block_state.source_initialize_building_liquids_state(tower_b, true, catalog)
	var tower_b_liquids: Dictionary = tower_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(tower_b_liquids, cyanogen_id, 1.0)
	tower_b_frame["timer_check_elapsed"] = 0.0
	tower_b_frame["reload_counter"] = 79.0
	tower_b_frame["heat"] = 0.5
	tower_b_frame["targets"] = [stale_target.duplicate(true)]

	tower_a_frame["power_status"] = 1.0
	tower_b_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	tower_a_frame = tower_a.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	tower_b_frame = tower_b.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var live_a_targets: Array = tower_a_frame.get("targets", [{}])
	var live_b_targets: Array = tower_b_frame.get("targets", [])
	proof["live_tick_passes_check_ready_on_fire"] = live_a_targets.is_empty() and is_equal_approx(float(tower_a_frame.get("timer_check_elapsed", -1.0)), 0.0) and live_b_targets.size() == 1 and is_equal_approx(float(live_b_targets[0].get("x", -1.0)), 0.0) and is_equal_approx(float(tower_b_frame.get("timer_check_elapsed", -1.0)), 1.0)
	proof["timer_resets_elapsed_on_fire"] = reset_pure and is_equal_approx(float(tower_a_frame.get("timer_check_elapsed", -1.0)), 0.0) and is_equal_approx(float(tower_b_frame.get("timer_check_elapsed", -1.0)), 1.0)
	proof["timer_fire_alone_does_not_fire_wave"] = fire_alone_pure and is_equal_approx(float(tower_a_frame.get("reload_counter", -1.0)), 80.0) and is_equal_approx(float(tower_a_frame.get("heat", -1.0)), 0.4875) and is_equal_approx(float(tower_b_frame.get("reload_counter", -1.0)), 80.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerTimerCheckProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
