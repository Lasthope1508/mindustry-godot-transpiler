extends Node

const main_scene := preload("res://scenes/Main.tscn")
const light_block_build_state := preload("res://src/game/SourceLightBlockBuildState.gd")
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

	# --- Draw rows (N2374): LightBuild.draw()
	# (LightBlock.java:96-102) and drawLight()
	# (LightBlock.java:126-128). draw() is super.draw()
	# (:97) + the color set (`Draw.color(Tmp.c1.set(color)
	# .a(0.6f));`, :98 -- the config color, `public int
	# color = Pal.accent.rgba();`, :68, at alpha 0.6f) +
	# the top rect (`Draw.rect(topRegion, x, y);`, :99 --
	# topRegion is the `@-top` region, :24) + the color
	# reset (`Draw.color();`, :100). drawLight() is the
	# emitted light (`Drawf.light(x, y, lightRadius *
	# Math.min(smoothTime, 2f), Tmp.c1.set(color),
	# brightness * efficiency);`, :127 -- lightRadius is
	# radius*2.5f, :40; brightness 0.9f / radius 200f are
	# the class defaults, :22-23, overridden by the
	# illuminator def to 0.75f / 140f,
	# Blocks.java:6765-6766). There is NO drawSelect:
	# LightBuild overrides draw / drawLight / updateTile
	# only (verified by reading LightBlock.java in full).
	# The pures return draw-call dicts; they never draw
	# for real (the N2356 ShockwaveTower pattern). The
	# color is an explicit param (the color config waits
	# for its own slice); lightRadius / brightness are
	# caller-supplied so the pures stay def-agnostic.
	var block_x := 100.0
	var block_y := 200.0
	# An arbitrary fixture color int (the pure echoes the
	# config color; the config itself waits for its own
	# slice -- this value makes no claim about Pal.accent).
	var fixture_color := 0xFFAA33FF

	# --- Top region rect: Draw.rect(topRegion, x, y) at
	# the building x/y, after super.draw(). The call
	# records the region name topRegion (the `@-top`
	# region, LightBlock.java:24).
	var drawn: Dictionary = light_block_build_state.source_light_block_draw_state(block_x, block_y, fixture_color)
	var top_call: Dictionary = drawn.get("top_call", {})
	proof["draw_top_region_rect"] = bool(drawn.get("super_draw_called", false)) and top_call.get("region", "") == "topRegion" and is_equal_approx(float(top_call.get("x", -1.0)), block_x) and is_equal_approx(float(top_call.get("y", -1.0)), block_y) and top_call.get("call", "") == "Draw.rect(topRegion, x, y);"

	# --- Color alpha: Draw.color(Tmp.c1.set(color)
	# .a(0.6f)) -- the config color at alpha 0.6f, NOT
	# 1.0 and NOT the 0.5f picker alpha
	# (buildConfiguration, LightBlock.java:112). The rect
	# call carries the echoed color int and the 0.6 alpha.
	proof["draw_color_alpha_06"] = int(top_call.get("color", -1)) == fixture_color and is_equal_approx(float(top_call.get("alpha", -1.0)), 0.6) and drawn.get("color_expr", "") == "Draw.color(Tmp.c1.set(color).a(0.6f));" and drawn.get("reset_expr", "") == "Draw.color();"

	# --- Light radius clamp: Drawf.light(x, y,
	# lightRadius * Math.min(smoothTime, 2f), ...) -- the
	# radius is lightRadius * smoothTime, clamped at
	# lightRadius * 2f. At smoothTime 1.0 with lightRadius
	# 500.0 (the class default radius 200f * 2.5f) the
	# radius is 500.0; at smoothTime 3.0 it clamps to
	# 1000.0; at smoothTime 0.5 it is 250.0.
	var lit: Dictionary = light_block_build_state.source_light_block_draw_light_state(block_x, block_y, fixture_color, 1.0, 500.0, 0.9, 1.0)
	var lit_call: Dictionary = lit.get("light_call", {})
	var lit_hot: Dictionary = light_block_build_state.source_light_block_draw_light_state(block_x, block_y, fixture_color, 3.0, 500.0, 0.9, 1.0)
	var lit_hot_call: Dictionary = lit_hot.get("light_call", {})
	var lit_low: Dictionary = light_block_build_state.source_light_block_draw_light_state(block_x, block_y, fixture_color, 0.5, 500.0, 0.9, 1.0)
	var lit_low_call: Dictionary = lit_low.get("light_call", {})
	proof["draw_light_radius_clamp"] = is_equal_approx(float(lit_call.get("radius", -1.0)), 500.0) and is_equal_approx(float(lit.get("light_radius_scale", -1.0)), 1.0) and is_equal_approx(float(lit_hot_call.get("radius", -1.0)), 1000.0) and is_equal_approx(float(lit_hot.get("light_radius_scale", -1.0)), 2.0) and is_equal_approx(float(lit_low_call.get("radius", -1.0)), 250.0) and is_equal_approx(float(lit_low.get("light_radius_scale", -1.0)), 0.5)

	# --- Light brightness: brightness * efficiency --
	# the emitted light scales by the folded efficiency,
	# so an unpowered illuminator emits at brightness 0
	# (the N2185 fold). At brightness 0.9 and efficiency
	# 1.0 the brightness is 0.9; at efficiency 0 it is 0;
	# at efficiency 0.5 it is 0.45. The light color is
	# the config color at full alpha (Tmp.c1.set(color)
	# with NO .a() call -- unlike the 0.6f draw alpha).
	proof["draw_light_brightness_efficiency"] = is_equal_approx(float(lit_call.get("brightness", -1.0)), 0.9) and int(lit_call.get("color", -1)) == fixture_color and is_equal_approx(float(lit_call.get("x", -1.0)), block_x) and is_equal_approx(float(lit_call.get("y", -1.0)), block_y)
	var lit_dead: Dictionary = light_block_build_state.source_light_block_draw_light_state(block_x, block_y, fixture_color, 1.0, 500.0, 0.9, 0.0)
	var lit_dead_call: Dictionary = lit_dead.get("light_call", {})
	var lit_half: Dictionary = light_block_build_state.source_light_block_draw_light_state(block_x, block_y, fixture_color, 1.0, 500.0, 0.9, 0.5)
	var lit_half_call: Dictionary = lit_half.get("light_call", {})
	proof["draw_light_brightness_efficiency"] = bool(proof["draw_light_brightness_efficiency"]) and is_equal_approx(float(lit_dead_call.get("brightness", -1.0)), 0.0) and is_equal_approx(float(lit_half_call.get("brightness", -1.0)), 0.45)

	# --- Def values: the illuminator def overrides
	# brightness to 0.75f and radius to 140f
	# (Blocks.java:6765-6766), so lightRadius is
	# 140 * 2.5 = 350. At smoothTime 1.0 and efficiency
	# 1.0 the radius is 350.0 and the brightness is 0.75.
	var def_lit: Dictionary = light_block_build_state.source_light_block_draw_light_state(block_x, block_y, fixture_color, 1.0, 350.0, 0.75, 1.0)
	var def_lit_call: Dictionary = def_lit.get("light_call", {})
	proof["draw_light_def_values"] = is_equal_approx(float(def_lit_call.get("radius", -1.0)), 350.0) and is_equal_approx(float(def_lit_call.get("brightness", -1.0)), 0.75) and is_equal_approx(float(blocks_by_id["illuminator"].properties.get("consumePower", -1.0)), 0.05)

	# --- Live frame values: a placed illuminator's frame
	# smooth_time + efficiency feed the draw-light pure.
	# The frame smooth_time 1.5 and efficiency 0.5 with
	# the def lightRadius 350.0 and brightness 0.75 give
	# radius 525.0 and brightness 0.375 -- the draw-light
	# pure reads live frame state, it just never runs
	# inside the tick.
	var light_block_cell := Vector2i(28, 21)
	var light_block := Sprite2D.new()
	game.add_child(light_block)
	game.call("record_placed_block", light_block, blocks_by_id["illuminator"], light_block_cell)
	light_block_build_state.source_light_block_bind_frame_state(light_block, blocks_by_id["illuminator"])
	var light_block_frame: Dictionary = light_block.get_meta(light_block_build_state.SOURCE_LIGHT_BLOCK_BUILDING_META_KEY, {})
	light_block_frame["smooth_time"] = 1.5
	light_block_frame["efficiency"] = 0.5
	var live: Dictionary = light_block_build_state.source_light_block_draw_light_state(block_x, block_y, fixture_color, float(light_block_frame.get("smooth_time", -1.0)), 350.0, 0.75, float(light_block_frame.get("efficiency", -1.0)))
	var live_call: Dictionary = live.get("light_call", {})
	proof["draw_live_frame_values"] = is_equal_approx(float(live_call.get("radius", -1.0)), 525.0) and is_equal_approx(float(live_call.get("brightness", -1.0)), 0.375) and is_equal_approx(float(live.get("light_radius_scale", -1.0)), 1.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LightBlockDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
