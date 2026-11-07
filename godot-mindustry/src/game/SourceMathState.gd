class_name SourceMathState
extends RefCounted

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_source_text_state := preload("res://src/game/SourceMathSourceTextState.gd")

const SOURCE_PI2 := source_math_defaults.PI2
const SOURCE_ARC_PI := source_math_defaults.ARC_PI
const SOURCE_ARC_SIN_BITS := source_math_defaults.ARC_SIN_BITS
const SOURCE_ARC_SIN_MASK := source_math_defaults.ARC_SIN_MASK
const SOURCE_ARC_SIN_COUNT := source_math_defaults.ARC_SIN_COUNT
const SOURCE_ARC_RAD_TO_INDEX := source_math_defaults.ARC_RAD_TO_INDEX
const SOURCE_INT64_MIN := source_math_defaults.INT64_MIN
const SOURCE_INT64_MAX := source_math_defaults.INT64_MAX
const SOURCE_UINT16_MASK := source_math_defaults.UINT16_MASK
const SOURCE_RAND_NORM_FLOAT := source_math_defaults.RAND_NORM_FLOAT
const SOURCE_RAND_MURMUR_CONST1 := source_math_defaults.RAND_MURMUR_CONST1
const SOURCE_RAND_MURMUR_CONST2 := source_math_defaults.RAND_MURMUR_CONST2
const SOURCE_RAND_MURMUR_CONST1_WORDS := source_math_defaults.RAND_MURMUR_CONST1_WORDS
const SOURCE_RAND_MURMUR_CONST2_WORDS := source_math_defaults.RAND_MURMUR_CONST2_WORDS
const SOURCE_LONG_MIN_WORDS := source_math_defaults.LONG_MIN_WORDS
const SOURCE_FULL_CIRCLE_DEGREES := source_math_defaults.FULL_CIRCLE_DEGREES
const SOURCE_LERP_DELTA_METHOD := source_math_defaults.LERP_DELTA_METHOD
const SOURCE_LERP_DELTA_SCALED_PROGRESS := source_math_defaults.LERP_DELTA_SCALED_PROGRESS
const SOURCE_LERP_DELTA_CLAMP_EXPR := source_math_defaults.LERP_DELTA_CLAMP_EXPR
const SOURCE_LERP_DELTA_LERP_EXPR := source_math_defaults.LERP_DELTA_LERP_EXPR
const SOURCE_MATHF_LERP_DELTA_METHOD := source_math_defaults.LERP_DELTA_METHOD
const SOURCE_MATHF_LERP_DELTA_SCALED_PROGRESS := source_math_defaults.LERP_DELTA_SCALED_PROGRESS
const SOURCE_MATHF_LERP_DELTA_CLAMP_EXPR := source_math_defaults.LERP_DELTA_CLAMP_EXPR
const SOURCE_MATHF_LERP_DELTA_LERP_EXPR := source_math_defaults.LERP_DELTA_LERP_EXPR
const SOURCE_MATHF_APPROACH_DELTA_METHOD := source_math_source_text_state.SOURCE_MATHF_APPROACH_DELTA_METHOD
const SOURCE_MATHF_APPROACH_DELTA_APPROACH_METHOD := source_math_source_text_state.SOURCE_MATHF_APPROACH_DELTA_APPROACH_METHOD
const SOURCE_MATHF_APPROACH_DELTA_SCALED_SPEED := source_math_source_text_state.SOURCE_MATHF_APPROACH_DELTA_SCALED_SPEED
const SOURCE_MATHF_DST_METHOD := source_math_source_text_state.SOURCE_MATHF_DST_METHOD
const SOURCE_MATHF_DST_XD_EXPR := source_math_source_text_state.SOURCE_MATHF_DST_XD_EXPR
const SOURCE_MATHF_DST_YD_EXPR := source_math_source_text_state.SOURCE_MATHF_DST_YD_EXPR
const SOURCE_MATHF_DST_RETURN_EXPR := source_math_source_text_state.SOURCE_MATHF_DST_RETURN_EXPR
const SOURCE_ARC_MATHF_NUM_METHOD := source_math_source_text_state.SOURCE_ARC_MATHF_NUM_METHOD
const SOURCE_ANGLES_WITHIN_METHOD := source_math_source_text_state.SOURCE_ANGLES_WITHIN_METHOD

