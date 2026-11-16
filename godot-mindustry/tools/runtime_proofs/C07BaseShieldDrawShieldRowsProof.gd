extends Node

const main_scene := preload("res://scenes/Main.tscn")
const base_shield_build_state := preload("res://src/game/SourceBaseShieldBuildState.gd")
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

	# --- DrawShield + drawSelect rows (N2441):
	# BaseShieldBuild.drawShield() (BaseShield.java:125-147)
	# + drawSelect() (BaseShield.java:106-110), one
	# pure-only draw pure (the N2439 precedent: pures
	# return draw-call dicts, they never draw for real).
	# drawShield() is `if(!broken){` + `float radius =
	# radius();` (:127, radius() = smoothRadius, :101-103)
	# + `Draw.z(Layer.shields);` (z 125, Layer.java:87) +
	# `Draw.color(shieldColor == null ? team.color :
	# shieldColor, Color.white, Mathf.clamp(hit));` (the
	# mix lerps the base toward white by clamp(hit), arc
	# Draw.java:234-236; clamp is [0,1], arc
	# Mathf.java:402-404). The animated branch
	# (`if(renderer.animateShields){`, :133 -- the renderer
	# flag, Renderer.java:42) draws ONLY the fill; the
	# static branch strokes 1.5f, fills at alpha 0.09 +
	# clamp(0.08 * hit) (the sum is NOT clamped), resets
	# alpha to 1f, then draws the outline. drawSelect() is
	# super.drawSelect() (recorded, NOT ported) +
	# Drawf.dashCircle(x, y, radius, team.color) with the
	# FIELD radius (`public float radius = 200f;`, :20) --
	# NOT radius() = smoothRadius. The fixture building
	# sits at (80, 160) with smooth radius 150.0 and field
	# radius 200.0 -- the two radii deliberately differ so
	# the dash key proves the FIELD radius, and the large
	# def field radius 400f (Blocks.java:2060) is covered
	# too. The colors are String tokens (the N2439
	# Pal.placing token precedent): "team.color" for the
	# team color, "shieldColor" for a set shield color.
	var build_x := 80.0
	var build_y := 160.0
	var smooth_radius := 150.0
	var field_radius := 200.0
	var large_field_radius := 400.0
	var team_color := "team.color"
	var shield_color := "shieldColor"

	# --- Broken gate: broken=true nulls the shield call,
	# the fill call and the line call (the whole if(!broken)
	# block is skipped) -- but the dash call SURVIVES, with
	# the FIELD radius: drawSelect has no broken gate.
	var broken: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, true, smooth_radius, field_radius, 0.5, null, team_color, false)
	var broken_dash: Dictionary = broken.get("dash_call", {})
	proof["draw_shield_broken_gate"] = broken.get("shield_call", {}) == null and broken.get("fill_call", {}) == null and broken.get("line_call", {}) == null and is_equal_approx(float(broken_dash.get("radius", -1.0)), 200.0) and broken_dash.get("color", "") == team_color

	# --- Animated branch: animateShields=true draws ONLY
	# the fill -- z 125 (Layer.shields), base team.color
	# (shieldColor null), mix toward Color.white by
	# clamp(0.5) = 0.5, fill branch "animated" at alpha 1.0
	# (no Draw.alpha in the animated branch -- the fill
	# uses the color's own alpha), radius the SMOOTH radius
	# 150.0, sides 24 -- and NO line call.
	var animated: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, field_radius, 0.5, null, team_color, true)
	var animated_shield: Dictionary = animated.get("shield_call", {})
	var animated_fill: Dictionary = animated.get("fill_call", {})
	proof["draw_shield_animated_branch"] = animated_shield.get("call", "") == "Draw.z(Layer.shields);" and int(animated_shield.get("z", -1)) == 125 and animated_shield.get("z_name", "") == "Layer.shields" and animated_shield.get("base_color", "") == team_color and animated_shield.get("mix_color", "") == "Color.white" and is_equal_approx(float(animated_shield.get("mix", -1.0)), 0.5) and animated_fill.get("call", "") == "Fill.poly(x, y, sides, radius);" and animated_fill.get("branch", "") == "animated" and is_equal_approx(float(animated_fill.get("alpha", -1.0)), 1.0) and is_equal_approx(float(animated_fill.get("x", -1.0)), 80.0) and is_equal_approx(float(animated_fill.get("y", -1.0)), 160.0) and int(animated_fill.get("sides", -1)) == 24 and is_equal_approx(float(animated_fill.get("radius", -1.0)), 150.0) and animated.get("line_call", {}) == null

	# --- Static alpha: animateShields=false strokes 1.5f,
	# fills at alpha 0.09 + clamp(0.08 * hit) -- 0.13 at hit
	# 0.5, 0.09 at hit 0.0 -- then resets alpha to 1f and
	# draws the outline (stroke 1.5f, alpha 1.0, radius the
	# SMOOTH radius 150.0, sides 24).
	var static_half: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, field_radius, 0.5, null, team_color, false)
	var static_zero: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, field_radius, 0.0, null, team_color, false)
	var static_fill: Dictionary = static_half.get("fill_call", {})
	var static_zero_fill: Dictionary = static_zero.get("fill_call", {})
	var static_line: Dictionary = static_half.get("line_call", {})
	proof["draw_shield_static_alpha"] = static_fill.get("branch", "") == "static" and is_equal_approx(float(static_fill.get("alpha", -1.0)), 0.13) and is_equal_approx(float(static_zero_fill.get("alpha", -1.0)), 0.09) and static_line.get("call", "") == "Lines.poly(x, y, sides, radius);" and static_line.get("stroke_call", "") == "Lines.stroke(1.5f);" and is_equal_approx(float(static_line.get("stroke", -1.0)), 1.5) and is_equal_approx(float(static_line.get("alpha", -1.0)), 1.0) and int(static_line.get("sides", -1)) == 24 and is_equal_approx(float(static_line.get("radius", -1.0)), 150.0)

	# --- Color null vs set: shieldColor null -> the mix
	# base is the team color; shieldColor set -> the mix
	# base is the shield color. The mix target is
	# Color.white in both cases, the mix is clamp(hit).
	var color_set: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, field_radius, 0.5, shield_color, team_color, true)
	var color_set_shield: Dictionary = color_set.get("shield_call", {})
	proof["draw_shield_color_null_vs_set"] = animated_shield.get("base_color", "") == team_color and color_set_shield.get("base_color", "") == shield_color and color_set_shield.get("mix_color", "") == "Color.white" and is_equal_approx(float(color_set_shield.get("mix", -1.0)), 0.5)

	# --- Hit clamp: Mathf.clamp(hit) is [0,1] -- hit 2.0
	# mixes fully (1.0), hit -0.5 mixes nothing (0.0).
	# The static fill alpha clamps the 0.08 * hit term
	# only: hit 2.0 -> 0.09 + 0.16 = 0.25, hit -1.0 ->
	# 0.09 + 0.0 = 0.09 (the sum itself is NOT clamped).
	var hit_high: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, field_radius, 2.0, null, team_color, false)
	var hit_low: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, field_radius, -0.5, null, team_color, true)
	var hit_neg: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, field_radius, -1.0, null, team_color, false)
	var hit_high_shield: Dictionary = hit_high.get("shield_call", {})
	var hit_low_shield: Dictionary = hit_low.get("shield_call", {})
	var hit_high_fill: Dictionary = hit_high.get("fill_call", {})
	var hit_neg_fill: Dictionary = hit_neg.get("fill_call", {})
	proof["draw_shield_hit_clamp"] = is_equal_approx(float(hit_high_shield.get("mix", -1.0)), 1.0) and is_equal_approx(float(hit_low_shield.get("mix", -1.0)), 0.0) and is_equal_approx(float(hit_high_fill.get("alpha", -1.0)), 0.25) and is_equal_approx(float(hit_neg_fill.get("alpha", -1.0)), 0.09)

	# --- Dash FIELD radius: the drawSelect dashCircle uses
	# the FIELD radius 200.0 -- NOT the smooth radius 150.0
	# (the two deliberately differ in this fixture) -- and
	# the large def field radius 400.0 (Blocks.java:2060)
	# dashes at 400.0 with the same smooth radius. The
	# super.drawSelect() call is recorded, not ported.
	var large: Dictionary = base_shield_build_state.source_base_shield_draw_shield_state(build_x, build_y, false, smooth_radius, large_field_radius, 0.5, null, team_color, true)
	var animated_dash: Dictionary = animated.get("dash_call", {})
	var large_dash: Dictionary = large.get("dash_call", {})
	proof["draw_select_dash_field_radius"] = animated_dash.get("call", "") == "Drawf.dashCircle(x, y, radius, team.color);" and animated_dash.get("super_call", "") == "super.drawSelect();" and is_equal_approx(float(animated_dash.get("x", -1.0)), 80.0) and is_equal_approx(float(animated_dash.get("y", -1.0)), 160.0) and is_equal_approx(float(animated_dash.get("radius", -1.0)), 200.0) and animated_dash.get("color", "") == team_color and is_equal_approx(float(large_dash.get("radius", -1.0)), 400.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseShieldDrawShieldRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
