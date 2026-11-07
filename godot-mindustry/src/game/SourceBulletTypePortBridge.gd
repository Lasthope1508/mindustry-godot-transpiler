extends "res://src/game/SourceBulletRuntimePortBridge.gd"

const source_bullet_type_create_state := preload("res://src/game/SourceBulletTypeCreateState.gd")
const source_bullet_type_create_incend_state_script := preload("res://src/game/SourceBulletTypeCreateIncendState.gd")
const source_bullet_type_create_units_state := preload("res://src/game/SourceBulletTypeCreateUnitsState.gd")
const source_bullet_type_create_splash_damage_state := preload("res://src/game/SourceBulletTypeCreateSplashDamageState.gd")
const source_bullet_type_create_frags_state := preload("res://src/game/SourceBulletTypeCreateFragsState.gd")
const source_bullet_type_create_puddles_state := preload("res://src/game/SourceBulletTypeCreatePuddlesState.gd")
const source_bullet_type_hit_state := preload("res://src/game/SourceBulletTypeHitState.gd")
const source_bullet_type_hit_entity_state := preload("res://src/game/SourceBulletTypeHitEntityState.gd")
const source_bullet_type_draw_state_script := preload("res://src/game/SourceBulletTypeDrawState.gd")
const source_bullet_type_damage_state := preload("res://src/game/SourceBulletTypeDamageState.gd")
const source_bullet_type_lifecycle_state := preload("res://src/game/SourceBulletTypeLifecycleState.gd")
const source_bullet_type_hit_core_state := preload("res://src/game/SourceBulletTypeHitCoreState.gd")
const source_bullet_type_hit_tile_state := preload("res://src/game/SourceBulletTypeHitTileState.gd")
const source_bullet_type_init_range_state := preload("res://src/game/SourceBulletTypeInitRangeState.gd")
const source_bullet_type_init_state := preload("res://src/game/SourceBulletTypeInitState.gd")
const source_bullet_type_update_state := preload("res://src/game/SourceBulletTypeUpdateState.gd")
const source_bullet_type_update_motion_state := preload("res://src/game/SourceBulletTypeUpdateMotionState.gd")

func source_bullet_type_create_initial_gate_state(create_call_state: Dictionary, bullet_type_state: Dictionary, random_angle_offset: float, create_chance_roll: float) -> Dictionary:
	return source_bullet_type_create_state.initial_gate_state(create_call_state, bullet_type_state, random_angle_offset, create_chance_roll)

