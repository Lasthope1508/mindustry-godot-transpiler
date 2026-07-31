extends RefCounted
class_name SourceTurretCombatState

const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_runtime_state := preload("res://src/game/SourceTurretRuntimeState.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")

const SOURCE_TURRET_SHOOT_X_DEFAULT := source_turret_defaults.SHOOT_X_DEFAULT
const SOURCE_RECOIL_POW := source_turret_defaults.RECOIL_POW
const SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_DEFAULT := source_turret_defaults.RECOIL_OFFSET_RECOIL_POW_DEFAULT
const SOURCE_MOVE_ANGLE_TOWARD_CANONICAL_WRAPPER := "source_arc_angles_move_toward(current_degrees, target_degrees, max_delta)"
const SOURCE_TURRET_TOTAL_INACCURACY_EXPR := "inaccuracy + type.inaccuracy"
const SOURCE_TURRET_COMBAT_ANGLE_KEY := "angle"
const SOURCE_TURRET_COMBAT_ANGLE_FALLBACK := "source_arc_angles_angle"
const SOURCE_TURRET_COMBAT_TRNS_VEC_KEY := "trns_vec"
const SOURCE_TURRET_COMBAT_TRNS_VEC_FALLBACK := "source_arc_angles_trns_vec"

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

static func cooldown_state(cooldown_seconds: float, seconds: float) -> Dictionary:
	return source_turret_runtime_state.cooldown_state(cooldown_seconds, seconds)

static func fire_cycle_state(current_rotation: float, target_rotation: float, seconds: float, rotate_speed: float, shoot_cone: float, cooldown_seconds: float, reload_seconds: float, tick_rate: float, move_angle_toward: Callable, angle_distance: Callable) -> Dictionary:
	return source_turret_runtime_state.fire_cycle_state(current_rotation, target_rotation, seconds, rotate_speed, shoot_cone, cooldown_seconds, reload_seconds, tick_rate, move_angle_toward, angle_distance)

static func recoil_offset(recoil_rotation_degrees: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Vector2:
	return source_turret_runtime_state.recoil_offset(recoil_rotation_degrees, cur_recoil, recoil_pow, recoil)

static func recoil_step_state(cur_recoil: float, seconds: float, tick_rate: float, recoil_time: float) -> Dictionary:
	return source_turret_runtime_state.recoil_step_state(cur_recoil, seconds, tick_rate, recoil_time)

static func update_turret_recoil(game, cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:
	var key := str(game.call("cell_key", cell))
	var turret_recoils: Dictionary = game.get("turret_recoils")
	var cur_recoil := float(turret_recoils.get(key, 0.0))
	var recoil_state := recoil_step_state(
		cur_recoil,
		delta,
		source_time_defaults.TICK_RATE,
		float(game.call("source_turret_recoil_time", turret))
	)
	cur_recoil = float(recoil_state.get("cur_recoil_after", cur_recoil))
	turret_recoils[key] = cur_recoil
	game.set("last_turret_cur_recoil", cur_recoil)
	game.set("last_turret_recoil", float(game.call("source_turret_recoil", turret)))
	game.set("last_turret_recoils", int(game.call("source_turret_recoils", turret)))
	var computed_recoil_offset: Vector2 = game.call("source_turret_recoil_offset", turret, recoil_rotation_degrees, cur_recoil)
	game.set("last_turret_recoil_offset", computed_recoil_offset)
	apply_turret_recoil_offset(game, cell, turret, computed_recoil_offset)

static func apply_turret_recoil_offset(game, cell: Vector2i, turret, offset: Vector2) -> void:
	var key := str(game.call("cell_key", cell))
	var placed_block_origins: Dictionary = game.get("placed_block_origins")
	var sprite = placed_block_origins.get(key)
	if is_instance_valid(sprite):
		sprite.position = game.call("source_block_sprite_base_position", turret, cell) + offset

static func shoot_x_offset_state(pattern: Dictionary, counter: int) -> Dictionary:
	return source_turret_runtime_state.shoot_x_offset_state(pattern, counter)

static func use_turret_shoot_x_offset(game, cell: Vector2i, turret) -> float:
	var pattern: Dictionary = game.call("source_turret_shoot_pattern", turret)
	var key := str(game.call("cell_key", cell))
	var turret_barrel_counters: Dictionary = game.get("turret_barrel_counters")
	var counter := int(turret_barrel_counters.get(key, 0))
	var shoot_offset_state := shoot_x_offset_state(pattern, counter)
	if bool(shoot_offset_state.get("used", false)):
		turret_barrel_counters[key] = counter + 1
	else:
		turret_barrel_counters[key] = counter
	return float(shoot_offset_state.get("offset", 0.0))

static func bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret_property_map: Dictionary, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	return source_turret_runtime_state.bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret_property_map, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func turret_bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	return source_turret_runtime_state.turret_bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func game_turret_bullet_origin_state(game: Object, origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
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
		callbacks.get(SOURCE_TURRET_COMBAT_TRNS_VEC_KEY, Callable())
	)

static func target_selection_state(origin: Vector2, range_pixels: float, candidates: Array) -> Dictionary:
	return source_turret_runtime_state.target_selection_state(origin, range_pixels, candidates)

static func target_candidates_from_enemy_units(enemy_units: Array) -> Array:
	var target_candidates: Array = []
	for enemy in enemy_units:
		if not (enemy is Dictionary):
			continue
		var sprite = enemy.get("sprite")
		if not is_instance_valid(sprite):
			continue
		target_candidates.append({"target": enemy, "position": sprite.position})
	return target_candidates

static func enemy_target_state(origin: Vector2, range_pixels: float, enemy_units: Array) -> Dictionary:
	var target_candidates := target_candidates_from_enemy_units(enemy_units)
	return target_selection_state(origin, range_pixels, target_candidates)

static func total_inaccuracy(turret_inaccuracy: float, bullet_inaccuracy: float) -> float:
	return turret_inaccuracy + bullet_inaccuracy

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
