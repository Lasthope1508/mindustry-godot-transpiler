extends Node

const main_scene := preload("res://scenes/Main.tscn")
const weapons_state := preload("res://src/game/SourceWeaponsState.gd")
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

	# --- Weapon.update() leg 2 (N2541): mount position /
	# rotate block / weapon rotation / bullet position /
	# shoot angle / alwaysShooting (Weapon.java:313-315,
	# :350-371, :373, bulletRotation :455-457).
	# `float` /
	# `mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),` /
	# `mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);` /
	# `if(rotate && (mount.rotate || mount.shoot) && can){` /
	# `float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),` /
	# `axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y);` /
	# `mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;` /
	# `mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);` /
	# `if(rotationLimit < 360){` /
	# `float dst = Angles.angleDist(mount.rotation, baseRotation);` /
	# `if(dst > rotationLimit/2f){` /
	# `mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);` /
	# `}` /
	# `}` /
	# `}else if(!rotate){` /
	# `mount.rotation = baseRotation;` /
	# `mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);` /
	# `}` /
	# `float` /
	# `weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),` /
	# `bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),` /
	# `bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),` /
	# `shootAngle = bulletRotation(unit, mount, bulletX, bulletY);` /
	# `if(alwaysShooting) mount.shoot = true;` /
	# bulletRotation (Weapon.java:455-457):
	# `return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;`.
	# Defaults unless noted: unit (100, 100), rotation 90,
	# weapon offsets x 5 / y 0, shoot offsets x 0 / y 3,
	# mount rotation 0, mount targetRotation 0, aim (115,
	# 100), mount.shoot false, mount.rotate false, can
	# false, rotate false, rotateSpeed 20, rotationLimit
	# 361, baseRotation 0, alwaysShooting false, delta 1.0.
	# The proof drives the pure function through the Weapon
	# facade on exact legs:

	# Phase 1: mount position: unit (100, 100), rotation
	# 90, weapon (5, 0) -> mount (105, 100).
	var aim_state: Dictionary = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 0.0, 0.0, 115.0, 100.0, false, false, false, false, 20.0, 361.0, 0.0, false, 1.0)
	proof["mount_position"] = is_equal_approx(float(aim_state.get("mount_x", -1.0)), 105.0) and is_equal_approx(float(aim_state.get("mount_y", -1.0)), 100.0)

	# Phase 2: rotate toward: rotate, mount.rotate, can,
	# aim (115, 100) -> angle(axis (105, 100) -> aim) 0,
	# targetRotation 0 - 90 = -90, rotation 0 -> -20
	# (moveToward by rotateSpeed * delta = 20).
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 0.0, 0.0, 115.0, 100.0, false, true, true, true, 20.0, 361.0, 0.0, false, 1.0)
	proof["rotate_toward"] = is_equal_approx(float(aim_state.get("mount_rotation", -999.0)), -20.0) and is_equal_approx(float(aim_state.get("mount_target_rotation", -999.0)), -90.0)

	# Phase 3: rotationLimit clamp: limit 40, rotation 50
	# -> moveToward 30, dst = angleDist(30, 0) = 30 >
	# 40/2 = 20 -> moveToward(30, 0, 10) = 20.
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 50.0, 0.0, 115.0, 100.0, false, true, true, true, 20.0, 40.0, 0.0, false, 1.0)
	proof["rotation_limit_clamp"] = is_equal_approx(float(aim_state.get("mount_rotation", -999.0)), 20.0)

	# Phase 4: !rotate branch: rotation 77 -> baseRotation
	# 10, targetRotation = angleTo(unit -> aim) = 0 (NO
	# subtraction of unit.rotation, unlike the rotate
	# branch).
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 77.0, 5.0, 115.0, 100.0, false, false, false, false, 20.0, 361.0, 10.0, false, 1.0)
	proof["no_rotate_branch"] = is_equal_approx(float(aim_state.get("mount_rotation", -999.0)), 10.0) and is_equal_approx(float(aim_state.get("mount_target_rotation", -999.0)), 0.0)

	# Phase 5: weapon rotation, !rotate leg: 90 - 90 +
	# baseRotation 10 = 10 (uses baseRotation, not the
	# input mount rotation 77).
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 77.0, 5.0, 115.0, 100.0, false, false, false, false, 20.0, 361.0, 10.0, false, 1.0)
	proof["weapon_rotation"] = is_equal_approx(float(aim_state.get("weapon_rotation", -999.0)), 10.0)

	# Phase 6: bullet position, !rotate leg:
	# weaponRotation 10, shoot (0, 3) -> bullet (105 -
	# 3*sin(10), 100 + 3*cos(10)) = (104.479055,
	# 102.954423).
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 77.0, 5.0, 115.0, 100.0, false, false, false, false, 20.0, 361.0, 10.0, false, 1.0)
	proof["bullet_position"] = is_equal_approx(float(aim_state.get("bullet_x", -1.0)), 104.479055) and is_equal_approx(float(aim_state.get("bullet_y", -1.0)), 102.954423)

	# Phase 7: shoot angle, rotate leg: unit.rotation 90 +
	# updated mount.rotation -20 = 70.
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 0.0, 0.0, 115.0, 100.0, false, true, true, true, 20.0, 361.0, 0.0, false, 1.0)
	proof["shoot_angle_rotate"] = is_equal_approx(float(aim_state.get("shoot_angle", -999.0)), 70.0)

	# Phase 8: shoot angle, aim leg: shoot (0, 0) -> bullet
	# = mount (105, 100); angle(bullet -> aim) = 0,
	# angleTo(unit -> aim) = 0, baseRotation 10 -> 0 +
	# (90 - 0) + 10 = 100 (all three bulletRotation terms).
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 0.0, 77.0, 5.0, 115.0, 100.0, false, false, false, false, 20.0, 361.0, 10.0, false, 1.0)
	proof["shoot_angle_aim"] = is_equal_approx(float(aim_state.get("shoot_angle", -999.0)), 100.0)

	# Phase 9: alwaysShooting: alwaysShooting true,
	# mount.shoot false -> mount_shoot true; the rotate
	# block still sees the pre-alwaysShooting shoot false
	# (mount.rotate false, mount.shoot false, rotate true
	# -> guard false), so rotation stays 5.
	aim_state = weapons_state.source_weapon_update_aim_state(100.0, 100.0, 90.0, 5.0, 0.0, 0.0, 3.0, 5.0, 0.0, 115.0, 100.0, false, false, true, true, 20.0, 361.0, 0.0, true, 1.0)
	proof["always_shooting"] = bool(aim_state.get("mount_shoot", false)) == true and is_equal_approx(float(aim_state.get("mount_rotation", -999.0)), 5.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponUpdateAimProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
