extends RefCounted
class_name SourceUnitUpdateState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_unit_motion_state := preload("res://src/game/SourceUnitMotionState.gd")
const source_unit_environment_state := preload("res://src/game/SourceUnitEnvironmentState.gd")
const source_unit_lifecycle_state := preload("res://src/game/SourceUnitLifecycleState.gd")
const source_unit_boosting_state := preload("res://src/game/SourceUnitBoostingState.gd")
const source_unit_runtime_state := preload("res://src/game/SourceUnitRuntimeState.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")
const source_unit_metadata_state := preload("res://src/game/SourceUnitMetadataState.gd")
const source_unit_navigation_state := preload("res://src/game/SourceUnitNavigationState.gd")
const source_unit_sensor_state := preload("res://src/game/SourceUnitSensorState.gd")
const source_unit_set_prop_state := preload("res://src/game/SourceUnitSetPropState.gd")
const source_unit_combat_metadata_state := preload("res://src/game/SourceUnitCombatMetadataState.gd")
const source_unit_controller_state := preload("res://src/game/SourceUnitControllerState.gd")

const SOURCE_UNIT_UPDATE_REQUIRED_KEYS := [
	"type_bounded", "world_unit_height", "world_unit_width", "rules_limit_map_area", "team_is_ai",
	"rules_limit_x", "rules_limit_y", "rules_limit_width", "rules_limit_height", "current_x", "current_y",
	"elevation_value", "net_client", "is_local", "source_delta", "current_health", "is_flying_value",
	"was_flying_value", "tile_exists", "floor_is_liquid", "tile_floor_color", "type_hovering",
	"type_emit_walk_effect", "type_emit_walk_sound", "current_splash_timer", "delta_x", "delta_y",
	"hit_size_value", "floor_map_color", "floor_walk_sound_pitch_min", "floor_walk_sound_pitch_max",
	"floor_walk_sound_volume", "random_pitch_value", "floor_exists", "floor_drown_time", "can_drown_value",
	"current_drown_time", "hit_size", "type_drown_time_multiplier", "chance_delta_result", "was_healed_value",
	"current_heal_time", "team_is_only_ai", "state_is_campaign", "sector_is_captured", "headless_value",
	"type_loop_sound", "type_loop_sound_volume", "type_move_sound", "type_move_sound_volume",
	"type_move_sound_pitch_min", "type_move_sound_pitch_max", "velocity_x", "velocity_y", "type_speed",
	"type_supports_env", "dead_value", "ability_ids", "trail_exists", "type_trail_length",
	"type_use_engine_elevation", "type_engine_offset", "x_value", "y_value", "source_rotation_degrees",
	"type_drag", "floor_drag_multiplier", "unit_drag_multiplier", "rules_drag_multiplier", "team_is_wave_team",
	"state_has_spawns_value", "is_local_value", "hittable_value", "drop_zone_radius", "unit_x", "unit_y",
	"spawns", "health_value", "current_drag", "tmp_v1_x", "tmp_v1_y", "type_engine_size", "engine_range_value",
	"x_range_value", "y_range_value", "random_rotation_value", "type_fall_speed", "is_grounded_value",
	"max_health", "type_wreck_health_multiplier", "unit_id", "tile_build_exists", "type_hovering_value",
	"floor_damage_taken", "hit_time", "hit_duration", "can_pass_on_value", "type_can_boost", "current_elevation",
	"headless_state", "is_remote_value", "should_update_controller_value", "controller_is_valid_value",
	"spawned_by_core_value", "is_player_value"
]

static func _missing_update_dependencies(context: Dictionary) -> Array:
	var missing: Array = []
	for key in SOURCE_UNIT_UPDATE_REQUIRED_KEYS:
		if not context.has(key):
			missing.append(key)
	return missing

