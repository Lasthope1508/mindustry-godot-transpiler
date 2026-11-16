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

	# --- Discovery/glow rows (N2503): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2489 /
	# N2490 / N2498 precedent). The class fields
	# (Radar.java:18-19, :24-25): discoveryTime 60f
	# * 10f, rotateSpeed 2f, glowColor
	# Pal.turretHeat, glowScl 5f, glowMag 0.6f. The
	# single radar def (Blocks.java:1988-1995) does
	# NOT override any of them -- it sets only
	# fogRadius 34 + consumers -- so the def row
	# EQUALS the class row here. An unknown def id
	# falls back to the CLASS defaults (the N2304
	# fallback precedent). The glow color rides as
	# a String TOKEN ("Pal.turretHeat", the N2469
	# token precedent). Pure-only: the caller (the
	# N2427 draw pure's caller, the N2190 advance's
	# caller) reads it; the existing pures are
	# unchanged.

	# --- Def row: radar -- discoveryTime 600f,
	# rotateSpeed 2f, glowColor Pal.turretHeat,
	# glowScl 5f, glowMag 0.6f.
	var radar: Dictionary = radar_build_state.source_radar_discovery_glow_rows_state("radar")
	proof["rows_radar"] = is_equal_approx(float(radar.get("discovery_time", -1.0)), 600.0) and is_equal_approx(float(radar.get("rotate_speed", -1.0)), 2.0) and str(radar.get("glow_color", "")) == "Pal.turretHeat" and is_equal_approx(float(radar.get("glow_scl", -1.0)), 5.0) and is_equal_approx(float(radar.get("glow_mag", -1.0)), 0.6)

	# --- Discovery: discoveryTime is 60f * 10f =
	# 600f (Radar.java:18) -- a full-efficiency
	# radar discovers in 600 ticks: frame progress
	# 0.0 plus edelta 600 over the discoveryTime
	# divisor lands on 1.0 through the N2190
	# advance (`progress += edelta() /
	# discoveryTime;`, Radar.java:68).
	var discover_frame: Dictionary = {"progress": 0.0, "smooth_efficiency": 1.0, "total_progress": 0.0, "last_radius": 0.0}
	var discover_advance: Dictionary = radar_build_state.source_radar_update_tile_state(discover_frame, 1.0, 600.0, 0.0, 34.0, float(radar.get("discovery_time", 0.0)))
	var discover_advanced: Dictionary = discover_advance.get("advance", {})
	proof["rows_discovery"] = is_equal_approx(float(radar.get("discovery_time", -1.0)), 60.0 * 10.0) and is_equal_approx(float(radar.get("discovery_time", -1.0)), 600.0) and is_equal_approx(float(discover_advanced.get("progress", -1.0)), 1.0)

	# --- Rotate / glow: rotateSpeed 2f (Radar.java:19),
	# glowScl 5f and glowMag 0.6f (Radar.java:25) --
	# the draw rotation factor and the additive glow
	# pulse (Radar.java:89).
	proof["rows_rotate_glow"] = is_equal_approx(float(radar.get("rotate_speed", -1.0)), 2.0) and is_equal_approx(float(radar.get("glow_scl", -1.0)), 5.0) and is_equal_approx(float(radar.get("glow_mag", -1.0)), 0.6)

	# --- Color token: the glow color is the String
	# TOKEN "Pal.turretHeat" (the N2469 token
	# precedent -- SSOT has no Color type), not a
	# Color value. Pal.turretHeat is
	# Color.valueOf("ab3400") (Pal.java:52 --
	# 6-digit hex, so alpha 1.0).
	proof["rows_color_token"] = typeof(radar.get("glow_color", null)) == TYPE_STRING and str(radar.get("glow_color", "")) == "Pal.turretHeat"

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# discoveryTime 60f * 10f, rotateSpeed 2f,
	# glowColor Pal.turretHeat, glowScl 5f,
	# glowMag 0.6f (the N2304 fallback precedent).
	# The def does not override any of them, so
	# the fallback rows equal the def rows.
	var fallback: Dictionary = radar_build_state.source_radar_discovery_glow_rows_state("no-such-def")
	var empty_fallback: Dictionary = radar_build_state.source_radar_discovery_glow_rows_state("")
	proof["rows_class_fallback"] = is_equal_approx(float(fallback.get("discovery_time", -1.0)), 600.0) and is_equal_approx(float(fallback.get("rotate_speed", -1.0)), 2.0) and str(fallback.get("glow_color", "")) == "Pal.turretHeat" and is_equal_approx(float(fallback.get("glow_scl", -1.0)), 5.0) and is_equal_approx(float(fallback.get("glow_mag", -1.0)), 0.6) and is_equal_approx(float(empty_fallback.get("discovery_time", -1.0)), 600.0) and is_equal_approx(float(empty_fallback.get("rotate_speed", -1.0)), 2.0) and str(empty_fallback.get("glow_color", "")) == "Pal.turretHeat" and is_equal_approx(float(empty_fallback.get("glow_scl", -1.0)), 5.0) and is_equal_approx(float(empty_fallback.get("glow_mag", -1.0)), 0.6)

	# --- Live input: the rows feed the N2427 draw
	# pure + the N2190 advance as their
	# caller-supplied inputs -- rotateSpeed 2f x
	# totalProgress 1.0 rotates 2.0, the glow
	# absin at time 0.0 is mag / 2 = 0.3 (the
	# shared helper at the DOUBLED scale glowScl *
	# 2f), so the glow alpha with glowColor.a 1.0
	# is 1.0 * (1 - 0.6 + 0.3) = 0.7 and the glow
	# call carries the Pal.turretHeat token; and
	# the advance divisor discoveryTime 600f takes
	# frame progress 0.5 plus edelta 60 to 0.6.
	var draw: Dictionary = radar_build_state.source_radar_draw_state(0.0, 0.0, float(radar.get("rotate_speed", 0.0)), 1.0, str(radar.get("glow_color", "")), 1.0, float(radar.get("glow_mag", 0.0)), float(radar.get("glow_scl", 0.0)), 0.0, 34.0, 0.0, 0.0, 1, 0, 0)
	var glow_call: Dictionary = draw.get("glow_call", {})
	var live_frame: Dictionary = {"progress": 0.5, "smooth_efficiency": 1.0, "total_progress": 0.0, "last_radius": 0.0}
	var live_advance: Dictionary = radar_build_state.source_radar_update_tile_state(live_frame, 1.0, 60.0, 0.0, 34.0, float(radar.get("discovery_time", 0.0)))
	var live_advanced: Dictionary = live_advance.get("advance", {})
	proof["rows_live_input"] = is_equal_approx(float(draw.get("rotation", -1.0)), 2.0) and is_equal_approx(float(draw.get("glow_absin", -1.0)), 0.3) and is_equal_approx(float(draw.get("glow_alpha_value", -1.0)), 0.7) and str(glow_call.get("color", "")) == "Pal.turretHeat" and is_equal_approx(float(live_advanced.get("progress", -1.0)), 0.6)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarDiscoveryGlowRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
