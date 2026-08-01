extends "res://src/game/SourceBuildingDrawPortBridge.gd"

const source_math_state := preload("res://src/game/SourceMathState.gd")

func source_absin(value: float, scl: float, mag: float) -> float:
	return source_math_state.source_absin(value, scl, mag)

func source_approach(from_value: float, to_value: float, speed: float) -> float:
	return source_math_state.source_approach(from_value, to_value, speed)

func source_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:
	return source_math_state.source_approach_delta(from_value, to_value, speed, source_delta)

func source_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return source_math_state.source_lerp_delta(from_value, to_value, progress, source_delta)

func source_arc_is_power_of_two(value: int) -> bool:
	return source_math_state.is_power_of_two(value)

func source_arc_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:
	return source_math_state.random_seed_int(source_seed, min_value, max_value)

func source_arc_random_seed_float_max(source_seed: int, max_value: float) -> float:
	return source_math_state.random_seed_float_max(source_seed, max_value)

func source_arc_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return source_math_state.source_arc_lerp_delta(from_value, to_value, progress, source_delta)

func source_arc_chance_delta_threshold(chance: float, source_delta: float) -> float:
	return source_math_state.source_arc_chance_delta_threshold(chance, source_delta)

func source_arc_mathf_sin_table_value(index: int) -> float:
	return source_math_state.source_arc_mathf_sin_table_value(index)

func source_arc_mathf_sin_lookup(radians: float) -> float:
	return source_math_state.source_arc_mathf_sin_lookup(radians)

func source_arc_mathf_cos_lookup(radians: float) -> float:
	return source_math_state.source_arc_mathf_cos_lookup(radians)

func source_arc_mathf_sin_scaled(radians: float, scl: float, mag: float) -> float:
	return source_math_state.source_arc_mathf_sin_scaled(radians, scl, mag)

func source_arc_mathf_cos_scaled(radians: float, scl: float, mag: float) -> float:
	return source_math_state.source_arc_mathf_cos_scaled(radians, scl, mag)

func source_arc_vec2_limit(vec: Vector2, limit: float) -> Vector2:
	return source_math_state.source_arc_vec2_limit(vec, limit)

func source_arc_mathf_mod_float(value: float, divisor: float) -> float:
	return source_math_state.source_mod_float(value, divisor)

func source_arc_angles_forward_distance(angle1: float, angle2: float) -> float:
	return source_math_state.source_angles_forward_distance(angle1, angle2)

func source_arc_angles_backward_distance(angle1: float, angle2: float) -> float:
	return source_math_state.source_angles_backward_distance(angle1, angle2)

func source_arc_angles_angle_dist(angle_a: float, angle_b: float) -> float:
	return source_math_state.source_angles_angle_dist(angle_a, angle_b)

func source_arc_angles_move_toward(angle: float, to: float, speed: float) -> float:
	return source_math_state.source_angles_move_toward(angle, to, speed)

func source_unit_vec2_angle(vec_x: float, vec_y: float) -> float:
	return source_math_state.source_vec2_angle(vec_x, vec_y)

func source_arc_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	return source_math_state.source_angles_angle(from_x, from_y, to_x, to_y)

func source_mathf_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:
	return source_math_state.source_approach_delta(from_value, to_value, speed, source_delta)

func source_mathf_dst(x1: float, y1: float, x2: float, y2: float) -> float:
	return source_math_state.source_dst(x1, y1, x2, y2)

func source_mathf_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return source_math_state.source_lerp_delta(from_value, to_value, progress, source_delta)

func source_arc_angles_trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	return source_math_state.source_angles_trns_vec(angle_degrees, x_value, y_value)

func source_vec2_limit(vector_state: Dictionary, limit: float) -> Dictionary:
	return source_math_state.source_vec2_limit(vector_state, limit)

func source_angle_distance(current_degrees: float, target_degrees: float) -> float:
	return source_math_state.source_angles_angle_dist(current_degrees, target_degrees)

func source_move_angle_toward(current_degrees: float, target_degrees: float, max_delta: float) -> float:
	return source_math_state.source_angles_move_toward(current_degrees, target_degrees, max_delta)