static func update_state(context: Dictionary) -> Dictionary:
	var missing := _missing_update_dependencies(context)
	if not missing.is_empty():
		return {
			"deferred": true,
			"missing_dependencies": missing,
			"call_order": [],
		}

	var stages: Dictionary = {}
	var call_order: Array = []
	stages["type_update"] = type_hook_state()
	call_order.append("type.update(self());")
	stages["bounds"] = bounds_state(context["type_bounded"], context["world_unit_height"], context["world_unit_width"], context["rules_limit_map_area"], context["team_is_ai"], context["rules_limit_x"], context["rules_limit_y"], context["rules_limit_width"], context["rules_limit_height"], context["current_x"], context["current_y"], context["elevation_value"], context["net_client"], context["is_local"], context["source_delta"])
	call_order.append("bounds")
	stages["nan_health"] = nan_health_state(context["current_health"])
	call_order.append("Float.isNaN(health)")
	stages["flying_transition"] = flying_transition_state(context["is_flying_value"], context["was_flying_value"], context["tile_exists"], context["floor_is_liquid"], context["tile_floor_color"])
	call_order.append("flying_transition")
	stages["walk_effect"] = walk_effect_state(context["type_hovering"], context["elevation_value"], context["type_emit_walk_effect"], context["type_emit_walk_sound"], context["current_splash_timer"], context["delta_x"], context["delta_y"], context["hit_size_value"], context["tile_exists"], context["tile_floor_color"], context["floor_map_color"], context["floor_walk_sound_pitch_min"], context["floor_walk_sound_pitch_max"], context["floor_walk_sound_volume"], context["random_pitch_value"])
	call_order.append("walk_effect")
	stages["drowning"] = drowning_state(context["floor_exists"], context["floor_is_liquid"], context["floor_drown_time"], context["can_drown_value"], context["current_drown_time"], context["source_delta"], context["hit_size"], context["type_drown_time_multiplier"], context["chance_delta_result"], context["net_client"])
	call_order.append("updateDrowning();")
	stages["heal_time"] = heal_time_state(context["was_healed_value"], context["current_heal_time"], context["source_delta"])
	call_order.append("healTime")
	stages["captured_sector_death"] = captured_sector_death_state(context["team_is_only_ai"], context["state_is_campaign"], context["sector_is_captured"])
	call_order.append("captured_sector_death")
	stages["sound_loop"] = sound_loop_state(context["headless_value"], context["type_loop_sound"], context["type_loop_sound_volume"], context["type_move_sound"], context["type_move_sound_volume"], context["type_move_sound_pitch_min"], context["type_move_sound_pitch_max"], context["velocity_x"], context["velocity_y"], context["type_speed"])
	call_order.append("sound_loop")
	stages["unsupported_environment"] = unsupported_env_state(context["type_supports_env"], context["dead_value"])
	call_order.append("unsupported_environment")
	stages["abilities"] = abilities_loop_state(context["ability_ids"])
	call_order.append("abilities")
	stages["trail"] = trail_position_state(context["trail_exists"], context["type_trail_length"], context["type_use_engine_elevation"], context["elevation_value"], context["type_engine_offset"], context["x_value"], context["y_value"], context["source_rotation_degrees"])
	call_order.append("trail")
	stages["drag"] = drag_formula_state(context["type_drag"], context["is_grounded_value"], context["floor_drag_multiplier"], context["unit_drag_multiplier"], context["rules_drag_multiplier"])
	call_order.append("drag")
	stages["spawn_knockback"] = spawn_knockback_state(context["team_is_wave_team"], context["state_has_spawns_value"], context["net_client"], context["is_local_value"], context["hittable_value"], context["drop_zone_radius"], context["hit_size"], context["unit_x"], context["unit_y"], context["spawns"], context["source_delta"])
	call_order.append("spawn_knockback")
	stages["falling_drag"] = falling_drag_state(context["dead_value"], context["health_value"], context["current_drag"])
	call_order.append("falling_drag")
	stages["falling_smoke"] = falling_smoke_state(context["dead_value"], context["health_value"], context["chance_delta_result"], context["unit_x"], context["unit_y"], context["hit_size"], context["tmp_v1_x"], context["tmp_v1_y"])
	call_order.append("falling_smoke")
	stages["falling_engine_trail"] = falling_engine_trail_state(context["dead_value"], context["health_value"], context["chance_delta_result"], context["unit_x"], context["unit_y"], context["source_rotation_degrees"], context["elevation_value"], context["type_engine_offset"], context["type_engine_size"], context["engine_range_value"], context["x_range_value"], context["y_range_value"], context["random_rotation_value"])
	call_order.append("falling_engine_trail")
	stages["falling_descent"] = falling_descent_state(context["dead_value"], context["health_value"], context["elevation_value"], context["type_fall_speed"], context["source_delta"], context["is_grounded_value"], context["max_health"], context["type_wreck_health_multiplier"], context["unit_id"])
	call_order.append("falling_descent")
	stages["tile_unit_on_any"] = tile_unit_on_any_state(context["tile_exists"], context["tile_build_exists"], context["unit_id"])
	call_order.append("tile.build.unitOnAny(self())")
	stages["tile_unit_on"] = tile_unit_on_state(context["tile_exists"], context["is_grounded_value"], context["type_hovering_value"], context["tile_build_exists"], context["unit_id"])
	call_order.append("tile.build.unitOn(self())")
	stages["floor_damage"] = floor_damage_state(context["tile_exists"], context["is_grounded_value"], context["type_hovering_value"], context["floor_damage_taken"], context["source_delta"], context["hit_time"], context["hit_duration"])
	call_order.append("damageContinuous(floor.damageTaken)")
	stages["solid_tile_response"] = solid_tile_response_state(context["tile_exists"], context["can_pass_on_value"], context["type_can_boost"], context["current_elevation"], context["net_client"], context["headless_state"], context["is_remote_value"], context["unit_id"])
	call_order.append("solid_tile_response")
	stages["controller_update"] = ai_controller_server_gate_state(context["net_client"], context["dead_value"], context["should_update_controller_value"], context["unit_id"])
	call_order.append("controller.updateUnit();")
	stages["invalid_controller_reset"] = invalid_controller_reset_state(context["controller_is_valid_value"], context["unit_id"])
	call_order.append("resetController();")
	stages["spawned_core_despawn"] = spawned_core_despawn_state(context["spawned_by_core_value"], context["is_player_value"], context["dead_value"], context["unit_id"])
	call_order.append("Call.unitDespawn(self())")
	return {
		"deferred": false,
		"call_order": call_order,
		"stages": stages,
	}

