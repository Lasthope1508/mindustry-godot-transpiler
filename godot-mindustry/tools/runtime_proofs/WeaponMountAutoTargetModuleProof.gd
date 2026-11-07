extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_weapon_mount_auto_target_state := preload("res://src/game/SourceWeaponMountAutoTargetState.gd")
const source_weapon_mount_update_state := preload("res://src/game/SourceWeaponMountUpdateState.gd")
const source_weapons_state := preload("res://src/game/SourceWeaponsState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var retarget_mount_state := {
		"retarget": 0.2,
		"targetExists": false,
	}
	var target_weapon_state := {
		"controllable": false,
		"autoTarget": true,
		"targetInterval": 18.0,
		"targetSwitchInterval": 7.0,
		"shootY": 3.0,
		"predictTarget": true,
	}
	var bullet_state := {
		"range": 80.0,
		"collidesAir": true,
		"collidesGround": false,
	}
	var invalidation_mount_state := {
		"targetExists": true,
	}
	var shoot_mount_state := {
		"targetExists": true,
		"targetSized": true,
		"targetHitSize": 12.0,
		"targetX": 90.0,
		"targetY": -2.0,
		"aimX": 1.0,
		"aimY": 2.0,
	}
	var predicted_aim := {
		"x": 35.0,
		"y": -12.0,
	}
	var retarget_wrapper := game.source_weapon_update_auto_target_retarget_state(retarget_mount_state, target_weapon_state, bullet_state, 0.5, 12.0, -4.0, true)
	var retarget_facade := source_weapons_state.update_auto_target_retarget_state(retarget_mount_state, target_weapon_state, bullet_state, 0.5, 12.0, -4.0, true)
	var retarget_mount_facade := source_weapon_mount_update_state.update_auto_target_retarget_state(retarget_mount_state, target_weapon_state, bullet_state, 0.5, 12.0, -4.0, true)
	var retarget_module := source_weapon_mount_auto_target_state.update_auto_target_retarget_state(retarget_mount_state, target_weapon_state, bullet_state, 0.5, 12.0, -4.0, true)
	var invalidation_wrapper := game.source_weapon_update_auto_target_invalidation_state(invalidation_mount_state, target_weapon_state, bullet_state, 12.0, -4.0, true)
	var invalidation_facade := source_weapons_state.update_auto_target_invalidation_state(invalidation_mount_state, target_weapon_state, bullet_state, 12.0, -4.0, true)
	var invalidation_mount_facade := source_weapon_mount_update_state.update_auto_target_invalidation_state(invalidation_mount_state, target_weapon_state, bullet_state, 12.0, -4.0, true)
	var invalidation_module := source_weapon_mount_auto_target_state.update_auto_target_invalidation_state(invalidation_mount_state, target_weapon_state, bullet_state, 12.0, -4.0, true)
	var shoot_aim_wrapper := game.source_weapon_update_auto_target_shoot_aim_state(shoot_mount_state, target_weapon_state, bullet_state, true, 12.0, -4.0, true, predicted_aim)
	var shoot_aim_facade := source_weapons_state.update_auto_target_shoot_aim_state(shoot_mount_state, target_weapon_state, bullet_state, true, 12.0, -4.0, true, predicted_aim)
	var shoot_aim_mount_facade := source_weapon_mount_update_state.update_auto_target_shoot_aim_state(shoot_mount_state, target_weapon_state, bullet_state, true, 12.0, -4.0, true, predicted_aim)
	var shoot_aim_module := source_weapon_mount_auto_target_state.update_auto_target_shoot_aim_state(shoot_mount_state, target_weapon_state, bullet_state, true, 12.0, -4.0, true, predicted_aim)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "WEAPON_MOUNT_AUTO_TARGET_MODULE_PROOF",
		"retarget_matches": retarget_wrapper == retarget_facade and retarget_wrapper == retarget_mount_facade and retarget_wrapper == retarget_module,
		"invalidation_matches": invalidation_wrapper == invalidation_facade and invalidation_wrapper == invalidation_mount_facade and invalidation_wrapper == invalidation_module,
		"shoot_aim_matches": shoot_aim_wrapper == shoot_aim_facade and shoot_aim_wrapper == shoot_aim_mount_facade and shoot_aim_wrapper == shoot_aim_module,
		"retarget_finder_uses_mount_origin": bool(retarget_module.get("findTargetCalled", false)) and float(retarget_module.get("findTargetCall", {}).get("mountX", 0.0)) == 12.0 and float(retarget_module.get("findTargetCall", {}).get("mountY", 0.0)) == -4.0,
		"invalidation_clears_target": bool(invalidation_module.get("targetCleared", false)) and not bool(invalidation_module.get("targetExists", true)),
		"predict_aim_updates": float(shoot_aim_module.get("aimX", 0.0)) == 35.0 and float(shoot_aim_module.get("aimY", 0.0)) == -12.0,
		"matches": retarget_wrapper == retarget_facade and retarget_wrapper == retarget_mount_facade and retarget_wrapper == retarget_module and invalidation_wrapper == invalidation_facade and invalidation_wrapper == invalidation_mount_facade and invalidation_wrapper == invalidation_module and shoot_aim_wrapper == shoot_aim_facade and shoot_aim_wrapper == shoot_aim_mount_facade and shoot_aim_wrapper == shoot_aim_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["retarget_matches"] and proof["invalidation_matches"] and proof["shoot_aim_matches"] and proof["retarget_finder_uses_mount_origin"] and proof["invalidation_clears_target"] and proof["predict_aim_updates"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("WEAPON_MOUNT_AUTO_TARGET_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("WeaponMountAutoTargetModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

