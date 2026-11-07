extends RefCounted
class_name SourceWeaponsState

const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")
const source_weapons_callback_registry := preload("res://src/game/SourceWeaponsCallbackRegistry.gd")
const source_weapon_bullet_state := preload("res://src/game/SourceWeaponBulletState.gd")
const source_weapon_firing_state := preload("res://src/game/SourceWeaponFiringState.gd")
const source_weapon_shoot_pattern_state := preload("res://src/game/SourceWeaponShootPatternState.gd")
const source_weapons_core_state := preload("res://src/game/SourceWeaponsCoreState.gd")
const source_weapon_mount_update_state := preload("res://src/game/SourceWeaponMountUpdateState.gd")

const SOURCE_WEAPONS_APPROACH_DELTA_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_APPROACH_DELTA_KEY
const SOURCE_WEAPONS_APPROACH_DELTA_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_APPROACH_DELTA_FALLBACK
const SOURCE_WEAPONS_LERP_DELTA_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_LERP_DELTA_KEY
const SOURCE_WEAPONS_LERP_DELTA_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_LERP_DELTA_FALLBACK
const SOURCE_WEAPONS_TRNS_VEC_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_TRNS_VEC_KEY
const SOURCE_WEAPONS_TRNS_VEC_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_TRNS_VEC_FALLBACK
const SOURCE_WEAPONS_ANGLES_ANGLE_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_ANGLES_ANGLE_KEY
const SOURCE_WEAPONS_ANGLES_ANGLE_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_ANGLES_ANGLE_FALLBACK
const SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY
const SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_FALLBACK
const SOURCE_WEAPONS_ANGLE_DIST_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_ANGLE_DIST_KEY
const SOURCE_WEAPONS_ANGLE_DIST_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_ANGLE_DIST_FALLBACK
const SOURCE_WEAPONS_MATHF_DST_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_MATHF_DST_KEY
const SOURCE_WEAPONS_MATHF_DST_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_MATHF_DST_FALLBACK
const SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY
const SOURCE_WEAPONS_STATUS_APPLY_RESULT_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_STATUS_APPLY_RESULT_FALLBACK
const SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY := source_weapons_callback_registry.SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY
const SOURCE_WEAPONS_BULLET_ORIGIN_STATE_FALLBACK := source_weapons_callback_registry.SOURCE_WEAPONS_BULLET_ORIGIN_STATE_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_weapons_state_method_names"):
		var names = game.call("_weapons_state_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_WEAPONS_APPROACH_DELTA_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_APPROACH_DELTA_KEY, SOURCE_WEAPONS_APPROACH_DELTA_FALLBACK)),
		SOURCE_WEAPONS_LERP_DELTA_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_LERP_DELTA_KEY, SOURCE_WEAPONS_LERP_DELTA_FALLBACK)),
		SOURCE_WEAPONS_TRNS_VEC_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_TRNS_VEC_KEY, SOURCE_WEAPONS_TRNS_VEC_FALLBACK)),
		SOURCE_WEAPONS_ANGLES_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_ANGLES_ANGLE_KEY, SOURCE_WEAPONS_ANGLES_ANGLE_FALLBACK)),
		SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY, SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_FALLBACK)),
		SOURCE_WEAPONS_ANGLE_DIST_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_ANGLE_DIST_KEY, SOURCE_WEAPONS_ANGLE_DIST_FALLBACK)),
		SOURCE_WEAPONS_MATHF_DST_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_MATHF_DST_KEY, SOURCE_WEAPONS_MATHF_DST_FALLBACK)),
		SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY, SOURCE_WEAPONS_STATUS_APPLY_RESULT_FALLBACK)),
		SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY, SOURCE_WEAPONS_BULLET_ORIGIN_STATE_FALLBACK)),
	}

static func game_update_passive_timers_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_passive_timers_state(mount_state, weapon_state, unit_state, source_delta, callbacks.get(SOURCE_WEAPONS_APPROACH_DELTA_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_LERP_DELTA_KEY, Callable()))

static func game_update_mount_origin_state(game: Object, unit_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_mount_origin_state(unit_state, weapon_state, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))

static func game_update_rotate_toward_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_rotate_toward_state(mount_state, weapon_state, unit_state, can_shoot, source_delta, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_ANGLES_ANGLE_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_MOVE_TOWARD_ANGLE_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_ANGLE_DIST_KEY, Callable()))