const SOURCE_UNIT_UPDATE_SIN_SCALED_KEY := source_unit_motion_state.SOURCE_UNIT_UPDATE_SIN_SCALED_KEY
const SOURCE_UNIT_UPDATE_SIN_SCALED_FALLBACK := source_unit_motion_state.SOURCE_UNIT_UPDATE_SIN_SCALED_FALLBACK
const SOURCE_UNIT_UPDATE_COS_SCALED_KEY := source_unit_motion_state.SOURCE_UNIT_UPDATE_COS_SCALED_KEY
const SOURCE_UNIT_UPDATE_COS_SCALED_FALLBACK := source_unit_motion_state.SOURCE_UNIT_UPDATE_COS_SCALED_FALLBACK
const SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY := source_unit_motion_state.SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY
const SOURCE_UNIT_UPDATE_VEC2_LIMIT_FALLBACK := source_unit_motion_state.SOURCE_UNIT_UPDATE_VEC2_LIMIT_FALLBACK
const SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY := source_unit_motion_state.SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY
const SOURCE_UNIT_UPDATE_VEC2_ANGLE_FALLBACK := source_unit_motion_state.SOURCE_UNIT_UPDATE_VEC2_ANGLE_FALLBACK
const SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY := source_unit_motion_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY
const SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_FALLBACK := source_unit_motion_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_FALLBACK
const SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY := source_unit_motion_state.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY
const SOURCE_UNIT_UPDATE_ANGLES_ANGLE_FALLBACK := source_unit_motion_state.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	return source_unit_motion_state.runtime_method_names(game)

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return source_unit_motion_state.runtime_method_name(method_names, key, fallback_name)

static func default_callbacks_state(game: Object) -> Dictionary:
	return source_unit_motion_state.default_callbacks_state(game)

static func game_wobble_state(game: Object, current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int) -> Dictionary:
	return source_unit_motion_state.game_wobble_state(game, current_x, current_y, source_time, source_delta, elevation_value, unit_id)

static func game_move_at_state(game: Object, vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float) -> Dictionary:
	return source_unit_motion_state.game_move_at_state(game, vel_x, vel_y, vector_x, vector_y, acceleration, source_delta)

