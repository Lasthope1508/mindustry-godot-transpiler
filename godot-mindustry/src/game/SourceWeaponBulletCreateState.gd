extends RefCounted
class_name SourceWeaponBulletCreateState

const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")

const SOURCE_WEAPON_X_DEFAULT := source_weapon_defaults.X_DEFAULT
const SOURCE_WEAPON_Y_DEFAULT := source_weapon_defaults.Y_DEFAULT
const SOURCE_WEAPON_ROTATION_OFFSET_DEGREES := source_weapon_defaults.ROTATION_OFFSET_DEGREES
const SOURCE_WEAPON_SHOOT_Y_DEFAULT := source_weapon_defaults.SHOOT_Y_DEFAULT
const SOURCE_WEAPON_ROTATE_DEFAULT := source_weapon_defaults.ROTATE_DEFAULT
const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := source_weapon_defaults.BASE_ROTATION_DEFAULT
const SOURCE_WEAPON_SHOOT_X_DEFAULT := source_weapon_defaults.SHOOT_X_DEFAULT
const SOURCE_WEAPON_INACCURACY_DEFAULT := source_weapon_defaults.INACCURACY_DEFAULT
const SOURCE_WEAPON_VELOCITY_RND_DEFAULT := source_weapon_defaults.VELOCITY_RND_DEFAULT
const SOURCE_WEAPON_EXTRA_VELOCITY_DEFAULT := source_weapon_defaults.EXTRA_VELOCITY_DEFAULT

static func bullet_initial_guard_state(unit_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	var unit_added := bool(unit_state.get("isAdded", false))
	var bullet_continues := unit_added
	var mount_charging := bool(mount_state.get("charging", false))
	if bullet_continues:
		mount_charging = false
	return {
		"unitAdded": unit_added,
		"bulletContinues": bullet_continues,
		"mountCharging": mount_charging,
		"unitAddedGuardSource": "if(!unit.isAdded()) return",
		"chargingResetSource": "mount.charging = false",
		"geometryReservedSource": "float xSpread = Mathf.range(xRand)",
	}

static func bullet_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, trns_vec: Callable) -> Dictionary:
	var guard_state := bullet_initial_guard_state(unit_state, mount_state)
	var bullet_continues := bool(guard_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": guard_state.get("mountCharging", false),
			"xSpreadSource": "xSpread = Mathf.range(xRand)",
			"ySpreadSource": "ySpread = Mathf.range(yRand)",
			"shootAngleReservedSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
		}
	var unit_x := float(unit_state.get("x", 0.0))
	var unit_y := float(unit_state.get("y", 0.0))
	var unit_rotation := float(unit_state.get("rotation", 0.0))
	var weapon_x := float(weapon_state.get("x", SOURCE_WEAPON_X_DEFAULT))
	var weapon_y := float(weapon_state.get("y", SOURCE_WEAPON_Y_DEFAULT))
	var weapon_rotate := bool(weapon_state.get("rotate", SOURCE_WEAPON_ROTATE_DEFAULT))
	var mount_rotation := float(mount_state.get("rotation", 0.0))
	var base_rotation := float(weapon_state.get("baseRotation", SOURCE_WEAPON_BASE_ROTATION_DEFAULT))
	var shoot_x := float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT))
	var shoot_y := float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT))
	var weapon_rotation := unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES + (mount_rotation if weapon_rotate else base_rotation)
	var mount_vec: Dictionary = trns_vec.call(unit_rotation - SOURCE_WEAPON_ROTATION_OFFSET_DEGREES, weapon_x, weapon_y)
	var mount_x := unit_x + float(mount_vec["x"])
	var mount_y := unit_y + float(mount_vec["y"])
	var bullet_offset_x := shoot_x + x_offset + x_spread
	var bullet_offset_y := shoot_y + y_offset + y_spread
	var bullet_vec: Dictionary = trns_vec.call(weapon_rotation, bullet_offset_x, bullet_offset_y)
	var bullet_x := mount_x + float(bullet_vec["x"])
	var bullet_y := mount_y + float(bullet_vec["y"])
	return {
		"bulletContinues": true,
		"mountCharging": guard_state.get("mountCharging", false),
		"xSpread": x_spread,
		"ySpread": y_spread,
		"weaponRotation": weapon_rotation,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletOffsetX": bullet_offset_x,
		"bulletOffsetY": bullet_offset_y,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"xSpreadSource": "xSpread = Mathf.range(xRand)",
		"ySpreadSource": "ySpread = Mathf.range(yRand)",
		"mathfRangeSource": "return random(-range, range)",
		"weaponRotationSource": "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation)",
		"mountXSource": "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y)",
		"mountYSource": "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y)",
		"bulletXSource": "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread)",
		"bulletYSource": "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread)",
		"anglesSource": "rv.set(x, y).rotate(angle)",
		"shootAngleReservedSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
	}