static func game_update_bullet_origin_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_bullet_origin_state(mount_state, weapon_state, unit_state, mount_x, mount_y, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_ANGLES_ANGLE_KEY, Callable()))

static func game_update_continuous_live_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, weapon_rotation: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_continuous_live_state(mount_state, weapon_state, unit_state, bullet_state, source_delta, bullet_x, bullet_y, weapon_rotation, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))

static func game_update_continuous_laser_aim_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, shoot_angle: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_continuous_laser_aim_state(mount_state, weapon_state, bullet_state, source_delta, bullet_x, bullet_y, shoot_angle, callbacks.get(SOURCE_WEAPONS_MATHF_DST_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_APPROACH_DELTA_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))

static func game_update_always_continuous_keepalive_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_always_continuous_keepalive_state(mount_state, weapon_state, bullet_state, unit_state, callbacks.get(SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY, Callable()))

static func game_update_cone_gate_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return update_cone_gate_state(mount_state, weapon_state, unit_state, callbacks.get(SOURCE_WEAPONS_ANGLE_DIST_KEY, Callable()))

static func game_shoot_charge_start_state(game: Object, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, shoot_x: float, shoot_y: float, charge_rotation: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return shoot_charge_start_state(mount_state, weapon_state, bullet_state, unit_state, shoot_x, shoot_y, charge_rotation, callbacks.get(SOURCE_WEAPONS_STATUS_APPLY_RESULT_KEY, Callable()))

static func game_bullet_geometry_state(game: Object, unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return bullet_geometry_state(unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))

static func game_bullet_angle_life_state(game: Object, unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return bullet_angle_life_state(unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_MATHF_DST_KEY, Callable()))

static func game_bullet_create_call_state(game: Object, unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return bullet_create_call_state(unit_state, mount_state, weapon_state, bullet_state, controller_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, velocity_random, mover, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_MATHF_DST_KEY, Callable()))

static func game_handle_bullet_continuous_geometry_state(game: Object, unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return handle_bullet_continuous_geometry_state(unit_state, mount_state, weapon_state, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))

static func game_handle_bullet_aim_update_state(game: Object, unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return handle_bullet_aim_update_state(unit_state, mount_state, weapon_state, bullet_state, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()), callbacks.get(SOURCE_WEAPONS_BULLET_ORIGIN_STATE_KEY, Callable()))

static func game_bullet_recoil_velocity_state(game: Object, create_call_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return bullet_recoil_velocity_state(create_call_state, unit_state, bullet_state, callbacks.get(SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))

const SOURCE_WEAPON_RELOAD_DEFAULT := source_weapon_defaults.RELOAD_DEFAULT
const SOURCE_WEAPON_RECOIL_TIME_DEFAULT := source_weapon_defaults.RECOIL_TIME_DEFAULT
const SOURCE_WEAPON_RECOILS_DEFAULT := source_weapon_defaults.RECOILS_DEFAULT
const SOURCE_WEAPON_SMOOTH_RELOAD_SPEED_DEFAULT := source_weapon_defaults.SMOOTH_RELOAD_SPEED_DEFAULT
const SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_SHOTS_DEFAULT
const SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_FIRST_SHOT_DELAY_DEFAULT
const SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_SHOT_DELAY_DEFAULT
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOTS_FIELD := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOTS_FIELD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_FIRST_SHOT_DELAY_FIELD := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_FIRST_SHOT_DELAY_FIELD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOT_DELAY_FIELD := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_SHOT_DELAY_FIELD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_METHOD := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_METHOD
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_LOOP := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_LOOP
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_HANDLER_CALL := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_HANDLER_CALL
const SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_MOVER_NULL := source_weapon_shoot_pattern_state.SOURCE_SHOOT_PATTERN_DEFAULT_EVENTS_MOVER_NULL
const SOURCE_WEAPON_CONTINUOUS_DEFAULT := source_weapon_defaults.CONTINUOUS_DEFAULT
const SOURCE_WEAPON_SHOOT_WARMUP_SPEED_DEFAULT := source_weapon_defaults.SHOOT_WARMUP_SPEED_DEFAULT
const SOURCE_WEAPON_LINEAR_WARMUP_DEFAULT := source_weapon_defaults.LINEAR_WARMUP_DEFAULT
const SOURCE_WEAPON_X_DEFAULT := source_weapon_defaults.X_DEFAULT
const SOURCE_WEAPON_Y_DEFAULT := source_weapon_defaults.Y_DEFAULT
const SOURCE_WEAPON_CONTROLLABLE_DEFAULT := source_weapon_defaults.CONTROLLABLE_DEFAULT
const SOURCE_WEAPON_ROTATION_OFFSET_DEGREES := source_weapon_defaults.ROTATION_OFFSET_DEGREES
const SOURCE_WEAPON_FULL_CIRCLE_DEGREES := source_math_defaults.FULL_CIRCLE_DEGREES
const SOURCE_WEAPON_HALF_CIRCLE_DEGREES := source_math_defaults.HALF_CIRCLE_DEGREES
const SOURCE_WEAPON_AUTO_TARGET_DEFAULT := source_weapon_defaults.AUTO_TARGET_DEFAULT
const SOURCE_WEAPON_TARGET_INTERVAL_DEFAULT := source_weapon_defaults.TARGET_INTERVAL_DEFAULT
const SOURCE_WEAPON_TARGET_SWITCH_INTERVAL_DEFAULT := source_weapon_defaults.TARGET_SWITCH_INTERVAL_DEFAULT
const SOURCE_WEAPON_SHOOT_Y_DEFAULT := source_weapon_defaults.SHOOT_Y_DEFAULT
const SOURCE_WEAPON_PREDICT_TARGET_DEFAULT := source_weapon_defaults.PREDICT_TARGET_DEFAULT
const SOURCE_WEAPON_ROTATE_DEFAULT := source_weapon_defaults.ROTATE_DEFAULT
const SOURCE_WEAPON_ROTATE_SPEED_DEFAULT := source_weapon_defaults.ROTATE_SPEED_DEFAULT
const SOURCE_WEAPON_ROTATION_LIMIT_DEFAULT := source_weapon_defaults.ROTATION_LIMIT_DEFAULT
const SOURCE_WEAPON_BASE_ROTATION_DEFAULT := source_weapon_defaults.BASE_ROTATION_DEFAULT
const SOURCE_WEAPON_SHOOT_CONE_DEFAULT := source_weapon_defaults.SHOOT_CONE_DEFAULT
const SOURCE_WEAPON_SHOOT_X_DEFAULT := source_weapon_defaults.SHOOT_X_DEFAULT
const SOURCE_WEAPON_ALWAYS_SHOOTING_DEFAULT := source_weapon_defaults.ALWAYS_SHOOTING_DEFAULT
const SOURCE_WEAPON_AIM_CHANGE_SPEED_DEFAULT := source_weapon_defaults.AIM_CHANGE_SPEED_DEFAULT
const SOURCE_WEAPON_ALWAYS_CONTINUOUS_DEFAULT := source_weapon_defaults.ALWAYS_CONTINUOUS_DEFAULT
const SOURCE_WEAPON_SHOOT_STATUS_DURATION_DEFAULT := source_weapon_defaults.SHOOT_STATUS_DURATION_DEFAULT
const SOURCE_WEAPON_COOLDOWN_TIME_DEFAULT := source_weapon_defaults.COOLDOWN_TIME_DEFAULT
const SOURCE_WEAPON_MIN_WARMUP_DEFAULT := source_weapon_defaults.MIN_WARMUP_DEFAULT
const SOURCE_WEAPON_FLIP_SPRITE_DEFAULT := source_weapon_defaults.FLIP_SPRITE_DEFAULT
const SOURCE_WEAPON_ALTERNATE_DEFAULT := source_weapon_defaults.ALTERNATE_DEFAULT
const SOURCE_WEAPON_OTHER_SIDE_DEFAULT := source_weapon_defaults.OTHER_SIDE_DEFAULT
const SOURCE_WEAPON_MIN_SHOOT_VELOCITY_DEFAULT := source_weapon_defaults.MIN_SHOOT_VELOCITY_DEFAULT
const SOURCE_WEAPON_ACTIVE_SOUND_VOLUME_DEFAULT := source_weapon_defaults.ACTIVE_SOUND_VOLUME_DEFAULT
const SOURCE_WEAPON_SHOOT_SOUND_VOLUME_DEFAULT := source_weapon_defaults.SHOOT_SOUND_VOLUME_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MIN_DEFAULT := source_weapon_defaults.SOUND_PITCH_MIN_DEFAULT
const SOURCE_WEAPON_SOUND_PITCH_MAX_DEFAULT := source_weapon_defaults.SOUND_PITCH_MAX_DEFAULT
const SOURCE_WEAPON_PARENTIZE_EFFECTS_DEFAULT := source_weapon_defaults.PARENTIZE_EFFECTS_DEFAULT
const SOURCE_WEAPON_INACCURACY_DEFAULT := source_weapon_defaults.INACCURACY_DEFAULT
const SOURCE_WEAPON_SHAKE_DEFAULT := source_weapon_defaults.SHAKE_DEFAULT
const SOURCE_WEAPON_VELOCITY_RND_DEFAULT := source_weapon_defaults.VELOCITY_RND_DEFAULT
const SOURCE_WEAPON_EXTRA_VELOCITY_DEFAULT := source_weapon_defaults.EXTRA_VELOCITY_DEFAULT

static func setup_mounts_state(weapon_states: Array) -> Dictionary:
	return source_weapons_core_state.setup_mounts_state(weapon_states)

static func set_rotation_state(mount_states: Array, source_rotation: float) -> Dictionary:
	return source_weapons_core_state.set_rotation_state(mount_states, source_rotation)

static func control_state(mount_states: Array, rotate_value: bool, shoot_value: bool) -> Dictionary:
	return source_weapons_core_state.control_state(mount_states, rotate_value, shoot_value)

static func control_rotate_shoot_state(mount_states: Array, rotate_shoot: bool) -> Dictionary:
	return source_weapons_core_state.control_rotate_shoot_state(mount_states, rotate_shoot)

static func aim_state(mount_states: Array, unit_x: float, unit_y: float, target_x: float, target_y: float, aim_dst: float) -> Dictionary:
	return source_weapons_core_state.aim_state(mount_states, unit_x, unit_y, target_x, target_y, aim_dst)

static func aim_position_state(mount_states: Array, unit_x: float, unit_y: float, position_x: float, position_y: float, aim_dst: float) -> Dictionary:
	return source_weapons_core_state.aim_position_state(mount_states, unit_x, unit_y, position_x, position_y, aim_dst)

static func can_shoot_state(disarmed_value: bool) -> Dictionary:
	return source_weapons_core_state.can_shoot_state(disarmed_value)

static func remove_continuous_bullet_cleanup_state(mount_states: Array, unit_id: int) -> Dictionary:
	return source_weapons_core_state.remove_continuous_bullet_cleanup_state(mount_states, unit_id)

static func remove_sound_stop_state(mount_states: Array) -> Dictionary:
	return source_weapons_core_state.remove_sound_stop_state(mount_states)

static func update_dispatch_state(mount_states: Array, unit_id: int) -> Dictionary:
	return source_weapons_core_state.update_dispatch_state(mount_states, unit_id)

static func update_passive_timers_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, approach_delta: Callable, lerp_delta: Callable) -> Dictionary:
	return source_weapon_mount_update_state.update_passive_timers_state(mount_state, weapon_state, unit_state, source_delta, approach_delta, lerp_delta)

static func update_mount_origin_state(unit_state: Dictionary, weapon_state: Dictionary, trns_vec: Callable) -> Dictionary:
	return source_weapon_mount_update_state.update_mount_origin_state(unit_state, weapon_state, trns_vec)

static func update_auto_target_retarget_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, mount_x: float, mount_y: float, find_target_result_exists: bool) -> Dictionary:
	return source_weapon_mount_update_state.update_auto_target_retarget_state(mount_state, weapon_state, bullet_state, source_delta, mount_x, mount_y, find_target_result_exists)

