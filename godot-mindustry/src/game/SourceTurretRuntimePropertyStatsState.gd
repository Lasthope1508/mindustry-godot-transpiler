extends RefCounted
class_name SourceTurretRuntimePropertyStatsState

const source_turret_selected_ammo_runtime_state := preload("res://src/game/SourceTurretSelectedAmmoRuntimeState.gd")
const source_turret_property_state := preload("res://src/game/SourceTurretPropertyState.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_UPDATE_RELOAD := source_turret_source_text_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_UPDATE_RELOAD
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN := source_turret_source_text_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA := source_turret_source_text_state.SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA
const SOURCE_TURRET_UPDATE_SHOOTING_METHOD := source_turret_source_text_state.SOURCE_TURRET_UPDATE_SHOOTING_METHOD
const SOURCE_TURRET_RANGE_FOR_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_RANGE_FOR_AMMO_METHOD
const SOURCE_TURRET_RANGE_FOR_AMMO_GATE := source_turret_source_text_state.SOURCE_TURRET_RANGE_FOR_AMMO_GATE
const SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT := source_turret_source_text_state.SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT
const SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT := source_turret_source_text_state.SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT
const SOURCE_TURRET_SELECTED_RELOAD_SECONDS_METHOD := "source_turret_reload_seconds"
const SOURCE_TURRET_SELECTED_RANGE_METHOD := "source_turret_range"
const SOURCE_TURRET_SELECTED_SHOOT_Y_METHOD := "source_turret_shoot_y"
const SOURCE_TURRET_SELECTED_SHOOT_PATTERN_METHOD := "source_turret_shoot_pattern"
const SOURCE_TURRET_SELECTED_INACCURACY_METHOD := "source_turret_inaccuracy"
const SOURCE_TURRET_SELECTED_ROTATE_SPEED_METHOD := "source_turret_rotate_speed"
const SOURCE_TURRET_SELECTED_SHOOT_CONE_METHOD := "source_turret_shoot_cone"
const SOURCE_TURRET_SELECTED_RECOIL_METHOD := "source_turret_recoil"
const SOURCE_TURRET_SELECTED_RECOILS_METHOD := "source_turret_recoils"

static func read_turret_properties(turret) -> Dictionary:
	return source_turret_selected_ammo_runtime_state.read_turret_properties(turret)

static func turret_reload_seconds(turret, reload_key: String, reload_default: float, tick_rate: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var reload_state := source_turret_property_state.reload_seconds_state(turret_property_map, reload_key, reload_default, tick_rate)
	return float(reload_state.get("reload_seconds", 0.0))

static func turret_reload_seconds_for_ammo(base_reload_seconds: float, data: Dictionary, reload_multiplier: float) -> float:
	if data.is_empty():
		return base_reload_seconds
	return base_reload_seconds / reload_multiplier

static func turret_range(turret, range_key: String, range_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var range_state := source_turret_property_state.range_state(turret_property_map, range_key, range_default)
	return float(range_state.get("range", 0.0))

static func turret_range_for_ammo(base_range: float, data: Dictionary, range_change: float) -> float:
	if data.is_empty():
		return base_range
	return base_range + range_change

static func turret_shoot_y(turret, shoot_y_key: String, shoot_y_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var shoot_y_state := source_turret_property_state.shoot_y_state(turret_property_map, shoot_y_key, shoot_y_default)
	return float(shoot_y_state.get("shoot_y", 0.0))

static func turret_inaccuracy(turret, inaccuracy_key: String, inaccuracy_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var inaccuracy_state := source_turret_property_state.inaccuracy_state(turret_property_map, inaccuracy_key, inaccuracy_default)
	return float(inaccuracy_state.get("inaccuracy", 0.0))

static func turret_rotate_speed(turret, rotate_speed_key: String, rotate_speed_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var rotate_speed_state := source_turret_property_state.rotate_speed_state(turret_property_map, rotate_speed_key, rotate_speed_default)
	return float(rotate_speed_state.get("rotate_speed", 0.0))

static func turret_shoot_cone(turret, shoot_cone_key: String, shoot_cone_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var shoot_cone_state := source_turret_property_state.shoot_cone_state(turret_property_map, shoot_cone_key, shoot_cone_default)
	return float(shoot_cone_state.get("shoot_cone", 0.0))

static func turret_recoil(turret, recoil_key: String, recoil_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var recoil_state := source_turret_property_state.recoil_state(turret_property_map, recoil_key, recoil_default)
	return float(recoil_state.get("recoil", 0.0))

static func turret_recoils(turret, recoils_key: String, recoils_default: int) -> int:
	if turret == null:
		return 0
	var turret_property_map := read_turret_properties(turret)
	var recoils_state := source_turret_property_state.recoils_state(turret_property_map, recoils_key, recoils_default)
	return int(recoils_state.get("recoils", 0))

static func turret_recoil_time(turret, recoil_time_key: String, recoil_time_default: float, reload_key: String, reload_default: float, tick_rate: float) -> float:
	if turret == null:
		return 1.0
	var turret_property_map := read_turret_properties(turret)
	var reload_seconds := turret_reload_seconds(turret, reload_key, reload_default, tick_rate)
	var recoil_time_state := source_turret_property_state.recoil_time_state(turret_property_map, recoil_time_key, recoil_time_default, reload_seconds, tick_rate)
	return float(recoil_time_state.get("recoil_time", 1.0))

static func turret_shoot_pattern(turret, shoot_pattern_key: String) -> Dictionary:
	if turret == null:
		return {}
	var turret_property_map := read_turret_properties(turret)
	var shoot_pattern_state := source_turret_property_state.shoot_pattern_state(turret_property_map, shoot_pattern_key)
	return shoot_pattern_state.get("shoot_pattern", {})

static func selected_turret_float_stat(game: Object, source_method: String) -> float:
	var turret = game.call("selected_playable_turret")
	if turret == null:
		return 0.0
	return float(game.call(source_method, turret))

static func selected_turret_dict_stat(game: Object, source_method: String) -> Dictionary:
	var turret = game.call("selected_playable_turret")
	if turret == null:
		return {}
	var stat = game.call(source_method, turret)
	return stat if stat is Dictionary else {}

static func selected_turret_int_stat(game: Object, source_method: String) -> int:
	var turret = game.call("selected_playable_turret")
	if turret == null:
		return 0
	return int(game.call(source_method, turret))
