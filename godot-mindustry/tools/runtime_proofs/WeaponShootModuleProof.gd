extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_weapons_state := preload("res://src/game/SourceWeaponsState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _weapons_state_method_names() -> Dictionary:
	return {
		source_weapons_state.SOURCE_WEAPONS_APPROACH_DELTA_KEY: "_proof_approach_delta",
	}

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_weapons_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_weapons_state.SOURCE_WEAPONS_APPROACH_DELTA_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_APPROACH_DELTA_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_LERP_DELTA_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_LERP_DELTA_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_ANGLES_ANGLE_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_ANGLES_ANGLE_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_ANGLE_DIST_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_ANGLE_DIST_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_MATHF_DST_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_MATHF_DST_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_STATUS_APPLY_RESULT_FALLBACK),
		source_weapons_state.SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY: Callable(game, source_weapons_state.SOURCE_WEAPONS_BULLET_ORIGIN_STATE_FALLBACK),
	}
	var override_callbacks := source_weapons_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_weapons_state.SOURCE_WEAPONS_APPROACH_DELTA_KEY, Callable()) == Callable(self, "_proof_approach_delta")
	var mount_state := {
		"charging": false,
		"totalShots": 4,
		"barrelCounter": 2,
	}
	var weapon_state := {
		"shootStatus": "burning",
		"shootStatusDuration": 99.0,
		"firstShotDelay": 1.25,
		"chargeSound": "charge",
		"soundPitchMin": 0.7,
		"soundPitchMax": 1.1,
		"parentizeEffects": false,
	}
	var bullet_state := {
		"keepVelocity": true,
		"chargeEffect": "chargeEffect",
	}
	var unit_state := {
		"id": 42,
		"statusImmune": false,
	}
	var shoot_state := {
		"shots": 2,
		"firstShotDelay": 0.25,
		"shotDelay": 0.5,
	}
	var rotate_mount_state := {
		"rotate": true,
		"shoot": false,
		"rotation": 0.0,
		"targetRotation": 0.0,
		"aimX": -10.0,
		"aimY": 0.0,
	}
	var rotate_weapon_state := {
		"rotate": true,
		"x": 0.0,
		"y": 0.0,
		"rotateSpeed": 1000.0,
		"rotationLimit": source_math_defaults.FULL_CIRCLE_DEGREES,
		"baseRotation": 0.0,
	}
	var rotate_unit_state := {
		"x": 0.0,
		"y": 0.0,
		"rotation": 0.0,
	}
	var charge_wrapper := game.source_weapon_shoot_charge_start_state(mount_state, weapon_state, bullet_state, unit_state, 8.0, 9.0, 45.0)
	var charge_module_bridge := source_weapons_state.game_shoot_charge_start_state(game, mount_state, weapon_state, bullet_state, unit_state, 8.0, 9.0, 45.0)
	var charge_module := source_weapons_state.shoot_charge_start_state(mount_state, weapon_state, bullet_state, unit_state, 8.0, 9.0, 45.0, callbacks.get(source_weapons_state.SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY, Callable()))
	var events_wrapper := game.source_shoot_pattern_default_events(shoot_state)
	var events_module := source_weapons_state.shoot_pattern_default_events(shoot_state)
	var dispatch_wrapper := game.source_weapon_shoot_default_pattern_dispatch_state(mount_state, shoot_state)
	var dispatch_module := source_weapons_state.shoot_default_pattern_dispatch_state(mount_state, shoot_state)
	var rotation_limit_wrapper := game.source_weapon_update_rotate_toward_state(rotate_mount_state, rotate_weapon_state, rotate_unit_state, true, 1.0)
	var rotation_limit_module_bridge := source_weapons_state.game_update_rotate_toward_state(game, rotate_mount_state, rotate_weapon_state, rotate_unit_state, true, 1.0)
	var rotation_limit_module := source_weapons_state.update_rotate_toward_state(rotate_mount_state, rotate_weapon_state, rotate_unit_state, true, 1.0, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLES_ANGLE_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(source_weapons_state.SOURCE_WEAPONS_ANGLE_DIST_KEY, Callable()))
	var recoil_create_state := {
		"bulletContinues": true,
		"angleLifeState": {
			"shootAngle": 12.0,
		},
	}
	var recoil_bullet_state := {
		"recoil": 3.0,
	}
	var recoil_unit_state := {
		"vel": {"x": 0.0, "y": 0.0},
	}
	var recoil_wrapper := game.source_weapon_bullet_recoil_velocity_state(recoil_create_state, recoil_unit_state, recoil_bullet_state)
	var recoil_module_bridge := source_weapons_state.game_bullet_recoil_velocity_state(game, recoil_create_state, recoil_unit_state, recoil_bullet_state)
	var recoil_module := source_weapons_state.bullet_recoil_velocity_state(recoil_create_state, recoil_unit_state, recoil_bullet_state, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))
	var continuous_mount_state := {
		"bulletExists": true,
		"reload": 0.0,
		"recoil": 0.0,
	}
	var continuous_weapon_state := {
		"continuous": true,
		"reload": 12.0,
	}
	var continuous_unit_state := {
		"velX": 0.0,
		"velY": 0.0,
	}
	var continuous_bullet_state := {
		"isAdded": true,
		"time": 1.0,
		"lifetime": 2.0,
		"typeMatches": true,
		"recoil": 0.0,
	}
	var continuous_wrapper := game.source_weapon_update_continuous_live_state(continuous_mount_state, continuous_weapon_state, continuous_unit_state, continuous_bullet_state, 1.0, 2.0, 3.0, 15.0)
	var continuous_module_bridge := source_weapons_state.game_update_continuous_live_state(game, continuous_mount_state, continuous_weapon_state, continuous_unit_state, continuous_bullet_state, 1.0, 2.0, 3.0, 15.0)
	var continuous_module := source_weapons_state.update_continuous_live_state(continuous_mount_state, continuous_weapon_state, continuous_unit_state, continuous_bullet_state, 1.0, 2.0, 3.0, 15.0, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceWeaponsState",
		"charge_start_matches": charge_wrapper == charge_module,
		"charge_start_bridge_matches": charge_wrapper == charge_module_bridge,
		"default_events_matches": events_wrapper == events_module,
		"default_dispatch_matches": dispatch_wrapper == dispatch_module,
		"rotation_limit_full_circle_guard_matches": rotation_limit_wrapper == rotation_limit_module and rotation_limit_wrapper == rotation_limit_module_bridge and not bool(rotation_limit_module.get("rotationLimitApplied", true)),
		"recoil_half_circle_matches": recoil_wrapper == recoil_module and recoil_wrapper == recoil_module_bridge and float(recoil_module.get("recoilVector", {}).get("angle_degrees", 0.0)) == 12.0 + source_math_defaults.HALF_CIRCLE_DEGREES,
		"continuous_live_quarter_circle_matches": continuous_wrapper == continuous_module and continuous_wrapper == continuous_module_bridge and float(continuous_module.get("bulletRotation", 0.0)) == 15.0 + source_math_defaults.QUARTER_CIRCLE_DEGREES,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"module_matches": charge_wrapper == charge_module and charge_wrapper == charge_module_bridge and events_wrapper == events_module and dispatch_wrapper == dispatch_module and rotation_limit_wrapper == rotation_limit_module and rotation_limit_wrapper == rotation_limit_module_bridge and recoil_wrapper == recoil_module and recoil_wrapper == recoil_module_bridge and continuous_wrapper == continuous_module and continuous_wrapper == continuous_module_bridge,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("WEAPON_SHOOT_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _proof_approach_delta(from_value: float, to_value: float, delta: float) -> float:
	if from_value < to_value:
		return minf(from_value + delta, to_value)
	if from_value > to_value:
		return maxf(from_value - delta, to_value)
	return to_value
