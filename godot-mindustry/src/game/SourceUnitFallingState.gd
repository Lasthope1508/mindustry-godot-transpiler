extends RefCounted
class_name SourceUnitFallingState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")

const SOURCE_UNIT_FALLING_DRAG_MIN := source_unit_defaults.FALLING_DRAG_MIN
const SOURCE_UNIT_FALL_SMOKE_CHANCE := source_unit_defaults.FALL_SMOKE_CHANCE
const SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR := source_unit_defaults.FALL_ENGINE_OFFSET_DIVISOR
const SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET := source_unit_defaults.FALL_ENGINE_ROTATION_OFFSET
const SOURCE_UNIT_FALL_ENGINE_TRAIL_CHANCE := source_unit_defaults.FALL_ENGINE_TRAIL_CHANCE

static func falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	var guard := dead_value or health_value <= 0.0
	var next_drag := SOURCE_UNIT_FALLING_DRAG_MIN if guard else current_drag
	return {
		"guard": guard,
		"drag": next_drag,
		"call": "drag = 0.01f" if guard else "",
		"source": "if(dead || health <= 0){",
	}

static func falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var effect_call: Variant = null
	if falling_guard and chance_delta_result:
		effect_call = {
			"call": "type.fallEffect.at(x + Tmp.v1.x, y + Tmp.v1.y)",
			"x": unit_x + tmp_v1_x,
			"y": unit_y + tmp_v1_y,
			"tmp": {"call": "Tmp.v1.rnd(Mathf.range(hitSize))", "x": tmp_v1_x, "y": tmp_v1_y},
			"range": {"call": "Mathf.range(hitSize)", "hitSize": hit_size},
		}
	return {
		"fallingGuard": falling_guard,
		"chance": {"call": "Mathf.chanceDelta(0.1)", "result": chance_delta_result, "chanceValue": SOURCE_UNIT_FALL_SMOKE_CHANCE},
		"effect": effect_call,
	}

static func falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var offset := type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR + type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR * elevation_value
	var angle := source_rotation_degrees + SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET
	var effect_call: Variant = null
	if falling_guard and chance_delta_result:
		var position_state := source_math_state.source_angles_trns_vec(angle, offset, 0.0)
		effect_call = {
			"call": "type.fallEngineEffect.at(x + Angles.trnsx(rotation + 180, offset) + Mathf.range(range), y + Angles.trnsy(rotation + 180, offset) + Mathf.range(range), Mathf.random())",
			"x": unit_x + float(position_state.get("x", 0.0)) + x_range_value,
			"y": unit_y + float(position_state.get("y", 0.0)) + y_range_value,
			"rotation": random_rotation_value,
			"range": {"call": "Mathf.range(type.engineSize)", "value": engine_range_value, "type.engineSize": type_engine_size},
			"xRange": {"call": "Mathf.range(range)", "value": x_range_value},
			"yRange": {"call": "Mathf.range(range)", "value": y_range_value},
			"offset": offset,
		}
	return {
		"fallingGuard": falling_guard,
		"chance": {"call": "Mathf.chanceDelta(0.2)", "result": chance_delta_result, "chanceValue": SOURCE_UNIT_FALL_ENGINE_TRAIL_CHANCE},
		"angle": angle,
		"offset": offset,
		"effect": effect_call,
	}

static func falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	var falling_guard := dead_value or health_value <= 0.0
	var next_elevation := elevation_value
	if falling_guard:
		next_elevation -= type_fall_speed * source_delta
	var wreck_health_threshold := -max_health * type_wreck_health_multiplier
	var destroy_call: Variant = null
	if falling_guard and (is_grounded_value or health_value <= wreck_health_threshold):
		destroy_call = {
			"call": "Call.unitDestroy(id)",
			"id": unit_id,
		}
	return {
		"fallingGuard": falling_guard,
		"elevationBefore": elevation_value,
		"elevation": next_elevation,
		"descent": {"call": "elevation -= type.fallSpeed * Time.delta", "type.fallSpeed": type_fall_speed, "Time.delta": source_delta},
		"grounded": is_grounded_value,
		"wreckHealthThreshold": wreck_health_threshold,
		"destroy": destroy_call,
	}