static func game_rotate_move_motion_state(game: Object, unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	return source_unit_motion_state.game_rotate_move_motion_state(game, unit_rotation_degrees, vec_x, vec_y)

static func game_rotate_move_rotation_state(game: Object, current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_motion_state.game_rotate_move_rotation_state(game, current_rotation, vec_x, vec_y, type_rotate_speed, speed_multiplier_value, source_delta)

static func game_look_at_angle_state(game: Object, current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_motion_state.game_look_at_angle_state(game, current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta)

static func game_look_at_position_state(game: Object, current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_motion_state.game_look_at_position_state(game, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)

static func game_look_at_xy_state(game: Object, current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_motion_state.game_look_at_xy_state(game, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)

const SOURCE_UNIT_GROUNDED_EPSILON := source_unit_defaults.GROUNDED_EPSILON
const SOURCE_UNIT_WOBBLE_SIN_SCL := source_unit_defaults.WOBBLE_SIN_SCL
const SOURCE_UNIT_WOBBLE_MAG := source_unit_defaults.WOBBLE_MAG
const SOURCE_UNIT_WALK_EFFECT_THRESHOLD_BASE := source_unit_defaults.WALK_EFFECT_THRESHOLD_BASE
const SOURCE_UNIT_WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR := source_unit_defaults.WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR
const SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION := source_unit_defaults.FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION
const SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION := source_unit_defaults.FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION
const SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR := source_unit_defaults.FALL_ENGINE_OFFSET_DIVISOR
const SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET := source_unit_defaults.FALL_ENGINE_ROTATION_OFFSET
const SOURCE_UNIT_FALL_ENGINE_TRAIL_CHANCE := source_unit_defaults.FALL_ENGINE_TRAIL_CHANCE
const SOURCE_UNIT_TRAIL_SCALE_DEFAULT := source_unit_defaults.TRAIL_SCALE_DEFAULT
const SOURCE_UNIT_DRAG_FLOOR_FACTOR_DEFAULT := source_unit_defaults.DRAG_FLOOR_FACTOR_DEFAULT
const SOURCE_UNIT_FALLING_DRAG_MIN := source_unit_defaults.FALLING_DRAG_MIN
const SOURCE_UNIT_FALL_SMOKE_CHANCE := source_unit_defaults.FALL_SMOKE_CHANCE
const SOURCE_UNIT_SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET := source_unit_defaults.SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET
const SOURCE_UNIT_SPAWN_KNOCKBACK_STRENGTH_OFFSET := source_unit_defaults.SPAWN_KNOCKBACK_STRENGTH_OFFSET
const SOURCE_UNIT_SPAWN_KNOCKBACK_SCALE := source_unit_defaults.SPAWN_KNOCKBACK_SCALE
const SOURCE_UNIT_SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR := source_unit_defaults.SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR
const SOURCE_UNIT_SOLID_TILE_BOOST_ELEVATION := source_unit_defaults.SOLID_TILE_BOOST_ELEVATION
const SOURCE_UNIT_WARP_DST := source_world_defaults.UNIT_WARP_DST
const SOURCE_FINAL_WORLD_BOUNDS := source_world_defaults.FINAL_WORLD_BOUNDS
const SOURCE_UNIT_FLYING_ELEVATION_MIN := source_unit_defaults.FLYING_ELEVATION_MIN
const SOURCE_UNIT_IS_GROUNDED_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_IS_GROUNDED_METHOD
const SOURCE_UNIT_IS_GROUNDED_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_IS_GROUNDED_RETURN
const SOURCE_UNIT_IS_FLYING_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_METHOD
const SOURCE_UNIT_IS_FLYING_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_RETURN
const SOURCE_UNIT_CHECK_TARGET_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_METHOD
const SOURCE_UNIT_CHECK_TARGET_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_RETURN
const SOURCE_UNIT_CHECK_TARGET_IS_GROUNDED_CALL := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_IS_GROUNDED_CALL
const SOURCE_UNIT_CHECK_TARGET_IS_FLYING_CALL := source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_IS_FLYING_CALL
const SOURCE_UNIT_CAN_DROWN_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_METHOD
const SOURCE_UNIT_CAN_DROWN_IS_GROUNDED_CALL := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_IS_GROUNDED_CALL
const SOURCE_UNIT_CAN_DROWN_TYPE_CAN_DROWN := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_TYPE_CAN_DROWN
const SOURCE_UNIT_CAN_DROWN_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_RETURN
const SOURCE_UNIT_DROWN_FLOOR_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_METHOD
const SOURCE_UNIT_DROWN_FLOOR_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_RETURN
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_METHOD
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_TILE := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_TILE
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_ON_RETURN
const SOURCE_UNIT_DROWN_FLOOR_TILE_ON_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_TILE_ON_METHOD
const SOURCE_UNIT_DROWN_FLOOR_TILE_ON_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_TILE_ON_RETURN
const SOURCE_UNIT_DROWN_FLOOR_FLOOR_CLASS := source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_FLOOR_CLASS
const SOURCE_UNIT_MOVE_AT_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_METHOD
const SOURCE_UNIT_MOVE_AT_TARGET_SET := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_TARGET_SET
const SOURCE_UNIT_MOVE_AT_DELTA_LIMIT := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DELTA_LIMIT
const SOURCE_UNIT_MOVE_AT_VEL_ADD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_VEL_ADD
const SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_METHOD
const SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_CALL := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_CALL
const SOURCE_UNIT_APPROACH_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_METHOD
const SOURCE_UNIT_APPROACH_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_CALL
const SOURCE_UNIT_APPROACH_VEC2_APPROACH_DELTA_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_APPROACH_DELTA_CALL
const SOURCE_UNIT_APPROACH_VEC2_APPROACH_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_APPROACH_METHOD
const SOURCE_UNIT_APPROACH_VEC2_DX_DY := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_DX_DY
const SOURCE_UNIT_APPROACH_VEC2_ALPHA2 := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_ALPHA2
const SOURCE_UNIT_APPROACH_VEC2_LEN2 := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_LEN2
const SOURCE_UNIT_APPROACH_VEC2_SCL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_SCL
const SOURCE_UNIT_APPROACH_VEC2_SUB_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_SUB_CALL
const SOURCE_UNIT_APPROACH_VEC2_SET_CALL := source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_VEC2_SET_CALL
const SOURCE_UNIT_ROTATE_MOVE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_METHOD
const SOURCE_UNIT_ROTATE_MOVE_MOTION_CALL := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_MOTION_CALL
const SOURCE_UNIT_ROTATE_MOVE_VEC2_TRNS_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_VEC2_TRNS_RETURN
const SOURCE_UNIT_ROTATE_MOVE_ROTATION_GATE := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_ROTATION_GATE
const SOURCE_UNIT_ROTATE_MOVE_ROTATION_ASSIGNMENT := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_ROTATION_ASSIGNMENT
const SOURCE_UNIT_ROTATE_MOVE_VEC2_IS_ZERO := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_VEC2_IS_ZERO
const SOURCE_UNIT_ROTATE_MOVE_VEC2_ANGLE := source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_VEC2_ANGLE
const SOURCE_UNIT_MOVE_PREF_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_METHOD
const SOURCE_UNIT_MOVE_PREF_OMNI_GATE := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_OMNI_GATE
const SOURCE_UNIT_MOVE_PREF_MOVE_AT_CALL := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_MOVE_AT_CALL
const SOURCE_UNIT_MOVE_PREF_ROTATE_MOVE_CALL := source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_ROTATE_MOVE_CALL
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_METHOD
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_CHOICE := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_CHOICE
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_RETURN
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_HOVERING := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_HOVERING
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_FLOOR_MULTIPLIER := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_TYPE_FLOOR_MULTIPLIER
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED_DEFAULT := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_FLOOR_SPEED_DEFAULT
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_BLOCK_AS_FLOOR := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_BLOCK_AS_FLOOR
const SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_SPEED_MULTIPLIER := source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_SPEED_MULTIPLIER
const SOURCE_UNIT_AIM_LOOK_POSITION_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_METHOD
const SOURCE_UNIT_AIM_LOOK_POSITION_POS_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_POS_ARG
const SOURCE_UNIT_AIM_LOOK_POSITION_AIM_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_AIM_CALL
const SOURCE_UNIT_AIM_LOOK_POSITION_LOOK_AT_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_LOOK_AT_CALL
const SOURCE_UNIT_AIM_LOOK_XY_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_METHOD
const SOURCE_UNIT_AIM_LOOK_XY_X_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_X_ARG
const SOURCE_UNIT_AIM_LOOK_XY_Y_ARG := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_Y_ARG
const SOURCE_UNIT_AIM_LOOK_XY_AIM_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_AIM_CALL
const SOURCE_UNIT_AIM_LOOK_XY_LOOK_AT_CALL := source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_LOOK_AT_CALL
const SOURCE_UNIT_LOOK_AT_ANGLE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_METHOD
const SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION := source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION
const SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION_SPEED := source_unit_update_source_text_state.SOURCE_UNIT_LOOK_AT_ANGLE_ROTATION_SPEED
static func is_grounded(elevation_value: float) -> bool:
	return source_unit_motion_state.is_grounded(elevation_value)

static func is_flying(elevation_value: float) -> bool:
	return source_unit_motion_state.is_flying(elevation_value)

static func check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return source_unit_motion_state.check_target_state(elevation_value, target_air, target_ground)

static func can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:
	return source_unit_motion_state.can_drown_state(elevation_value, type_can_drown)

static func drown_floor_state(floor_on_value: Variant) -> Variant:
	return source_unit_motion_state.drown_floor_state(floor_on_value)

static func wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int, sin_scaled: Callable, cos_scaled: Callable) -> Dictionary:
	return source_unit_motion_state.wobble_state(current_x, current_y, source_time, source_delta, elevation_value, unit_id, sin_scaled, cos_scaled)

static func player_controllable_state(type_player_controllable: bool, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_block_privileged: bool) -> Dictionary:
	return source_unit_lifecycle_state.player_controllable_state(type_player_controllable, controller_is_logic_ai, logic_controller_exists, logic_controller_block_privileged)

static func targetable_state(type_targetable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, targeter_id: int) -> Dictionary:
	return source_unit_lifecycle_state.targetable_state(type_targetable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, targeter_id)

static func is_sync_hidden_state(is_shooting_value: bool, in_fog_to_value: bool) -> Dictionary:
	return source_unit_lifecycle_state.is_sync_hidden_state(is_shooting_value, in_fog_to_value)

static func in_fog_to_state(same_team: bool, rules_fog: bool, hit_size: float, unit_x: float, unit_y: float, center_visible: bool, d8_visible: Array) -> Dictionary:
	return source_unit_lifecycle_state.in_fog_to_state(same_team, rules_fog, hit_size, unit_x, unit_y, center_visible, d8_visible)

static func handle_sync_hidden_state(unit_id: int) -> Dictionary:
	return source_unit_lifecycle_state.handle_sync_hidden_state(unit_id)

static func killable_state(type_killable: bool) -> Dictionary:
	return source_unit_lifecycle_state.killable_state(type_killable)

static func hittable_state(type_hittable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool) -> Dictionary:
	return source_unit_lifecycle_state.hittable_state(type_hittable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload)

static func after_sync_state(type_id: int, controller_exists: bool) -> Dictionary:
	return source_unit_lifecycle_state.after_sync_state(type_id, controller_exists)

static func after_read_state(type_id: int, controller_is_ai_controller: bool, ai_keep_state: bool, controller_exists: bool) -> Dictionary:
	return source_unit_lifecycle_state.after_read_state(type_id, controller_is_ai_controller, ai_keep_state, controller_exists)

static func after_read_all_state(controller_exists: bool) -> Dictionary:
	return source_unit_lifecycle_state.after_read_all_state(controller_exists)

static func add_state(type_use_unit_cap: bool, count_after_add: int, cap_value: int, spawned_by_core: bool, dead: bool, rules_editor: bool) -> Dictionary:
	return source_unit_lifecycle_state.add_state(type_use_unit_cap, count_after_add, cap_value, spawned_by_core, dead, rules_editor)

static func move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float, vec2_limit: Callable) -> Dictionary:
	return source_unit_motion_state.move_at_state(vel_x, vel_y, vector_x, vector_y, acceleration, source_delta, vec2_limit)

static func move_at_default_accel_state(vector_x: float, vector_y: float, type_accel: float) -> Dictionary:
	return source_unit_motion_state.move_at_default_accel_state(vector_x, vector_y, type_accel)

static func approach_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, type_accel: float, speed_value: float, source_delta: float) -> Dictionary:
	return source_unit_motion_state.approach_state(vel_x, vel_y, vector_x, vector_y, type_accel, speed_value, source_delta)

static func rotate_move_motion_state(unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	return source_unit_motion_state.rotate_move_motion_state(unit_rotation_degrees, vec_x, vec_y)

static func rotate_move_rotation_state(current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, vec2_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	return source_unit_motion_state.rotate_move_rotation_state(current_rotation, vec_x, vec_y, type_rotate_speed, speed_multiplier_value, source_delta, vec2_angle, angles_move_toward)

static func aim_look_position_state(pos_x: float, pos_y: float) -> Dictionary:
	return source_unit_motion_state.aim_look_position_state(pos_x, pos_y)

static func aim_look_xy_state(target_x: float, target_y: float) -> Dictionary:
	return source_unit_motion_state.aim_look_xy_state(target_x, target_y)

static func look_at_angle_state(current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_move_toward: Callable) -> Dictionary:
	return source_unit_motion_state.look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta, angles_move_toward)

static func look_at_position_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	return source_unit_motion_state.look_at_position_state(current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta, angles_angle, angles_move_toward)

static func look_at_xy_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float, angles_angle: Callable, angles_move_toward: Callable) -> Dictionary:
	return source_unit_motion_state.look_at_xy_state(current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta, angles_angle, angles_move_toward)

static func controller_predicates_state(controller_is_ai_controller: bool, controller_is_command_ai: bool) -> Dictionary:
	return source_unit_lifecycle_state.controller_predicates_state(controller_is_ai_controller, controller_is_command_ai)

static func can_target_state(other_exists: bool, other_is_unit: bool, other_unit_check_target_result: bool, other_is_building: bool, type_target_air: bool, type_target_ground: bool) -> Dictionary:
	return source_unit_lifecycle_state.can_target_state(other_exists, other_is_unit, other_unit_check_target_result, other_is_building, type_target_air, type_target_ground)

static func command_state(controller_is_command_ai: bool) -> Dictionary:
	return source_unit_lifecycle_state.command_state(controller_is_command_ai)

static func is_missile_state(unit_is_timed_killc: bool) -> Dictionary:
	return source_unit_lifecycle_state.is_missile_state(unit_is_timed_killc)

static func count_state(team_data_count_type_result: int, type_id: int) -> Dictionary:
	return source_unit_lifecycle_state.count_state(team_data_count_type_result, type_id)

static func cap_state(team_is_wave_team: bool, rules_pvp: bool, state_is_campaign: bool, rules_disable_unit_cap: bool, team_ignore_unit_cap: bool, rules_unit_cap_variable: bool, rules_unit_cap: int, team_data_unit_cap: int) -> Dictionary:
	return source_unit_lifecycle_state.cap_state(team_is_wave_team, rules_pvp, state_is_campaign, rules_disable_unit_cap, team_ignore_unit_cap, rules_unit_cap_variable, rules_unit_cap, team_data_unit_cap)

static func set_type_state(type_id: int, type_health: float, type_drag: float, type_armor: float, type_hit_size: float, mounts_length: int, type_weapons_size: int, abilities_length: int, type_abilities_size: int, first_ability_is_empty_data_ability: bool, controller_is_null: bool) -> Dictionary:
	return source_unit_lifecycle_state.set_type_state(type_id, type_health, type_drag, type_armor, type_hit_size, mounts_length, type_weapons_size, abilities_length, type_abilities_size, first_ability_is_empty_data_ability, controller_is_null)

static func drowning_state(floor_exists: bool, floor_is_liquid: bool, floor_drown_time: float, can_drown_value: bool, current_drown_time: float, source_delta: float, hit_size: float, type_drown_time_multiplier: float, chance_delta_result: bool, net_client: bool) -> Dictionary:
	return source_unit_runtime_state.drowning_state(floor_exists, floor_is_liquid, floor_drown_time, can_drown_value, current_drown_time, source_delta, hit_size, type_drown_time_multiplier, chance_delta_result, net_client)

static func type_hook_state() -> Dictionary:
	return source_unit_runtime_state.type_hook_state()

static func landed_state(type_mech_land_shake: float) -> Dictionary:
	return source_unit_boosting_state.landed_state(type_mech_land_shake)

static func heal_state(current_health: float, max_health: float, amount: float, current_was_healed: bool) -> Dictionary:
	return source_unit_runtime_state.heal_state(current_health, max_health, amount, current_was_healed)

static func heal_time_state(was_healed_value: bool, current_heal_time: float, source_delta: float) -> Dictionary:
	return source_unit_runtime_state.heal_time_state(was_healed_value, current_heal_time, source_delta)

static func captured_sector_death_state(team_is_only_ai: bool, state_is_campaign: bool, sector_is_captured: bool) -> Dictionary:
	return source_unit_runtime_state.captured_sector_death_state(team_is_only_ai, state_is_campaign, sector_is_captured)

static func sound_loop_state(headless_value: bool, type_loop_sound: String, type_loop_sound_volume: float, type_move_sound: String, type_move_sound_volume: float, type_move_sound_pitch_min: float, type_move_sound_pitch_max: float, velocity_x: float, velocity_y: float, type_speed: float) -> Dictionary:
	return source_unit_runtime_state.sound_loop_state(headless_value, type_loop_sound, type_loop_sound_volume, type_move_sound, type_move_sound_volume, type_move_sound_pitch_min, type_move_sound_pitch_max, velocity_x, velocity_y, type_speed)

static func unsupported_env_state(type_supports_env: bool, dead_value: bool) -> Dictionary:
	return source_unit_runtime_state.unsupported_env_state(type_supports_env, dead_value)

static func abilities_loop_state(ability_ids: Array) -> Dictionary:
	return source_unit_runtime_state.abilities_loop_state(ability_ids)

static func trail_position_state(trail_exists: bool, type_trail_length: int, type_use_engine_elevation: bool, elevation_value: float, type_engine_offset: float, x_value: float, y_value: float, source_rotation_degrees: float) -> Dictionary:
	return source_unit_environment_state.trail_position_state(trail_exists, type_trail_length, type_use_engine_elevation, elevation_value, type_engine_offset, x_value, y_value, source_rotation_degrees)

static func drag_formula_state(type_drag: float, grounded_value: bool, floor_drag_multiplier: float, unit_drag_multiplier: float, rules_drag_multiplier: float) -> Dictionary:
	return source_unit_environment_state.drag_formula_state(type_drag, grounded_value, floor_drag_multiplier, unit_drag_multiplier, rules_drag_multiplier)

static func falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	return source_unit_environment_state.falling_drag_state(dead_value, health_value, current_drag)

static func falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	return source_unit_environment_state.falling_smoke_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, hit_size, tmp_v1_x, tmp_v1_y)

static func falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	return source_unit_environment_state.falling_engine_trail_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, source_rotation_degrees, elevation_value, type_engine_offset, type_engine_size, engine_range_value, x_range_value, y_range_value, random_rotation_value)