static func update_auto_target_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, mount_x: float, mount_y: float, check_target_result: bool) -> Dictionary:
	return source_weapon_mount_update_state.update_auto_target_invalidation_state(mount_state, weapon_state, bullet_state, mount_x, mount_y, check_target_result)

static func update_auto_target_shoot_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, mount_x: float, mount_y: float, target_within_result: bool, predicted_aim: Dictionary) -> Dictionary:
	return source_weapon_mount_update_state.update_auto_target_shoot_aim_state(mount_state, weapon_state, bullet_state, can_shoot, mount_x, mount_y, target_within_result, predicted_aim)

static func update_rotate_toward_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float, trns_vec: Callable, angles_angle: Callable, move_toward_angle: Callable, angle_dist: Callable) -> Dictionary:
	return source_weapon_mount_update_state.update_rotate_toward_state(mount_state, weapon_state, unit_state, can_shoot, source_delta, trns_vec, angles_angle, move_toward_angle, angle_dist)

static func update_bullet_origin_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float, trns_vec: Callable, angles_angle: Callable) -> Dictionary:
	return source_weapon_mount_update_state.update_bullet_origin_state(mount_state, weapon_state, unit_state, mount_x, mount_y, trns_vec, angles_angle)

static func update_always_shooting_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapon_mount_update_state.update_always_shooting_state(mount_state, weapon_state)

