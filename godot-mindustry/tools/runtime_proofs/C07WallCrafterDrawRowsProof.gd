extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
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

	# --- Draw rows (N2426): WallCrafterBuild.draw()
	# (WallCrafter.java:231-244), icons() (:120-122),
	# drawPlanRegion() (:125-129), drawPlace()
	# (:131-135). draw() rects the block region, then
	# the top region at rotdeg() (rotation * 90), then
	# the rotator loop over the facing edge tiles: ds
	# 0.6f, dx/dy = d4(rotation) * ds, bs = (rotation
	# 0/3) ? 1 : -1, sign = idx++ >= size/2 && size %
	# 2 == 0 ? -1 : 1 (INT size/2 -- a size-2 crafter
	# flips the second rotator, a size-3 never flips),
	# vx/vy = (c - d) * tilesize at Layer.blockOver,
	# the rotatorBottom rect at totalTime *
	# rotateSpeed * sign * bs + the unrotated rotator
	# rect at the same vx/vy. icons() returns
	# [region, topRegion]. drawPlanRegion rects the
	# region + the top at plan.rotation * 90.
	# drawPlace writes the drillspeed text 60f /
	# drillTime * eff at 2 decimals (Strings.fixed
	# TRUNCATES, it does not round). Pure-only: the
	# tick never calls draw.

	# --- Base / top: a cliff-crusher (size 2) at
	# (80, 160), rotation 0 -- the base rect is the
	# block region at (80, 160) and the top rect is
	# the topRegion at (80, 160), rotation 0
	# (rotdeg 0 * 90). At rotation 1 the top draws
	# at 90.
	var flat_edges: Array = [{"cx": 12, "cy": 20}, {"cx": 12, "cy": 21}]
	var flat_plan: Dictionary = {"drawx": 84.0, "drawy": 164.0, "rotation": 1}
	var flat_draw: Dictionary = wall_crafter_build_state.source_wall_crafter_draw_state(80.0, 160.0, 0, 2, 10.0, 2.0, flat_edges, 2.0, 110.0, flat_plan, 10, 20, true)
	var flat_base: Dictionary = flat_draw.get("base_call", {})
	var flat_top: Dictionary = flat_draw.get("top_call", {})
	var turned_draw: Dictionary = wall_crafter_build_state.source_wall_crafter_draw_state(80.0, 160.0, 1, 2, 10.0, 2.0, [{"cx": 10, "cy": 22}, {"cx": 11, "cy": 22}], 2.0, 110.0, flat_plan, 10, 20, true)
	var turned_top: Dictionary = turned_draw.get("top_call", {})
	proof["draw_base_top"] = str(flat_base.get("region", "")) == "region" and is_equal_approx(float(flat_base.get("x", -1.0)), 80.0) and is_equal_approx(float(flat_base.get("y", -1.0)), 160.0) and str(flat_top.get("region", "")) == "topRegion" and is_equal_approx(float(flat_top.get("x", -1.0)), 80.0) and is_equal_approx(float(flat_top.get("y", -1.0)), 160.0) and is_equal_approx(float(flat_top.get("rotation", -1.0)), 0.0) and is_equal_approx(float(flat_draw.get("rotdeg", -1.0)), 0.0) and is_equal_approx(float(turned_top.get("rotation", -1.0)), 90.0) and is_equal_approx(float(turned_draw.get("rotdeg", -1.0)), 90.0)

	# --- Rotator loop: the rotation-0 cliff-crusher
	# above (tile (10, 20), facing edge (12, 20) /
	# (12, 21)) -- d4x 1 / d4y 0, so dx 0.6 / dy 0;
	# vx (12 - 0.6) * 8 = 91.2, vy 160 / 168; bs 1;
	# the size-2 INT size/2 = 1 flips the second
	# rotator (signs 1 / -1), so with totalTime 10
	# and rotateSpeed 2 the bottom rotations are
	# 20 / -20, both at Layer.blockOver, each with
	# its unrotated rotator rect at the same vx/vy.
	# A size-3 large-cliff-crusher (rotation 3,
	# facing edge (9, 18) / (10, 18) / (11, 18),
	# totalTime 5) never flips -- all three signs
	# are 1 (odd size fails the % 2 gate) -- with
	# vx 72 / 80 / 88, vy (18 + 0.6) * 8 = 148.8,
	# rotation 10 each.
	var flat_rotators: Array = flat_draw.get("rotator_calls", [])
	var flat_first: Dictionary = flat_rotators[0] if flat_rotators.size() > 0 else {}
	var flat_second: Dictionary = flat_rotators[1] if flat_rotators.size() > 1 else {}
	var flat_first_bottom: Dictionary = flat_first.get("bottom_call", {})
	var flat_first_rotator: Dictionary = flat_first.get("rotator_call", {})
	var flat_second_bottom: Dictionary = flat_second.get("bottom_call", {})
	var large_edges: Array = [{"cx": 9, "cy": 18}, {"cx": 10, "cy": 18}, {"cx": 11, "cy": 18}]
	var large_draw: Dictionary = wall_crafter_build_state.source_wall_crafter_draw_state(80.0, 160.0, 3, 3, 5.0, 2.0, large_edges, 3.0, 48.0, flat_plan, 10, 20, true)
	var large_rotators: Array = large_draw.get("rotator_calls", [])
	var large_first: Dictionary = large_rotators[0] if large_rotators.size() > 0 else {}
	var large_second: Dictionary = large_rotators[1] if large_rotators.size() > 1 else {}
	var large_third: Dictionary = large_rotators[2] if large_rotators.size() > 2 else {}
	proof["draw_rotator_loop"] = flat_rotators.size() == 2 and is_equal_approx(float(flat_draw.get("dx", -1.0)), 0.6) and is_equal_approx(float(flat_draw.get("dy", -1.0)), 0.0) and int(flat_draw.get("bs", 0)) == 1 and int(flat_first.get("cx", -1)) == 12 and int(flat_first.get("cy", -1)) == 20 and is_equal_approx(float(flat_first.get("vx", -1.0)), 91.2) and is_equal_approx(float(flat_first.get("vy", -1.0)), 160.0) and int(flat_first.get("sign", 0)) == 1 and is_equal_approx(float(flat_first.get("rotation", -1.0)), 20.0) and str(flat_first.get("z", "")) == "Layer.blockOver" and str(flat_first_bottom.get("region", "")) == "rotatorBottomRegion" and is_equal_approx(float(flat_first_bottom.get("rotation", -1.0)), 20.0) and str(flat_first_rotator.get("region", "")) == "rotatorRegion" and is_equal_approx(float(flat_first_rotator.get("vx", -1.0)), 91.2) and is_equal_approx(float(flat_first_rotator.get("vy", -1.0)), 160.0) and int(flat_second.get("cx", -1)) == 12 and int(flat_second.get("cy", -1)) == 21 and is_equal_approx(float(flat_second.get("vx", -1.0)), 91.2) and is_equal_approx(float(flat_second.get("vy", -1.0)), 168.0) and int(flat_second.get("sign", 0)) == -1 and is_equal_approx(float(flat_second.get("rotation", -1.0)), -20.0) and is_equal_approx(float(flat_second_bottom.get("rotation", -1.0)), -20.0) and large_rotators.size() == 3 and int(large_first.get("sign", 0)) == 1 and int(large_second.get("sign", 0)) == 1 and int(large_third.get("sign", 0)) == 1 and is_equal_approx(float(large_first.get("vx", -1.0)), 72.0) and is_equal_approx(float(large_second.get("vx", -1.0)), 80.0) and is_equal_approx(float(large_third.get("vx", -1.0)), 88.0) and is_equal_approx(float(large_first.get("vy", -1.0)), 148.8) and is_equal_approx(float(large_first.get("rotation", -1.0)), 10.0) and is_equal_approx(float(large_second.get("rotation", -1.0)), 10.0) and is_equal_approx(float(large_third.get("rotation", -1.0)), 10.0)

	# --- DrawPlace drillspeed: the cliff-crusher at
	# eff 2.0 / drillTime 110 gives 60 / 110 * 2 =
	# 1.0909..., fixed to "1.09" -- "Drill Speed:
	# 1.09/s". The truncation probe (drillTime 60,
	# eff 1.099) gives 1.099, which Strings.fixed
	# TRUNCATES to "1.09" where rounding would give
	# "1.10". The large def at eff 3.0 / drillTime
	# 48 gives exactly 3.75. At eff 0 the text is
	# "Drill Speed: 0.00/s".
	var flat_place: Dictionary = flat_draw.get("place_call", {})
	var trunc_draw: Dictionary = wall_crafter_build_state.source_wall_crafter_draw_state(0.0, 0.0, 0, 2, 0.0, 2.0, [], 1.099, 60.0, flat_plan, 10, 20, true)
	var trunc_place: Dictionary = trunc_draw.get("place_call", {})
	var large_place: Dictionary = large_draw.get("place_call", {})
	var empty_draw: Dictionary = wall_crafter_build_state.source_wall_crafter_draw_state(0.0, 0.0, 0, 2, 0.0, 2.0, [], 0.0, 110.0, flat_plan, 10, 20, false)
	var empty_place: Dictionary = empty_draw.get("place_call", {})
	proof["draw_place_drillspeed"] = str(flat_place.get("bundle_key", "")) == "bar.drillspeed" and int(flat_place.get("decimals", -1)) == 2 and is_equal_approx(float(flat_place.get("drillspeed", -1.0)), 60.0 / 110.0 * 2.0) and str(flat_place.get("value_text", "")) == "1.09" and str(flat_place.get("text", "")) == "Drill Speed: 1.09/s" and int(flat_place.get("tile_x", -1)) == 10 and int(flat_place.get("tile_y", -1)) == 20 and bool(flat_place.get("valid", false)) and str(trunc_place.get("value_text", "")) == "1.09" and str(trunc_place.get("text", "")) == "Drill Speed: 1.09/s" and is_equal_approx(float(large_place.get("drillspeed", -1.0)), 3.75) and str(large_place.get("value_text", "")) == "3.75" and str(large_place.get("text", "")) == "Drill Speed: 3.75/s" and is_equal_approx(float(empty_place.get("drillspeed", -1.0)), 0.0) and str(empty_place.get("value_text", "")) == "0.00" and str(empty_place.get("text", "")) == "Drill Speed: 0.00/s" and not bool(empty_place.get("valid", true))

	# --- DrawPlanRegion: plan at draw (84, 164),
	# rotation 1 -- the region rect at (84, 164) and
	# the top rect at (84, 164), rotation 90. At plan
	# rotation 3 the top draws at 270.
	var flat_plan_call: Dictionary = flat_draw.get("plan_call", {})
	var flat_plan_region: Dictionary = flat_plan_call.get("region_call", {})
	var flat_plan_top: Dictionary = flat_plan_call.get("top_call", {})
	var spun_plan: Dictionary = {"drawx": 84.0, "drawy": 164.0, "rotation": 3}
	var spun_draw: Dictionary = wall_crafter_build_state.source_wall_crafter_draw_state(0.0, 0.0, 0, 2, 0.0, 2.0, [], 0.0, 110.0, spun_plan, 0, 0, true)
	var spun_plan_call: Dictionary = spun_draw.get("plan_call", {})
	var spun_plan_top: Dictionary = spun_plan_call.get("top_call", {})
	proof["draw_plan_region"] = str(flat_plan_region.get("region", "")) == "region" and is_equal_approx(float(flat_plan_region.get("x", -1.0)), 84.0) and is_equal_approx(float(flat_plan_region.get("y", -1.0)), 164.0) and str(flat_plan_top.get("region", "")) == "topRegion" and is_equal_approx(float(flat_plan_top.get("x", -1.0)), 84.0) and is_equal_approx(float(flat_plan_top.get("y", -1.0)), 164.0) and is_equal_approx(float(flat_plan_top.get("rotation", -1.0)), 90.0) and is_equal_approx(float(spun_plan_top.get("rotation", -1.0)), 270.0)

	# --- Icons: [region, topRegion], in Java order --
	# folded into the draw pure (icons() takes no args
	# and the SSOT schema validator requires non-empty
	# input keys), the two regions draw() draws.
	proof["draw_icons"] = (flat_draw.get("icon_regions", []) as Array) == ["region", "topRegion"]

	# --- Rotation branch: bs is 1 for rotations 0
	# and 3, -1 for rotations 1 and 2; rotdeg is
	# rotation * 90 (0 / 90 / 180 / 270); the d4
	# step is (0.6, 0) / (0, 0.6) / (-0.6, 0) /
	# (0, -0.6). At rotation 1 the bs -1 flips the
	# first rotator's spin: totalTime 10,
	# rotateSpeed 2, sign 1 gives -20 (facing edge
	# (10, 22) / (11, 22): vx 80 / 88, vy
	# (22 - 0.6) * 8 = 171.2). At rotation 2 the
	# first rotator sits at vx (9 + 0.6) * 8 = 76.8.
	var turned_rotators: Array = turned_draw.get("rotator_calls", [])
	var turned_first: Dictionary = turned_rotators[0] if turned_rotators.size() > 0 else {}
	var turned_second: Dictionary = turned_rotators[1] if turned_rotators.size() > 1 else {}
	var back_draw: Dictionary = wall_crafter_build_state.source_wall_crafter_draw_state(80.0, 160.0, 2, 2, 10.0, 2.0, [{"cx": 9, "cy": 20}, {"cx": 9, "cy": 21}], 2.0, 110.0, flat_plan, 10, 20, true)
	var back_rotators: Array = back_draw.get("rotator_calls", [])
	var back_first: Dictionary = back_rotators[0] if back_rotators.size() > 0 else {}
	proof["draw_rotation_branch"] = int(flat_draw.get("bs", 0)) == 1 and int(turned_draw.get("bs", 0)) == -1 and int(back_draw.get("bs", 0)) == -1 and int(large_draw.get("bs", 0)) == 1 and is_equal_approx(float(flat_draw.get("rotdeg", -1.0)), 0.0) and is_equal_approx(float(turned_draw.get("rotdeg", -1.0)), 90.0) and is_equal_approx(float(back_draw.get("rotdeg", -1.0)), 180.0) and is_equal_approx(float(large_draw.get("rotdeg", -1.0)), 270.0) and is_equal_approx(float(flat_draw.get("dx", -1.0)), 0.6) and is_equal_approx(float(flat_draw.get("dy", -1.0)), 0.0) and is_equal_approx(float(turned_draw.get("dx", -1.0)), 0.0) and is_equal_approx(float(turned_draw.get("dy", -1.0)), 0.6) and is_equal_approx(float(back_draw.get("dx", -1.0)), -0.6) and is_equal_approx(float(back_draw.get("dy", -1.0)), 0.0) and is_equal_approx(float(large_draw.get("dx", -1.0)), 0.0) and is_equal_approx(float(large_draw.get("dy", -1.0)), -0.6) and is_equal_approx(float(turned_first.get("vx", -1.0)), 80.0) and is_equal_approx(float(turned_first.get("vy", -1.0)), 171.2) and is_equal_approx(float(turned_first.get("rotation", -1.0)), -20.0) and is_equal_approx(float(turned_second.get("vx", -1.0)), 88.0) and is_equal_approx(float(turned_second.get("rotation", -1.0)), 20.0) and is_equal_approx(float(back_first.get("vx", -1.0)), 76.8) and is_equal_approx(float(back_first.get("vy", -1.0)), 160.0) and is_equal_approx(float(back_first.get("rotation", -1.0)), -20.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterDrawRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
