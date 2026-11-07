extends RefCounted
class_name SourceUnitMotionState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")
const source_unit_update_callback_registry := preload("res://src/game/SourceUnitUpdateCallbackRegistry.gd")

const SOURCE_UNIT_GROUNDED_EPSILON := source_unit_defaults.GROUNDED_EPSILON
const SOURCE_UNIT_WOBBLE_SIN_SCL := source_unit_defaults.WOBBLE_SIN_SCL
const SOURCE_UNIT_WOBBLE_MAG := source_unit_defaults.WOBBLE_MAG
const SOURCE_UNIT_FLYING_ELEVATION_MIN := source_unit_defaults.FLYING_ELEVATION_MIN
const SOURCE_UNIT_IS_GROUNDED_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_IS_GROUNDED_METHOD
const SOURCE_UNIT_IS_GROUNDED_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_IS_GROUNDED_RETURN
const SOURCE_UNIT_IS_FLYING_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_METHOD
const SOURCE_UNIT_IS_FLYING_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_RETURN
const SOURCE_UNIT_CHECK_TARGET_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_METHOD
const SOURCE_UNIT_CHECK_TARGET_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_RETURN
const SOURCE_UNIT_CHECK_TARGET_IS_GROUNDED_CALL := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_IS_GROUNDED_CALL
const SOURCE_UNIT_CHECK_TARGET_IS_FLYING_CALL := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_IS_FLYING_CALL
const SOURCE_UNIT_CAN_DROWN_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_METHOD
const SOURCE_UNIT_CAN_DROWN_IS_GROUNDED_CALL := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_IS_GROUNDED_CALL
const SOURCE_UNIT_CAN_DROWN_TYPE_CAN_DROWN := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_TYPE_CAN_DROWN
const SOURCE_UNIT_CAN_DROWN_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_RETURN
const SOURCE_UNIT_DROWN_FLOOR_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_METHOD
const SOURCE_UNIT_DROWN_FLOOR_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_RETURN
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_METHOD
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_TILE := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_TILE
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_RETURN
const SOURCE_UNIT_DROWN_FLOOR_TILE_ON_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_TILE_ON_METHOD
const SOURCE_UNIT_DROWN_FLOOR_TILE_ON_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_TILE_ON_RETURN
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_CLASS := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_CLASS
const SOURCE_UNIT_MOVE_AT_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_METHOD
const SOURCE_UNIT_MOVE_AT_TARGET_SET := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_TARGET_SET
const SOURCE_UNIT_MOVE_AT_DELTA_LIMIT := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DELTA_LIMIT
const SOURCE_UNIT_MOVE_AT_VEL_ADD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_VEL_ADD
const SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_METHOD
const SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_CALL := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_CALL
const SOURCE_UNIT_APPROACH_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_METHOD
const SOURCE_UNIT_APPROACH_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_CALL
const SOURCE_UNIT_APPROACH_VEC2_APPROACH_DELTA_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_APPROACH_DELTA_CALL
const SOURCE_UNIT_APPROACH_VEC2_APPROACH_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_APPROACH_METHOD
const SOURCE_UNIT_APPROACH_VEC2_DX_DY := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_DX_DY
const SOURCE_UNIT_APPROACH_VEC2_ALPHA2 := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_ALPHA2
const SOURCE_UNIT_APPROACH_VEC2_LEN2 := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_LEN2
const SOURCE_UNIT_APPROACH_VEC2_SCL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_SCL
const SOURCE_UNIT_APPROACH_VEC2_SUB_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_SUB_CALL
const SOURCE_UNIT_APPROACH_VEC2_SET_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_SET_CALL
const SOURCE_UNIT_ROTATE_MOVE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_METHOD
const SOURCE_UNIT_ROTATE_MOVE_MOTION_CALL := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_MOTION_CALL
const SOURCE_UNIT_ROTATE_MOVE_VEC2_TRNS_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_VEC2_TRNS_RETURN
const SOURCE_UNIT_ROTATE_MOVE_ROTATION_GATE := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_ROTATION_GATE
const SOURCE_UNIT_ROTATE_MOVE_ROTATION_ASSIGNMENT := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_ROTATION_ASSIGNMENT
const SOURCE_UNIT_ROTATE_MOVE_VEC2_IS_ZERO := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_VEC2_IS_ZERO
const SOURCE_UNIT_ROTATE_MOVE_VEC2_ANGLE := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_VEC2_ANGLE
const SOURCE_UNIT_MOVE_PREF_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_METHOD
const SOURCE_UNIT_MOVE_PREF_OMNI_GATE := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_OMNI_GATE
const SOURCE_UNIT_MOVE_PREF_MOVE_AT_CALL := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_MOVE_AT_CALL
const SOURCE_UNIT_MOVE_PREF_ROTATE_MOVE_CALL := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_ROTATE_MOVE_CALL
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_METHOD
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_CHOICE := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_CHOICE
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_RETURN
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_HOVERING := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_HOVERING
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_FLOOR_MULTIPLIER := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_FLOOR_MULTIPLIER
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED_DEFAULT := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED_DEFAULT
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_BLOCK_AS_FLOOR := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_BLOCK_AS_FLOOR
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_SPEED_MULTIPLIER := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_SPEED_MULTIPLIER
const SOURCE_UNIT_AIM_LOOK_POSITION_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_METHOD
const SOURCE_UNIT_AIM_LOOK_POSITION_POS_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_POS_ARG
const SOURCE_UNIT_AIM_LOOK_POSITION_AIM_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_AIM_CALL
const SOURCE_UNIT_AIM_LOOK_POSITION_LOOK_AT_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_LOOK_AT_CALL
const SOURCE_UNIT_AIM_LOOK_XY_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_METHOD
const SOURCE_UNIT_AIM_LOOK_XY_X_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_X_ARG
const SOURCE_UNIT_AIM_LOOK_XY_Y_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_Y_ARG
const SOURCE_UNIT_AIM_LOOK_XY_AIM_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_AIM_CALL
const SOURCE_UNIT_AIM_LOOK_XY_LOOK_AT_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_LOOK_AT_CALL
const SOURCE_UNIT_LOOK_AT_ANGLE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_METHOD
const SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION := source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION
const SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION_SPEED := source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION_SPEED

