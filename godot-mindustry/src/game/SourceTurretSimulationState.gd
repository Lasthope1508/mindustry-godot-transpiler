extends RefCounted
class_name SourceTurretSimulationState

const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_combat_state := preload("res://src/game/SourceTurretCombatState.gd")
const source_turret_simulation_callback_state := preload("res://src/game/SourceTurretSimulationCallbackState.gd")

const SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_KEY
const SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_FALLBACK
const SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_KEY
const SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_FALLBACK
const SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_KEY
const SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_FALLBACK
const SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_KEY
const SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_FALLBACK
const SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_KEY
const SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_FALLBACK
const SOURCE_TURRET_SIMULATION_ROTATE_SPEED_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_ROTATE_SPEED_KEY
const SOURCE_TURRET_SIMULATION_ROTATE_SPEED_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_ROTATE_SPEED_FALLBACK
const SOURCE_TURRET_SIMULATION_SHOOT_CONE_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_SHOOT_CONE_KEY
const SOURCE_TURRET_SIMULATION_SHOOT_CONE_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_SHOOT_CONE_FALLBACK
const SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_KEY
const SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FALLBACK
const SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_KEY
const SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_FALLBACK
const SOURCE_TURRET_SIMULATION_PEEK_AMMO_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_PEEK_AMMO_KEY
const SOURCE_TURRET_SIMULATION_PEEK_AMMO_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_PEEK_AMMO_FALLBACK
const SOURCE_TURRET_SIMULATION_USE_AMMO_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_USE_AMMO_KEY
const SOURCE_TURRET_SIMULATION_USE_AMMO_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_USE_AMMO_FALLBACK
const SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_KEY
const SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_FALLBACK
const SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_KEY
const SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_FALLBACK
const SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_KEY
const SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_FALLBACK
const SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_KEY := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_KEY
const SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_FALLBACK := source_turret_simulation_callback_state.SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_turret_simulation_method_names"):
		var names = game.call("_turret_simulation_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func simulation_callbacks(game) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_KEY, SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_FALLBACK)),
		SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_KEY, SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_FALLBACK)),
		SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_KEY, SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_FALLBACK)),
		SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_KEY, SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_FALLBACK)),
		SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_KEY, SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_FALLBACK)),
		SOURCE_TURRET_SIMULATION_ROTATE_SPEED_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_ROTATE_SPEED_KEY, SOURCE_TURRET_SIMULATION_ROTATE_SPEED_FALLBACK)),
		SOURCE_TURRET_SIMULATION_SHOOT_CONE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_SHOOT_CONE_KEY, SOURCE_TURRET_SIMULATION_SHOOT_CONE_FALLBACK)),
		SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_KEY, SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FALLBACK)),
		SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_KEY, SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_FALLBACK)),
		SOURCE_TURRET_SIMULATION_PEEK_AMMO_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_PEEK_AMMO_KEY, SOURCE_TURRET_SIMULATION_PEEK_AMMO_FALLBACK)),
		SOURCE_TURRET_SIMULATION_USE_AMMO_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_USE_AMMO_KEY, SOURCE_TURRET_SIMULATION_USE_AMMO_FALLBACK)),
		SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_KEY, SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_FALLBACK)),
		SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_KEY, SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_FALLBACK)),
		SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_KEY, SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_FALLBACK)),
		SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_KEY, SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_FALLBACK)),
	}

static func turret_fire_state(cell: Vector2i, delta: float, turret, current_rotation: float, cooldown: float, data: Dictionary, callbacks: Dictionary, tick_rate: float) -> Dictionary:
	var range_for_ammo_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_RANGE_FOR_AMMO_KEY, Callable())
	var angle_to_target_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_ANGLE_TO_TARGET_KEY, Callable())
	var find_enemy_target_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_FIND_ENEMY_TARGET_KEY, Callable())
	var move_angle_toward_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_MOVE_ANGLE_TOWARD_KEY, Callable())
	var angle_distance_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_ANGLE_DISTANCE_KEY, Callable())
	var rotate_speed_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_ROTATE_SPEED_KEY, Callable())
	var shoot_cone_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_SHOOT_CONE_KEY, Callable())
	var reload_seconds_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_KEY, Callable())
	var origin := Vector2(cell)
	var range_pixels: float = float(range_for_ammo_fn.call(turret, data)) if range_for_ammo_fn.is_valid() else 0.0
	var target = find_enemy_target_fn.call(origin, range_pixels) if find_enemy_target_fn.is_valid() else null
	var target_rotation: float = float(angle_to_target_fn.call(origin, target)) if angle_to_target_fn.is_valid() else current_rotation
	if target == null:
		# Turret.updateTile (Turret.java:569-601): the aim, the turn
		# and the shoot gate all run inside validateTarget(), so
		# with no target the turret holds its rotation and never
		# fires. A null target used to read as an aim at 0 degrees,
		# so the duo burned its 30 copper rounds into empty air
		# before the dagger entered range and the defense leg came
		# down to a single hit.
		var idle_cooldown: float = maxf(0.0, cooldown - delta)
		var idle_fire_state := {
			"cooldown_after_tick": idle_cooldown,
			"cooldown_after_fire": idle_cooldown,
			"next_rotation": current_rotation,
			"angle_delta": 0.0,
			"within_shoot_cone": false,
			"should_fire": false,
		}
		var idle_decorated_fire_state := {
			"cell": cell,
			"target": target,
			"target_rotation": current_rotation,
			"range_pixels": range_pixels,
		}
		idle_fire_state.merge(idle_decorated_fire_state, true)
		return idle_fire_state
	var fire_state := source_turret_combat_state.fire_cycle_state(
		current_rotation,
		target_rotation,
		delta,
		float(rotate_speed_fn.call(turret)) if rotate_speed_fn.is_valid() else 0.0,
		float(shoot_cone_fn.call(turret)) if shoot_cone_fn.is_valid() else 0.0,
		cooldown,
		float(reload_seconds_fn.call(turret)) if reload_seconds_fn.is_valid() else 0.0,
		tick_rate,
		move_angle_toward_fn,
		angle_distance_fn
	)
	var decorated_fire_state := {
		"cell": cell,
		"target": target,
		"target_rotation": target_rotation,
		"range_pixels": range_pixels,
	}
	fire_state.merge(decorated_fire_state, true)
	return fire_state

