extends Node

const main_scene := preload("res://scenes/Main.tscn")
const drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- DrillBuild.draw() BASE (N2325):
	# DrillBuild.draw() (Drill.java:346-379,
	# `public void draw(){`): `float s = 0.3f;` (:347),
	# `float ts = 0.6f;` (:348), `Draw.rect(region, x,
	# y);` (:350), `Draw.z(Layer.blockCracks);` (:351),
	# `drawDefaultCracks();` (:352), `Draw.z(Layer.
	# blockAfterCracks);` (:354), `if(drawRim){`
	# (:355) with `Draw.color(heatColor);` (:356),
	# `Draw.alpha(warmup * ts * (1f - s + Mathf.absin(
	# Time.time, 3f, s)));` (:357), `Draw.blend(
	# Blending.additive);` (:358) and `Draw.rect(
	# rimRegion, x, y);` (:359), `if(drawSpinSprite){`
	# (:364) with `Drawf.spinSprite(rotatorRegion, x,
	# y, timeDrilled * rotateSpeed);` (:365), else
	# `Draw.rect(rotatorRegion, x, y, timeDrilled *
	# rotateSpeed);` (:367), `Draw.rect(topRegion, x,
	# y);` (:370), `if(dominantItem != null &&
	# drawMineItem){` (:372) with `Draw.color(
	# dominantItem.color);` (:373) and `Draw.rect(
	# itemRegion, x, y);` (:374). drawCracks()
	# (Drill.java:339) is an empty override (`public
	# void drawCracks(){}`); the cracks come only from
	# drawDefaultCracks() (Drill.java:341-343, `super.
	# drawCracks();`) over BuildingComp.drawCracks()
	# (BuildingComp.java:1231-1239): the guard `if(!
	# block.drawCracks || !damaged() || block.size >
	# BlockRenderer.maxCrackSize) return;`, `int id =
	# pos();`, the crack region `renderer.blocks.cracks
	# [block.size - 1][Mathf.clamp((int)((1f -
	# healthf()) * BlockRenderer.crackRegions), 0,
	# BlockRenderer.crackRegions-1)]`, `Draw.colorl(
	# 0.2f, 0.1f + (1f - healthf())* 0.6f);`, `Draw.rect(
	# region, x, y, (id%4)*90);`. The BurstDrillBuild.
	# draw() OVERRIDE is N2314, NOT this slice. There
	# is NO driver tick line: draw() is per-frame
	# render state (the N2283 lifecycle precedent).

	# Per-def inputs (Blocks.java): mechanical-drill
	# and pneumatic-drill `size = 2;`, laser-drill
	# `size = 3;`, blast-drill `size = 4;` with
	# `drawRim = true;` and `rotateSpeed = 6f;` (class
	# default `rotateSpeed = 2f;`). Class defaults
	# (Drill.java:59,68-70): `public float rotateSpeed
	# = 2f;`, `public boolean drawRim = false;`,
	# `public boolean drawSpinSprite = true;`,
	# `public Color heatColor = Color.valueOf(
	# "ff5512");`.
	var heat_color := Color("ff5512")
	var dominant_color := Color("d8a24a")
	var crack_regions: Array = ["crack-0", "crack-1", "crack-2", "crack-3", "crack-4", "crack-5", "crack-6", "crack-7"]

	# Mechanical-drill at (100, 200), damaged at
	# healthf 0.5, pos 5, no rim, spin rotator.
	var mech: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "mechanical-drill", "mechanical-drill-rim", "mechanical-drill-rotator", "mechanical-drill-top", "copper", true, true, 2, 0.5, 5, crack_regions, false, heat_color, 0.0, 0.0, true, 15.0, 2.0, 1.0, false, dominant_color, true)

	# Base rect: the block region at the building position.
	var base_rect: Dictionary = mech.get("base_rect", {})
	proof["draw_base_rect"] = String(base_rect.get("region", "")) == "mechanical-drill" and is_equal_approx(float(base_rect.get("x", -1.0)), 100.0) and is_equal_approx(float(base_rect.get("y", -1.0)), 200.0)

	# Cracks: guard passes (drawCracks on, damaged,
	# size 2 <= 7); index clamp(int((1 - 0.5) * 8), 0,
	# 7) = 4, rotation (5 % 4) * 90 = 90, colorl
	# lightness 0.2 alpha 0.1 + 0.5 * 0.6 = 0.4.
	var cracks: Dictionary = mech.get("cracks", {})
	proof["draw_cracks"] = String(cracks.get("region", "")) == "crack-4" and is_equal_approx(float(cracks.get("x", -1.0)), 100.0) and is_equal_approx(float(cracks.get("y", -1.0)), 200.0) and is_equal_approx(float(cracks.get("rotation_deg", -1.0)), 90.0) and is_equal_approx(float(cracks.get("color_lightness", -1.0)), 0.2) and is_equal_approx(float(cracks.get("color_alpha", -1.0)), 0.4) and int(cracks.get("crack_index", -1)) == 4

	# Cracks guard: hidden when undamaged, when
	# block.drawCracks is false, and when size 8 > 7.
	var undamaged: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "mechanical-drill", "mechanical-drill-rim", "mechanical-drill-rotator", "mechanical-drill-top", "copper", true, false, 2, 1.0, 5, crack_regions, false, heat_color, 0.0, 0.0, true, 15.0, 2.0, 1.0, false, dominant_color, true)
	var no_crack_flag: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "mechanical-drill", "mechanical-drill-rim", "mechanical-drill-rotator", "mechanical-drill-top", "copper", false, true, 2, 0.5, 5, crack_regions, false, heat_color, 0.0, 0.0, true, 15.0, 2.0, 1.0, false, dominant_color, true)
	var too_big: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "mechanical-drill", "mechanical-drill-rim", "mechanical-drill-rotator", "mechanical-drill-top", "copper", true, true, 8, 0.5, 5, crack_regions, false, heat_color, 0.0, 0.0, true, 15.0, 2.0, 1.0, false, dominant_color, true)
	proof["draw_cracks_guard"] = undamaged.get("cracks", {}) == null and no_crack_flag.get("cracks", {}) == null and too_big.get("cracks", {}) == null

	# Rim: blast-drill, drawRim true, warmup 1.0.
	# absin(0, 3, 0.3) = (sin(0) * 0.3 + 0.3) / 2 =
	# 0.15, so rim alpha = 1 * 0.6 * (0.7 + 0.15) =
	# 0.51; at time 3*PI absin = (sin(PI/2) * 0.3 +
	# 0.3) / 2 = 0.3, so rim alpha = 0.6 * 1.0 = 0.6.
	# Hidden without drawRim (alpha 0, rect null).
	var rim: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "blast-drill", "blast-drill-rim", "blast-drill-rotator", "blast-drill-top", "copper", true, true, 4, 0.5, 5, crack_regions, true, heat_color, 1.0, 0.0, true, 15.0, 6.0, 1.0, false, dominant_color, true)
	var rim_late: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "blast-drill", "blast-drill-rim", "blast-drill-rotator", "blast-drill-top", "copper", true, true, 4, 0.5, 5, crack_regions, true, heat_color, 1.0, 3.0 * PI, true, 15.0, 6.0, 1.0, false, dominant_color, true)
	var rim_rect: Dictionary = rim.get("rim_rect", {})
	var rim_rect_color: Color = rim_rect.get("color", Color.BLACK)
	proof["draw_rim"] = bool(rim.get("rim_visible", false)) == true and is_equal_approx(float(rim.get("rim_alpha", -1.0)), 0.51) and String(rim_rect.get("region", "")) == "blast-drill-rim" and rim_rect_color.is_equal_approx(heat_color) and String(rim_rect.get("blend", "")) == "additive" and is_equal_approx(float(rim_late.get("rim_alpha", -1.0)), 0.6) and bool(mech.get("rim_visible", true)) == false and is_equal_approx(float(mech.get("rim_alpha", -1.0)), 0.0) and mech.get("rim_rect", {}) == null

	# Spin rotator: rotation 15 * 2 = 30, r = mod(30,
	# 90) = 30; two rects -- rect(30) at alpha 1.0 and
	# rect(-60) at alpha 30/90 = 1/3.
	var rotator: Dictionary = mech.get("rotator", {})
	var rotator_rects: Array = rotator.get("rects", [])
	var spin_first: Dictionary = rotator_rects[0]
	var spin_second: Dictionary = rotator_rects[1]
	proof["draw_rotator_spin"] = bool(rotator.get("spin", false)) == true and is_equal_approx(float(rotator.get("rotation_deg", -1.0)), 30.0) and rotator_rects.size() == 2 and is_equal_approx(float(spin_first.get("rotation_deg", -1.0)), 30.0) and is_equal_approx(float(spin_first.get("alpha", -1.0)), 1.0) and is_equal_approx(float(spin_second.get("rotation_deg", -1.0)), -60.0) and is_equal_approx(float(spin_second.get("alpha", -1.0)), 1.0 / 3.0)

	# Plain rotator: drawSpinSprite false, rotation 15
	# * 6 = 90, a single rect at the full rotation.
	var plain: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "blast-drill", "blast-drill-rim", "blast-drill-rotator", "blast-drill-top", "copper", true, true, 4, 0.5, 5, crack_regions, true, heat_color, 1.0, 0.0, false, 15.0, 6.0, 1.0, false, dominant_color, true)
	var plain_rotator: Dictionary = plain.get("rotator", {})
	var plain_rects: Array = plain_rotator.get("rects", [])
	var plain_first: Dictionary = plain_rects[0]
	proof["draw_rotator_plain"] = bool(plain_rotator.get("spin", true)) == false and is_equal_approx(float(plain_rotator.get("rotation_deg", -1.0)), 90.0) and plain_rects.size() == 1 and is_equal_approx(float(plain_first.get("rotation_deg", -1.0)), 90.0) and is_equal_approx(float(plain_first.get("alpha", -1.0)), 1.0)

	# Top rect: the Drill top region at the same position.
	var top_rect: Dictionary = mech.get("top_rect", {})
	proof["draw_top_rect"] = String(top_rect.get("region", "")) == "mechanical-drill-top" and is_equal_approx(float(top_rect.get("x", -1.0)), 100.0) and is_equal_approx(float(top_rect.get("y", -1.0)), 200.0)

	# Mine-item overlay: visible with a dominant item
	# and drawMineItem, in the dominant item color;
	# hidden without a dominant item.
	var mine: Dictionary = drill_build_state.source_drill_draw_state(100.0, 200.0, "mechanical-drill", "mechanical-drill-rim", "mechanical-drill-rotator", "mechanical-drill-top", "copper", true, true, 2, 0.5, 5, crack_regions, false, heat_color, 0.0, 0.0, true, 15.0, 2.0, 1.0, true, dominant_color, true)
	var mine_rect: Dictionary = mine.get("mine_item_rect", {})
	var mine_rect_color: Color = mine_rect.get("color", Color.BLACK)
	proof["draw_mine_item"] = bool(mine.get("mine_item_visible", false)) == true and String(mine_rect.get("region", "")) == "copper" and mine_rect_color.is_equal_approx(dominant_color) and bool(mech.get("mine_item_visible", true)) == false and mech.get("mine_item_rect", {}) == null

	# Layers: cracks at Layer.blockCracks 30.1,
	# rim/rotator at Layer.blockAfterCracks 30.2.
	var cracks_z: float = float(mech.get("cracks_z", -1.0))
	var after_cracks_z: float = float(mech.get("after_cracks_z", -1.0))
	proof["draw_cracks_z"] = is_equal_approx(cracks_z, 30.1) and is_equal_approx(after_cracks_z, 30.2) and is_equal_approx(float(cracks.get("z", -1.0)), 30.1) and is_equal_approx(float(rim_rect.get("z", -1.0)), 30.2) and is_equal_approx(float(spin_first.get("z", -1.0)), 30.2)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
