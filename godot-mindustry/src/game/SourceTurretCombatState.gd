extends RefCounted
class_name SourceTurretCombatState

const source_turret_accuracy_state := preload("res://src/game/SourceTurretAccuracyState.gd")
const source_turret_aim_state := preload("res://src/game/SourceTurretAimState.gd")
const source_turret_bullet_origin_state := preload("res://src/game/SourceTurretBulletOriginState.gd")
const source_turret_fire_cycle_state := preload("res://src/game/SourceTurretFireCycleState.gd")
const source_turret_recoil_state := preload("res://src/game/SourceTurretRecoilState.gd")
const source_turret_shoot_pattern_state := preload("res://src/game/SourceTurretShootPatternState.gd")
const source_turret_targeting_state := preload("res://src/game/SourceTurretTargetingState.gd")

static func runtime_method_names(game: Object) -> Dictionary:
	return source_turret_aim_state.runtime_method_names(game)

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return source_turret_aim_state.runtime_method_name(method_names, key, fallback_name)

static func default_callbacks_state(game: Object) -> Dictionary:
	return source_turret_aim_state.default_callbacks_state(game)

static func cooldown_state(cooldown_seconds: float, seconds: float) -> Dictionary:
	return source_turret_fire_cycle_state.cooldown_state(cooldown_seconds, seconds)

static func fire_cycle_state(current_rotation: float, target_rotation: float, seconds: float, rotate_speed: float, shoot_cone: float, cooldown_seconds: float, reload_seconds: float, tick_rate: float, move_angle_toward: Callable, angle_distance: Callable) -> Dictionary:
	return source_turret_fire_cycle_state.fire_cycle_state(current_rotation, target_rotation, seconds, rotate_speed, shoot_cone, cooldown_seconds, reload_seconds, tick_rate, move_angle_toward, angle_distance)

static func recoil_offset(recoil_rotation_degrees: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Vector2:
	return source_turret_recoil_state.recoil_offset(recoil_rotation_degrees, cur_recoil, recoil_pow, recoil)

static func recoil_step_state(cur_recoil: float, seconds: float, tick_rate: float, recoil_time: float) -> Dictionary:
	return source_turret_recoil_state.recoil_step_state(cur_recoil, seconds, tick_rate, recoil_time)

static func update_turret_recoil(game, cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:
	source_turret_recoil_state.update_turret_recoil(game, cell, turret, delta, recoil_rotation_degrees)

static func apply_turret_recoil_offset(game, cell: Vector2i, turret, offset: Vector2) -> void:
	source_turret_recoil_state.apply_turret_recoil_offset(game, cell, turret, offset)

static func shoot_x_offset_state(pattern: Dictionary, counter: int) -> Dictionary:
	return source_turret_shoot_pattern_state.shoot_x_offset_state(pattern, counter)

static func use_turret_shoot_x_offset(game, cell: Vector2i, turret) -> float:
	return source_turret_shoot_pattern_state.use_turret_shoot_x_offset(game, cell, turret)

static func bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret_property_map: Dictionary, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	return source_turret_bullet_origin_state.bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret_property_map, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func turret_bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	return source_turret_bullet_origin_state.turret_bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func game_turret_bullet_origin_state(game: Object, origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return source_turret_bullet_origin_state.game_turret_bullet_origin_state(game, origin_x, origin_y, turret_rotation_degrees, turret, shoot_x_offset, y_offset, x_spread, callbacks.get(source_turret_aim_state.SOURCE_TURRET_COMBAT_TRNS_VEC_KEY, Callable()))

static func target_selection_state(origin: Vector2, range_pixels: float, candidates: Array) -> Dictionary:
	return source_turret_targeting_state.target_selection_state(origin, range_pixels, candidates)

static func target_candidates_from_enemy_units(enemy_units: Array) -> Array:
	return source_turret_targeting_state.target_candidates_from_enemy_units(enemy_units)

static func enemy_target_state(origin: Vector2, range_pixels: float, enemy_units: Array) -> Dictionary:
	return source_turret_targeting_state.enemy_target_state(origin, range_pixels, enemy_units)

static func total_inaccuracy(turret_inaccuracy: float, bullet_inaccuracy: float) -> float:
	return source_turret_accuracy_state.total_inaccuracy(turret_inaccuracy, bullet_inaccuracy)

static func angle_to_target(origin, target, angle_fn: Callable) -> float:
	return source_turret_aim_state.angle_to_target(origin, target, angle_fn)

static func game_angle_to_target(game: Object, origin, target) -> float:
	return source_turret_aim_state.game_angle_to_target(game, origin, target)
