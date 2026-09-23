extends RefCounted
class_name SourceTurretBulletOriginState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_POINT_FIELD := source_turret_source_text_state.SOURCE_TURRET_BULLET_ORIGIN_SHOOT_POINT_FIELD
const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_Y_DEFAULT := source_turret_source_text_state.SOURCE_TURRET_BULLET_ORIGIN_SHOOT_Y_DEFAULT
const SOURCE_TURRET_BULLET_ORIGIN_X_SPREAD := source_turret_source_text_state.SOURCE_TURRET_BULLET_ORIGIN_X_SPREAD
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_X := source_turret_source_text_state.SOURCE_TURRET_BULLET_ORIGIN_BULLET_X
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y := source_turret_source_text_state.SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y
const SOURCE_TURRET_BULLET_ORIGIN_ROTATION_OFFSET_DEGREES := source_turret_defaults.BULLET_ORIGIN_ROTATION_OFFSET_DEGREES
const SOURCE_TURRET_SHOOT_X_DEFAULT := source_turret_defaults.SHOOT_X_DEFAULT

static func _read_turret_properties(turret) -> Dictionary:
	if turret == null:
		return {}
	if turret is Dictionary:
		var properties = turret.get("properties", turret)
		return properties if properties is Dictionary else {}
	var property_value = turret.get("properties") if turret is Object else null
	return property_value if property_value is Dictionary else {}

static func bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret_property_map: Dictionary, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	var shoot_x := float(turret_property_map.get("shootX", shoot_x_default))
	var shoot_y := float(turret_property_map.get("shootY", float(turret_property_map.get("size", block_size_default)) * tilesize / 2.0))
	var rotation_minus_90 := turret_rotation_degrees - SOURCE_TURRET_BULLET_ORIGIN_ROTATION_OFFSET_DEGREES
	var trns: Dictionary = trns_vec.call(rotation_minus_90, shoot_x + shoot_x_offset + x_spread, shoot_y + y_offset)
	var trnsx := float(trns.get("x", 0.0))
	var trnsy := float(trns.get("y", 0.0))
	return {
		"originX": origin_x,
		"originY": origin_y,
		"rotationDegrees": turret_rotation_degrees,
		"rotationMinus90": rotation_minus_90,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"shootXOffset": shoot_x_offset,
		"yOffset": y_offset,
		"xSpread": x_spread,
		"trnsx": trnsx,
		"trnsy": trnsy,
		"bulletX": origin_x + trnsx,
		"bulletY": origin_y + trnsy,
		"bulletXSource": SOURCE_TURRET_BULLET_ORIGIN_BULLET_X,
		"bulletYSource": SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y,
	}

static func turret_bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	var turret_property_map := _read_turret_properties(turret)
	return bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret_property_map, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func game_turret_bullet_origin_state(_game: Object, origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float, trns_vec: Callable) -> Dictionary:
	return turret_bullet_origin_state(
		origin_x,
		origin_y,
		turret_rotation_degrees,
		turret,
		shoot_x_offset,
		y_offset,
		x_spread,
		SOURCE_TURRET_SHOOT_X_DEFAULT,
		source_block_defaults.SIZE_DEFAULT,
		int(source_world_defaults.TILESIZE),
		trns_vec
	)
