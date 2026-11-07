extends RefCounted
class_name SourceWeaponBulletState

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")
const source_weapon_bullet_create_state := preload("res://src/game/SourceWeaponBulletCreateState.gd")
const source_weapon_bullet_continuous_state := preload("res://src/game/SourceWeaponBulletContinuousState.gd")
const source_weapon_bullet_effects_state := preload("res://src/game/SourceWeaponBulletEffectsState.gd")

const SOURCE_WEAPON_RECOILS_DEFAULT := source_weapon_defaults.RECOILS_DEFAULT
const SOURCE_WEAPON_CONTINUOUS_DEFAULT := source_weapon_defaults.CONTINUOUS_DEFAULT
const SOURCE_WEAPON_X_DEFAULT := source_weapon_defaults.X_DEFAULT
const SOURCE_WEAPON_Y_DEFAULT := source_weapon_defaults.Y_DEFAULT
const SOURCE_WEAPON_ROTATION_OFFSET_DEGREES := source_weapon_defaults.ROTATION_OFFSET_DEGREES
const SOURCE_WEAPON_HALF_CIRCLE_DEGREES := source_math_defaults.HALF_CIRCLE_DEGREES
const SOURCE_WEAPON_SHOOT_Y_DEFAULT := source_weapon_defaults.SHOOT_Y_DEFAULT
const SOURCE_WEAPON_ROTATE_DEFAULT := source_weapon_defaults.ROTATE_DEFAULT
const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := source_weapon_defaults.BASE_ROTATION_DEFAULT
const SOURCE_WEAPON_SHOOT_X_DEFAULT := source_weapon_defaults.SHOOT_X_DEFAULT
const SOURCE_WEAPON_SHOOT_SOUND_VOLUME_DEFAULT := source_weapon_defaults.SHOOT_SOUND_VOLUME_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MIN_DEFAULT := source_weapon_defaults.SOUND_PITCH_MIN_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MAX_DEFAULT := source_weapon_defaults.SOUND_PITCH_MAX_DEFAULT
const SOURCE_WEAPON_SHAKE_DEFAULT := source_weapon_defaults.SHAKE_DEFAULT
const SOURCE_WEAPON_INACCURACY_DEFAULT := source_weapon_defaults.INACCURACY_DEFAULT
const SOURCE_WEAPON_VELOCITY_RND_DEFAULT := source_weapon_defaults.VELOCITY_RND_DEFAULT
const SOURCE_WEAPON_EXTRA_VELOCITY_DEFAULT := source_weapon_defaults.EXTRA_VELOCITY_DEFAULT
const SOURCE_WEAPON_RELOAD_DEFAULT := source_weapon_defaults.RELOAD_DEFAULT
const SOURCE_WEAPON_AIM_CHANGE_SPEED_DEFAULT := source_weapon_defaults.AIM_CHANGE_SPEED_DEFAULT
const SOURCE_WEAPON_ALWAYS_CONTINUOUS_DEFAULT := source_weapon_defaults.ALWAYS_CONTINUOUS_DEFAULT
const SOURCE_WEAPON_SHOOT_STATUS_DURATION_DEFAULT := source_weapon_defaults.SHOOT_STATUS_DURATION_DEFAULT
const SOURCE_WEAPON_COOLDOWN_TIME_DEFAULT := source_weapon_defaults.COOLDOWN_TIME_DEFAULT

static func bullet_initial_guard_state(unit_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_create_state.bullet_initial_guard_state(unit_state, mount_state)

static func bullet_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_create_state.bullet_geometry_state(unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread, trns_vec)

static func bullet_angle_life_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	return source_weapon_bullet_create_state.bullet_angle_life_state(unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, trns_vec, bullet_origin_state, mathf_dst)

static func bullet_shooter_state(unit_state: Dictionary, controller_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_create_state.bullet_shooter_state(unit_state, controller_state)

static func bullet_create_call_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	return source_weapon_bullet_create_state.bullet_create_call_state(unit_state, mount_state, weapon_state, bullet_state, controller_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, velocity_random, mover, trns_vec, bullet_origin_state, mathf_dst)

static func bullet_handle_call_state(unit_state: Dictionary, mount_state: Dictionary, create_call_state: Dictionary, created_bullet: Variant) -> Dictionary:
	return source_weapon_bullet_create_state.bullet_handle_call_state(unit_state, mount_state, create_call_state, created_bullet)

static func _continuous_gate_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_continuous_state._continuous_gate_state(mount_state, weapon_state, bullet_state)

static func update_continuous_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_continuous_state.update_continuous_invalidation_state(mount_state, weapon_state, bullet_state)

static func update_continuous_live_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, weapon_rotation: float, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_continuous_state.update_continuous_live_state(mount_state, weapon_state, unit_state, bullet_state, source_delta, bullet_x, bullet_y, weapon_rotation, trns_vec)

static func update_continuous_sound_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, runtime_state: Dictionary, bullet_x: float, bullet_y: float) -> Dictionary:
	return source_weapon_bullet_continuous_state.update_continuous_sound_state(mount_state, weapon_state, bullet_state, runtime_state, bullet_x, bullet_y)

static func update_continuous_laser_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, shoot_angle: float, mathf_dst: Callable, approach_delta: Callable, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_continuous_state.update_continuous_laser_aim_state(mount_state, weapon_state, bullet_state, source_delta, bullet_x, bullet_y, shoot_angle, mathf_dst, approach_delta, trns_vec)

static func update_always_continuous_keepalive_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, status_apply_result: Callable) -> Dictionary:
	return source_weapon_bullet_continuous_state.update_always_continuous_keepalive_state(mount_state, weapon_state, bullet_state, unit_state, status_apply_result)

