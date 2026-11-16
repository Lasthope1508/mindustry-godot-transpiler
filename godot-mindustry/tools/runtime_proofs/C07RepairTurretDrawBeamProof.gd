extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret drawBeam state (N2219):
	# RepairPointBuild.draw() calls the static drawBeam
	# (`drawBeam(x, y, rotation, length, id, target, team,
	# strength,`, RepairTurret.java:171, inside `public void
	# draw(){`, RepairTurret.java:164): the beam origin is the
	# turret position plus the rotated length (`originX = x +
	# Angles.trnsx(rotation, length),` / `originY = y +
	# Angles.trnsy(rotation, length);`,
	# RepairTurret.java:115-116); with a target the endpoint is
	# the target position relative to the origin, clamped to at
	# least 2f (`lastEnd.set(target).sub(originX, originY);` /
	# `lastEnd.setLength(Math.max(2f, lastEnd.len()));`,
	# RepairTurret.java:118-119); with no target the endpoint
	# stays stale -- Java leaves lastEnd untouched (`if(target !=
	# null){`, RepairTurret.java:113). The laser draws only while
	# the beam is strong (`if(strength > 0.01f){`,
	# RepairTurret.java:129, STRICT) with width `strength *
	# beamWidth` (RepairTurret.java:145) and pulse stroke
	# `strength * pulseStroke` (`Lines.stroke(strength *
	# pulseStroke);`, RepairTurret.java:141). The proof calls the
	# pure function with synthetic frames (no live tick: the beam
	# state is pure geometry from frame values -- target,
	# strength, last_end -- plus explicit per-def params).
	# Angles.trnsx/trnsy are cos/sin of the rotation in degrees
	# times the length (the N2213 Angles.angle precedent: the
	# Java formula verbatim on Godot coordinates, no y-flip).

	# Origin at rotation 90, length 5 (repair-point class
	# default): turret (100, 100) -> origin (100, 105)
	# (cos 90 = 0, sin 90 = 1).
	var origin_90: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 1.0, "target": null, "last_end": Vector2.ZERO}, 100.0, 100.0, 90.0, 5.0, 1.0, 2.0)
	proof["beam_origin_at_rotation_90"] = (origin_90.get("beam_origin", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 105))

	# Origin at rotation 0, length 5: turret (100, 100) ->
	# origin (105, 100) (cos 0 = 1, sin 0 = 0).
	var origin_0: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 1.0, "target": null, "last_end": Vector2.ZERO}, 100.0, 100.0, 0.0, 5.0, 1.0, 2.0)
	proof["beam_origin_at_rotation_0"] = (origin_0.get("beam_origin", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(105, 100))

	# Endpoint clamps to min length 2: target (100, 106) is 1px
	# from the origin (100, 105), so the relative vector (0, 1)
	# is scaled to length 2 -> endpoint (100, 107).
	var clamped: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 1.0, "target": {"x": 100.0, "y": 106.0}, "last_end": Vector2.ZERO}, 100.0, 100.0, 90.0, 5.0, 1.0, 2.0)
	proof["beam_end_clamps_to_min_length_2"] = (clamped.get("beam_end", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 107))

	# Endpoint uses the target position when it is far enough:
	# target (100, 200) is 95px from the origin (100, 105), so
	# the endpoint is the target itself, and has_target is true.
	var far: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 1.0, "target": {"x": 100.0, "y": 200.0}, "last_end": Vector2.ZERO}, 100.0, 100.0, 90.0, 5.0, 1.0, 2.0)
	proof["beam_end_uses_target_position"] = (far.get("beam_end", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 200)) and bool(far.get("has_target", false))

	# Endpoint stays stale without a target: Java leaves lastEnd
	# untouched, so the function returns the frame's stored
	# last_end (150, 160) and has_target is false.
	var stale: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 1.0, "target": null, "last_end": Vector2(150, 160)}, 100.0, 100.0, 90.0, 5.0, 1.0, 2.0)
	proof["beam_end_stale_without_target"] = (stale.get("beam_end", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(150, 160)) and not bool(stale.get("has_target", true))

	# Beam visible above the threshold: strength 0.5 > 0.01f, so
	# the laser draws with width 0.5 * 1.0 = 0.5 and pulse stroke
	# 0.5 * 2.0 = 1.0.
	var visible: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 0.5, "target": null, "last_end": Vector2.ZERO}, 100.0, 100.0, 90.0, 5.0, 1.0, 2.0)
	proof["beam_visible_above_threshold"] = bool(visible.get("beam_visible", false)) and is_equal_approx(float(visible.get("beam_width", -1.0)), 0.5) and is_equal_approx(float(visible.get("pulse_stroke", -1.0)), 1.0)

	# Beam hidden at the threshold: the gate is STRICT
	# (`if(strength > 0.01f){`), so strength 0.01 does not draw,
	# and neither does strength 0.0.
	var hidden_edge: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 0.01, "target": null, "last_end": Vector2.ZERO}, 100.0, 100.0, 90.0, 5.0, 1.0, 2.0)
	var hidden_zero: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 0.0, "target": null, "last_end": Vector2.ZERO}, 100.0, 100.0, 90.0, 5.0, 1.0, 2.0)
	proof["beam_hidden_at_threshold"] = not bool(hidden_edge.get("beam_visible", true)) and not bool(hidden_zero.get("beam_visible", true))

	# Widths scale with strength at repair-turret per-def values
	# (length 6f, beamWidth 1.1f, Blocks.java:6399/6403):
	# strength 0.5 -> beam width 0.5 * 1.1 = 0.55, pulse stroke
	# 0.5 * 2.0 = 1.0, and the origin moves out to (100, 106).
	var scaled: Dictionary = repair_turret_build_state.source_repair_turret_draw_beam_state({"strength": 0.5, "target": null, "last_end": Vector2.ZERO}, 100.0, 100.0, 90.0, 6.0, 1.1, 2.0)
	proof["beam_width_scales_with_strength"] = is_equal_approx(float(scaled.get("beam_width", -1.0)), 0.55) and is_equal_approx(float(scaled.get("pulse_stroke", -1.0)), 1.0) and (scaled.get("beam_origin", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 106))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretDrawBeamProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
