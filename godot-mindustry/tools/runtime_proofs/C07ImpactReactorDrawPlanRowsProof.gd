extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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

	# --- DrawPlan rows (N2438): PowerGenerator.
	# drawPlanRegion() (PowerGenerator.java:84-85,
	# drawer.drawPlan(this, plan, list)) through the
	# SAME DrawMulti class-default drawer as the draw
	# pure (ImpactReactor.java:34) -- DrawRegion(
	# "-bottom"), DrawPlasma(), DrawDefault() -- and
	# DrawMulti.drawPlan iterates in drawer order
	# (DrawMulti.java:40-43). The -bottom member
	# rects its plan region at the plan position,
	# rotation 0; DrawPlasma draws NOTHING in the
	# plan (no drawPlan() override in DrawPlasma or
	# its parent DrawFlame -- the base is the no-op
	# DrawBlock.drawPlan); DrawDefault draws the
	# default plan region (fullIcon, rotation 0 --
	# ImpactReactor sets no rotate) plus the team
	# overlay, only in a world context with a
	# player and a found team region, coloring the
	# team color only when the team's region IS the
	# base team region. PowerGenerator.
	# drawPlanRegion draws NO region of its own --
	# it only delegates to drawer.drawPlan -- so
	# the generator call records the delegation.
	# Pure-only: the tick never plans.

	# --- Bottom: a plan at (100, 200), rotation 0,
	# no world context, draws the -bottom plan rect
	# at (100, 200), rotation 0 (buildingRotate
	# false, rotation 0). The region is
	# impact-reactor-bottom.
	var planned: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_plan_state(100.0, 200.0, 0, false, false, false, false)
	var plan_bottom_call: Dictionary = planned.get("plan_bottom_call", {})
	proof["draw_plan_bottom"] = str(plan_bottom_call.get("region", "")) == "impact-reactor-bottom" and is_equal_approx(float(plan_bottom_call.get("x", -1.0)), 100.0) and is_equal_approx(float(plan_bottom_call.get("y", -1.0)), 200.0) and is_equal_approx(float(plan_bottom_call.get("rotation", -1.0)), 0.0)

	# --- Default: the default plan region is the
	# fullIcon rect at (100, 200), rotation 0
	# (ImpactReactor sets no rotate, so the
	# !rotate || !rotateDraw branch folds to 0).
	var plan_call: Dictionary = planned.get("plan_call", {})
	proof["draw_plan_default"] = str(plan_call.get("region", "")) == "fullIcon" and is_equal_approx(float(plan_call.get("x", -1.0)), 100.0) and is_equal_approx(float(plan_call.get("y", -1.0)), 200.0) and is_equal_approx(float(plan_call.get("rotation", -1.0)), 0.0) and is_equal_approx(float(planned.get("plan_rotation_value", -1.0)), 0.0)

	# --- Generator: the PowerGenerator delegation
	# records drawer.drawPlan(this, plan, list)
	# through the DrawMulti, members in drawer
	# order -- and DrawPlasma contributes NO plan
	# call (the empty dict: no drawPlan override,
	# the DrawBlock no-op base).
	var plan_generator_call: Dictionary = planned.get("plan_generator_call", {})
	proof["draw_plan_generator"] = str(plan_generator_call.get("call", "")) == "drawer.drawPlan(this, plan, list);" and str(plan_generator_call.get("drawer", "")) == "DrawMulti" and (plan_generator_call.get("members", []) as Array) == ["DrawRegion(-bottom)", "DrawPlasma", "DrawDefault"] and (planned.get("plan_plasma_call", {"nonempty": true}) as Dictionary).is_empty()

	# --- Team on: in a world context with a
	# player and a found team region, the overlay
	# draws teamRegions[player.team().id] at the
	# plan position -- in the team color when the
	# team region IS the base team region, and
	# with no team color when it is not.
	var team_on: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_plan_state(100.0, 200.0, 0, true, true, true, true)
	var team_on_call: Dictionary = team_on.get("plan_team_call", {})
	var team_other: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_plan_state(100.0, 200.0, 0, true, true, true, false)
	var team_other_call: Dictionary = team_other.get("plan_team_call", {})
	proof["draw_plan_team_on"] = bool(team_on.get("team_gate", false)) and str(team_on_call.get("region", "")) == "teamRegions[player.team().id]" and is_equal_approx(float(team_on_call.get("x", -1.0)), 100.0) and is_equal_approx(float(team_on_call.get("y", -1.0)), 200.0) and str(team_on_call.get("color", "")) == "player.team().color" and bool(team_other.get("team_gate", false)) and str(team_other_call.get("region", "")) == "teamRegions[player.team().id]" and str(team_other_call.get("color", "x")) == ""

	# --- Team off: without a world context, or
	# without a player, or without a found team
	# region, the gate fails and the overlay is the
	# empty dict -- the bottom / default rects
	# still draw.
	var no_context: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_plan_state(100.0, 200.0, 0, false, true, true, true)
	var no_player: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_plan_state(100.0, 200.0, 0, true, false, true, true)
	var no_region: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_plan_state(100.0, 200.0, 0, true, true, false, true)
	proof["draw_plan_team_off"] = not bool(no_context.get("team_gate", true)) and (no_context.get("plan_team_call", {"nonempty": true}) as Dictionary).is_empty() and not bool(no_player.get("team_gate", true)) and (no_player.get("plan_team_call", {"nonempty": true}) as Dictionary).is_empty() and not bool(no_region.get("team_gate", true)) and (no_region.get("plan_team_call", {"nonempty": true}) as Dictionary).is_empty() and not (no_context.get("plan_bottom_call", {}) as Dictionary).is_empty() and not (no_context.get("plan_call", {}) as Dictionary).is_empty()

	# --- Rotation: a plan rotated 2 (180 degrees
	# in Java) still draws every plan rect at
	# rotation 0 -- ImpactReactor sets no rotate,
	# so the plan rotation folds away in both the
	# -bottom rect (buildingRotate false) and the
	# default region (!rotate || !rotateDraw).
	var rotated: Dictionary = impact_reactor_build_state.source_impact_reactor_draw_plan_state(100.0, 200.0, 2, false, false, false, false)
	var rotated_bottom_call: Dictionary = rotated.get("plan_bottom_call", {})
	var rotated_call: Dictionary = rotated.get("plan_call", {})
	proof["draw_plan_rotation"] = int(rotated.get("plan_rotation", -1)) == 2 and is_equal_approx(float(rotated.get("plan_rotation_value", -1.0)), 0.0) and is_equal_approx(float(rotated_bottom_call.get("rotation", -1.0)), 0.0) and is_equal_approx(float(rotated_call.get("rotation", -1.0)), 0.0) and is_equal_approx(float(rotated_bottom_call.get("x", -1.0)), 100.0) and is_equal_approx(float(rotated_bottom_call.get("y", -1.0)), 200.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorDrawPlanRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
