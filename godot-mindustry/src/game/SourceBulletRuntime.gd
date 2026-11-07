extends RefCounted
class_name SourceBulletRuntime

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_bullet_removed_runtime_state := preload("res://src/game/SourceBulletRemovedRuntimeState.gd")
const source_bullet_type_create_state := preload("res://src/game/SourceBulletTypeCreateState.gd")
const source_bullet_type_create_splash_damage_state := preload("res://src/game/SourceBulletTypeCreateSplashDamageState.gd")
const source_bullet_type_create_incend_state := preload("res://src/game/SourceBulletTypeCreateIncendState.gd")
const source_bullet_type_create_frags_state := preload("res://src/game/SourceBulletTypeCreateFragsState.gd")
const source_bullet_type_create_puddles_state := preload("res://src/game/SourceBulletTypeCreatePuddlesState.gd")
const source_bullet_type_create_units_state := preload("res://src/game/SourceBulletTypeCreateUnitsState.gd")
const source_bullet_type_damage_state := preload("res://src/game/SourceBulletTypeDamageState.gd")
const source_bullet_type_init_state := preload("res://src/game/SourceBulletTypeInitState.gd")
const source_bullet_type_init_range_state := preload("res://src/game/SourceBulletTypeInitRangeState.gd")
const source_bullet_type_update_motion_state := preload("res://src/game/SourceBulletTypeUpdateMotionState.gd")
const source_bullet_type_update_state := preload("res://src/game/SourceBulletTypeUpdateState.gd")
const source_bullet_type_lifecycle_state := preload("res://src/game/SourceBulletTypeLifecycleState.gd")
const source_bullet_type_hit_core_state := preload("res://src/game/SourceBulletTypeHitCoreState.gd")
const source_bullet_type_hit_tile_state := preload("res://src/game/SourceBulletTypeHitTileState.gd")
const source_bullet_type_hit_state := preload("res://src/game/SourceBulletTypeHitState.gd")
const source_bullet_type_hit_entity_state := preload("res://src/game/SourceBulletTypeHitEntityState.gd")
const SOURCE_BULLET_VELOCITY_SPEED_FIELD := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_SPEED_FIELD
const SOURCE_BULLET_VELOCITY_INIT_VEL_CALL := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_INIT_VEL_CALL
const SOURCE_BULLET_VELOCITY_COMP_INIT_VEL_METHOD := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_COMP_INIT_VEL_METHOD
const SOURCE_BULLET_VELOCITY_COMP_TRNS := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_COMP_TRNS
const SOURCE_BULLET_VELOCITY_COMP_ROTATION := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_COMP_ROTATION
const SOURCE_BULLET_VELOCITY_VECTOR_FIELD := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_FIELD
const SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN
const SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE
const SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE := source_bullet_runtime_state.SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE

static func range_change(data: Dictionary, _defaults: source_bullet_defaults) -> float:
	return source_bullet_runtime_state.range_change(data)

static func inaccuracy(data: Dictionary, _defaults: source_bullet_defaults) -> float:
	return source_bullet_runtime_state.inaccuracy(data)

static func lifetime_seconds(data: Dictionary, _defaults: source_bullet_defaults, _tick_rate: float) -> float:
	return source_bullet_runtime_state.lifetime_seconds(data)

static func world_speed(data: Dictionary, _defaults: source_bullet_defaults, _tick_rate: float) -> float:
	return source_bullet_runtime_state.world_speed(data)

static func velocity(data: Dictionary, _defaults: source_bullet_defaults, _tick_rate: float, shoot_angle_degrees: float) -> Vector2:
	return source_bullet_runtime_state.velocity(data, shoot_angle_degrees)

static func velocity_vector_state(velocity_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_state.velocity_vector_state(velocity_state, Callable(SourceBulletRuntime, "arc_angles_trns_vec"))

static func create_keep_velocity_state(trail_add_state: Dictionary, bullet_type_state: Dictionary, owner_state: Dictionary, _defaults: source_bullet_defaults) -> Dictionary:
	return source_bullet_type_create_state.keep_velocity_state(trail_add_state, bullet_type_state, owner_state, Callable(SourceBulletRuntime, "arc_angles_trns_vec"))

static func init_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, _defaults: source_bullet_defaults) -> Dictionary:
	return source_bullet_type_init_state.init_initial_state(bullet_state, bullet_type_state, owner_health_state)