const SOURCE_UNIT_UPDATE_SIN_SCALED_KEY := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_SIN_SCALED_KEY
const SOURCE_UNIT_UPDATE_SIN_SCALED_FALLBACK := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_SIN_SCALED_FALLBACK
const SOURCE_UNIT_UPDATE_COS_SCALED_KEY := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_COS_SCALED_KEY
const SOURCE_UNIT_UPDATE_COS_SCALED_FALLBACK := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_COS_SCALED_FALLBACK
const SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY
const SOURCE_UNIT_UPDATE_VEC2_LIMIT_FALLBACK := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_VEC2_LIMIT_FALLBACK
const SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY
const SOURCE_UNIT_UPDATE_VEC2_ANGLE_FALLBACK := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_VEC2_ANGLE_FALLBACK
const SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY
const SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_FALLBACK := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_FALLBACK
const SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY
const SOURCE_UNIT_UPDATE_ANGLES_ANGLE_FALLBACK := source_unit_update_callback_registry.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_unit_update_method_names"):
		var names = game.call("_unit_update_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_UNIT_UPDATE_SIN_SCALED_KEY: Callable(game, runtime_method_name(method_names, SOURCE_UNIT_UPDATE_SIN_SCALED_KEY, SOURCE_UNIT_UPDATE_SIN_SCALED_FALLBACK)),
		SOURCE_UNIT_UPDATE_COS_SCALED_KEY: Callable(game, runtime_method_name(method_names, SOURCE_UNIT_UPDATE_COS_SCALED_KEY, SOURCE_UNIT_UPDATE_COS_SCALED_FALLBACK)),
		SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY: Callable(game, runtime_method_name(method_names, SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY, SOURCE_UNIT_UPDATE_VEC2_LIMIT_FALLBACK)),
		SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY, SOURCE_UNIT_UPDATE_VEC2_ANGLE_FALLBACK)),
		SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY: Callable(game, runtime_method_name(method_names, SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_FALLBACK)),
		SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY, SOURCE_UNIT_UPDATE_ANGLES_ANGLE_FALLBACK)),
	}

