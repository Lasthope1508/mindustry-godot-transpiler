extends RefCounted
class_name SourceTurretPropertyState

const SOURCE_TURRET_RELOAD_FIELD := "public float reload = 10f;"
const SOURCE_TURRET_RELOAD_KEY := "reload"
const SOURCE_TURRET_RELOAD_DUO_VALUE := "reload = 20f;"
const SOURCE_TIME_TO_SECONDS_FIELD := "public static final float toSeconds = 60f"

const SOURCE_TURRET_RANGE_FIELD := "public float range = 80f;"
const SOURCE_TURRET_RANGE_METHOD := "public float range(){\n            return range;\n        }"
const SOURCE_TURRET_RANGE_KEY := "range"
const SOURCE_TURRET_RANGE_DUO_VALUE := "range = 160;"

const SOURCE_TURRET_SHOOT_Y_COMMENT := "/** Turret shoot point. */"
const SOURCE_TURRET_SHOOT_Y_FIELD := "public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;"
const SOURCE_TURRET_SHOOT_Y_KEY := "shootY"
const SOURCE_TURRET_SHOOT_Y_SENTINEL := "Float.NEGATIVE_INFINITY"
const SOURCE_TURRET_SHOOT_Y_INIT_DEFAULT := "if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;"
const SOURCE_TURRET_SHOOT_Y_DUO_VALUE := "shootY = 3f;"

const SOURCE_TURRET_INACCURACY_COMMENT := "/** Bullet angle randomness in degrees. */"
const SOURCE_TURRET_INACCURACY_FIELD := "public float inaccuracy = 0f;"
const SOURCE_TURRET_INACCURACY_KEY := "inaccuracy"
const SOURCE_TURRET_INACCURACY_DUO_VALUE := "inaccuracy = 2f;"
const SOURCE_TURRET_INACCURACY_SHOOT_ANGLE := "shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy);"

const SOURCE_TURRET_ROTATE_SPEED_FIELD := "public float rotateSpeed = 5;"
const SOURCE_TURRET_ROTATE_SPEED_KEY := "rotateSpeed"
const SOURCE_TURRET_ROTATE_SPEED_DUO_VALUE := "rotateSpeed = 10f;"
const SOURCE_TURRET_ROTATE_SPEED_TURN_TO_TARGET := "rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);"

const SOURCE_TURRET_SHOOT_CONE_COMMENT := "/** Maximum angle difference in degrees at which turret will still try to shoot. */"
const SOURCE_TURRET_SHOOT_CONE_FIELD := "public float shootCone = 8f;"
const SOURCE_TURRET_SHOOT_CONE_KEY := "shootCone"
const SOURCE_TURRET_SHOOT_CONE_DUO_VALUE := "shootCone = 15f;"
const SOURCE_TURRET_SHOOT_CONE_CAN_SHOOT_GATE := "if(!alwaysShooting && Angles.angleDist(rotation, targetRot) < shootCone && canShoot){"

const SOURCE_TURRET_RECOIL_COMMENT := "/** Visual amount by which the turret recoils back per shot. */"
const SOURCE_TURRET_RECOIL_FIELD := "public float recoil = 1f;"
const SOURCE_TURRET_RECOIL_KEY := "recoil"
const SOURCE_TURRET_RECOIL_DUO_VALUE := "recoil = 0.5f;"
const SOURCE_TURRET_RECOILS_COMMENT := "/** Number of additional counters for recoil. */"
const SOURCE_TURRET_RECOILS_FIELD := "public int recoils = -1;"
const SOURCE_TURRET_RECOILS_KEY := "recoils"
const SOURCE_TURRET_RECOILS_DUO_VALUE := "recoils = 2;"
const SOURCE_TURRET_RECOIL_TIME_COMMENT := "/** ticks taken for turret to return to starting position in ticks. uses reload time by default  */"
const SOURCE_TURRET_RECOIL_TIME_FIELD := "public float recoilTime = -1f;"
const SOURCE_TURRET_RECOIL_TIME_KEY := "recoilTime"

const SOURCE_TURRET_RECOIL_OFFSET_COMMENT := "/** Turret sprite offset, based on recoil. Updated every frame. */"
const SOURCE_TURRET_RECOIL_OFFSET_FIELD := "public Vec2 recoilOffset = new Vec2();"
const SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_FIELD := "public float recoilPow = 1.8f;"
const SOURCE_TURRET_RECOIL_OFFSET_CUR_RECOIL_FIELD := "public float curRecoil, heat, logicControlTime = -1;"

const SOURCE_TURRET_SHOOT_PATTERN_FIELD := "public ShootPattern shoot = new ShootPattern();"
const SOURCE_TURRET_SHOOT_PATTERN_KEY := "shootPattern"
const SOURCE_TURRET_SHOOT_PATTERN_DUO_ASSIGNMENT := "shoot = new ShootAlternate(3.5f);"
const SOURCE_TURRET_SHOOT_PATTERN_SELECTION := "ShootPattern pattern = type.shootPattern != null ? type.shootPattern : shoot;"
const SOURCE_TURRET_SHOOT_PATTERN_DISPATCH := "pattern.shoot(barrelCounter, (xOffset, yOffset, angle, delay, mover) -> {"

