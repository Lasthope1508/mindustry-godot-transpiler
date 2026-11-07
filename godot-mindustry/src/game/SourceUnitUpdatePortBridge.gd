extends Node2D

const source_unit_update_module := preload("res://src/game/SourceUnitUpdateState.gd")
const source_unit_destroy_state := preload("res://src/game/SourceUnitDestroyState.gd")

func source_unit_remove_state(trail_exists: bool, trail_size: int, trail_width: float, type_trail_color_exists: bool, team_color: String, type_trail_color: String) -> Dictionary:
	return source_unit_destroy_state.remove_state(trail_exists, trail_size, trail_width, type_trail_color_exists, team_color, type_trail_color)

func source_unit_destroy_initial_payload_state(is_added_value: bool, killable_value: bool, item_explosiveness: float, item_flammability: float, item_charge: float, stack_amount: int) -> Dictionary:
	return source_unit_destroy_state.initial_payload_state(is_added_value, killable_value, item_explosiveness, item_flammability, item_charge, stack_amount)

func source_unit_destroy_explosion_dispatch_state(spawned_by_core_value: bool, source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, bounds_value: float, type_leg_length: float, rules_damage_explosions: bool, rules_unit_crash_damage: float, item_flammability: float, team_id: int, death_explosion_effect: String) -> Dictionary:
	return source_unit_destroy_state.explosion_dispatch_state(spawned_by_core_value, source_x, source_y, flammability, explosiveness, power, bounds_value, type_leg_length, rules_damage_explosions, rules_unit_crash_damage, item_flammability, team_id, death_explosion_effect)

func source_unit_destroy_visual_effects_state(source_x: float, source_y: float, hit_size: float, type_death_shake: float, type_create_scorch: bool, unit_id: int) -> Dictionary:
	return source_unit_destroy_state.visual_effects_state(source_x, source_y, hit_size, type_death_shake, type_create_scorch, unit_id)

func source_unit_destroy_sound_and_event_state(death_sound: String, death_sound_volume: float, unit_id: int) -> Dictionary:
	return source_unit_destroy_state.sound_and_event_state(death_sound, death_sound_volume, unit_id)

func source_unit_destroy_suicide_bomb_trigger_state(explosiveness: float, is_local_value: bool, was_player_value: bool) -> Dictionary:
	return source_unit_destroy_state.suicide_bomb_trigger_state(explosiveness, is_local_value, was_player_value)

func source_unit_destroy_shoot_on_death_mounts_state(mount_states: Array, has_target_value: bool, source_x: float, source_y: float, source_rotation_degrees: float, unit_id: int) -> Dictionary:
	return source_unit_destroy_state.shoot_on_death_mounts_state(mount_states, has_target_value, source_x, source_y, source_rotation_degrees, unit_id)

func source_unit_destroy_crash_landing_damage_state(type_flying: bool, spawned_by_core_value: bool, type_create_wreck: bool, rules_unit_crash_damage: float, hit_size: float, type_crash_damage_multiplier: float, shields_empty: bool, shield_absorbed: bool, team_id: int, source_x: float, source_y: float) -> Dictionary:
	return source_unit_destroy_state.crash_landing_damage_state(type_flying, spawned_by_core_value, type_create_wreck, rules_unit_crash_damage, hit_size, type_crash_damage_multiplier, shields_empty, shield_absorbed, team_id, source_x, source_y)

func source_unit_destroy_wreck_decal_state(headless_value: bool, type_create_scorch: bool, wreck_regions: Array, tmp_offsets: Array, source_x: float, source_y: float, source_rotation_degrees: float, type_hit_size: float) -> Dictionary:
	return source_unit_destroy_state.wreck_decal_state(headless_value, type_create_scorch, wreck_regions, tmp_offsets, source_x, source_y, source_rotation_degrees, type_hit_size)

func source_unit_destroy_ability_death_state(ability_states: Array, unit_id: int) -> Dictionary:
	return source_unit_destroy_state.ability_death_state(ability_states, unit_id)

