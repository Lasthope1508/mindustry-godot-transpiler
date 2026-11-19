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

	# --- Pure draw() rows (N2278): RadarBuild.draw()
	# (Radar.java:84-90) rotates the dish region and the glow
	# by rotateSpeed * totalProgress (Radar.java:87, :89) and
	# pulses the glow alpha as glowColor.a * (1f - glowMag +
	# Mathf.absin(glowScl, glowMag)) (Radar.java:89). The def
	# values are rotateSpeed 2f (Radar.java:19), glowScl 5f /
	# glowMag 0.6f (Radar.java:25), glowColor Pal.turretHeat
	# (Radar.java:24, Pal.java:52, 6-digit hex -- alpha 1.0).
	# The proof calls the pure functions
	# source_radar_draw_rotation_state(frame, rotate_speed) and
	# source_radar_draw_glow_state(frame, glow_color_alpha,
	# glow_mag, absin_value) directly with synthetic frames and
	# def values; absin is time-dependent, so the caller
	# supplies its evaluated value. There are no driver-tick
	# keys: draw() is a render call, not tick state. Float
	# comparisons use is_equal_approx (the N2310 write/read
	# precedent for inexact float32 values).

	# Zero total progress reads zero rotation -- the dish has
	# not advanced yet.
	var zero: Dictionary = radar_build_state.source_radar_draw_rotation_state({"total_progress": 0.0}, 2.0)
	proof["draw_rotation_zero_total_progress"] = is_equal_approx(float(zero.get("rotation", -1.0)), 0.0)

	# Half a progress unit at the def rotate speed reads 1.0.
	var half: Dictionary = radar_build_state.source_radar_draw_rotation_state({"total_progress": 0.5}, 2.0)
	proof["draw_rotation_half_progress"] = is_equal_approx(float(half.get("rotation", -1.0)), 1.0)

	# Ten progress units at the def rotate speed read 20.0 --
	# the rotation is unbounded, it follows totalProgress.
	var full: Dictionary = radar_build_state.source_radar_draw_rotation_state({"total_progress": 10.0}, 2.0)
	proof["draw_rotation_full_progress"] = is_equal_approx(float(full.get("rotation", -1.0)), 20.0)

	# An absent frame defaults total_progress to 0.0 (the Java
	# field init, Radar.java:52) and reads zero rotation.
	var absent: Dictionary = radar_build_state.source_radar_draw_rotation_state({}, 2.0)
	proof["draw_rotation_absent_frame_zero"] = is_equal_approx(float(absent.get("rotation", -1.0)), 0.0)

	# Partial pulse: def glow alpha 1.0, glowMag 0.6, absin 0.3
	# reads 1.0 * (1.0 - 0.6 + 0.3) = 0.7.
	var pulse: Dictionary = radar_build_state.source_radar_draw_glow_state({}, 1.0, 0.6, 0.3)
	proof["draw_glow_alpha_full_pulse"] = is_equal_approx(float(pulse.get("glow_alpha", -1.0)), 0.7)

	# Zero absin reads the floor: 1.0 * (1.0 - 0.6 + 0.0) = 0.4.
	var floor: Dictionary = radar_build_state.source_radar_draw_glow_state({}, 1.0, 0.6, 0.0)
	proof["draw_glow_alpha_zero_absin"] = is_equal_approx(float(floor.get("glow_alpha", -1.0)), 0.4)

	# Half color alpha at peak absin reads 0.5 * (1.0 - 0.6 +
	# 0.6) = 0.5 -- the alpha scales the whole pulse.
	var half_alpha: Dictionary = radar_build_state.source_radar_draw_glow_state({}, 0.5, 0.6, 0.6)
	proof["draw_glow_alpha_half_color_alpha"] = is_equal_approx(float(half_alpha.get("glow_alpha", -1.0)), 0.5)

	# Peak absin reads full glow alpha: 1.0 * (1.0 - 0.6 +
	# 0.6) = 1.0.
	var peak: Dictionary = radar_build_state.source_radar_draw_glow_state({}, 1.0, 0.6, 0.6)
	proof["draw_glow_alpha_absin_max"] = is_equal_approx(float(peak.get("glow_alpha", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
