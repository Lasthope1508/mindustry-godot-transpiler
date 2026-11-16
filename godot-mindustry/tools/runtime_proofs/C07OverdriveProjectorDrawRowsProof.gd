extends Node

const main_scene := preload("res://scenes/Main.tscn")
const overdrive_projector_build_state := preload("res://src/game/SourceOverdriveProjectorBuildState.gd")
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

	# --- Draw rows (N2435): OverdriveBuild.draw()
	# (OverdriveProjector.java:137-158), drawLight()
	# (:92-94), drawSelect() (:128-133) and
	# OverdriveProjector.drawPlace() (:54-61). draw()
	# is super.draw() + the Lod.l2 gate + f = 1 -
	# (Time.time / 100f) % 1f + the baseColor ->
	# phaseColor lerp by phaseHeat + the top rect at
	# alpha heat * absin(Time.time, 50f / PI2, 1f) *
	# 0.5f * Lod.alpha2 + the 4-point ring (the d4
	# loop with the extra point when f < 0.5f) at
	# stroke (2f * f + 0.1f) * heat. f is computed
	# AFTER the Lod guard (:140 before :142 -- the
	# reverse of MendProjector), so the pure reports
	# f 0.0 when hidden. The absin calls are
	# Java-exact through the shared helper at the
	# DOUBLED scale (100f / PI2 for draw, 8f for
	# select/place). The ring uses Geometry.d4
	# ((1,0) / (0,1) / (-1,0) / (0,-1)) with r =
	# max(0, clamp(2f - f * 2f) * size * tilesize /
	# 2f - f - 0.2f) and w = clamp(0.5f - f) * size *
	# tilesize. drawPlace uses the Block offset
	# (((size + 1) % 2) * tilesize / 2f) -- 4 for the
	# size-2 projector, 0 for the size-3 dome.
	# Pure-only: the tick never calls draw /
	# drawLight / drawSelect / drawPlace.
	var selected: Array = [{"x": 120.0, "y": 200.0}, {"x": 100.0, "y": 240.0}]

	# --- f math + top call: a projector at (100,
	# 200), size 2, range 80, phaseHeat 0.5,
	# phaseRangeBoost 20, lightRadius 50,
	# smoothEfficiency 0.5, heat 1.0, time 0.0. f =
	# 1.0, top absin 0.5 (sin(0) = 0), top alpha =
	# 1 * 0.5 * 0.5 * 1 = 0.25, color lerp
	# baseColor -> phaseColor at t 0.5, stroke =
	# (2 * 1 + 0.1) * 1 = 2.1, r = 0 (clamp(0) * 8
	# - 1 - 0.2 < 0), w = 0. At time 50 f = 0.5 and
	# the stroke is 1.1. The base call records
	# super.draw().
	var draw_zero: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 0.5, 1.0, 0.0, true, 1.0, 2.0, "baseColor", "phaseColor", selected, true)
	var zero_top: Dictionary = draw_zero.get("top_call", {})
	var zero_top_color: Dictionary = zero_top.get("color", {})
	var zero_base: Dictionary = draw_zero.get("base_call", {})
	var draw_half: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 0.5, 1.0, 50.0, true, 1.0, 2.0, "baseColor", "phaseColor", selected, true)
	proof["draw_f_top"] = is_equal_approx(float(draw_zero.get("f", -1.0)), 1.0) and is_equal_approx(float(draw_zero.get("top_absin", -1.0)), 0.5) and is_equal_approx(float(draw_zero.get("top_alpha", -1.0)), 0.25) and is_equal_approx(float(zero_top.get("alpha", -1.0)), 0.25) and str(zero_top.get("region", "")) == "topRegion" and str(zero_top_color.get("from", "")) == "baseColor" and str(zero_top_color.get("to", "")) == "phaseColor" and is_equal_approx(float(zero_top_color.get("t", -1.0)), 0.5) and is_equal_approx(float(zero_top.get("x", -1.0)), 100.0) and is_equal_approx(float(zero_top.get("y", -1.0)), 200.0) and is_equal_approx(float(draw_zero.get("stroke", -1.0)), 2.1) and is_equal_approx(float(draw_zero.get("ring_r", -1.0)), 0.0) and is_equal_approx(float(draw_zero.get("ring_w", -1.0)), 0.0) and str(zero_base.get("call", "")) == "super.draw();" and is_equal_approx(float(draw_half.get("f", -1.0)), 0.5) and is_equal_approx(float(draw_half.get("stroke", -1.0)), 1.1)

	# --- Ring points: at time 50 (f = 0.5) r =
	# clamp(1) * 8 - 0.5 - 0.2 = 7.3 and w = 0, so
	# the ring has 4 points on the axes: (107.3,
	# 200), (100, 207.3), (92.7, 200), (100, 192.7).
	# At time 75 (f = 0.25) r = clamp(1.5 -> 1) * 8
	# - 0.25 - 0.2 = 7.55 and w = clamp(0.25) * 16
	# = 4.0, so the ring has 8 points (the extra
	# point per d4 direction, f < 0.5): (107.55,
	# 196), (107.55, 204), (104, 207.55), (96,
	# 207.55), (92.45, 204), (92.45, 196), (96,
	# 192.45), (104, 192.45). The ring is closed
	# (Lines.endLine(true)) at alpha Lod.alpha2.
	var half_ring: Dictionary = draw_half.get("ring_call", {})
	var half_points: Array = half_ring.get("points", [])
	var draw_quarter: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 0.5, 1.0, 75.0, true, 1.0, 2.0, "baseColor", "phaseColor", selected, true)
	var quarter_ring: Dictionary = draw_quarter.get("ring_call", {})
	var quarter_points: Array = quarter_ring.get("points", [])
	proof["draw_ring_points"] = is_equal_approx(float(draw_half.get("ring_r", -1.0)), 7.3) and is_equal_approx(float(draw_half.get("ring_w", -1.0)), 0.0) and int(draw_half.get("ring_point_count", -1)) == 4 and half_points.size() == 4 and is_equal_approx(float(half_points[0].get("x", -1.0)), 107.3) and is_equal_approx(float(half_points[0].get("y", -1.0)), 200.0) and is_equal_approx(float(half_points[1].get("x", -1.0)), 100.0) and is_equal_approx(float(half_points[1].get("y", -1.0)), 207.3) and is_equal_approx(float(half_points[2].get("x", -1.0)), 92.7) and is_equal_approx(float(half_points[2].get("y", -1.0)), 200.0) and is_equal_approx(float(half_points[3].get("x", -1.0)), 100.0) and is_equal_approx(float(half_points[3].get("y", -1.0)), 192.7) and is_equal_approx(float(draw_quarter.get("f", -1.0)), 0.25) and is_equal_approx(float(draw_quarter.get("ring_r", -1.0)), 7.55) and is_equal_approx(float(draw_quarter.get("ring_w", -1.0)), 4.0) and int(draw_quarter.get("ring_point_count", -1)) == 8 and quarter_points.size() == 8 and is_equal_approx(float(quarter_points[0].get("x", -1.0)), 107.55) and is_equal_approx(float(quarter_points[0].get("y", -1.0)), 196.0) and is_equal_approx(float(quarter_points[1].get("x", -1.0)), 107.55) and is_equal_approx(float(quarter_points[1].get("y", -1.0)), 204.0) and is_equal_approx(float(quarter_points[2].get("x", -1.0)), 104.0) and is_equal_approx(float(quarter_points[2].get("y", -1.0)), 207.55) and is_equal_approx(float(quarter_points[3].get("x", -1.0)), 96.0) and is_equal_approx(float(quarter_points[3].get("y", -1.0)), 207.55) and is_equal_approx(float(quarter_points[4].get("x", -1.0)), 92.45) and is_equal_approx(float(quarter_points[4].get("y", -1.0)), 204.0) and is_equal_approx(float(quarter_points[5].get("x", -1.0)), 92.45) and is_equal_approx(float(quarter_points[5].get("y", -1.0)), 196.0) and is_equal_approx(float(quarter_points[6].get("x", -1.0)), 96.0) and is_equal_approx(float(quarter_points[6].get("y", -1.0)), 192.45) and is_equal_approx(float(quarter_points[7].get("x", -1.0)), 104.0) and is_equal_approx(float(quarter_points[7].get("y", -1.0)), 192.45) and is_equal_approx(float(quarter_ring.get("stroke", -1.0)), 0.6) and bool(quarter_ring.get("closed", false)) and is_equal_approx(float(quarter_ring.get("alpha", -1.0)), 1.0)

	# --- Lod.l2 gate: with lod_l2 false the draw
	# rows are hidden -- visible false, f 0.0 (Java
	# computes f AFTER the guard), top alpha 0,
	# stroke 0, r/w 0, empty top/ring calls -- but
	# the base call is still recorded (super.draw()
	# runs BEFORE the guard) and the light / select
	# / place calls still draw (no Lod gate on
	# drawLight / drawSelect / drawPlace).
	var hidden_draw: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 0.5, 1.0, 0.0, false, 1.0, 2.0, "baseColor", "phaseColor", selected, true)
	var hidden_base: Dictionary = hidden_draw.get("base_call", {})
	var hidden_light: Dictionary = hidden_draw.get("light_call", {})
	var hidden_select: Dictionary = hidden_draw.get("select_call", {})
	var hidden_place: Dictionary = hidden_draw.get("place_call", {})
	proof["draw_lod_gate"] = not bool(hidden_draw.get("visible", true)) and is_equal_approx(float(hidden_draw.get("f", -1.0)), 0.0) and is_equal_approx(float(hidden_draw.get("top_alpha", -1.0)), 0.0) and is_equal_approx(float(hidden_draw.get("stroke", -1.0)), 0.0) and is_equal_approx(float(hidden_draw.get("ring_r", -1.0)), 0.0) and is_equal_approx(float(hidden_draw.get("ring_w", -1.0)), 0.0) and int(hidden_draw.get("ring_point_count", -1)) == 0 and Dictionary(hidden_draw.get("top_call", {"x": 1})).is_empty() and Dictionary(hidden_draw.get("ring_call", {"x": 1})).is_empty() and str(hidden_base.get("call", "")) == "super.draw();" and not hidden_light.is_empty() and not hidden_select.is_empty() and not hidden_place.is_empty()

	# --- Light scaling: at smoothEfficiency 0.5
	# the light radius is 50 * 0.5 = 25 and the
	# alpha 0.7 * 0.5 = 0.35, color baseColor. At
	# smoothEfficiency 0 the light collapses to
	# radius 0 / alpha 0 (Java still calls
	# Drawf.light). At 1.0 the radius is 50 and
	# the alpha 0.7.
	var light: Dictionary = draw_zero.get("light_call", {})
	var dark_draw: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 0.0, 1.0, 0.0, true, 1.0, 2.0, "baseColor", "phaseColor", selected, true)
	var dark_light: Dictionary = dark_draw.get("light_call", {})
	var full_draw: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 1.0, 1.0, 0.0, true, 1.0, 2.0, "baseColor", "phaseColor", selected, true)
	var full_light: Dictionary = full_draw.get("light_call", {})
	proof["draw_light"] = is_equal_approx(float(light.get("radius", -1.0)), 25.0) and is_equal_approx(float(light.get("alpha", -1.0)), 0.35) and str(light.get("color", "")) == "baseColor" and is_equal_approx(float(light.get("x", -1.0)), 100.0) and is_equal_approx(float(light.get("y", -1.0)), 200.0) and is_equal_approx(float(dark_light.get("radius", -1.0)), 0.0) and is_equal_approx(float(dark_light.get("alpha", -1.0)), 0.0) and is_equal_approx(float(full_light.get("radius", -1.0)), 50.0) and is_equal_approx(float(full_light.get("alpha", -1.0)), 0.7)

	# --- Select: realRange = 80 + 0.5 * 20 = 90,
	# the dash circle at (100, 200) radius 90,
	# color baseColor, and one selected call per
	# supplied candidate at the absin alpha 0.5
	# (time 0). A non-Dictionary entry and an
	# entry missing x/y are excluded. At time 4
	# the selected alpha is (sin(0.5) + 1) / 2 =
	# 0.73971 -- the doubled-scale helper landing
	# Java's absin(4f, 1f) exactly.
	var select: Dictionary = draw_zero.get("select_call", {})
	var select_dash: Dictionary = select.get("dash_call", {})
	var select_targets: Array = select.get("selected_calls", [])
	var mixed_selected: Array = [{"x": 120.0, "y": 200.0}, "not-a-dict", {"y": 240.0}, {"x": 100.0, "y": 240.0}]
	var mixed_draw: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 0.5, 1.0, 0.0, true, 1.0, 2.0, "baseColor", "phaseColor", mixed_selected, true)
	var mixed_select: Dictionary = mixed_draw.get("select_call", {})
	var mixed_targets: Array = mixed_select.get("selected_calls", [])
	var late_draw: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 80.0, 0.5, 20.0, 50.0, 0.5, 1.0, 4.0, true, 1.0, 2.0, "baseColor", "phaseColor", selected, true)
	proof["draw_select"] = is_equal_approx(float(draw_zero.get("real_range", -1.0)), 90.0) and is_equal_approx(float(select.get("real_range", -1.0)), 90.0) and is_equal_approx(float(select_dash.get("radius", -1.0)), 90.0) and is_equal_approx(float(select_dash.get("x", -1.0)), 100.0) and is_equal_approx(float(select_dash.get("y", -1.0)), 200.0) and str(select_dash.get("color", "")) == "baseColor" and select_targets.size() == 2 and is_equal_approx(float(select_targets[0].get("x", -1.0)), 120.0) and is_equal_approx(float(select_targets[0].get("y", -1.0)), 200.0) and is_equal_approx(float(select_targets[1].get("x", -1.0)), 100.0) and is_equal_approx(float(select_targets[1].get("y", -1.0)), 240.0) and is_equal_approx(float(select_targets[0].get("alpha", -1.0)), 0.5) and str(select_targets[0].get("color", "")) == "baseColor" and is_equal_approx(float(draw_zero.get("selected_alpha", -1.0)), 0.5) and mixed_targets.size() == 2 and is_equal_approx(float(late_draw.get("selected_alpha", -1.0)), 0.73971)

	# --- Place: tile (12, 25), size 2 -- the Block
	# offset is 4, so the dash circle is at (12 * 8
	# + 4, 25 * 8 + 4) = (100, 204) with the plain
	# range 80 (no phaseHeat fold -- drawPlace uses
	# range, not realRange), color baseColor, and
	# the same selected targets. The super call is
	# recorded with the valid flag. For the size-3
	# dome the offset is 0, so the same tile draws
	# at (96, 200).
	var place: Dictionary = draw_zero.get("place_call", {})
	var place_dash: Dictionary = place.get("dash_call", {})
	var place_targets: Array = place.get("selected_calls", [])
	var dome_draw: Dictionary = overdrive_projector_build_state.source_overdrive_projector_draw_rows_state(100.0, 200.0, 12, 25, 200.0, 0.0, 20.0, 50.0, 0.5, 1.0, 0.0, true, 1.0, 3.0, "baseColor", "phaseColor", selected, false)
	var dome_place: Dictionary = dome_draw.get("place_call", {})
	var dome_dash: Dictionary = dome_place.get("dash_call", {})
	proof["draw_place"] = is_equal_approx(float(draw_zero.get("offset", -1.0)), 4.0) and is_equal_approx(float(draw_zero.get("place_x", -1.0)), 100.0) and is_equal_approx(float(draw_zero.get("place_y", -1.0)), 204.0) and is_equal_approx(float(place_dash.get("x", -1.0)), 100.0) and is_equal_approx(float(place_dash.get("y", -1.0)), 204.0) and is_equal_approx(float(place_dash.get("radius", -1.0)), 80.0) and str(place_dash.get("color", "")) == "baseColor" and place_targets.size() == 2 and str(place.get("super_call", "")) == "super.drawPlace(x, y, rotation, valid);" and bool(place.get("valid", false)) and is_equal_approx(float(place.get("offset", -1.0)), 4.0) and is_equal_approx(float(dome_draw.get("offset", -1.0)), 0.0) and is_equal_approx(float(dome_dash.get("x", -1.0)), 96.0) and is_equal_approx(float(dome_dash.get("y", -1.0)), 200.0) and is_equal_approx(float(dome_dash.get("radius", -1.0)), 200.0) and not bool(dome_place.get("valid", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07OverdriveProjectorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