static func _continuous_gate_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state._continuous_gate_state(mount_state, weapon_state, bullet_state)

static func update_continuous_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.update_continuous_invalidation_state(mount_state, weapon_state, bullet_state)

static func update_continuous_live_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, weapon_rotation: float, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_state.update_continuous_live_state(mount_state, weapon_state, unit_state, bullet_state, source_delta, bullet_x, bullet_y, weapon_rotation, trns_vec)

static func update_continuous_sound_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, runtime_state: Dictionary, bullet_x: float, bullet_y: float) -> Dictionary:
	return source_weapon_bullet_state.update_continuous_sound_state(mount_state, weapon_state, bullet_state, runtime_state, bullet_x, bullet_y)

static func update_continuous_laser_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, shoot_angle: float, mathf_dst: Callable, approach_delta: Callable, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_state.update_continuous_laser_aim_state(mount_state, weapon_state, bullet_state, source_delta, bullet_x, bullet_y, shoot_angle, mathf_dst, approach_delta, trns_vec)

static func update_always_continuous_keepalive_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, status_apply_result: Callable) -> Dictionary:
	return source_weapon_bullet_state.update_always_continuous_keepalive_state(mount_state, weapon_state, bullet_state, unit_state, status_apply_result)

static func update_continuous_idle_heat_sound_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float) -> Dictionary:
	return source_weapon_bullet_state.update_continuous_idle_heat_sound_state(mount_state, weapon_state, unit_state, source_delta, bullet_x, bullet_y)

