extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- BurstDrillBuild.draw() OVERRIDE (N2314):
	# BurstDrillBuild.draw() (BurstDrill.java:133-180,
	# `public void draw(){`): `Draw.rect(region, x, y);`
	# (:134), `drawDefaultCracks();` (:135),
	# `Draw.rect(topRegion, x, y);` (:137),
	# `if(invertTime > 0 && topInvertRegion.found()){`
	# (:139) with `Draw.alpha(Interp.pow3Out.apply(
	# invertTime));` (:140) and `Draw.rect(
	# topInvertRegion, x, y);` (:141),
	# `if(dominantItem != null && drawMineItem){`
	# (:145) with `Draw.color(dominantItem.color);`
	# (:146) and `Draw.rect(itemRegion, x, y);` (:147),
	# `float fract = smoothProgress;` (:151),
	# `Draw.color(arrowColor);` (:152), the 4-direction
	# arrow ring (:153-173): `float arrowFract =
	# (arrows - 1 - j);` (:155), `float a =
	# Mathf.clamp(fract * arrows - arrowFract);` (:156),
	# `Tmp.v1.trns(i * 90 + 45, j * arrowSpacing +
	# arrowOffset);` (:157), `Draw.z(Layer.block);`
	# (:159), `Draw.color(baseArrowColor, arrowColor, a);`
	# (:160), `Draw.rect(arrowRegion, x + Tmp.v1.x, y +
	# Tmp.v1.y, i * 90);` (:161), blur `if(
	# arrowBlurRegion.found()){` (:165) with
	# `Draw.z(Layer.blockAdditive);` (:166),
	# `Draw.blend(Blending.additive);` (:167),
	# `Draw.alpha(Mathf.pow(a, 10f));` (:168) and
	# `Draw.rect(arrowBlurRegion, x + Tmp.v1.x, y +
	# Tmp.v1.y, i * 90);` (:169), then `Draw.color();`
	# (:174) and `if(glowRegion.found()){` (:177) with
	# `Drawf.additive(glowRegion, Tmp.c2.set(glowColor)
	# .a(Mathf.pow(fract, 3f) * glowColor.a), x, y);`
	# (:178). The DrillBuild.draw() BASE (Drill.java:
	# 346-379) is a LATER slice (N2317), NOT this one.
	# drawDefaultCracks() (Drill.java:341-343) is a
	# callee (D5): its result rides in as an explicit
	# param. There is NO driver tick line: draw() is
	# per-frame render state (the N2341 lifecycle
	# precedent).

	# Per-def inputs (Blocks.java): impact-drill
	# `size = 4;` (:3073) uses class defaults (arrows 3,
	# arrowSpacing 4f, arrowOffset 0f, glowColor.a 1.0);
	# eruption-drill `size = 5;` (:3096) overrides
	# `arrowOffset = 2f;` (:3108), `arrowSpacing = 5f;`
	# (:3109), `arrows = 2;` (:3110),
	# `glowColor.a = 0.6f;` (:3111). Class defaults
	# (BurstDrill.java:26-30): `public int arrows = 3;`,
	# `public Color arrowColor = Color.valueOf("feb380"),
	# baseArrowColor = Color.valueOf("6e7080");`,
	# `public Color glowColor = arrowColor.cpy();`.
	var arrow_color := Color("feb380")
	var base_arrow_color := Color("6e7080")
	var glow_color := Color("feb380")
	var eruption_glow_color := Color("feb380")
	eruption_glow_color.a = 0.6
	var dominant_color := Color("d8a24a")
	var cracks := {"cracks": ["crack-1", "crack-2"]}

	# Impact-drill at (100, 200), fract 0.5, no invert,
	# no dominant item.
	var impact: Dictionary = burst_drill_build_state.source_burst_drill_draw_state(100.0, 200.0, "impact-drill", "impact-drill-top", "copper", "impact-drill-arrow", "impact-drill-arrow-blur", "impact-drill-glow", "impact-drill-top-invert", 0.0, 0.5, false, dominant_color, true, 3, 4.0, 0.0, arrow_color, base_arrow_color, glow_color, true, true, true, cracks)

	# Base rect: the block region at the building position.
	var base_rect: Dictionary = impact.get("base_rect", {})
	proof["draw_base_rect"] = String(base_rect.get("region", "")) == "impact-drill" and is_equal_approx(float(base_rect.get("x", -1.0)), 100.0) and is_equal_approx(float(base_rect.get("y", -1.0)), 200.0)

	# Top rect: the Drill top region at the same position.
	var top_rect: Dictionary = impact.get("top_rect", {})
	proof["draw_top_rect"] = String(top_rect.get("region", "")) == "impact-drill-top" and is_equal_approx(float(top_rect.get("x", -1.0)), 100.0) and is_equal_approx(float(top_rect.get("y", -1.0)), 200.0)

	# Cracks: the callee result passes through unchanged.
	proof["draw_cracks_passthrough"] = impact.get("cracks", {}) == cracks

	# Invert overlay: visible at invertTime 0.5 with
	# alpha pow3Out(0.5) = 1 - (1 - 0.5)^3 = 0.875;
	# hidden at invertTime 0 (alpha 0, rect null).
	var invert: Dictionary = burst_drill_build_state.source_burst_drill_draw_state(100.0, 200.0, "impact-drill", "impact-drill-top", "copper", "impact-drill-arrow", "impact-drill-arrow-blur", "impact-drill-glow", "impact-drill-top-invert", 0.5, 0.5, false, dominant_color, true, 3, 4.0, 0.0, arrow_color, base_arrow_color, glow_color, true, true, true, cracks)
	var invert_rect: Dictionary = invert.get("invert_rect", {})
	proof["draw_invert"] = bool(invert.get("invert_visible", false)) == true and is_equal_approx(float(invert.get("invert_alpha", -1.0)), 0.875) and String(invert_rect.get("region", "")) == "impact-drill-top-invert" and is_equal_approx(float(invert_rect.get("alpha", -1.0)), 0.875) and bool(impact.get("invert_visible", true)) == false and is_equal_approx(float(impact.get("invert_alpha", -1.0)), 0.0) and impact.get("invert_rect", {}) == null

	# Mine-item overlay: visible with a dominant item
	# and drawMineItem, in the dominant item color;
	# hidden without a dominant item.
	var mine: Dictionary = burst_drill_build_state.source_burst_drill_draw_state(100.0, 200.0, "impact-drill", "impact-drill-top", "copper", "impact-drill-arrow", "impact-drill-arrow-blur", "impact-drill-glow", "impact-drill-top-invert", 0.0, 0.5, true, dominant_color, true, 3, 4.0, 0.0, arrow_color, base_arrow_color, glow_color, true, true, true, cracks)
	var mine_rect: Dictionary = mine.get("mine_item_rect", {})
	var mine_rect_color: Color = mine_rect.get("color", Color.BLACK)
	proof["draw_mine_item"] = bool(mine.get("mine_item_visible", false)) == true and String(mine_rect.get("region", "")) == "copper" and mine_rect_color.is_equal_approx(dominant_color) and bool(impact.get("mine_item_visible", true)) == false and impact.get("mine_item_rect", {}) == null

	# fract = smoothProgress.
	proof["draw_fract"] = is_equal_approx(float(impact.get("fract", -1.0)), 0.5)

	# Arrow counts: 4 directions x arrows -- 12 impact
	# (arrows 3), 8 eruption (arrows 2).
	var eruption: Dictionary = burst_drill_build_state.source_burst_drill_draw_state(100.0, 200.0, "eruption-drill", "eruption-drill-top", "copper", "eruption-drill-arrow", "eruption-drill-arrow-blur", "eruption-drill-glow", "eruption-drill-top-invert", 0.0, 0.5, false, dominant_color, true, 2, 5.0, 2.0, arrow_color, base_arrow_color, eruption_glow_color, true, true, true, cracks)
	var impact_arrows: Array = impact.get("arrows", [])
	var eruption_arrows: Array = eruption.get("arrows", [])
	proof["draw_arrow_count"] = int(impact.get("arrow_count", -1)) == 12 and impact_arrows.size() == 12 and int(eruption.get("arrow_count", -1)) == 8 and eruption_arrows.size() == 8

	# First arrow (i=0, j=0) at fract 1.0: angle 45 deg,
	# distance 0 * spacing + offset = 0, so it sits at
	# (100, 200); alpha clamp(1*3 - 2) = 1, rotation 0,
	# color fully lerped to arrowColor.
	var full: Dictionary = burst_drill_build_state.source_burst_drill_draw_state(100.0, 200.0, "impact-drill", "impact-drill-top", "copper", "impact-drill-arrow", "impact-drill-arrow-blur", "impact-drill-glow", "impact-drill-top-invert", 0.0, 1.0, false, dominant_color, true, 3, 4.0, 0.0, arrow_color, base_arrow_color, glow_color, true, true, true, cracks)
	var full_arrows: Array = full.get("arrows", [])
	var first: Dictionary = full_arrows[0]
	var first_color: Color = first.get("color", Color.BLACK)
	proof["draw_arrow_first"] = is_equal_approx(float(first.get("x", -1.0)), 100.0) and is_equal_approx(float(first.get("y", -1.0)), 200.0) and is_equal_approx(float(first.get("alpha", -1.0)), 1.0) and is_equal_approx(float(first.get("rotation_deg", -1.0)), 0.0) and first_color.is_equal_approx(arrow_color)

	# Alpha clamping at fract 0.5: j=0 (arrowFract 2)
	# gives clamp(1.5 - 2) = 0, j=2 (arrowFract 0) gives
	# clamp(1.5 - 0) = 1 (clamped from 1.5).
	var alpha_zero: Dictionary = impact_arrows[0]
	var alpha_one: Dictionary = impact_arrows[2]
	proof["draw_arrow_alpha_clamp"] = is_equal_approx(float(alpha_zero.get("alpha", -1.0)), 0.0) and is_equal_approx(float(alpha_one.get("alpha", -1.0)), 1.0)

	# Arrow position (i=1, j=1) at fract 1.0: angle 135
	# deg, distance 1*4 + 0 = 4, so (100 + cos135*4,
	# 200 + sin135*4) = (100 - 2.828, 200 + 2.828),
	# rotation 90.
	var positioned: Dictionary = full_arrows[4]
	proof["draw_arrow_position"] = is_equal_approx(float(positioned.get("x", -1.0)), 97.17157287525381) and is_equal_approx(float(positioned.get("y", -1.0)), 202.8284271247462) and is_equal_approx(float(positioned.get("rotation_deg", -1.0)), 90.0)

	# Blur: visible with the blur region, alpha
	# pow(a, 10) = 1 at a = 1, z 30 / blur z 31, blur
	# blend additive; hidden without the region (alpha 0).
	var no_blur: Dictionary = burst_drill_build_state.source_burst_drill_draw_state(100.0, 200.0, "impact-drill", "impact-drill-top", "copper", "impact-drill-arrow", "impact-drill-arrow-blur", "impact-drill-glow", "impact-drill-top-invert", 0.0, 1.0, false, dominant_color, true, 3, 4.0, 0.0, arrow_color, base_arrow_color, glow_color, true, false, true, cracks)
	var no_blur_arrows: Array = no_blur.get("arrows", [])
	var no_blur_first: Dictionary = no_blur_arrows[0]
	proof["draw_arrow_blur"] = bool(first.get("blur_visible", false)) == true and is_equal_approx(float(first.get("blur_alpha", -1.0)), 1.0) and int(first.get("z", -1)) == 30 and int(first.get("blur_z", -1)) == 31 and String(first.get("blur_blend", "")) == "additive" and bool(no_blur_first.get("blur_visible", true)) == false and is_equal_approx(float(no_blur_first.get("blur_alpha", -1.0)), 0.0)

	# Glow: alpha pow(fract, 3) * glowColor.a -- 0.125
	# impact (a 1.0) and 0.075 eruption (a 0.6) at fract
	# 0.5; hidden when the glow region is missing.
	var no_glow: Dictionary = burst_drill_build_state.source_burst_drill_draw_state(100.0, 200.0, "impact-drill", "impact-drill-top", "copper", "impact-drill-arrow", "impact-drill-arrow-blur", "impact-drill-glow", "impact-drill-top-invert", 0.0, 0.5, false, dominant_color, true, 3, 4.0, 0.0, arrow_color, base_arrow_color, glow_color, true, true, false, cracks)
	var impact_glow_color: Color = impact.get("glow_color", Color.BLACK)
	var eruption_glow_color_value: Color = eruption.get("glow_color", Color.BLACK)
	proof["draw_glow"] = bool(impact.get("glow_visible", false)) == true and is_equal_approx(float(impact.get("glow_alpha", -1.0)), 0.125) and is_equal_approx(float(impact_glow_color.a), 0.125) and is_equal_approx(float(eruption.get("glow_alpha", -1.0)), 0.075) and is_equal_approx(float(eruption_glow_color_value.a), 0.075) and bool(no_glow.get("glow_visible", true)) == false and is_equal_approx(float(no_glow.get("glow_alpha", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
