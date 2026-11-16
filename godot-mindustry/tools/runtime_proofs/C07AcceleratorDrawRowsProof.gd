extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	# --- Draw rows (N2373): AcceleratorBuild.draw()
	# (Accelerator.java:157-233), drawLight()
	# (Accelerator.java:235-237) and drawSelect()
	# (Accelerator.java:249-256). draw() is super.draw()
	# (:158) + the arrows loop (:160-169: 4 layers, length
	# 7f + l * 5f, color lerp darkMetal -> team.color by
	# statusLerp then -> darkMetal by absin(Time.time +
	# l*50f, 10f, 1f), 4 arrows per layer at rot i*90f +
	# 45f via Angles.trnsx/trnsy, rotation rot + 180f) +
	# the launching branch (:180-194, Fill.light /
	# fullIcon / mixcol by launchTime / chargeDuration --
	# DEFERRED, launchTime is not tracked) or the
	# non-launching branch (:195-212: Drawf.shadow(x, y,
	# launchBlock.size * tilesize * 2f, progress) +
	# Draw.draw(Layer.blockBuilding, ...) with
	# Draw.color(Pal.accent, heat) and the blockbuild
	# shader (region / time / progress per generated
	# icon)) + the heat gate (:215, if(heat < 0.0001f)
	# return) + the rings (:217-232: rad = size *
	# tilesize / 2f * 0.74f * lerp(1f, 1.3f, launchHeat),
	# z Layer.bullet - 0.0001f, stroke 1.75f * heat
	# square rad * 1.22f rot lerp(45f, 0f, launchHeat),
	# stroke 3f * heat squares rad * lerp(1f, 1.3f,
	# launchHeat) rot 45f + time / scl and rad * lerp(1f,
	# 1.8f, launchHeat) rot lerp(45f, 0f, launchHeat) -
	# time / scl, scl 2f, then team.color arrows alpha
	# clamp(heat * 3f), rot i*90f + 45f + (-time/3f)%360f,
	# length 26f * heat * lerp(1f, 1.5f, launchHeat)).
	# drawLight() is Drawf.light(x, y, lightRadius,
	# lightColor, launchHeat) (:236 -- lightRadius 70f,
	# lightColor Pal.accent, :79-80). drawSelect() is
	# super.drawSelect() + the battery warning (:252-254:
	# battery < requirement && !launching ->
	# drawPlaceText("bar.nobatterypower", tile.x, tile.y,
	# false), valid false -> Pal.remove, Block.java:531).
	# The pures return draw-call dicts; they never draw
	# for real (the N2356 ShockwaveTower pattern).
	var accelerator_x := 100.0
	var accelerator_y := 200.0

	# --- Arrows: 4 layers x 4 arrows, length 7f + l * 5f
	# (7 / 12 / 17 / 22), color base lerp darkMetal ->
	# team.color by statusLerp, pulse absin(Time.time +
	# l*50f, 10f, 1f). At time_value 0.0 the layer-0 pulse
	# is absin(0, 10, 1) = 0.5; at statusLerp 0.5 the base
	# lerp factor is 0.5. Arrow i sits at rot i*90f + 45f
	# via Angles.trnsx/trnsy with rotation rot + 180f: the
	# layer-0 arrow 0 is at rot 45, rotation 225, offset
	# 7 * (cos 45, sin 45) from the building center.
	var warm: Dictionary = accelerator_build_state.source_accelerator_draw_state(accelerator_x, accelerator_y, 0.5, 0.5, 0.0, 0.0, 0.0, 0.5, false)
	var warm_arrows: Dictionary = warm.get("arrows_call", {})
	var warm_layers: Array = warm_arrows.get("layers", [])
	var warm_layer0: Dictionary = warm_layers[0] if warm_layers.size() > 0 else {}
	var warm_layer1: Dictionary = warm_layers[1] if warm_layers.size() > 1 else {}
	var warm_layer2: Dictionary = warm_layers[2] if warm_layers.size() > 2 else {}
	var warm_layer3: Dictionary = warm_layers[3] if warm_layers.size() > 3 else {}
	var warm_layer0_color: Dictionary = warm_layer0.get("color", {})
	var warm_layer0_base: Dictionary = warm_layer0_color.get("base", {})
	var warm_layer0_arrows: Array = warm_layer0.get("arrows", [])
	var warm_arrow0: Dictionary = warm_layer0_arrows[0] if warm_layer0_arrows.size() > 0 else {}
	proof["draw_arrows_status_lerp_pulse"] = bool(warm.get("super_draw_called", false)) and warm_arrows.get("region", "") == "arrowRegion" and warm_layers.size() == 4 and is_equal_approx(float(warm_layer0.get("length", -1.0)), 7.0) and is_equal_approx(float(warm_layer1.get("length", -1.0)), 12.0) and is_equal_approx(float(warm_layer2.get("length", -1.0)), 17.0) and is_equal_approx(float(warm_layer3.get("length", -1.0)), 22.0) and is_equal_approx(float(warm_layer0.get("pulse", -1.0)), 0.5) and warm_layer0_base.get("from", "") == "Pal.darkMetal" and warm_layer0_base.get("to", "") == "team.color" and is_equal_approx(float(warm_layer0_base.get("t", -1.0)), 0.5) and warm_layer0_color.get("pulse_to", "") == "Pal.darkMetal" and is_equal_approx(float(warm_layer0_color.get("pulse_t", -1.0)), 0.5) and warm_layer0_arrows.size() == 4 and is_equal_approx(float(warm_arrow0.get("rot", -1.0)), 45.0) and is_equal_approx(float(warm_arrow0.get("rotation", -1.0)), 225.0) and is_equal_approx(float(warm_arrow0.get("x", -1.0)), accelerator_x + cos(deg_to_rad(45.0)) * 7.0) and is_equal_approx(float(warm_arrow0.get("y", -1.0)), accelerator_y + sin(deg_to_rad(45.0)) * 7.0)

	# --- Shadow + blockbuild: the non-launching branch.
	# The shadow radius is launchBlock.size * tilesize *
	# 2f = 5 * 8 * 2 = 80 (the launchBlock is
	# core-nucleus, size 5, Blocks.java:3159) and the
	# circle-shadow black alpha is 0.4 * progress (0.2 at
	# progress 0.5, Drawf.java:360-364). The blockbuild
	# draw is at Layer.blockBuilding, color Pal.accent,
	# alpha heat (0.5), shader time 0.0 and shader
	# progress 0.5. When launching is true the shadow /
	# blockbuild calls are empty and the launching visual
	# is flagged deferred (launchTime is not tracked).
	var warm_build: Dictionary = warm.get("build_call", {})
	var warm_shadow: Dictionary = warm_build.get("shadow_call", {})
	var warm_blockbuild: Dictionary = warm_build.get("blockbuild_call", {})
	var launching_draw: Dictionary = accelerator_build_state.source_accelerator_draw_state(accelerator_x, accelerator_y, 0.5, 0.5, 0.0, 0.0, 0.0, 0.5, true)
	var launching_build: Dictionary = launching_draw.get("build_call", {})
	proof["draw_shadow_blockbuild"] = bool(warm_build.get("launching_visual_deferred", true)) == false and warm_shadow.get("region", "") == "circle-shadow" and is_equal_approx(float(warm_shadow.get("radius", -1.0)), 80.0) and is_equal_approx(float(warm_shadow.get("alpha_factor", -1.0)), 0.5) and is_equal_approx(float(warm_shadow.get("black_alpha", -1.0)), 0.2) and warm_blockbuild.get("layer", "") == "Layer.blockBuilding" and warm_blockbuild.get("color", "") == "Pal.accent" and is_equal_approx(float(warm_blockbuild.get("alpha", -1.0)), 0.5) and is_equal_approx(float(warm_blockbuild.get("shader_time", -1.0)), 0.0) and is_equal_approx(float(warm_blockbuild.get("shader_progress", -1.0)), 0.5) and warm_blockbuild.get("region_source", "") == "launchBlock.getGeneratedIcons()" and bool(launching_build.get("launching_visual_deferred", false)) and (launching_build.get("shadow_call", {}) as Dictionary).is_empty() and (launching_build.get("blockbuild_call", {}) as Dictionary).is_empty()

	# --- Charge rings: gated on heat >= 0.0001f (Java
	# returns early otherwise, so a cold accelerator draws
	# no rings at all). At heat 0.5, launchHeat 0.0 and
	# time 0.0 the rad is 7 * 8 / 2 * 0.74 * 1.0 = 20.72;
	# square 1 is stroke 1.75 * 0.5 = 0.875, radius
	# 20.72 * 1.22 = 25.2784, rotation 45; squares 2-3 are
	# stroke 3 * 0.5 = 1.5, radius 20.72, rotation 45; the
	# 4 team-color arrows are length 26 * 0.5 * 1.0 = 13
	# with alpha clamp(0.5 * 3) = 1.0. At launchHeat 1.0
	# the rad is 20.72 * 1.3 = 26.936, square 1 rotates to
	# 0, and the arrows stretch to 26 * 0.5 * 1.5 = 19.5.
	# At build time 6.0 the squares rotate by time / 2 =
	# 3 (square 2 to 48, square 3 to 42) and the ring
	# arrow 0 rot is 45 + (-6/3)%360 = 43.
	var cold: Dictionary = accelerator_build_state.source_accelerator_draw_state(accelerator_x, accelerator_y, 0.0, 0.5, 0.0, 0.0, 0.0, 0.5, false)
	var cold_rings: Dictionary = cold.get("rings_call", {})
	var warm_rings: Dictionary = warm.get("rings_call", {})
	var warm_squares: Array = warm_rings.get("squares", [])
	var warm_square0: Dictionary = warm_squares[0] if warm_squares.size() > 0 else {}
	var warm_square1: Dictionary = warm_squares[1] if warm_squares.size() > 1 else {}
	var warm_square2: Dictionary = warm_squares[2] if warm_squares.size() > 2 else {}
	var warm_ring_arrows: Array = warm_rings.get("arrows", [])
	var warm_ring_arrow0: Dictionary = warm_ring_arrows[0] if warm_ring_arrows.size() > 0 else {}
	var charged: Dictionary = accelerator_build_state.source_accelerator_draw_state(accelerator_x, accelerator_y, 0.5, 0.5, 1.0, 0.0, 0.0, 0.5, false)
	var charged_rings: Dictionary = charged.get("rings_call", {})
	var charged_squares: Array = charged_rings.get("squares", [])
	var charged_square0: Dictionary = charged_squares[0] if charged_squares.size() > 0 else {}
	var charged_ring_arrows: Array = charged_rings.get("arrows", [])
	var charged_ring_arrow0: Dictionary = charged_ring_arrows[0] if charged_ring_arrows.size() > 0 else {}
	var timed: Dictionary = accelerator_build_state.source_accelerator_draw_state(accelerator_x, accelerator_y, 0.5, 0.5, 0.0, 0.0, 6.0, 0.5, false)
	var timed_rings: Dictionary = timed.get("rings_call", {})
	var timed_squares: Array = timed_rings.get("squares", [])
	var timed_square1: Dictionary = timed_squares[1] if timed_squares.size() > 1 else {}
	var timed_square2: Dictionary = timed_squares[2] if timed_squares.size() > 2 else {}
	var timed_ring_arrows: Array = timed_rings.get("arrows", [])
	var timed_ring_arrow0: Dictionary = timed_ring_arrows[0] if timed_ring_arrows.size() > 0 else {}
	proof["draw_charge_rings_heat_gate"] = bool(cold_rings.get("present", true)) == false and (cold_rings.get("squares", []) as Array).is_empty() and (cold_rings.get("arrows", []) as Array).is_empty() and is_equal_approx(float(cold_rings.get("rad", -1.0)), 0.0) and bool(warm_rings.get("present", false)) and is_equal_approx(float(warm_rings.get("rad", -1.0)), 20.72) and warm_rings.get("z", "") == "Layer.bullet - 0.0001f" and warm_squares.size() == 3 and is_equal_approx(float(warm_square0.get("stroke", -1.0)), 0.875) and is_equal_approx(float(warm_square0.get("radius", -1.0)), 25.2784) and is_equal_approx(float(warm_square0.get("rotation", -1.0)), 45.0) and is_equal_approx(float(warm_square1.get("stroke", -1.0)), 1.5) and is_equal_approx(float(warm_square1.get("radius", -1.0)), 20.72) and is_equal_approx(float(warm_square1.get("rotation", -1.0)), 45.0) and is_equal_approx(float(warm_square2.get("radius", -1.0)), 20.72) and is_equal_approx(float(warm_square2.get("rotation", -1.0)), 45.0) and warm_ring_arrows.size() == 4 and is_equal_approx(float(warm_ring_arrow0.get("length", -1.0)), 13.0) and is_equal_approx(float(warm_rings.get("arrow_alpha", -1.0)), 1.0) and warm_rings.get("arrow_color", "") == "team.color" and is_equal_approx(float(charged_rings.get("rad", -1.0)), 26.936) and is_equal_approx(float(charged_square0.get("rotation", -1.0)), 0.0) and is_equal_approx(float(charged_ring_arrow0.get("length", -1.0)), 19.5) and is_equal_approx(float(timed_square1.get("rotation", -1.0)), 48.0) and is_equal_approx(float(timed_square2.get("rotation", -1.0)), 42.0) and is_equal_approx(float(timed_ring_arrow0.get("rot", -1.0)), 43.0)

	# --- drawLight: Drawf.light(x, y, lightRadius,
	# lightColor, launchHeat) -- radius 70f, color
	# lightColor (Pal.accent), opacity launchHeat. At
	# launchHeat 0 the opacity is 0 (an idle accelerator
	# emits no light); at 0.5 it is 0.5; at 1.0 it is 1.0.
	var dark: Dictionary = accelerator_build_state.source_accelerator_draw_light_state(accelerator_x, accelerator_y, 0.0)
	var dark_light: Dictionary = dark.get("light_call", {})
	var dim: Dictionary = accelerator_build_state.source_accelerator_draw_light_state(accelerator_x, accelerator_y, 0.5)
	var dim_light: Dictionary = dim.get("light_call", {})
	var bright: Dictionary = accelerator_build_state.source_accelerator_draw_light_state(accelerator_x, accelerator_y, 1.0)
	var bright_light: Dictionary = bright.get("light_call", {})
	proof["draw_light_launch_heat"] = is_equal_approx(float(dim_light.get("x", -1.0)), accelerator_x) and is_equal_approx(float(dim_light.get("y", -1.0)), accelerator_y) and is_equal_approx(float(dim_light.get("radius", -1.0)), 70.0) and dim_light.get("color", "") == "lightColor" and is_equal_approx(float(dark_light.get("opacity", -1.0)), 0.0) and is_equal_approx(float(dim_light.get("opacity", -1.0)), 0.5) and is_equal_approx(float(bright_light.get("opacity", -1.0)), 1.0)

	# --- drawSelect: super.drawSelect() + the battery
	# warning. At tile (3, 4) with an empty battery and
	# not launching the warning shows (text key
	# bar.nobatterypower, valid false -> Pal.remove with
	# the underline); with a full battery (1,000,000) it
	# hides; while launching it hides too.
	var empty: Dictionary = accelerator_build_state.source_accelerator_draw_select_state(3, 4, 0.0, false)
	var empty_warning: Dictionary = empty.get("battery_warning_call", {})
	var full: Dictionary = accelerator_build_state.source_accelerator_draw_select_state(3, 4, 1000000.0, false)
	var full_warning: Dictionary = full.get("battery_warning_call", {})
	var launching_select: Dictionary = accelerator_build_state.source_accelerator_draw_select_state(3, 4, 0.0, true)
	var launching_warning: Dictionary = launching_select.get("battery_warning_call", {})
	proof["draw_select_battery_warning"] = bool(empty.get("super_draw_select_called", false)) and bool(empty_warning.get("shown", false)) and empty_warning.get("text_key", "") == "bar.nobatterypower" and int(empty_warning.get("tile_x", -1)) == 3 and int(empty_warning.get("tile_y", -1)) == 4 and empty_warning.get("color", "") == "Pal.remove" and bool(empty_warning.get("draw_line", false)) and bool(empty_warning.get("valid", true)) == false and bool(full_warning.get("shown", true)) == false and bool(launching_warning.get("shown", true)) == false

	# --- Live frame values: a placed accelerator's frame
	# heat / statusLerp / launchHeat / time / progress /
	# launching / battery_stored feed the draw pures. The
	# frame heat 0.5, statusLerp 0.5, launchHeat 0.0,
	# time 0.0, progress 0.5, launching false and
	# battery_stored 0.0 at Time.time 0.0 give the shadow
	# black alpha 0.2, the rings present with rad 20.72,
	# the layer-0 pulse 0.5, the light opacity 0.0 and the
	# battery warning shown -- the draw pures read live
	# frame state, they just never run inside the tick.
	var accelerator_cell := Vector2i(30, 21)
	var accelerator := Sprite2D.new()
	game.add_child(accelerator)
	game.call("record_placed_block", accelerator, blocks_by_id["interplanetary-accelerator"], accelerator_cell)
	accelerator_build_state.source_accelerator_bind_frame_state(accelerator, blocks_by_id["interplanetary-accelerator"])
	var accelerator_frame: Dictionary = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	accelerator_frame["heat"] = 0.5
	accelerator_frame["status_lerp"] = 0.5
	accelerator_frame["launch_heat"] = 0.0
	accelerator_frame["time"] = 0.0
	accelerator_frame["progress"] = 0.5
	accelerator_frame["launching"] = false
	accelerator_frame["battery_stored"] = 0.0
	var live: Dictionary = accelerator_build_state.source_accelerator_draw_state(accelerator_x, accelerator_y, float(accelerator_frame.get("heat", -1.0)), float(accelerator_frame.get("status_lerp", -1.0)), float(accelerator_frame.get("launch_heat", -1.0)), 0.0, float(accelerator_frame.get("time", -1.0)), float(accelerator_frame.get("progress", -1.0)), bool(accelerator_frame.get("launching", true)))
	var live_build: Dictionary = live.get("build_call", {})
	var live_shadow: Dictionary = live_build.get("shadow_call", {})
	var live_rings: Dictionary = live.get("rings_call", {})
	var live_arrows: Dictionary = live.get("arrows_call", {})
	var live_layers: Array = live_arrows.get("layers", [])
	var live_layer0: Dictionary = live_layers[0] if live_layers.size() > 0 else {}
	var live_light: Dictionary = accelerator_build_state.source_accelerator_draw_light_state(accelerator_x, accelerator_y, float(accelerator_frame.get("launch_heat", -1.0)))
	var live_light_call: Dictionary = live_light.get("light_call", {})
	var live_select: Dictionary = accelerator_build_state.source_accelerator_draw_select_state(accelerator_cell.x, accelerator_cell.y, float(accelerator_frame.get("battery_stored", -1.0)), bool(accelerator_frame.get("launching", true)))
	var live_warning: Dictionary = live_select.get("battery_warning_call", {})
	proof["draw_live_frame_values"] = is_equal_approx(float(live_shadow.get("black_alpha", -1.0)), 0.2) and bool(live_rings.get("present", false)) and is_equal_approx(float(live_rings.get("rad", -1.0)), 20.72) and is_equal_approx(float(live_layer0.get("pulse", -1.0)), 0.5) and is_equal_approx(float(live_light_call.get("opacity", -1.0)), 0.0) and bool(live_warning.get("shown", false)) and int(live_warning.get("tile_x", -1)) == 30 and int(live_warning.get("tile_y", -1)) == 21

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
