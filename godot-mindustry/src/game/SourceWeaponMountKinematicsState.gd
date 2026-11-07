extends RefCounted
class_name SourceWeaponMountKinematicsState

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_WEAPON_X_DEFAULT := source_weapon_defaults.X_DEFAULT
const SOURCE_WEAPON_Y_DEFAULT := source_weapon_defaults.Y_DEFAULT
const SOURCE_WEAPON_ROTATION_OFFSET_DEGREES := source_weapon_defaults.ROTATION_OFFSET_DEGREES
const SOURCE_WEAPON_FULL_CIRCLE_DEGREES := source_math_defaults.FULL_CIRCLE_DEGREES
const SOURCE_WEAPON_ROTATE_DEFAULT := source_weapon_defaults.ROTATE_DEFAULT
const SOURCE_WEAPON_ROTATE_SPEED_DEFAULT := source_weapon_defaults.ROTATE_SPEED_DEFAULT
const SOURCE_WEAPON_ROTATION_LIMIT_DEFAULT := source_weapon_defaults.ROTATION_LIMIT_DEFAULT
const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := source_weapon_defaults.BASE_ROTATION_DEFAULT
const SOURCE_WEAPON_SHOOT_X_DEFAULT := source_weapon_defaults.SHOOT_X_DEFAULT
const SOURCE_WEAPON_SHOOT_Y_DEFAULT := source_weapon_defaults.SHOOT_Y_DEFAULT

static func update_mount_origin_state(unit_state: Dictionary, weapon_state: Dictionary, trns_vec: Callable) -> Dictionary:
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var angle_degrees := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES
	var rotated: Dictionary = trns_vec.call(angle_degrees, weapon_x, weapon_y)
	var mount_x := unit_x + float(rotated["x"])
	var mount_y := unit_y + float(rotated["y"])
	return {
		"methodSource": "public void update(Unit unit, WeaponMount mount){",
		"angle": angle_degrees,
		"trnsx": float(rotated["x"]),
		"trnsy": float(rotated["y"]),
		"mountX": mount_x,
		"mountY": mount_y,
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"vec2RotateSource": "newX = this.x * cos - this.y * sin; newY = this.x * sin + this.y * cos",
	}

static func update_rotate_toward_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float, trns_vec: Callable, angles_angle: Callable, move_toward_angle: Callable, angle_dist: Callable) -> Dictionary:
	var mount_rotate := bool(mount_state.get("rotate", false))
	var mount_shoot := bool(mount_state.get("shoot", false))
	var current_rotation := float(mount_state.get("rotation", 0.0))
	var current_target_rotation := float(mount_state.get("targetRotation", 0.0))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var rotate_speed := float(weapon_state.get("rotateSpeed", SOURCE_WEAPON_ROTATE_SPEED_DEFAULT))
	var rotation_limit := float(weapon_state.get("rotationLimit", SOURCE_WEAPON_ROTATION_LIMIT_DEFAULT))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var gate := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT)) and (mount_rotate or mount_shoot) and can_shoot
	var non_rotate_branch := not bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var axis_angle := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES
	var axis_vec: Dictionary = trns_vec.call(axis_angle, weapon_x, weapon_y)
	var axis_x := unit_x + float(axis_vec["x"])
	var axis_y := unit_y + float(axis_vec["y"])
	var target_rotation := current_target_rotation
	var next_rotation := current_rotation
	var limit_dst := 0.0
	if gate:
		target_rotation = angles_angle.call(axis_x, axis_y, aim_x, aim_y) - unit_rotation
		next_rotation = move_toward_angle.call(current_rotation, target_rotation, rotate_speed * source_delta)
	if gate and rotation_limit < SOURCE_WEAPON_FULL_CIRCLE_DEGREES:
		limit_dst = angle_dist.call(next_rotation, base_rotation)
		if limit_dst > rotation_limit / 2.0:
			next_rotation = move_toward_angle.call(next_rotation, base_rotation, limit_dst - rotation_limit / 2.0)
	elif non_rotate_branch:
		next_rotation = base_rotation
		target_rotation = angles_angle.call(unit_x, unit_y, aim_x, aim_y)
	return {
		"gate": gate,
		"axisAngle": axis_angle,
		"axisX": axis_x,
		"axisY": axis_y,
		"targetRotation": target_rotation,
		"rotation": next_rotation,
		"rotationLimit": rotation_limit,
		"baseRotation": base_rotation,
		"limitDistance": limit_dst,
		"rotationLimitApplied": gate and rotation_limit < SOURCE_WEAPON_FULL_CIRCLE_DEGREES and limit_dst > rotation_limit / 2.0,
		"nonRotateApplied": non_rotate_branch,
		"canShoot": can_shoot,
		"mountRotate": mount_rotate,
		"mountShoot": mount_shoot,
		"gateSource": "if(rotate && (mount.rotate || mount.shoot) && can){",
		"axisXSource": "float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),",
		"axisYSource": "axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y);",
		"targetRotationSource": "mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;",
		"rotationSource": "mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);",
		"rotationLimitSource": "if(rotationLimit < 360){",
		"limitDistanceSource": "float dst = Angles.angleDist(mount.rotation, baseRotation);",
		"limitMoveSource": "mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);",
		"nonRotateSource": "else if(!rotate){",
		"baseRotationSource": "mount.rotation = baseRotation;",
		"angleToSource": "mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);",
	}

static func update_bullet_origin_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float, trns_vec: Callable, angles_angle: Callable) -> Dictionary:
	var rotate_weapon := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var aim_x := float(mount_state.get("aimX", 0.0))
	var aim_y := float(mount_state.get("aimY", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var shoot_x := float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_rotation := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES + (mount_rotation if rotate_weapon else base_rotation)
	var bullet_vec: Dictionary = trns_vec.call(weapon_rotation, shoot_x, shoot_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	var shoot_angle := unit_rotation + mount_rotation
	if not rotate_weapon:
		shoot_angle = angles_angle.call(bullet_x, bullet_y, aim_x, aim_y) + (unit_rotation - angles_angle.call(unit_x, unit_y, aim_x, aim_y)) + base_rotation
	return {
		"rotate": rotate_weapon,
		"weaponRotation": weapon_rotation,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"shootAngle": shoot_angle,
		"mountX": mount_x,
		"mountY": mount_y,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"baseRotation": base_rotation,
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),",
		"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY);",
		"bulletRotationMethodSource": "protected float bulletRotation(Unit unit, WeaponMount mount, float bulletX, float bulletY){",
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;",
		"anglesTrnsxSource": "public static float trnsx(float angle, float x, float y){",
		"anglesTrnsySource": "public static float trnsy(float angle, float x, float y){",
		"anglesAngleSource": "public static float angle(float x, float y, float x2, float y2){",
		"positionAngleToSource": "default float angleTo(float x, float y){",
	}
