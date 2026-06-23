extends RefCounted
class_name Mathf

static func clamp_value(value: float, min_value: float, max_value: float) -> float:
	return clamp(value, min_value, max_value)

static func lerp_delta(from_value: float, to_value: float, alpha: float) -> float:
	return lerp(from_value, to_value, alpha)

static func dst(x: float, y: float) -> float:
	return sqrt(x * x + y * y)
