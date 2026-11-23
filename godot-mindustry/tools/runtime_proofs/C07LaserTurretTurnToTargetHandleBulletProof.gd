extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceLaserTurretBuildPortBridge.gd")
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

	# --- LaserTurretBuild.turnToTarget() + handleBullet() (N2369):
	# LaserTurretBuild.turnToTarget()
	# (LaserTurret.java:135-137) turns rotation toward
	# targetRot with the wraparound Angles.moveToward
	# (already ported as
	# SourceMathState.source_angles_move_toward), the step
	# scaled by firingMoveFract (LaserTurret.java:16,
	# `public float firingMoveFract = 0.25f;`) only while a
	# bullet is around, full speed otherwise:
	# `protected void turnToTarget(float targetRot){`
	# `rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta() * (bullets.any() ? firingMoveFract : 1f));`
	# `}`
	# LaserTurretBuild.handleBullet()
	# (LaserTurret.java:140-144) appends a BulletEntry
	# (Turret.java:864-876, fields bullet/x/y/rotation/life)
	# only for a non-null bullet:
	# `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){`
	# `if(bullet != null){`
	# `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));`
	# `}`
	# `}`
	# on `public class LaserTurretBuild extends PowerTurretBuild{`
	# (LaserTurret.java:44). The bullets seq / firingMoveFract /
	# shootDuration arrive as explicit params (the N2330 param
	# precedent); the driver adds the returned entry to the
	# seq. NO driver tick line: pure functions. The proof
	# calls the pure function with synthetic scalar inputs
	# (no live tick). The bullet is a Variant, passed here
	# as the string "test-bullet".

	# No bullet around: full-speed turn toward the target.
	var moved: Dictionary = bridge.source_laser_turret_build_turn_to_target_handle_bullet_state(0.0, 90.0, 1.0, 10.0, 1.0, false, 0.25, null, 0.0, 0.0, 0.0, 100.0)
	proof["turn_to_target_moves_toward_target"] = float(moved.get("rotation", -1.0)) == 10.0

	# A bullet around: the step is scaled by firingMoveFract.
	var slowed: Dictionary = bridge.source_laser_turret_build_turn_to_target_handle_bullet_state(0.0, 90.0, 1.0, 10.0, 1.0, true, 0.25, null, 0.0, 0.0, 0.0, 100.0)
	proof["turn_to_target_firing_move_fract_when_bullets"] = float(slowed.get("rotation", -1.0)) == 2.5

	# Zero efficiency does not turn at all.
	var stalled: Dictionary = bridge.source_laser_turret_build_turn_to_target_handle_bullet_state(30.0, 90.0, 0.0, 10.0, 1.0, false, 0.25, null, 0.0, 0.0, 0.0, 100.0)
	proof["turn_to_target_efficiency_zero_no_move"] = float(stalled.get("rotation", -1.0)) == 30.0

	# Closer than the step snaps to the target.
	var snapped: Dictionary = bridge.source_laser_turret_build_turn_to_target_handle_bullet_state(85.0, 90.0, 1.0, 10.0, 1.0, false, 0.25, null, 0.0, 0.0, 0.0, 100.0)
	proof["turn_to_target_snaps_when_close"] = float(snapped.get("rotation", -1.0)) == 90.0

	# Wraparound crosses 360 the short way (350 -> 355).
	var wrapped: Dictionary = bridge.source_laser_turret_build_turn_to_target_handle_bullet_state(350.0, 10.0, 1.0, 5.0, 1.0, false, 0.25, null, 0.0, 0.0, 0.0, 100.0)
	proof["turn_to_target_wraps_around"] = float(wrapped.get("rotation", -1.0)) == 355.0

	# A non-null bullet yields a BulletEntry dict with the
	# constructor fields (bullet/x/y/rotation/life).
	var handed: Dictionary = bridge.source_laser_turret_build_turn_to_target_handle_bullet_state(0.0, 90.0, 1.0, 10.0, 1.0, false, 0.25, "test-bullet", 1.5, 2.5, 45.0, 100.0)
	var entry: Variant = handed.get("bullet_entry", null)
	proof["handle_bullet_adds_entry_when_bullet"] = entry is Dictionary and String(entry.get("bullet", "")) == "test-bullet" and float(entry.get("x", -1.0)) == 1.5 and float(entry.get("y", -1.0)) == 2.5 and float(entry.get("rotation", -1.0)) == 45.0 and float(entry.get("life", -1.0)) == 100.0

	# A null bullet yields no entry.
	proof["handle_bullet_null_bullet_no_entry"] = moved.get("bullet_entry", "not-null") == null

	# Each result carries ONLY its two keys.
	proof["returns_only_two_keys"] = moved.size() == 2 and handed.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaserTurretTurnToTargetHandleBulletProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
