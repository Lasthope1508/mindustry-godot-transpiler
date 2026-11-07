extends RefCounted
class_name SourceTurretAimState

const source_turret_aim_callback_state := preload("res://src/game/SourceTurretAimCallbackState.gd")

const SOURCE_MOVE_ANGLE_TOWARD_CANONICAL_WRAPPER := source_turret_aim_callback_state.SOURCE_MOVE_ANGLE_TOWARD_CANONICAL_WRAPPER
const SOURCE_TURRET_COMBAT_ANGLE_KEY := source_turret_aim_callback_state.SOURCE_TURRET_COMBAT_ANGLE_KEY
const SOURCE_TURRET_COMBAT_ANGLE_FALLBACK := source_turret_aim_callback_state.SOURCE_TURRET_COMBAT_ANGLE_FALLBACK
const SOURCE_TURRET_COMBAT_TRNS_VEC_KEY := source_turret_aim_callback_state.SOURCE_TURRET_COMBAT_TRNS_VEC_KEY
const SOURCE_TURRET_COMBAT_TRNS_VEC_FALLBACK := source_turret_aim_callback_state.SOURCE_TURRET_COMBAT_TRNS_VEC_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_turret_combat_method_names"):
		var names = game.call("_turret_combat_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_TURRET_COMBAT_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_COMBAT_ANGLE_KEY, SOURCE_TURRET_COMBAT_ANGLE_FALLBACK)),
		SOURCE_TURRET_COMBAT_TRNS_VEC_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_COMBAT_TRNS_VEC_KEY, SOURCE_TURRET_COMBAT_TRNS_VEC_FALLBACK)),
	}

static func angle_to_target(origin, target, angle_fn: Callable) -> float:
	var origin_x := 0.0
	var origin_y := 0.0
	if typeof(origin) == TYPE_DICTIONARY:
		origin_x = float(origin.get("x", 0.0))
		origin_y = float(origin.get("y", 0.0))
	elif origin is Vector2:
		origin_x = origin.x
		origin_y = origin.y
	if target == null:
		return 0.0
	if typeof(target) == TYPE_DICTIONARY:
		if target.has("x") and target.has("y"):
			return float(angle_fn.call(origin_x, origin_y, float(target.get("x", 0.0)), float(target.get("y", 0.0))))
		var sprite = target.get("sprite", null)
		if is_instance_valid(sprite):
			return float(angle_fn.call(origin_x, origin_y, sprite.position.x, sprite.position.y))
	return 0.0

static func game_angle_to_target(game: Object, origin, target) -> float:
	var callbacks := default_callbacks_state(game)
	return angle_to_target(origin, target, callbacks.get(SOURCE_TURRET_COMBAT_ANGLE_KEY, Callable()))
