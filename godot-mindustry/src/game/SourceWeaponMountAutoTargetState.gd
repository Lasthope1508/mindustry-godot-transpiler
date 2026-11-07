extends RefCounted
class_name SourceWeaponMountAutoTargetState

const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_WEAPON_CONTROLLABLE_DEFAULT := source_weapon_defaults.CONTROLLABLE_DEFAULT
const SOURCE_WEAPON_AUTO_TARGET_DEFAULT := source_weapon_defaults.AUTO_TARGET_DEFAULT
const SOURCE_WEAPON_TARGET_INTERVAL_DEFAULT := source_weapon_defaults.TARGET_INTERVAL_DEFAULT
const SOURCE_WEAPON_TARGET_SWITCH_INTERVAL_DEFAULT := source_weapon_defaults.TARGET_SWITCH_INTERVAL_DEFAULT
const SOURCE_WEAPON_SHOOT_Y_DEFAULT := source_weapon_defaults.SHOOT_Y_DEFAULT
const SOURCE_WEAPON_PREDICT_TARGET_DEFAULT := source_weapon_defaults.PREDICT_TARGET_DEFAULT

static func update_auto_target_retarget_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, mount_x: float, mount_y: float, find_target_result_exists: bool) -> Dictionary:
	var controllable := bool(weapon_state.get("controllable", SOURCE_WEAPON_CONTROLLABLE_DEFAULT))
	var auto_target := bool(weapon_state.get("autoTarget", SOURCE_WEAPON_AUTO_TARGET_DEFAULT))
	var current_retarget := float(mount_state.get("retarget", 0.0))
	var target_interval := float(weapon_state.get("targetInterval", SOURCE_WEAPON_TARGET_INTERVAL_DEFAULT))
	var target_switch_interval := float(weapon_state.get("targetSwitchInterval", SOURCE_WEAPON_TARGET_SWITCH_INTERVAL_DEFAULT))
	var current_target_exists := bool(mount_state.get("targetExists", false))
	var gate := (not controllable) and auto_target
	var retarget_after_decrement := current_retarget - source_delta
	var next_retarget := current_retarget
	var target_exists := current_target_exists
	var finder_call: Variant = null
	if gate:
		next_retarget = retarget_after_decrement
	if gate and retarget_after_decrement <= 0.0:
		finder_call = {
			"call": "findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround)",
			"mountX": mount_x,
			"mountY": mount_y,
			"range": float(bullet_state.get("range", 0.0)),
			"air": bool(bullet_state.get("collidesAir", true)),
			"ground": bool(bullet_state.get("collidesGround", true)),
		}
		target_exists = find_target_result_exists
		next_retarget = target_switch_interval if target_exists else target_interval
	return {
		"gate": gate,
		"retarget": next_retarget,
		"retargetAfterDecrement": retarget_after_decrement,
		"findTargetCalled": finder_call != null,
		"findTargetCall": finder_call,
		"targetExists": target_exists,
		"gateSource": "if(!controllable && autoTarget){",
		"retargetSource": "if((mount.retarget -= Time.delta) <= 0f){",
		"findTargetSource": "mount.target = findTarget(unit, mountX, mountY, bullet.range, bullet.collidesAir, bullet.collidesGround);",
		"intervalSource": "mount.retarget = mount.target == null ? targetInterval : targetSwitchInterval;",
	}

static func update_auto_target_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, mount_x: float, mount_y: float, check_target_result: bool) -> Dictionary:
	var controllable := bool(weapon_state.get("controllable", SOURCE_WEAPON_CONTROLLABLE_DEFAULT))
	var auto_target := bool(weapon_state.get("autoTarget", SOURCE_WEAPON_AUTO_TARGET_DEFAULT))
	var target_exists := bool(mount_state.get("targetExists", false))
	var gate := (not controllable) and auto_target
	var check_called := gate and target_exists
	var check_call: Variant = null
	if check_called:
		check_call = {
			"call": "checkTarget(unit, mount.target, mountX, mountY, bullet.range)",
			"mountX": mount_x,
			"mountY": mount_y,
			"range": float(bullet_state.get("range", 0.0)),
			"shootY": float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT)),
			"rangeWithShootY": float(bullet_state.get("range", 0.0)) + absf(float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))),
		}
	if check_called and check_target_result:
		target_exists = false
	return {
		"gate": gate,
		"checkTargetCalled": check_called,
		"checkTargetCall": check_call,
		"checkTargetResult": check_target_result if check_called else false,
		"targetExists": target_exists,
		"targetCleared": check_called and check_target_result,
		"gateSource": "if(!controllable && autoTarget)",
		"guardSource": "if(mount.target != null && checkTarget(unit, mount.target, mountX, mountY, bullet.range)){",
		"clearSource": "mount.target = null;",
		"checkTargetSource": "return Units.invalidateTarget(target, unit.team, x, y, range + Math.abs(shootY));",
		"invalidateTargetSource": "target == null || out of range || same team || invalid health || unit not targetable",
	}

static func update_auto_target_shoot_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, mount_x: float, mount_y: float, target_within_result: bool, predicted_aim: Dictionary) -> Dictionary:
	var target_exists := bool(mount_state.get("targetExists", false))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var bullet_range := float(bullet_state.get("range", 0.0))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var target_hit_size := float(mount_state.get("targetHitSize", 0.0)) if bool(mount_state.get("targetSized", false)) else 0.0
	var predict_target := bool(weapon_state.get("predictTarget", SOURCE_WEAPON_PREDICT_TARGET_DEFAULT))
	var within_range := bullet_range + absf(shoot_y) + target_hit_size / 2.0
	var shoot := false
	if target_exists:
		shoot = target_within_result and can_shoot
		if predict_target:
			aim_x = float(predicted_aim.get("x", aim_x))
			aim_y = float(predicted_aim.get("y", aim_y))
		else:
			aim_x = float(mount_state.get("targetX", aim_x))
			aim_y = float(mount_state.get("targetY", aim_y))
	var next_rotate := shoot
	return {
		"targetExists": target_exists,
		"withinRange": within_range,
		"targetWithin": target_within_result if target_exists else false,
		"canShoot": can_shoot,
		"shoot": shoot,
		"rotate": next_rotate,
		"aimX": aim_x,
		"aimY": aim_y,
		"predictTarget": predict_target,
		"mountX": mount_x,
		"mountY": mount_y,
		"shootInitSource": "boolean shoot = false;",
		"targetGuardSource": "if(mount.target != null){",
		"withinSource": "mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f))",
		"shootSource": "shoot = mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f)) && can;",
		"predictGuardSource": "if(predictTarget){",
		"predictSource": "Vec2 to = Predict.intercept(unit, mount.target, bullet);",
		"predictAimXSource": "mount.aimX = to.x;",
		"predictAimYSource": "mount.aimY = to.y;",
		"directAimXSource": "mount.aimX = mount.target.x();",
		"directAimYSource": "mount.aimY = mount.target.y();",
		"shootRotateSource": "mount.shoot = mount.rotate = shoot;",
		"logicNoteSource": "//note that shooting state is not affected, as these cannot be controlled",
		"predictInterceptSource": "public static Vec2 intercept(Position src, Position dst, BulletType bullet){",
		"predictInterceptReturnSource": "return intercept(src, dst, 0f, 0f, bullet.keepVelocity, bullet.speed);",
	}
