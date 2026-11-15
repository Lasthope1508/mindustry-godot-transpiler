extends Node

const main_scene := preload("res://scenes/Main.tscn")
const radar_build_state := preload("res://src/game/SourceRadarBuildState.gd")
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

	# --- Pure updateTile advance (N2190): RadarBuild.updateTile()
	# (Radar.java:60-72), in Java order -- the smooth-efficiency
	# lerp FIRST (Radar.java:61, `smoothEfficiency =
	# Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`),
	# then the fog-radius change check against the NEW smooth
	# efficiency and the CURRENT progress (Radar.java:63-66),
	# then the progress advance + clamp (Radar.java:68-69,
	# `progress += edelta() / discoveryTime;` / `progress =
	# Mathf.clamp(progress);`), then the total-progress advance
	# (Radar.java:71, `totalProgress += efficiency * edelta();`).
	# The fogControl.forceUpdate call (Radar.java:64,
	# `Vars.fogControl.forceUpdate(team, this);`) is NOT made
	# here: the fog system has no port-side control yet, so the
	# advance tracks the condition + the lastRadius write, and
	# the call waits for its own fog slice. One tick is
	# source_delta 1.0 (60fps ticks, arc Time.java:26); the def
	# values are fogRadius 34 (Blocks.java:1991) and
	# discoveryTime 60f * 10f = 600f (Radar.java:18).
	var lerp_step: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "progress": 0.0, "total_progress": 0.0, "last_radius": 0.0}, 0.5, 0.5, 1.0, 34.0, 600.0)
	proof["smooth_efficiency_lerps_to_efficiency"] = is_equal_approx(float(lerp_step.get("advance", {}).get("smooth_efficiency", -1.0)), 0.975)

	var progress_step: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "progress": 0.0, "total_progress": 0.0, "last_radius": 0.0}, 1.0, 1.0, 1.0, 34.0, 600.0)
	proof["progress_advances_edelta_over_discovery"] = is_equal_approx(float(progress_step.get("advance", {}).get("progress", -1.0)), 1.0 / 600.0)

	var clamp_step: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "progress": 0.9999, "total_progress": 0.0, "last_radius": 0.0}, 1.0, 1.0, 1.0, 34.0, 600.0)
	proof["progress_clamps_at_one"] = is_equal_approx(float(clamp_step.get("advance", {}).get("progress", -1.0)), 1.0)

	var total_step: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "progress": 0.0, "total_progress": 2.0, "last_radius": 0.0}, 0.5, 0.5, 1.0, 34.0, 600.0)
	proof["total_progress_accumulates"] = is_equal_approx(float(total_step.get("advance", {}).get("total_progress", -1.0)), 2.25)

	# fogRadius() = fogRadius * progress * smoothEfficiency
	# (Radar.java:56): at full progress + full smooth efficiency
	# the radius is 34, so lastRadius jumps 0 -> 34 and the
	# force-update condition fires; at half progress with
	# lastRadius already 17 the radius is unchanged, so the
	# condition stays false and lastRadius is untouched.
	var radius_update: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "progress": 1.0, "total_progress": 0.0, "last_radius": 0.0}, 1.0, 1.0, 1.0, 34.0, 600.0)
	var radius_steady: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "progress": 0.5, "total_progress": 0.0, "last_radius": 17.0}, 1.0, 1.0, 1.0, 34.0, 600.0)
	proof["last_radius_updates_on_fog_change"] = bool(radius_update.get("force_update_needed", false)) and is_equal_approx(float(radius_update.get("advance", {}).get("last_radius", -1.0)), 34.0) and bool(radius_steady.get("force_update_needed", true)) == false and is_equal_approx(float(radius_steady.get("advance", {}).get("last_radius", -1.0)), 17.0)

	# --- Live tick: the radar is a Radar build with a power
	# consumer (consumePower 0.6f), placed live; the tick driver
	# is called directly (as the N2173 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. Half power: efficiency folds the
	# power min 0.5 (the N2173 power row, preserved), and the
	# advance follows it for one 1/60s tick (source_delta 1.0,
	# edelta 0.5): smoothEfficiency 1.0 -> 0.975, progress 0 ->
	# 0.5/600, totalProgress 0 -> 0.25, lastRadius stays 0
	# (fogRadius() is 0 at progress 0, so no force update).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var radar_cell := Vector2i(28, 21)
	var radar := Sprite2D.new()
	game.add_child(radar)
	game.call("record_placed_block", radar, blocks_by_id["radar"], radar_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	radar_build_state.source_radar_bind_frame_state(radar, blocks_by_id["radar"])
	var radar_frame: Dictionary = radar.get_meta(radar_build_state.SOURCE_RADAR_BUILDING_META_KEY, {})

	radar_frame["power_status"] = 0.5
	radar_build_state.source_radar_tick_buildings_state(game, 1.0 / 60.0)
	radar_frame = radar.get_meta(radar_build_state.SOURCE_RADAR_BUILDING_META_KEY, {})
	proof["live_tick_advances_and_keeps_power_row"] = is_equal_approx(float(radar_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(radar_frame.get("smooth_efficiency", -1.0)), 0.975) and is_equal_approx(float(radar_frame.get("progress", -1.0)), 0.5 / 600.0) and is_equal_approx(float(radar_frame.get("total_progress", -1.0)), 0.25) and is_equal_approx(float(radar_frame.get("last_radius", -1.0)), 0.0) and bool(radar_frame.get("force_update_needed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
