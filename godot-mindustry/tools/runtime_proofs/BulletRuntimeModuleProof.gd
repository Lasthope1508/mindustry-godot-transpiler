extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_bullet_spawn_state := preload("res://src/game/SourceBulletSpawnState.gd")
const source_bullet_target_runtime_state := preload("res://src/game/SourceBulletTargetRuntimeState.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")
const source_bullet_type_create_state := preload("res://src/game/SourceBulletTypeCreateState.gd")
const source_bullet_type_damage_state := preload("res://src/game/SourceBulletTypeDamageState.gd")
const source_bullet_type_lifecycle_state := preload("res://src/game/SourceBulletTypeLifecycleState.gd")
const source_bullet_type_init_state := preload("res://src/game/SourceBulletTypeInitState.gd")
const source_bullet_type_update_motion_state := preload("res://src/game/SourceBulletTypeUpdateMotionState.gd")
const source_bullet_type_update_state := preload("res://src/game/SourceBulletTypeUpdateState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_bullet_type_hit_core_state := preload("res://src/game/SourceBulletTypeHitCoreState.gd")
const source_bullet_type_hit_tile_state := preload("res://src/game/SourceBulletTypeHitTileState.gd")
const source_bullet_type_hit_state := preload("res://src/game/SourceBulletTypeHitState.gd")
const source_bullet_type_hit_entity_state := preload("res://src/game/SourceBulletTypeHitEntityState.gd")
const source_bullet_type_init_range_state := preload("res://src/game/SourceBulletTypeInitRangeState.gd")
const source_bullet_type_create_splash_damage_state := preload("res://src/game/SourceBulletTypeCreateSplashDamageState.gd")
const source_bullet_type_create_incend_state := preload("res://src/game/SourceBulletTypeCreateIncendState.gd")
const source_bullet_type_create_frags_state := preload("res://src/game/SourceBulletTypeCreateFragsState.gd")
const source_bullet_type_create_puddles_state := preload("res://src/game/SourceBulletTypeCreatePuddlesState.gd")
const source_bullet_type_create_units_state := preload("res://src/game/SourceBulletTypeCreateUnitsState.gd")
const source_bullet_removed_runtime_state := preload("res://src/game/SourceBulletRemovedRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var bullet_defaults := source_bullet_defaults.new(source_ssot_accessor_runtime_state)
	game.bullets = []
	game.bullet_hit_count = 0
	var proof_spawn_data := {"damage": 1.0, "speed": 1.0, "sprite": "bullet"}
	var proof_spawn_texture_size := Vector2(5, 7)
	var spawn_state := source_bullet_runtime_state.spawn_state(proof_spawn_data, 0.0, proof_spawn_texture_size)
	var spawn_shard_state := source_bullet_spawn_state.spawn_state_from_values(str(proof_spawn_data.get("ammo_item", proof_spawn_data.get("item", ""))), source_bullet_runtime_state.damage(proof_spawn_data), source_bullet_runtime_state.reload_multiplier(proof_spawn_data), source_bullet_runtime_state.velocity(proof_spawn_data, 0.0), source_bullet_runtime_state.world_speed(proof_spawn_data), source_bullet_runtime_state.hit_size(proof_spawn_data), source_bullet_runtime_state.lifetime_seconds(proof_spawn_data), str(proof_spawn_data.get("sprite", source_bullet_runtime_state.SOURCE_BULLET_TEXTURE_DEFAULT)), source_bullet_runtime_state.scale(proof_spawn_data, proof_spawn_texture_size))
	var runtime_context := source_bullet_runtime_state.target_step_context(game, {"sprite": null, "target": null, "velocity": Vector2.ZERO, "damage": 1.0, "hitSize": 4.0, "lifetime_remaining": 1.0}, 0.1)
	var target_step_from_context := source_bullet_runtime_state.target_step_from_context(runtime_context)
	var target_step_state := source_bullet_runtime_state.target_step_state(Vector2.ZERO, Vector2.ZERO, 0.1, Vector2.ZERO, 1.0, 4.0, 1.0, 1.0)
	var target_step_shard_state := source_bullet_target_runtime_state.target_step_state(Vector2.ZERO, Vector2.ZERO, 0.1, Vector2.ZERO, 1.0, 4.0, 1.0, 1.0)
	var runtime_step := source_bullet_runtime_state.runtime_step_from_context(runtime_context)
	var runtime_hit_application := source_bullet_runtime_state.runtime_hit_application_state(runtime_context, runtime_step, 0)
	var hit_core_type_state := {"hitEffect": "Fx.hitBulletSmall", "hitSound": "Sounds.none", "hitSoundPitch": 1.0, "hitSoundPitchRange": 0.1, "hitSoundVolume": 1.0, "hitShake": 0.0, "hitColor": "Color.white", "fragOnHit": true, "delayFrags": false, "suppressionRange": 0.0, "suppressionDuration": 8.0, "suppressionEffectChance": 50.0, "suppressColor": "Pal.sapBullet"}
	var hit_core_bullet_state := {"rotation": 90.0, "x": 2.0, "y": 3.0, "team": "blue"}
	var hit_core_xy_state := {"x": 2.0, "y": 3.0}
	var hit_core_frag_state := {"createFrags": true, "fragBullet": {"delayFrags": false}}
	var runtime_hit_effects_state := source_bullet_runtime.hit_effects_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state)
	var module_hit_effects_state := source_bullet_type_hit_core_state.hit_effects_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state)
	var runtime_hit_frag_dispatch_state := source_bullet_runtime.hit_frag_dispatch_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, hit_core_frag_state)
	var module_hit_frag_dispatch_state := source_bullet_type_hit_core_state.hit_frag_dispatch_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, hit_core_frag_state)
	var runtime_hit_post_frag_dispatch_state := source_bullet_runtime.hit_post_frag_dispatch_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, runtime_hit_frag_dispatch_state)
	var module_hit_post_frag_dispatch_state := source_bullet_type_hit_core_state.hit_post_frag_dispatch_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, module_hit_frag_dispatch_state)
	var runtime_hit_suppression_state := source_bullet_runtime.hit_suppression_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, runtime_hit_post_frag_dispatch_state, 60.0)
	var module_hit_suppression_state := source_bullet_type_hit_core_state.hit_suppression_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, module_hit_post_frag_dispatch_state)
	var runtime_hit_splash_damage_dispatch_state := source_bullet_runtime.hit_splash_damage_dispatch_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, runtime_hit_suppression_state)
	var module_hit_splash_damage_dispatch_state := source_bullet_type_hit_core_state.hit_splash_damage_dispatch_state(hit_core_type_state, hit_core_bullet_state, hit_core_xy_state, module_hit_suppression_state)
	var hit_tile_type_state := {"makeFire": true, "healPercent": 25.0, "healAmount": 1.0, "healColor": "Pal.heal", "healSoundVolume": 1.0, "lifesteal": 0.5, "damage": 4.0, "pierceDamageFactor": 0.5, "removeAfterPierce": true}
	var hit_tile_bullet_state := {"team": "blue", "damage": 6.0}
	var hit_tile_state := {"direct": true}
	var hit_tile_enemy_build_state := {"team": "red", "tile": "enemy_tile", "health": 5.0, "x": 4.0, "y": 5.0, "block": "block", "maxHealth": 20.0}
	var hit_tile_ally_build_state := {"team": "blue", "tile": "ally_tile", "health": 5.0, "x": 4.0, "y": 5.0, "block": "block", "maxHealth": 20.0}
	var hit_tile_owner_health_state := {"isHealthc": true}
	var hit_tile_collision_state := {"team": "red", "healthf": 0.5}
	var pierce_state := {"initialHealth": 8.0, "x": 2.0, "y": 3.0}
	var runtime_heals_state := source_bullet_runtime.heals_state(hit_tile_type_state)
	var module_heals_state := source_bullet_type_hit_tile_state.heals_state(hit_tile_type_state)
	var runtime_test_collision_state := source_bullet_runtime.test_collision_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_collision_state)
	var module_test_collision_state := source_bullet_type_hit_tile_state.test_collision_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_collision_state)
	var runtime_hit_tile_fire_state := source_bullet_runtime.hit_tile_fire_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_enemy_build_state)
	var module_hit_tile_fire_state := source_bullet_type_hit_tile_state.hit_tile_fire_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_enemy_build_state)
	var runtime_hit_tile_heal_state := source_bullet_runtime.hit_tile_heal_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_ally_build_state)
	var module_hit_tile_heal_state := source_bullet_type_hit_tile_state.hit_tile_heal_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_ally_build_state)
	var runtime_hit_tile_enemy_direct_state := source_bullet_runtime.hit_tile_enemy_direct_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_enemy_build_state, hit_tile_state)
	var module_hit_tile_enemy_direct_state := source_bullet_type_hit_tile_state.hit_tile_enemy_direct_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_enemy_build_state, hit_tile_state)
	var runtime_hit_tile_lifesteal_state := source_bullet_runtime.hit_tile_lifesteal_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_enemy_build_state, hit_tile_state, hit_tile_owner_health_state)
	var module_hit_tile_lifesteal_state := source_bullet_type_hit_tile_state.hit_tile_lifesteal_state(hit_tile_type_state, hit_tile_bullet_state, hit_tile_enemy_build_state, hit_tile_state, hit_tile_owner_health_state)
	var runtime_handle_pierce_state := source_bullet_runtime.handle_pierce_state(hit_tile_type_state, hit_tile_bullet_state, pierce_state)
	var module_handle_pierce_state := source_bullet_type_hit_tile_state.handle_pierce_state(hit_tile_type_state, hit_tile_bullet_state, pierce_state)
	var hit_entity_type_state := {"maxDamageFraction": 0.5, "lifesteal": 0.25, "pierceArmor": true, "armorMultiplier": 1.0, "knockback": -1.0, "impact": true, "status": "burning", "statusDuration": 10.0, "pierceDamageFactor": 0.5, "removeAfterPierce": true}
	var hit_entity_bullet_state := {"damage": 12.0, "x": 0.0, "y": 0.0, "rotation": 0.0}
	var hit_entity_target_state := {"isUnit": true, "unitDead": false, "isHealthc": true, "isShieldc": true, "shield": 2.0, "maxHealth": 20.0, "health": 16.0, "x": 1.0, "y": 0.0}
	var hit_entity_input_state := {"health": 18.0}
	var hit_entity_owner_health_state := {"isHealthc": true}
	var runtime_hit_entity_damage_cap_state := source_bullet_runtime.hit_entity_damage_cap_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, hit_entity_input_state)
	var module_hit_entity_damage_cap_state := source_bullet_type_hit_entity_state.entity_damage_cap_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, hit_entity_input_state)
	var runtime_hit_entity_lifesteal_state := source_bullet_runtime.hit_entity_lifesteal_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, hit_entity_input_state, runtime_hit_entity_damage_cap_state, hit_entity_owner_health_state)
	var module_hit_entity_lifesteal_state := source_bullet_type_hit_entity_state.entity_lifesteal_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, hit_entity_input_state, module_hit_entity_damage_cap_state, hit_entity_owner_health_state)
	var runtime_hit_entity_armor_damage_state := source_bullet_runtime.hit_entity_armor_damage_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, hit_entity_input_state, runtime_hit_entity_damage_cap_state, runtime_hit_entity_lifesteal_state)
	var module_hit_entity_armor_damage_state := source_bullet_type_hit_entity_state.entity_armor_damage_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, hit_entity_input_state, module_hit_entity_damage_cap_state, module_hit_entity_lifesteal_state)
	var runtime_hit_entity_unit_effects_state := source_bullet_runtime.hit_entity_unit_effects_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, runtime_hit_entity_armor_damage_state)
	var module_hit_entity_unit_effects_state := source_bullet_type_hit_entity_state.entity_unit_effects_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, module_hit_entity_armor_damage_state)
	var runtime_hit_entity_unit_destroy_event_state := source_bullet_runtime.hit_entity_unit_destroy_event_state(hit_entity_bullet_state, hit_entity_target_state, runtime_hit_entity_damage_cap_state, runtime_hit_entity_unit_effects_state)
	var module_hit_entity_unit_destroy_event_state := source_bullet_type_hit_entity_state.entity_unit_destroy_event_state(hit_entity_bullet_state, hit_entity_target_state, module_hit_entity_damage_cap_state, module_hit_entity_unit_effects_state)
	var runtime_hit_entity_handle_pierce_state := source_bullet_runtime.hit_entity_handle_pierce_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, runtime_hit_entity_damage_cap_state, runtime_hit_entity_unit_destroy_event_state)
	var module_hit_entity_handle_pierce_state := source_bullet_type_hit_entity_state.entity_handle_pierce_state(hit_entity_type_state, hit_entity_bullet_state, hit_entity_target_state, module_hit_entity_damage_cap_state, module_hit_entity_unit_destroy_event_state, Callable(SourceBulletRuntime, "handle_pierce_state"))
	var angle_helper_matches := source_bullet_runtime.arc_angles_angle_dist(10.0, 350.0) == 20.0 and source_bullet_runtime.arc_angles_move_toward(10.0, 30.0, 5.0) == 15.0
	var runtime_arc_angles_forward_distance := source_bullet_runtime.arc_angles_forward_distance(350.0, 10.0)
	var module_arc_angles_forward_distance := source_math_state.source_angles_forward_distance(350.0, 10.0)
	var runtime_arc_angles_backward_distance := source_bullet_runtime.arc_angles_backward_distance(350.0, 10.0)
	var module_arc_angles_backward_distance := source_math_state.source_angles_backward_distance(350.0, 10.0)
	var runtime_arc_mathf_mod_float := source_bullet_runtime.arc_mathf_mod_float(-10.0, source_math_defaults.FULL_CIRCLE_DEGREES)
	var module_arc_mathf_mod_float := source_math_state.source_mod_float(-10.0, source_math_defaults.FULL_CIRCLE_DEGREES)
	var runtime_arc_angles_angle_dist := source_bullet_runtime.arc_angles_angle_dist(10.0, 350.0)
	var module_arc_angles_angle_dist := source_math_state.source_angles_angle_dist(10.0, 350.0)
	var runtime_arc_angles_move_toward := source_bullet_runtime.arc_angles_move_toward(10.0, 350.0, 5.0)
	var module_arc_angles_move_toward := source_math_state.source_angles_move_toward(10.0, 350.0, 5.0)
	var runtime_arc_angles_angle := source_bullet_runtime.arc_angles_angle(0.0, 0.0, 0.0, -1.0)
	var module_arc_angles_angle := source_math_state.source_angles_angle(0.0, 0.0, 0.0, -1.0)
	var runtime_arc_angles_trns_vec := source_bullet_runtime.arc_angles_trns_vec(45.0, 2.0, 1.0)
	var module_arc_angles_trns_vec := source_math_state.source_angles_trns_vec(45.0, 2.0, 1.0)
	var scalar_bullet_state := {"rangeChange": 3.0, "inaccuracy": 1.5, "lifetime": 120.0, "speed": 2.0, "hitSize": 5.0, "damage": 7.0, "ammoMultiplier": 4.0, "reloadMultiplier": 0.5, "width": 6.0, "height": 9.0}
	var scalar_texture_size := Vector2(3.0, 6.0)
	var runtime_scalar_range_change := source_bullet_runtime.range_change(scalar_bullet_state, bullet_defaults)
	var module_scalar_range_change := source_bullet_runtime_state.range_change(scalar_bullet_state)
	var runtime_scalar_inaccuracy := source_bullet_runtime.inaccuracy(scalar_bullet_state, bullet_defaults)
	var module_scalar_inaccuracy := source_bullet_runtime_state.inaccuracy(scalar_bullet_state)
	var runtime_scalar_lifetime_seconds := source_bullet_runtime.lifetime_seconds(scalar_bullet_state, bullet_defaults, source_bullet_defaults.TICKS_PER_SECOND)
	var module_scalar_lifetime_seconds := source_bullet_runtime_state.lifetime_seconds(scalar_bullet_state)
	var runtime_scalar_world_speed := source_bullet_runtime.world_speed(scalar_bullet_state, bullet_defaults, source_bullet_defaults.TICKS_PER_SECOND)
	var module_scalar_world_speed := source_bullet_runtime_state.world_speed(scalar_bullet_state)
	var runtime_scalar_velocity := source_bullet_runtime.velocity(scalar_bullet_state, bullet_defaults, source_bullet_defaults.TICKS_PER_SECOND, 0.0)
	var module_scalar_velocity := source_bullet_runtime_state.velocity(scalar_bullet_state, 0.0)
	var runtime_scalar_hit_size := source_bullet_runtime.hit_size(scalar_bullet_state, bullet_defaults)
	var module_scalar_hit_size := source_bullet_runtime_state.hit_size(scalar_bullet_state)
	var runtime_scalar_damage := source_bullet_runtime.damage(scalar_bullet_state, bullet_defaults)
	var module_scalar_damage := source_bullet_runtime_state.damage(scalar_bullet_state)
	var runtime_scalar_ammo_multiplier := source_bullet_runtime.ammo_multiplier(scalar_bullet_state, bullet_defaults)
	var module_scalar_ammo_multiplier := source_bullet_runtime_state.ammo_multiplier(scalar_bullet_state)
	var runtime_scalar_reload_multiplier := source_bullet_runtime.reload_multiplier(scalar_bullet_state, bullet_defaults)
	var module_scalar_reload_multiplier := source_bullet_runtime_state.reload_multiplier(scalar_bullet_state)
	var runtime_scalar_scale := source_bullet_runtime.scale(scalar_bullet_state, bullet_defaults, scalar_texture_size)
	var module_scalar_scale := source_bullet_runtime_state.scale(scalar_bullet_state, scalar_texture_size)
	var impact_type_state := {"impact": true, "knockback": -1.0}
	var impact_bullet_state := {"rotation": 0.0, "x": 0.0, "y": 0.0}
	var impact_entity_state := {"isUnit": true, "x": 1.0, "y": 0.0}
	var impact_state := source_bullet_runtime.hit_entity_unit_effects_state(impact_type_state, impact_bullet_state, impact_entity_state, {})
	var impact_expected := source_bullet_runtime.arc_angles_trns_vec(source_math_defaults.HALF_CIRCLE_DEGREES, 80.0, 0.0)
	var impact_half_circle_matches := absf(float(impact_state.get("impulseVector", {}).get("x", 0.0)) - float(impact_expected.get("x", 0.0))) < 0.001 and absf(float(impact_state.get("impulseVector", {}).get("y", 0.0)) - float(impact_expected.get("y", 0.0))) < 0.001
	var removed_type_state := {"trailLength": 3, "trailWidth": 2.5, "trailColor": "Pal.missileYellowBack", "fragOnDespawn": true, "fragBullet": {"id": "frag"}}
	var removed_bullet_state := {"x": 8.0, "y": 9.0, "trail": {"size": 2, "points": [1, 2, 3]}, "frags": 0}
	var removed_trail_fade_state := source_bullet_removed_runtime_state.removed_trail_fade_state(removed_type_state, removed_bullet_state)
	var removed_frag_dispatch_state := source_bullet_removed_runtime_state.removed_frag_dispatch_state(removed_type_state, removed_bullet_state, removed_trail_fade_state)
	var despawn_type_state := {"despawnHit": true, "despawnEffect": "Fx.hitBulletSmall", "hitColor": "Color.white", "despawnSound": "Sounds.none", "hitSoundPitchRange": 0.1, "despawnShake": 0.0}
	var despawn_bullet_state := {"x": 8.0, "y": 9.0, "rotation": 90.0}
	var despawn_dispatch_state := source_bullet_type_lifecycle_state.despawned_dispatch_state(despawn_type_state, despawn_bullet_state)
	var runtime_despawn_dispatch_state := source_bullet_runtime.despawned_dispatch_state(despawn_type_state, despawn_bullet_state)
	var despawn_effect_state := source_bullet_type_lifecycle_state.despawned_effect_state(despawn_type_state, despawn_bullet_state, despawn_dispatch_state)
	var runtime_despawn_effect_state := source_bullet_runtime.despawned_effect_state(despawn_type_state, despawn_bullet_state, despawn_dispatch_state)
	var despawn_sound_state := source_bullet_type_lifecycle_state.despawned_sound_state(despawn_type_state, despawn_bullet_state, despawn_effect_state, {"rangeSample": 0.0})
	var runtime_despawn_sound_state := source_bullet_runtime.despawned_sound_state(despawn_type_state, despawn_bullet_state, despawn_effect_state, {"rangeSample": 0.0})
	var despawn_shake_state := source_bullet_type_lifecycle_state.despawned_shake_state(despawn_type_state, despawn_bullet_state, despawn_sound_state)
	var runtime_despawn_shake_state := source_bullet_runtime.despawned_shake_state(despawn_type_state, despawn_bullet_state, despawn_sound_state)
	var init_type_state := {"killShooter": true, "instantDisappear": true, "lifetime": 30.0}
	var init_bullet_state := {"time": 0.0}
	var init_owner_state := {"isHealthc": true, "dead": false, "health": 10.0}
	var init_initial_state := source_bullet_type_init_state.init_initial_state(init_bullet_state, init_type_state, init_owner_state)
	var runtime_init_initial_state := source_bullet_runtime.init_initial_state(init_bullet_state, init_type_state, init_owner_state, bullet_defaults)
	var init_spawn_bullets_state := source_bullet_type_init_state.init_spawn_bullets_state(init_initial_state, {"spawnBullets": [1], "spawnBulletRandomSpread": 2.0}, [0.5])
	var runtime_init_spawn_bullets_state := source_bullet_runtime.init_spawn_bullets_state(init_initial_state, {"spawnBullets": [1], "spawnBulletRandomSpread": 2.0}, [0.5])
	var init_range_type_state := {"pierceCap": 2, "setDefaults": true, "lightning": 1, "status": "none", "fragBullet": {"keepVelocity": true, "scaleKeepVelocity": true}, "splashDamageRadius": 3.0, "collidesAir": false, "collidesGround": true, "lightRadius": -1.0, "hitSize": 5.0, "drawSize": 10.0, "trailLength": 3, "speed": 2.0}
	var runtime_init_type_defaults_state := source_bullet_runtime.init_type_defaults_state(init_range_type_state)
	var module_init_type_defaults_state := source_bullet_type_init_range_state.init_type_defaults_state(init_range_type_state)
	var runtime_init_frag_velocity_state := source_bullet_runtime.init_frag_velocity_state(runtime_init_type_defaults_state)
	var module_init_frag_velocity_state := source_bullet_type_init_range_state.init_frag_velocity_state(module_init_type_defaults_state)
	var runtime_init_lightning_type_state := source_bullet_runtime.init_lightning_type_state(runtime_init_frag_velocity_state)
	var module_init_lightning_type_state := source_bullet_type_init_range_state.init_lightning_type_state(module_init_frag_velocity_state)
	var runtime_init_light_radius_state := source_bullet_runtime.init_light_radius_state(runtime_init_lightning_type_state)
	var module_init_light_radius_state := source_bullet_type_init_range_state.init_light_radius_state(module_init_lightning_type_state)
	var runtime_init_draw_size_state := source_bullet_runtime.init_draw_size_state(runtime_init_light_radius_state)
	var module_init_draw_size_state := source_bullet_type_init_range_state.init_draw_size_state(module_init_light_radius_state)
	var runtime_init_range_assignment_state := source_bullet_runtime.init_range_assignment_state(runtime_init_draw_size_state, 42.0)
	var module_init_range_assignment_state := source_bullet_type_init_range_state.init_range_assignment_state(module_init_draw_size_state, 42.0)
	var runtime_calculate_range_override_state := source_bullet_runtime.calculate_range_override_state({"rangeOverride": 7.0})
	var module_calculate_range_override_state := source_bullet_type_init_range_state.calculate_range_override_state({"rangeOverride": 7.0})
	var calculate_range_spawn_input_state := {"bulletType": {"spawnUnit": {"lifetime": 2.0, "speed": 3.0}}, "returnEarly": false, "range": null}
	var runtime_calculate_range_spawn_unit_state := source_bullet_runtime.calculate_range_spawn_unit_state(calculate_range_spawn_input_state)
	var module_calculate_range_spawn_unit_state := source_bullet_type_init_range_state.calculate_range_spawn_unit_state(calculate_range_spawn_input_state)
	var calculate_range_despawn_input_state := {"bulletType": {"despawnUnit": {"lifetime": 4.0, "speed": 1.5}}, "returnEarly": false, "range": null}
	var runtime_calculate_range_despawn_unit_state := source_bullet_runtime.calculate_range_despawn_unit_state(calculate_range_despawn_input_state)
	var module_calculate_range_despawn_unit_state := source_bullet_type_init_range_state.calculate_range_despawn_unit_state(calculate_range_despawn_input_state)
	var calculate_range_fallback_input_state := {"bulletType": {"speed": 2.0, "lifetime": 5.0, "drag": 0.1, "maxRange": -1.0}, "returnEarly": false, "range": null}
	var runtime_calculate_range_fallback_state := source_bullet_runtime.calculate_range_fallback_state(calculate_range_fallback_input_state)
	var module_calculate_range_fallback_state := source_bullet_type_init_range_state.calculate_range_fallback_state(calculate_range_fallback_input_state)
	var runtime_continuous_damage_default_state := source_bullet_runtime.continuous_damage_default_state(init_range_type_state)
	var module_continuous_damage_default_state := source_bullet_type_init_range_state.continuous_damage_default_state(init_range_type_state)
	var damage_multiplier_bullet_state := {"team": "blue"}
	var damage_multiplier_owner_state := {"isUnit": true, "unitDamageMultiplier": 1.25}
	var damage_multiplier_rules_state := {"unitDamage": 0.8, "blockDamage": 0.5}
	var runtime_damage_multiplier_state := source_bullet_runtime.damage_multiplier_state(damage_multiplier_bullet_state, damage_multiplier_owner_state, damage_multiplier_rules_state)
	var module_damage_multiplier_state := source_bullet_type_damage_state.damage_multiplier_state(damage_multiplier_bullet_state, damage_multiplier_owner_state, damage_multiplier_rules_state)
	var trail_effects_bullet_state := {"velocity": {"x": 1.0, "y": 0.0}, "x": 2.0, "y": 3.0, "rotation": 0.0}
	var trail_effects_type_state := {"trailMinVelocity": 0.0, "trailChance": 1.0, "trailSpread": 0.5, "trailRotation": true, "trailParam": 2.0, "trailColor": "Pal.missileYellowBack", "trailEffect": "Fx.missileTrail", "trailInterval": 0.25}
	var trail_effects_random_state := {"x": 0.25, "y": -0.25}
	var runtime_rotation_degrees_state := source_bullet_runtime.rotation_degrees(trail_effects_bullet_state)
	var module_rotation_degrees_state := source_bullet_type_update_state.bullet_rotation_degrees(trail_effects_bullet_state, Callable(SourceBulletRuntime, "arc_angles_angle"))
	var runtime_trail_effects_chance_state := source_bullet_runtime.update_trail_effects_chance_state(trail_effects_bullet_state, trail_effects_type_state, true, trail_effects_random_state)
	var module_trail_effects_chance_state := source_bullet_type_update_state.update_trail_effects_chance_state(trail_effects_bullet_state, trail_effects_type_state, true, trail_effects_random_state, Callable(SourceBulletRuntime, "rotation_degrees"))
	var runtime_trail_effects_interval_state := source_bullet_runtime.update_trail_effects_interval_state(runtime_trail_effects_chance_state, trail_effects_type_state, true, trail_effects_random_state)
	var module_trail_effects_interval_state := source_bullet_type_update_state.update_trail_effects_interval_state(module_trail_effects_chance_state, trail_effects_type_state, true, trail_effects_random_state, Callable(SourceBulletRuntime, "rotation_degrees"))
	var update_dispatch_state := source_bullet_type_update_state.update_dispatch_state({"time": 0.0})
	var runtime_update_dispatch_state := source_bullet_runtime.update_dispatch_state({"time": 0.0})
	var update_bullet_interval_state := source_bullet_type_update_state.update_bullet_interval_state({"time": 25.0, "rotation": 90.0}, {"intervalBullet": {"id": "x"}, "intervalDelay": 20.0, "intervalBullets": 2, "intervalSpread": 4.0, "intervalAngle": 5.0, "bulletInterval": 20.0}, true, [0.0, 0.25])
	var runtime_update_bullet_interval_state := source_bullet_runtime.update_bullet_interval_state({"time": 25.0, "rotation": 90.0}, {"intervalBullet": {"id": "x"}, "intervalDelay": 20.0, "intervalBullets": 2, "intervalSpread": 4.0, "intervalAngle": 5.0, "bulletInterval": 20.0}, true, [0.0, 0.25])
	var update_trail_state := source_bullet_type_update_state.update_trail_state({"trail": {"counter": 1.0}, "x": 2.0, "y": 3.0}, {"trailLength": 3, "trailSinMag": 0.0}, false, 0.5, 0.0, 0.25)
	var runtime_update_trail_state := source_bullet_runtime.update_trail_state({"trail": {"counter": 1.0}, "x": 2.0, "y": 3.0}, {"trailLength": 3, "trailSinMag": 0.0}, false, 0.5, 0.0, 0.25)
	var velocity_vector_state := source_bullet_type_create_state.velocity_vector_state({"angle": 0.0, "speed": 2.0}, Callable(SourceBulletRuntime, "arc_angles_trns_vec"))
	var runtime_velocity_vector_state := source_bullet_runtime.velocity_vector_state({"angle": 0.0, "speed": 2.0})
	var keep_velocity_trail_add_state := {"bulletTrailAddApplied": true, "bulletContinues": true, "bullet": {"velocity": {"angle": 0.0, "speed": 2.0}, "lifetime": 10.0}}
	var keep_velocity_type_state := {"keepVelocity": true, "scaleKeepVelocity": true}
	var keep_velocity_owner_state := {"isVelc": true, "vel": {"x": 1.0, "y": 0.0}}
	var keep_velocity_state := source_bullet_type_create_state.keep_velocity_state(keep_velocity_trail_add_state, keep_velocity_type_state, keep_velocity_owner_state, Callable(SourceBulletRuntime, "arc_angles_trns_vec"))
	var runtime_keep_velocity_state := source_bullet_runtime.create_keep_velocity_state(keep_velocity_trail_add_state, keep_velocity_type_state, keep_velocity_owner_state, bullet_defaults)
	var homing_initial_state := source_bullet_type_update_state.update_homing_initial_state({"time": 1.0, "x": 0.0, "y": 0.0, "velocity": {"angle": 0.0, "speed": 2.0}}, {"homingPower": 0.5, "homingDelay": 0.0, "homingRange": 50.0})
	var runtime_homing_initial_state := source_bullet_runtime.update_homing_initial_state({"time": 1.0, "x": 0.0, "y": 0.0, "velocity": {"angle": 0.0, "speed": 2.0}}, {"homingPower": 0.5, "homingDelay": 0.0, "homingRange": 50.0})
	var homing_target_velocity_state := source_bullet_type_update_motion_state.update_homing_target_velocity_state(homing_initial_state, {"x": 10.0, "y": 0.0}, 0.1, Callable(SourceBulletRuntime, "arc_angles_angle"), Callable(SourceBulletRuntime, "arc_angles_move_toward"), Callable(SourceBulletRuntime, "arc_angles_trns_vec"))
	var runtime_homing_target_velocity_state := source_bullet_runtime.update_homing_target_velocity_state(homing_initial_state, {"x": 10.0, "y": 0.0}, 0.1)
	var homing_follow_aim_state := source_bullet_type_update_motion_state.update_homing_follow_aim_state(homing_target_velocity_state, {"followAimSpeed": 5.0}, {"isUnit": true, "aimX": 10.0, "aimY": 1.0}, 0.1, Callable(SourceBulletRuntime, "arc_angles_angle"), Callable(SourceBulletRuntime, "arc_angles_move_toward"), Callable(SourceBulletRuntime, "arc_angles_trns_vec"))
	var runtime_homing_follow_aim_state := source_bullet_runtime.update_homing_follow_aim_state(homing_target_velocity_state, {"followAimSpeed": 5.0}, {"isUnit": true, "aimX": 10.0, "aimY": 1.0}, 0.1)
	var weaving_state := source_bullet_type_update_motion_state.update_weaving_state({"time": 1.0, "velocity": {"x": 2.0, "y": 0.0}}, {"weaveMag": 1.0, "weaveScale": 1.0, "weaveRandom": false}, 0, 0.1, Callable(SourceBulletRuntime, "arc_angles_angle"))
	var runtime_weaving_state := source_bullet_runtime.update_weaving_state({"time": 1.0, "velocity": {"x": 2.0, "y": 0.0}}, {"weaveMag": 1.0, "weaveScale": 1.0, "weaveRandom": false}, 0, 0.1)
	var weaving_rotate_speed_state := source_bullet_type_update_motion_state.update_weaving_rotate_speed_state(weaving_state, {"rotateSpeed": 2.0}, 0.1, Callable(SourceBulletRuntime, "arc_angles_angle"))
	var runtime_weaving_rotate_speed_state := source_bullet_runtime.update_weaving_rotate_speed_state(weaving_state, {"rotateSpeed": 2.0}, 0.1)
	var vec2_limit_state := source_math_state.source_vec2_limit({"x": 3.0, "y": 4.0}, 2.0)
	var runtime_vec2_limit_state := source_bullet_runtime.vec2_limit({"x": 3.0, "y": 4.0}, 2.0)
	var weaving_circle_shooter_state := source_bullet_type_update_motion_state.update_weaving_circle_shooter_state(weaving_rotate_speed_state, {"circleShooter": true, "circleShooterRadius": 13.0, "circleShooterRadiusSmooth": 10.0, "circleShooterRotateSpeed": 0.3, "speed": 1.0}, {"isHealthc": true, "isValid": true, "x": 1.0, "y": 1.0}, 0.1, Callable(SourceBulletRuntime, "vec2_limit"), Callable(SourceBulletRuntime, "arc_angles_angle"))
	var runtime_weaving_circle_shooter_state := source_bullet_runtime.update_weaving_circle_shooter_state(weaving_rotate_speed_state, {"circleShooter": true, "circleShooterRadius": 13.0, "circleShooterRadiusSmooth": 10.0, "circleShooterRotateSpeed": 0.3, "speed": 1.0}, {"isHealthc": true, "isValid": true, "x": 1.0, "y": 1.0}, 0.1)
	var frags_type_state := {"fragBullet": true, "fragBullets": 1, "fragOffsetMin": 1.0, "fragOffsetMax": 1.0, "fragRandomSpread": 0.0, "fragAngle": 0.0, "fragSpread": 0.0, "fragVelocityMin": 0.2, "fragVelocityMax": 0.2, "fragLifeMin": 1.0, "fragLifeMax": 1.0}
	var frags_bullet_state := {"rotation": 0.0, "frags": 0, "absorbed": false}
	var frags_create_state := {"x": 1.0, "y": 2.0}
	var frags_random_state := {"lenSamples": [1.0], "rangeSamples": [0.0], "velocitySamples": [0.2], "lifeSamples": [1.0]}
	var frags_initial_state := source_bullet_type_create_frags_state.initial_state(frags_type_state, frags_bullet_state, frags_create_state)
	var runtime_frags_initial_state := source_bullet_runtime.create_frags_initial_state(frags_type_state, frags_bullet_state, frags_create_state)
	var frags_random_geometry_state := source_bullet_type_create_frags_state.random_geometry_state(frags_type_state, frags_bullet_state, frags_initial_state, frags_random_state)
	var runtime_frags_random_geometry_state := source_bullet_runtime.create_frags_random_geometry_state(frags_type_state, frags_bullet_state, frags_initial_state, frags_random_state)
	var frags_create_call_state := source_bullet_type_create_frags_state.game_create_call_state(game, frags_type_state, frags_bullet_state, frags_random_geometry_state, frags_random_state)
	var runtime_frags_create_call_state := source_bullet_runtime.create_frags_create_call_state(frags_type_state, frags_bullet_state, frags_random_geometry_state, frags_random_state)
	var frags_increment_state := source_bullet_type_create_frags_state.increment_state(frags_bullet_state, frags_create_call_state)
	var runtime_frags_increment_state := source_bullet_runtime.create_frags_increment_state(frags_bullet_state, frags_create_call_state)
	var incend_type_state := {"incendChance": 1.0, "incendSpread": 8.0, "incendAmount": 2}
	var incend_bullet_state := {}
	var incend_create_state := {"x": 6.0, "y": 7.0}
	var incend_random_state := {"chancePassed": true}
	var incend_state := source_bullet_type_create_incend_state.create_state(incend_type_state, incend_bullet_state, incend_create_state, incend_random_state)
	var runtime_incend_state := source_bullet_runtime.create_incend_state(incend_type_state, incend_bullet_state, incend_create_state, incend_random_state)
	var puddles_type_state := {"puddleLiquid": "water", "puddles": 1, "puddleRange": 2.0, "puddleAmount": 5.0}
	var puddles_bullet_state := {"x": 1.0, "y": 2.0}
	var puddles_create_state := {"x": 3.0, "y": 4.0}
	var puddles_random_state := {"xRangeSamples": [0.25], "yRangeSamples": [0.5]}
	var puddles_initial_state := source_bullet_type_create_puddles_state.initial_state(puddles_type_state, puddles_bullet_state, puddles_create_state)
	var runtime_puddles_initial_state := source_bullet_runtime.create_puddles_initial_state(puddles_type_state, puddles_bullet_state, puddles_create_state)
	var puddles_tile_world_state := source_bullet_type_create_puddles_state.tile_world_state(puddles_type_state, puddles_bullet_state, puddles_initial_state, puddles_random_state)
	var runtime_puddles_tile_world_state := source_bullet_runtime.create_puddles_tile_world_state(puddles_type_state, puddles_bullet_state, puddles_initial_state, puddles_random_state)
	var puddles_deposit_state := source_bullet_type_create_puddles_state.deposit_state(puddles_type_state, puddles_bullet_state, puddles_tile_world_state)
	var runtime_puddles_deposit_state := source_bullet_runtime.create_puddles_deposit_state(puddles_type_state, puddles_bullet_state, puddles_tile_world_state)
	var units_type_state := {"despawnUnit": {"id": "flare"}, "despawnUnitChance": 1.0, "despawnUnitCount": 1, "despawnUnitRadius": 2.0, "faceOutwards": true}
	var units_bullet_state := {"team": "blue", "rotation": 45.0}
	var units_create_state := {"x": 3.0, "y": 4.0}
	var units_random_state := {"chancePassed": true, "lengthSamples": [1.0], "thetaSamples": [0.0]}
	var units_net_state := {"client": false}
	var units_initial_state := source_bullet_type_create_units_state.initial_state(units_type_state, units_bullet_state, units_create_state, units_random_state, units_net_state)
	var runtime_units_initial_state := source_bullet_runtime.create_units_initial_state(units_type_state, units_bullet_state, units_create_state, units_random_state, units_net_state)
	var units_random_offset_state := source_bullet_type_create_units_state.random_offset_state(units_type_state, units_bullet_state, units_initial_state, units_random_state)
	var runtime_units_random_offset_state := source_bullet_runtime.create_units_random_offset_state(units_type_state, units_bullet_state, units_initial_state, units_random_state)
	var units_spawn_state := source_bullet_type_create_units_state.spawn_state(units_type_state, units_bullet_state, units_random_offset_state)
	var runtime_units_spawn_state := source_bullet_runtime.create_units_spawn_state(units_type_state, units_bullet_state, units_random_offset_state)
	var units_rotation_state := source_bullet_type_create_units_state.rotation_state(units_type_state, units_bullet_state, units_spawn_state)
	var runtime_units_rotation_state := source_bullet_runtime.create_units_rotation_state(units_type_state, units_bullet_state, units_spawn_state)
	var units_notify_state := source_bullet_type_create_units_state.notify_state(units_type_state, units_bullet_state, units_rotation_state)
	var runtime_units_notify_state := source_bullet_runtime.create_units_notify_state(units_type_state, units_bullet_state, units_rotation_state)
	var splash_type_state := {"splashDamageRadius": 6.0, "splashDamage": 4.0, "status": "burning", "statusDuration": 12.0, "healPercent": 50.0, "healAmount": 2.0, "healColor": "Pal.heal", "healEffect": "Fx.healBlockFull", "makeFire": true}
	var splash_bullet_state := {"team": "blue", "absorbed": false}
	var splash_hit_state := {"x": 2.0, "y": 3.0}
	var splash_damage_state := source_bullet_type_create_splash_damage_state.damage_dispatch_state(splash_type_state, splash_bullet_state, splash_hit_state, {"damageMultiplier": 1.5})
	var splash_status_state := source_bullet_type_create_splash_damage_state.status_dispatch_state(splash_type_state, splash_bullet_state, splash_damage_state, 60.0)
	var splash_heal_nearby_state := {"blocks": [{"damaged": true, "x": 4.0, "y": 5.0, "block": "block", "maxHealth": 10.0}]}
	var splash_make_fire_nearby_state := {"blocks": [{"team": "red", "tile": "tile"}, {"team": "blue", "tile": "ally_tile"}]}
	var splash_heal_state := source_bullet_type_create_splash_damage_state.heal_dispatch_state(splash_type_state, splash_bullet_state, splash_status_state, splash_heal_nearby_state)
	var splash_make_fire_state := source_bullet_type_create_splash_damage_state.make_fire_dispatch_state(splash_type_state, splash_bullet_state, splash_heal_state, splash_make_fire_nearby_state)
	var circle_shooter_rotation_offset_degrees := source_math_defaults.QUARTER_CIRCLE_DEGREES
	var texture_path := source_bullet_runtime_state.texture_path("bullet")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BULLET_RUNTIME_MODULE_PROOF",
		"spawn_state": spawn_state,
		"runtime_spawn_state_shard_matches": spawn_state == spawn_shard_state,
		"runtime_step_matches": bool(runtime_step.get("next_position", Vector2.ZERO) == Vector2.ZERO),
		"target_context_matches": bool(runtime_context.has("target_position")),
		"target_step_from_context_matches": bool(target_step_from_context.has("next_position")),
		"target_step_state_matches": bool(target_step_state.has("next_position")),
		"runtime_target_step_shard_matches": target_step_state == target_step_shard_state,
		"runtime_hit_application_matches": bool(runtime_hit_application.has("hit_count")),
		"runtime_hit_effects_matches": runtime_hit_effects_state == module_hit_effects_state,
		"runtime_hit_frag_dispatch_matches": runtime_hit_frag_dispatch_state == module_hit_frag_dispatch_state,
		"runtime_hit_post_frag_dispatch_matches": runtime_hit_post_frag_dispatch_state == module_hit_post_frag_dispatch_state,
		"runtime_hit_suppression_matches": runtime_hit_suppression_state == module_hit_suppression_state,
		"runtime_hit_splash_damage_dispatch_matches": runtime_hit_splash_damage_dispatch_state == module_hit_splash_damage_dispatch_state,
		"runtime_heals_matches": runtime_heals_state == module_heals_state,
		"runtime_test_collision_matches": runtime_test_collision_state == module_test_collision_state,
		"runtime_hit_tile_fire_matches": runtime_hit_tile_fire_state == module_hit_tile_fire_state,
		"runtime_hit_tile_heal_matches": runtime_hit_tile_heal_state == module_hit_tile_heal_state,
		"runtime_hit_tile_enemy_direct_matches": runtime_hit_tile_enemy_direct_state == module_hit_tile_enemy_direct_state,
		"runtime_hit_tile_lifesteal_matches": runtime_hit_tile_lifesteal_state == module_hit_tile_lifesteal_state,
		"runtime_handle_pierce_matches": runtime_handle_pierce_state == module_handle_pierce_state,
		"runtime_hit_entity_damage_cap_matches": runtime_hit_entity_damage_cap_state == module_hit_entity_damage_cap_state,
		"runtime_hit_entity_lifesteal_matches": runtime_hit_entity_lifesteal_state == module_hit_entity_lifesteal_state,
		"runtime_hit_entity_armor_damage_matches": runtime_hit_entity_armor_damage_state == module_hit_entity_armor_damage_state,
		"runtime_hit_entity_unit_effects_matches": runtime_hit_entity_unit_effects_state == module_hit_entity_unit_effects_state,
		"runtime_hit_entity_unit_destroy_event_matches": runtime_hit_entity_unit_destroy_event_state == module_hit_entity_unit_destroy_event_state,
		"runtime_hit_entity_handle_pierce_matches": runtime_hit_entity_handle_pierce_state == module_hit_entity_handle_pierce_state,
		"angle_helper_matches": angle_helper_matches,
		"impact_half_circle_matches": impact_half_circle_matches,
		"removed_trail_fade_matches": bool(removed_trail_fade_state.get("gatePassed", false)) and bool(removed_trail_fade_state.get("trailFadeCall", {}) is Dictionary),
		"removed_frag_dispatch_matches": bool(removed_frag_dispatch_state.get("fragGatePassed", false)) and bool(removed_frag_dispatch_state.get("createFragsCall", {}) is Dictionary),
		"despawned_dispatch_matches": runtime_despawn_dispatch_state == despawn_dispatch_state,
		"despawned_effect_matches": runtime_despawn_effect_state == despawn_effect_state,
		"despawned_sound_matches": runtime_despawn_sound_state == despawn_sound_state,
		"despawned_shake_matches": runtime_despawn_shake_state == despawn_shake_state,
		"init_initial_matches": runtime_init_initial_state == init_initial_state,
		"init_spawn_bullets_matches": runtime_init_spawn_bullets_state == init_spawn_bullets_state,
		"runtime_init_type_defaults_matches": runtime_init_type_defaults_state == module_init_type_defaults_state,
		"runtime_init_frag_velocity_matches": runtime_init_frag_velocity_state == module_init_frag_velocity_state,
		"runtime_init_lightning_type_matches": runtime_init_lightning_type_state == module_init_lightning_type_state,
		"runtime_init_light_radius_matches": runtime_init_light_radius_state == module_init_light_radius_state,
		"runtime_init_draw_size_matches": runtime_init_draw_size_state == module_init_draw_size_state,
		"runtime_init_range_assignment_matches": runtime_init_range_assignment_state == module_init_range_assignment_state,
		"runtime_calculate_range_override_matches": runtime_calculate_range_override_state == module_calculate_range_override_state,
		"runtime_calculate_range_spawn_unit_matches": runtime_calculate_range_spawn_unit_state == module_calculate_range_spawn_unit_state,
		"runtime_calculate_range_despawn_unit_matches": runtime_calculate_range_despawn_unit_state == module_calculate_range_despawn_unit_state,
		"runtime_calculate_range_fallback_matches": runtime_calculate_range_fallback_state == module_calculate_range_fallback_state,
		"runtime_continuous_damage_default_matches": runtime_continuous_damage_default_state == module_continuous_damage_default_state,
		"runtime_damage_multiplier_matches": runtime_damage_multiplier_state == module_damage_multiplier_state,
		"runtime_rotation_degrees_matches": runtime_rotation_degrees_state == module_rotation_degrees_state,
		"runtime_trail_effects_chance_matches": runtime_trail_effects_chance_state == module_trail_effects_chance_state,
		"runtime_trail_effects_interval_matches": runtime_trail_effects_interval_state == module_trail_effects_interval_state,
		"runtime_scalar_range_change_matches": runtime_scalar_range_change == module_scalar_range_change,
		"runtime_scalar_inaccuracy_matches": runtime_scalar_inaccuracy == module_scalar_inaccuracy,
		"runtime_scalar_lifetime_seconds_matches": runtime_scalar_lifetime_seconds == module_scalar_lifetime_seconds,
		"runtime_scalar_world_speed_matches": runtime_scalar_world_speed == module_scalar_world_speed,
		"runtime_scalar_velocity_matches": runtime_scalar_velocity == module_scalar_velocity,
		"runtime_scalar_hit_size_matches": runtime_scalar_hit_size == module_scalar_hit_size,
		"runtime_scalar_damage_matches": runtime_scalar_damage == module_scalar_damage,
		"runtime_scalar_ammo_multiplier_matches": runtime_scalar_ammo_multiplier == module_scalar_ammo_multiplier,
		"runtime_scalar_reload_multiplier_matches": runtime_scalar_reload_multiplier == module_scalar_reload_multiplier,
		"runtime_scalar_scale_matches": runtime_scalar_scale == module_scalar_scale,
		"runtime_arc_angles_forward_distance_matches": runtime_arc_angles_forward_distance == module_arc_angles_forward_distance,
		"runtime_arc_angles_backward_distance_matches": runtime_arc_angles_backward_distance == module_arc_angles_backward_distance,
		"runtime_arc_mathf_mod_float_matches": runtime_arc_mathf_mod_float == module_arc_mathf_mod_float,
		"runtime_arc_angles_angle_dist_matches": runtime_arc_angles_angle_dist == module_arc_angles_angle_dist,
		"runtime_arc_angles_move_toward_matches": runtime_arc_angles_move_toward == module_arc_angles_move_toward,
		"runtime_arc_angles_angle_matches": runtime_arc_angles_angle == module_arc_angles_angle,
		"runtime_arc_angles_trns_vec_matches": runtime_arc_angles_trns_vec == module_arc_angles_trns_vec,
		"update_dispatch_matches": runtime_update_dispatch_state == update_dispatch_state,
		"update_bullet_interval_matches": runtime_update_bullet_interval_state == update_bullet_interval_state,
		"update_trail_matches": runtime_update_trail_state == update_trail_state,
		"velocity_vector_matches": runtime_velocity_vector_state == velocity_vector_state,
		"keep_velocity_matches": runtime_keep_velocity_state == keep_velocity_state,
		"homing_initial_matches": runtime_homing_initial_state == homing_initial_state,
		"homing_target_velocity_matches": runtime_homing_target_velocity_state == homing_target_velocity_state,
		"homing_follow_aim_matches": runtime_homing_follow_aim_state == homing_follow_aim_state,
		"weaving_matches": runtime_weaving_state == weaving_state,
		"weaving_rotate_speed_matches": runtime_weaving_rotate_speed_state == weaving_rotate_speed_state,
		"vec2_limit_matches": runtime_vec2_limit_state == vec2_limit_state,
		"weaving_circle_shooter_matches": runtime_weaving_circle_shooter_state == weaving_circle_shooter_state,
		"frags_initial_matches": runtime_frags_initial_state == frags_initial_state,
		"frags_random_geometry_matches": runtime_frags_random_geometry_state == frags_random_geometry_state,
		"frags_create_call_matches": runtime_frags_create_call_state == frags_create_call_state,
		"frags_increment_matches": runtime_frags_increment_state == frags_increment_state,
		"incend_matches": runtime_incend_state == incend_state,
		"puddles_initial_matches": runtime_puddles_initial_state == puddles_initial_state,
		"puddles_tile_world_matches": runtime_puddles_tile_world_state == puddles_tile_world_state,
		"puddles_deposit_matches": runtime_puddles_deposit_state == puddles_deposit_state,
		"units_initial_matches": runtime_units_initial_state == units_initial_state,
		"units_random_offset_matches": runtime_units_random_offset_state == units_random_offset_state,
		"units_spawn_matches": runtime_units_spawn_state == units_spawn_state,
		"units_rotation_matches": runtime_units_rotation_state == units_rotation_state,
		"units_notify_matches": runtime_units_notify_state == units_notify_state,
		"splash_damage_matches": bool(splash_damage_state.get("splashDamageGatePassed", false)) and bool(splash_damage_state.get("damageCall", {}) is Dictionary) and float(splash_damage_state.get("damageCall", {}).get("damage", 0.0)) == 6.0,
		"splash_status_matches": bool(splash_status_state.get("statusGatePassed", false)) and bool(splash_status_state.get("statusCall", {}) is Dictionary) and str(splash_status_state.get("statusCall", {}).get("effect", "")) == "burning",
		"splash_heal_matches": bool(splash_heal_state.get("healGatePassed", false)) and int(splash_heal_state.get("healApplications", []).size()) == 1,
		"splash_make_fire_matches": bool(splash_make_fire_state.get("makeFireGatePassed", false)) and int(splash_make_fire_state.get("fireApplications", []).size()) == 1,
		"circle_shooter_rotation_offset_degrees": circle_shooter_rotation_offset_degrees,
		"texture_path": texture_path,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["runtime_spawn_state_shard_matches"] and proof["runtime_step_matches"] and proof["target_context_matches"] and proof["target_step_from_context_matches"] and proof["target_step_state_matches"] and proof["runtime_target_step_shard_matches"] and proof["runtime_hit_application_matches"] and proof["runtime_hit_effects_matches"] and proof["runtime_hit_frag_dispatch_matches"] and proof["runtime_hit_post_frag_dispatch_matches"] and proof["runtime_hit_suppression_matches"] and proof["runtime_hit_splash_damage_dispatch_matches"] and proof["runtime_heals_matches"] and proof["runtime_test_collision_matches"] and proof["runtime_hit_tile_fire_matches"] and proof["runtime_hit_tile_heal_matches"] and proof["runtime_hit_tile_enemy_direct_matches"] and proof["runtime_hit_tile_lifesteal_matches"] and proof["runtime_handle_pierce_matches"] and proof["runtime_hit_entity_damage_cap_matches"] and proof["runtime_hit_entity_lifesteal_matches"] and proof["runtime_hit_entity_armor_damage_matches"] and proof["runtime_hit_entity_unit_effects_matches"] and proof["runtime_hit_entity_unit_destroy_event_matches"] and proof["runtime_hit_entity_handle_pierce_matches"] and proof["angle_helper_matches"] and proof["impact_half_circle_matches"] and proof["removed_trail_fade_matches"] and proof["removed_frag_dispatch_matches"] and proof["despawned_dispatch_matches"] and proof["despawned_effect_matches"] and proof["despawned_sound_matches"] and proof["despawned_shake_matches"] and proof["init_initial_matches"] and proof["init_spawn_bullets_matches"] and proof["runtime_init_type_defaults_matches"] and proof["runtime_init_frag_velocity_matches"] and proof["runtime_init_lightning_type_matches"] and proof["runtime_init_light_radius_matches"] and proof["runtime_init_draw_size_matches"] and proof["runtime_init_range_assignment_matches"] and proof["runtime_calculate_range_override_matches"] and proof["runtime_calculate_range_spawn_unit_matches"] and proof["runtime_calculate_range_despawn_unit_matches"] and proof["runtime_calculate_range_fallback_matches"] and proof["runtime_continuous_damage_default_matches"] and proof["runtime_damage_multiplier_matches"] and proof["runtime_rotation_degrees_matches"] and proof["runtime_trail_effects_chance_matches"] and proof["runtime_trail_effects_interval_matches"] and proof["runtime_scalar_range_change_matches"] and proof["runtime_scalar_inaccuracy_matches"] and proof["runtime_scalar_lifetime_seconds_matches"] and proof["runtime_scalar_world_speed_matches"] and proof["runtime_scalar_velocity_matches"] and proof["runtime_scalar_hit_size_matches"] and proof["runtime_scalar_damage_matches"] and proof["runtime_scalar_ammo_multiplier_matches"] and proof["runtime_scalar_reload_multiplier_matches"] and proof["runtime_scalar_scale_matches"] and proof["runtime_arc_angles_forward_distance_matches"] and proof["runtime_arc_angles_backward_distance_matches"] and proof["runtime_arc_mathf_mod_float_matches"] and proof["runtime_arc_angles_angle_dist_matches"] and proof["runtime_arc_angles_move_toward_matches"] and proof["runtime_arc_angles_angle_matches"] and proof["runtime_arc_angles_trns_vec_matches"] and proof["update_dispatch_matches"] and proof["update_bullet_interval_matches"] and proof["update_trail_matches"] and proof["velocity_vector_matches"] and proof["keep_velocity_matches"] and proof["homing_initial_matches"] and proof["homing_target_velocity_matches"] and proof["homing_follow_aim_matches"] and proof["weaving_matches"] and proof["weaving_rotate_speed_matches"] and proof["vec2_limit_matches"] and proof["weaving_circle_shooter_matches"] and proof["frags_initial_matches"] and proof["frags_random_geometry_matches"] and proof["frags_create_call_matches"] and proof["frags_increment_matches"] and proof["incend_matches"] and proof["puddles_initial_matches"] and proof["puddles_tile_world_matches"] and proof["puddles_deposit_matches"] and proof["units_initial_matches"] and proof["units_random_offset_matches"] and proof["units_spawn_matches"] and proof["units_rotation_matches"] and proof["units_notify_matches"] and proof["splash_damage_matches"] and proof["splash_status_matches"] and proof["splash_heal_matches"] and proof["splash_make_fire_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BULLET_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BulletRuntimeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