static func game_wobble_state(game: Object, current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return wobble_state(current_x, current_y, source_time, source_delta, elevation_value, unit_id, callbacks.get(SOURCE_UNIT_UPDATE_SIN_SCALED_KEY, Callable()), callbacks.get(SOURCE_UNIT_UPDATE_COS_SCALED_KEY, Callable()))

static func game_move_at_state(game: Object, vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return move_at_state(vel_x, vel_y, vector_x, vector_y, acceleration, source_delta, callbacks.get(SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY, Callable()))

static func game_rotate_move_motion_state(_game: Object, unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	return rotate_move_motion_state(unit_rotation_degrees, vec_x, vec_y)

static func game_rotate_move_rotation_state(game: Object, current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return rotate_move_rotation_state(current_rotation, vec_x, vec_y, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get(SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY, Callable()), callbacks.get(SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))

static func game_look_at_angle_state(game: Object, current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get(SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))

static func game_look_at_position_state(game: Object, current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return look_at_position_state(current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get(SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY, Callable()), callbacks.get(SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))

static func game_look_at_xy_state(game: Object, current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return look_at_xy_state(current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get(SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY, Callable()), callbacks.get(SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))

static func is_grounded(elevation_value: float) -> bool:
	return elevation_value < SOURCE_UNIT_GROUNDED_EPSILON

static func is_flying(elevation_value: float) -> bool:
	return elevation_value >= SOURCE_UNIT_FLYING_ELEVATION_MIN

static func check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	var grounded: bool = is_grounded(elevation_value)
	var flying: bool = is_flying(elevation_value)
	return {
		"grounded": grounded,
		"flying": flying,
		"targetable": (grounded and target_ground) or (flying and target_air),
	}

static func can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:
	var grounded: bool = is_grounded(elevation_value)
	return {
		"grounded": grounded,
		"can_drown": grounded and type_can_drown,
	}

static func drown_floor_state(floor_on_value: Variant) -> Variant:
	return floor_on_value

static func wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int, sin_scaled: Callable, cos_scaled: Callable) -> Dictionary:
	var wobble_input := source_time + float(unit_id % 10) * 12.0
	var dx := float(sin_scaled.call(wobble_input, SOURCE_UNIT_WOBBLE_SIN_SCL, SOURCE_UNIT_WOBBLE_MAG)) * source_delta * elevation_value
	var dy := float(cos_scaled.call(wobble_input, SOURCE_UNIT_WOBBLE_SIN_SCL, SOURCE_UNIT_WOBBLE_MAG)) * source_delta * elevation_value
	return {
		"x": current_x + dx,
		"y": current_y + dy,
		"dx": dx,
		"dy": dy,
		"wobble_input": wobble_input,
	}

static func move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float, vec2_limit: Callable) -> Dictionary:
	var vel := Vector2(vel_x, vel_y)
	var target := Vector2(vector_x, vector_y)
	var delta: Vector2 = vec2_limit.call(target - vel, acceleration * target.length() * source_delta)
	var next_vel := vel + delta
	return {
		"method": SOURCE_UNIT_MOVE_AT_METHOD,
		"targetSet": SOURCE_UNIT_MOVE_AT_TARGET_SET,
		"deltaLimit": SOURCE_UNIT_MOVE_AT_DELTA_LIMIT,
		"velAdd": SOURCE_UNIT_MOVE_AT_VEL_ADD,
		"vel_x": next_vel.x,
		"vel_y": next_vel.y,
		"delta_x": delta.x,
		"delta_y": delta.y,
		"target_x": target.x,
		"target_y": target.y,
		"limit": acceleration * target.length() * source_delta,
	}

static func move_at_default_accel_state(vector_x: float, vector_y: float, type_accel: float) -> Dictionary:
	return {
		"method": SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_METHOD,
		"source": SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_CALL,
		"vector": {"x": vector_x, "y": vector_y},
		"acceleration": type_accel,
		"call": "moveAt",
	}

static func approach_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, type_accel: float, speed_value: float, source_delta: float) -> Dictionary:
	var vel := Vector2(vel_x, vel_y)
	var target := Vector2(vector_x, vector_y)
	var alpha := source_delta * type_accel * speed_value
	var diff := vel - target
	var alpha2 := alpha * alpha
	var len2 := diff.length_squared()
	var next_vel := Vector2.ZERO
	if len2 > alpha2:
		var scl := sqrt(alpha2 / len2)
		next_vel = vel - diff * scl
	else:
		next_vel = target
	return {
		"alpha": alpha,
		"vel_x": next_vel.x,
		"vel_y": next_vel.y,
		"target_x": target.x,
		"target_y": target.y,
	}

static func rotate_move_motion_state(unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	var amount := Vector2(vec_x, vec_y).length()
	var movement_state := source_math_state.source_angles_trns_vec(unit_rotation_degrees, amount, 0.0)
	var movement := Vector2(float(movement_state.get("x", 0.0)), float(movement_state.get("y", 0.0)))
	return {
		"method": SOURCE_UNIT_ROTATE_MOVE_METHOD,
		"moveAtCall": SOURCE_UNIT_ROTATE_MOVE_MOTION_CALL,
		"vec2Trns": SOURCE_UNIT_ROTATE_MOVE_VEC2_TRNS_RETURN,
		"call": "moveAt",
		"movement": {"x": movement.x, "y": movement.y},
		"amount": amount,
	}

static func rotate_move_rotation_state(current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, vec2_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	var vector_is_zero := vec_x == 0.0 and vec_y == 0.0
	var target_rotation := float(vec2_angle.call(vec_x, vec_y)) if not vector_is_zero else current_rotation
	var next_rotation := current_rotation
	if not vector_is_zero:
		next_rotation = float(angles_move_toward.call(current_rotation, target_rotation, type_rotate_speed * source_delta * speed_multiplier_value))
	return {
		"gate": SOURCE_UNIT_ROTATE_MOVE_ROTATION_GATE,
		"rotationAssignment": SOURCE_UNIT_ROTATE_MOVE_ROTATION_ASSIGNMENT,
		"vec2IsZero": SOURCE_UNIT_ROTATE_MOVE_VEC2_IS_ZERO,
		"vec2Angle": SOURCE_UNIT_ROTATE_MOVE_VEC2_ANGLE,
		"vector_is_zero": vector_is_zero,
		"target_rotation": target_rotation,
		"rotation": next_rotation,
	}

static func aim_look_position_state(pos_x: float, pos_y: float) -> Dictionary:
	return {
		"target": {"x": pos_x, "y": pos_y},
		"aim_call": "aim(Position)",
		"look_at_call": "lookAt(Position)",
		"call_order": ["aim", "lookAt"],
	}

static func aim_look_xy_state(target_x: float, target_y: float) -> Dictionary:
	return {
		"target": {"x": target_x, "y": target_y},
		"aim_call": "aim(float, float)",
		"look_at_call": "lookAt(float, float)",
		"call_order": ["aim", "lookAt"],
	}

static func look_at_angle_state(current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_move_toward: Callable) -> Dictionary:
	var rotation_speed := type_rotate_speed * source_delta * speed_multiplier_value
	var next_rotation := float(angles_move_toward.call(current_rotation, target_angle, rotation_speed))
	return {
		"method": SOURCE_UNIT_LOOK_AT_ANGLE_METHOD,
		"source": SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION,
		"target_angle": target_angle,
		"rotation_speed": rotation_speed,
		"rotation": next_rotation,
	}

static func look_at_position_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	var target_angle := float(angles_angle.call(unit_x, unit_y, target_x, target_y))
	var angle_state := look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta, angles_move_toward)
	return {
		"call": "lookAt(angleTo(pos))",
		"target": {"x": target_x, "y": target_y},
		"target_angle": angle_state["target_angle"],
		"rotation_speed": angle_state["rotation_speed"],
		"rotation": angle_state["rotation"],
	}

static func look_at_xy_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	var target_angle := float(angles_angle.call(unit_x, unit_y, target_x, target_y))
	var angle_state := look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta, angles_move_toward)
	return {
		"call": "lookAt(angleTo(x, y))",
		"target": {"x": target_x, "y": target_y},
		"target_angle": angle_state["target_angle"],
		"rotation_speed": angle_state["rotation_speed"],
		"rotation": angle_state["rotation"],
	}

static func move_pref_state(type_omni_movement: bool, movement_x: float, movement_y: float) -> Dictionary:
	return {
		"method": SOURCE_UNIT_MOVE_PREF_METHOD,
		"omniGate": SOURCE_UNIT_MOVE_PREF_OMNI_GATE,
		"moveAtCall": SOURCE_UNIT_MOVE_PREF_MOVE_AT_CALL,
		"rotateMoveCall": SOURCE_UNIT_MOVE_PREF_ROTATE_MOVE_CALL,
		"movement": {"x": movement_x, "y": movement_y},
		"call": "moveAt" if type_omni_movement else "rotateMove",
	}

static func floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:
	var flying: bool = is_flying(elevation_value)
	var uses_air_floor: bool = flying or type_hovering
	var on_speed_multiplier: float = 1.0 if uses_air_floor else floor_on_speed_multiplier
	var result: float = pow(on_speed_multiplier, type_floor_multiplier) * speed_multiplier_value
	return {
		"flying": flying,
		"uses_air_floor": uses_air_floor,
		"on_speed_multiplier": on_speed_multiplier,
		"speed_multiplier": result,
	}
