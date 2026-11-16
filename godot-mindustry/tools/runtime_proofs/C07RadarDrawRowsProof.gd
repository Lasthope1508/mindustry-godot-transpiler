extends Node

const main_scene := preload("res://scenes/Main.tscn")
const radar_build_state := preload("res://src/game/SourceRadarBuildState.gd")
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

	# --- Draw rows (N2427): RadarBuild.draw()
	# (Radar.java:85-90) rects the base region, then the
	# region rect rotated rotateSpeed * totalProgress,
	# then the additive glow on Layer.blockAdditive with
	# alpha glowColor.a * (1f - glowMag + absin) --
	# absin Java-exact through the shared helper at the
	# DOUBLED scale (glow_scl * 2f, the N2372/N2382
	# lesson). drawSelect (Radar.java:80-82) dashes the
	# LIVE fogRadius() radius (fogRadius * progress *
	# smoothEfficiency, Radar.java:55-57) while
	# drawPlace (Radar.java:42-46) dashes the DEF
	# fogRadius field radius at x * tilesize + offset
	# (method vs field, verified first). icons()
	# (Radar.java:37-39) returns [baseRegion, region]
	# and rides the draw pure (the N2396 precedent).
	# Pure-only: the tick never calls draw -- draw is
	# called by the renderer, drawSelect/drawPlace by
	# the UI, icons by the atlas, and the call sites
	# wait for renderer/UI slices, so this proof has no
	# live-tick key. Def values: rotateSpeed 2f /
	# glowScl 5f / glowMag 0.6f / glowColor
	# Pal.turretHeat (alpha 1.0, Pal.java:52) /
	# fogRadius 34 (Blocks.java:1991) / size 1 (offset
	# 0, Block.java:761).

	# --- Base + region rotation: the base rect draws
	# unrotated at (x, y) with region baseRegion; the
	# region rect draws at (x, y) with region region,
	# rotated rotateSpeed * totalProgress = 2 * 10 = 20,
	# and the glow rotates with it.
	var drawn: Dictionary = radar_build_state.source_radar_draw_state(100.0, 200.0, 2.0, 10.0, "Pal.turretHeat", 1.0, 0.6, 5.0, 0.0, 34.0, 17.0, 0.0, 1, 10, 20)
	var drawn_base: Dictionary = drawn.get("base_call", {})
	var drawn_region: Dictionary = drawn.get("region_call", {})
	var drawn_glow: Dictionary = drawn.get("glow_call", {})
	proof["draw_base_region_rotation"] = str(drawn_base.get("region", "")) == "baseRegion" and is_equal_approx(float(drawn_base.get("x", -1.0)), 100.0) and is_equal_approx(float(drawn_base.get("y", -1.0)), 200.0) and str(drawn_region.get("region", "")) == "region" and is_equal_approx(float(drawn_region.get("x", -1.0)), 100.0) and is_equal_approx(float(drawn_region.get("y", -1.0)), 200.0) and is_equal_approx(float(drawn_region.get("rotation", -1.0)), 20.0) and is_equal_approx(float(drawn_glow.get("rotation", -1.0)), 20.0) and is_equal_approx(float(drawn.get("rotation", -1.0)), 20.0)

	# --- Glow absin math: Java absin(Time.time, 5, 0.6)
	# is (sin(t / 10) * 0.6 + 0.6) / 2 -- at t = 0 the
	# absin is 0.3 and the glow alpha is 1.0 * (1 - 0.6
	# + 0.3) = 0.7; at t = 5 * PI the absin peaks at
	# 0.6 (sin(PI / 2) = 1) and the glow alpha is 1.0 *
	# (1 - 0.6 + 0.6) = 1.0. An undoubled scale would
	# peak twice as fast and fail the 5 * PI check.
	var peaked: Dictionary = radar_build_state.source_radar_draw_state(100.0, 200.0, 2.0, 10.0, "Pal.turretHeat", 1.0, 0.6, 5.0, 5.0 * PI, 34.0, 17.0, 0.0, 1, 10, 20)
	var peaked_glow: Dictionary = peaked.get("glow_call", {})
	proof["draw_glow_absin"] = is_equal_approx(float(drawn.get("glow_absin", -1.0)), 0.3) and is_equal_approx(float(drawn_glow.get("absin", -1.0)), 0.3) and is_equal_approx(float(drawn.get("glow_alpha_value", -1.0)), 0.7) and is_equal_approx(float(drawn_glow.get("alpha", -1.0)), 0.7) and is_equal_approx(float(peaked.get("glow_absin", -1.0)), 0.6) and is_equal_approx(float(peaked_glow.get("absin", -1.0)), 0.6) and is_equal_approx(float(peaked.get("glow_alpha_value", -1.0)), 1.0) and is_equal_approx(float(peaked_glow.get("alpha", -1.0)), 1.0) and str(drawn_glow.get("region", "")) == "glowRegion" and str(drawn_glow.get("color", "")) == "Pal.turretHeat" and str(drawn_glow.get("z", "")) == "Layer.blockAdditive"

	# --- drawSelect dash circle: centered on the
	# building, radius fogRadius() * tilesize on the
	# LIVE method radius -- 17 * 8 = 136 at half
	# discovery, 34 * 8 = 272 at full discovery --
	# color Pal.accent.
	var drawn_select: Dictionary = drawn.get("select_call", {})
	var discovered: Dictionary = radar_build_state.source_radar_draw_state(100.0, 200.0, 2.0, 10.0, "Pal.turretHeat", 1.0, 0.6, 5.0, 0.0, 34.0, 34.0, 0.0, 1, 10, 20)
	var discovered_select: Dictionary = discovered.get("select_call", {})
	proof["draw_select_dash_circle"] = is_equal_approx(float(drawn_select.get("x", -1.0)), 100.0) and is_equal_approx(float(drawn_select.get("y", -1.0)), 200.0) and is_equal_approx(float(drawn_select.get("radius", -1.0)), 136.0) and str(drawn_select.get("color", "")) == "Pal.accent" and is_equal_approx(float(discovered_select.get("radius", -1.0)), 272.0)

	# --- drawPlace dash circle: centered on x * tilesize
	# + offset / y * tilesize + offset -- (80, 160) at
	# tile (10, 20) with the size-1 offset 0, (84, 164)
	# with an even-size offset 4 -- radius fogRadius *
	# tilesize on the DEF field radius (34 * 8 = 272
	# even at half discovery, unlike drawSelect), color
	# Pal.accent, with the super.drawPlace call
	# recorded.
	var drawn_place: Dictionary = drawn.get("place_call", {})
	var offset_place_state: Dictionary = radar_build_state.source_radar_draw_state(100.0, 200.0, 2.0, 10.0, "Pal.turretHeat", 1.0, 0.6, 5.0, 0.0, 34.0, 17.0, 4.0, 2, 10, 20)
	var offset_place: Dictionary = offset_place_state.get("place_call", {})
	proof["draw_place_dash_circle"] = is_equal_approx(float(drawn_place.get("center_x", -1.0)), 80.0) and is_equal_approx(float(drawn_place.get("center_y", -1.0)), 160.0) and is_equal_approx(float(drawn_place.get("radius", -1.0)), 272.0) and str(drawn_place.get("color", "")) == "Pal.accent" and int(drawn_place.get("tile_x", -1)) == 10 and int(drawn_place.get("tile_y", -1)) == 20 and int(drawn_place.get("size", -1)) == 1 and is_equal_approx(float(drawn_place.get("offset", -1.0)), 0.0) and str(drawn_place.get("super_call", "")) == "super.drawPlace(x, y, rotation, valid);" and is_equal_approx(float(offset_place.get("center_x", -1.0)), 84.0) and is_equal_approx(float(offset_place.get("center_y", -1.0)), 164.0)

	# --- Merged icons: icons() returns [baseRegion,
	# region] in draw order, carried on the draw pure
	# because icons() takes no args.
	var icons: Array = drawn.get("icon_regions", [])
	proof["draw_icons_merged"] = icons.size() == 2 and str(icons[0]) == "baseRegion" and str(icons[1]) == "region"

	# --- totalProgress 0 edge: a fresh radar draws
	# unrotated -- rotation 0 on the region rect, the
	# glow, and the top-level echo -- while the base
	# rect still draws at (x, y).
	var fresh: Dictionary = radar_build_state.source_radar_draw_state(100.0, 200.0, 2.0, 0.0, "Pal.turretHeat", 1.0, 0.6, 5.0, 0.0, 34.0, 0.0, 0.0, 1, 10, 20)
	var fresh_base: Dictionary = fresh.get("base_call", {})
	var fresh_region: Dictionary = fresh.get("region_call", {})
	var fresh_glow: Dictionary = fresh.get("glow_call", {})
	proof["draw_total_progress_zero_edge"] = is_equal_approx(float(fresh.get("rotation", -1.0)), 0.0) and is_equal_approx(float(fresh_region.get("rotation", -1.0)), 0.0) and is_equal_approx(float(fresh_glow.get("rotation", -1.0)), 0.0) and str(fresh_base.get("region", "")) == "baseRegion" and is_equal_approx(float(fresh_base.get("x", -1.0)), 100.0) and is_equal_approx(float(fresh_base.get("y", -1.0)), 200.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