func source_bullet_type_create_spawn_unit_state(initial_gate_state: Dictionary, bullet_type_state: Dictionary, net_client: bool, owner_health_state: Dictionary, shooter_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_state.spawn_unit_state(initial_gate_state, bullet_type_state, net_client, owner_health_state, shooter_state)

func source_bullet_type_create_bullet_identity_state(create_call_state: Dictionary, initial_gate_state: Dictionary, spawn_unit_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_state.bullet_identity_state(create_call_state, initial_gate_state, spawn_unit_state, bullet_type_state)

func source_bullet_type_create_aim_state(identity_state: Dictionary, create_call_state: Dictionary, target_state: Dictionary, world_tile_from_aim: Variant) -> Dictionary:
	return source_bullet_type_create_state.aim_state(identity_state, create_call_state, target_state, world_tile_from_aim)

func source_bullet_type_create_velocity_position_state(aim_state: Dictionary, initial_gate_state: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, velocity_scale_random_factor: float) -> Dictionary:
	return source_bullet_type_create_state.velocity_position_state(aim_state, initial_gate_state, create_call_state, bullet_type_state, velocity_scale_random_factor)

func source_bullet_type_create_lifetime_payload_damage_state(velocity_position_state: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, life_scale_random_factor: float, damage_multiplier_factor: float) -> Dictionary:
	return source_bullet_type_create_state.lifetime_payload_damage_state(velocity_position_state, create_call_state, bullet_type_state, life_scale_random_factor, damage_multiplier_factor)

func source_bullet_type_create_trail_add_state(lifetime_payload_damage_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_state.trail_add_state(lifetime_payload_damage_state)

func source_bullet_velocity_vector_state(velocity_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_state.game_velocity_vector_state(self, velocity_state)

func source_bullet_type_create_keep_velocity_state(trail_add_state: Dictionary, bullet_type_state: Dictionary, owner_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_state.game_keep_velocity_state(self, trail_add_state, bullet_type_state, owner_state)

func source_bullet_type_init_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_state.init_initial_state(bullet_state, bullet_type_state, owner_health_state)

func source_bullet_type_init_spawn_bullets_state(init_initial_state: Dictionary, bullet_type_state: Dictionary, spawn_bullet_random_offsets: Array) -> Dictionary:
	return source_bullet_type_init_state.init_spawn_bullets_state(init_initial_state, bullet_type_state, spawn_bullet_random_offsets)

func source_bullet_type_update_dispatch_state(bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.update_dispatch_state(bullet_state)

func source_bullet_type_update_bullet_interval_state(bullet_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, interval_random_offsets: Array) -> Dictionary:
	return source_bullet_type_update_state.update_bullet_interval_state(bullet_state, bullet_type_state, timer_get_result, interval_random_offsets)

func source_bullet_type_update_trail_state(bullet_state: Dictionary, bullet_type_state: Dictionary, headless_value: bool, trail_interp_value: float, absin_value: float, source_delta: float) -> Dictionary:
	return source_bullet_type_update_state.update_trail_state(bullet_state, bullet_type_state, headless_value, trail_interp_value, absin_value, source_delta)

func source_bullet_type_update_homing_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.update_homing_initial_state(bullet_state, bullet_type_state)

func source_bullet_type_update_homing_target_velocity_state(homing_initial_state: Dictionary, target_state: Variant, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.game_update_homing_target_velocity_state(self, homing_initial_state, target_state, source_delta)

func source_bullet_type_update_homing_follow_aim_state(homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.game_update_homing_follow_aim_state(self, homing_target_velocity_state, bullet_type_state, shooter_state, source_delta)

func source_bullet_type_update_weaving_state(bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.game_update_weaving_state(self, bullet_state, bullet_type_state, random_seed_result, source_delta)

func source_bullet_type_update_weaving_rotate_speed_state(weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.game_update_weaving_rotate_speed_state(self, weaving_state, bullet_type_state, source_delta)

func source_bullet_type_update_weaving_circle_shooter_state(rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.game_update_weaving_circle_shooter_state(self, rotate_speed_state, bullet_type_state, owner_health_state, source_delta)

func source_bullet_rotation_degrees(bullet_state: Dictionary) -> float:
	return source_bullet_type_update_state.game_bullet_rotation_degrees(self, bullet_state)

func source_building_delta(source_delta: float, time_scale: float) -> float:
	return source_building_time_state.delta(source_delta, time_scale)

func source_building_edelta(source_delta: float, time_scale: float, efficiency: float) -> float:
	return source_building_time_state.edelta(source_delta, time_scale, efficiency)

func source_bullet_type_update_trail_effects_chance_state(bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.game_update_trail_effects_chance_state(self, bullet_state, bullet_type_state, chance_delta_result, random_offset_state)

func source_bullet_type_update_trail_effects_interval_state(chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.game_update_trail_effects_interval_state(self, chance_state, bullet_type_state, timer_get_result, random_offset_state)

func source_bullet_type_init_type_defaults_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_type_defaults_state(bullet_type_state)

func source_bullet_type_init_frag_velocity_state(type_defaults_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_frag_velocity_state(type_defaults_state)

func source_bullet_type_init_lightning_type_state(frag_velocity_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_lightning_type_state(frag_velocity_state)

func source_bullet_type_init_light_radius_state(lightning_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_light_radius_state(lightning_type_state)

func source_bullet_type_init_draw_size_state(light_radius_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_draw_size_state(light_radius_state)

func source_bullet_type_init_range_assignment_state(draw_size_state: Dictionary, calculate_range_result: float) -> Dictionary:
	return source_bullet_type_init_range_state.init_range_assignment_state(draw_size_state, calculate_range_result)

func source_bullet_type_calculate_range_override_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_override_state(bullet_type_state)

func source_bullet_type_calculate_range_spawn_unit_state(override_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_spawn_unit_state(override_state)

func source_bullet_type_calculate_range_despawn_unit_state(spawn_unit_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_despawn_unit_state(spawn_unit_state)

func source_bullet_type_calculate_range_fallback_state(despawn_unit_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_fallback_state(despawn_unit_state)

func source_bullet_type_continuous_damage_default_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.continuous_damage_default_state(bullet_type_state)

func source_bullet_type_heals_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.heals_state(bullet_type_state)

func source_bullet_type_test_collision_state(bullet_type_state: Dictionary, bullet_state: Dictionary, tile_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.test_collision_state(bullet_type_state, bullet_state, tile_state)

func source_bullet_type_hit_tile_fire_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_fire_state(bullet_type_state, bullet_state, build_state)

func source_bullet_type_hit_tile_heal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_heal_state(bullet_type_state, bullet_state, build_state)

func source_bullet_type_hit_tile_enemy_direct_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_enemy_direct_state(bullet_type_state, bullet_state, build_state, hit_tile_state)

func source_bullet_type_hit_tile_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_lifesteal_state(bullet_type_state, bullet_state, build_state, hit_tile_state, owner_health_state)

func source_bullet_type_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, pierce_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.handle_pierce_state(bullet_type_state, bullet_state, pierce_state)

func source_bullet_type_damage_multiplier_state(bullet_state: Dictionary, bullet_owner_state: Dictionary, rules_state: Dictionary) -> Dictionary:
	return source_bullet_type_damage_state.damage_multiplier_state(bullet_state, bullet_owner_state, rules_state)

func source_bullet_type_hit_default_state(bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_default_state(bullet_state)

func source_bullet_type_hit_xy_default_state(bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_xy_default_state(bullet_state, hit_xy_state)

func source_bullet_type_hit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_effects_state(bullet_type_state, bullet_state, hit_xy_state)

func source_bullet_type_hit_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_frag_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, hit_frag_state)

func source_bullet_type_hit_post_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_dispatch_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_post_frag_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, hit_frag_dispatch_state)

func source_bullet_type_create_incend_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_incend_state: Dictionary, incend_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_incend_state_script.create_state(bullet_type_state, bullet_state, create_incend_state, incend_random_state)

func source_bullet_type_create_units_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_state: Dictionary, create_units_random_state: Dictionary, net_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.initial_state(bullet_type_state, bullet_state, create_units_state, create_units_random_state, net_state)

func source_bullet_type_create_units_random_offset_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_initial_state: Dictionary, create_units_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.random_offset_state(bullet_type_state, bullet_state, create_units_initial_state, create_units_random_state)

func source_bullet_type_create_units_spawn_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_random_offset_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.spawn_state(bullet_type_state, bullet_state, create_units_random_offset_state)

func source_bullet_type_create_units_rotation_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_spawn_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.rotation_state(bullet_type_state, bullet_state, create_units_spawn_state)

func source_bullet_type_create_units_notify_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_rotation_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.notify_state(bullet_type_state, bullet_state, create_units_rotation_state)

func source_bullet_type_despawned_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_dispatch_state(bullet_type_state, bullet_state)

func source_bullet_type_despawned_effect_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_dispatch_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_effect_state(bullet_type_state, bullet_state, despawned_dispatch_state)

func source_bullet_type_despawned_sound_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_effect_state: Dictionary, despawn_sound_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_sound_state(bullet_type_state, bullet_state, despawned_effect_state, despawn_sound_random_state)

func source_bullet_type_despawned_shake_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_sound_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_shake_state(bullet_type_state, bullet_state, despawned_sound_state)

func source_bullet_type_removed_trail_fade_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.removed_trail_fade_state(bullet_type_state, bullet_state)

func source_bullet_type_removed_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, removed_trail_fade_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.removed_frag_dispatch_state(bullet_type_state, bullet_state, removed_trail_fade_state)

func source_bullet_type_hit_suppression_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_post_frag_dispatch_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_suppression_state(bullet_type_state, bullet_state, hit_xy_state, hit_post_frag_dispatch_state)

func source_bullet_type_hit_splash_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_suppression_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_splash_damage_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, hit_suppression_state)

func source_bullet_type_create_splash_damage_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_splash_damage_dispatch_state: Dictionary, damage_multiplier_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.damage_dispatch_state(bullet_type_state, bullet_state, hit_splash_damage_dispatch_state, damage_multiplier_state)

func source_bullet_type_create_splash_damage_status_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_damage_dispatch_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.status_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_damage_dispatch_state)

func source_bullet_type_create_splash_damage_heal_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_status_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.heal_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_status_dispatch_state, nearby_blocks_state)

func source_bullet_type_create_splash_damage_make_fire_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_heal_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.make_fire_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_heal_dispatch_state, nearby_blocks_state)

func source_bullet_type_create_frags_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.initial_state(bullet_type_state, bullet_state, create_frags_state)

func source_bullet_type_create_frags_random_geometry_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_initial_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.random_geometry_state(bullet_type_state, bullet_state, create_frags_initial_state, frag_random_state)

func source_bullet_type_create_frags_create_call_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_random_geometry_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.game_create_call_state(self, bullet_type_state, bullet_state, create_frags_random_geometry_state, frag_random_state)

func source_bullet_type_create_frags_increment_state(bullet_state: Dictionary, create_frags_create_call_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.increment_state(bullet_state, create_frags_create_call_state)

func source_bullet_type_create_puddles_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_puddles_state.initial_state(bullet_type_state, bullet_state, create_puddles_state)

func source_bullet_type_create_puddles_tile_world_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_initial_state: Dictionary, puddle_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_puddles_state.tile_world_state(bullet_type_state, bullet_state, create_puddles_initial_state, puddle_random_state)

func source_bullet_type_create_puddles_deposit_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_tile_world_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_puddles_state.deposit_state(bullet_type_state, bullet_state, create_puddles_tile_world_state)

func source_bullet_type_hit_entity_damage_cap_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_damage_cap_state(bullet_type_state, bullet_state, entity_state, hit_entity_state)
func source_bullet_type_hit_entity_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_lifesteal_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, owner_health_state)
func source_bullet_type_hit_entity_armor_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, lifesteal_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_armor_damage_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, lifesteal_state)
func source_bullet_type_hit_entity_unit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, armor_damage_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_unit_effects_state(bullet_type_state, bullet_state, entity_state, armor_damage_state)
func source_bullet_type_hit_entity_unit_destroy_event_state(bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_effects_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_unit_destroy_event_state(bullet_state, entity_state, damage_cap_state, unit_effects_state)
func source_bullet_type_hit_entity_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_destroy_event_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_state.game_entity_handle_pierce_state(self, bullet_type_state, bullet_state, entity_state, damage_cap_state, unit_destroy_event_state)
func source_bullet_type_building_damage_state(bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_damage_state.building_damage_state(bullet_state)

func source_bullet_type_shield_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_damage_state.shield_damage_state(bullet_type_state, bullet_state)

func source_bullet_type_draw_state(bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_draw_state_script.draw_state(bullet_state)

func source_bullet_type_draw_trail_state(bullet_type_state: Dictionary, bullet_state: Dictionary, current_draw_z: float) -> Dictionary:
	return source_bullet_type_draw_state_script.draw_trail_state(bullet_type_state, bullet_state, current_draw_z)

func source_bullet_type_draw_parts_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_draw_state_script.draw_parts_state(bullet_type_state, bullet_state)

func source_bullet_type_draw_light_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_draw_state_script.draw_light_state(bullet_type_state, bullet_state)
