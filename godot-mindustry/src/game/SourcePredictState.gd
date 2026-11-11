extends RefCounted
class_name SourcePredictState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_PREDICT_QUAD_EPSILON := 1e-6
const SOURCE_PREDICT_INTERCEPT_MIN_BULLET_SPEED := 0.01

# Predict.quad(a, b, c) (Predict.java): the quadratic solver behind
# intercept. The degenerate branch (|a| < 1e-6) is linear: no roots
# when |b| is also ~0 and c != 0, the double root -c / b otherwise.
# The quadratic branch returns null when the discriminant is
# negative, else the two roots (-b - disc) / 2a and (-b + disc) / 2a.
static func source_predict_quad_state(a: float, b: float, c: float) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_PREDICT_QUAD_STATE,
		"has_roots": false,
		"root0": 0.0,
		"root1": 0.0,
	}
	if absf(a) < SOURCE_PREDICT_QUAD_EPSILON:
		if absf(b) < SOURCE_PREDICT_QUAD_EPSILON:
			if absf(c) < SOURCE_PREDICT_QUAD_EPSILON:
				result["has_roots"] = true
				result["root0"] = 0.0
				result["root1"] = 0.0
		else:
			result["has_roots"] = true
			result["root0"] = -c / b
			result["root1"] = -c / b
		return result
	var disc: float = b * b - 4.0 * a * c
	if disc >= 0.0:
		disc = sqrt(disc)
		var denom: float = 2.0 * a
		result["has_roots"] = true
		result["root0"] = (-b - disc) / denom
		result["root1"] = (-b + disc) / denom
	return result

# Predict.intercept(srcx, srcy, dstx, dsty, dstvx, dstvy, v)
# (Predict.java): the intercept of a stationary shooter and a moving
# target. dstvx/dstvy are the target's per-frame displacement (its
# Hitboxc deltaX/deltaY); dividing by Time.delta (ticks) turns them
# into a per-tick velocity. The quadratic a = dstv^2 - v^2,
# b = 2(dstv . t), c = t^2 is solved for the smallest positive root;
# with no positive root the intercept is the target's current
# position. The caller passes time_delta in ticks (1.0 per live-loop
# tick); a zero time_delta keeps the displacement as-is.
static func source_predict_intercept_state(src_x: float, src_y: float, dst_x: float, dst_y: float, dst_vx: float, dst_vy: float, bullet_speed: float, time_delta: float) -> Dictionary:
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_PREDICT_INTERCEPT_STATE,
		"intercept_x": dst_x,
		"intercept_y": dst_y,
		"intercept_time": 0.0,
		"used_intercept": false,
		"bullet_speed": bullet_speed,
	}
	var vel_x: float = dst_vx / time_delta if time_delta != 0.0 else dst_vx
	var vel_y: float = dst_vy / time_delta if time_delta != 0.0 else dst_vy
	var tx: float = dst_x - src_x
	var ty: float = dst_y - src_y
	var quad_a: float = vel_x * vel_x + vel_y * vel_y - bullet_speed * bullet_speed
	var quad_b: float = 2.0 * (vel_x * tx + vel_y * ty)
	var quad_c: float = tx * tx + ty * ty
	var roots: Dictionary = source_predict_quad_state(quad_a, quad_b, quad_c)
	if bool(roots.get("has_roots", false)):
		var t0: float = float(roots.get("root0", 0.0))
		var t1: float = float(roots.get("root1", 0.0))
		var t: float = minf(t0, t1)
		if t < 0.0:
			t = maxf(t0, t1)
		if t > 0.0:
			result["intercept_x"] = dst_x + vel_x * t
			result["intercept_y"] = dst_y + vel_y * t
			result["intercept_time"] = t
			result["used_intercept"] = true
	return result