static func falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	return source_unit_environment_state.falling_descent_state(dead_value, health_value, elevation_value, type_fall_speed, source_delta, is_grounded_value, max_health, type_wreck_health_multiplier, unit_id)

static func tile_unit_on_any_state(tile_exists: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return source_unit_environment_state.tile_unit_on_any_state(tile_exists, tile_build_exists, unit_id)

static func tile_unit_on_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return source_unit_environment_state.tile_unit_on_state(tile_exists, is_grounded_value, type_hovering, tile_build_exists, unit_id)

static func floor_damage_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, floor_damage_taken: float, source_delta: float, hit_time: float, hit_duration: float) -> Dictionary:
	return source_unit_environment_state.floor_damage_state(tile_exists, is_grounded_value, type_hovering, floor_damage_taken, source_delta, hit_time, hit_duration)

static func solid_tile_response_state(tile_exists: bool, can_pass_on_value: bool, type_can_boost: bool, current_elevation: float, net_client_value: bool, headless_value: bool, is_remote_value: bool, unit_id: int) -> Dictionary:
	return source_unit_environment_state.solid_tile_response_state(tile_exists, can_pass_on_value, type_can_boost, current_elevation, net_client_value, headless_value, is_remote_value, unit_id)

static func ai_controller_server_gate_state(net_client_value: bool, dead_value: bool, should_update_controller_value: bool, unit_id: int) -> Dictionary:
	return source_unit_runtime_state.ai_controller_server_gate_state(net_client_value, dead_value, should_update_controller_value, unit_id)