static func source_absin(value: float, scl: float, mag: float) -> float:
	if scl == 0.0:
		return 0.0
	return (sin(value / scl) * 0.5 + 0.5) * mag

static func source_approach(from_value: float, to_value: float, speed: float) -> float:
	return from_value + clampf(to_value - from_value, -speed, speed)

static func source_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:
	return source_approach(from_value, to_value, source_delta * speed)

static func source_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return lerpf(from_value, to_value, clampf(source_delta * progress, 0.0, 1.0))

static func source_arc_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return source_lerp_delta(from_value, to_value, progress, source_delta)

static func is_power_of_two(value: int) -> bool:
	return value != 0 and (value & (value - 1)) == 0

static func random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:
	if max_value < min_value:
		var tmp := min_value
		min_value = max_value
		max_value = tmp
	var rand_state := _source_arc_rand_set_seed(source_seed * 99999)
	if is_power_of_two(max_value):
		return (_source_arc_rand_next_int_unbounded(rand_state) & max_value) + min_value
	return _source_arc_rand_next_int_bound(rand_state, max_value - min_value + 1) + min_value

static func random_seed_float_max(source_seed: int, max_value: float) -> float:
	var rand_state := _source_arc_rand_set_seed(source_seed * 99999)
	return _source_arc_rand_next_float(rand_state) * max_value

static func source_arc_chance_delta_threshold(chance: float, source_delta: float) -> float:
	return chance * source_delta

static func source_arc_mathf_sin_table_value(index: int) -> float:
	index = index & SOURCE_ARC_SIN_MASK
	return sin((float(index) + 0.5) / float(SOURCE_ARC_SIN_COUNT) * source_math_defaults.ARC_RAD_FULL)

static func source_arc_mathf_sin_lookup(radians: float) -> float:
	var index := int(radians * SOURCE_ARC_RAD_TO_INDEX) & SOURCE_ARC_SIN_MASK
	return source_arc_mathf_sin_table_value(index)

static func source_arc_mathf_cos_lookup(radians: float) -> float:
	return source_arc_mathf_sin_lookup(radians + SOURCE_ARC_PI / 2.0)

static func source_arc_mathf_sin_scaled(radians: float, scl: float, mag: float) -> float:
	return source_arc_mathf_sin_lookup(radians / scl) * mag

static func source_arc_mathf_cos_scaled(radians: float, scl: float, mag: float) -> float:
	return source_arc_mathf_cos_lookup(radians / scl) * mag

static func source_mod_float(value: float, divisor: float) -> float:
	if divisor == 0.0:
		return 0.0
	return fposmod(value, divisor)

static func source_angles_forward_distance(angle1: float, angle2: float) -> float:
	return abs(angle1 - angle2)

static func source_angles_backward_distance(angle1: float, angle2: float) -> float:
	return SOURCE_FULL_CIRCLE_DEGREES - abs(angle1 - angle2)

static func source_angles_angle_dist(angle_a: float, angle_b: float) -> float:
	angle_a = source_mod_float(angle_a, SOURCE_FULL_CIRCLE_DEGREES)
	angle_b = source_mod_float(angle_b, SOURCE_FULL_CIRCLE_DEGREES)
	var forward := angle_a - angle_b + SOURCE_FULL_CIRCLE_DEGREES if (angle_a - angle_b) < 0.0 else angle_a - angle_b
	var backward := angle_b - angle_a + SOURCE_FULL_CIRCLE_DEGREES if (angle_b - angle_a) < 0.0 else angle_b - angle_a
	return min(forward, backward)

static func source_angles_within(a: float, b: float, margin: float) -> bool:
	return abs(source_angles_angle_dist(a, b)) <= margin

static func source_angles_move_toward(angle: float, to: float, speed: float) -> float:
	if abs(source_angles_angle_dist(angle, to)) < speed:
		return to
	angle = source_mod_float(angle, SOURCE_FULL_CIRCLE_DEGREES)
	to = source_mod_float(to, SOURCE_FULL_CIRCLE_DEGREES)
	if (angle > to) == (source_angles_backward_distance(angle, to) > source_angles_forward_distance(angle, to)):
		angle -= speed
	else:
		angle += speed
	return angle

static func source_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	var angle := rad_to_deg(atan2(to_y - from_y, to_x - from_x))
	if angle < 0.0:
		angle += SOURCE_FULL_CIRCLE_DEGREES
	return angle