static func turret_fire_context(game, cell: Vector2i, key: String, turret, seconds: float, callbacks: Dictionary) -> Dictionary:
	var peek_ammo_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_PEEK_AMMO_KEY, Callable())
	var data: Dictionary = {}
	if peek_ammo_fn.is_valid():
		data = peek_ammo_fn.call(cell, turret)
	return {
		"game": game,
		"cell": cell,
		"key": key,
		"turret": turret,
		"seconds": seconds,
		"callbacks": callbacks,
		"data": data,
		"current_rotation": float(game.get("turret_rotations").get(key, 0.0)),
		"cooldown": float(game.get("turret_cooldowns").get(key, 0.0)),
	}

static func turret_fire_from_context(context: Dictionary) -> Dictionary:
	var callbacks: Dictionary = context.get("callbacks", {})
	var data: Dictionary = context.get("data", {})
	return turret_fire_state(
		context.get("cell", Vector2i.ZERO),
		float(context.get("seconds", 0.0)),
		context.get("turret", null),
		float(context.get("current_rotation", 0.0)),
		float(context.get("cooldown", 0.0)),
		data,
		callbacks,
		source_time_defaults.TICK_RATE
	)

static func turret_shot_context(cell: Vector2i, turret, data: Dictionary, target, current_rotation: float, range_pixels: float, callbacks: Dictionary) -> Dictionary:
	var total_inaccuracy_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_TOTAL_INACCURACY_KEY, Callable())
	var random_inaccuracy_offset_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_RANDOM_INACCURACY_OFFSET_KEY, Callable())
	var inaccuracy_range: float = float(total_inaccuracy_fn.call(turret, data)) if total_inaccuracy_fn.is_valid() else 0.0
	var inaccuracy_offset: float = float(random_inaccuracy_offset_fn.call(inaccuracy_range)) if random_inaccuracy_offset_fn.is_valid() else 0.0
	return {
		"cell": cell,
		"turret": turret,
		"data": data,
		"target": target,
		"current_rotation": current_rotation,
		"range_pixels": range_pixels,
		"inaccuracy_range": inaccuracy_range,
		"inaccuracy_offset": inaccuracy_offset,
		"shoot_angle_degrees": current_rotation + inaccuracy_offset,
	}

