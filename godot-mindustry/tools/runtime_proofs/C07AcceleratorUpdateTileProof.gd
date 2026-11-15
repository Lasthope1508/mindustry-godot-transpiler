extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	# --- Pure updateTile advance (N2191): AcceleratorBuild.
	# updateTile() (Accelerator.java:127-146) lerps heat toward
	# launching ? 1f : efficiency and statusLerp toward
	# power.status (Accelerator.java:131-132), advances time by
	# Time.delta * efficiency when idle and slerps it toward 0
	# when launching (Accelerator.java:134-138), lerps
	# launchHeat toward launching ? 1f : 0f
	# (Accelerator.java:140), and advances progress by
	# Time.delta * efficiency / buildDuration, clamped at 1f,
	# when efficiency >= 0 (Accelerator.java:142-145).
	# Time.delta in the port is seconds * 60
	# (game_source_delta, arc Time.java:26), so the pure checks
	# pass Time.delta ticks explicitly (1.0 = one tick, 60.0 =
	# one second). The lerpDelta/slerpDelta formulas come from
	# Arc Mathf.java: lerpDelta is lerp(from, to, clamp
	# (progress * Time.delta)) (Mathf.java:430-432) and
	# slerpDelta is slerp(from, to, clamp(progress *
	# Time.delta)) (Mathf.java:460-462), where slerp is the
	# angle lerp in degrees with wrap (Mathf.java:455-458)
	# and clamp is [0, 1] (Mathf.java:402-404).
	# buildDuration is the class field 120f
	# (Accelerator.java:52). launching defaults false; the
	# launching branch is proven pure here (with
	# launching=true in the frame), not live, because nothing
	# in the port sets the flag yet -- beginLaunch/endLaunch
	# (Accelerator.java:334-337, 392-394) wait for the launch
	# sequence slice.
	var idle_frame: Dictionary = {"heat": 0.0, "status_lerp": 0.0, "time": 0.0, "launch_heat": 0.0, "progress": 0.0, "launching": false, "efficiency": 0.5, "power_status": 0.5}
	var idle: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(idle_frame, 1.0)
	# Heat lerps toward efficiency when idle: lerp(0, 0.5,
	# 0.05) = 0.025. When launching it lerps toward 1:
	# lerp(0, 1, 0.05) = 0.05.
	var launching_frame: Dictionary = {"heat": 0.0, "status_lerp": 0.0, "time": 10.0, "launch_heat": 0.0, "progress": 0.0, "launching": true, "efficiency": 0.5, "power_status": 0.5}
	var launching: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(launching_frame, 1.0)
	proof["heat_lerps_toward_efficiency"] = is_equal_approx(float(idle.get("heat", -1.0)), 0.025) and is_equal_approx(float(launching.get("heat", -1.0)), 0.05)

	# statusLerp tracks power.status: lerp(0, 0.5, 0.05) =
	# 0.025 from cold, lerp(1, 0, 0.05) = 0.95 from hot at no
	# power.
	var dark_frame: Dictionary = {"heat": 0.0, "status_lerp": 1.0, "time": 0.0, "launch_heat": 0.0, "progress": 0.0, "launching": false, "efficiency": 0.0, "power_status": 0.0}
	var dark: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(dark_frame, 1.0)
	proof["status_lerp_tracks_power_status"] = is_equal_approx(float(idle.get("status_lerp", -1.0)), 0.025) and is_equal_approx(float(dark.get("status_lerp", -1.0)), 0.95)

	# launchHeat lerps toward 0 when idle: lerp(1, 0, 0.1) =
	# 0.9 from hot; toward 1 when launching: lerp(0, 1, 0.1)
	# = 0.1 from cold.
	var hot_frame: Dictionary = {"heat": 0.0, "status_lerp": 0.0, "time": 0.0, "launch_heat": 1.0, "progress": 0.0, "launching": false, "efficiency": 0.5, "power_status": 0.5}
	var hot: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(hot_frame, 1.0)
	proof["launch_heat_lerps_by_launching"] = is_equal_approx(float(hot.get("launch_heat", -1.0)), 0.9) and is_equal_approx(float(launching.get("launch_heat", -1.0)), 0.1)

	# Time advances by Time.delta * efficiency when idle: 0 +
	# 1.0 * 0.5 = 0.5. When launching it slerps toward 0:
	# from 10, delta = ((0 - 10 + 360 + 180) % 360) - 180 =
	# -10, so (10 + (-10) * 0.4 + 360) % 360 = 6.
	proof["time_advances_and_slerps"] = is_equal_approx(float(idle.get("time", -1.0)), 0.5) and is_equal_approx(float(launching.get("time", -1.0)), 6.0)

	# Progress advances by Time.delta * efficiency /
	# buildDuration: 0 + 60 * 0.5 / 120 = 0.25; and clamps
	# at 1: 0.999 + 60 * 1 / 120 = 1.499 -> 1.0.
	var charging_frame: Dictionary = {"heat": 0.0, "status_lerp": 0.0, "time": 0.0, "launch_heat": 0.0, "progress": 0.0, "launching": false, "efficiency": 0.5, "power_status": 0.5}
	var charging: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(charging_frame, 60.0)
	var full_frame: Dictionary = {"heat": 0.0, "status_lerp": 0.0, "time": 0.0, "launch_heat": 0.0, "progress": 0.999, "launching": false, "efficiency": 1.0, "power_status": 1.0}
	var full: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(full_frame, 60.0)
	proof["progress_advances_and_clamps"] = is_equal_approx(float(charging.get("progress", -1.0)), 0.25) and is_equal_approx(float(full.get("progress", -1.0)), 1.0)

	# --- Live tick: the accelerator is an Accelerator build
	# with a static power consumer (interplanetary-accelerator,
	# consumePower 10f, Blocks.java:6829), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/
	# N2172/N2173/N2174/N2175/N2176/N2177/N2178/N2179/N2180/N2181/
	# N2182/N2183 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The driver
	# advances the frame after the consumption fold
	# (Building.update() calls updateConsumption() then
	# updateTile(), BuildingComp.java:2274-2278), and the N2183
	# power.status fold still holds: efficiency folds the power
	# min 0.5 at half power and 0 at no power.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var accelerator_cell := Vector2i(30, 21)
	var accelerator := Sprite2D.new()
	game.add_child(accelerator)
	game.call("record_placed_block", accelerator, blocks_by_id["interplanetary-accelerator"], accelerator_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	accelerator_build_state.source_accelerator_bind_frame_state(accelerator, blocks_by_id["interplanetary-accelerator"])
	var accelerator_frame: Dictionary = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})

	# N2267: the required item row folds 0.0 on an empty
	# frame, so seed the full core-nucleus stacks before
	# ticking -- otherwise the live efficiency reads 0 and
	# the advance never runs.
	accelerator_frame["items"] = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 4000}

	# Half power: efficiency folds the power min 0.5, and the
	# frame advances one tick (seconds = 1/60, Time.delta =
	# 1.0): progress by 1.0 * 0.5 / 120, heat toward 0.5 by
	# lerpDelta 0.05, time by 1.0 * 0.5.
	accelerator_frame["power_status"] = 0.5
	accelerator_build_state.source_accelerator_tick_buildings_state(game, 1.0 / 60.0)
	accelerator_frame = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	var live_progress: float = float(accelerator_frame.get("progress", -1.0))
	var live_ok: bool = is_equal_approx(float(accelerator_frame.get("efficiency", -1.0)), 0.5)
	live_ok = live_ok and is_equal_approx(live_progress, 0.5 / 120.0)
	live_ok = live_ok and is_equal_approx(float(accelerator_frame.get("heat", -1.0)), lerpf(0.0, 0.5, clampf(0.05 * 1.0, 0.0, 1.0)))
	live_ok = live_ok and is_equal_approx(float(accelerator_frame.get("time", -1.0)), 0.5)

	# No power: efficiency 0, and progress stops advancing
	# (progress += Time.delta * 0 / buildDuration). This proves
	# the folded efficiency is 0 and the advance follows it;
	# it carries no launch / battery claim -- the launch
	# sequence and the canLaunch battery gate
	# (Accelerator.java:239-240) wait for their own slices.
	accelerator_frame["power_status"] = 0.0
	accelerator_build_state.source_accelerator_tick_buildings_state(game, 1.0 / 60.0)
	accelerator_frame = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	live_ok = live_ok and is_equal_approx(float(accelerator_frame.get("efficiency", -1.0)), 0.0)
	live_ok = live_ok and is_equal_approx(float(accelerator_frame.get("progress", -1.0)), live_progress)
	proof["live_tick_advances_and_folds_power"] = live_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
