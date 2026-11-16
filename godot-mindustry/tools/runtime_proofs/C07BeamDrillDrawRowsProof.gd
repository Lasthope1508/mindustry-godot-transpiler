extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- Draw rows (N2436): BeamDrillBuild.drawSelect()
	# (BeamDrill.java:231-234) + BeamDrillBuild.draw()
	# (BeamDrill.java:275-357). draw() rects the base
	# region + the top region at rotdeg(), then returns
	# early when the build is a payload; per laser the
	# width absin reads (id % 9) * 9 while the mixcol
	# absin reads id * 9, the centered branch rects
	# laserCenter / laserCenterBoost at scl(width) and
	# the laser branch records Drawf.laser calls with
	# the ASYMMETRIC boost gates (> 0.01 center vs >
	# 0.001 laser); the Lod.l2 sparks ride
	# caller-supplied rolls in Java draw order and
	# draw only when fin <= 1; the glow additive draws
	# when the glow region is found. icons() returns
	# {region, topRegion}. Pure-only: the tick never
	# calls draw/drawSelect.

	# --- Fixture: a plasma-bore at (100, 200),
	# rotation 0, size 2, id 0, warmup 1.0, boost 0.0,
	# time 0.0 -- every absin reads mag / 2 at time 0
	# except the i = 1 laser, whose input is i * 5 = 5
	# (width 0.7109061898618614, mixcol
	# 0.1740176853196037, precomputed from sin(5/6)).
	# Laser 0 sits ON its face tile (14, 25) --
	# centered; laser 1 sits at (14, 26) with its face
	# at (16, 26) -- the laser branch. dir = d4(0) =
	# (1, 0), ddx/ddy = d4(1) = (0, 1).
	var facing: Array = [
		{"tile_x": 14, "tile_y": 25, "world_x": 112.0, "world_y": 200.0, "drop": {"name": "copper", "color": "drop-color"}},
		{"tile_x": 16, "tile_y": 26, "world_x": 128.0, "world_y": 208.0, "drop": {"name": "lead", "color": "drop-color"}},
	]
	var lasers: Array = [{"x": 14, "y": 25}, {"x": 14, "y": 26}]
	var spark_rolls: Array = [
		[0.5, 1.0, 0.0, 0.5, 0.0, 90.0, 2.0, 0.0, 0.0, 3.0, 0.0, 0.0, 3.0, 0.0, 0.0, 3.0, 0.0, 0.0, 3.0, 0.0, 0.0],
		[2.0, 0.0, 0.0, 2.0, 0.0, 0.0, 2.0, 0.0, 0.0, 2.0, 0.0, 0.0, 2.0, 0.0, 0.0, 2.0, 0.0, 0.0, 2.0, 0.0, 0.0],
	]
	var drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.0, 0.0, true, 1.0, false, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)

	# --- Base / top: the base rect (region, no z key
	# -- it draws before any Draw.z call) + the top
	# rect (topRegion at rotdeg() 0, no z key either),
	# icons() [region, topRegion], draw_rotation 0.0,
	# payload_return false. The payload fixture keeps
	# base/top/icons/select but drops the lasers and
	# the glow (the early return skips both).
	var base_call: Dictionary = drawn.get("base_call", {})
	var top_call: Dictionary = drawn.get("top_call", {})
	var payload_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.0, 0.0, true, 1.0, true, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var payload_base: Dictionary = payload_drawn.get("base_call", {})
	var payload_top: Dictionary = payload_drawn.get("top_call", {})
	proof["draw_base_top"] = str(base_call.get("region", "")) == "region" and is_equal_approx(float(base_call.get("x", -1.0)), 100.0) and is_equal_approx(float(base_call.get("y", -1.0)), 200.0) and not base_call.has("z") and str(top_call.get("region", "")) == "topRegion" and is_equal_approx(float(top_call.get("x", -1.0)), 100.0) and is_equal_approx(float(top_call.get("y", -1.0)), 200.0) and is_equal_approx(float(top_call.get("rotation", -1.0)), 0.0) and not top_call.has("z") and (drawn.get("icon_regions", []) as Array) == ["region", "topRegion"] and is_equal_approx(float(drawn.get("draw_rotation", -1.0)), 0.0) and not bool(drawn.get("payload_return", true)) and bool(payload_drawn.get("payload_return", false)) and (payload_drawn.get("laser_calls", [{}]) as Array).is_empty() and payload_drawn.get("glow_call", {}) == null and is_equal_approx(float(payload_base.get("x", -1.0)), 100.0) and is_equal_approx(float(payload_top.get("x", -1.0)), 100.0) and (payload_drawn.get("icon_regions", []) as Array) == ["region", "topRegion"] and payload_drawn.get("select_call", {}) != null

	# --- Laser centered: laser 0 is centered (|14-14|
	# + |25-25| == 0), lx = 112 - 4 = 108, ly = 200,
	# width (0.65 + 0.035) * 1.0 = 0.685, mixcol 0.1,
	# z Layer.power - 1, one center call (laserCenter,
	# alpha 1.0, scl 0.685 -- the boost center does
	# NOT draw at boostWarmup 0.0) and no laser calls.
	# The skip rules: a null face and a null drop both
	# omit their laser from laser_calls (the entry
	# keeps its index).
	var laser_calls: Array = drawn.get("laser_calls", [])
	var laser0: Dictionary = laser_calls[0]
	var center0: Array = laser0.get("center_calls", [])
	var center_call0: Dictionary = center0[0]
	var null_face_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.0, 0.0, true, 1.0, false, [null, facing[1]], lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var null_face_calls: Array = null_face_drawn.get("laser_calls", [])
	var no_drop_facing: Array = [{"tile_x": 14, "tile_y": 25, "world_x": 112.0, "world_y": 200.0, "drop": null}, facing[1]]
	var no_drop_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.0, 0.0, true, 1.0, false, no_drop_facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var no_drop_calls: Array = no_drop_drawn.get("laser_calls", [])
	proof["draw_laser_centered"] = laser_calls.size() == 2 and bool(laser0.get("centered", false)) and int(laser0.get("index", -1)) == 0 and is_equal_approx(float(laser0.get("width", -1.0)), 0.685) and is_equal_approx(float(laser0.get("mixcol", {}).get("amount", -1.0)), 0.1) and str(laser0.get("mixcol", {}).get("color", "")) == "glowColor" and is_equal_approx(float(laser0.get("lx", -1.0)), 108.0) and is_equal_approx(float(laser0.get("ly", -1.0)), 200.0) and str(laser0.get("z", "")) == "Layer.power - 1" and center0.size() == 1 and str(center_call0.get("region", "")) == "laserCenter" and is_equal_approx(float(center_call0.get("alpha", -1.0)), 1.0) and is_equal_approx(float(center_call0.get("scl", -1.0)), 0.685) and is_equal_approx(float(center_call0.get("x", -1.0)), 108.0) and is_equal_approx(float(center_call0.get("y", -1.0)), 200.0) and laser0.get("laser_calls", {}) == null and null_face_calls.size() == 1 and int(null_face_calls[0].get("index", -1)) == 1 and no_drop_calls.size() == 1 and int(no_drop_calls[0].get("index", -1)) == 1

	# --- Laser branch + boost gates: laser 1 is NOT
	# centered, lx = 128 - 4 = 124, ly = 208, width
	# 0.7109061898618614, mixcol 0.1740176853196037,
	# one laser call (Drawf.laser laser/laserEnd from
	# (108, 208) to (124, 208), scale width, alpha
	# 1.0 -- the boost laser does NOT draw at
	# boostWarmup 0.0) and no center calls. At boost
	# 0.5 both branches draw both variants (alphas
	# 0.5/0.5); at boost 1.0 only the boost variants
	# draw (alpha 1.0). The ASYMMETRIC gates: at
	# boost 0.01 the center branch draws ONLY the
	# normal center (0.01 > 0.01 is false) while the
	# laser branch draws BOTH (0.01 > 0.001 is true);
	# at boost 0.99 both branches draw ONLY the boost
	# variant (0.99 < 0.99 is false).
	var laser1: Dictionary = laser_calls[1]
	var laser1_calls: Array = laser1.get("laser_calls", [])
	var laser_call1: Dictionary = laser1_calls[0]
	var half_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.5, 0.0, true, 1.0, false, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var half_calls: Array = half_drawn.get("laser_calls", [])
	var half_center0: Array = half_calls[0].get("center_calls", [])
	var half_laser1: Array = half_calls[1].get("laser_calls", [])
	var full_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 1.0, 0.0, true, 1.0, false, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var full_calls: Array = full_drawn.get("laser_calls", [])
	var full_center0: Array = full_calls[0].get("center_calls", [])
	var full_laser1: Array = full_calls[1].get("laser_calls", [])
	var edge_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.01, 0.0, true, 1.0, false, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var edge_calls: Array = edge_drawn.get("laser_calls", [])
	var edge_center0: Array = edge_calls[0].get("center_calls", [])
	var edge_laser1: Array = edge_calls[1].get("laser_calls", [])
	var top_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.99, 0.0, true, 1.0, false, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var top_calls: Array = top_drawn.get("laser_calls", [])
	var top_center0: Array = top_calls[0].get("center_calls", [])
	var top_laser1: Array = top_calls[1].get("laser_calls", [])
	proof["draw_laser_branch_boost"] = not bool(laser1.get("centered", true)) and int(laser1.get("index", -1)) == 1 and is_equal_approx(float(laser1.get("width", -1.0)), 0.7109061898618614) and is_equal_approx(float(laser1.get("mixcol", {}).get("amount", -1.0)), 0.1740176853196037) and is_equal_approx(float(laser1.get("lx", -1.0)), 124.0) and is_equal_approx(float(laser1.get("ly", -1.0)), 208.0) and laser1_calls.size() == 1 and str(laser_call1.get("call", "")) == "Drawf.laser(laser, laserEnd, lsx, lsy, lx, ly, width);" and str(laser_call1.get("line", "")) == "laser" and str(laser_call1.get("edge", "")) == "laserEnd" and is_equal_approx(float(laser_call1.get("x1", -1.0)), 108.0) and is_equal_approx(float(laser_call1.get("y1", -1.0)), 208.0) and is_equal_approx(float(laser_call1.get("x2", -1.0)), 124.0) and is_equal_approx(float(laser_call1.get("y2", -1.0)), 208.0) and is_equal_approx(float(laser_call1.get("scale", -1.0)), 0.7109061898618614) and is_equal_approx(float(laser_call1.get("alpha", -1.0)), 1.0) and laser1.get("center_calls", {}) == null and half_center0.size() == 2 and is_equal_approx(float(half_center0[0].get("alpha", -1.0)), 0.5) and is_equal_approx(float(half_center0[1].get("alpha", -1.0)), 0.5) and str(half_center0[1].get("region", "")) == "laserCenterBoost" and half_laser1.size() == 2 and is_equal_approx(float(half_laser1[0].get("alpha", -1.0)), 0.5) and is_equal_approx(float(half_laser1[1].get("alpha", -1.0)), 0.5) and str(half_laser1[1].get("line", "")) == "laserBoost" and str(half_laser1[1].get("edge", "")) == "laserEndBoost" and full_center0.size() == 1 and str(full_center0[0].get("region", "")) == "laserCenterBoost" and is_equal_approx(float(full_center0[0].get("alpha", -1.0)), 1.0) and full_laser1.size() == 1 and str(full_laser1[0].get("line", "")) == "laserBoost" and is_equal_approx(float(full_laser1[0].get("alpha", -1.0)), 1.0) and edge_center0.size() == 1 and str(edge_center0[0].get("region", "")) == "laserCenter" and edge_laser1.size() == 2 and top_center0.size() == 1 and str(top_center0[0].get("region", "")) == "laserCenterBoost" and top_laser1.size() == 1 and str(top_laser1[0].get("line", "")) == "laserBoost"

	# --- Sparks: laser 0 draws exactly 2 spark lines
	# (the fin gate drops the fin-2.0 and fin-3.0
	# sparks). Spark 0: fin 0.5, or 1.0, spread 0.0 --
	# v1 = (5, 0), line at (108 + 5 + 1*0, 200 + 0 +
	# 1*1) = (113, 201), angle 0, length slope(0.5) *
	# 3.5 = 3.5. Spark 1: fin 0.5, or 0.0, spread 90.0
	# -- v1 = (0, 5), line at (108, 205), angle 90,
	# length 3.5. The color is the nested lerp
	# (sparkColor -> boostHeatColor at boostWarmup 0.0,
	# then -> drop.color at fin 0.5), alpha_scale
	# lod_alpha2 1.0, z Layer.effect, stroke warmup
	# 1.0. Laser 1 draws no sparks (all fins 2.0).
	# With Lod.l2 false there are no spark calls and
	# no stroke.
	var sparks0: Array = laser0.get("spark_calls", [])
	var spark0: Dictionary = sparks0[0]
	var spark1: Dictionary = sparks0[1]
	var sparks1: Array = laser1.get("spark_calls", [])
	var dark_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.0, 0.0, false, 1.0, false, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var dark_calls: Array = dark_drawn.get("laser_calls", [])
	var dark_sparks0: Array = dark_calls[0].get("spark_calls", [])
	proof["draw_sparks_rolls"] = sparks0.size() == 2 and is_equal_approx(float(spark0.get("fin", -1.0)), 0.5) and is_equal_approx(float(spark0.get("x", -1.0)), 113.0) and is_equal_approx(float(spark0.get("y", -1.0)), 201.0) and is_equal_approx(float(spark0.get("angle", -1.0)), 0.0) and is_equal_approx(float(spark0.get("length", -1.0)), 3.5) and str(spark0.get("color", {}).get("from", {}).get("from", "")) == "sparkColor" and str(spark0.get("color", {}).get("from", {}).get("to", "")) == "boostHeatColor" and is_equal_approx(float(spark0.get("color", {}).get("from", {}).get("t", -1.0)), 0.0) and str(spark0.get("color", {}).get("to", "")) == "drop-color" and is_equal_approx(float(spark0.get("color", {}).get("t", -1.0)), 0.5) and is_equal_approx(float(spark0.get("alpha_scale", -1.0)), 1.0) and str(spark0.get("z", "")) == "Layer.effect" and is_equal_approx(float(spark1.get("x", -1.0)), 108.0) and is_equal_approx(float(spark1.get("y", -1.0)), 205.0) and is_equal_approx(float(spark1.get("angle", -1.0)), 90.0) and is_equal_approx(float(spark1.get("length", -1.0)), 3.5) and is_equal_approx(float(laser0.get("spark_stroke", -1.0)), 1.0) and sparks1.is_empty() and dark_sparks0.is_empty() and dark_calls[0].get("spark_stroke", 0.0) == null

	# --- Glow: found at warmup 1.0 -- region
	# glowRegion, color heatColor -> boostHeatColor
	# at boostWarmup 0.0, alpha 1.0 * (0.9 * (1 - 0.3
	# + 0.15)) = 0.765 (the glow absin reads 0.15 at
	# time 0), rotation 0, z Layer.blockAdditive,
	# additive blend. At warmup 0.0 the glow STILL
	# draws when found (Java gates on found() only,
	# not on warmup) with alpha 0.0. Not found: null.
	var glow: Dictionary = drawn.get("glow_call", {})
	var cold_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 0.0, 0.0, 0.0, true, 1.0, false, facing, lasers, {"name": "copper"}, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	var cold_glow: Dictionary = cold_drawn.get("glow_call", {})
	var no_glow_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.0, 0.0, true, 1.0, false, facing, lasers, {"name": "copper"}, false, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	proof["draw_glow"] = str(glow.get("region", "")) == "glowRegion" and str(glow.get("color", {}).get("from", "")) == "heatColor" and str(glow.get("color", {}).get("to", "")) == "boostHeatColor" and is_equal_approx(float(glow.get("color", {}).get("t", -1.0)), 0.0) and is_equal_approx(float(glow.get("alpha", -1.0)), 0.765) and is_equal_approx(float(glow.get("x", -1.0)), 100.0) and is_equal_approx(float(glow.get("y", -1.0)), 200.0) and is_equal_approx(float(glow.get("rotation", -1.0)), 0.0) and str(glow.get("z", "")) == "Layer.blockAdditive" and str(glow.get("blend", "")) == "Blending.additive" and is_equal_approx(float(cold_glow.get("alpha", -1.0)), 0.0) and no_glow_drawn.get("glow_call", {}) == null

	# --- Select: with lastItem the select call
	# records drawItemSelection(lastItem) with the
	# item; with lastItem null the select call is
	# null (drawItemSelection does nothing for a
	# null selection).
	var select_call: Dictionary = drawn.get("select_call", {})
	var no_item_drawn: Dictionary = beam_drill_build_state.source_beam_drill_draw_state(100.0, 200.0, 0, 2, 0, 1.0, 0.0, 0.0, true, 1.0, false, facing, lasers, null, true, "heatColor", "boostHeatColor", 0.3, 7.0, spark_rolls, 0.65)
	proof["draw_select"] = str(select_call.get("call", "")) == "drawItemSelection(lastItem);" and str(select_call.get("item", {}).get("name", "")) == "copper" and no_item_drawn.get("select_call", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