@warning_ignore("unused_parameter")
static func turret_shot_application_state(shot_context: Dictionary, turret_step_state: Dictionary, current_rotation: float, cooldown: float) -> Dictionary:
	var callbacks: Dictionary = shot_context.get("callbacks", {})
	var turret = shot_context.get("turret", null)
	var duo = turret
	var data: Dictionary = shot_context.get("data", {})
	var cell: Vector2i = shot_context.get("cell", Vector2i.ZERO)
	var bullet_origin_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_BULLET_ORIGIN_KEY, Callable())
	var shoot_x_offset_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_SHOOT_X_OFFSET_KEY, Callable())
	var reload_seconds_for_ammo_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_RELOAD_SECONDS_FOR_AMMO_KEY, Callable())
	var use_ammo_fn: Callable = callbacks.get(SOURCE_TURRET_SIMULATION_USE_AMMO_KEY, Callable())
	var shoot_x_offset := float(shoot_x_offset_fn.call(cell, turret)) if shoot_x_offset_fn.is_valid() else 0.0
	# The bullet spawns at the turret's true world position (the
	# building's x/y), not at its grid cell: the live loop carries
	# the game on the shot context, so the cell is converted there;
	# a context without a game (the module proof) keeps the cell.
	var shot_game = shot_context.get("game", null)
	var turret_origin := Vector2(cell)
	if shot_game != null and shot_game.has_method("grid_to_world"):
		turret_origin = shot_game.call("grid_to_world", cell)
	var bullet_origin_state: Dictionary = bullet_origin_fn.call(turret_origin.x, turret_origin.y, current_rotation, turret, shoot_x_offset) if bullet_origin_fn.is_valid() else {}
	var bullet_origin := Vector2(float(bullet_origin_state.get("bulletX", turret_origin.x)), float(bullet_origin_state.get("bulletY", turret_origin.y)))
	var shot_application := {
		"cooldown_after_fire": cooldown,
		"bullet_origin": bullet_origin,
		"shoot_y": float(bullet_origin_state.get("shootY", 0.0)),
		"shoot_x_offset": shoot_x_offset,
		"range_pixels": float(shot_context.get("range_pixels", 0.0)),
		"inaccuracy_range": float(shot_context.get("inaccuracy_range", 0.0)),
		"inaccuracy_offset": float(shot_context.get("inaccuracy_offset", 0.0)),
		"shoot_angle_degrees": float(shot_context.get("shoot_angle_degrees", current_rotation)),
		"recoil": 1.0,
		"recoils": 1,
		"data": data,
	}
	if use_ammo_fn.is_valid():
		data = use_ammo_fn.call(cell, duo)
	shot_application["data"] = data
	if not data.is_empty():
		shot_application["cooldown_after_fire"] = float(reload_seconds_for_ammo_fn.call(turret, data)) if reload_seconds_for_ammo_fn.is_valid() else cooldown
	return shot_application

static func simulate_turrets(game, delta: float) -> void:
	var callbacks := simulation_callbacks(game)
	var turret_cells: Array = game.get("turret_cells")
	var turret_rotations: Dictionary = game.get("turret_rotations")
	var turret_cooldowns: Dictionary = game.get("turret_cooldowns")
	var turret_recoils: Dictionary = game.get("turret_recoils")
	for cell in turret_cells:
		var key: String = str(game.call("cell_key", cell))
		var duo = game.call("selected_playable_turret")
		game.call("update_turret_recoil", cell, duo, delta, float(turret_rotations.get(key, 0.0)))
		var fire_context := turret_fire_context(game, cell, key, duo, delta, callbacks)
		var turret_step_state := turret_fire_from_context(fire_context)
		var data: Dictionary = fire_context.get("data", {})
		var target = turret_step_state.get("target", null)
		var target_rotation: float = float(turret_step_state.get("target_rotation", 0.0))
		var current_rotation: float = float(turret_step_state.get("current_rotation", target_rotation))
		var angle_delta: float = float(turret_step_state.get("angle_delta", 0.0))
		var cooldown := float(turret_step_state.get("cooldown_after_tick", 0.0))
		turret_rotations[key] = current_rotation
		turret_cooldowns[key] = cooldown
		game.set("last_turret_target_rotation", target_rotation)
		game.set("last_turret_rotation", current_rotation)
		game.set("last_turret_angle_delta", angle_delta)
		var cur_recoil := float(turret_recoils.get(key, 0.0))
		turret_recoils[key] = cur_recoil
		game.set("last_turret_cur_recoil", cur_recoil)
		if not bool(turret_step_state.get("should_fire", false)):
			continue
		var shot_context := turret_shot_context(cell, duo, data, target, current_rotation, float(turret_step_state.get("range_pixels", 0.0)), callbacks)
		shot_context["callbacks"] = callbacks
		shot_context["game"] = game
		var shot_application := turret_shot_application_state(shot_context, turret_step_state, current_rotation, cooldown)
		cooldown = float(shot_application.get("cooldown_after_fire", cooldown))
		turret_cooldowns[key] = cooldown
		game.set("last_turret_fired_range", float(shot_application.get("range_pixels", 0.0)))
		game.set("last_turret_fired_shoot_y", float(shot_application.get("shoot_y", 0.0)))
		game.set("last_turret_fired_shoot_x_offset", float(shot_application.get("shoot_x_offset", 0.0)))
		game.set("last_turret_fired_inaccuracy_range", float(shot_application.get("inaccuracy_range", 0.0)))
		game.set("last_turret_fired_inaccuracy_offset", float(shot_application.get("inaccuracy_offset", 0.0)))
		game.set("last_turret_recoil", float(shot_application.get("recoil", 0.0)))
		game.set("last_turret_recoils", int(shot_application.get("recoils", 0)))
		var recoil_offset: Vector2 = game.call("source_turret_recoil_offset", duo, current_rotation, 1.0)
		game.call("apply_turret_recoil_offset", cell, duo, recoil_offset)
		var bullet_origin: Vector2 = shot_application.get("bullet_origin", Vector2.ZERO) as Vector2
		var shoot_angle_degrees := float(shot_application.get("shoot_angle_degrees", current_rotation))
		data = shot_application.get("data", {})
		if not data.is_empty():
			game.call("spawn_turret_bullet", bullet_origin, target, data, shoot_angle_degrees)