static func invalid_controller_reset_state(controller_is_valid_value: bool, unit_id: int) -> Dictionary:
	return source_unit_runtime_state.invalid_controller_reset_state(controller_is_valid_value, unit_id)

static func spawned_core_despawn_state(spawned_by_core_value: bool, is_player_value: bool, dead_value: bool, unit_id: int) -> Dictionary:
	return source_unit_runtime_state.spawned_core_despawn_state(spawned_by_core_value, is_player_value, dead_value, unit_id)

static func boosting_default_event_state(boost: bool) -> Dictionary:
	return source_unit_boosting_state.boosting_default_event_state(boost)

static func boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:
	return source_unit_boosting_state.boosting_guard_state(type_can_boost, dead_state, elevation_value)

static func boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:
	return source_unit_boosting_state.boosting_should_boost_state(boost, on_solid_result, elevation_value, can_land_result)

static func boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:
	return source_unit_boosting_state.boosting_elevation_state(current_elevation, type_can_boost, should_boost, type_rise_speed, type_descent_speed, source_delta)

static func boosting_event_state(event: bool) -> Dictionary:
	return source_unit_boosting_state.boosting_event_state(event)

static func spawn_knockback_state(team_is_wave_team: bool, state_has_spawns_value: bool, net_client_value: bool, is_local_value: bool, hittable_value: bool, drop_zone_radius: float, hit_size: float, unit_x: float, unit_y: float, spawns: Array, source_delta: float) -> Dictionary:
	return source_unit_environment_state.spawn_knockback_state(team_is_wave_team, state_has_spawns_value, net_client_value, is_local_value, hittable_value, drop_zone_radius, hit_size, unit_x, unit_y, spawns, source_delta)

