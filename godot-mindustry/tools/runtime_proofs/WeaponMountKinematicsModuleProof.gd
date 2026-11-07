extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_weapon_mount_kinematics_state := preload("res://src/game/SourceWeaponMountKinematicsState.gd")
const source_weapon_mount_update_state := preload("res://src/game/SourceWeaponMountUpdateState.gd")
const source_weapons_state := preload("res://src/game/SourceWeaponsState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_weapons_state.default_callbacks_state(game)
	var unit_state := {
		"x": 4.0,
		"y": -3.0,
		"rotation": 135.0,
	}
	var weapon_state := {
		"x": 6.0,
		"y": -2.0,
		"rotate": true,
		"rotateSpeed": 900.0,
		"rotationLimit": 60.0,
		"baseRotation": 15.0,
		"shootX": 1.5,
		"shootY": 3.5,
	}
	var rotate_mount_state := {
		"rotate": true,
		"shoot": true,
		"rotation": 80.0,
		"targetRotation": 0.0,
		"aimX": -10.0,
		"aimY": 7.0,
	}
	var bullet_mount_state := {
		"rotation": 20.0,
		"aimX": 30.0,
		"aimY": -12.0,
	}
	var origin_wrapper := game.source_weapon_update_mount_origin_state(unit_state, weapon_state)
	var origin_facade := source_weapons_state.game_update_mount_origin_state(game, unit_state, weapon_state)
	var origin_mount_facade := source_weapon_mount_update_state.update_mount_origin_state(unit_state, weapon_state, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))
	var origin_module := source_weapon_mount_kinematics_state.update_mount_origin_state(unit_state, weapon_state, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))
	var rotate_wrapper := game.source_weapon_update_rotate_toward_state(rotate_mount_state, weapon_state, unit_state, true, 0.25)
	var rotate_facade := source_weapons_state.game_update_rotate_toward_state(game, rotate_mount_state, weapon_state, unit_state, true, 0.25)
	var rotate_mount_facade := source_weapon_mount_update_state.update_rotate_toward_state(rotate_mount_state, weapon_state, unit_state, true, 0.25, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLES_ANGLE_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLE_DIST_KEY, Callable()))
	var rotate_module := source_weapon_mount_kinematics_state.update_rotate_toward_state(rotate_mount_state, weapon_state, unit_state, true, 0.25, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLES_ANGLE_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLE_DIST_KEY, Callable()))
	var bullet_wrapper := game.source_weapon_update_bullet_origin_state(bullet_mount_state, weapon_state, unit_state, 11.0, -8.0)
	var bullet_facade := source_weapons_state.game_update_bullet_origin_state(game, bullet_mount_state, weapon_state, unit_state, 11.0, -8.0)
	var bullet_mount_facade := source_weapon_mount_update_state.update_bullet_origin_state(bullet_mount_state, weapon_state, unit_state, 11.0, -8.0, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLES_ANGLE_KEY, Callable()))
	var bullet_module := source_weapon_mount_kinematics_state.update_bullet_origin_state(bullet_mount_state, weapon_state, unit_state, 11.0, -8.0, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLES_ANGLE_KEY, Callable()))
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "WEAPON_MOUNT_KINEMATICS_MODULE_PROOF",
		"origin_matches": origin_wrapper == origin_facade and origin_wrapper == origin_mount_facade and origin_wrapper == origin_module,
		"rotate_matches": rotate_wrapper == rotate_facade and rotate_wrapper == rotate_mount_facade and rotate_wrapper == rotate_module,
		"bullet_origin_matches": bullet_wrapper == bullet_facade and bullet_wrapper == bullet_mount_facade and bullet_wrapper == bullet_module,
		"origin_uses_rotation_offset": float(origin_module.get("angle", 0.0)) == 45.0,
		"rotate_limit_branch_reachable": bool(rotate_module.get("rotationLimitApplied", false)) or float(rotate_module.get("rotationLimit", 0.0)) == 60.0,
		"bullet_origin_uses_shoot_offset": float(bullet_module.get("shootX", 0.0)) == 1.5 and float(bullet_module.get("shootY", 0.0)) == 3.5,
		"matches": origin_wrapper == origin_facade and origin_wrapper == origin_mount_facade and origin_wrapper == origin_module and rotate_wrapper == rotate_facade and rotate_wrapper == rotate_mount_facade and rotate_wrapper == rotate_module and bullet_wrapper == bullet_facade and bullet_wrapper == bullet_mount_facade and bullet_wrapper == bullet_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["origin_matches"] and proof["rotate_matches"] and proof["bullet_origin_matches"] and proof["origin_uses_rotation_offset"] and proof["rotate_limit_branch_reachable"] and proof["bullet_origin_uses_shoot_offset"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("WEAPON_MOUNT_KINEMATICS_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("WeaponMountKinematicsModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

