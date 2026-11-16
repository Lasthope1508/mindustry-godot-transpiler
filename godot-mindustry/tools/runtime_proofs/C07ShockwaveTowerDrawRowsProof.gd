extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
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

	# --- Draw rows (N2356): ShockwaveTowerBuild.draw()
	# (ShockwaveTower.java:126-134), drawSelect()
	# (ShockwaveTower.java:137-139) and drawPlace()
	# (ShockwaveTower.java:60-64). draw() is super.draw()
	# (:127) + the additive heatRegion glow (`Drawf.additive(
	# heatRegion, heatColor, heat, x, y, 0f,
	# Layer.blockAdditive);`, :128 -- heatRegion is the
	# `@-heat` region, :42; heatColor is Pal.turretHeat,
	# :33) + the shape poly at Layer.effect (`Draw.z(
	# Layer.effect);`, :130) with the color lerp (`Draw.color(
	# shapeColor, waveColor, Mathf.pow(heat, 2f));`, :131 --
	# shapeColor is Color.valueOf("f29c83"), waveColor is
	# Pal.accent, :33) and the poly (`Fill.poly(x, y,
	# shapeSides, shapeRadius * potentialEfficiency,
	# Time.time * shapeRotateSpeed);`, :132 -- shapeSides 4,
	# shapeRadius 6f, shapeRotateSpeed 1f, :39-40), then the
	# color reset (`Draw.color();`, :133). drawSelect() is
	# the dash circle at the building x/y (`Drawf.dashCircle(
	# x, y, range, waveColor);`, :138); drawPlace() is the
	# SAME waveColor dash circle at the tile position
	# (`Drawf.dashCircle(x * tilesize + offset, y * tilesize
	# + offset, range, waveColor);`, :63 -- NOT Pal.placing,
	# unlike the BaseTurret drawPlace), so one pure serves
	# both (the caller supplies world coords). The shape has
	# NO state advance -- the rotation is a function of
	# Time.time, which the caller supplies as time_value
	# (draw never runs in the tick, so the tick never stamps
	# it). The color lerp has NO precedent in the port's
	# draw-call dicts (BaseTurret uses flat color strings),
	# so the shape call carries it as an explicit from/to/t
	# dict. The pures return draw-call dicts; they never
	# draw for real (the SourceBlockDrawState /
	# SourceBaseTurretDrawState pattern).
	var tower_x := 100.0
	var tower_y := 200.0
	var def_range := 170.0

	# --- Heat call: the additive heatRegion glow, alpha =
	# heat. At heat 0.5 the alpha is 0.5 (region heatRegion,
	# color heatColor, rotation 0, layer Layer.blockAdditive);
	# at heat 0 the alpha is 0 (the glow is invisible); at
	# heat 1 the alpha is 1.
	var warm: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_state(tower_x, tower_y, 0.5, 1.0, 10.0)
	var warm_heat: Dictionary = warm.get("heat_call", {})
	var cold: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_state(tower_x, tower_y, 0.0, 1.0, 10.0)
	var cold_heat: Dictionary = cold.get("heat_call", {})
	var hot: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_state(tower_x, tower_y, 1.0, 1.0, 10.0)
	var hot_heat: Dictionary = hot.get("heat_call", {})
	proof["draw_heat_call_additive"] = bool(warm.get("super_draw_called", false)) and warm_heat.get("region", "") == "heatRegion" and warm_heat.get("color", "") == "heatColor" and is_equal_approx(float(warm_heat.get("alpha", -1.0)), 0.5) and is_equal_approx(float(warm_heat.get("x", -1.0)), tower_x) and is_equal_approx(float(warm_heat.get("y", -1.0)), tower_y) and is_equal_approx(float(warm_heat.get("rotation", -1.0)), 0.0) and warm_heat.get("layer", "") == "Layer.blockAdditive" and is_equal_approx(float(cold_heat.get("alpha", -1.0)), 0.0) and is_equal_approx(float(hot_heat.get("alpha", -1.0)), 1.0)

	# --- Shape poly geometry: 4 sides, radius shapeRadius *
	# potentialEfficiency, rotation Time.time *
	# shapeRotateSpeed. At potentialEfficiency 1.0 and time
	# 10.0 the radius is 6.0 and the rotation is 10.0; at
	# potentialEfficiency 0.5 the radius is 3.0; at
	# potentialEfficiency 0 the radius is 0 (the poly
	# collapses -- Java still calls Fill.poly with radius 0).
	var warm_shape: Dictionary = warm.get("shape_call", {})
	var half: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_state(tower_x, tower_y, 0.5, 0.5, 10.0)
	var half_shape: Dictionary = half.get("shape_call", {})
	var dead: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_state(tower_x, tower_y, 0.5, 0.0, 10.0)
	var dead_shape: Dictionary = dead.get("shape_call", {})
	proof["draw_shape_poly_geometry"] = int(warm_shape.get("sides", -1)) == 4 and is_equal_approx(float(warm_shape.get("radius", -1.0)), 6.0) and is_equal_approx(float(warm_shape.get("rotation", -1.0)), 10.0) and warm_shape.get("z", "") == "Layer.effect" and is_equal_approx(float(half_shape.get("radius", -1.0)), 3.0) and is_equal_approx(float(dead_shape.get("radius", -1.0)), 0.0)

	# --- Shape color lerp: Draw.color(shapeColor, waveColor,
	# Mathf.pow(heat, 2f)) -- the lerp factor is heat SQUARED,
	# not heat. At heat 0.5 the factor is 0.25 (25% toward
	# waveColor); at heat 1 it is 1.0 (fully waveColor); at
	# heat 0 it is 0.0 (fully shapeColor).
	var warm_color: Dictionary = warm_shape.get("color", {})
	var hot_shape: Dictionary = hot.get("shape_call", {})
	var hot_color: Dictionary = hot_shape.get("color", {})
	var cold_shape: Dictionary = cold.get("shape_call", {})
	var cold_color: Dictionary = cold_shape.get("color", {})
	proof["draw_shape_color_lerp"] = warm_color.get("from", "") == "shapeColor" and warm_color.get("to", "") == "waveColor" and is_equal_approx(float(warm_color.get("t", -1.0)), 0.25) and is_equal_approx(float(hot_color.get("t", -1.0)), 1.0) and is_equal_approx(float(cold_color.get("t", -1.0)), 0.0)

	# --- drawSelect dash circle: Drawf.dashCircle(x, y,
	# range, waveColor) at the building x/y and the def range
	# (170f, Blocks.java:2043 -- the class default is 110f,
	# ShockwaveTower.java:25).
	var selected: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_select_state(tower_x, tower_y, def_range)
	var selected_circle: Dictionary = selected.get("dash_circle_call", {})
	proof["draw_select_dash_circle"] = is_equal_approx(float(selected_circle.get("x", -1.0)), tower_x) and is_equal_approx(float(selected_circle.get("y", -1.0)), tower_y) and is_equal_approx(float(selected_circle.get("radius", -1.0)), def_range) and selected_circle.get("color", "") == "waveColor"

	# --- drawPlace dash circle: the SAME waveColor dash
	# circle, but at the tile position (x * tilesize +
	# offset, y * tilesize + offset). Tile (2, 3) with
	# tilesize 8 and the size-3 offset 0 maps to world
	# (16, 24) -- and the color is waveColor, NOT
	# Pal.placing (the BaseTurret drawPlace color).
	var placed: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_select_state(2.0 * 8.0, 3.0 * 8.0, def_range)
	var placed_circle: Dictionary = placed.get("dash_circle_call", {})
	proof["draw_place_dash_circle_wave_color"] = is_equal_approx(float(placed_circle.get("x", -1.0)), 16.0) and is_equal_approx(float(placed_circle.get("y", -1.0)), 24.0) and is_equal_approx(float(placed_circle.get("radius", -1.0)), def_range) and placed_circle.get("color", "") == "waveColor"

	# --- Live frame values: a placed tower's frame heat +
	# potentialEfficiency feed the draw pure. The frame heat
	# 0.5 and potentialEfficiency 1.0 at time 10.0 give the
	# same shape the pure call gives (radius 6.0, rotation
	# 10.0, lerp 0.25) and the same heat alpha (0.5) -- the
	# draw pure reads live frame state, it just never runs
	# inside the tick.
	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	shockwave_tower_frame["heat"] = 0.5
	shockwave_tower_frame["potential_efficiency"] = 1.0
	var live: Dictionary = shockwave_tower_build_state.source_shockwave_tower_draw_state(tower_x, tower_y, float(shockwave_tower_frame.get("heat", -1.0)), float(shockwave_tower_frame.get("potential_efficiency", -1.0)), 10.0)
	var live_heat: Dictionary = live.get("heat_call", {})
	var live_shape: Dictionary = live.get("shape_call", {})
	var live_color: Dictionary = live_shape.get("color", {})
	proof["draw_live_frame_values"] = is_equal_approx(float(live_heat.get("alpha", -1.0)), 0.5) and is_equal_approx(float(live_shape.get("radius", -1.0)), 6.0) and is_equal_approx(float(live_shape.get("rotation", -1.0)), 10.0) and is_equal_approx(float(live_color.get("t", -1.0)), 0.25)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
