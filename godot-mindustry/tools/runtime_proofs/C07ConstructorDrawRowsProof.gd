extends Node

const main_scene := preload("res://scenes/Main.tscn")
const constructor_build_state := preload("res://src/game/SourceConstructorBuildState.gd")
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

	# --- Draw / drawSelect / placeEffect rows (N2440):
	# BlockProducerBuild.draw() (BlockProducer.java:134-160)
	# rects the base region, then the out region at
	# rotdeg(), then -- only with a recipe -- the shadow
	# (Drawf.shadow, radius recipe.size * tilesize * 2f,
	# alpha progress / recipe.buildTime) + the blockbuild
	# shader loop over the recipe generated icons (region /
	# time / progress per icon, rect at rotdeg() when the
	# recipe rotates else 0, flush per icon, on
	# Layer.blockBuilding) + the scan line (center x +
	# sin(time / 10f) * (tilesize / 2f * recipe.size + 1f),
	# angle 90, length recipe.size * tilesize + 1f, color
	# Pal.accent at alpha heat, z Layer.blockBuilding + 1),
	# then drawPayload(), then the top region at z
	# Layer.blockBuilding + 1.1f. drawSelect()
	# (Constructor.java:77-87) draws the recipe uiIcon at
	# dx = x - size * tilesize / 2f, dy = y + size *
	# tilesize / 2f (the PRODUCER size) with a darkGray
	# mixcol shadow rect at dx - 0.7f, dy - 1f, both sized
	# scl * xscl * 24f by scl * yscl * 24f. The placeEffect
	# (BlockProducer.java:116-119) fires when the craft
	# completes, at scale payload.size() / tilesize -- and
	# BuildPayload.size() is build.block.size * tilesize,
	# so the scale is the RECIPE block size in tiles. The
	# sin is the arc 3-arg form (Mathf.java:90-92, arc),
	# NOT absin. Pure-only: the tick never calls draw --
	# draw is called by the renderer, and the renderer
	# call site waits for a renderer slice, so this proof
	# has no live-tick key.

	var recipe: Dictionary = {"name": "tungsten-wall-large", "size": 2, "build_time": 100.0, "rotate": true, "icons": ["tungsten-wall-large", "tungsten-wall-large-team"], "ui_icon": "tungsten-wall-large-ui", "place_effect": "Fx.placeBlock"}
	var big_recipe: Dictionary = {"name": "reinforced-surge-wall-large", "size": 4, "build_time": 200.0, "rotate": false, "icons": ["reinforced-surge-wall-large"], "ui_icon": "reinforced-surge-wall-large-ui", "place_effect": "Fx.placeBlock"}

	# --- No recipe: the base rect and the out rect (at
	# rotdeg() 90 for rotation 1) and the top rect still
	# draw, while the shadow, build, scan and select calls
	# are null and no payload draws.
	var idle: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 1, 0.0, 0.0, 0.0, null, false, false, 3, 1.0, 1.0, 1.0)
	var idle_base: Dictionary = idle.get("base_call", {})
	var idle_out: Dictionary = idle.get("out_call", {})
	var idle_top: Dictionary = idle.get("top_call", {})
	proof["draw_no_recipe"] = not bool(idle.get("has_recipe", true)) and is_equal_approx(float(idle_base.get("x", -1.0)), 100.0) and is_equal_approx(float(idle_base.get("y", -1.0)), 200.0) and str(idle_base.get("region", "")) == "region" and is_equal_approx(float(idle_out.get("rotation", -1.0)), 90.0) and str(idle_out.get("region", "")) == "outRegion" and is_equal_approx(float(idle.get("rotdeg", -1.0)), 90.0) and idle.get("shadow_call") == null and idle.get("build_call") == null and idle.get("scan_call") == null and idle.get("select_call") == null and idle.get("payload_call") == null and idle.get("place_effect_call") == null and is_equal_approx(float(idle_top.get("x", -1.0)), 100.0) and is_equal_approx(float(idle_top.get("y", -1.0)), 200.0) and str(idle_top.get("region", "")) == "topRegion" and is_equal_approx(float(idle_top.get("z_value", -1.0)), 41.1)

	# --- Recipe build: at progress 25 over buildTime 100
	# the ratio is 0.25; the build call carries the two
	# generated icons on Layer.blockBuilding (40) in
	# Pal.accent, shader time 40.0, shader progress 0.25,
	# and each region rect at rotdeg() 90 because the
	# recipe rotates; a non-rotating recipe rects at 0.
	# A HELD payload draws through drawPayload()
	# (payload.draw() on Layer.blockOver after
	# updatePayload()) even with no recipe.
	var working: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 1, 40.0, 0.5, 25.0, recipe, false, false, 3, 1.0, 1.0, 1.0)
	var working_build: Dictionary = working.get("build_call", {})
	var working_regions: Array = working_build.get("regions", [])
	var working_region_calls: Array = working_build.get("region_calls", [])
	var working_first: Dictionary = working_region_calls[0] if working_region_calls.size() > 0 else {}
	var working_second: Dictionary = working_region_calls[1] if working_region_calls.size() > 1 else {}
	var flat: Dictionary = constructor_build_state.source_constructor_draw_state(0.0, 0.0, 2, 0.0, 0.0, 0.0, big_recipe, false, false, 5, 1.0, 1.0, 1.0)
	var flat_build: Dictionary = flat.get("build_call", {})
	var flat_region_calls: Array = flat_build.get("region_calls", [])
	var flat_first: Dictionary = flat_region_calls[0] if flat_region_calls.size() > 0 else {}
	var held: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 0, 0.0, 0.0, 0.0, null, true, false, 3, 1.0, 1.0, 1.0)
	var held_payload: Dictionary = held.get("payload_call", {})
	proof["draw_recipe_build"] = bool(working.get("has_recipe", false)) and is_equal_approx(float(working.get("progress_ratio", -1.0)), 0.25) and str(working_build.get("layer", "")) == "Layer.blockBuilding" and is_equal_approx(float(working_build.get("layer_value", -1.0)), 40.0) and str(working_build.get("color", "")) == "Pal.accent" and working_regions.size() == 2 and str(working_regions[0]) == "tungsten-wall-large" and str(working_regions[1]) == "tungsten-wall-large-team" and is_equal_approx(float(working_build.get("shader_time", -1.0)), 40.0) and is_equal_approx(float(working_build.get("shader_progress", -1.0)), 0.25) and bool(working_build.get("rotate", false)) and working_region_calls.size() == 2 and is_equal_approx(float(working_first.get("rotation", -1.0)), 90.0) and is_equal_approx(float(working_second.get("rotation", -1.0)), 90.0) and str(working_first.get("flush", "")) == "Draw.flush();" and str(working_first.get("shader_region", "")) == "Shaders.blockbuild.region = region;" and is_equal_approx(float(flat_first.get("rotation", -1.0)), 0.0) and str(flat_first.get("region", "")) == "reinforced-surge-wall-large" and str(held_payload.get("call", "")) == "payload.draw();" and str(held_payload.get("update_payload_call", "")) == "updatePayload();" and str(held_payload.get("z", "")) == "Layer.blockOver" and is_equal_approx(float(held_payload.get("z_value", -1.0)), 35.0)

	# --- Shadow math: radius recipe.size * tilesize * 2f
	# = 32 for recipe size 2 (64 for size 4), alpha the
	# progress ratio 0.25, circle-shadow color alpha
	# 0.4 * 0.25 = 0.1, centered on the building.
	var working_shadow: Dictionary = working.get("shadow_call", {})
	var flat_shadow: Dictionary = flat.get("shadow_call", {})
	proof["draw_shadow_math"] = is_equal_approx(float(working_shadow.get("radius", -1.0)), 32.0) and is_equal_approx(float(working.get("shadow_radius", -1.0)), 32.0) and is_equal_approx(float(working_shadow.get("alpha", -1.0)), 0.25) and is_equal_approx(float(working_shadow.get("color_alpha", -1.0)), 0.1) and str(working_shadow.get("region", "")) == "circle-shadow" and is_equal_approx(float(working_shadow.get("x", -1.0)), 100.0) and is_equal_approx(float(working_shadow.get("y", -1.0)), 200.0) and is_equal_approx(float(flat_shadow.get("radius", -1.0)), 64.0) and is_equal_approx(float(flat_shadow.get("alpha", -1.0)), 0.0)

	# --- Scan line sin: the line sits at the building
	# center when time is 0 (sin(0) = 0), angle 90,
	# length recipe.size * tilesize + 1f = 17 for recipe
	# size 2, color Pal.accent at alpha heat 0.5, z
	# Layer.blockBuilding + 1 (41); at time 10 * PI / 2
	# the sin peaks at 1 and the line sits 9 (tilesize /
	# 2f * recipe.size + 1f) right of center; recipe size
	# 4 gives magnitude 17 and length 33.
	var fresh: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 0, 0.0, 0.5, 0.0, recipe, false, false, 3, 1.0, 1.0, 1.0)
	var fresh_scan: Dictionary = fresh.get("scan_call", {})
	var peaked: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 0, 10.0 * PI / 2.0, 0.5, 0.0, recipe, false, false, 3, 1.0, 1.0, 1.0)
	var peaked_scan: Dictionary = peaked.get("scan_call", {})
	var big_scan: Dictionary = flat.get("scan_call", {})
	proof["draw_scan_line_sin"] = is_equal_approx(float(fresh_scan.get("x", -1.0)), 100.0) and is_equal_approx(float(fresh_scan.get("y", -1.0)), 200.0) and is_equal_approx(float(fresh_scan.get("angle", -1.0)), 90.0) and is_equal_approx(float(fresh_scan.get("length", -1.0)), 17.0) and is_equal_approx(float(fresh.get("scan_length", -1.0)), 17.0) and is_equal_approx(float(fresh.get("scan_magnitude", -1.0)), 9.0) and str(fresh_scan.get("color", "")) == "Pal.accent" and is_equal_approx(float(fresh_scan.get("alpha", -1.0)), 0.5) and str(fresh_scan.get("z", "")) == "Layer.blockBuilding + 1" and is_equal_approx(float(fresh_scan.get("z_value", -1.0)), 41.0) and is_equal_approx(float(peaked_scan.get("x", -1.0)), 109.0) and is_equal_approx(float(peaked.get("scan_x", -1.0)), 109.0) and is_equal_approx(float(big_scan.get("length", -1.0)), 33.0) and is_equal_approx(float(flat.get("scan_magnitude", -1.0)), 17.0)

	# --- Select icon: for the size-3 constructor the
	# icon sits at dx = 100 - 12 = 88, dy = 200 + 12 =
	# 212, with the darkGray shadow rect at (87.3, 211),
	# both 24 by 24 at unit scales; for the size-5
	# large-constructor dx = 80, dy = 220; non-unit
	# scales fold as scl * xscl * 24f by scl * yscl *
	# 24f (scl 2, xscl 0.5, yscl 2 gives 24 by 96).
	# The select call is null with no recipe.
	var working_select: Dictionary = working.get("select_call", {})
	var flat_select: Dictionary = flat.get("select_call", {})
	var scaled: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 0, 0.0, 0.0, 0.0, recipe, false, false, 3, 2.0, 0.5, 2.0)
	var scaled_select: Dictionary = scaled.get("select_call", {})
	proof["draw_select_icon"] = str(working_select.get("icon", "")) == "tungsten-wall-large-ui" and is_equal_approx(float(working_select.get("x", -1.0)), 88.0) and is_equal_approx(float(working_select.get("y", -1.0)), 212.0) and is_equal_approx(float(working.get("select_dx", -1.0)), 88.0) and is_equal_approx(float(working.get("select_dy", -1.0)), 212.0) and is_equal_approx(float(working_select.get("shadow_x", -1.0)), 87.3) and is_equal_approx(float(working_select.get("shadow_y", -1.0)), 211.0) and is_equal_approx(float(working_select.get("width", -1.0)), 24.0) and is_equal_approx(float(working_select.get("height", -1.0)), 24.0) and str(working_select.get("mixcol", "")) == "Color.darkGray" and is_equal_approx(float(working_select.get("mixcol_alpha", -1.0)), 1.0) and is_equal_approx(float(flat_select.get("x", -1.0)), -20.0) and is_equal_approx(float(flat_select.get("y", -1.0)), 20.0) and is_equal_approx(float(scaled_select.get("width", -1.0)), 24.0) and is_equal_approx(float(scaled_select.get("height", -1.0)), 96.0) and idle.get("select_call") == null

	# --- Place effect: the effect fires only on the
	# craft-complete tick (just_crafted), at scale
	# payload.size() / tilesize = the RECIPE block size
	# (2 for the tungsten wall, 4 for the surge wall) --
	# NOT the producer size; without just_crafted, or
	# with no recipe, the call is null.
	var crafted: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 0, 0.0, 1.0, 100.0, recipe, false, true, 3, 1.0, 1.0, 1.0)
	var crafted_effect: Dictionary = crafted.get("place_effect_call", {})
	var big_crafted: Dictionary = constructor_build_state.source_constructor_draw_state(0.0, 0.0, 0, 0.0, 1.0, 200.0, big_recipe, false, true, 5, 1.0, 1.0, 1.0)
	var big_effect: Dictionary = big_crafted.get("place_effect_call", {})
	var no_recipe_crafted: Dictionary = constructor_build_state.source_constructor_draw_state(100.0, 200.0, 0, 0.0, 1.0, 0.0, null, false, true, 3, 1.0, 1.0, 1.0)
	proof["draw_place_effect"] = str(crafted_effect.get("effect", "")) == "Fx.placeBlock" and is_equal_approx(float(crafted_effect.get("scale", -1.0)), 2.0) and is_equal_approx(float(crafted_effect.get("x", -1.0)), 100.0) and is_equal_approx(float(crafted_effect.get("y", -1.0)), 200.0) and is_equal_approx(float(big_effect.get("scale", -1.0)), 4.0) and working.get("place_effect_call") == null and no_recipe_crafted.get("place_effect_call") == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ConstructorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
