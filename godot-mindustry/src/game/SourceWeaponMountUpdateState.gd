extends RefCounted
class_name SourceWeaponMountUpdateState

const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")
const source_weapon_shoot_pattern_state := preload("res://src/game/SourceWeaponShootPatternState.gd")
const source_weapon_mount_auto_target_state := preload("res://src/game/SourceWeaponMountAutoTargetState.gd")
const source_weapon_mount_kinematics_state := preload("res://src/game/SourceWeaponMountKinematicsState.gd")

const SOURCE_WEAPON_RELOAD_DEFAULT := source_weapon_defaults.RELOAD_DEFAULT
const SOURCE_WEAPON_RECOIL_TIME_DEFAULT := source_weapon_defaults.RECOIL_TIME_DEFAULT
const SOURCE_WEAPON_RECOILS_DEFAULT := source_weapon_defaults.RECOILS_DEFAULT
const SOURCE_WEAPON_SMOOTH_RELOAD_SPEED_DEFAULT := source_weapon_defaults.SMOOTH_RELOAD_SPEED_DEFAULT
const SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT
const SOURCE_WEAPON_CONTINUOUS_DEFAULT := source_weapon_defaults.CONTINUOUS_DEFAULT
const SOURCE_WEAPON_SHOOT_WARMUP_SPEED_DEFAULT := source_weapon_defaults.SHOOT_WARMUP_SPEED_DEFAULT
const SOURCE_WEAPON_LINEAR_WARMUP_DEFAULT := source_weapon_defaults.LINEAR_WARMUP_DEFAULT
const SOURCE_WEAPON_ALWAYS_SHOOTING_DEFAULT := source_weapon_defaults.ALWAYS_SHOOTING_DEFAULT

static func update_passive_timers_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, approach_delta: Callable, lerp_delta: Callable) -> Dictionary:
	var can_shoot := bool(unit_state.get("canShoot", false))
	var reload_multiplier := float(unit_state.get("reloadMultiplier", 1.0))
	var current_reload := float(mount_state.get("reload", 0.0))
	var current_recoil := float(mount_state.get("recoil", 0.0))
	var current_smooth_reload := float(mount_state.get("smoothReload", 0.0))
	var current_charge := float(mount_state.get("charge", 0.0))
	var current_warmup := float(mount_state.get("warmup", 0.0))
	var charging := bool(mount_state.get("charging", false))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var bullet_state = mount_state.get("bullet", null)
	var has_bullet: bool = bullet_state != null and not (bullet_state is Dictionary and bullet_state.is_empty())
	var reload_time := float(weapon_state.get("reload", SOURCE_WEAPON_RELOAD_DEFAULT))
	var raw_recoil_time := float(weapon_state.get("recoilTime", SOURCE_WEAPON_RECOIL_TIME_DEFAULT))
	var recoil_time := reload_time if raw_recoil_time < 0.0 else raw_recoil_time
	var recoils_count := int(weapon_state.get("recoils", SOURCE_WEAPON_RECOILS_DEFAULT))
	var smooth_reload_speed := float(weapon_state.get("smoothReloadSpeed", SOURCE_WEAPON_SMOOTH_RELOAD_SPEED_DEFAULT))
	var first_shot_delay := float(weapon_state.get("firstShotDelay", SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT))
	var continuous := bool(weapon_state.get("continuous", SOURCE_WEAPON_CONTINUOUS_DEFAULT))
	var shoot_warmup_speed := float(weapon_state.get("shootWarmupSpeed", SOURCE_WEAPON_SHOOT_WARMUP_SPEED_DEFAULT))
	var linear_warmup := bool(weapon_state.get("linearWarmup", SOURCE_WEAPON_LINEAR_WARMUP_DEFAULT))
	var new_reload: float = maxf(current_reload - source_delta * reload_multiplier, 0.0)
	var new_recoil: float = approach_delta.call(current_recoil, 0.0, reload_multiplier / recoil_time, source_delta)
	var new_recoils: Array = []
	var mount_recoils = mount_state.get("recoils", [])
	if recoils_count > 0:
		for i in range(recoils_count):
			var recoil_value := 0.0
			if mount_recoils is Array and i < mount_recoils.size():
				recoil_value = float(mount_recoils[i])
			new_recoils.append(approach_delta.call(recoil_value, 0.0, reload_multiplier / recoil_time, source_delta))
	var new_smooth_reload: float = lerp_delta.call(current_smooth_reload, new_reload / reload_time, smooth_reload_speed, source_delta)
	var new_charge := 0.0
	if charging and first_shot_delay > 0.0:
		new_charge = approach_delta.call(current_charge, 1.0, 1.0 / first_shot_delay, source_delta)
	var warmup_target := 1.0 if ((can_shoot and mount_shoot) or (continuous and has_bullet) or charging) else 0.0
	var new_warmup := 0.0
	if linear_warmup:
		new_warmup = approach_delta.call(current_warmup, warmup_target, shoot_warmup_speed, source_delta)
	else:
		new_warmup = lerp_delta.call(current_warmup, warmup_target, shoot_warmup_speed, source_delta)
	return {
		"canShootCall": "boolean can = unit.canShoot();",
		"canShoot": can_shoot,
		"lastReload": current_reload,
		"reload": new_reload,
		"recoil": new_recoil,
		"recoils": new_recoils,
		"smoothReload": new_smooth_reload,
		"charge": new_charge,
		"warmupTarget": warmup_target,
		"warmup": new_warmup,
		"reloadAssignment": "mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);",
		"recoilAssignment": "mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);",
		"smoothReloadAssignment": "mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);",
		"chargeAssignment": "mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;",
		"warmupTargetSource": "float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;",
		"warmupMode": "Mathf.approachDelta" if linear_warmup else "Mathf.lerpDelta",
		"deltaSource": "Time.delta",
		"recoilTimeInitSource": "if(w.recoilTime < 0) w.recoilTime = w.reload;",
	}