func source_unit_destroy_type_killed_remove_state(unit_id: int) -> Dictionary:
	return source_unit_destroy_state.type_killed_remove_state(unit_id)

func source_unit_killed_state(is_local_value: bool, current_health: float, type_flying: bool, type_create_wreck: bool, wreck_sound: String, wreck_sound_volume: float, unit_id: int) -> Dictionary:
	return source_unit_destroy_state.killed_state(is_local_value, current_health, type_flying, type_create_wreck, wreck_sound, wreck_sound_volume, unit_id)

func source_unit_kill_sync_state(dead_value: bool, net_client: bool, killable_value: bool, unit_id: int) -> Dictionary:
	return source_unit_destroy_state.kill_sync_state(dead_value, net_client, killable_value, unit_id)

func source_unit_is_grounded(elevation_value: float) -> bool:
	return source_unit_update_module.is_grounded(elevation_value)

func source_unit_is_flying(elevation_value: float) -> bool:
	return source_unit_update_module.is_flying(elevation_value)

func source_unit_check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return source_unit_update_module.check_target_state(elevation_value, target_air, target_ground)

func source_unit_can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:
	return source_unit_update_module.can_drown_state(elevation_value, type_can_drown)

func source_unit_drown_floor_state(floor_on_value: Variant) -> Variant:
	return source_unit_update_module.drown_floor_state(floor_on_value)

func source_unit_wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int) -> Dictionary:
	return source_unit_update_module.game_wobble_state(self, current_x, current_y, source_time, source_delta, elevation_value, unit_id)

func source_unit_move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.game_move_at_state(self, vel_x, vel_y, vector_x, vector_y, acceleration, source_delta)

func source_unit_move_at_default_accel_state(vector_x: float, vector_y: float, type_accel: float) -> Dictionary:
	return source_unit_update_module.move_at_default_accel_state(vector_x, vector_y, type_accel)

func source_unit_approach_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, type_accel: float, speed_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.approach_state(vel_x, vel_y, vector_x, vector_y, type_accel, speed_value, source_delta)

