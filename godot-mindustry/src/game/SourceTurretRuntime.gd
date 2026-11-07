extends RefCounted
class_name SourceTurretRuntime

const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_turret_accuracy_state := preload("res://src/game/SourceTurretAccuracyState.gd")
const source_turret_recoil_state := preload("res://src/game/SourceTurretRecoilState.gd")
const source_turret_bullet_origin_state := preload("res://src/game/SourceTurretBulletOriginState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_runtime_property_stats_state := preload("res://src/game/SourceTurretRuntimePropertyStatsState.gd")

const SOURCE_TURRET_RELOAD_FIELD := source_turret_source_text_state.SOURCE_TURRET_RELOAD_FIELD
const SOURCE_TURRET_RELOAD_KEY := source_turret_source_text_state.SOURCE_TURRET_RELOAD_KEY
const SOURCE_TURRET_RELOAD_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_RELOAD_DUO_VALUE
const SOURCE_TIME_TO_SECONDS_FIELD := source_time_defaults.SOURCE_TIME_TO_SECONDS_FIELD
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_UPDATE_RELOAD := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_UPDATE_RELOAD
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA := source_turret_runtime_property_stats_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA

const SOURCE_TURRET_RANGE_FIELD := source_turret_source_text_state.SOURCE_TURRET_RANGE_FIELD
const SOURCE_TURRET_RANGE_METHOD := source_turret_source_text_state.SOURCE_TURRET_RANGE_METHOD
const SOURCE_TURRET_RANGE_KEY := source_turret_source_text_state.SOURCE_TURRET_RANGE_KEY
const SOURCE_TURRET_RANGE_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_RANGE_DUO_VALUE
const SOURCE_TURRET_RANGE_FOR_AMMO_METHOD := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_METHOD
const SOURCE_TURRET_RANGE_FOR_AMMO_GATE := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_GATE
const SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT
const SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT := source_turret_runtime_property_stats_state.SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT

const SOURCE_TURRET_SHOOT_Y_COMMENT := source_turret_source_text_state.SOURCE_TURRET_SHOOT_Y_COMMENT
const SOURCE_TURRET_SHOOT_Y_FIELD := source_turret_source_text_state.SOURCE_TURRET_SHOOT_Y_FIELD
const SOURCE_TURRET_SHOOT_Y_KEY := source_turret_source_text_state.SOURCE_TURRET_SHOOT_Y_KEY
const SOURCE_TURRET_SHOOT_Y_SENTINEL := source_turret_source_text_state.SOURCE_TURRET_SHOOT_Y_SENTINEL
const SOURCE_TURRET_SHOOT_Y_INIT_DEFAULT := source_turret_source_text_state.SOURCE_TURRET_SHOOT_Y_INIT_DEFAULT
const SOURCE_TURRET_SHOOT_Y_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_SHOOT_Y_DUO_VALUE

const SOURCE_TURRET_INACCURACY_COMMENT := source_turret_source_text_state.SOURCE_TURRET_INACCURACY_COMMENT
const SOURCE_TURRET_INACCURACY_FIELD := source_turret_source_text_state.SOURCE_TURRET_INACCURACY_FIELD
const SOURCE_TURRET_INACCURACY_KEY := source_turret_source_text_state.SOURCE_TURRET_INACCURACY_KEY
const SOURCE_TURRET_INACCURACY_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_INACCURACY_DUO_VALUE
const SOURCE_TURRET_INACCURACY_SHOOT_ANGLE := source_turret_source_text_state.SOURCE_TURRET_INACCURACY_SHOOT_ANGLE
const SOURCE_TURRET_TOTAL_INACCURACY_EXPR := source_turret_accuracy_state.SOURCE_TURRET_TOTAL_INACCURACY_EXPR
const SOURCE_TURRET_TOTAL_INACCURACY_SHOOT_ANGLE := source_turret_source_text_state.SOURCE_TURRET_INACCURACY_SHOOT_ANGLE

const SOURCE_TURRET_ROTATE_SPEED_FIELD := source_turret_source_text_state.SOURCE_TURRET_ROTATE_SPEED_FIELD
const SOURCE_TURRET_ROTATE_SPEED_KEY := source_turret_source_text_state.SOURCE_TURRET_ROTATE_SPEED_KEY
const SOURCE_TURRET_ROTATE_SPEED_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_ROTATE_SPEED_DUO_VALUE
const SOURCE_TURRET_ROTATE_SPEED_TURN_TO_TARGET := source_turret_source_text_state.SOURCE_TURRET_ROTATE_SPEED_TURN_TO_TARGET

const SOURCE_TURRET_SHOOT_CONE_COMMENT := source_turret_source_text_state.SOURCE_TURRET_SHOOT_CONE_COMMENT
const SOURCE_TURRET_SHOOT_CONE_FIELD := source_turret_source_text_state.SOURCE_TURRET_SHOOT_CONE_FIELD
const SOURCE_TURRET_SHOOT_CONE_KEY := source_turret_source_text_state.SOURCE_TURRET_SHOOT_CONE_KEY
const SOURCE_TURRET_SHOOT_CONE_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_SHOOT_CONE_DUO_VALUE
const SOURCE_TURRET_SHOOT_CONE_CAN_SHOOT_GATE := source_turret_source_text_state.SOURCE_TURRET_SHOOT_CONE_CAN_SHOOT_GATE

const SOURCE_TURRET_RECOIL_COMMENT := source_turret_source_text_state.SOURCE_TURRET_RECOIL_COMMENT
const SOURCE_TURRET_RECOIL_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_FIELD
const SOURCE_TURRET_RECOIL_KEY := source_turret_source_text_state.SOURCE_TURRET_RECOIL_KEY
const SOURCE_TURRET_RECOIL_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_RECOIL_DUO_VALUE
const SOURCE_TURRET_RECOILS_COMMENT := source_turret_source_text_state.SOURCE_TURRET_RECOILS_COMMENT
const SOURCE_TURRET_RECOILS_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOILS_FIELD
const SOURCE_TURRET_RECOILS_KEY := source_turret_source_text_state.SOURCE_TURRET_RECOILS_KEY
const SOURCE_TURRET_RECOILS_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_RECOILS_DUO_VALUE
const SOURCE_TURRET_RECOIL_TIME_COMMENT := source_turret_source_text_state.SOURCE_TURRET_RECOIL_TIME_COMMENT
const SOURCE_TURRET_RECOIL_TIME_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_TIME_FIELD
const SOURCE_TURRET_RECOIL_TIME_KEY := source_turret_source_text_state.SOURCE_TURRET_RECOIL_TIME_KEY
const SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK := source_turret_recoil_state.SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK
const SOURCE_TURRET_RECOIL_TIME_DECAY_USE := source_turret_recoil_state.SOURCE_TURRET_RECOIL_TIME_DECAY_USE
const SOURCE_TURRET_RECOIL_OFFSET_COMMENT := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_COMMENT
const SOURCE_TURRET_RECOIL_OFFSET_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_FIELD
const SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_FIELD
const SOURCE_TURRET_RECOIL_OFFSET_CUR_RECOIL_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_CUR_RECOIL_FIELD
const SOURCE_TURRET_RECOIL_OFFSET_FORMULA := source_turret_recoil_state.SOURCE_TURRET_RECOIL_OFFSET_FORMULA

const SOURCE_TURRET_SHOOT_PATTERN_FIELD := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_FIELD
const SOURCE_TURRET_SHOOT_PATTERN_KEY := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_KEY
const SOURCE_TURRET_SHOOT_PATTERN_DUO_ASSIGNMENT := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_DUO_ASSIGNMENT
const SOURCE_TURRET_SHOOT_PATTERN_SELECTION := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_SELECTION
const SOURCE_TURRET_SHOOT_PATTERN_DISPATCH := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_DISPATCH

const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_POINT_FIELD := source_turret_source_text_state.SOURCE_TURRET_BULLET_ORIGIN_SHOOT_POINT_FIELD
const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_Y_DEFAULT := source_turret_source_text_state.SOURCE_TURRET_BULLET_ORIGIN_SHOOT_Y_DEFAULT
const SOURCE_TURRET_BULLET_ORIGIN_X_SPREAD := source_turret_bullet_origin_state.SOURCE_TURRET_BULLET_ORIGIN_X_SPREAD
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_X := source_turret_bullet_origin_state.SOURCE_TURRET_BULLET_ORIGIN_BULLET_X
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y := source_turret_bullet_origin_state.SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y

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

static func reload_seconds(turret, defaults: source_turret_defaults, tick_rate: float) -> float:
	if turret == null or tick_rate == 0.0:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_RELOAD_KEY, defaults.reload_default())) / tick_rate