static func update_continuous_idle_heat_sound_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float) -> Dictionary:
	return source_weapon_bullet_continuous_state.update_continuous_idle_heat_sound_state(mount_state, weapon_state, unit_state, source_delta, bullet_x, bullet_y)

static func handle_bullet_continuous_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var continuous := bool(weapon_state.get("continuous", SOURCE_WEAPON_CONTINUOUS_DEFAULT))
	if not continuous:
		return {
			"continuous": false,
			"continuousGate": false,
			"aimUpdateReservedSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
		}
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_rotate := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var shoot_x := float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var weapon_rotation := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES + (mount_rotation if weapon_rotate else base_rotation)
	var mount_vec: Dictionary = trns_vec.call(unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES, weapon_x, weapon_y)
	var mount_x := unit_x + float(mount_vec["x"])
	var mount_y := unit_y + float(mount_vec["y"])
	var bullet_vec: Dictionary = trns_vec.call(weapon_rotation, shoot_x, shoot_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	return {
		"continuous": true,
		"continuousGate": true,
		"weaponRotation": weapon_rotation,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"lastLength": float(mount_state.get("lastLength", 0.0)),
		"continuousGateSource": "if(continuous){",
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y),",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY);",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"anglesTrnsxSource": "return rv.set(x, y).rotate(angle).x;",
		"anglesTrnsySource": "return rv.set(x, y).rotate(angle).y;",
		"aimUpdateReservedSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
	}

static func handle_bullet_aim_update_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, trns_vec: Callable, bullet_origin_state: Callable) -> Dictionary:
	var geometry_state := handle_bullet_continuous_geometry_state(unit_state, mount_state, weapon_state, trns_vec)
	if not bool(geometry_state.get("continuousGate", false)):
		return {
			"continuous": false,
			"continuousGate": false,
			"bulletAimUpdated": false,
			"bulletAimX": float(bullet_state.get("aimX", 0.0)),
			"bulletAimY": float(bullet_state.get("aimY", 0.0)),
			"aimUpdateSkippedSource": "if(continuous)",
		}
	var bullet_rotation_state: Dictionary = bullet_origin_state.call(mount_state, weapon_state, unit_state, float(geometry_state["mountX"]), float(geometry_state["mountY"]))
	var bullet_rotation := float(bullet_rotation_state["shootAngle"])
	var aim_length := float(geometry_state["shootY"]) + float(geometry_state["lastLength"])
	var aim_vec: Dictionary = trns_vec.call(bullet_rotation, aim_length, 0.0)
	var bullet_aim_x := float(aim_vec["x"]) + float(geometry_state["bulletX"])
	var bullet_aim_y := float(aim_vec["y"]) + float(geometry_state["bulletY"])
	return {
		"continuous": true,
		"continuousGate": true,
		"bulletAimUpdated": true,
		"weaponRotation": float(geometry_state["weaponRotation"]),
		"mountX": float(geometry_state["mountX"]),
		"mountY": float(geometry_state["mountY"]),
		"bulletX": float(geometry_state["bulletX"]),
		"bulletY": float(geometry_state["bulletY"]),
		"bulletRotation": bullet_rotation,
		"aimLength": aim_length,
		"bulletAimX": bullet_aim_x,
		"bulletAimY": bullet_aim_y,
		"previousBulletAimX": float(bullet_state.get("aimX", 0.0)),
		"previousBulletAimY": float(bullet_state.get("aimY", 0.0)),
		"aimUpdateSource": "Tmp.v1.trns(bulletRotation(unit, mount, bulletX, bulletY), shootY + mount.lastLength).add(bulletX, bulletY);",
		"bulletAimXSource": "bullet.aimX = Tmp.v1.x;",
		"bulletAimYSource": "bullet.aimY = Tmp.v1.y;",
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation",
		"vec2TrnsSource": "return set(amount, 0).rotate(angle);",
		"vec2AddSource": "this.x += x; this.y += y;",
	}

static func bullet_sound_state(create_call_state: Dictionary, weapon_state: Dictionary, sound_pitch: float) -> Dictionary:
	return source_weapon_bullet_effects_state.bullet_sound_state(create_call_state, weapon_state, sound_pitch)

static func bullet_effects_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_effects_state.bullet_effects_state(create_call_state, mount_state, weapon_state, bullet_state, unit_state)

static func bullet_recoil_velocity_state(create_call_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_effects_state.bullet_recoil_velocity_state(create_call_state, unit_state, bullet_state, trns_vec)

static func bullet_shake_state(create_call_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_effects_state.bullet_shake_state(create_call_state, weapon_state)

static func bullet_mount_recoil_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_effects_state.bullet_mount_recoil_state(create_call_state, mount_state)

static func bullet_recoil_slots_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_effects_state.bullet_recoil_slots_state(create_call_state, mount_state, weapon_state)

static func bullet_heat_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_effects_state.bullet_heat_state(create_call_state, mount_state)
