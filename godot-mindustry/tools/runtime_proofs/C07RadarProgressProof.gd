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

	# --- Pure progress() accessor (N2263): RadarBuild.progress()
	# (Radar.java:93, `public float progress(){` with `return
	# progress;`, Radar.java:94) overrides the base
	# BuildingComp.progress() for Radar: it returns the frame's
	# progress (the Java field `public float progress;`,
	# Radar.java:49, init 0.0), advanced by updateTile
	# (Radar.java:68, `progress += edelta() / discoveryTime;`,
	# clamped Radar.java:69, `progress = Mathf.clamp(progress);`,
	# N2248) and read by fogRadius() (Radar.java:56, `return
	# fogRadius * progress * smoothEfficiency;`, N2249). The
	# proof calls the pure function
	# source_radar_progress_state(frame) directly with
	# synthetic frames. There are no logic-dispatch keys: the
	# sensor hook waits for its own slice, and the write/read
	# persistence rows are a separate slice with their own
	# proof.

	# Absent frame starts at the Java default: an empty frame
	# reads progress 0.0 -- so the accessor returns 0.0.
	var absent: Dictionary = radar_build_state.source_radar_progress_state({})
	proof["progress_absent_frame_starts_at_zero"] = is_equal_approx(float(absent.get("progress", -1.0)), 0.0)

	# Half discovery: progress 0.5 returns 0.5.
	var half: Dictionary = radar_build_state.source_radar_progress_state({"progress": 0.5})
	proof["progress_half_discovery"] = is_equal_approx(float(half.get("progress", -1.0)), 0.5)

	# Full discovery: progress 1.0 returns 1.0.
	var full: Dictionary = radar_build_state.source_radar_progress_state({"progress": 1.0})
	proof["progress_full_discovery"] = is_equal_approx(float(full.get("progress", -1.0)), 1.0)

	# The N2248 advance round-trips through the accessor:
	# one tick at efficiency 1.0 and delta 1.0 advances
	# progress by edelta() / discoveryTime = 1.0 / 600.0,
	# and the accessor returns exactly that advanced value.
	var advanced: Dictionary = radar_build_state.source_radar_update_tile_state({"efficiency": 1.0}, 1.0, 600.0, 34.0)
	var expected: float = 1.0 / 600.0
	var round_tripped: Dictionary = radar_build_state.source_radar_progress_state(advanced)
	proof["progress_matches_update_tile_advance"] = is_equal_approx(float(advanced.get("progress", -1.0)), expected) and is_equal_approx(float(round_tripped.get("progress", -1.0)), expected)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarProgressProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
