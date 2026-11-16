extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
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

	# --- Draw rows (N2419): SeparatorBuild.draw()
	# (Separator.java:104-106) runs the DrawMulti def
	# drawer (Blocks.java:1246/1266, the SAME drawer for
	# separator size 2 and disassembler size 3 -- NOT the
	# DrawDefault class default, Separator.java:25), in
	# drawer order: DrawRegion("-bottom") rects its region
	# at (x, y) with rotation 0; DrawLiquidTile() tiles the
	# current liquid over size*size tiles at amount /
	# capacity; DrawRegion("-spinner", 3, true) spinSprites
	# at totalProgress * 3 mod 90 (two rects, the second at
	# r - 90 with alpha factor r / 90); DrawDefault rects
	# block.region at drawrot() = 0 (Separator sets no
	# rotate). drawLight() (Separator.java:109-112) is the
	# super liquid light only (no drawer member overrides
	# drawLight): radius size * 30, opacity lightColor.a *
	# visualLiquid, visualLiquid lerping toward 1 / 0 at
	# 0.06 per delta. icons() (Separator.java:71-73) is the
	# DrawMulti concat: "-bottom", "-spinner", block.region.
	# drawPlanRegion() (Separator.java:66-69) draws the
	# bottom rect + the spinner spin at 0 + the fullIcon
	# rect + the team overlay when the world-context gate
	# passes. Pure-only: the tick never calls draw -- draw
	# is called by the renderer, and the renderer call site
	# waits for a renderer slice, so this proof has no
	# live-tick key.

	# --- Bottom rect: the "-bottom" region rects at (x, y)
	# with rotation 0, whatever the rotation / totalProgress
	# inputs are (rotateSpeed 0, buildingRotate false).
	var building: Dictionary = separator_build_state.source_separator_draw_state(100.0, 200.0, 2, 10.0, false, "ffa166", 0.4, 20.0, 40.0, 3, 0.0, 1.0, 2)
	var building_bottom: Dictionary = building.get("bottom_call", {})
	proof["draw_bottom"] = str(building_bottom.get("region", "")) == "block.name-bottom" and is_equal_approx(float(building_bottom.get("x", -1.0)), 100.0) and is_equal_approx(float(building_bottom.get("y", -1.0)), 200.0) and is_equal_approx(float(building_bottom.get("rotation", -1.0)), 0.0)

	# --- Liquid tiles: size 2 tiles 4 frames at (+/-4,
	# +/-4) around the center, alpha amount / capacity =
	# 20 / 40 = 0.5, color slag, frame fluidFrames[0][3]
	# (not gas, animation frame 3); size 3 tiles 9 frames
	# at -8 / 0 / 8 offsets; an empty tank (alpha 0 <
	# 1/255) draws no tiles.
	var building_liquid: Dictionary = building.get("liquid_call", {})
	var building_tiles: Array = building_liquid.get("tiles", [])
	var big: Dictionary = separator_build_state.source_separator_draw_state(0.0, 0.0, 0, 0.0, false, "ffa166", 0.4, 72.0, 72.0, 0, 0.0, 1.0, 3)
	var big_liquid: Dictionary = big.get("liquid_call", {})
	var big_tiles: Array = big_liquid.get("tiles", [])
	var empty: Dictionary = separator_build_state.source_separator_draw_state(0.0, 0.0, 0, 0.0, false, "ffa166", 0.4, 0.0, 40.0, 0, 0.0, 1.0, 2)
	var first_tile: Dictionary = building_tiles[0] if not building_tiles.is_empty() else {}
	var last_tile: Dictionary = building_tiles[building_tiles.size() - 1] if not building_tiles.is_empty() else {}
	proof["draw_liquid"] = int(building_liquid.get("tile_count", -1)) == 4 and building_tiles.size() == 4 and is_equal_approx(float(building_liquid.get("alpha", -1.0)), 0.5) and str(building_liquid.get("color", "")) == "ffa166" and str(building_liquid.get("frame", "")) == "fluidFrames[0][3]" and is_equal_approx(float(first_tile.get("x", -1.0)), 96.0) and is_equal_approx(float(first_tile.get("y", -1.0)), 196.0) and is_equal_approx(float(last_tile.get("x", -1.0)), 104.0) and is_equal_approx(float(last_tile.get("y", -1.0)), 204.0) and int(big_liquid.get("tile_count", -1)) == 9 and big_tiles.size() == 9 and is_equal_approx(float(big_liquid.get("alpha", -1.0)), 1.0) and Dictionary(empty.get("liquid_call", {"missing": true})).is_empty()

	# --- Spinner: the spin rotation is totalProgress * 3
	# mod 90 -- totalProgress 10 gives 30, totalProgress 40
	# gives 120 mod 90 = 30, totalProgress 0 gives 0 -- with
	# the second rect at r - 90 and alpha factor r / 90.
	var building_spinner: Dictionary = building.get("spinner_call", {})
	var spun: Dictionary = separator_build_state.source_separator_draw_state(0.0, 0.0, 0, 40.0, false, "ffa166", 0.4, 0.0, 40.0, 0, 0.0, 1.0, 2)
	var spun_spinner: Dictionary = spun.get("spinner_call", {})
	var still: Dictionary = separator_build_state.source_separator_draw_state(0.0, 0.0, 0, 0.0, false, "ffa166", 0.4, 0.0, 40.0, 0, 0.0, 1.0, 2)
	var still_spinner: Dictionary = still.get("spinner_call", {})
	proof["draw_spinner"] = str(building_spinner.get("region", "")) == "block.name-spinner" and is_equal_approx(float(building_spinner.get("rotation", -1.0)), 30.0) and is_equal_approx(float(building_spinner.get("second_rotation", -1.0)), -60.0) and is_equal_approx(float(building_spinner.get("second_alpha_factor", -1.0)), 30.0 / 90.0) and is_equal_approx(float(building.get("spinner_rotation", -1.0)), 30.0) and is_equal_approx(float(spun_spinner.get("rotation", -1.0)), 30.0) and is_equal_approx(float(still_spinner.get("rotation", -1.0)), 0.0) and is_equal_approx(float(still_spinner.get("second_alpha_factor", -1.0)), 0.0)

	# --- Base rect: the block.region rect draws at (x, y)
	# with rotation drawrot() = 0 even at rotation 2
	# (Separator sets no rotate, Block.java:120 default
	# false).
	var building_base: Dictionary = building.get("base_call", {})
	proof["draw_base"] = str(building_base.get("region", "")) == "block.region" and is_equal_approx(float(building_base.get("x", -1.0)), 100.0) and is_equal_approx(float(building_base.get("y", -1.0)), 200.0) and is_equal_approx(float(building_base.get("rotation", -1.0)), 0.0) and is_equal_approx(float(building.get("draw_rotation", -1.0)), 0.0)

	# --- Light call: with slag (light alpha 0.4) and a
	# half-full tank the light draws at (x, y) with radius
	# size * 30 = 60, color liquid.lightColor, opacity
	# 0.4 * visualLiquid (visual 0 -> 0.06 after one delta
	# tick, so opacity 0.024); with a dark liquid (light
	# alpha 0) the gate fails and no light draws.
	var building_light: Dictionary = building.get("draw_light_call", {})
	var dark: Dictionary = separator_build_state.source_separator_draw_state(0.0, 0.0, 0, 0.0, false, "313131", 0.0, 20.0, 40.0, 0, 1.0, 1.0, 2)
	proof["draw_light"] = not building_light.is_empty() and is_equal_approx(float(building_light.get("x", -1.0)), 100.0) and is_equal_approx(float(building_light.get("y", -1.0)), 200.0) and is_equal_approx(float(building_light.get("radius", -1.0)), 60.0) and str(building_light.get("color", "")) == "liquid.lightColor" and is_equal_approx(float(building_light.get("opacity", -1.0)), 0.024) and is_equal_approx(float(building_light.get("visual_liquid", -1.0)), 0.06) and Dictionary(dark.get("draw_light_call", {"missing": true})).is_empty()

	# --- Light visual: visualLiquid lerps toward 1 at
	# 0.06 * delta when the tank holds >= 0.01 (0 -> 0.06
	# in one tick) and toward 0 when empty (1 -> 0.94);
	# a full visual with a full tank stays 1.
	var drained: Dictionary = separator_build_state.source_separator_draw_state(0.0, 0.0, 0, 0.0, false, "ffa166", 0.4, 0.0, 40.0, 0, 1.0, 1.0, 2)
	var full: Dictionary = separator_build_state.source_separator_draw_state(0.0, 0.0, 0, 0.0, false, "ffa166", 0.4, 20.0, 40.0, 0, 1.0, 1.0, 2)
	proof["draw_light_visual"] = is_equal_approx(float(building.get("visual_liquid_after", -1.0)), 0.06) and is_equal_approx(float(drained.get("visual_liquid_after", -1.0)), 0.94) and is_equal_approx(float(full.get("visual_liquid_after", -1.0)), 1.0) and is_equal_approx(float(building.get("light_target", -1.0)), 1.0) and is_equal_approx(float(drained.get("light_target", -1.0)), 0.0)

	# --- Icons: the DrawMulti concat in drawer order --
	# "-bottom", "-spinner", block.region (DrawLiquidTile
	# contributes nothing).
	var icons: Array = building.get("icon_regions", [])
	proof["draw_icons"] = icons.size() == 3 and str(icons[0]) == "block.name-bottom" and str(icons[1]) == "block.name-spinner" and str(icons[2]) == "block.region"

	# --- Plan region: the bottom rect + the spinner spin
	# at 0 (second rect -90, alpha factor 0) + the fullIcon
	# rect all draw at the plan position with rotation 0,
	# whatever the plan rotation is (Separator sets no
	# rotate).
	var plan: Dictionary = separator_build_state.source_separator_draw_plan_state(300.0, 400.0, 3, false, false, false, false)
	var plan_bottom: Dictionary = plan.get("plan_bottom_call", {})
	var plan_spinner: Dictionary = plan.get("plan_spinner_call", {})
	var plan_main: Dictionary = plan.get("plan_call", {})
	proof["draw_plan_region"] = str(plan_bottom.get("region", "")) == "block.name-bottom" and is_equal_approx(float(plan_bottom.get("x", -1.0)), 300.0) and is_equal_approx(float(plan_bottom.get("y", -1.0)), 400.0) and is_equal_approx(float(plan_bottom.get("rotation", -1.0)), 0.0) and str(plan_spinner.get("region", "")) == "block.name-spinner" and is_equal_approx(float(plan_spinner.get("rotation", -1.0)), 0.0) and is_equal_approx(float(plan_spinner.get("second_rotation", -1.0)), -90.0) and is_equal_approx(float(plan_spinner.get("second_alpha_factor", -1.0)), 0.0) and str(plan_main.get("region", "")) == "fullIcon" and is_equal_approx(float(plan_main.get("x", -1.0)), 300.0) and is_equal_approx(float(plan_main.get("y", -1.0)), 400.0) and is_equal_approx(float(plan_main.get("rotation", -1.0)), 0.0) and Dictionary(plan.get("plan_team_call", {"missing": true})).is_empty()

	# --- Plan team: the team overlay draws only when the
	# world-context gate passes (world context + player +
	# found team region), carrying the team color only when
	# the team's region is the base team region.
	var teamed: Dictionary = separator_build_state.source_separator_draw_plan_state(300.0, 400.0, 0, true, true, true, true)
	var teamed_overlay: Dictionary = teamed.get("plan_team_call", {})
	var unteamed: Dictionary = separator_build_state.source_separator_draw_plan_state(300.0, 400.0, 0, true, true, true, false)
	var unteamed_overlay: Dictionary = unteamed.get("plan_team_call", {})
	var no_world: Dictionary = separator_build_state.source_separator_draw_plan_state(300.0, 400.0, 0, false, true, true, true)
	proof["draw_plan_team"] = not teamed_overlay.is_empty() and str(teamed_overlay.get("region", "")) == "teamRegions[player.team().id]" and is_equal_approx(float(teamed_overlay.get("x", -1.0)), 300.0) and is_equal_approx(float(teamed_overlay.get("y", -1.0)), 400.0) and str(teamed_overlay.get("color", "")) == "player.team().color" and not unteamed_overlay.is_empty() and str(unteamed_overlay.get("color", "")) == "" and Dictionary(no_world.get("plan_team_call", {"missing": true})).is_empty()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