static func bounds_state(type_bounded: bool, world_unit_height: float, world_unit_width: float, rules_limit_map_area: bool, team_is_ai: bool, rules_limit_x: int, rules_limit_y: int, rules_limit_width: int, rules_limit_height: int, current_x: float, current_y: float, elevation_value: float, net_client: bool, is_local: bool, source_delta: float) -> Dictionary:
	return source_unit_environment_state.bounds_state(type_bounded, world_unit_height, world_unit_width, rules_limit_map_area, team_is_ai, rules_limit_x, rules_limit_y, rules_limit_width, rules_limit_height, current_x, current_y, elevation_value, net_client, is_local, source_delta)

static func nan_health_state(current_health: float) -> Dictionary:
	return source_unit_environment_state.nan_health_state(current_health)

static func flying_transition_state(is_flying_value: bool, was_flying_value: bool, tile_exists: bool, floor_is_liquid: bool, tile_floor_color: String) -> Dictionary:
	return source_unit_environment_state.flying_transition_state(is_flying_value, was_flying_value, tile_exists, floor_is_liquid, tile_floor_color)

static func walk_effect_state(type_hovering: bool, elevation_value: float, type_emit_walk_effect: bool, type_emit_walk_sound: bool, current_splash_timer: float, delta_x: float, delta_y: float, hit_size_value: float, tile_exists: bool, tile_floor_color: String, floor_map_color: String, floor_walk_sound_pitch_min: float, floor_walk_sound_pitch_max: float, floor_walk_sound_volume: float, random_pitch_value: float) -> Dictionary:
	return source_unit_environment_state.walk_effect_state(type_hovering, elevation_value, type_emit_walk_effect, type_emit_walk_sound, current_splash_timer, delta_x, delta_y, hit_size_value, tile_exists, tile_floor_color, floor_map_color, floor_walk_sound_pitch_min, floor_walk_sound_pitch_max, floor_walk_sound_volume, random_pitch_value)

static func move_pref_state(type_omni_movement: bool, movement_x: float, movement_y: float) -> Dictionary:
	return source_unit_motion_state.move_pref_state(type_omni_movement, movement_x, movement_y)

static func floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:
	return source_unit_motion_state.floor_speed_multiplier_state(elevation_value, type_hovering, floor_on_speed_multiplier, type_floor_multiplier, speed_multiplier_value)

static func unloaded_state(unit_state: Variant) -> Variant:
	return unit_state

static func physic_size(hit_size: float) -> float:
	return source_unit_metadata_state.physic_size(hit_size)

static func in_range(unit_x: float, unit_y: float, other_x: float, other_y: float, type_range: float) -> bool:
	return source_unit_metadata_state.in_range(unit_x, unit_y, other_x, other_y, type_range)

static func range_state(type_max_range: float) -> Dictionary:
	return source_unit_metadata_state.range_state(type_max_range)

static func clip_size_state(is_building: bool, infinite_resources: bool, type_clip_size: float, type_region_width: float, type_build_range: float, source_tilesize: float, is_mining: bool, type_mine_range: float) -> Dictionary:
	return source_unit_metadata_state.clip_size_state(is_building, infinite_resources, type_clip_size, type_region_width, type_build_range, source_tilesize, is_mining, type_mine_range)