static func bullet_angle_life_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	var geometry_state := bullet_geometry_state(unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread, trns_vec)
	var bullet_continues := bool(geometry_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": geometry_state.get("mountCharging", false),
			"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
			"lifeSclSource": "lifeScl = bullet.scaleLife ? Mathf.clamp(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY) / bullet.range) : 1f",
			"angleSource": "angle = shootAngle + Mathf.range(inaccuracy + bullet.inaccuracy)",
		}
	var mount_x := float(geometry_state["mountX"])
	var mount_y := float(geometry_state["mountY"])
	var bullet_x := float(geometry_state["bulletX"])
	var bullet_y := float(geometry_state["bulletY"])
	var adjusted_weapon_state := weapon_state.duplicate(true)
	adjusted_weapon_state["shootX"] = float(weapon_state.get("shootX", SOURCE_WEAPON_SHOOT_X_DEFAULT)) + x_offset + x_spread
	adjusted_weapon_state["shootY"] = float(weapon_state.get("shootY", SOURCE_WEAPON_SHOOT_Y_DEFAULT)) + y_offset + y_spread
	var bullet_rotation_state: Dictionary = bullet_origin_state.call(mount_state, adjusted_weapon_state, unit_state, mount_x, mount_y)
	var shoot_angle := float(bullet_rotation_state["shootAngle"]) + angle_offset
	var life_scl := 1.0
	var bullet_scale_life := bool(bullet_state.get("scaleLife", false))
	var bullet_range := float(bullet_state.get("range", 0.0))
	var target_distance: float = float(mathf_dst.call(bullet_x, bullet_y, float(mount_state.get("aimX", 0.0)), float(mount_state.get("aimY", 0.0))))
	if bullet_scale_life:
		var life_ratio := target_distance / bullet_range
		life_scl = clampf(life_ratio, 0.0, 1.0)
	var weapon_inaccuracy := float(weapon_state.get("inaccuracy", SOURCE_WEAPON_INACCURACY_DEFAULT))
	var bullet_inaccuracy := float(bullet_state.get("inaccuracy", 0.0))
	var angle := shoot_angle + angle_spread
	return {
		"bulletContinues": true,
		"mountCharging": geometry_state.get("mountCharging", false),
		"shootAngle": shoot_angle,
		"bulletRotation": float(bullet_rotation_state["shootAngle"]),
		"lifeScl": life_scl,
		"angle": angle,
		"angleSpread": angle_spread,
		"inaccuracyRange": weapon_inaccuracy + bullet_inaccuracy,
		"bulletScaleLife": bullet_scale_life,
		"bulletRange": bullet_range,
		"targetDistance": target_distance,
		"bulletX": bullet_x,
		"bulletY": bullet_y,
		"mountX": mount_x,
		"mountY": mount_y,
		"bulletRotationSource": "return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation",
		"shootAngleSource": "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset",
		"lifeSclSource": "lifeScl = bullet.scaleLife ? Mathf.clamp(Mathf.dst(bulletX, bulletY, mount.aimX, mount.aimY) / bullet.range) : 1f",
		"mathfDstSource": "public static float dst(float x1, float y1, float x2, float y2)",
		"mathfClampSource": "return Math.max(Math.min(value, 1f), 0f)",
		"angleSource": "angle = shootAngle + Mathf.range(inaccuracy + bullet.inaccuracy)",
		"mathfRangeSource": "return random(-range, range)",
	}