static func update_alternating_side_flip_state(mount_state: Dictionary, weapon_state: Dictionary, unit_mount_states: Array) -> Dictionary:
	return source_weapon_firing_state.update_alternating_side_flip_state(mount_state, weapon_state, unit_mount_states)

static func update_active_sound_loop_state(mount_state: Dictionary, weapon_state: Dictionary, runtime_state: Dictionary, can_shoot: bool, unit_id: int) -> Dictionary:
	return source_weapon_firing_state.update_active_sound_loop_state(mount_state, weapon_state, runtime_state, can_shoot, unit_id)

static func update_velocity_length_state(unit_state: Dictionary, source_delta: float) -> Dictionary:
	return source_weapon_firing_state.update_velocity_length_state(unit_state, source_delta)

static func update_shoot_gate_prefix_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, was_flipped: bool, vel_len: float) -> Dictionary:
	return source_weapon_firing_state.update_shoot_gate_prefix_state(mount_state, weapon_state, bullet_state, can_shoot, was_flipped, vel_len)

static func update_reload_gate_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapon_firing_state.update_reload_gate_state(mount_state, weapon_state)

static func update_cone_gate_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, angle_dist: Callable) -> Dictionary:
	return source_weapon_firing_state.update_cone_gate_state(mount_state, weapon_state, unit_state, angle_dist)

static func update_shoot_call_reload_state(mount_state: Dictionary, weapon_state: Dictionary, unit_id: int, bullet_x: float, bullet_y: float, shoot_angle: float, shoot_gate: bool) -> Dictionary:
	return source_weapon_firing_state.update_shoot_call_reload_state(mount_state, weapon_state, unit_id, bullet_x, bullet_y, shoot_angle, shoot_gate)