static func reload_seconds_state(turret_properties: Dictionary, reload_key: String, reload_default: float, tick_rate: float) -> Dictionary:
	var reload_ticks := float(turret_properties.get(reload_key, reload_default))
	var reload_seconds := reload_ticks / tick_rate if tick_rate != 0.0 else 0.0
	return {
		"reload_field": SOURCE_TURRET_RELOAD_FIELD,
		"reload_key": reload_key,
		"reload_ticks": reload_ticks,
		"tick_rate": tick_rate,
		"reload_seconds": reload_seconds,
	}

static func range_state(turret_properties: Dictionary, range_key: String, range_default: float) -> Dictionary:
	var range_value := float(turret_properties.get(range_key, range_default))
	return {
		"range_field": SOURCE_TURRET_RANGE_FIELD,
		"range_method": SOURCE_TURRET_RANGE_METHOD,
		"range_key": range_key,
		"range": range_value,
	}

static func shoot_y_state(turret_properties: Dictionary, shoot_y_key: String, shoot_y_default: float) -> Dictionary:
	var shoot_y := float(turret_properties.get(shoot_y_key, shoot_y_default))
	return {
		"shoot_y_comment": SOURCE_TURRET_SHOOT_Y_COMMENT,
		"shoot_y_field": SOURCE_TURRET_SHOOT_Y_FIELD,
		"shoot_y_key": shoot_y_key,
		"shoot_y": shoot_y,
	}

static func inaccuracy_state(turret_properties: Dictionary, inaccuracy_key: String, inaccuracy_default: float) -> Dictionary:
	var inaccuracy := float(turret_properties.get(inaccuracy_key, inaccuracy_default))
	return {
		"inaccuracy_comment": SOURCE_TURRET_INACCURACY_COMMENT,
		"inaccuracy_field": SOURCE_TURRET_INACCURACY_FIELD,
		"inaccuracy_key": inaccuracy_key,
		"inaccuracy": inaccuracy,
	}

static func rotate_speed_state(turret_properties: Dictionary, rotate_speed_key: String, rotate_speed_default: float) -> Dictionary:
	var rotate_speed := float(turret_properties.get(rotate_speed_key, rotate_speed_default))
	return {
		"rotate_speed_field": SOURCE_TURRET_ROTATE_SPEED_FIELD,
		"rotate_speed_key": rotate_speed_key,
		"rotate_speed": rotate_speed,
	}

static func shoot_cone_state(turret_properties: Dictionary, shoot_cone_key: String, shoot_cone_default: float) -> Dictionary:
	var shoot_cone := float(turret_properties.get(shoot_cone_key, shoot_cone_default))
	return {
		"shoot_cone_comment": SOURCE_TURRET_SHOOT_CONE_COMMENT,
		"shoot_cone_field": SOURCE_TURRET_SHOOT_CONE_FIELD,
		"shoot_cone_key": shoot_cone_key,
		"shoot_cone": shoot_cone,
	}

static func recoil_state(turret_properties: Dictionary, recoil_key: String, recoil_default: float) -> Dictionary:
	var recoil := float(turret_properties.get(recoil_key, recoil_default))
	return {
		"recoil_comment": SOURCE_TURRET_RECOIL_COMMENT,
		"recoil_field": SOURCE_TURRET_RECOIL_FIELD,
		"recoil_key": recoil_key,
		"recoil": recoil,
	}

static func recoils_state(turret_properties: Dictionary, recoils_key: String, recoils_default: int) -> Dictionary:
	var recoils := int(turret_properties.get(recoils_key, recoils_default))
	return {
		"recoils_comment": SOURCE_TURRET_RECOILS_COMMENT,
		"recoils_field": SOURCE_TURRET_RECOILS_FIELD,
		"recoils_key": recoils_key,
		"recoils": recoils,
	}

static func recoil_time_state(turret_properties: Dictionary, recoil_time_key: String, recoil_time_default: float, reload_seconds: float, tick_rate: float) -> Dictionary:
	var raw_recoil_time := float(turret_properties.get(recoil_time_key, recoil_time_default))
	var used_reload_fallback := raw_recoil_time < 0.0
	var recoil_time := reload_seconds * tick_rate if used_reload_fallback else raw_recoil_time
	return {
		"recoil_time_comment": SOURCE_TURRET_RECOIL_TIME_COMMENT,
		"recoil_time_field": SOURCE_TURRET_RECOIL_TIME_FIELD,
		"recoil_time_key": recoil_time_key,
		"raw_recoil_time": raw_recoil_time,
		"used_reload_fallback": used_reload_fallback,
		"recoil_time": recoil_time,
	}

static func shoot_pattern_state(turret_properties: Dictionary, shoot_pattern_key: String) -> Dictionary:
	var shoot_pattern = turret_properties.get(shoot_pattern_key, {})
	return {
		"shoot_pattern_field": SOURCE_TURRET_SHOOT_PATTERN_FIELD,
		"shoot_pattern_key": shoot_pattern_key,
		"shoot_pattern": shoot_pattern if typeof(shoot_pattern) == TYPE_DICTIONARY else {},
	}
