extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- Pure updateTile advance (N2256): BurstDrillBuild.updateTile
	# (BurstDrill.java:76, `public void updateTile(){`) returns
	# early with no dominant item (BurstDrill.java:77,
	# `if(dominantItem == null){`), decays invertTime
	# (BurstDrill.java:81, `if(invertTime > 0f) invertTime -=
	# delta() / invertedTime;`), dumps on the dump timer
	# (BurstDrill.java:83, `if(timer(timerDump, dumpTime /
	# timeScale)){` with `dump(items.has(dominantItem) ?
	# dominantItem : null);`, BurstDrill.java:84), reads the
	# effective drill time (BurstDrill.java:87, `float drillTime
	# = getDrillTime(dominantItem);` with `getDrillTime`
	# dividing by the per-item multiplier, BurstDrill.java:53-54),
	# lerps the smooth progress (BurstDrill.java:89,
	# `smoothProgress = Mathf.lerpDelta(smoothProgress, progress
	# / (drillTime - 20f), 0.1f);`), approaches warmup and
	# advances timeDrilled / lastDrillSpeed / progress when
	# producing (BurstDrill.java:91-99), decays warmup and zeroes
	# the drill speed when not producing (BurstDrill.java:101-102,
	# `warmup = Mathf.approachDelta(warmup, 0f, 0.01f);` /
	# `lastDrillSpeed = 0f;`) and returns, and offloads, inverts
	# and wraps progress when the progress crosses the drill time
	# (BurstDrill.java:106-112). delta() is Time.delta *
	# timeScale (BuildingComp.java:1922-1923, `public float
	# delta(){` with `return Time.delta * timeScale;` --
	# timeScale is 1 by default and the port passes the raw tick
	# seconds, the N2190 driver convention). The speed curve is
	# Interp.pow2In (`public Interp speedCurve = Interp.pow2In;`,
	# BurstDrill.java:19, `PowIn pow2In = new PowIn(2);`,
	# Interp.java:29, with `return (float)Math.pow(a, power);`,
	# Interp.java:116 -- pow2In(a) is a squared). The proof calls
	# the pure function
	# source_burst_drill_update_tile_state(frame, delta,
	# drill_time_base, drill_multiplier, inverted_time,
	# liquid_boost_intensity, item_capacity, dump_interval)
	# directly with synthetic frames. There are no dump-call,
	# offload-application or completion-effect keys: the dump
	# call, the offload application and the wasVisible-gated shake
	# / sound / drillEffect wait for their own slices, and the
	# dump_due / offloaded_count / invert_fired flags are the
	# observable signals those slices will consume.

	# Smooth progress lerps and warmup approaches: impact-drill
	# (drillTime 720f, Blocks.java:3072, `drillTime = 60f * 12f;`)
	# on beryllium (multiplier 2f, Blocks.java:3083,
	# `drillMultipliers.put(Items.beryllium, 2f);`) gives an
	# effective drill time of 360.0; progress 100.0 with delta
	# 1.0 lerps the smooth progress toward 100 / (360 - 20) =
	# 0.2941176 by 0.1 -> 0.0294118, approaches warmup toward
	# 100 / 360 = 0.2777778 by 0.01 -> 0.01, folds the speed
	# lerpf(1.0, 1.75, 1.0) * 1.0 = 1.75, advances timeDrilled
	# by (100 / 360)^2 * 1.75 = 0.13503086, records the drill
	# speed 1 / 360 * 1.75 * 2 = 0.00972222 and advances
	# progress by 1.0 * 1.75 -> 101.75, with no offload (101.75
	# < 360) and no invert.
	var lerped: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 2, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 100.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 1.0, "optional_efficiency": 1.0, "items_total": 0.0, "dump_timer": 0.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["update_tile_smooth_progress_lerps_and_warmup_approaches"] = is_equal_approx(float(lerped.get("smooth_progress", -1.0)), 0.0294118) and is_equal_approx(float(lerped.get("warmup", -1.0)), 0.01) and is_equal_approx(float(lerped.get("time_drilled", -1.0)), 0.13503086) and is_equal_approx(float(lerped.get("last_drill_speed", -1.0)), 0.00972222) and is_equal_approx(float(lerped.get("progress", -1.0)), 101.75) and bool(lerped.get("invert_fired", true)) == false

	# Offload inverts and wraps progress: progress 359.0 with
	# dominant_items 3, efficiency 1.0 and no liquid boost
	# (optional_efficiency 0.0, so the speed is
	# lerpf(1.0, 1.75, 0.0) * 1.0 = 1.0) advances by 1.0 to
	# 360.0, which reaches the effective drill time 360.0 --
	# so 3 items offload, invertTime becomes 1.0, invert_fired
	# is true and progress wraps to fposmod(360.0, 360.0) = 0.0.
	var crossed: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 3, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 359.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 1.0, "optional_efficiency": 0.0, "items_total": 0.0, "dump_timer": 0.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["update_tile_offload_inverts_and_wraps_progress"] = int(crossed.get("offloaded_count", -1)) == 3 and is_equal_approx(float(crossed.get("invert_time", -1.0)), 1.0) and bool(crossed.get("invert_fired", false)) == true and is_equal_approx(float(crossed.get("progress", -1.0)), 0.0)

	# Drill time divides by the multiplier: the same base 720.0
	# gives 720.0 with multiplier 1.0 and 360.0 with multiplier
	# 2.0 (getDrillTime, BurstDrill.java:53-54, `return
	# drillTime / drillMultipliers.get(item, 1f);`).
	var unboosted: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 1, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 0.0, "optional_efficiency": 0.0, "items_total": 0.0, "dump_timer": 0.0}, 1.0, 720.0, 1.0, 200.0, 1.75, 40.0, 5.0)
	var boosted: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 1, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 0.0, "optional_efficiency": 0.0, "items_total": 0.0, "dump_timer": 0.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["update_tile_drill_time_divides_by_multiplier"] = is_equal_approx(float(unboosted.get("drill_time", -1.0)), 720.0) and is_equal_approx(float(boosted.get("drill_time", -1.0)), 360.0)

	# No efficiency means no advance: progress 100.0 with
	# efficiency 0.0 stays 100.0, timeDrilled stays 10.0, the
	# drill speed zeroes and warmup decays from 0.5 by 0.01 to
	# 0.49 -- while the smooth progress still lerps (Java line
	# 89 runs before the producing check, BurstDrill.java:91).
	var frozen: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 2, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 100.0, "warmup": 0.5, "time_drilled": 10.0, "last_drill_speed": 5.0, "efficiency": 0.0, "optional_efficiency": 0.0, "items_total": 0.0, "dump_timer": 0.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["update_tile_no_advance_without_efficiency"] = is_equal_approx(float(frozen.get("progress", -1.0)), 100.0) and is_equal_approx(float(frozen.get("time_drilled", -1.0)), 10.0) and is_equal_approx(float(frozen.get("last_drill_speed", -1.0)), 0.0) and is_equal_approx(float(frozen.get("warmup", -1.0)), 0.49) and int(frozen.get("offloaded_count", -1)) == 0 and bool(frozen.get("invert_fired", true)) == false

	# Dump timer fires at the interval: dump_timer 4.0 with
	# delta 1.0 and dump_interval 5.0 reaches 5.0, so the timer
	# wraps to 0.0 and dump_due is true; dump_timer 0.0 only
	# advances to 1.0 with dump_due false.
	var firing: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 1, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 0.0, "optional_efficiency": 0.0, "items_total": 0.0, "dump_timer": 4.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	var idle: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 1, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 0.0, "optional_efficiency": 0.0, "items_total": 0.0, "dump_timer": 0.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["update_tile_dump_timer_fires_at_interval"] = bool(firing.get("dump_due", false)) == true and is_equal_approx(float(firing.get("dump_timer", -1.0)), 0.0) and bool(idle.get("dump_due", true)) == false and is_equal_approx(float(idle.get("dump_timer", -1.0)), 1.0)

	# No dominant item returns unchanged: a frame with progress
	# 50.0, warmup 0.3, timeDrilled 7.0, invertTime 0.5 and
	# dump_timer 2.0 but no dominant_item comes back untouched
	# -- the early return (BurstDrill.java:77-79) runs before
	# the invert decay, the dump timer and the smooth-progress
	# lerp, so even the dump timer stays 2.0; only the effective
	# drill time (720.0 / 2.0 = 360.0) is derived from the params.
	var absent: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_items": 2, "invert_time": 0.5, "smooth_progress": 0.0, "progress": 50.0, "warmup": 0.3, "time_drilled": 7.0, "last_drill_speed": 1.0, "efficiency": 1.0, "optional_efficiency": 1.0, "items_total": 0.0, "dump_timer": 2.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["update_tile_no_dominant_item_returns_unchanged"] = is_equal_approx(float(absent.get("progress", -1.0)), 50.0) and is_equal_approx(float(absent.get("warmup", -1.0)), 0.3) and is_equal_approx(float(absent.get("time_drilled", -1.0)), 7.0) and is_equal_approx(float(absent.get("invert_time", -1.0)), 0.5) and is_equal_approx(float(absent.get("dump_timer", -1.0)), 2.0) and is_equal_approx(float(absent.get("drill_time", -1.0)), 360.0) and bool(absent.get("dump_due", true)) == false and int(absent.get("offloaded_count", -1)) == 0 and bool(absent.get("invert_fired", true)) == false

	# No advance when full: items_total 40.0 with itemCapacity
	# 40.0 and dominant_items 2 fails the producing gate
	# (40.0 <= 40.0 - 2.0 is false), so progress stays 100.0,
	# timeDrilled stays 10.0, the drill speed zeroes and warmup
	# decays from 0.5 to 0.49 -- the else branch returns before
	# the offload gate (BurstDrill.java:101-104).
	var full: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 2, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 100.0, "warmup": 0.5, "time_drilled": 10.0, "last_drill_speed": 5.0, "efficiency": 1.0, "optional_efficiency": 1.0, "items_total": 40.0, "dump_timer": 0.0}, 1.0, 720.0, 2.0, 200.0, 1.75, 40.0, 5.0)
	proof["update_tile_no_advance_when_full"] = is_equal_approx(float(full.get("progress", -1.0)), 100.0) and is_equal_approx(float(full.get("warmup", -1.0)), 0.49) and is_equal_approx(float(full.get("last_drill_speed", -1.0)), 0.0) and is_equal_approx(float(full.get("time_drilled", -1.0)), 10.0) and int(full.get("offloaded_count", -1)) == 0 and bool(full.get("invert_fired", true)) == false

	# Eruption def uses its boost and capacity: drillTime
	# 281.25f (Blocks.java:3095, `drillTime = 281.25f;`) with
	# multiplier 1.0 gives an effective drill time of 281.25;
	# with efficiency 1.0 and optional_efficiency 1.0 the speed
	# is lerpf(1.0, 2.0, 1.0) * 1.0 = 2.0
	# (liquidBoostIntensity 2f, Blocks.java:3115,
	# `liquidBoostIntensity = 2f;`), so progress advances by
	# 1.0 * 2.0 -> 2.0 and the drill speed is 1 / 281.25 * 2.0 *
	# 1 = 0.00711111; and with items_total 60.0 against
	# itemCapacity 60 (Blocks.java:3107, `itemCapacity = 60;`)
	# the producing gate fails (60.0 <= 60.0 - 1.0 is false), so
	# progress stays 0.0.
	var eruption: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 1, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 1.0, "optional_efficiency": 1.0, "items_total": 0.0, "dump_timer": 0.0}, 1.0, 281.25, 1.0, 200.0, 2.0, 60.0, 5.0)
	var eruption_full: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_state({"dominant_item": "beryllium", "dominant_items": 1, "invert_time": 0.0, "smooth_progress": 0.0, "progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "efficiency": 1.0, "optional_efficiency": 1.0, "items_total": 60.0, "dump_timer": 0.0}, 1.0, 281.25, 1.0, 200.0, 2.0, 60.0, 5.0)
	proof["update_tile_eruption_def_uses_boost_and_capacity"] = is_equal_approx(float(eruption.get("drill_time", -1.0)), 281.25) and is_equal_approx(float(eruption.get("progress", -1.0)), 2.0) and is_equal_approx(float(eruption.get("last_drill_speed", -1.0)), 0.00711111) and is_equal_approx(float(eruption_full.get("progress", -1.0)), 0.0) and is_equal_approx(float(eruption_full.get("last_drill_speed", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
