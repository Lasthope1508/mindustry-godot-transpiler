extends RefCounted
class_name SourceTurretCombatState

const source_predict_state := preload("res://src/game/SourcePredictState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
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
	# The live-loop turret sim passes the turret's grid cell as the
	# origin and a live enemy dict as the target; the aim must come
	# from the turret's true world position at the intercept point
	# (Turret.targetPosition), not from the cell at the target's
	# current position. Other callers keep the plain angle: the
	# tractor beam passes a world-coordinate dict origin, and the
	# module proof passes a fake target with no type, so the
	# target-position step only runs for a Vector2 cell origin and
	# a real enemy dict.
	if game != null and origin is Vector2 and target is Dictionary and Dictionary(target).has("type"):
		var positioned: Dictionary = source_turret_target_position_state(game, origin, target)
		target = positioned.get("target_position", target)
		if game.has_method("grid_to_world"):
			origin = game.call("grid_to_world", Vector2i(origin))
	return source_turret_aim_state.game_angle_to_target(game, origin, target)

static func _turret_target_current_position(target) -> Vector2:
	var target_dict: Dictionary = target if target is Dictionary else {}
	if target_dict.has("x") and target_dict.has("y"):
		return Vector2(float(target_dict.get("x", 0.0)), float(target_dict.get("y", 0.0)))
	var sprite = target_dict.get("sprite", null)
	if is_instance_valid(sprite):
		return sprite.position
	return Vector2.ZERO

# Turret.targetPosition(Posc) (Turret.java:453-470): with ammo and a
# target, the aim point is Predict.intercept when predictTarget is
# set (the Turret default, true) and the peeked bullet is fast
# enough (bullet.speed >= 0.01), else the target's current position;
# a zero intercept falls back to the current position. The duo runs
# accurateDelay with moveWhileCharging, so the charge offset is
# zero. The target's per-frame displacement is its world speed
# toward the core for one live-loop tick (time_delta 1.0); the
# shooter is the turret's world position from its grid cell.
static func source_turret_target_position_state(game: Object, origin, target) -> Dictionary:
	var current: Vector2 = _turret_target_current_position(target)
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_TARGET_POSITION_STATE,
		"target_position": {"x": current.x, "y": current.y},
		"used_intercept": false,
		"bullet_speed": 0.0,
	}
	if game == null or not (target is Dictionary) or not (origin is Vector2):
		return result
	var target_dict: Dictionary = target
	var sprite = target_dict.get("sprite", null)
	if not is_instance_valid(sprite):
		return result
	if not target_dict.has("type"):
		return result
	if not game.has_method("peek_turret_ammo") or not game.has_method("selected_playable_turret") or not game.has_method("grid_to_world") or not game.has_method("source_unit_world_speed") or not game.has_method("source_bullet_world_speed_per_tick"):
		return result
	var cell := Vector2i(origin)
	var origin_world: Vector2 = game.call("grid_to_world", cell)
	var turret = game.call("selected_playable_turret")
	var peeked = game.call("peek_turret_ammo", cell, turret)
	var ammo_data: Dictionary = peeked if peeked is Dictionary else {}
	if ammo_data.is_empty():
		return result
	var bullet_speed: float = float(game.call("source_bullet_world_speed_per_tick", ammo_data))
	if bullet_speed < source_predict_state.SOURCE_PREDICT_INTERCEPT_MIN_BULLET_SPEED:
		return result
	var target_pos: Vector2 = sprite.position
	var core_world: Vector2 = game.call("grid_to_world", game.get("core_pos"))
	var direction: Vector2 = core_world - target_pos
	var velocity := Vector2.ZERO
	if direction.length() > 0.0:
		var world_speed: float = float(game.call("source_unit_world_speed", target_dict.get("type")))
		velocity = direction.normalized() * (world_speed / source_time_defaults.TICK_RATE)
	var time_delta := 1.0
	var intercept: Dictionary = source_predict_state.source_predict_intercept_state(origin_world.x, origin_world.y, target_pos.x, target_pos.y, velocity.x * time_delta, velocity.y * time_delta, bullet_speed, time_delta)
	var point := Vector2(float(intercept.get("intercept_x", target_pos.x)), float(intercept.get("intercept_y", target_pos.y)))
	if point == Vector2.ZERO:
		return result
	result["target_position"] = {"x": point.x, "y": point.y}
	result["used_intercept"] = true
	result["bullet_speed"] = bullet_speed
	return result