static func shoot_charge_start_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, shoot_x: float, shoot_y: float, charge_rotation: float, status_apply_result: Callable) -> Dictionary:
	return source_weapon_firing_state.shoot_charge_start_state(mount_state, weapon_state, bullet_state, unit_state, shoot_x, shoot_y, charge_rotation, status_apply_result)

static func shoot_pattern_default_events(shoot_state: Dictionary) -> Array:
	return source_weapon_shoot_pattern_state.shoot_pattern_default_events(shoot_state)

static func generated_shoot_pattern_default_events_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	return source_weapon_shoot_pattern_state.generated_shoot_pattern_default_events_bridge_state(shots, first_shot_delay, shot_delay)

static func generated_shoot_pattern_default_events_default_bridge_state() -> Dictionary:
	return source_weapon_shoot_pattern_state.generated_shoot_pattern_default_events_default_bridge_state()

static func generated_shoot_pattern_compat_dispatch_bridge_state(total_shots: int, shots: int, first_shot_delay: float, shot_delay: float, barrel_incrementer_present: bool) -> Dictionary:
	return source_weapon_shoot_pattern_state.generated_shoot_pattern_compat_dispatch_bridge_state(total_shots, shots, first_shot_delay, shot_delay, barrel_incrementer_present)

static func generated_shoot_pattern_flip_bridge_state() -> Dictionary:
	return source_weapon_shoot_pattern_state.generated_shoot_pattern_flip_bridge_state()

static func generated_shoot_pattern_copy_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	return source_weapon_shoot_pattern_state.generated_shoot_pattern_copy_bridge_state(shots, first_shot_delay, shot_delay)

static func shoot_default_pattern_dispatch_state(mount_state: Dictionary, shoot_state: Dictionary) -> Dictionary:
	return source_weapon_shoot_pattern_state.shoot_default_pattern_dispatch_state(mount_state, shoot_state)

static func bullet_initial_guard_state(unit_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.bullet_initial_guard_state(unit_state, mount_state)

static func bullet_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_state.bullet_geometry_state(unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread, trns_vec)

static func bullet_angle_life_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	return source_weapon_bullet_state.bullet_angle_life_state(unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, trns_vec, bullet_origin_state, mathf_dst)

static func bullet_shooter_state(unit_state: Dictionary, controller_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.bullet_shooter_state(unit_state, controller_state)

static func bullet_create_call_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant, trns_vec: Callable, bullet_origin_state: Callable, mathf_dst: Callable) -> Dictionary:
	return source_weapon_bullet_state.bullet_create_call_state(unit_state, mount_state, weapon_state, bullet_state, controller_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, velocity_random, mover, trns_vec, bullet_origin_state, mathf_dst)

static func bullet_handle_call_state(unit_state: Dictionary, mount_state: Dictionary, create_call_state: Dictionary, created_bullet: Variant) -> Dictionary:
	return source_weapon_bullet_state.bullet_handle_call_state(unit_state, mount_state, create_call_state, created_bullet)

static func handle_bullet_continuous_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_state.handle_bullet_continuous_geometry_state(unit_state, mount_state, weapon_state, trns_vec)

static func handle_bullet_aim_update_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, trns_vec: Callable, bullet_origin_state: Callable) -> Dictionary:
	return source_weapon_bullet_state.handle_bullet_aim_update_state(unit_state, mount_state, weapon_state, bullet_state, trns_vec, bullet_origin_state)

static func bullet_sound_state(create_call_state: Dictionary, weapon_state: Dictionary, sound_pitch: float) -> Dictionary:
	return source_weapon_bullet_state.bullet_sound_state(create_call_state, weapon_state, sound_pitch)

static func bullet_effects_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.bullet_effects_state(create_call_state, mount_state, weapon_state, bullet_state, unit_state)

static func bullet_recoil_velocity_state(create_call_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, trns_vec: Callable) -> Dictionary:
	return source_weapon_bullet_state.bullet_recoil_velocity_state(create_call_state, unit_state, bullet_state, trns_vec)

static func bullet_shake_state(create_call_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.bullet_shake_state(create_call_state, weapon_state)

static func bullet_mount_recoil_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.bullet_mount_recoil_state(create_call_state, mount_state)

static func bullet_recoil_slots_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.bullet_recoil_slots_state(create_call_state, mount_state, weapon_state)

static func bullet_heat_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return source_weapon_bullet_state.bullet_heat_state(create_call_state, mount_state)
