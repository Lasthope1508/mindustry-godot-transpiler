extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Draw rows (N2372): MendBuild.draw()
	# (MendProjector.java:146-159), drawSelect()
	# (MendProjector.java:132-139), drawPlace()
	# (MendProjector.java:76-82) and drawLight()
	# (MendProjector.java:162-164). draw() is the cycle
	# factor (`float f = 1f - (Time.time / 100f) % 1f;`,
	# :147) + the Lod guard (`if(!Lod.l2) return;`, :149)
	# + the color blend (`Draw.color(baseColor,
	# phaseColor, phaseHeat);`, :151 -- baseColor is
	# Color.valueOf("84f491"), phaseColor is baseColor,
	# :23-24) + the top glow (`Draw.alpha(heat *
	# Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) *
	# 0.5f * Lod.alpha2);`, :152) + the top rect
	# (`Draw.rect(topRegion, x, y);`, :153 -- topRegion is
	# the `@-top` region, :25) + the square alpha
	# (`Draw.alpha(Lod.alpha2);`, :154) + the stroke
	# (`Lines.stroke((2f * f + 0.2f) * heat);`, :155) +
	# the expanding square (`Lines.square(x, y,
	# Math.min(1f + (1f - f) * size * tilesize / 2f,
	# size * tilesize/2f));`, :156), then the reset
	# (`Draw.reset();`, :158). drawSelect() is the
	# realRange fold (`float realRange = range +
	# phaseHeat * phaseRangeBoost;`, :133) + the
	# eachBlock selected highlights (`indexer.eachBlock(
	# this, realRange, other -> true, other ->
	# Drawf.selected(other, Tmp.c1.set(baseColor).a(
	# Mathf.absin(4f, 1f))));`, :135) + the dash circle
	# (`Drawf.dashCircle(x, y, realRange, baseColor);`,
	# :137). drawPlace() is the SAME baseColor dash
	# circle at the tile position (`Drawf.dashCircle(x
	# * tilesize + offset, y * tilesize + offset, range,
	# baseColor);`, :79) after `super.drawPlace(x, y,
	# rotation, valid);` (:77) + the same selected
	# highlights over the player team, so one pure serves
	# both (drawPlace passes the plain range with
	# phaseHeat 0). drawLight() is `Drawf.light(x, y,
	# lightRadius * smoothEfficiency, baseColor, 0.7f *
	# smoothEfficiency);` (:163 -- lightRadius 50f, :46;
	# neither def overrides it). The absin calls are
	# Java-exact through the shared helper at the DOUBLED
	# scale (100f / PI2 for the draw glow, 8f for the
	# select alpha): Java absin is `(sin(in, scl * 2f,
	# mag) + mag) / 2f` (Mathf.java:78-80, arc) while the
	# helper is `(sin(value / scl) * 0.5 + 0.5) * mag`,
	# so helper(v, s) == Java absin(v, s / 2f). The pures
	# return draw-call dicts; they never draw for real
	# (the SourceBlockDrawState / SourceBaseTurretDrawState
	# pattern, the N2356 ShockwaveTower precedent).
	var projector_x := 100.0
	var projector_y := 200.0

	# --- TopRegion glow alpha: heat * absin(Time.time,
	# 50f / PI2, 1f) * 0.5f * Lod.alpha2, with the color
	# blend baseColor -> phaseColor by phaseHeat. At heat
	# 1.0 and time 25.0 the absin peaks at 1.0 (Java
	# period 100 ticks: sin(25 * PI2 / 100) = sin(PI/2)
	# = 1), so the alpha is 0.5; at time 75.0 the absin
	# troughs at 0.0, so the alpha is 0.0; at heat 0 the
	# alpha is 0; at heat 0.5 and time 0.0 the absin is
	# 0.5, so the alpha is 0.125. The color lerp factor
	# is phaseHeat (0.25 here), not heat.
	var hot: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 1.0, 0.25, 1.0, 25.0)
	var hot_top: Dictionary = hot.get("top_call", {})
	var hot_color: Dictionary = hot_top.get("color", {})
	var trough: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 1.0, 0.25, 1.0, 75.0)
	var trough_top: Dictionary = trough.get("top_call", {})
	var cold: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 0.0, 0.25, 1.0, 25.0)
	var cold_top: Dictionary = cold.get("top_call", {})
	var half: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 0.5, 0.0, 1.0, 0.0)
	var half_top: Dictionary = half.get("top_call", {})
	proof["draw_top_region_alpha"] = bool(hot.get("visible", false)) and hot_top.get("region", "") == "topRegion" and hot_color.get("from", "") == "baseColor" and hot_color.get("to", "") == "phaseColor" and is_equal_approx(float(hot_color.get("t", -1.0)), 0.25) and is_equal_approx(float(hot.get("top_absin", -1.0)), 1.0) and is_equal_approx(float(hot_top.get("alpha", -1.0)), 0.5) and is_equal_approx(float(trough_top.get("alpha", -1.0)), 0.0) and is_equal_approx(float(cold_top.get("alpha", -1.0)), 0.0) and is_equal_approx(float(half_top.get("alpha", -1.0)), 0.125)

	# --- Square geometry: stroke (2f * f + 0.2f) * heat,
	# radius min(1f + (1f - f) * size * tilesize / 2f,
	# size * tilesize / 2f), alpha Lod.alpha2. At time
	# 10.0 f is 0.9, so a size-1 mender at heat 0.5 has
	# radius min(1.4, 4) = 1.4 and stroke 1.0; at time
	# 0.0 f is 1.0, so a size-2 mend-projector at heat
	# 1.0 has radius 1.0 and stroke 2.2; at time 50.0 f
	# is 0.5, so the size-2 radius is min(5, 8) = 5.0
	# and the stroke is 1.2; at time 99.0 f is 0.01, so
	# the size-1 radius clamps: min(4.96, 4) = 4.0.
	var warm: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 0.5, 0.0, 1.0, 10.0)
	var warm_square: Dictionary = warm.get("square_call", {})
	var big_start: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 1.0, 0.0, 2.0, 0.0)
	var big_start_square: Dictionary = big_start.get("square_call", {})
	var big_mid: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 1.0, 0.0, 2.0, 50.0)
	var big_mid_square: Dictionary = big_mid.get("square_call", {})
	var clamped: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 1.0, 0.0, 1.0, 99.0)
	var clamped_square: Dictionary = clamped.get("square_call", {})
	proof["draw_square_geometry"] = is_equal_approx(float(warm.get("f", -1.0)), 0.9) and is_equal_approx(float(warm_square.get("radius", -1.0)), 1.4) and is_equal_approx(float(warm_square.get("stroke", -1.0)), 1.0) and is_equal_approx(float(warm_square.get("alpha", -1.0)), 1.0) and is_equal_approx(float(big_start_square.get("radius", -1.0)), 1.0) and is_equal_approx(float(big_start_square.get("stroke", -1.0)), 2.2) and is_equal_approx(float(big_mid_square.get("radius", -1.0)), 5.0) and is_equal_approx(float(big_mid_square.get("stroke", -1.0)), 1.2) and is_equal_approx(float(clamped_square.get("radius", -1.0)), 4.0)

	# --- Lod guard: if(!Lod.l2) return -- Java draws
	# nothing when the zoom-detail gate is closed. The
	# pure reports visible false with empty calls and
	# zeroed outputs, but f is still computed (the f
	# line precedes the guard, :147 before :149). At
	# lod_alpha2 0.5 the top alpha halves (0.25 at heat
	# 1.0, time 25.0) and the square alpha is 0.5.
	var hidden: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 1.0, 0.5, 1.0, 10.0, false)
	var faded: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, 1.0, 0.5, 1.0, 25.0, true, 0.5)
	var faded_top: Dictionary = faded.get("top_call", {})
	var faded_square: Dictionary = faded.get("square_call", {})
	proof["draw_lod_guard"] = not bool(hidden.get("visible", true)) and Dictionary(hidden.get("top_call", {"x": 0})).is_empty() and Dictionary(hidden.get("square_call", {"x": 0})).is_empty() and is_equal_approx(float(hidden.get("top_alpha", -1.0)), 0.0) and is_equal_approx(float(hidden.get("f", -1.0)), 0.9) and is_equal_approx(float(faded_top.get("alpha", -1.0)), 0.25) and is_equal_approx(float(faded_square.get("alpha", -1.0)), 0.5)

	# --- drawSelect dash circle: Drawf.dashCircle(x, y,
	# realRange, baseColor) at the building x/y, with
	# realRange = range + phaseHeat * phaseRangeBoost.
	# A mender (range 40f, phaseRangeBoost 20f,
	# Blocks.java:1924/1927) at phaseHeat 0.5 has
	# realRange 50. The selected highlights ride the
	# supplied candidates (one call per candidate, alpha
	# = absin(Time.time, 4f, 1f)): at time 0.0 the alpha
	# is 0.5; at time 4 * PI it peaks at 1.0
	# (sin(4PI / 8) = sin(PI/2) = 1). A candidate
	# without x/y (or a non-Dictionary entry) is
	# excluded.
	var selected: Dictionary = mend_projector_build_state.source_mend_projector_draw_select_state(projector_x, projector_y, 40.0, 0.5, 20.0, [{"x": 110.0, "y": 210.0}, {"x": 90.0, "y": 190.0}], 0.0)
	var selected_circle: Dictionary = selected.get("dash_circle_call", {})
	var selected_calls: Array = selected.get("selected_calls", [])
	var first_selected: Dictionary = selected_calls[0] if selected_calls.size() > 0 else {}
	var peak: Dictionary = mend_projector_build_state.source_mend_projector_draw_select_state(projector_x, projector_y, 40.0, 0.0, 20.0, [{"x": 110.0, "y": 210.0}], 4.0 * PI)
	var peak_calls: Array = peak.get("selected_calls", [])
	var peak_first: Dictionary = peak_calls[0] if peak_calls.size() > 0 else {}
	var excluded: Dictionary = mend_projector_build_state.source_mend_projector_draw_select_state(projector_x, projector_y, 40.0, 0.0, 20.0, [{"x": 110.0}, "nope", {"y": 190.0}], 0.0)
	proof["draw_select_dash_circle"] = is_equal_approx(float(selected.get("real_range", -1.0)), 50.0) and is_equal_approx(float(selected_circle.get("x", -1.0)), projector_x) and is_equal_approx(float(selected_circle.get("y", -1.0)), projector_y) and is_equal_approx(float(selected_circle.get("radius", -1.0)), 50.0) and selected_circle.get("color", "") == "baseColor" and selected_calls.size() == 2 and is_equal_approx(float(first_selected.get("x", -1.0)), 110.0) and is_equal_approx(float(first_selected.get("y", -1.0)), 210.0) and first_selected.get("color", "") == "baseColor" and is_equal_approx(float(first_selected.get("alpha", -1.0)), 0.5) and is_equal_approx(float(peak.get("real_range", -1.0)), 40.0) and is_equal_approx(float(peak_first.get("alpha", -1.0)), 1.0) and Array(excluded.get("selected_calls", [{"x": 0}])).is_empty()

	# --- drawPlace dash circle: the SAME baseColor dash
	# circle, but at the tile position (x * tilesize +
	# offset, y * tilesize + offset) with the PLAIN range
	# (phaseHeat 0, so realRange collapses to range).
	# Tile (2, 3) with tilesize 8 and the size-1 offset 0
	# maps to world (16, 24) -- and the color is
	# baseColor, NOT Pal.placing (the BaseTurret drawPlace
	# color).
	var placed: Dictionary = mend_projector_build_state.source_mend_projector_draw_select_state(2.0 * 8.0, 3.0 * 8.0, 40.0, 0.0, 20.0, [], 0.0)
	var placed_circle: Dictionary = placed.get("dash_circle_call", {})
	proof["draw_place_dash_circle"] = is_equal_approx(float(placed_circle.get("x", -1.0)), 16.0) and is_equal_approx(float(placed_circle.get("y", -1.0)), 24.0) and is_equal_approx(float(placed_circle.get("radius", -1.0)), 40.0) and placed_circle.get("color", "") == "baseColor"

	# --- drawLight: Drawf.light(x, y, lightRadius *
	# smoothEfficiency, baseColor, 0.7f * smoothEfficiency)
	# with lightRadius 50f. At smoothEfficiency 0.5 the
	# radius is 25.0 and the alpha is 0.35; at 1.0 the
	# radius is 50.0 and the alpha is 0.7; at 0.0 both
	# collapse to 0 (Java still calls Drawf.light).
	var dim: Dictionary = mend_projector_build_state.source_mend_projector_draw_light_state(projector_x, projector_y, 0.5)
	var dim_light: Dictionary = dim.get("light_call", {})
	var bright: Dictionary = mend_projector_build_state.source_mend_projector_draw_light_state(projector_x, projector_y, 1.0)
	var bright_light: Dictionary = bright.get("light_call", {})
	var dark: Dictionary = mend_projector_build_state.source_mend_projector_draw_light_state(projector_x, projector_y, 0.0)
	var dark_light: Dictionary = dark.get("light_call", {})
	proof["draw_light_radius_alpha"] = is_equal_approx(float(dim.get("light_radius", -1.0)), 50.0) and is_equal_approx(float(dim_light.get("radius", -1.0)), 25.0) and is_equal_approx(float(dim_light.get("alpha", -1.0)), 0.35) and dim_light.get("color", "") == "baseColor" and is_equal_approx(float(bright_light.get("radius", -1.0)), 50.0) and is_equal_approx(float(bright_light.get("alpha", -1.0)), 0.7) and is_equal_approx(float(dark_light.get("radius", -1.0)), 0.0) and is_equal_approx(float(dark_light.get("alpha", -1.0)), 0.0)

	# --- Live frame values: a placed mender's frame heat
	# + phaseHeat + smoothEfficiency feed the draw pures.
	# The frame heat 0.5, phaseHeat 0.25 and
	# smoothEfficiency 0.5 at time 25.0 give the top
	# alpha 0.25 (0.5 * 1.0 * 0.5), the color lerp 0.25,
	# the size-1 square radius 2.0 (f 0.75) and stroke
	# 0.85, and the light radius 25.0 / alpha 0.35 -- the
	# draw pures read live frame state, they just never
	# run inside the tick.
	var mend_projector_cell := Vector2i(28, 21)
	var mend_projector := Sprite2D.new()
	game.add_child(mend_projector)
	game.call("record_placed_block", mend_projector, blocks_by_id["mender"], mend_projector_cell)
	mend_projector_build_state.source_mend_projector_bind_frame_state(mend_projector, blocks_by_id["mender"])
	var mend_projector_frame: Dictionary = mend_projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	mend_projector_frame["heat"] = 0.5
	mend_projector_frame["phase_heat"] = 0.25
	mend_projector_frame["smooth_efficiency"] = 0.5
	var mender_size: float = float(blocks_by_id["mender"].properties.get("size", 1))
	var live: Dictionary = mend_projector_build_state.source_mend_projector_draw_rows_state(projector_x, projector_y, float(mend_projector_frame.get("heat", -1.0)), float(mend_projector_frame.get("phase_heat", -1.0)), mender_size, 25.0)
	var live_top: Dictionary = live.get("top_call", {})
	var live_color: Dictionary = live_top.get("color", {})
	var live_square: Dictionary = live.get("square_call", {})
	var live_light: Dictionary = mend_projector_build_state.source_mend_projector_draw_light_state(projector_x, projector_y, float(mend_projector_frame.get("smooth_efficiency", -1.0)))
	var live_light_call: Dictionary = live_light.get("light_call", {})
	proof["draw_live_frame_values"] = is_equal_approx(float(live_top.get("alpha", -1.0)), 0.25) and is_equal_approx(float(live_color.get("t", -1.0)), 0.25) and is_equal_approx(float(live_square.get("radius", -1.0)), 2.0) and is_equal_approx(float(live_square.get("stroke", -1.0)), 0.85) and is_equal_approx(float(live_light_call.get("radius", -1.0)), 25.0) and is_equal_approx(float(live_light_call.get("alpha", -1.0)), 0.35)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