static func source_vec2_angle(vec_x: float, vec_y: float) -> float:
	var angle := rad_to_deg(atan2(vec_y, vec_x))
	if angle < 0.0:
		angle += SOURCE_FULL_CIRCLE_DEGREES
	return angle


static func source_angles_trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	var radians := deg_to_rad(angle_degrees)
	var cos_value := cos(radians)
	var sin_value := sin(radians)
	var new_x := x_value * cos_value - y_value * sin_value
	var new_y := x_value * sin_value + y_value * cos_value
	return {"x": new_x, "y": new_y, "angle_degrees": angle_degrees, "x_value": x_value, "y_value": y_value}

static func source_dst(x1: float, y1: float, x2: float, y2: float) -> float:
	var xd := x2 - x1
	var yd := y2 - y1
	return sqrt(xd * xd + yd * yd)

static func source_vec2_limit(vector_state: Dictionary, limit: float) -> Dictionary:
	var vector_x := float(vector_state.get("x", 0.0))
	var vector_y := float(vector_state.get("y", 0.0))
	var limited_vector := source_arc_vec2_limit(Vector2(vector_x, vector_y), limit)
	var len2 := vector_x * vector_x + vector_y * vector_y
	return {"x": limited_vector.x, "y": limited_vector.y, "limit": limit, "len2": len2, "limit2": limit * limit}

static func source_arc_vec2_limit(vector: Vector2, limit: float) -> Vector2:
	var limit2 := limit * limit
	var len2 := vector.length_squared()
	if len2 > limit2 and len2 > 0.0:
		return vector * sqrt(limit2 / len2)
	return vector

static func source_vec2_rotate_radians(x_value: float, y_value: float, radians: float) -> Dictionary:
	var cos_value := cos(radians)
	var sin_value := sin(radians)
	return {"x": x_value * cos_value - y_value * sin_value, "y": x_value * sin_value + y_value * cos_value, "radians": radians}

static func _source_arc_rand_set_seed(seed_value: int) -> Dictionary:
	return {"state": _source_arc_rand_murmur_hash3(seed_value)}

static func _source_arc_rand_next_int_unbounded(rand_state: Dictionary) -> int:
	return int(_source_arc_rand_next_long(rand_state) & 0x7fffffff)

static func _source_arc_rand_next_int_bound(rand_state: Dictionary, bound: int) -> int:
	if bound <= 0:
		return 0
	return int(_source_arc_rand_next_int_unbounded(rand_state) % bound)

static func _source_arc_rand_next_float(rand_state: Dictionary) -> float:
	return float(_source_words_to_nonnegative(_source_words_unsigned_shift_right(_source_arc_rand_next_long_words(rand_state), 40))) * SOURCE_RAND_NORM_FLOAT

static func _source_arc_rand_next_long_words(rand_state: Dictionary) -> Array:
	var value := _source_arc_rand_next_long(rand_state)
	return _source_int_to_words(value)

static func _source_arc_rand_next_long(rand_state: Dictionary) -> int:
	var state := int(rand_state.get("state", 0))
	state = _source_arc_rand_murmur_hash3(state + SOURCE_RAND_MURMUR_CONST1)
	rand_state["state"] = state
	return state

static func _source_arc_rand_murmur_hash3(value: int) -> int:
	var h := value
	h = int(h ^ (h >> 33))
	h = int(h * SOURCE_RAND_MURMUR_CONST1)
	h = int(h ^ (h >> 33))
	h = int(h * SOURCE_RAND_MURMUR_CONST2)
	h = int(h ^ (h >> 33))
	return abs(h)

static func _source_int_to_words(value: int) -> Array:
	var safe_value: int = int(abs(value))
	return [
		safe_value & SOURCE_UINT16_MASK,
		(safe_value >> 16) & SOURCE_UINT16_MASK,
		(safe_value >> 32) & SOURCE_UINT16_MASK,
		(safe_value >> 48) & SOURCE_UINT16_MASK,
	]

static func _source_words_unsigned_shift_right(words: Array, shift: int) -> Array:
	var value := _source_words_to_nonnegative(words)
	return _source_int_to_words(value >> shift)

static func _source_words_to_nonnegative(words: Array) -> int:
	var value := 0
	for index in range(min(words.size(), 4)):
		value |= int(words[index]) << (index * 16)
	return abs(value)