static func laccess_state(sensor: String, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	return source_unit_sensor_state.laccess_state(sensor, unit_state, source_tilesize)

static func sense_object_state(sensor: String, unit_state: Dictionary, no_sensed: Variant) -> Dictionary:
	return source_unit_sensor_state.object_state(sensor, unit_state, no_sensed)

static func sense_content_state(content: Dictionary, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	return source_unit_sensor_state.content_state(content, unit_state, source_tilesize)

static func set_prop_laccess_double_state(prop: String, value: float, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	return source_unit_set_prop_state.laccess_double_state(prop, value, unit_state, source_tilesize)

static func set_prop_laccess_object_state(prop: String, value: Variant, unit_state: Dictionary) -> Dictionary:
	return source_unit_set_prop_state.laccess_object_state(prop, value, unit_state)

static func set_prop_content_state(content: Dictionary, value: float, unit_state: Dictionary) -> Dictionary:
	return source_unit_set_prop_state.content_state(content, value, unit_state)

static func can_shoot_state(unit_state: Dictionary) -> Dictionary:
	return source_unit_combat_metadata_state.can_shoot_state(unit_state)

static func is_enemy_state(unit_is_enemy: bool) -> Dictionary:
	return source_unit_combat_metadata_state.is_enemy_state(unit_is_enemy)

static func collides_state(hittable: bool) -> Dictionary:
	return source_unit_combat_metadata_state.collides_state(hittable)

static func item_capacity_state(type_item_capacity: int) -> Dictionary:
	return source_unit_combat_metadata_state.item_capacity_state(type_item_capacity)

static func unit_bounds_metric_state(hit_size: float) -> Dictionary:
	return source_unit_combat_metadata_state.bounds_state(hit_size)

static func collision_state(other_is_bullet: bool, bullet: Variant) -> Dictionary:
	return source_unit_controller_state.collision_state(other_is_bullet, bullet)

static func controller_set_state(next_controller: Variant, controller_unit: Variant, self_unit: Variant) -> Dictionary:
	return source_unit_controller_state.controller_set_state(next_controller, controller_unit, self_unit)

static func controller_get_state(controller: Variant) -> Dictionary:
	return source_unit_controller_state.controller_get_state(controller)

static func get_controller_name_state(is_player: bool, player_colored_name: String, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_last_accessed: String) -> Dictionary:
	return source_unit_controller_state.get_controller_name_state(is_player, player_colored_name, controller_is_logic_ai, logic_controller_exists, logic_controller_last_accessed)

static func display_state(table: Variant) -> Dictionary:
	return source_unit_controller_state.display_state(table)

static func draw_state() -> Dictionary:
	return source_unit_controller_state.draw_state()

static func is_player_state(controller_is_player: bool) -> Dictionary:
	return source_unit_controller_state.is_player_state(controller_is_player)

static func get_player_state(controller_is_player: bool, controller: Variant) -> Dictionary:
	return source_unit_controller_state.get_player_state(controller_is_player, controller)

static func to_string_state(unit_id: int, unit_type: Variant, unit_x: float, unit_y: float) -> Dictionary:
	return source_unit_controller_state.to_string_state(unit_id, unit_type, unit_x, unit_y)

static func reset_controller_state(created_controller: Variant) -> Dictionary:
	return source_unit_controller_state.reset_controller_state(created_controller)

static func set_controller_state(current_type: Variant, definition: Variant, controller: Variant, controller_unit: Variant, self_unit: Variant) -> Dictionary:
	return source_unit_controller_state.set_state(current_type, definition, controller, controller_unit, self_unit)

static func collision_layer_state(type_allow_leg_step: bool, type_leg_physics_layer: bool, is_grounded: bool, layer_legs: int, layer_ground: int, layer_flying: int) -> Dictionary:
	return source_unit_controller_state.collision_layer_state(type_allow_leg_step, type_leg_physics_layer, is_grounded, layer_legs, layer_ground, layer_flying)

static func has_weapons(weapons: Array) -> bool:
	return source_unit_metadata_state.has_weapons(weapons)

static func speed(elevation_value: float, grounded_value: bool, player_value: bool, velocity_angle: float, rotation_value: float, strafe_penalty_value: float, can_boost_value: bool, boost_multiplier_value: float, type_speed_value: float, floor_speed_multiplier_value: float) -> float:
	return source_unit_metadata_state.speed(elevation_value, grounded_value, player_value, velocity_angle, rotation_value, strafe_penalty_value, can_boost_value, boost_multiplier_value, type_speed_value, floor_speed_multiplier_value)

static func ammof_state() -> Dictionary:
	return source_unit_metadata_state.ammof_state()

static func displayable_state(type_hoverable: bool) -> Dictionary:
	return source_unit_metadata_state.displayable_state(type_hoverable)

static func is_path_impassable_state(type_flying: bool, tile_x: int, tile_y: int, tile_in_bounds: bool, path_cost: int) -> Dictionary:
	return source_unit_navigation_state.is_path_impassable_state(type_flying, tile_x, tile_y, tile_in_bounds, path_cost)

static func can_land_state(unit_x: float, unit_y: float, physic_size: float, on_solid_result: bool, nearby_grounded_units_count: int) -> Dictionary:
	return source_unit_navigation_state.can_land_state(unit_x, unit_y, physic_size, on_solid_result, nearby_grounded_units_count)

static func pref_rotation_state(actively_building: bool, rotate_to_building: bool, build_plan_angle: float, mine_tile_exists: bool, mine_tile_angle: float, moving: bool, omni_movement: bool, velocity_angle: float, current_rotation: float) -> Dictionary:
	return source_unit_navigation_state.pref_rotation_state(actively_building, rotate_to_building, build_plan_angle, mine_tile_exists, mine_tile_angle, moving, omni_movement, velocity_angle, current_rotation)