static func update_mount_origin_state(unit_state: Dictionary, weapon_state: Dictionary, trns_vec: Callable) -> Dictionary:
	return source_weapon_mount_kinematics_state.update_mount_origin_state(unit_state, weapon_state, trns_vec)

static func update_auto_target_retarget_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, mount_x: float, mount_y: float, find_target_result_exists: bool) -> Dictionary:
	return source_weapon_mount_auto_target_state.update_auto_target_retarget_state(mount_state, weapon_state, bullet_state, source_delta, mount_x, mount_y, find_target_result_exists)

static func update_auto_target_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, mount_x: float, mount_y: float, check_target_result: bool) -> Dictionary:
	return source_weapon_mount_auto_target_state.update_auto_target_invalidation_state(mount_state, weapon_state, bullet_state, mount_x, mount_y, check_target_result)

static func update_auto_target_shoot_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, mount_x: float, mount_y: float, target_within_result: bool, predicted_aim: Dictionary) -> Dictionary:
	return source_weapon_mount_auto_target_state.update_auto_target_shoot_aim_state(mount_state, weapon_state, bullet_state, can_shoot, mount_x, mount_y, target_within_result, predicted_aim)

static func update_rotate_toward_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float, trns_vec: Callable, angles_angle: Callable, move_toward_angle: Callable, angle_dist: Callable) -> Dictionary:
	return source_weapon_mount_kinematics_state.update_rotate_toward_state(mount_state, weapon_state, unit_state, can_shoot, source_delta, trns_vec, angles_angle, move_toward_angle, angle_dist)

static func update_bullet_origin_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float, trns_vec: Callable, angles_angle: Callable) -> Dictionary:
	return source_weapon_mount_kinematics_state.update_bullet_origin_state(mount_state, weapon_state, unit_state, mount_x, mount_y, trns_vec, angles_angle)

static func update_always_shooting_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var shoot := bool(mount_state.get("shoot", false))
	var always_shooting := bool(weapon_state.get("alwaysShooting", SOURCE_WEAPON_ALWAYS_SHOOTING_DEFAULT))
	if always_shooting:
		shoot = true
	return {
		"shoot": shoot,
		"alwaysShooting": always_shooting,
		"alwaysShootingSource": "if(alwaysShooting) mount.shoot = true;",
		"continuousReservedSource": "if(continuous && mount.bullet != null){",
	}
