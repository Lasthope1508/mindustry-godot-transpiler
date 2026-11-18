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

	# --- Pure updateTile advance (N2274): RadarBuild.updateTile
	# (Radar.java:60, `public void updateTile(){`) lerps the
	# smoothed efficiency (Radar.java:61, `smoothEfficiency =
	# Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);`),
	# force-updates the fog when the live radius moved by 0.5
	# or more (Radar.java:63, `if(Math.abs(fogRadius() -
	# lastRadius) >= 0.5f){` with `Vars.fogControl.forceUpdate
	# (team, this);`, Radar.java:64, and `lastRadius =
	# fogRadius();`, Radar.java:65), advances discovery
	# (Radar.java:68, `progress += edelta() / discoveryTime;`
	# with `progress = Mathf.clamp(progress);`, Radar.java:69)
	# and tracks the efficiency-weighted ticks (Radar.java:71,
	# `totalProgress += efficiency * edelta();`). edelta() is
	# efficiency * delta (BuildingComp.java:1927-1928, `public
	# float edelta(){` with `return efficiency * delta();`, and
	# `public float delta(){` with `return Time.delta *
	# timeScale;`, BuildingComp.java:1922-1923 -- timeScale is 1
	# by default and the port passes the raw tick seconds, the
	# N2190 driver convention). The fog radius read is
	# fogRadius() (Radar.java:55, `public float fogRadius(){`
	# with `return fogRadius * progress * smoothEfficiency;`,
	# Radar.java:56): the def fogRadius is 34 (Blocks.java:1991,
	# `fogRadius = 34;`), overriding the class default 10
	# (Radar.java:33, `fogRadius = 10;`), and the discovery time
	# is 600f (Radar.java:18, `public float discoveryTime = 60f
	# * 10f;`). The proof calls the pure function
	# source_radar_update_tile_state(frame, delta,
	# discovery_time, fog_radius) directly with synthetic
	# frames. The actual FogControl call (`public void
	# forceUpdate(Team team, Building build){`,
	# FogControl.java:177) waits for its own fog slice; the
	# `force_update` flag is the observable signal that slice
	# will consume.

	# Smooth efficiency lerps toward the folded efficiency:
	# smooth 0.0 with efficiency 1.0, delta 1.0 lerps to 0.05
	# (lerpDelta 0.05f, SourceMathState.source_lerp_delta).
	var lerped: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 0.0, "efficiency": 1.0, "progress": 0.0, "last_radius": 0.0, "total_progress": 0.0}, 1.0, 600.0, 34.0)
	proof["update_tile_smooth_efficiency_lerps_toward_efficiency"] = is_equal_approx(float(lerped.get("smooth_efficiency", -1.0)), 0.05)

	# Force update fires when the radius jumps: progress 0.5
	# with smooth 1.0 gives fog radius 34 * 0.5 * 1.0 = 17.0,
	# which moved 17.0 from last_radius 0.0 -- force_update
	# true and last_radius becomes 17.0.
	var jumped: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "efficiency": 1.0, "progress": 0.5, "last_radius": 0.0, "total_progress": 0.0}, 1.0, 600.0, 34.0)
	proof["update_tile_force_update_when_radius_jumps"] = is_equal_approx(float(jumped.get("fog_radius", -1.0)), 17.0) and bool(jumped.get("force_update", false)) == true and is_equal_approx(float(jumped.get("last_radius", -1.0)), 17.0)

	# No force update when the radius is stable: progress 0.5
	# with smooth 1.0 gives fog radius 17.0, which equals
	# last_radius 17.0 -- force_update false and last_radius
	# stays 17.0.
	var stable: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "efficiency": 1.0, "progress": 0.5, "last_radius": 17.0, "total_progress": 0.0}, 1.0, 600.0, 34.0)
	proof["update_tile_no_force_update_when_radius_stable"] = bool(stable.get("force_update", true)) == false and is_equal_approx(float(stable.get("last_radius", -1.0)), 17.0)

	# Progress advances by edelta over the discovery time:
	# progress 0.0 with efficiency 1.0, delta 60.0 advances
	# by 60 / 600 = 0.1, and total_progress advances by
	# efficiency * edelta = 60.0.
	var advanced: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "efficiency": 1.0, "progress": 0.0, "last_radius": 0.0, "total_progress": 0.0}, 60.0, 600.0, 34.0)
	proof["update_tile_progress_advances_by_edelta"] = is_equal_approx(float(advanced.get("progress", -1.0)), 0.1) and is_equal_approx(float(advanced.get("total_progress", -1.0)), 60.0)

	# No efficiency means no advance: progress 0.25 with
	# efficiency 0.0 stays 0.25 and total_progress stays 0.0.
	# The smooth efficiency still lerps toward 0.0 (1.0 ->
	# 0.95), so the fog radius is 34 * 0.25 * 0.95 = 8.075,
	# which moved only 0.075 from last_radius 8.0 -- no
	# force update, and last_radius stays 8.0. This pins the
	# Java order: the check reads the NEW smooth efficiency,
	# not the old one (with the old smooth 1.0 the radius
	# would be 8.5 and the move 0.5 would force an update).
	var frozen: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "efficiency": 0.0, "progress": 0.25, "last_radius": 8.0, "total_progress": 0.0}, 1.0, 600.0, 34.0)
	proof["update_tile_no_advance_without_efficiency"] = is_equal_approx(float(frozen.get("progress", -1.0)), 0.25) and is_equal_approx(float(frozen.get("total_progress", -1.0)), 0.0) and bool(frozen.get("force_update", true)) == false and is_equal_approx(float(frozen.get("last_radius", -1.0)), 8.0)

	# Progress clamps at one: progress 0.9999 with efficiency
	# 1.0, delta 60.0 would reach 1.0999 without the clamp --
	# Mathf.clamp one-arg holds it at 1.0, while
	# total_progress still advances to 60.0.
	var clamped: Dictionary = radar_build_state.source_radar_update_tile_state({"smooth_efficiency": 1.0, "efficiency": 1.0, "progress": 0.9999, "last_radius": 0.0, "total_progress": 0.0}, 60.0, 600.0, 34.0)
	proof["update_tile_progress_clamps_at_one"] = is_equal_approx(float(clamped.get("progress", -1.0)), 1.0) and is_equal_approx(float(clamped.get("total_progress", -1.0)), 60.0)

	# Absent frame keys start at the Java defaults: an empty
	# frame reads smooth_efficiency 1.0, progress 0.0,
	# last_radius 0.0, total_progress 0.0 and efficiency 0.0
	# -- so with delta 1.0 the smooth efficiency lerps
	# toward 0.0 (1.0 -> 0.95) while progress and
	# total_progress stay 0.0 and last_radius stays 0.0.
	var absent: Dictionary = radar_build_state.source_radar_update_tile_state({}, 1.0, 600.0, 34.0)
	proof["update_tile_absent_frame_starts_at_java_defaults"] = is_equal_approx(float(absent.get("progress", -1.0)), 0.0) and is_equal_approx(float(absent.get("total_progress", -1.0)), 0.0) and is_equal_approx(float(absent.get("last_radius", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
