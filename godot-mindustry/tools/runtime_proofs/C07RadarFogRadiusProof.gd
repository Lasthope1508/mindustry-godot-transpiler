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

	# --- Pure fogRadius() accessor (N2321): RadarBuild.fogRadius()
	# (Radar.java:55, `public float fogRadius(){` with `return
	# fogRadius * progress * smoothEfficiency;`, Radar.java:56)
	# is the live fog radius: the def fogRadius (34 for the
	# radar def, Blocks.java:1991, `fogRadius = 34;`,
	# overriding the class default 10, Radar.java:33,
	# `fogRadius = 10;`) scaled by the discovery progress
	# (Radar.java:49, `public float progress;`, init 0.0) and
	# the smoothed efficiency (Radar.java:51, `public float
	# smoothEfficiency = 1f;`, init 1.0). The accessor is what
	# updateTile reads for its force-update check
	# (Radar.java:63, `if(Math.abs(fogRadius() - lastRadius)
	# >= 0.5f){`) and what drawSelect draws (Radar.java:80-82,
	# `Drawf.dashCircle(x, y, fogRadius() * tilesize,
	# Pal.accent);`). The proof calls the pure function
	# source_radar_fog_radius_state(frame, fog_radius)
	# directly with synthetic frames. There are no fog-system
	# keys: the actual FogControl.forceUpdate call waits for
	# its own fog slice, and the updateTile advance (N2248)
	# and the draw / icons rows are separate slices with their
	# own proofs.

	# Zero before discovery: progress 0.0 with smooth 1.0
	# gives fog radius 34 * 0.0 * 1.0 = 0.0.
	var undiscovered: Dictionary = radar_build_state.source_radar_fog_radius_state({"progress": 0.0, "smooth_efficiency": 1.0}, 34.0)
	proof["fog_radius_zero_before_discovery"] = is_equal_approx(float(undiscovered.get("fog_radius", -1.0)), 0.0)

	# Scales with progress: progress 0.5 with smooth 1.0
	# gives fog radius 34 * 0.5 * 1.0 = 17.0.
	var half: Dictionary = radar_build_state.source_radar_fog_radius_state({"progress": 0.5, "smooth_efficiency": 1.0}, 34.0)
	proof["fog_radius_scales_with_progress"] = is_equal_approx(float(half.get("fog_radius", -1.0)), 17.0)

	# Scales with smooth efficiency: progress 1.0 with smooth
	# 0.5 gives fog radius 34 * 1.0 * 0.5 = 17.0.
	var smoothed: Dictionary = radar_build_state.source_radar_fog_radius_state({"progress": 1.0, "smooth_efficiency": 0.5}, 34.0)
	proof["fog_radius_scales_with_smooth_efficiency"] = is_equal_approx(float(smoothed.get("fog_radius", -1.0)), 17.0)

	# Full discovery: progress 1.0 with smooth 1.0 gives the
	# full def radius 34 * 1.0 * 1.0 = 34.0.
	var full: Dictionary = radar_build_state.source_radar_fog_radius_state({"progress": 1.0, "smooth_efficiency": 1.0}, 34.0)
	proof["fog_radius_full_discovery"] = is_equal_approx(float(full.get("fog_radius", -1.0)), 34.0)

	# Class-default def radius: the class default fogRadius
	# is 10 (Radar.java:33), so progress 0.5 with smooth 1.0
	# gives 10 * 0.5 * 1.0 = 5.0.
	var class_default: Dictionary = radar_build_state.source_radar_fog_radius_state({"progress": 0.5, "smooth_efficiency": 1.0}, 10.0)
	proof["fog_radius_class_default_ten"] = is_equal_approx(float(class_default.get("fog_radius", -1.0)), 5.0)

	# Absent frame keys start at the Java defaults: an empty
	# frame reads progress 0.0 and smooth_efficiency 1.0 --
	# so the live radius is 34 * 0.0 * 1.0 = 0.0.
	var absent: Dictionary = radar_build_state.source_radar_fog_radius_state({}, 34.0)
	proof["fog_radius_absent_frame_starts_at_java_defaults"] = is_equal_approx(float(absent.get("fog_radius", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarFogRadiusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
