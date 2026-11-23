extends Node

const main_scene := preload("res://scenes/Main.tscn")
const state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _draw_case(facing: Array, lasers: Array, size: int, build_id: int, warmup: float, boost_warmup: float, is_payload: bool, time_ticks: float, lod_l2: bool, rotation: int = 0) -> Dictionary:
	return state.source_beam_drill_draw_state(80.0, 80.0, "block-region", "top-region", "laser", "laser-end", "laser-center", "laser-boost", "laser-end-boost", "laser-center-boost", "glow-region", true, rotation, size, build_id, warmup, boost_warmup, is_payload, facing, lasers, 0.65, 3.0, 0.07, Color.WHITE, 0.2, Color(0.992, 0.619, 0.506), Color(0.4, 0.7, 0.9), Color(1.0, 0.35, 0.35, 0.9), 0.3, 7.0, 7, 27.0, 4.0, 10.0, 45.0, 3.5, time_ticks, lod_l2, 1.0, 8.0)


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

	# --- BeamDrillBuild.draw() (N2382):
	# BeamDrillBuild.draw() (BeamDrill.java:275-361) draws the base
	# + top rects, one laser per faced side (center rects when the
	# laser point sits on the face tile, Drawf.laser beams
	# otherwise), the Lod.l2 spark loop driven by the build rand,
	# and the additive glow rect. The proof drives the pure
	# function with synthetic frames (no live tick): plasma-bore
	# defaults (laserWidth 0.65, glowScl 3, pulseIntensity 0.07,
	# glowIntensity 0.2, sparks 7, sparkRange 10, sparkLife 27,
	# sparkRecurrence 4, sparkSpread 45, sparkSize 3.5,
	# Blocks.java:3038-3051), build at tile (10, 10) -> world
	# (80, 80), tilesize 8. The spark draws are checked against
	# an independent Python oracle of arc Rand (Rand.java
	# xorshift128+, setState(i, id) direct): face i=0, id=7 gives
	# fin 0.0 / or -2.0 / spread -45.0 on spark 0 (the degenerate
	# first draw from the near-zero state -- Java does the same),
	# fin 0.000133514404296875 on spark 1, fin
	# 0.00015020370483398438 on spark 2; id=8 gives fin
	# 0.000152587890625 on spark 1. NO driver tick line: draw()
	# is per-frame render state.

	var copper_tile: Dictionary = {"x": 12, "y": 10, "wall_drop": "copper", "drop_color": Color(0.85, 0.55, 0.25)}
	var lead_tile: Dictionary = {"x": 12, "y": 11, "wall_drop": "lead", "drop_color": Color(0.6, 0.65, 0.85)}
	var centered: Dictionary = _draw_case([copper_tile, lead_tile], [Vector2i(12, 10), Vector2i(12, 11)], 2, 7, 1.0, 0.0, false, 0.0, true)
	var centered_lasers: Array = centered.get("lasers", [])

	# Base + top rects are always drawn; the top rect rotates
	# with the build (rotation 0 -> 0 deg here).
	var base_rect: Dictionary = centered.get("base_rect", {})
	var top_rect: Dictionary = centered.get("top_rect", {})
	proof["base_and_top_rects"] = base_rect.get("region", "") == "block-region" and is_equal_approx(float(base_rect.get("x", -1.0)), 80.0) and is_equal_approx(float(base_rect.get("y", -1.0)), 80.0) and top_rect.get("region", "") == "top-region" and is_equal_approx(float(top_rect.get("rotation_deg", -1.0)), 0.0)

	# A payload build draws only the base + top rects: no lasers,
	# no glow.
	var payload: Dictionary = _draw_case([copper_tile, lead_tile], [Vector2i(12, 10), Vector2i(12, 11)], 2, 7, 1.0, 0.0, true, 0.0, true)
	proof["payload_returns_early"] = bool(payload.get("is_payload", false)) and (payload.get("lasers", [1]) as Array).is_empty() and not bool(payload.get("glow_visible", true)) and payload.get("glow_rect", "x") == null and (payload.get("base_rect", {}) as Dictionary).get("region", "") == "block-region"

	# Both faces are centered (laser point == face tile): the
	# center rects carry scale = width and alpha 1 - boostWarmup
	# (boost 0 -> alpha 1), the boost center rects are null
	# (boost 0 is not > 0.01).
	var entry0: Dictionary = centered_lasers[0]
	var entry1: Dictionary = centered_lasers[1]
	var center0: Dictionary = entry0.get("center_rect", {})
	proof["centered_branch"] = centered_lasers.size() == 2 and bool(entry0.get("centered", false)) and bool(entry1.get("centered", false)) and is_equal_approx(float(entry0.get("lx", -1.0)), 92.0) and is_equal_approx(float(entry0.get("ly", -1.0)), 80.0) and is_equal_approx(float(entry1.get("lx", -1.0)), 92.0) and is_equal_approx(float(entry1.get("ly", -1.0)), 88.0) and center0.get("region", "") == "laser-center" and is_equal_approx(float(center0.get("scale", -1.0)), float(entry0.get("width", -2.0))) and is_equal_approx(float(center0.get("alpha", -1.0)), 1.0) and entry0.get("center_boost_rect", "x") == null

	# A face whose laser point is off the tile takes the beam
	# branch: Drawf.laser from the laser point (lsx, lsy) to the
	# face point (lx, ly), boost 0.5 -> both alphas 0.5.
	var far_tile: Dictionary = {"x": 14, "y": 10, "wall_drop": "copper", "drop_color": Color(0.85, 0.55, 0.25)}
	var beamed: Dictionary = _draw_case([far_tile], [Vector2i(12, 10)], 1, 7, 1.0, 0.5, false, 0.0, true)
	var beam_lasers: Array = beamed.get("lasers", [])
	var beam0: Dictionary = beam_lasers[0]
	var beam_laser: Dictionary = beam0.get("laser", {})
	var beam_laser_boost: Dictionary = beam0.get("laser_boost", {})
	proof["beam_branch"] = beam_lasers.size() == 1 and not bool(beam0.get("centered", true)) and is_equal_approx(float(beam0.get("lsx", -1.0)), 92.0) and is_equal_approx(float(beam0.get("lsy", -1.0)), 80.0) and is_equal_approx(float(beam0.get("lx", -1.0)), 108.0) and is_equal_approx(float(beam0.get("ly", -1.0)), 80.0) and beam_laser.get("region", "") == "laser" and beam_laser.get("end_region", "") == "laser-end" and is_equal_approx(float(beam_laser.get("x1", -1.0)), 92.0) and is_equal_approx(float(beam_laser.get("y1", -1.0)), 80.0) and is_equal_approx(float(beam_laser.get("x2", -1.0)), 108.0) and is_equal_approx(float(beam_laser.get("y2", -1.0)), 80.0) and is_equal_approx(float(beam_laser.get("alpha", -1.0)), 0.5) and beam_laser_boost.get("region", "") == "laser-boost" and is_equal_approx(float(beam_laser_boost.get("alpha", -1.0)), 0.5)

	# Width and mixcol follow the absin formulas with the pinned
	# time: width = (laserWidth + absin(time + i*5 + (id % 9)*9,
	# glowScl, pulseIntensity)) * warmup, mix = absin(time + i*5
	# + id*9, glowScl, glowIntensity). Expected values are
	# computed here with plain sin (not the helper under test).
	var expected_width0: float = (0.65 + (sin(63.0 / 3.0) * 0.5 + 0.5) * 0.07) * 1.0
	var expected_mix0: float = (sin(63.0 / 3.0) * 0.5 + 0.5) * 0.2
	var expected_width1: float = (0.65 + (sin(68.0 / 3.0) * 0.5 + 0.5) * 0.07) * 1.0
	proof["width_and_mix_formula"] = is_equal_approx(float(entry0.get("width", -1.0)), expected_width0) and is_equal_approx(float(entry0.get("mix_amount", -1.0)), expected_mix0) and is_equal_approx(float(entry1.get("width", -1.0)), expected_width1) and is_equal_approx(float(entry0.get("z_layer", -1.0)), 69.0)

	# The boost gates differ per branch: center 0.99/0.01, beam
	# 0.99/0.001. At boost 0.999 the center rect vanishes and the
	# boost center rect appears; at boost 0.0005 the beam stays
	# and the boost beam vanishes.
	var boost_high: Dictionary = _draw_case([copper_tile], [Vector2i(12, 10)], 1, 7, 1.0, 0.999, false, 0.0, true)
	var boost_high_entry: Dictionary = (boost_high.get("lasers", []) as Array)[0]
	var boost_low: Dictionary = _draw_case([far_tile], [Vector2i(12, 10)], 1, 7, 1.0, 0.0005, false, 0.0, true)
	var boost_low_entry: Dictionary = (boost_low.get("lasers", []) as Array)[0]
	proof["boost_gates"] = boost_high_entry.get("center_rect", "x") == null and (boost_high_entry.get("center_boost_rect", {}) as Dictionary).get("region", "") == "laser-center-boost" and is_equal_approx(float((boost_high_entry.get("center_boost_rect", {}) as Dictionary).get("alpha", -1.0)), 0.999) and (boost_low_entry.get("laser", {}) as Dictionary).get("region", "") == "laser" and boost_low_entry.get("laser_boost", "x") == null

	# Each face draws exactly `sparks` sparks, every fin in
	# [0, sparkRecurrence).
	var sparks0: Array = entry0.get("sparks", [])
	var sparks1: Array = entry1.get("sparks", [])
	var fin_range_ok: bool = sparks0.size() == 7 and sparks1.size() == 7
	for spark in sparks0 + sparks1:
		var fin_value: float = float((spark as Dictionary).get("fin", -1.0))
		if fin_value < 0.0 or fin_value >= 4.0:
			fin_range_ok = false
	proof["spark_count_and_fin_range"] = fin_range_ok and is_equal_approx(float(entry0.get("spark_stroke", -1.0)), 1.0) and is_equal_approx(float(entry0.get("spark_z_layer", -1.0)), 110.0)

	# The first draws match the independent Python arc-Rand
	# oracle (setState(i, id) direct, no murmur hash): spark 0
	# is the degenerate first draw from the near-zero state.
	var oracle0: Dictionary = sparks0[0]
	var oracle1: Dictionary = sparks0[1]
	var oracle2: Dictionary = sparks0[2]
	var oracle_face1: Dictionary = sparks1[0]
	proof["spark_oracle_first_draws"] = is_equal_approx(float(oracle0.get("fin", -1.0)), 0.0) and is_equal_approx(float(oracle0.get("or", -9.0)), -2.0) and is_equal_approx(float(oracle0.get("px", -9.0)), 0.0) and is_equal_approx(float(oracle0.get("py", -9.0)), 0.0) and is_equal_approx(float(oracle1.get("fin", -1.0)), 0.000133514404296875) and is_equal_approx(float(oracle1.get("or", -9.0)), -1.999786376953125) and is_equal_approx(float(oracle1.get("px", -9.0)), 0.0009441686025803973) and is_equal_approx(float(oracle1.get("py", -9.0)), -0.0009440102040636632) and is_equal_approx(float(oracle2.get("fin", -1.0)), 0.00015020370483398438) and is_equal_approx(float(oracle2.get("or", -9.0)), -1.5623664855957031) and is_equal_approx(float(oracle2.get("px", -9.0)), 0.0013580980251812805) and is_equal_approx(float(oracle2.get("py", -9.0)), -0.0006416268764509294) and is_equal_approx(float(oracle_face1.get("fin", -1.0)), 0.0) and is_equal_approx(float(oracle_face1.get("or", -9.0)), -2.0)

	# Same inputs twice -> identical spark lists (setState
	# re-seeds per face, the sequence is deterministic).
	var centered_again: Dictionary = _draw_case([copper_tile, lead_tile], [Vector2i(12, 10), Vector2i(12, 11)], 2, 7, 1.0, 0.0, false, 0.0, true)
	var centered_again_lasers: Array = centered_again.get("lasers", [])
	proof["spark_determinism"] = ((centered_again_lasers[0] as Dictionary).get("sparks", []) as Array) == sparks0 and ((centered_again_lasers[1] as Dictionary).get("sparks", []) as Array) == sparks1

	# A different build id seeds a different sequence: id 8
	# spark 1 fin is 0.000152587890625, not id 7's
	# 0.000133514404296875.
	var other_id: Dictionary = _draw_case([copper_tile, lead_tile], [Vector2i(12, 10), Vector2i(12, 11)], 2, 8, 1.0, 0.0, false, 0.0, true)
	var other_sparks0: Array = ((other_id.get("lasers", []) as Array)[0] as Dictionary).get("sparks", [])
	proof["spark_seed_sensitivity"] = is_equal_approx(float((other_sparks0[1] as Dictionary).get("fin", -1.0)), 0.000152587890625) and not is_equal_approx(float((other_sparks0[1] as Dictionary).get("fin", -1.0)), float(oracle1.get("fin", -1.0)))

	# Spark line geometry: rotation preserves the offset length
	# (|offset| == sparkRange * fin), the line appears exactly
	# when fin <= 1 with length slope(fin) * sparkSize, and the
	# draw alpha is result.a * lod_alpha2.
	var geometry_ok: bool = true
	for spark in sparks0:
		var spark_dict: Dictionary = spark
		var fin_value: float = float(spark_dict.get("fin", 0.0))
		var px_value: float = float(spark_dict.get("px", 0.0))
		var py_value: float = float(spark_dict.get("py", 0.0))
		if not is_equal_approx(px_value * px_value + py_value * py_value, (10.0 * fin_value) * (10.0 * fin_value)):
			geometry_ok = false
		var line_value: Variant = spark_dict.get("line", "missing")
		if fin_value <= 1.0:
			if not (line_value is Dictionary):
				geometry_ok = false
			else:
				var line_dict: Dictionary = line_value
				var slope_fin: float = fin_value * 2.0 if fin_value <= 0.5 else (1.0 - fin_value) * 2.0
				if not is_equal_approx(float(line_dict.get("length", -1.0)), slope_fin * 3.5):
					geometry_ok = false
				var expected_angle: float = rad_to_deg(atan2(py_value, px_value))
				if expected_angle < 0.0:
					expected_angle += 360.0
				if not is_equal_approx(float(line_dict.get("angle_deg", -1.0)), expected_angle):
					geometry_ok = false
		var spark_color: Color = spark_dict.get("color", Color.BLACK)
		if not is_equal_approx(float(spark_dict.get("alpha", -1.0)), spark_color.a * 1.0):
			geometry_ok = false
	proof["spark_line_geometry"] = geometry_ok

	# Lod off skips the whole spark loop.
	var lod_off: Dictionary = _draw_case([copper_tile], [Vector2i(12, 10)], 1, 7, 1.0, 0.0, false, 0.0, false)
	var lod_off_entry: Dictionary = (lod_off.get("lasers", []) as Array)[0]
	proof["lod_off_skips_sparks"] = ((lod_off_entry.get("sparks", [1]) as Array)).is_empty()

	# The glow is additive at z 31 with the heat color lerped
	# toward boostHeatColor by boostWarmup (0 here -> heat
	# color) and alpha warmup * (heatColor.a * (1 - heatPulse +
	# absin(time, heatPulseScl, heatPulse))).
	var expected_glow_alpha: float = 1.0 * (0.9 * (1.0 - 0.3 + (sin(0.0 / 7.0) * 0.5 + 0.5) * 0.3))
	var glow_rect: Dictionary = centered.get("glow_rect", {})
	var glow_color: Color = centered.get("glow_color", Color.BLACK)
	proof["glow_state"] = bool(centered.get("glow_visible", false)) and glow_rect.get("region", "") == "glow-region" and is_equal_approx(float(glow_rect.get("rotation_deg", -1.0)), 0.0) and is_equal_approx(float(centered.get("glow_alpha", -1.0)), expected_glow_alpha) and glow_color.is_equal_approx(Color(1.0, 0.35, 0.35, 0.9))

	# A null face and a face with no drop are both skipped; only
	# the copper face draws.
	var no_drop_tile: Dictionary = {"x": 12, "y": 10, "wall_drop": null, "drop_color": Color(0.85, 0.55, 0.25)}
	var skipped: Dictionary = _draw_case([null, no_drop_tile, copper_tile], [Vector2i(12, 10), Vector2i(12, 10), Vector2i(12, 10)], 3, 7, 1.0, 0.0, false, 0.0, true)
	var skipped_lasers: Array = skipped.get("lasers", [])
	proof["null_face_and_null_drop_skipped"] = skipped_lasers.size() == 1 and int((skipped_lasers[0] as Dictionary).get("index", -1)) == 2

	# Each result carries ONLY its own keys.
	proof["returns_only_eight_keys"] = centered.size() == 8

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
