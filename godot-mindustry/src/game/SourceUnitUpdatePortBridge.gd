extends Node2D

const source_unit_update_state := preload("res://src/game/SourceUnitUpdateState.gd")

func source_unit_is_grounded(elevation_value: float) -> bool:
	return source_unit_update_state.is_grounded(elevation_value)

func source_unit_is_flying(elevation_value: float) -> bool:
	return source_unit_update_state.is_flying(elevation_value)

func source_unit_check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return source_unit_update_state.check_target_state(elevation_value, target_air, target_ground)

func source_unit_can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:
	return source_unit_update_state.can_drown_state(elevation_value, type_can_drown)

func source_unit_drown_floor_state(floor_on_value: Variant) -> Variant:
	return source_unit_update_state.drown_floor_state(floor_on_value)

func source_unit_wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int) -> Dictionary:
	return source_unit_update_state.game_wobble_state(self, current_x, current_y, source_time, source_delta, elevation_value, unit_id)

func source_unit_move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.game_move_at_state(self, vel_x, vel_y, vector_x, vector_y, acceleration, source_delta)

func source_unit_move_at_default_accel_state(vector_x: float, vector_y: float, type_accel: float) -> Dictionary:
	return source_unit_update_state.move_at_default_accel_state(vector_x, vector_y, type_accel)

func source_unit_approach_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, type_accel: float, speed_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.approach_state(vel_x, vel_y, vector_x, vector_y, type_accel, speed_value, source_delta)

