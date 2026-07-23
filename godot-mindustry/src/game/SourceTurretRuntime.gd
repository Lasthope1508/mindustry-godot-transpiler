extends RefCounted
class_name SourceTurretRuntime

const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")

const SOURCE_TURRET_RELOAD_FIELD := "public float reload = 10f;"
const SOURCE_TURRET_RELOAD_KEY := "reload"
const SOURCE_TURRET_RELOAD_DUO_VALUE := "reload = 20f;"
const SOURCE_TIME_TO_SECONDS_FIELD := "public static final float toSeconds = 60f"
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_UPDATE_RELOAD := "reloadCounter += delta() * ammoReloadMultiplier() * baseReloadSpeed();"
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD := "protected float ammoReloadMultiplier(){"
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN := "return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;"
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA := "source_turret_reload_seconds(turret) / source_bullet_reload_multiplier(data)"

const SOURCE_TURRET_RANGE_FIELD := "public float range = 80f;"
const SOURCE_TURRET_RANGE_METHOD := "public float range(){\n            return range;\n        }"
const SOURCE_TURRET_RANGE_KEY := "range"
const SOURCE_TURRET_RANGE_DUO_VALUE := "range = 160;"
const SOURCE_TURRET_RANGE_FOR_AMMO_METHOD := "public float range(){\n            if(peekAmmo() != null){\n                return range + peekAmmo().rangeChange;\n            }\n            return range;\n        }"
const SOURCE_TURRET_RANGE_FOR_AMMO_GATE := "if(peekAmmo() != null){"
const SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT := "return range + peekAmmo().rangeChange;"
const SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT := "return range;"

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
const SOURCE_TURRET_TOTAL_INACCURACY_EXPR := "inaccuracy + type.inaccuracy"
const SOURCE_TURRET_TOTAL_INACCURACY_SHOOT_ANGLE := "shootAngle = rotation + angleOffset + Mathf.range(inaccuracy + type.inaccuracy);"

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
const SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK := "if(recoilTime < 0f) recoilTime = reload;"
const SOURCE_TURRET_RECOIL_TIME_DECAY_USE := "curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);"
const SOURCE_TURRET_RECOIL_OFFSET_COMMENT := "/** Turret sprite offset, based on recoil. Updated every frame. */"
const SOURCE_TURRET_RECOIL_OFFSET_FIELD := "public Vec2 recoilOffset = new Vec2();"
const SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_FIELD := "public float recoilPow = 1.8f;"
const SOURCE_TURRET_RECOIL_OFFSET_CUR_RECOIL_FIELD := "public float curRecoil, heat, logicControlTime = -1;"
const SOURCE_TURRET_RECOIL_OFFSET_FORMULA := "recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);"

const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_POINT_FIELD := "public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;"
const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_Y_DEFAULT := "if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;"
const SOURCE_TURRET_BULLET_ORIGIN_X_SPREAD := "xSpread = Mathf.range(xRand)"
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_X := "bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset)"
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y := "bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset)"

static func _properties(turret) -> Dictionary:
	if turret == null:
		return {}
	if turret is Dictionary:
		return turret.get("properties", {})
	return turret.properties

static func _trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	var radians := deg_to_rad(angle_degrees)
	var cos_value := cos(radians)
	var sin_value := sin(radians)
	return {
		"x": x_value * cos_value - y_value * sin_value,
		"y": x_value * sin_value + y_value * cos_value,
	}

static func reload_seconds(turret, defaults: SourceTurretDefaults, tick_rate: float) -> float:
	if turret == null or tick_rate == 0.0:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_RELOAD_KEY, defaults.reload_default())) / tick_rate

static func reload_seconds_for_ammo(turret, data: Dictionary, defaults: SourceTurretDefaults, tick_rate: float, bullet_reload_multiplier: float) -> float:
	var seconds := reload_seconds(turret, defaults, tick_rate)
	if data.is_empty():
		return seconds
	if bullet_reload_multiplier == 0.0:
		return seconds
	return seconds / bullet_reload_multiplier

static func range_value(turret, defaults: SourceTurretDefaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_RANGE_KEY, defaults.range_default()))

static func range_for_ammo(turret, data: Dictionary, defaults: SourceTurretDefaults, bullet_range_change: float) -> float:
	if data.is_empty():
		return range_value(turret, defaults)
	return range_value(turret, defaults) + bullet_range_change

static func shoot_y(turret, defaults: SourceTurretDefaults, source_tilesize: float) -> float:
	if turret == null:
		return 0.0
	var properties := _properties(turret)
	var source_default := defaults.shoot_y_default(float(properties.get("size", 0.0)), source_tilesize)
	return float(properties.get(SOURCE_TURRET_SHOOT_Y_KEY, source_default))

static func inaccuracy(turret, defaults: SourceTurretDefaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_INACCURACY_KEY, defaults.inaccuracy_default()))

static func total_inaccuracy(turret, defaults: SourceTurretDefaults, bullet_inaccuracy: float) -> float:
	return inaccuracy(turret, defaults) + bullet_inaccuracy

static func rotate_speed(turret, defaults: SourceTurretDefaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_ROTATE_SPEED_KEY, defaults.rotate_speed_default()))

static func shoot_cone(turret, defaults: SourceTurretDefaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_SHOOT_CONE_KEY, defaults.shoot_cone_default()))

static func recoil(turret, defaults: SourceTurretDefaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_RECOIL_KEY, defaults.recoil_default()))

static func recoils(turret, defaults: SourceTurretDefaults) -> int:
	if turret == null:
		return 0
	return int(_properties(turret).get(SOURCE_TURRET_RECOILS_KEY, defaults.recoils_default()))

static func recoil_time(turret, defaults: SourceTurretDefaults, reload_seconds_value: float, tick_rate: float) -> float:
	if turret == null:
		return 1.0
	var recoil_time_value := float(_properties(turret).get(SOURCE_TURRET_RECOIL_TIME_KEY, defaults.recoil_time_default()))
	if recoil_time_value < 0.0:
		return reload_seconds_value * tick_rate
	return recoil_time_value

static func recoil_offset(turret, defaults: SourceTurretDefaults, recoil_rotation_degrees: float, cur_recoil: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(recoil_rotation_degrees)) * (-pow(cur_recoil, defaults.recoil_pow()) * recoil(turret, defaults))

static func bullet_origin(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, defaults: SourceTurretDefaults, source_tilesize: float, shoot_x_offset := 0.0, y_offset := 0.0, x_spread := 0.0) -> Dictionary:
	var properties := _properties(turret)
	var shoot_x := float(properties.get("shootX", 0.0))
	var shoot_y_value := shoot_y(turret, defaults, source_tilesize)
	var rotation_minus_90 := turret_rotation_degrees - 90.0
	var trns := _trns_vec(rotation_minus_90, shoot_x + shoot_x_offset + x_spread, shoot_y_value + y_offset)
	return {
		"originX": origin_x,
		"originY": origin_y,
		"rotationDegrees": turret_rotation_degrees,
		"rotationMinus90": rotation_minus_90,
		"shootX": shoot_x,
		"shootY": shoot_y_value,
		"shootXOffset": shoot_x_offset,
		"yOffset": y_offset,
		"xSpread": x_spread,
		"trnsx": float(trns.get("x", 0.0)),
		"trnsy": float(trns.get("y", 0.0)),
		"bulletX": origin_x + float(trns.get("x", 0.0)),
		"bulletY": origin_y + float(trns.get("y", 0.0)),
		"bulletXSource": SOURCE_TURRET_BULLET_ORIGIN_BULLET_X,
		"bulletYSource": SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y,
	}
