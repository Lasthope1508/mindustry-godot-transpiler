extends RefCounted
class_name SourceTurretPropertyState

const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

const SOURCE_TURRET_RELOAD_FIELD := source_turret_source_text_state.SOURCE_TURRET_RELOAD_FIELD
const SOURCE_TURRET_RELOAD_KEY := source_turret_source_text_state.SOURCE_TURRET_RELOAD_KEY
const SOURCE_TURRET_RELOAD_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_RELOAD_DUO_VALUE
const SOURCE_TIME_TO_SECONDS_FIELD := source_time_defaults.SOURCE_TIME_TO_SECONDS_FIELD

const SOURCE_TURRET_RANGE_FIELD := source_turret_source_text_state.SOURCE_TURRET_RANGE_FIELD
const SOURCE_TURRET_RANGE_METHOD := source_turret_source_text_state.SOURCE_TURRET_RANGE_METHOD
const SOURCE_TURRET_RANGE_KEY := source_turret_source_text_state.SOURCE_TURRET_RANGE_KEY
const SOURCE_TURRET_RANGE_DUO_VALUE := source_turret_source_text_state.SOURCE_TURRET_RANGE_DUO_VALUE

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

const SOURCE_TURRET_RECOIL_OFFSET_COMMENT := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_COMMENT
const SOURCE_TURRET_RECOIL_OFFSET_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_FIELD
const SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_FIELD
const SOURCE_TURRET_RECOIL_OFFSET_CUR_RECOIL_FIELD := source_turret_source_text_state.SOURCE_TURRET_RECOIL_OFFSET_CUR_RECOIL_FIELD

const SOURCE_TURRET_SHOOT_PATTERN_FIELD := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_FIELD
const SOURCE_TURRET_SHOOT_PATTERN_KEY := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_KEY
const SOURCE_TURRET_SHOOT_PATTERN_DUO_ASSIGNMENT := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_DUO_ASSIGNMENT
const SOURCE_TURRET_SHOOT_PATTERN_SELECTION := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_SELECTION
const SOURCE_TURRET_SHOOT_PATTERN_DISPATCH := source_turret_source_text_state.SOURCE_TURRET_SHOOT_PATTERN_DISPATCH

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