func source_unit_rotate_move_motion_state(unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	return source_unit_update_state.game_rotate_move_motion_state(self, unit_rotation_degrees, vec_x, vec_y)

func source_unit_rotate_move_rotation_state(current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.game_rotate_move_rotation_state(self, current_rotation, vec_x, vec_y, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_aim_look_position_state(pos_x: float, pos_y: float) -> Dictionary:
	return source_unit_update_state.aim_look_position_state(pos_x, pos_y)

func source_unit_aim_look_xy_state(target_x: float, target_y: float) -> Dictionary:
	return source_unit_update_state.aim_look_xy_state(target_x, target_y)

func source_unit_look_at_angle_state(current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.game_look_at_angle_state(self, current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_look_at_position_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.game_look_at_position_state(self, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_look_at_xy_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.game_look_at_xy_state(self, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_controller_predicates_state(controller_is_ai_controller: bool, controller_is_command_ai: bool) -> Dictionary:
	return source_unit_update_state.controller_predicates_state(controller_is_ai_controller, controller_is_command_ai)

func source_unit_can_target_state(other_exists: bool, other_is_unit: bool, other_unit_check_target_result: bool, other_is_building: bool, type_target_air: bool, type_target_ground: bool) -> Dictionary:
	return source_unit_update_state.can_target_state(other_exists, other_is_unit, other_unit_check_target_result, other_is_building, type_target_air, type_target_ground)

func source_unit_command_state(controller_is_command_ai: bool) -> Dictionary:
	return source_unit_update_state.command_state(controller_is_command_ai)

func source_unit_is_missile_state(unit_is_timed_killc: bool) -> Dictionary:
	return source_unit_update_state.is_missile_state(unit_is_timed_killc)

func source_unit_count_state(team_data_count_type_result: int, type_id: int) -> Dictionary:
	return source_unit_update_state.count_state(team_data_count_type_result, type_id)

func source_unit_cap_state(team_is_wave_team: bool, rules_pvp: bool, state_is_campaign: bool, rules_disable_unit_cap: bool, team_ignore_unit_cap: bool, rules_unit_cap_variable: bool, rules_unit_cap: int, team_data_unit_cap: int) -> Dictionary:
	return source_unit_update_state.cap_state(team_is_wave_team, rules_pvp, state_is_campaign, rules_disable_unit_cap, team_ignore_unit_cap, rules_unit_cap_variable, rules_unit_cap, team_data_unit_cap)

func source_unit_set_type_state(type_id: int, type_health: float, type_drag: float, type_armor: float, type_hit_size: float, mounts_length: int, type_weapons_size: int, abilities_length: int, type_abilities_size: int, first_ability_is_empty_data_ability: bool, controller_is_null: bool) -> Dictionary:
	return source_unit_update_state.set_type_state(type_id, type_health, type_drag, type_armor, type_hit_size, mounts_length, type_weapons_size, abilities_length, type_abilities_size, first_ability_is_empty_data_ability, controller_is_null)

func source_unit_player_controllable_state(type_player_controllable: bool, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_block_privileged: bool) -> Dictionary:
	return source_unit_update_state.player_controllable_state(type_player_controllable, controller_is_logic_ai, logic_controller_exists, logic_controller_block_privileged)

func source_unit_targetable_state(type_targetable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, targeter_id: int) -> Dictionary:
	return source_unit_update_state.targetable_state(type_targetable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, targeter_id)

func source_unit_killable_state(type_killable: bool) -> Dictionary:
	return source_unit_update_state.killable_state(type_killable)

func source_unit_hittable_state(type_hittable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool) -> Dictionary:
	return source_unit_update_state.hittable_state(type_hittable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload)

func source_unit_after_sync_state(type_id: int, controller_exists: bool) -> Dictionary:
	return source_unit_update_state.after_sync_state(type_id, controller_exists)

func source_unit_after_read_state(type_id: int, controller_is_ai_controller: bool, ai_keep_state: bool, controller_exists: bool) -> Dictionary:
	return source_unit_update_state.after_read_state(type_id, controller_is_ai_controller, ai_keep_state, controller_exists)

func source_unit_after_read_all_state(controller_exists: bool) -> Dictionary:
	return source_unit_update_state.after_read_all_state(controller_exists)

func source_unit_add_state(type_use_unit_cap: bool, count_after_add: int, cap_value: int, spawned_by_core: bool, dead: bool, rules_editor: bool) -> Dictionary:
	return source_unit_update_state.add_state(type_use_unit_cap, count_after_add, cap_value, spawned_by_core, dead, rules_editor)

func source_unit_landed_state(type_mech_land_shake: float) -> Dictionary:
	return source_unit_update_state.landed_state(type_mech_land_shake)

func source_unit_heal_state(current_health: float, max_health: float, amount: float, current_was_healed: bool) -> Dictionary:
	return source_unit_update_state.heal_state(current_health, max_health, amount, current_was_healed)

func source_unit_update_heal_time_state(was_healed_value: bool, current_heal_time: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.heal_time_state(was_healed_value, current_heal_time, source_delta)

func source_unit_update_captured_sector_death_state(team_is_only_ai: bool, state_is_campaign: bool, sector_is_captured: bool) -> Dictionary:
	return source_unit_update_state.captured_sector_death_state(team_is_only_ai, state_is_campaign, sector_is_captured)

func source_unit_update_sound_loop_state(headless_value: bool, type_loop_sound: String, type_loop_sound_volume: float, type_move_sound: String, type_move_sound_volume: float, type_move_sound_pitch_min: float, type_move_sound_pitch_max: float, velocity_x: float, velocity_y: float, type_speed: float) -> Dictionary:
	return source_unit_update_state.sound_loop_state(headless_value, type_loop_sound, type_loop_sound_volume, type_move_sound, type_move_sound_volume, type_move_sound_pitch_min, type_move_sound_pitch_max, velocity_x, velocity_y, type_speed)

func source_unit_update_unsupported_env_state(type_supports_env: bool, dead_value: bool) -> Dictionary:
	return source_unit_update_state.unsupported_env_state(type_supports_env, dead_value)

func source_unit_update_abilities_loop_state(ability_ids: Array) -> Dictionary:
	return source_unit_update_state.abilities_loop_state(ability_ids)

func source_unit_update_trail_position_state(trail_exists: bool, type_trail_length: int, type_use_engine_elevation: bool, elevation_value: float, type_engine_offset: float, x_value: float, y_value: float, source_rotation_degrees: float) -> Dictionary:
	return source_unit_update_state.trail_position_state(trail_exists, type_trail_length, type_use_engine_elevation, elevation_value, type_engine_offset, x_value, y_value, source_rotation_degrees)

func source_unit_update_drag_formula_state(type_drag: float, grounded_value: bool, floor_drag_multiplier: float, unit_drag_multiplier: float, rules_drag_multiplier: float) -> Dictionary:
	return source_unit_update_state.drag_formula_state(type_drag, grounded_value, floor_drag_multiplier, unit_drag_multiplier, rules_drag_multiplier)

func source_unit_update_spawn_knockback_state(team_is_wave_team: bool, state_has_spawns_value: bool, net_client_value: bool, is_local_value: bool, hittable_value: bool, drop_zone_radius: float, hit_size: float, unit_x: float, unit_y: float, spawns: Array, source_delta: float) -> Dictionary:
	return source_unit_update_state.spawn_knockback_state(team_is_wave_team, state_has_spawns_value, net_client_value, is_local_value, hittable_value, drop_zone_radius, hit_size, unit_x, unit_y, spawns, source_delta)

func source_unit_update_falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	return source_unit_update_state.falling_drag_state(dead_value, health_value, current_drag)

func source_unit_update_falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	return source_unit_update_state.falling_smoke_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, hit_size, tmp_v1_x, tmp_v1_y)

func source_unit_update_falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	return source_unit_update_state.falling_engine_trail_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, source_rotation_degrees, elevation_value, type_engine_offset, type_engine_size, engine_range_value, x_range_value, y_range_value, random_rotation_value)

func source_unit_update_falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	return source_unit_update_state.falling_descent_state(dead_value, health_value, elevation_value, type_fall_speed, source_delta, is_grounded_value, max_health, type_wreck_health_multiplier, unit_id)

func source_unit_update_tile_unit_on_any_state(tile_exists: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return source_unit_update_state.tile_unit_on_any_state(tile_exists, tile_build_exists, unit_id)

func source_unit_update_tile_unit_on_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return source_unit_update_state.tile_unit_on_state(tile_exists, is_grounded_value, type_hovering, tile_build_exists, unit_id)

func source_unit_update_floor_damage_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, floor_damage_taken: float, source_delta: float, hit_time: float, hit_duration: float) -> Dictionary:
	return source_unit_update_state.floor_damage_state(tile_exists, is_grounded_value, type_hovering, floor_damage_taken, source_delta, hit_time, hit_duration)

func source_unit_update_solid_tile_response_state(tile_exists: bool, can_pass_on_value: bool, type_can_boost: bool, current_elevation: float, net_client_value: bool, headless_value: bool, is_remote_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_state.solid_tile_response_state(tile_exists, can_pass_on_value, type_can_boost, current_elevation, net_client_value, headless_value, is_remote_value, unit_id)

func source_unit_update_ai_controller_server_gate_state(net_client_value: bool, dead_value: bool, should_update_controller_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_state.ai_controller_server_gate_state(net_client_value, dead_value, should_update_controller_value, unit_id)

func source_unit_update_invalid_controller_reset_state(controller_is_valid_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_state.invalid_controller_reset_state(controller_is_valid_value, unit_id)

func source_unit_update_spawned_core_despawn_state(spawned_by_core_value: bool, is_player_value: bool, dead_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_state.spawned_core_despawn_state(spawned_by_core_value, is_player_value, dead_value, unit_id)

func source_unit_update_drowning_state(floor_exists: bool, floor_is_liquid: bool, floor_drown_time: float, can_drown_value: bool, current_drown_time: float, source_delta: float, hit_size: float, type_drown_time_multiplier: float, chance_delta_result: bool, net_client: bool) -> Dictionary:
	return source_unit_update_state.drowning_state(floor_exists, floor_is_liquid, floor_drown_time, can_drown_value, current_drown_time, source_delta, hit_size, type_drown_time_multiplier, chance_delta_result, net_client)

func source_unit_update_type_hook_state() -> Dictionary:
	return source_unit_update_state.type_hook_state()

func source_unit_update_bounds_state(type_bounded: bool, world_unit_height: float, world_unit_width: float, rules_limit_map_area: bool, team_is_ai: bool, rules_limit_x: int, rules_limit_y: int, rules_limit_width: int, rules_limit_height: int, current_x: float, current_y: float, elevation_value: float, net_client: bool, is_local: bool, source_delta: float) -> Dictionary:
	return source_unit_update_state.bounds_state(type_bounded, world_unit_height, world_unit_width, rules_limit_map_area, team_is_ai, rules_limit_x, rules_limit_y, rules_limit_width, rules_limit_height, current_x, current_y, elevation_value, net_client, is_local, source_delta)

func source_unit_update_nan_health_state(current_health: float) -> Dictionary:
	return source_unit_update_state.nan_health_state(current_health)

func source_unit_update_flying_transition_state(is_flying_value: bool, was_flying_value: bool, tile_exists: bool, floor_is_liquid: bool, tile_floor_color: String) -> Dictionary:
	return source_unit_update_state.flying_transition_state(is_flying_value, was_flying_value, tile_exists, floor_is_liquid, tile_floor_color)

func source_unit_update_walk_effect_state(type_hovering: bool, elevation_value: float, type_emit_walk_effect: bool, type_emit_walk_sound: bool, current_splash_timer: float, delta_x: float, delta_y: float, hit_size_value: float, tile_exists: bool, tile_floor_color: String, floor_map_color: String, floor_walk_sound_pitch_min: float, floor_walk_sound_pitch_max: float, floor_walk_sound_volume: float, random_pitch_value: float) -> Dictionary:
	return source_unit_update_state.walk_effect_state(type_hovering, elevation_value, type_emit_walk_effect, type_emit_walk_sound, current_splash_timer, delta_x, delta_y, hit_size_value, tile_exists, tile_floor_color, floor_map_color, floor_walk_sound_pitch_min, floor_walk_sound_pitch_max, floor_walk_sound_volume, random_pitch_value)

func source_unit_move_pref_state(type_omni_movement: bool, movement_x: float, movement_y: float) -> Dictionary:
	return source_unit_update_state.move_pref_state(type_omni_movement, movement_x, movement_y)

func source_unit_floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:
	return source_unit_update_state.floor_speed_multiplier_state(elevation_value, type_hovering, floor_on_speed_multiplier, type_floor_multiplier, speed_multiplier_value)

func source_unit_unloaded_state(unit_state: Variant) -> Variant:
	return source_unit_update_state.unloaded_state(unit_state)

func source_unit_update_boosting_default_event_state(boost: bool) -> Dictionary:
	return source_unit_update_state.boosting_default_event_state(boost)

func source_unit_update_boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:
	return source_unit_update_state.boosting_guard_state(type_can_boost, dead_state, elevation_value)

func source_unit_update_boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:
	return source_unit_update_state.boosting_should_boost_state(boost, on_solid_result, elevation_value, can_land_result)

func source_unit_update_boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:
	return source_unit_update_state.boosting_elevation_state(current_elevation, type_can_boost, should_boost, type_rise_speed, type_descent_speed, source_delta)

func source_unit_update_boosting_event_state(event: bool) -> Dictionary:
	return source_unit_update_state.boosting_event_state(event)