static func reload_seconds_for_ammo(turret, data: Dictionary, defaults: source_turret_defaults, tick_rate: float, bullet_reload_multiplier: float) -> float:
	var seconds := reload_seconds(turret, defaults, tick_rate)
	if data.is_empty():
		return seconds
	if bullet_reload_multiplier == 0.0:
		return seconds
	return seconds / bullet_reload_multiplier

static func range_value(turret, defaults: source_turret_defaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_RANGE_KEY, defaults.range_default()))

static func range_for_ammo(turret, data: Dictionary, defaults: source_turret_defaults, bullet_range_change: float) -> float:
	if data.is_empty():
		return range_value(turret, defaults)
	return range_value(turret, defaults) + bullet_range_change

static func shoot_y(turret, defaults: source_turret_defaults, source_tilesize: float) -> float:
	if turret == null:
		return 0.0
	var properties := _properties(turret)
	var source_default := defaults.shoot_y_default(float(properties.get("size", 0.0)), source_tilesize)
	return float(properties.get(SOURCE_TURRET_SHOOT_Y_KEY, source_default))

static func inaccuracy(turret, defaults: source_turret_defaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_INACCURACY_KEY, defaults.inaccuracy_default()))

static func total_inaccuracy(turret, defaults: source_turret_defaults, bullet_inaccuracy: float) -> float:
	return inaccuracy(turret, defaults) + bullet_inaccuracy