static func bullet_shooter_state(unit_state: Dictionary, controller_state: Dictionary) -> Dictionary:
	var unit_id: Variant = unit_state.get("id", null)
	var controller_is_missile_ai := str(controller_state.get("type", "")) == "MissileAI"
	var missile_shooter: Variant = controller_state.get("shooter", null)
	var shooter: Variant = controller_state.get("shooter", null) if controller_is_missile_ai else unit_id
	return {
		"unit": unit_id,
		"controllerIsMissileAI": controller_is_missile_ai,
		"missileShooter": missile_shooter,
		"shooter": shooter,
		"shooterSelectionSource": "Entityc shooter = unit.controller() instanceof MissileAI ai ? ai.shooter : unit",
		"missileShooterSource": "public @Nullable Unit shooter",
		"unitControllerFieldSource": "private UnitController controller",
		"unitControllerSource": "public UnitController controller(){ return controller; }",
		"missileAiClassSource": "public class MissileAI extends AIController{",
		"bulletCreateReservedSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		"bulletCreateShooterParamSource": "@Nullable Entityc owner, @Nullable Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl,",
		"bulletCreateNullShooterFallbackSource": "bullet.shooter = (shooter == null ? owner : shooter)",
	}

static func bullet_create_call_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	var angle_life_state := bullet_angle_life_state(unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, trns_vec, bullet_origin_state, mathf_dst)
	var bullet_continues := bool(angle_life_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"mountCharging": angle_life_state.get("mountCharging", false),
			"bulletCreateCall": null,
			"mountBulletSetFromCreateCall": false,
			"bulletCreateCallSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		}
	var shooter_state := bullet_shooter_state(unit_state, controller_state)
	var velocity_rnd := float(weapon_state.get("velocityRnd", SOURCE_WEAPON_VELOCITY_RND_DEFAULT))
	var extra_velocity := float(weapon_state.get("extraVelocity", SOURCE_WEAPON_EXTRA_VELOCITY_DEFAULT))
	var velocity_scl := (1.0 - velocity_rnd) + velocity_random + extra_velocity
	var bullet_create_call := {
		"owner": unit_state.get("id", null),
		"shooter": shooter_state.get("shooter", null),
		"team": unit_state.get("team", null),
		"x": angle_life_state["bulletX"],
		"y": angle_life_state["bulletY"],
		"angle": angle_life_state["angle"],
		"damage": -1.0,
		"velocityScl": velocity_scl,
		"lifetimeScl": angle_life_state["lifeScl"],
		"data": null,
		"mover": mover,
		"aimX": float(mount_state.get("aimX", 0.0)),
		"aimY": float(mount_state.get("aimY", 0.0)),
		"target": mount_state.get("target", null),
	}
	return {
		"bulletContinues": true,
		"mountCharging": angle_life_state.get("mountCharging", false),
		"bulletCreateCall": bullet_create_call,
		"mountBulletSetFromCreateCall": true,
		"velocityRnd": velocity_rnd,
		"velocityRandom": velocity_random,
		"extraVelocity": extra_velocity,
		"velocityScl": velocity_scl,
		"angleLifeState": angle_life_state,
		"shooterState": shooter_state,
		"bulletCreateCallSource": "mount.bullet = bullet.create(unit, shooter, unit.team, bulletX, bulletY, angle, -1f, (1f - velocityRnd) + Mathf.random(velocityRnd) + extraVelocity, lifeScl, null, mover, mount.aimX, mount.aimY, mount.target)",
		"mathfRandomSource": "return rand.nextFloat() * range",
		"handleBulletReservedSource": "handleBullet(unit, mount, mount.bullet)",
	}

static func bullet_handle_call_state(unit_state: Dictionary, mount_state: Dictionary, create_call_state: Dictionary, created_bullet: Variant) -> Dictionary:
	var bullet_continues := bool(create_call_state.get("bulletContinues", false))
	if not bullet_continues:
		return {
			"bulletContinues": false,
			"handleBulletCalled": false,
			"handleBulletCall": null,
			"handleBulletSource": "handleBullet(unit, mount, mount.bullet)",
		}
	var handle_bullet_call := {
		"unit": unit_state.get("id", null),
		"mount": mount_state.get("id", null),
		"mountBullet": created_bullet,
		"bullet": created_bullet,
	}
	return {
		"bulletContinues": true,
		"handleBulletCalled": true,
		"handleBulletCall": handle_bullet_call,
		"mountBullet": created_bullet,
		"handleBulletSource": "handleBullet(unit, mount, mount.bullet)",
		"handleBulletInternalsReservedSource": "protected void handleBullet(Unit unit, WeaponMount mount, Bullet bullet)",
		"continuousBranchReservedSource": "if(continuous)",
		"soundReservedSource": "if(!continuous)",
	}