static func init_spawn_bullets_state(initial_state: Dictionary, bullet_type_state: Dictionary, spawn_bullet_random_offsets: Array) -> Dictionary:
	return source_bullet_type_init_state.init_spawn_bullets_state(initial_state, bullet_type_state, spawn_bullet_random_offsets)

static func update_dispatch_state(bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.update_dispatch_state(bullet_state)

static func update_bullet_interval_state(bullet_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, interval_random_offsets: Array) -> Dictionary:
	return source_bullet_type_update_state.update_bullet_interval_state(bullet_state, bullet_type_state, timer_get_result, interval_random_offsets)

static func update_trail_state(bullet_state: Dictionary, bullet_type_state: Dictionary, headless_value: bool, trail_interp_value: float, absin_value: float, source_delta: float) -> Dictionary:
	return source_bullet_type_update_state.update_trail_state(bullet_state, bullet_type_state, headless_value, trail_interp_value, absin_value, source_delta)

static func arc_angles_forward_distance(angle1: float, angle2: float) -> float:
	return source_math_state.source_angles_forward_distance(angle1, angle2)

static func arc_angles_backward_distance(angle1: float, angle2: float) -> float:
	return source_math_state.source_angles_backward_distance(angle1, angle2)

static func arc_mathf_mod_float(value: float, mod: float) -> float:
	return source_math_state.source_mod_float(value, mod)

static func arc_angles_angle_dist(angle_a: float, angle_b: float) -> float:
	return source_math_state.source_angles_angle_dist(angle_a, angle_b)

static func arc_angles_move_toward(angle: float, to: float, speed: float) -> float:
	return source_math_state.source_angles_move_toward(angle, to, speed)

static func arc_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	return source_math_state.source_angles_angle(from_x, from_y, to_x, to_y)

static func arc_angles_trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	return source_math_state.source_angles_trns_vec(angle_degrees, x_value, y_value)

static func update_homing_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.update_homing_initial_state(bullet_state, bullet_type_state)

static func update_homing_target_velocity_state(homing_initial_state: Dictionary, target_state: Variant, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.update_homing_target_velocity_state(homing_initial_state, target_state, source_delta, Callable(SourceBulletRuntime, "arc_angles_angle"), Callable(SourceBulletRuntime, "arc_angles_move_toward"), Callable(SourceBulletRuntime, "arc_angles_trns_vec"))

static func update_homing_follow_aim_state(homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.update_homing_follow_aim_state(homing_target_velocity_state, bullet_type_state, shooter_state, source_delta, Callable(SourceBulletRuntime, "arc_angles_angle"), Callable(SourceBulletRuntime, "arc_angles_move_toward"), Callable(SourceBulletRuntime, "arc_angles_trns_vec"))

static func update_weaving_state(bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.update_weaving_state(bullet_state, bullet_type_state, random_seed_result, source_delta, Callable(SourceBulletRuntime, "arc_angles_angle"))

static func update_weaving_rotate_speed_state(weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.update_weaving_rotate_speed_state(weaving_state, bullet_type_state, source_delta, Callable(SourceBulletRuntime, "arc_angles_angle"))

static func vec2_limit(vector_state: Dictionary, limit: float) -> Dictionary:
	return source_math_state.source_vec2_limit(vector_state, limit)

static func update_weaving_circle_shooter_state(rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
	return source_bullet_type_update_motion_state.update_weaving_circle_shooter_state(rotate_speed_state, bullet_type_state, owner_health_state, source_delta, Callable(SourceBulletRuntime, "vec2_limit"), Callable(SourceBulletRuntime, "arc_angles_angle"))

static func rotation_degrees(bullet_state: Dictionary) -> float:
	return source_bullet_type_update_state.bullet_rotation_degrees(bullet_state, Callable(SourceBulletRuntime, "arc_angles_angle"))

static func update_trail_effects_chance_state(bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.update_trail_effects_chance_state(bullet_state, bullet_type_state, chance_delta_result, random_offset_state, Callable(SourceBulletRuntime, "rotation_degrees"))

static func update_trail_effects_interval_state(chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary) -> Dictionary:
	return source_bullet_type_update_state.update_trail_effects_interval_state(chance_state, bullet_type_state, timer_get_result, random_offset_state, Callable(SourceBulletRuntime, "rotation_degrees"))

static func init_type_defaults_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_type_defaults_state(bullet_type_state)

static func init_frag_velocity_state(type_defaults_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_frag_velocity_state(type_defaults_state)

static func init_lightning_type_state(frag_velocity_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_lightning_type_state(frag_velocity_state)

static func init_light_radius_state(lightning_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_light_radius_state(lightning_type_state)

static func init_draw_size_state(light_radius_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.init_draw_size_state(light_radius_state)

static func init_range_assignment_state(draw_size_state: Dictionary, calculate_range_result: float) -> Dictionary:
	return source_bullet_type_init_range_state.init_range_assignment_state(draw_size_state, calculate_range_result)

static func calculate_range_override_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_override_state(bullet_type_state)

static func calculate_range_spawn_unit_state(override_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_spawn_unit_state(override_state)

static func calculate_range_despawn_unit_state(spawn_unit_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_despawn_unit_state(spawn_unit_state)

static func calculate_range_fallback_state(despawn_unit_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.calculate_range_fallback_state(despawn_unit_state)

static func continuous_damage_default_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_init_range_state.continuous_damage_default_state(bullet_type_state)

static func heals_state(bullet_type_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.heals_state(bullet_type_state)

static func test_collision_state(bullet_type_state: Dictionary, bullet_state: Dictionary, tile_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.test_collision_state(bullet_type_state, bullet_state, tile_state)

static func hit_tile_fire_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_fire_state(bullet_type_state, bullet_state, build_state)

static func hit_tile_heal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_heal_state(bullet_type_state, bullet_state, build_state)

static func hit_tile_enemy_direct_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_enemy_direct_state(bullet_type_state, bullet_state, build_state, hit_tile_state)

static func hit_tile_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.hit_tile_lifesteal_state(bullet_type_state, bullet_state, build_state, hit_tile_state, owner_health_state)

static func handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, pierce_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_tile_state.handle_pierce_state(bullet_type_state, bullet_state, pierce_state)

static func damage_multiplier_state(bullet_state: Dictionary, bullet_owner_state: Dictionary, rules_state: Dictionary) -> Dictionary:
	return source_bullet_type_damage_state.damage_multiplier_state(bullet_state, bullet_owner_state, rules_state)

static func hit_entity_damage_cap_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_damage_cap_state(bullet_type_state, bullet_state, entity_state, hit_entity_state)

static func hit_entity_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_lifesteal_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, owner_health_state)

static func hit_entity_armor_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, lifesteal_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_armor_damage_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, lifesteal_state)

static func hit_entity_unit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, armor_damage_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_unit_effects_state(bullet_type_state, bullet_state, entity_state, armor_damage_state)

static func hit_entity_unit_destroy_event_state(bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_effects_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_unit_destroy_event_state(bullet_state, entity_state, damage_cap_state, unit_effects_state)

static func hit_entity_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_destroy_event_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_entity_state.entity_handle_pierce_state(bullet_type_state, bullet_state, entity_state, damage_cap_state, unit_destroy_event_state, Callable(SourceBulletRuntime, "handle_pierce_state"))

static func hit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_effects_state(bullet_type_state, bullet_state, hit_xy_state)

static func hit_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_frag_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, hit_frag_state)

static func hit_post_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, incoming_hit_frag_dispatch_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_post_frag_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, incoming_hit_frag_dispatch_state)

static func create_incend_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_incend_state: Dictionary, incend_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_incend_state.create_state(bullet_type_state, bullet_state, incoming_create_incend_state, incend_random_state)

static func hit_suppression_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, incoming_hit_post_frag_dispatch_state: Dictionary, _source_tick_rate: float) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_suppression_state(bullet_type_state, bullet_state, hit_xy_state, incoming_hit_post_frag_dispatch_state)

static func hit_splash_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, incoming_hit_suppression_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_core_state.hit_splash_damage_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, incoming_hit_suppression_state)

static func create_splash_damage_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_hit_splash_damage_dispatch_state: Dictionary, incoming_damage_multiplier_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.damage_dispatch_state(bullet_type_state, bullet_state, incoming_hit_splash_damage_dispatch_state, incoming_damage_multiplier_state)

static func create_splash_damage_status_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_splash_damage_damage_dispatch_state: Dictionary, source_tick_rate: float) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.status_dispatch_state(bullet_type_state, bullet_state, incoming_create_splash_damage_damage_dispatch_state, source_tick_rate)

static func create_splash_damage_heal_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_splash_damage_status_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.heal_dispatch_state(bullet_type_state, bullet_state, incoming_create_splash_damage_status_dispatch_state, nearby_blocks_state)

static func create_splash_damage_make_fire_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_splash_damage_heal_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_splash_damage_state.make_fire_dispatch_state(bullet_type_state, bullet_state, incoming_create_splash_damage_heal_dispatch_state, nearby_blocks_state)

static func create_frags_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.initial_state(bullet_type_state, bullet_state, create_frags_state)

static func create_frags_random_geometry_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_frags_initial_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.random_geometry_state(bullet_type_state, bullet_state, incoming_create_frags_initial_state, frag_random_state)

static func create_frags_create_call_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_frags_random_geometry_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.create_call_state(bullet_type_state, bullet_state, incoming_create_frags_random_geometry_state, frag_random_state, Callable(SourceBulletRuntime, "arc_angles_trns_vec"))

static func create_frags_increment_state(bullet_state: Dictionary, incoming_create_frags_create_call_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_frags_state.increment_state(bullet_state, incoming_create_frags_create_call_state)

static func create_puddles_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_puddles_state.initial_state(bullet_type_state, bullet_state, create_puddles_state)

static func create_units_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_units_state: Dictionary, create_units_random_state: Dictionary, net_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.initial_state(bullet_type_state, bullet_state, incoming_create_units_state, create_units_random_state, net_state)

static func create_units_random_offset_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_units_initial_state: Dictionary, create_units_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.random_offset_state(bullet_type_state, bullet_state, incoming_create_units_initial_state, create_units_random_state)

static func create_units_spawn_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_units_random_offset_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.spawn_state(bullet_type_state, bullet_state, incoming_create_units_random_offset_state)

static func create_units_rotation_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_units_spawn_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.rotation_state(bullet_type_state, bullet_state, incoming_create_units_spawn_state)

static func create_units_notify_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_units_rotation_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_units_state.notify_state(bullet_type_state, bullet_state, incoming_create_units_rotation_state)

static func despawned_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_dispatch_state(bullet_type_state, bullet_state)

static func despawned_effect_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_despawned_dispatch_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_effect_state(bullet_type_state, bullet_state, incoming_despawned_dispatch_state)

static func despawned_sound_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_despawned_effect_state: Dictionary, despawn_sound_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_sound_state(bullet_type_state, bullet_state, incoming_despawned_effect_state, despawn_sound_random_state)

static func despawned_shake_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_despawned_sound_state: Dictionary) -> Dictionary:
	return source_bullet_type_lifecycle_state.despawned_shake_state(bullet_type_state, bullet_state, incoming_despawned_sound_state)

static func create_puddles_tile_world_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_puddles_initial_state: Dictionary, puddle_random_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_puddles_state.tile_world_state(bullet_type_state, bullet_state, incoming_create_puddles_initial_state, puddle_random_state)

static func create_puddles_deposit_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_create_puddles_tile_world_state: Dictionary) -> Dictionary:
	return source_bullet_type_create_puddles_state.deposit_state(bullet_type_state, bullet_state, incoming_create_puddles_tile_world_state)

static func removed_trail_fade_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return source_bullet_removed_runtime_state.removed_trail_fade_state(bullet_type_state, bullet_state)

static func removed_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, incoming_removed_trail_fade_state: Dictionary) -> Dictionary:
	return source_bullet_removed_runtime_state.removed_frag_dispatch_state(bullet_type_state, bullet_state, incoming_removed_trail_fade_state)

static func hit_size(data: Dictionary, _defaults: source_bullet_defaults) -> float:
	return source_bullet_runtime_state.hit_size(data)

static func damage(data: Dictionary, _defaults: source_bullet_defaults) -> float:
	return source_bullet_runtime_state.damage(data)

static func ammo_multiplier(data: Dictionary, _defaults: source_bullet_defaults) -> float:
	return source_bullet_runtime_state.ammo_multiplier(data)

static func reload_multiplier(data: Dictionary, _defaults: source_bullet_defaults) -> float:
	return source_bullet_runtime_state.reload_multiplier(data)

static func scale(data: Dictionary, _defaults: source_bullet_defaults, texture_size: Vector2) -> Vector2:
	return source_bullet_runtime_state.scale(data, texture_size)
