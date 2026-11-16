extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_conveyor_build_state := preload("res://src/game/SourceStackConveyorBuildState.gd")
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

	# --- Blends / plan / rotatedOutput rows
	# (N2448): StackConveyor.blends()
	# (StackConveyor.java:71-88),
	# drawPlanRegion() (:90-104) and
	# rotatedOutput() (:106-112). The state
	# constants are stateMove 0 / stateLoad 1 /
	# stateUnload 2 (StackConveyor.java:25).
	# blends() reads the tile build state: load
	# -> outputsItems() && lookingAtEither(...);
	# unload && !outputRouter -> the router-mode
	# gate; anything else (not a stack build,
	# stateMove, unload with outputRouter)
	# falls through to outputsItems() &&
	# blendsArmored(...) && instanceof
	# StackConveyor. Every geometry / indexer
	# predicate is caller-supplied -- the pure
	# NEVER reads world / tile. drawPlanRegion()
	# reads bits = getTiling(plan, list)
	# (caller-supplied; getTiling itself is NOT
	# ported): null -> return; regions[0] at
	# plan.rotation * 90, then the edge loop
	# over bits[3] with (plan.rotation - i) *
	# 90. rotatedOutput() returns s.state !=
	# stateUnload for a StackConveyorBuild
	# tile, else the super call (Block.
	# java:615-617, return rotate;).
	# Pure-only: the tick never calls blends /
	# drawPlanRegion / rotatedOutput.

	# --- Blends load branch: stateLoad (1)
	# blends when the other block outputs items
	# AND either side looks at the other; false
	# when either half fails. The state is the
	# Variant null-or-int: null means the tile
	# build is NOT a StackConveyorBuild.
	var load_ok: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(1, false, true, false, false, true, false, false, false, false, false, false)
	var load_no_look: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(1, false, true, false, false, false, false, false, false, false, false, false)
	var load_no_out: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(1, false, false, false, false, true, false, false, false, false, false, false)
	proof["blends_load"] = load_ok.get("blends", false) == true and load_no_look.get("blends", true) == false and load_no_out.get("blends", true) == false

	# --- Blends router branch: stateUnload
	# (2) && !outputRouter blends when the
	# other block accepts items AND the
	# noSideBlend / lookingAtEither half holds
	# AND the notLookingAt / facing half holds
	# AND the other build is NOT unloading AND
	# NOT moving away. The facing half covers
	# the notLookingAt=false case when the
	# other block IS a StackConveyor facing
	# this tile.
	var router_ok: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(2, false, false, true, false, false, true, false, false, false, false, false)
	var router_facing: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(2, false, false, true, true, true, false, true, false, false, false, true)
	var router_no_accept: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(2, false, false, false, false, false, true, false, false, false, false, false)
	var router_other_unload: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(2, false, false, true, false, false, true, false, true, false, false, false)
	var router_move_away: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(2, false, false, true, false, false, true, false, false, true, false, false)
	proof["blends_unload_router"] = router_ok.get("blends", false) == true and router_facing.get("blends", false) == true and router_no_accept.get("blends", true) == false and router_other_unload.get("blends", true) == false and router_move_away.get("blends", true) == false

	# --- Blends fallback: not a stack build
	# (state null), stateMove (0), or unload
	# with outputRouter all fall through to
	# outputsItems() && blendsArmored(...) &&
	# instanceof StackConveyor.
	var fb_null: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(null, false, true, false, false, false, false, false, false, false, true, true)
	var fb_null_no_stack: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(null, false, true, false, false, false, false, false, false, false, true, false)
	var fb_move: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(0, false, true, false, false, false, false, false, false, false, true, true)
	var fb_router_out: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(2, true, true, false, false, false, false, false, false, false, true, true)
	var fb_router_out_no_armor: Dictionary = stack_conveyor_build_state.source_stack_conveyor_blends_state(2, true, true, false, false, false, false, false, false, false, false, true)
	proof["blends_fallback"] = fb_null.get("blends", false) == true and fb_null_no_stack.get("blends", true) == false and fb_move.get("blends", false) == true and fb_router_out.get("blends", false) == true and fb_router_out_no_armor.get("blends", true) == false

	# --- Plan null bits: bits null (getTiling
	# returned null, Autotiler.java:78) means
	# drawPlanRegion returns before drawing
	# anything -- both calls null.
	var null_plan: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_plan_state(null, 100.0, 200.0, 1)
	proof["plan_bits_null"] = null_plan.get("base_call", {}) == null and null_plan.get("edge_calls", []) == null

	# --- Plan edges: a plan at (100, 200),
	# rotation 1, bits[3] = 10 (0b1010: bits 1
	# and 3 set) draws the regions[0] base at
	# 90 plus edgeRegion rects at sides 0 and 2
	# only, at (rotation - i) * 90 = 90 and
	# -90. bits[3] = 0 draws all four edges;
	# bits[3] = 15 draws none.
	var plan: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_plan_state([0, 0, 0, 10], 100.0, 200.0, 1)
	var plan_base: Dictionary = plan.get("base_call", {})
	var plan_edges: Array = plan.get("edge_calls", [])
	var all_plan: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_plan_state([0, 0, 0, 0], 100.0, 200.0, 1)
	var none_plan: Dictionary = stack_conveyor_build_state.source_stack_conveyor_draw_plan_state([0, 0, 0, 15], 100.0, 200.0, 1)
	var edge0: Dictionary = plan_edges[0] if plan_edges.size() > 0 else {}
	var edge1: Dictionary = plan_edges[1] if plan_edges.size() > 1 else {}
	proof["plan_edges"] = is_equal_approx(float(plan_base.get("x", -1.0)), 100.0) and is_equal_approx(float(plan_base.get("y", -1.0)), 200.0) and str(plan_base.get("region", "")) == "regions[0]" and str(plan_base.get("call", "")) == "Draw.rect(region, plan.drawx(), plan.drawy(), plan.rotation * 90);" and is_equal_approx(float(plan_base.get("rotation", -1.0)), 90.0) and plan_edges.size() == 2 and int(edge0.get("side", -1)) == 0 and is_equal_approx(float(edge0.get("rotation", -1.0)), 90.0) and str(edge0.get("region", "")) == "edgeRegion" and int(edge1.get("side", -1)) == 2 and is_equal_approx(float(edge1.get("rotation", -1.0)), -90.0) and str(edge1.get("region", "")) == "edgeRegion" and is_equal_approx(float(edge0.get("x", -1.0)), 100.0) and is_equal_approx(float(edge1.get("y", -1.0)), 200.0) and (all_plan.get("edge_calls", []) as Array).size() == 4 and (none_plan.get("edge_calls", []) as Array).size() == 0

	# --- Rotated output: a StackConveyorBuild
	# tile returns s.state != stateUnload (2);
	# any other tile returns the super call
	# (Block.java:615-617, return rotate; --
	# caller-supplied here).
	var rot_unload: Dictionary = stack_conveyor_build_state.source_stack_conveyor_rotated_output_state(true, 2, true)
	var rot_load: Dictionary = stack_conveyor_build_state.source_stack_conveyor_rotated_output_state(true, 1, false)
	var rot_move: Dictionary = stack_conveyor_build_state.source_stack_conveyor_rotated_output_state(true, 0, false)
	var rot_super_true: Dictionary = stack_conveyor_build_state.source_stack_conveyor_rotated_output_state(false, 2, true)
	var rot_super_false: Dictionary = stack_conveyor_build_state.source_stack_conveyor_rotated_output_state(false, 0, false)
	proof["rotated_output"] = rot_unload.get("rotated_output", true) == false and rot_load.get("rotated_output", false) == true and rot_move.get("rotated_output", false) == true and rot_super_true.get("rotated_output", false) == true and rot_super_false.get("rotated_output", true) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackConveyorBlendsPlanRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