static func rotate_speed(turret, defaults: source_turret_defaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_ROTATE_SPEED_KEY, defaults.rotate_speed_default()))

static func shoot_cone(turret, defaults: source_turret_defaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_SHOOT_CONE_KEY, defaults.shoot_cone_default()))

static func recoil(turret, defaults: source_turret_defaults) -> float:
	if turret == null:
		return 0.0
	return float(_properties(turret).get(SOURCE_TURRET_RECOIL_KEY, defaults.recoil_default()))

static func recoils(turret, defaults: source_turret_defaults) -> int:
	if turret == null:
		return 0
	return int(_properties(turret).get(SOURCE_TURRET_RECOILS_KEY, defaults.recoils_default()))

static func recoil_time(turret, defaults: source_turret_defaults, reload_seconds_value: float, tick_rate: float) -> float:
	if turret == null:
		return 1.0
	var recoil_time_value := float(_properties(turret).get(SOURCE_TURRET_RECOIL_TIME_KEY, defaults.recoil_time_default()))
	if recoil_time_value < 0.0:
		return reload_seconds_value * tick_rate
	return recoil_time_value

static func recoil_offset(turret, defaults: source_turret_defaults, recoil_rotation_degrees: float, cur_recoil: float) -> Vector2:
	return Vector2.RIGHT.rotated(deg_to_rad(recoil_rotation_degrees)) * (-pow(cur_recoil, defaults.recoil_pow()) * recoil(turret, defaults))

static func bullet_origin(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, defaults: source_turret_defaults, source_tilesize: float, shoot_x_offset := 0.0, y_offset := 0.0, x_spread := 0.0) -> Dictionary:
	var properties := _properties(turret)
	var shoot_x := float(properties.get("shootX", 0.0))
	var shoot_y_value := shoot_y(turret, defaults, source_tilesize)
	var rotation_minus_90 := turret_rotation_degrees - source_turret_defaults.BULLET_ORIGIN_ROTATION_OFFSET_DEGREES
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
