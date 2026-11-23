extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceContinuousTurretBuildPortBridge.gd")
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

	# --- ContinuousTurretBuild.turnToTarget() + handleBullet() (N2370):
	# ContinuousTurretBuild.turnToTarget()
	# (ContinuousTurret.java:149-151) turns rotation toward
	# targetRot with the wraparound Angles.moveToward
	# (already ported as
	# SourceMathState.source_angles_move_toward), the step
	# scaled by efficiency * rotateSpeed * delta() with NO
	# firingMoveFract factor:
	# `protected void turnToTarget(float targetRot){`
	# `rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta());`
	# `}`
	# ContinuousTurretBuild.handleBullet()
	# (ContinuousTurret.java:154-164) appends a BulletEntry
	# (Turret.java:864-876, fields bullet/x/y/rotation/life)
	# only for a non-null bullet, with life 0f, and
	# initialises its aim from Tmp.v1:
	# `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){`
	# `if(bullet != null){`
	# `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, 0f));`
	# `//make sure the length updates to the last set value`
	# `Tmp.v1.trns(rotation, shootY + lastLength).add(x, y);`
	# `bullet.aimX = Tmp.v1.x;`
	# `bullet.aimY = Tmp.v1.y;`
	# `}`
	# `}`
	# on `public class ContinuousTurretBuild extends TurretBuild{`
	# (ContinuousTurret.java:38). Unlike LaserTurret (N2369)
	# there is no firingMoveFract factor and the entry life
	# is 0f, not shootDuration. The aim uses the NEW rotation
	# (turnToTarget runs before handleBullet in the tick).
	# delta() / shootY / lastLength arrive as explicit params
	# (the N2330 param precedent); the driver adds the
	# returned entry to the seq. NO driver tick line: pure
	# functions. The proof calls the pure function with
	# synthetic scalar inputs (no live tick). The bullet is a
	# Variant, passed here as the string "test-bullet".

	# No bullet: full-speed turn toward the target.
	var moved: Dictionary = bridge.source_continuous_turret_build_turn_to_target_handle_bullet_state(0.0, 90.0, 1.0, 10.0, 1.0, 0.0, 0.0, 10.0, 20.0, null, 0.0, 0.0, 0.0)
	proof["turn_to_target_moves_toward_target"] = float(moved.get("rotation", -1.0)) == 10.0

	# Closer than the step snaps to the target.
	var snapped: Dictionary = bridge.source_continuous_turret_build_turn_to_target_handle_bullet_state(85.0, 90.0, 1.0, 10.0, 1.0, 0.0, 0.0, 10.0, 20.0, null, 0.0, 0.0, 0.0)
	proof["turn_to_target_snaps_when_close"] = float(snapped.get("rotation", -1.0)) == 90.0

	# Wraparound crosses 360 the short way (350 -> 355).
	var wrapped: Dictionary = bridge.source_continuous_turret_build_turn_to_target_handle_bullet_state(350.0, 10.0, 1.0, 5.0, 1.0, 0.0, 0.0, 10.0, 20.0, null, 0.0, 0.0, 0.0)
	proof["turn_to_target_wraps_around"] = float(wrapped.get("rotation", -1.0)) == 355.0

	# Zero efficiency does not turn at all.
	var stalled: Dictionary = bridge.source_continuous_turret_build_turn_to_target_handle_bullet_state(30.0, 90.0, 0.0, 10.0, 1.0, 0.0, 0.0, 10.0, 20.0, null, 0.0, 0.0, 0.0)
	proof["turn_to_target_efficiency_zero_no_move"] = float(stalled.get("rotation", -1.0)) == 30.0

	# A non-null bullet yields a BulletEntry dict with the
	# constructor fields (bullet/x/y/rotation/life). The
	# target rotation is 0 here so the rotation stays 0 and
	# the aim below is exactly (30, 0).
	var handed: Dictionary = bridge.source_continuous_turret_build_turn_to_target_handle_bullet_state(0.0, 0.0, 1.0, 10.0, 1.0, 0.0, 0.0, 10.0, 20.0, "test-bullet", 1.5, 2.5, 45.0)
	var entry: Variant = handed.get("bullet_entry", null)
	proof["handle_bullet_adds_entry_when_bullet"] = entry is Dictionary and String(entry.get("bullet", "")) == "test-bullet" and float(entry.get("x", -1.0)) == 1.5 and float(entry.get("y", -1.0)) == 2.5 and float(entry.get("rotation", -1.0)) == 45.0

	# The entry life is 0f -- the distinguishing point from
	# LaserTurret.handleBullet (N2369, shootDuration).
	proof["handle_bullet_entry_life_zero"] = entry is Dictionary and float(entry.get("life", -1.0)) == 0.0

	# The aim comes from Tmp.v1.trns(rotation, shootY +
	# lastLength).add(x, y): rotation 0, shootY 10,
	# lastLength 20, at (0, 0) -> aim (30, 0).
	proof["handle_bullet_aim_from_last_length"] = float(handed.get("bullet_aim_x", -1.0)) == 30.0 and float(handed.get("bullet_aim_y", -1.0)) == 0.0

	# The aim uses the NEW rotation: rotation 80 turns to 90
	# in one step, so the aim points along 90 degrees
	# (0, 30) -- not along the old 80 degrees.
	var turned: Dictionary = bridge.source_continuous_turret_build_turn_to_target_handle_bullet_state(80.0, 90.0, 1.0, 10.0, 1.0, 0.0, 0.0, 10.0, 20.0, "test-bullet", 0.0, 0.0, 0.0)
	proof["handle_bullet_aim_uses_new_rotation"] = float(turned.get("rotation", -1.0)) == 90.0 and absf(float(turned.get("bullet_aim_x", -1.0))) < 0.001 and absf(float(turned.get("bullet_aim_y", -1.0)) - 30.0) < 0.001

	# A null bullet yields no entry.
	proof["handle_bullet_null_bullet_no_entry"] = moved.get("bullet_entry", "not-null") == null

	# Each result carries ONLY its four keys.
	proof["returns_only_four_keys"] = moved.size() == 4 and handed.size() == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretTurnToTargetHandleBulletProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
