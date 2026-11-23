extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _defaults_case(block_name: String) -> Dictionary:
	return state.source_beam_drill_laser_defaults_state({}, block_name)


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

	# --- BeamDrill field defaults (N2440):
	# BeamDrill field defaults (BeamDrill.java:28-59)
	# are load-time block definition setup, not a
	# per-tick driver: they only fix the 12 laser /
	# spark / glow / heat field defaults. The proof
	# drives the pure function with synthetic frames
	# (no live tick): plasma-bore (Blocks.java:3038)
	# and large-plasma-bore (Blocks.java:3052) region
	# names -- neither def overrides any of the 12
	# lines (only laserWidth 0.7f, Blocks.java:3062)
	# -- plus every scalar / color default. NOT
	# ambient C (N2304 HELD -- the SoundControl
	# updateLoops mixer), NO driver tick line: field
	# defaults are load-time, not per-tick state.

	# The laser region names resolve as block name +
	# suffix ("@-beam" etc., BeamDrill.java:28-34).
	var plasma: Dictionary = _defaults_case("plasma-bore")
	proof["defaults_laser_region"] = plasma.get("laser", null) == "plasma-bore-beam"
	proof["defaults_laser_end_region"] = plasma.get("laser_end", null) == "plasma-bore-beam-end"
	proof["defaults_laser_center_region"] = plasma.get("laser_center", null) == "plasma-bore-beam-center"
	proof["defaults_laser_boost_region"] = plasma.get("laser_boost", null) == "plasma-bore-beam-boost"
	proof["defaults_laser_end_boost_region"] = plasma.get("laser_end_boost", null) == "plasma-bore-beam-boost-end"
	proof["defaults_laser_center_boost_region"] = plasma.get("laser_center_boost", null) == "plasma-bore-beam-boost-center"

	# sparkColor is Color.valueOf("fd9e81"):
	# (253, 158, 129) / 255, alpha 1.
	var spark_color: Color = plasma.get("spark_color", Color.BLACK)
	proof["defaults_spark_color"] = is_equal_approx(spark_color.r, 253.0 / 255.0) and is_equal_approx(spark_color.g, 158.0 / 255.0) and is_equal_approx(spark_color.b, 129.0 / 255.0) and is_equal_approx(spark_color.a, 1.0)

	# glowColor is Color.white.
	var glow_color: Color = plasma.get("glow_color", Color.BLACK)
	proof["defaults_glow_color"] = glow_color == Color.WHITE

	# glowIntensity is 0.2f, pulseIntensity is 0.07f.
	proof["defaults_glow_intensity"] = is_equal_approx(float(plasma.get("glow_intensity", -1.0)), 0.2)
	proof["defaults_pulse_intensity"] = is_equal_approx(float(plasma.get("pulse_intensity", -1.0)), 0.07)

	# glowScl is 3f.
	proof["defaults_glow_scl"] = is_equal_approx(float(plasma.get("glow_scl", -1.0)), 3.0)

	# sparks is 7.
	proof["defaults_sparks"] = int(plasma.get("sparks", -1)) == 7

	# sparkRange 10f, sparkLife 27f, sparkRecurrence 4f,
	# sparkSpread 45f, sparkSize 3.5f.
	proof["defaults_spark_range"] = is_equal_approx(float(plasma.get("spark_range", -1.0)), 10.0)
	proof["defaults_spark_life"] = is_equal_approx(float(plasma.get("spark_life", -1.0)), 27.0)
	proof["defaults_spark_recurrence"] = is_equal_approx(float(plasma.get("spark_recurrence", -1.0)), 4.0)
	proof["defaults_spark_spread"] = is_equal_approx(float(plasma.get("spark_spread", -1.0)), 45.0)
	proof["defaults_spark_size"] = is_equal_approx(float(plasma.get("spark_size", -1.0)), 3.5)

	# boostHeatColor is Color.sky.cpy().mul(0.87f):
	# sky (135, 206, 235) / 255, every component * 0.87.
	var boost_heat_color: Color = plasma.get("boost_heat_color", Color.BLACK)
	proof["defaults_boost_heat_color"] = is_equal_approx(boost_heat_color.r, 135.0 / 255.0 * 0.87) and is_equal_approx(boost_heat_color.g, 206.0 / 255.0 * 0.87) and is_equal_approx(boost_heat_color.b, 235.0 / 255.0 * 0.87) and is_equal_approx(boost_heat_color.a, 0.87)

	# A second block name resolves its own region names
	# and shares the same scalar / color defaults.
	var large: Dictionary = _defaults_case("large-plasma-bore")
	proof["defaults_large_bore_regions"] = large.get("laser", null) == "large-plasma-bore-beam" and large.get("laser_end", null) == "large-plasma-bore-beam-end" and large.get("laser_center", null) == "large-plasma-bore-beam-center" and large.get("laser_boost", null) == "large-plasma-bore-beam-boost" and large.get("laser_end_boost", null) == "large-plasma-bore-beam-boost-end" and large.get("laser_center_boost", null) == "large-plasma-bore-beam-boost-center" and int(large.get("sparks", -1)) == 7 and is_equal_approx(float(large.get("glow_scl", -1.0)), 3.0)

	# Each result carries ONLY its own keys (18).
	proof["returns_only_expected_keys"] = plasma.size() == 18 and large.size() == 18

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillLaserDefaultsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