func source_unit_rotate_move_motion_state(unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	return source_unit_update_module.game_rotate_move_motion_state(self, unit_rotation_degrees, vec_x, vec_y)

func source_unit_rotate_move_rotation_state(current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.game_rotate_move_rotation_state(self, current_rotation, vec_x, vec_y, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_aim_look_position_state(pos_x: float, pos_y: float) -> Dictionary:
	return source_unit_update_module.aim_look_position_state(pos_x, pos_y)

func source_unit_aim_look_xy_state(target_x: float, target_y: float) -> Dictionary:
	return source_unit_update_module.aim_look_xy_state(target_x, target_y)

func source_unit_look_at_angle_state(current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.game_look_at_angle_state(self, current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_look_at_position_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.game_look_at_position_state(self, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_look_at_xy_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.game_look_at_xy_state(self, current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta)

func source_unit_controller_predicates_state(controller_is_ai_controller: bool, controller_is_command_ai: bool) -> Dictionary:
	return source_unit_update_module.controller_predicates_state(controller_is_ai_controller, controller_is_command_ai)

func source_unit_can_target_state(other_exists: bool, other_is_unit: bool, other_unit_check_target_result: bool, other_is_building: bool, type_target_air: bool, type_target_ground: bool) -> Dictionary:
	return source_unit_update_module.can_target_state(other_exists, other_is_unit, other_unit_check_target_result, other_is_building, type_target_air, type_target_ground)

func source_unit_command_state(controller_is_command_ai: bool) -> Dictionary:
	return source_unit_update_module.command_state(controller_is_command_ai)

func source_unit_is_missile_state(unit_is_timed_killc: bool) -> Dictionary:
	return source_unit_update_module.is_missile_state(unit_is_timed_killc)

func source_unit_count_state(team_data_count_type_result: int, type_id: int) -> Dictionary:
	return source_unit_update_module.count_state(team_data_count_type_result, type_id)

func source_unit_cap_state(team_is_wave_team: bool, rules_pvp: bool, state_is_campaign: bool, rules_disable_unit_cap: bool, team_ignore_unit_cap: bool, rules_unit_cap_variable: bool, rules_unit_cap: int, team_data_unit_cap: int) -> Dictionary:
	return source_unit_update_module.cap_state(team_is_wave_team, rules_pvp, state_is_campaign, rules_disable_unit_cap, team_ignore_unit_cap, rules_unit_cap_variable, rules_unit_cap, team_data_unit_cap)

func source_unit_set_type_state(type_id: int, type_health: float, type_drag: float, type_armor: float, type_hit_size: float, mounts_length: int, type_weapons_size: int, abilities_length: int, type_abilities_size: int, first_ability_is_empty_data_ability: bool, controller_is_null: bool) -> Dictionary:
	return source_unit_update_module.set_type_state(type_id, type_health, type_drag, type_armor, type_hit_size, mounts_length, type_weapons_size, abilities_length, type_abilities_size, first_ability_is_empty_data_ability, controller_is_null)

func source_unit_player_controllable_state(type_player_controllable: bool, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_block_privileged: bool) -> Dictionary:
	return source_unit_update_module.player_controllable_state(type_player_controllable, controller_is_logic_ai, logic_controller_exists, logic_controller_block_privileged)

func source_unit_targetable_state(type_targetable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, targeter_id: int) -> Dictionary:
	return source_unit_update_module.targetable_state(type_targetable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, targeter_id)

func source_unit_killable_state(type_killable: bool) -> Dictionary:
	return source_unit_update_module.killable_state(type_killable)

func source_unit_hittable_state(type_hittable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool) -> Dictionary:
	return source_unit_update_module.hittable_state(type_hittable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload)

func source_unit_after_sync_state(type_id: int, controller_exists: bool) -> Dictionary:
	return source_unit_update_module.after_sync_state(type_id, controller_exists)

func source_unit_after_read_state(type_id: int, controller_is_ai_controller: bool, ai_keep_state: bool, controller_exists: bool) -> Dictionary:
	return source_unit_update_module.after_read_state(type_id, controller_is_ai_controller, ai_keep_state, controller_exists)

func source_unit_after_read_all_state(controller_exists: bool) -> Dictionary:
	return source_unit_update_module.after_read_all_state(controller_exists)

func source_unit_add_state(type_use_unit_cap: bool, count_after_add: int, cap_value: int, spawned_by_core: bool, dead: bool, rules_editor: bool) -> Dictionary:
	return source_unit_update_module.add_state(type_use_unit_cap, count_after_add, cap_value, spawned_by_core, dead, rules_editor)

func source_unit_landed_state(type_mech_land_shake: float) -> Dictionary:
	return source_unit_update_module.landed_state(type_mech_land_shake)

func source_unit_heal_state(current_health: float, max_health: float, amount: float, current_was_healed: bool) -> Dictionary:
	return source_unit_update_module.heal_state(current_health, max_health, amount, current_was_healed)

func source_unit_update_heal_time_state(was_healed_value: bool, current_heal_time: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.heal_time_state(was_healed_value, current_heal_time, source_delta)

func source_unit_update_captured_sector_death_state(team_is_only_ai: bool, state_is_campaign: bool, sector_is_captured: bool) -> Dictionary:
	return source_unit_update_module.captured_sector_death_state(team_is_only_ai, state_is_campaign, sector_is_captured)

func source_unit_update_sound_loop_state(headless_value: bool, type_loop_sound: String, type_loop_sound_volume: float, type_move_sound: String, type_move_sound_volume: float, type_move_sound_pitch_min: float, type_move_sound_pitch_max: float, velocity_x: float, velocity_y: float, type_speed: float) -> Dictionary:
	return source_unit_update_module.sound_loop_state(headless_value, type_loop_sound, type_loop_sound_volume, type_move_sound, type_move_sound_volume, type_move_sound_pitch_min, type_move_sound_pitch_max, velocity_x, velocity_y, type_speed)

func source_unit_update_unsupported_env_state(type_supports_env: bool, dead_value: bool) -> Dictionary:
	return source_unit_update_module.unsupported_env_state(type_supports_env, dead_value)

func source_unit_update_abilities_loop_state(ability_ids: Array) -> Dictionary:
	return source_unit_update_module.abilities_loop_state(ability_ids)

func source_unit_update_trail_position_state(trail_exists: bool, type_trail_length: int, type_use_engine_elevation: bool, elevation_value: float, type_engine_offset: float, x_value: float, y_value: float, source_rotation_degrees: float) -> Dictionary:
	return source_unit_update_module.trail_position_state(trail_exists, type_trail_length, type_use_engine_elevation, elevation_value, type_engine_offset, x_value, y_value, source_rotation_degrees)

func source_unit_update_drag_formula_state(type_drag: float, grounded_value: bool, floor_drag_multiplier: float, unit_drag_multiplier: float, rules_drag_multiplier: float) -> Dictionary:
	return source_unit_update_module.drag_formula_state(type_drag, grounded_value, floor_drag_multiplier, unit_drag_multiplier, rules_drag_multiplier)

func source_unit_update_spawn_knockback_state(team_is_wave_team: bool, state_has_spawns_value: bool, net_client_value: bool, is_local_value: bool, hittable_value: bool, drop_zone_radius: float, hit_size: float, unit_x: float, unit_y: float, spawns: Array, source_delta: float) -> Dictionary:
	return source_unit_update_module.spawn_knockback_state(team_is_wave_team, state_has_spawns_value, net_client_value, is_local_value, hittable_value, drop_zone_radius, hit_size, unit_x, unit_y, spawns, source_delta)

func source_unit_update_falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	return source_unit_update_module.falling_drag_state(dead_value, health_value, current_drag)

func source_unit_update_falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	return source_unit_update_module.falling_smoke_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, hit_size, tmp_v1_x, tmp_v1_y)

func source_unit_update_falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	return source_unit_update_module.falling_engine_trail_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, source_rotation_degrees, elevation_value, type_engine_offset, type_engine_size, engine_range_value, x_range_value, y_range_value, random_rotation_value)

func source_unit_update_falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	return source_unit_update_module.falling_descent_state(dead_value, health_value, elevation_value, type_fall_speed, source_delta, is_grounded_value, max_health, type_wreck_health_multiplier, unit_id)

func source_unit_update_tile_unit_on_any_state(tile_exists: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return source_unit_update_module.tile_unit_on_any_state(tile_exists, tile_build_exists, unit_id)

func source_unit_update_tile_unit_on_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return source_unit_update_module.tile_unit_on_state(tile_exists, is_grounded_value, type_hovering, tile_build_exists, unit_id)

func source_unit_update_floor_damage_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, floor_damage_taken: float, source_delta: float, hit_time: float, hit_duration: float) -> Dictionary:
	return source_unit_update_module.floor_damage_state(tile_exists, is_grounded_value, type_hovering, floor_damage_taken, source_delta, hit_time, hit_duration)

func source_unit_update_solid_tile_response_state(tile_exists: bool, can_pass_on_value: bool, type_can_boost: bool, current_elevation: float, net_client_value: bool, headless_value: bool, is_remote_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_module.solid_tile_response_state(tile_exists, can_pass_on_value, type_can_boost, current_elevation, net_client_value, headless_value, is_remote_value, unit_id)

func source_unit_update_ai_controller_server_gate_state(net_client_value: bool, dead_value: bool, should_update_controller_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_module.ai_controller_server_gate_state(net_client_value, dead_value, should_update_controller_value, unit_id)

func source_unit_update_invalid_controller_reset_state(controller_is_valid_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_module.invalid_controller_reset_state(controller_is_valid_value, unit_id)

func source_unit_update_spawned_core_despawn_state(spawned_by_core_value: bool, is_player_value: bool, dead_value: bool, unit_id: int) -> Dictionary:
	return source_unit_update_module.spawned_core_despawn_state(spawned_by_core_value, is_player_value, dead_value, unit_id)

func source_unit_update_drowning_state(floor_exists: bool, floor_is_liquid: bool, floor_drown_time: float, can_drown_value: bool, current_drown_time: float, source_delta: float, hit_size: float, type_drown_time_multiplier: float, chance_delta_result: bool, net_client: bool) -> Dictionary:
	return source_unit_update_module.drowning_state(floor_exists, floor_is_liquid, floor_drown_time, can_drown_value, current_drown_time, source_delta, hit_size, type_drown_time_multiplier, chance_delta_result, net_client)

func source_unit_update_type_hook_state() -> Dictionary:
	return source_unit_update_module.type_hook_state()

func source_unit_update_bounds_state(type_bounded: bool, world_unit_height: float, world_unit_width: float, rules_limit_map_area: bool, team_is_ai: bool, rules_limit_x: int, rules_limit_y: int, rules_limit_width: int, rules_limit_height: int, current_x: float, current_y: float, elevation_value: float, net_client: bool, is_local: bool, source_delta: float) -> Dictionary:
	return source_unit_update_module.bounds_state(type_bounded, world_unit_height, world_unit_width, rules_limit_map_area, team_is_ai, rules_limit_x, rules_limit_y, rules_limit_width, rules_limit_height, current_x, current_y, elevation_value, net_client, is_local, source_delta)

func source_unit_update_nan_health_state(current_health: float) -> Dictionary:
	return source_unit_update_module.nan_health_state(current_health)

func source_unit_update_flying_transition_state(is_flying_value: bool, was_flying_value: bool, tile_exists: bool, floor_is_liquid: bool, tile_floor_color: String) -> Dictionary:
	return source_unit_update_module.flying_transition_state(is_flying_value, was_flying_value, tile_exists, floor_is_liquid, tile_floor_color)

func source_unit_update_walk_effect_state(type_hovering: bool, elevation_value: float, type_emit_walk_effect: bool, type_emit_walk_sound: bool, current_splash_timer: float, delta_x: float, delta_y: float, hit_size_value: float, tile_exists: bool, tile_floor_color: String, floor_map_color: String, floor_walk_sound_pitch_min: float, floor_walk_sound_pitch_max: float, floor_walk_sound_volume: float, random_pitch_value: float) -> Dictionary:
	return source_unit_update_module.walk_effect_state(type_hovering, elevation_value, type_emit_walk_effect, type_emit_walk_sound, current_splash_timer, delta_x, delta_y, hit_size_value, tile_exists, tile_floor_color, floor_map_color, floor_walk_sound_pitch_min, floor_walk_sound_pitch_max, floor_walk_sound_volume, random_pitch_value)

func source_unit_move_pref_state(type_omni_movement: bool, movement_x: float, movement_y: float) -> Dictionary:
	return source_unit_update_module.move_pref_state(type_omni_movement, movement_x, movement_y)

func source_unit_floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:
	return source_unit_update_module.floor_speed_multiplier_state(elevation_value, type_hovering, floor_on_speed_multiplier, type_floor_multiplier, speed_multiplier_value)

func source_unit_unloaded_state(unit_state: Variant) -> Variant:
	return source_unit_update_module.unloaded_state(unit_state)

func source_unit_update_boosting_default_event_state(boost: bool) -> Dictionary:
	return source_unit_update_module.boosting_default_event_state(boost)

func source_unit_update_boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:
	return source_unit_update_module.boosting_guard_state(type_can_boost, dead_state, elevation_value)

func source_unit_update_boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:
	return source_unit_update_module.boosting_should_boost_state(boost, on_solid_result, elevation_value, can_land_result)

func source_unit_update_boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:
	return source_unit_update_module.boosting_elevation_state(current_elevation, type_can_boost, should_boost, type_rise_speed, type_descent_speed, source_delta)

func source_unit_update_boosting_event_state(event: bool) -> Dictionary:
	return source_unit_update_module.boosting_event_state(event)

func source_unit_physic_size(hit_size: float) -> float:
	return source_unit_update_module.physic_size(hit_size)

func source_unit_in_range(unit_x: float, unit_y: float, other_x: float, other_y: float, type_range: float) -> bool:
	return source_unit_update_module.in_range(unit_x, unit_y, other_x, other_y, type_range)

func source_unit_range_state(type_max_range: float) -> Dictionary:
	return source_unit_update_module.range_state(type_max_range)

func source_unit_clip_size_state(is_building: bool, infinite_resources: bool, type_clip_size: float, type_region_width: float, type_build_range: float, source_tilesize: float, is_mining: bool, type_mine_range: float) -> Dictionary:
	return source_unit_update_module.clip_size_state(is_building, infinite_resources, type_clip_size, type_region_width, type_build_range, source_tilesize, is_mining, type_mine_range)

func source_unit_sense_laccess_state(sensor: String, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	return source_unit_update_module.laccess_state(sensor, unit_state, source_tilesize)

func source_unit_sense_object_state(sensor: String, unit_state: Dictionary, no_sensed: Variant) -> Dictionary:
	return source_unit_update_module.sense_object_state(sensor, unit_state, no_sensed)

func source_unit_sense_content_state(content: Dictionary, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	return source_unit_update_module.sense_content_state(content, unit_state, source_tilesize)

func source_unit_set_prop_laccess_double_state(prop: String, value: float, unit_state: Dictionary, source_tilesize: float) -> Dictionary:
	return source_unit_update_module.set_prop_laccess_double_state(prop, value, unit_state, source_tilesize)

func source_unit_set_prop_laccess_object_state(prop: String, value: Variant, unit_state: Dictionary) -> Dictionary:
	return source_unit_update_module.set_prop_laccess_object_state(prop, value, unit_state)

func source_unit_set_prop_content_state(content: Dictionary, value: float, unit_state: Dictionary) -> Dictionary:
	return source_unit_update_module.set_prop_content_state(content, value, unit_state)

func source_unit_can_shoot_state(unit_state: Dictionary) -> Dictionary:
	return source_unit_update_module.can_shoot_state(unit_state)

func source_unit_is_enemy_state(unit_is_enemy: bool) -> Dictionary:
	return source_unit_update_module.is_enemy_state(unit_is_enemy)

func source_unit_collides_state(hittable: bool) -> Dictionary:
	return source_unit_update_module.collides_state(hittable)

func source_unit_item_capacity_state(type_item_capacity: int) -> Dictionary:
	return source_unit_update_module.item_capacity_state(type_item_capacity)

func source_unit_bounds_state(hit_size: float) -> Dictionary:
	return source_unit_update_module.unit_bounds_metric_state(hit_size)

func source_unit_collision_state(other_is_bullet: bool, bullet: Variant) -> Dictionary:
	return source_unit_update_module.collision_state(other_is_bullet, bullet)

func source_unit_controller_set_state(next_controller: Variant, controller_unit: Variant, self_unit: Variant) -> Dictionary:
	return source_unit_update_module.controller_set_state(next_controller, controller_unit, self_unit)

func source_unit_controller_get_state(controller: Variant) -> Dictionary:
	return source_unit_update_module.controller_get_state(controller)

func source_unit_get_controller_name_state(is_player: bool, player_colored_name: String, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_last_accessed: String) -> Dictionary:
	return source_unit_update_module.get_controller_name_state(is_player, player_colored_name, controller_is_logic_ai, logic_controller_exists, logic_controller_last_accessed)

func source_unit_display_state(table: Variant) -> Dictionary:
	return source_unit_update_module.display_state(table)

func source_unit_draw_state() -> Dictionary:
	return source_unit_update_module.draw_state()

func source_unit_is_player_state(controller_is_player: bool) -> Dictionary:
	return source_unit_update_module.is_player_state(controller_is_player)

func source_unit_get_player_state(controller_is_player: bool, controller: Variant) -> Dictionary:
	return source_unit_update_module.get_player_state(controller_is_player, controller)

func source_unit_to_string_state(unit_id: int, unit_type: Variant, unit_x: float, unit_y: float) -> Dictionary:
	return source_unit_update_module.to_string_state(unit_id, unit_type, unit_x, unit_y)

func source_unit_reset_controller_state(created_controller: Variant) -> Dictionary:
	return source_unit_update_module.reset_controller_state(created_controller)

func source_unit_set_state(current_type: Variant, definition: Variant, controller: Variant, controller_unit: Variant, self_unit: Variant) -> Dictionary:
	return source_unit_update_module.set_controller_state(current_type, definition, controller, controller_unit, self_unit)

func source_unit_collision_layer_state(type_allow_leg_step: bool, type_leg_physics_layer: bool, is_grounded: bool, layer_legs: int, layer_ground: int, layer_flying: int) -> Dictionary:
	return source_unit_update_module.collision_layer_state(type_allow_leg_step, type_leg_physics_layer, is_grounded, layer_legs, layer_ground, layer_flying)

func source_unit_has_weapons(weapons: Array) -> bool:
	return source_unit_update_module.has_weapons(weapons)

func source_unit_speed(elevation_value: float, grounded_value: bool, player_value: bool, velocity_angle: float, rotation_value: float, strafe_penalty_value: float, can_boost_value: bool, boost_multiplier_value: float, type_speed_value: float, floor_speed_multiplier_value: float) -> float:
	return source_unit_update_module.speed(elevation_value, grounded_value, player_value, velocity_angle, rotation_value, strafe_penalty_value, can_boost_value, boost_multiplier_value, type_speed_value, floor_speed_multiplier_value)

func source_unit_ammof_state() -> Dictionary:
	return source_unit_update_module.ammof_state()

func source_unit_displayable_state(type_hoverable: bool) -> Dictionary:
	return source_unit_update_module.displayable_state(type_hoverable)

func source_unit_is_sync_hidden_state(is_shooting_value: bool, in_fog_to_value: bool) -> Dictionary:
	return source_unit_update_module.is_sync_hidden_state(is_shooting_value, in_fog_to_value)

func source_unit_in_fog_to_state(same_team: bool, rules_fog: bool, hit_size: float, unit_x: float, unit_y: float, center_visible: bool, d8_visible: Array) -> Dictionary:
	return source_unit_update_module.in_fog_to_state(same_team, rules_fog, hit_size, unit_x, unit_y, center_visible, d8_visible)

func source_unit_handle_sync_hidden_state(unit_id: int) -> Dictionary:
	return source_unit_update_module.handle_sync_hidden_state(unit_id)

func source_unit_is_path_impassable_state(type_flying: bool, tile_x: int, tile_y: int, tile_in_bounds: bool, path_cost: int) -> Dictionary:
	return source_unit_update_module.is_path_impassable_state(type_flying, tile_x, tile_y, tile_in_bounds, path_cost)

func source_unit_can_land_state(unit_x: float, unit_y: float, physic_size: float, on_solid_result: bool, nearby_grounded_units_count: int) -> Dictionary:
	return source_unit_update_module.can_land_state(unit_x, unit_y, physic_size, on_solid_result, nearby_grounded_units_count)

func source_unit_pref_rotation_state(actively_building: bool, rotate_to_building: bool, build_plan_angle: float, mine_tile_exists: bool, mine_tile_angle: float, moving: bool, omni_movement: bool, velocity_angle: float, current_rotation: float) -> Dictionary:
	return source_unit_update_module.pref_rotation_state(actively_building, rotate_to_building, build_plan_angle, mine_tile_exists, mine_tile_angle, moving, omni_movement, velocity_angle, current_rotation)
func source_unit_update_state(context: Dictionary) -> Dictionary:
	return source_unit_update_module.update_state(context)
