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

	# --- RepairTurret rotation slerp (N2214):
	# RepairPointBuild.updateTile rotates the turret toward
	# the acquired target (`rotation =
	# Mathf.slerpDelta(rotation, angle, 0.5f * efficiency *
	# timeScale);`, RepairTurret.java:209), inside the same
	# `if(target != null && efficiency > 0){` gate
	# (RepairTurret.java:203) but OUTSIDE the aim-cone
	# `if(Angles.angleDist(angle, rotation) < 30f){`
	# (RepairTurret.java:205) -- the cone gates only the
	# heal (RepairTurret.java:206-207), so the turret still
	# turns toward a target outside the cone. The angle is
	# `Angles.angle(x, y, target.x + offset.x, target.y +
	# offset.y)` (RepairTurret.java:204). Mathf.slerpDelta
	# multiplies its progress by Time.delta and clamps to
	# [0, 1] (`return slerp(fromDegrees, toDegrees,
	# clamp(progress * Time.delta));`, Mathf.java:461),
	# and slerp always takes the shortest circular path
	# (`float delta = ((toDegrees - fromDegrees + 360 +
	# 180) % 360) - 180;` / `return (fromDegrees + delta *
	# progress + 360) % 360;`, Mathf.java:456-457). The
	# strength lerp (RepairTurret.java:212) is NOT this
	# slice -- it waits for its own slice. The proof calls
	# the pure function
	# source_repair_turret_rotation_slerp_state(frame, x, y,
	# delta, time_scale) directly with synthetic frames
	# (the N2213 precedent -- the driver tick line lands
	# with GREEN). The turret sits at (0, 0); a target due
	# east (+x) is at angle 90 (Angles.angle is atan2(dx,
	# dy) in degrees), a target due north (+y) is at angle
	# 0, and a target at (1.73648178, 9.84807753) is at
	# angle 10 (10 * sin(10deg), 10 * cos(10deg)). delta
	# 1/60 is one tick, time_scale 1.0 is the Building
	# default, so one tick at full efficiency moves the
	# rotation by 1/120 of the angle gap (0.5 * 1.0 * 1.0
	# * 1/60 = 1/120).
	var east_target: Dictionary = {"id": 1, "x": 10.0, "y": 0.0, "health": 50.0, "max_health": 100.0}
	var north_target: Dictionary = {"id": 2, "x": 0.0, "y": 10.0, "health": 50.0, "max_health": 100.0}
	var ten_deg_target: Dictionary = {"id": 3, "x": 1.73648178, "y": 9.84807753, "health": 50.0, "max_health": 100.0}

	# Turns toward the target: rotation 80, target east at
	# angle 90 -- the gap is +10, one tick covers 10/120
	# = 0.0833, so rotation becomes 80.0833.
	var frame: Dictionary = {"target": east_target.duplicate(), "efficiency": 1.0, "rotation": 80.0, "offset": Vector2.ZERO}
	var result: Dictionary = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 1.0 / 60.0, 1.0)
	proof["rotation_turns_toward_target"] = abs(float(result.get("rotation", -1.0)) - 80.0833) < 0.001

	# Takes the short way across 0/360: rotation 350,
	# target at angle 10 -- the short gap is +20 (through
	# 360), not -340, so one tick covers 20/120 = 0.1667
	# and rotation becomes 350.1667.
	frame = {"target": ten_deg_target.duplicate(), "efficiency": 1.0, "rotation": 350.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 1.0 / 60.0, 1.0)
	proof["rotation_turns_short_way_across_360"] = abs(float(result.get("rotation", -1.0)) - 350.1667) < 0.001

	# Scales with efficiency: efficiency 0.5 halves the
	# progress, so rotation 90 toward angle 0 moves 90 *
	# 0.5 / 120 = 0.375 and becomes 89.625.
	frame = {"target": north_target.duplicate(), "efficiency": 0.5, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 1.0 / 60.0, 1.0)
	proof["rotation_scales_with_efficiency"] = abs(float(result.get("rotation", -1.0)) - 89.625) < 0.001

	# Scales with time_scale: time_scale 2.0 doubles the
	# progress, so rotation 90 toward angle 0 moves 90 *
	# 2 / 120 = 1.5 and becomes 88.5.
	frame = {"target": north_target.duplicate(), "efficiency": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 1.0 / 60.0, 2.0)
	proof["rotation_scales_with_time_scale"] = abs(float(result.get("rotation", -1.0)) - 88.5) < 0.001

	# Unchanged without a target: no target dict, rotation
	# 123.0 stays 123.0.
	frame = {"efficiency": 1.0, "rotation": 123.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 1.0 / 60.0, 1.0)
	proof["rotation_unchanged_without_target"] = abs(float(result.get("rotation", -1.0)) - 123.0) < 0.001

	# Unchanged without power: efficiency 0, rotation 90
	# toward angle 0 stays 90.0.
	frame = {"target": north_target.duplicate(), "efficiency": 0.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 1.0 / 60.0, 1.0)
	proof["rotation_unchanged_without_power"] = abs(float(result.get("rotation", -1.0)) - 90.0) < 0.001

	# Turns even outside the aim cone: rotation 90, target
	# north at angle 0 -- the angle distance is 90, above
	# the strict 30 cone that blocks the N2213 heal, but
	# the slerp still runs: one tick covers 90/120 = 0.75
	# and rotation becomes 89.25.
	frame = {"target": north_target.duplicate(), "efficiency": 1.0, "rotation": 90.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 1.0 / 60.0, 1.0)
	proof["rotation_turns_even_outside_cone"] = abs(float(result.get("rotation", -1.0)) - 89.25) < 0.001

	# Reaches the target when progress clamps: a huge
	# delta (60.0 seconds) pushes 0.5 * 1.0 * 1.0 * 60 =
	# 30 past the [0, 1] clamp, so progress is 1.0 and
	# rotation 350 lands exactly on angle 10.
	frame = {"target": ten_deg_target.duplicate(), "efficiency": 1.0, "rotation": 350.0, "offset": Vector2.ZERO}
	result = repair_turret_build_state.source_repair_turret_rotation_slerp_state(frame, 0.0, 0.0, 60.0, 1.0)
	var clamped_rotation: float = float(result.get("rotation", -1.0))
	proof["rotation_reaches_target_when_progress_clamps"] = abs(clamped_rotation - 10.0) < 0.001 and clamped_rotation >= 0.0 and clamped_rotation < 360.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretRotationSlerpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
