extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_router_build_state := preload("res://src/game/SourceStackRouterBuildState.gd")
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

	# --- Stats / plan rows (N2442): StackRouter
	# inherits setStats() (DuctRouter.java:48-52),
	# drawPlanRegion() (:60-63), minimapColor()
	# (:66-69) and rotatedOutput() (:72-74) from
	# DuctRouter (StackRouter.java:11) and
	# overrides NONE of them. setStats() adds
	# stats.add(Stat.itemsMoved, 60f / speed *
	# itemCapacity, StatUnit.itemsSecond) -- the
	# float math is Java-exact: 60f / speed
	# FIRST, then times itemCapacity. The class
	# defaults are speed 5f (DuctRouter.java:19)
	# and itemCapacity 10 (StackRouter.java:20),
	# so the class-default rate is 60 / 5 * 10 =
	# 120. drawPlanRegion() draws the base rect
	# at the plan position and the top rect at
	# the plan position rotated plan.rotation *
	# 90. minimapColor() returns 0 when the build
	# or the sort item is null, else
	# sortItem.color.rgba() -- the rgba8888 int
	# (arc Color.java:365-367), NOT a string
	# token. rotatedOutput() returns false.
	# Pure-only: the tick never calls setStats /
	# drawPlanRegion / minimapColor /
	# rotatedOutput.

	# --- Stats math: 60f / speed * itemCapacity
	# with the division FIRST -- 60 / 5 * 10 =
	# 120 at the class defaults, 60 / 6 * 10 =
	# 100 for the surge-router def (speed 6f,
	# Blocks.java:2259, no itemCapacity
	# override), 60 / 4 * 1 = 15 for the
	# duct-router def (speed 4f, Blocks.
	# java:2196, the DuctRouter class
	# itemCapacity 1).
	var class_stats: Dictionary = stack_router_build_state.source_stack_router_stats_state(5.0, 10)
	var surge_stats: Dictionary = stack_router_build_state.source_stack_router_stats_state(6.0, 10)
	var duct_stats: Dictionary = stack_router_build_state.source_stack_router_stats_state(4.0, 1)
	proof["stats_math"] = is_equal_approx(float(class_stats.get("items_moved_per_second", -1.0)), 120.0) and is_equal_approx(float(surge_stats.get("items_moved_per_second", -1.0)), 100.0) and is_equal_approx(float(duct_stats.get("items_moved_per_second", -1.0)), 15.0)

	# --- Stats tokens: the exact Stat /
	# StatUnit tokens -- "itemsMoved"
	# (Stat.java:52) and "itemsSecond"
	# (StatUnit.java:20).
	proof["stats_tokens"] = str(class_stats.get("stat_key", "")) == "itemsMoved" and str(class_stats.get("stat_unit", "")) == "itemsSecond" and str(class_stats.get("set_stats_expr", "")) == "stats.add(Stat.itemsMoved, 60f / speed * itemCapacity, StatUnit.itemsSecond);"

	# --- Plan base: a plan at (100, 200) --
	# the base call draws region at (100, 200)
	# unrotated, and the top call draws
	# topRegion at (100, 200) too.
	var plan: Dictionary = stack_router_build_state.source_stack_router_draw_plan_state(100.0, 200.0, 1, null)
	var plan_base: Dictionary = plan.get("base_call", {})
	var plan_top: Dictionary = plan.get("top_call", {})
	proof["plan_base"] = is_equal_approx(float(plan_base.get("x", -1.0)), 100.0) and is_equal_approx(float(plan_base.get("y", -1.0)), 200.0) and str(plan_base.get("region", "")) == "region" and str(plan_base.get("call", "")) == "Draw.rect(region, plan.drawx(), plan.drawy());" and is_equal_approx(float(plan_top.get("x", -1.0)), 100.0) and is_equal_approx(float(plan_top.get("y", -1.0)), 200.0) and str(plan_top.get("region", "")) == "topRegion" and str(plan_top.get("call", "")) == "Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);"

	# --- Plan top rotation: the top rect sits
	# at plan.rotation * 90 (rotation 1 -> 90,
	# rotation 3 -> 270, rotation 0 -> 0).
	var back_plan: Dictionary = stack_router_build_state.source_stack_router_draw_plan_state(100.0, 200.0, 3, null)
	var back_top: Dictionary = back_plan.get("top_call", {})
	var flat_plan: Dictionary = stack_router_build_state.source_stack_router_draw_plan_state(100.0, 200.0, 0, null)
	var flat_top: Dictionary = flat_plan.get("top_call", {})
	proof["plan_top_rotdeg"] = is_equal_approx(float(plan_top.get("rotation", -1.0)), 90.0) and is_equal_approx(float(plan.get("rotdeg", -1.0)), 90.0) and is_equal_approx(float(back_top.get("rotation", -1.0)), 270.0) and is_equal_approx(float(flat_top.get("rotation", -1.0)), 0.0)

	# --- Minimap color: 0 when the sort item
	# is null (both null branches -- no build
	# means no sortItem), else the sort item
	# color rgba8888 int. Surge-alloy is
	# Color.valueOf("f3e979") (Items.java:83),
	# rgba8888 0xf3e979ff, the Java signed int
	# -202802689.
	var sorted_plan: Dictionary = stack_router_build_state.source_stack_router_draw_plan_state(100.0, 200.0, 1, {"name": "surge-alloy", "color": -202802689})
	proof["plan_minimap"] = int(plan.get("minimap_color", -1)) == 0 and int(sorted_plan.get("minimap_color", -1)) == -202802689

	# --- Rotated output: rotatedOutput() is
	# always false, whatever the plan rotation.
	proof["plan_rotated_output"] = plan.get("rotated_output", true) == false and back_plan.get("rotated_output", true) == false and flat_plan.get("rotated_output", true) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterStatsPlanRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
