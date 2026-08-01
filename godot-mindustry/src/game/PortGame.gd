extends "res://src/game/SourceContinuousLiquidTurretBuildPortBridge.gd"
class_name PortGame

const ContentRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const generated_class_registry := preload("res://src/generated/GeneratedClassRegistry.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const mindustry_time_script := preload("res://src/runtime/Time.gd")
const source_rules_defaults := preload("res://src/game/SourceRulesDefaults.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_world_terrain_runtime_state_script := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const source_world_initial_build_runtime_state_script := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const source_world_viewport := preload("res://src/game/SourceWorldViewport.gd")
const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")
const source_conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const source_drill_dump_runtime_state_script := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const source_drill_runtime_state_script := preload("res://src/game/SourceDrillRuntimeState.gd")
const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_core_inventory_runtime_state := preload("res://src/game/SourceCoreInventoryRuntimeState.gd")
const source_wave_spawn_runtime_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const source_wave_timing_runtime_state_script := preload("res://src/game/SourceWaveTimingRuntimeState.gd")
const source_enemy_unit_runtime_state := preload("res://src/game/SourceEnemyUnitRuntimeState.gd")
const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const source_input_runtime := preload("res://src/game/SourceInputRuntime.gd")
const source_input_event_runtime_state := preload("res://src/game/SourceInputEventRuntimeState.gd")
const source_game_loop_runtime_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const source_game_config_runtime_state := preload("res://src/game/SourceGameConfigRuntimeState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const source_input_viewport_runtime_state := preload("res://src/game/SourceInputViewportRuntimeState.gd")
const source_game_runtime_summary_state := preload("res://src/game/SourceGameRuntimeSummaryState.gd")
const source_game_over_core_destroyed_state_script := preload("res://src/game/SourceGameOverCoreDestroyedState.gd")
const source_core_damage_runtime_state := preload("res://src/game/SourceCoreDamageRuntimeState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_ui_defaults := preload("res://src/game/SourceUiDefaults.gd")
const source_node_binding_runtime_state := preload("res://src/game/SourceNodeBindingRuntimeState.gd")
const source_hud_runtime_state := preload("res://src/game/SourceHudRuntimeState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_liquid_reaction_state := preload("res://src/game/SourceLiquidReactionState.gd")
const source_core_defaults := preload("res://src/game/SourceCoreDefaults.gd")
const source_consumer_defaults := preload("res://src/game/SourceConsumerDefaults.gd")
const source_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_factory_runtime_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const source_factory_simulation_runtime_state_script := preload("res://src/game/SourceFactorySimulationRuntimeState.gd")
const source_factory_simulation_apply_state_script := preload("res://src/game/SourceFactorySimulationApplyState.gd")
const source_power_defaults := preload("res://src/game/SourcePowerDefaults.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime_state := preload("res://src/game/SourceBulletRuntimeState.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const source_placed_power_battery_runtime_state := preload("res://src/game/SourcePlacedPowerBatteryRuntimeState.gd")
const source_placed_power_distribution_runtime_state := preload("res://src/game/SourcePlacedPowerDistributionRuntimeState.gd")
const source_bullet_type_create_state := preload("res://src/game/SourceBulletTypeCreateState.gd")
const source_bullet_type_create_incend_state_script := preload("res://src/game/SourceBulletTypeCreateIncendState.gd")
const source_bullet_type_create_units_state := preload("res://src/game/SourceBulletTypeCreateUnitsState.gd")
const source_bullet_type_create_splash_damage_state := preload("res://src/game/SourceBulletTypeCreateSplashDamageState.gd")
const source_bullet_type_create_frags_state := preload("res://src/game/SourceBulletTypeCreateFragsState.gd")
const source_bullet_type_create_puddles_state := preload("res://src/game/SourceBulletTypeCreatePuddlesState.gd")
const source_bullet_type_hit_state := preload("res://src/game/SourceBulletTypeHitState.gd")
const source_bullet_type_draw_state_script := preload("res://src/game/SourceBulletTypeDrawState.gd")
const source_bullet_type_damage_state := preload("res://src/game/SourceBulletTypeDamageState.gd")
const source_bullet_type_lifecycle_state := preload("res://src/game/SourceBulletTypeLifecycleState.gd")
const source_bullet_type_hit_core_state := preload("res://src/game/SourceBulletTypeHitCoreState.gd")
const source_bullet_type_hit_tile_state := preload("res://src/game/SourceBulletTypeHitTileState.gd")
const source_bullet_type_init_range_state := preload("res://src/game/SourceBulletTypeInitRangeState.gd")
const source_bullet_type_init_state := preload("res://src/game/SourceBulletTypeInitState.gd")
const source_bullet_type_update_state := preload("res://src/game/SourceBulletTypeUpdateState.gd")
const source_turret_cell_registry_state := preload("res://src/game/SourceTurretCellRegistryState.gd")
const source_turret_property_state := preload("res://src/game/SourceTurretPropertyState.gd")
const source_turret_simulation_state := preload("res://src/game/SourceTurretSimulationState.gd")
const source_turret_combat_state := preload("res://src/game/SourceTurretCombatState.gd")
const source_turret_init_state_script := preload("res://src/game/SourceTurretInitState.gd")
const source_turret_presentation_state := preload("res://src/game/SourceTurretPresentationState.gd")
const source_turret_placement_state := preload("res://src/game/SourceTurretPlacementState.gd")
const source_turret_range_state := preload("res://src/game/SourceTurretRangeState.gd")
const source_liquid_turret_init_state_script := preload("res://src/game/SourceLiquidTurretInitState.gd")
const source_liquid_turret_build_state := preload("res://src/game/SourceLiquidTurretBuildState.gd")
const source_continuous_liquid_turret_init_state_script := preload("res://src/game/SourceContinuousLiquidTurretInitState.gd")
const source_power_turret_build_state := preload("res://src/game/SourcePowerTurretBuildState.gd")
const source_item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")
const source_item_turret_init_state := preload("res://src/game/SourceItemTurretInitState.gd")
const source_item_entry_state := preload("res://src/game/SourceItemEntryState.gd")
const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_ability_state := preload("res://src/game/SourceAbilityState.gd")
const source_base_turret_draw_state := preload("res://src/game/SourceBaseTurretDrawState.gd")
const source_tractor_beam_turret_lifecycle_state := preload("res://src/game/SourceTractorBeamTurretLifecycleState.gd")
const source_tractor_beam_turret_build_update_tile_flow_state := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileFlowState.gd")
const source_tractor_beam_turret_build_update_tile_look_target_guard_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileLookTargetGuardState.gd")
const source_tractor_beam_turret_build_update_tile_sound_loop_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileSoundLoopState.gd")
const source_tractor_beam_turret_build_update_tile_angle_to_target_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.gd")
const source_tractor_beam_turret_build_update_tile_rotation_move_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileRotationMoveState.gd")
const source_tractor_beam_turret_build_update_tile_last_target_position_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileLastTargetPositionState.gd")
const source_tractor_beam_turret_build_update_tile_active_strength_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.gd")
const source_tractor_beam_turret_build_update_tile_inactive_strength_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.gd")
const source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState.gd")
const source_tractor_beam_turret_build_update_tile_damage_pierce_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileDamagePierceState.gd")
const source_tractor_beam_turret_build_update_tile_status_apply_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileStatusApplyState.gd")
const source_tractor_beam_turret_build_update_tile_any_true_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAnyTrueState.gd")
const source_tractor_beam_turret_build_update_tile_impulse_net_state_script := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileImpulseNetState.gd")
const source_tractor_beam_turret_build_draw_state_script := preload("res://src/game/SourceTractorBeamTurretBuildDrawState.gd")
const source_weapon_defaults := preload("res://src/game/SourceWeaponDefaults.gd")
const source_status_apply_state := preload("res://src/game/SourceStatusApplyState.gd")
const source_shoot_pattern_defaults := preload("res://src/game/SourceShootPatternDefaults.gd")
const source_child_state := preload("res://src/game/SourceChildState.gd")
const source_basic_comp_state := preload("res://src/game/SourceBasicCompState.gd")
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_unit_metadata_state := preload("res://src/game/SourceUnitMetadataState.gd")
const source_item_defaults := preload("res://src/game/SourceItemDefaults.gd")
const source_item_metadata_state := preload("res://src/game/SourceItemMetadataState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_block_footprint := preload("res://src/game/SourceBlockFootprint.gd")
const source_block_placement := preload("res://src/game/SourceBlockPlacement.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_building_time_state := preload("res://src/game/SourceBuildingTimeState.gd")
const source_building_meta_state := preload("res://src/game/SourceBuildingMetaState.gd")
const source_building_control_state := preload("res://src/game/SourceBuildingControlState.gd")
const source_builder_runtime_state := preload("res://src/game/SourceBuilderRuntimeState.gd")
const source_builder_draw_state := preload("res://src/game/SourceBuilderDrawState.gd")
const source_building_damage_state := preload("res://src/game/SourceBuildingDamageState.gd")
const source_building_sense_state := preload("res://src/game/SourceBuildingSenseState.gd")
const source_building_set_prop_state := preload("res://src/game/SourceBuildingSetPropState.gd")
const source_building_visibility_state := preload("res://src/game/SourceBuildingVisibilityState.gd")
const source_building_core_state := preload("res://src/game/SourceBuildingCoreState.gd")
const source_building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const source_building_payload_state := preload("res://src/game/SourceBuildingPayloadState.gd")
const source_building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")
const source_construct_block_state := preload("res://src/game/SourceConstructBlockState.gd")
const source_construct_build_state := preload("res://src/game/SourceConstructBuildState.gd")
const source_building_display_state := preload("res://src/game/SourceBuildingDisplayState.gd")
const source_building_configure_state := preload("res://src/game/SourceBuildingConfigureState.gd")
const source_building_interaction_state := preload("res://src/game/SourceBuildingInteractionState.gd")
const source_overdrive_boost_state := preload("res://src/game/SourceOverdriveBoostState.gd")
const source_overdrive_projector_state := preload("res://src/game/SourceOverdriveProjectorState.gd")
const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_power_generator_state := preload("res://src/game/SourcePowerGeneratorState.gd")
const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_consume_module_registry := preload("res://src/game/SourceConsumeModuleRegistry.gd")
const source_thermal_generator_state := preload("res://src/game/SourceThermalGeneratorState.gd")
const source_unit_payload_dump_state := preload("res://src/game/SourceUnitPayloadDumpState.gd")
const source_unit_destroy_state := preload("res://src/game/SourceUnitDestroyState.gd")
const source_unit_tether_state := preload("res://src/game/SourceUnitTetherState.gd")
const source_block_unit_state := preload("res://src/game/SourceBlockUnitState.gd")
const source_block_query_state := preload("res://src/game/SourceBlockQueryState.gd")
const source_block_query_basic_state_script := preload("res://src/game/SourceBlockQueryBasicState.gd")
const source_block_query_consumer_state_script := preload("res://src/game/SourceBlockQueryConsumerState.gd")
const source_block_query_placement_state_script := preload("res://src/game/SourceBlockQueryPlacementState.gd")
const source_block_query_darkness_state_script := preload("res://src/game/SourceBlockQueryDarknessState.gd")
const source_block_query_filter_state_script := preload("res://src/game/SourceBlockQueryFilterState.gd")
const source_block_requirements_state := preload("res://src/game/SourceBlockRequirementsState.gd")
const source_block_research_requirements_state := preload("res://src/game/SourceBlockResearchRequirementsState.gd")
const source_block_get_dependencies_state := preload("res://src/game/SourceBlockGetDependenciesState.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_block_post_init_state := preload("res://src/game/SourceBlockPostInitState.gd")
const source_block_init_sound_state := preload("res://src/game/SourceBlockInitSoundState.gd")
const source_block_init_flags_state := preload("res://src/game/SourceBlockInitFlagsState.gd")
const source_block_init_health_state := preload("res://src/game/SourceBlockInitHealthState.gd")
const source_block_init_clip_state := preload("res://src/game/SourceBlockInitClipState.gd")
const source_block_init_placement_state := preload("res://src/game/SourceBlockInitPlacementState.gd")
const source_block_init_build_time_state := preload("res://src/game/SourceBlockInitBuildTimeState.gd")
const source_block_init_consumer_state := preload("res://src/game/SourceBlockInitConsumerState.gd")
const source_block_init_building_default_state_script := preload("res://src/game/SourceBlockInitBuildingDefaultState.gd")
const source_block_init_item_liquid_filters_state_script := preload("res://src/game/SourceBlockInitItemLiquidFiltersState.gd")
const source_block_init_set_bars_call_state_script := preload("res://src/game/SourceBlockInitSetBarsCallState.gd")
const source_block_init_stats_categories_state_script := preload("res://src/game/SourceBlockInitStatsCategoriesState.gd")
const source_block_init_logic_configurable_state_script := preload("res://src/game/SourceBlockInitLogicConfigurableState.gd")
const source_block_init_buffered_power_state_script := preload("res://src/game/SourceBlockInitBufferedPowerState.gd")
const source_block_init_sandbox_visibility_state_script := preload("res://src/game/SourceBlockInitSandboxVisibilityState.gd")
const source_block_check_content_array_capacity_state_script := preload("res://src/game/SourceBlockCheckContentArrayCapacityState.gd")
const source_block_reinitialize_consumers_state := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")
const source_block_load_state := preload("res://src/game/SourceBlockLoadState.gd")
const source_block_plan_state := preload("res://src/game/SourceBlockPlanState.gd")
const source_block_sense_state := preload("res://src/game/SourceBlockSenseState.gd")
const source_build_payload_state := preload("res://src/game/SourceBuildPayloadState.gd")
const source_build_payload_draw_state_script := preload("res://src/game/SourceBuildPayloadDrawState.gd")
const source_build_payload_lifecycle_state := preload("res://src/game/SourceBuildPayloadLifecycleState.gd")
const source_block_producer_state := preload("res://src/game/SourceBlockProducerState.gd")
const source_block_producer_build_update_state := preload("res://src/game/SourceBlockProducerBuildUpdateState.gd")
const source_block_producer_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_unit_payload_content_state_script := preload("res://src/game/SourceUnitPayloadContentState.gd")
const source_unit_payload_requirements_state_script := preload("res://src/game/SourceUnitPayloadRequirementsState.gd")
const source_unit_payload_io_state := preload("res://src/game/SourceUnitPayloadIoState.gd")
const source_unit_payload_draw_state := preload("res://src/game/SourceUnitPayloadDrawState.gd")
const source_sync_state := preload("res://src/game/SourceSyncState.gd")
const source_building_tether_state := preload("res://src/game/SourceBuildingTetherState.gd")
const content_catalog_script := preload("res://src/mindustry/content/ContentCatalog.gd")

var tile_size := 0
var config: Dictionary = {}
var textures: Dictionary = {}
var block_texture_cache: Dictionary = {}
var content_counts: Dictionary = {"items": 0, "liquids": 0, "blocks": 0, "units": 0}
var generated_class_count := 0
var loaded_generated_scripts: Dictionary = {}
var loaded_generated_class_names: Array[String] = []
var loaded_generated_instances: Dictionary = {}
var loaded_generated_instance_names: Array[String] = []
var all_generated_scripts: Dictionary = {}
var all_generated_instances: Dictionary = {}
var all_generated_load_failures: Array[String] = []
var all_generated_instance_failures: Array[String] = []
var content_catalog: RefCounted
var build_palette: Array = []
var selected_build_index := 0
var ore_items_by_cell: Dictionary = {}
var placed_blocks: Dictionary = {}
var placed_block_origins: Dictionary = {}
var mend_projector_charges: Dictionary = {}
var mend_projector_smooth_efficiency: Dictionary = {}
var mend_projector_heat: Dictionary = {}
var mend_projector_phase_heat: Dictionary = {}
var mend_projector_optional_efficiency: Dictionary = {}
var mend_projector_booster_items: Dictionary = {}
var mend_projector_booster_timers: Dictionary = {}
var overdrive_projector_charges: Dictionary = {}
var overdrive_projector_smooth_efficiency: Dictionary = {}
var overdrive_projector_heat: Dictionary = {}
var overdrive_projector_phase_heat: Dictionary = {}
var overdrive_projector_optional_efficiency: Dictionary = {}
var overdrive_projector_booster_items: Dictionary = {}
var overdrive_projector_use_progress: Dictionary = {}
var initial_world_block_count := 0
var initial_occupied_cell_count := 0
var player_placed_block_count := 0
var last_placed_block_id := ""
var last_placed_block_size := 0
var last_placed_block_requirements: Array = []
var last_placed_cell := Vector2i.ZERO
var last_placed_occupied_cell_count := 0
var last_place_blocked := false
var last_mend_projector_healed_amount := 0.0
var last_mend_projector_healed_block_id := ""
var last_mend_projector_healed_cell := Vector2i.ZERO
var last_mend_projector_target_health := 0.0
var last_mend_projector_target_max_health := 0.0
var last_overdrive_projector_boost_range := 0.0
var last_overdrive_projector_boost := 0.0
var last_overdrive_projector_boost_duration := 0.0
var last_overdrive_projector_boosted_block_id := ""
var last_overdrive_projector_boosted_cell := Vector2i.ZERO
var core_inventory := 0
var core_items: Dictionary = {}
var core_item_capacity := 0
var rules_build_cost_multiplier := source_rules_defaults.BUILD_COST_MULTIPLIER_DEFAULT
var core_incinerates := source_core_defaults.RULES_CORE_INCINERATES_DEFAULT
var core_incinerate_non_buildable := source_core_defaults.INCINERATE_NON_BUILDABLE_DEFAULT
var core_max_health := 0.0
var core_health := 0.0
var core_damage_taken_total := 0.0
var game_over := false
var last_game_over_winner := ""
var drill_output_item_id := source_playable_scenario_defaults.ITEM_COPPER
var drill_ore_cell_count := 0
var drill_output_rate := 0.0
var drill_warmups: Dictionary = {}
var drill_time_drilled: Dictionary = {}
var drill_last_speeds: Dictionary = {}
var drill_items: Dictionary = {}
var drill_dump_timer := 0.0
var drill_dump_cursor := 0
var building_dump_accum := 0.0
var produced_total := 0
var item_progress := 0.0
var transport_progress := 0.0
var conveyor_world_speed := 0.0
var conveyor_path_progress_rate := 0.0
var item_sprites: Array[Sprite2D] = []
var enemy_units: Array = []
var bullets: Array = []
var bullet_hit_count := 0
var last_bullet_hit_damage := 0.0
var last_bullet_target_health_before := 0.0
var last_bullet_target_health_after := 0.0
var last_bullet_target_destroyed := false
var turret_cells: Array = []
var turret_cooldowns: Dictionary = {}
var turret_ammo_stacks: Dictionary = {}
var turret_total_ammo: Dictionary = {}
var turret_barrel_counters: Dictionary = {}
var turret_rotations: Dictionary = {}
var turret_recoils: Dictionary = {}
var bootstrapped_selected_turret_ammo_load_count := 0
var turret_shot_count := 0
var last_turret_fired_ammo_item := ""
var last_turret_fired_damage := 0.0
var last_turret_fired_reload_multiplier := 1.0
var last_turret_fired_range := 0.0
var last_turret_fired_shoot_y := 0.0
var last_turret_fired_shoot_x_offset := 0.0
var last_turret_fired_inaccuracy_range := 0.0
var last_turret_fired_inaccuracy_offset := 0.0
var last_turret_target_rotation := 0.0
var last_turret_rotation := 0.0
var last_turret_angle_delta := 0.0
var last_turret_recoil := 0.0
var last_turret_recoils := 0
var last_turret_cur_recoil := 0.0
var last_turret_recoil_offset := Vector2.ZERO
var wave_index := 1
var last_spawned_wave_index := 0
var last_spawned_wave_count := 0
var last_spawned_wave_groups: Array = []
var wave_cooldown := 0.0
var path_points: Array[Vector2] = []
var hud_label: Label
var camera: Camera2D
var input_runtime := source_input_runtime.new()
var drill_pos := source_playable_scenario_defaults.DRILL_POS
var core_pos := source_playable_scenario_defaults.CORE_POS
var duo_pos := source_playable_scenario_defaults.DUO_POS

func _ready() -> void:
	source_game_loop_runtime_state.ready(self)

func load_config() -> void:
	source_game_config_runtime_state.load_config(self)

func load_content_registry() -> void:
	source_content_registry_runtime_state.load_content_registry(self)

func load_all_generated_scripts() -> void:
	source_content_registry_runtime_state.load_all_generated_scripts(self)

func load_selected_generated_scripts() -> void:
	source_content_registry_runtime_state.load_selected_generated_scripts(self)

func load_textures() -> void:
	source_texture_runtime_state.load_textures(self)

func load_png_texture(path: String) -> Texture2D:
	return source_texture_runtime_state.load_png_texture(path)

func bind_nodes() -> void:
	source_node_binding_runtime_state.bind_nodes(self)

func build_world() -> void:
	source_world_initial_build_runtime_state_script.build_world(self)

func _unhandled_input(event: InputEvent) -> void:
	source_input_event_runtime_state.handle_unhandled_input(self, event)

func set_touch_move_axis(axis: Vector2) -> void:
	input_runtime.set_touch_move_axis(axis)

func set_roblox_move_axis(axis: Vector2) -> void:
	input_runtime.set_roblox_move_axis(axis)

func set_virtual_input_axes(touch_x: float, touch_y: float, roblox_x: float, roblox_y: float) -> void:
	input_runtime.set_virtual_input_axes(touch_x, touch_y, roblox_x, roblox_y)

func source_input_viewport_camera_pan_delta(movement: Vector2, boosted: bool, delta: float) -> Vector2:
	return source_input_viewport_runtime_state.camera_pan_delta(movement, boosted, delta, source_time_defaults.TICK_RATE)

func source_input_viewport_camera_zoom_state(current_zoom: Vector2, zoom_factor: float) -> Dictionary:
	return source_input_viewport_runtime_state.camera_zoom_state(current_zoom, zoom_factor)

func source_input_viewport_fit_camera_state(viewport_size: Vector2) -> Dictionary:
	return source_input_viewport_runtime_state.viewport_fit_camera_state_with_zoom(source_playable_scenario_defaults.WORLD_SIZE, tile_size, viewport_size, source_playable_scenario_defaults.display_camera_zoom_for_viewport(Vector2i(int(viewport_size.x), int(viewport_size.y))))

func source_input_viewport_screen_to_world_state(screen_position: Vector2) -> Dictionary:
	return source_input_viewport_runtime_state.screen_to_world_runtime_state(self, screen_position)

func source_input_viewport_clamped_camera_position_state(proposed_position: Vector2, viewport_size: Vector2) -> Dictionary:
	return source_input_viewport_runtime_state.clamped_camera_position_runtime_state(self, proposed_position, viewport_size)

func source_world_terrain_runtime_state() -> Dictionary:
	return source_world_terrain_runtime_state_script.terrain_plan_state(source_playable_scenario_defaults.background_cells_for_viewport(Vector2i(int(get_viewport().get_visible_rect().size.x), int(get_viewport().get_visible_rect().size.y))), source_playable_scenario_defaults.ore_copper_cells(), source_playable_scenario_defaults.BLOCK_STONE_FLOOR, source_playable_scenario_defaults.BLOCK_ORE_COPPER, source_playable_scenario_defaults.ITEM_COPPER, tile_size)

func source_world_initial_build_runtime_state() -> Dictionary:
	return source_world_initial_build_runtime_state_script.initial_build_plan_state(drill_pos, source_playable_scenario_defaults.conveyor_cells(), core_pos, duo_pos, source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, source_playable_scenario_defaults.BLOCK_CONVEYOR, source_playable_scenario_defaults.BLOCK_CORE_SHARD, source_playable_scenario_defaults.BLOCK_DUO, source_playable_scenario_defaults.path_points(tile_size), tile_size)

func source_item_transport_bootstrap_state() -> Dictionary:
	return source_item_transport_runtime_state_script.bootstrap_state(path_points, source_item_transport_runtime_state_script.ITEM_SPRITE_COUNT_DEFAULT, source_item_transport_runtime_state_script.ITEM_SPRITE_KEY_DEFAULT)

func source_item_transport_runtime_state(progress_before: float, progress_delta: float) -> Dictionary:
	return source_item_transport_runtime_state_script.transport_positions_state(path_points, item_sprites.size(), progress_before, progress_delta)

func source_drill_dump_runtime_state(current_timer: float, source_delta: float, dump_interval: float) -> Dictionary:
	return source_drill_dump_runtime_state_script.dump_timer_state(current_timer, source_delta, dump_interval)

func source_drill_production_runtime_state(current_progress_fraction: float, drill_delay: float, output_delta: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	return source_drill_production_runtime_state_script.game_production_state(self, current_progress_fraction, drill_delay, output_delta, dominant_items, items_total, item_capacity)

func source_drill_runtime_state(seconds: float) -> Dictionary:
	return source_drill_runtime_state_script.runtime_state(source_drill_runtime_state_script.runtime_context(self, seconds, drill_pos, source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, drill_output_item_id, drill_ore_cell_count, source_time_defaults.TICK_RATE), source_drill_runtime_state_script.runtime_callbacks(self))

func apply_world_viewport_fit() -> void:
	source_input_viewport_runtime_state.apply_world_viewport_fit(self)

func world_viewport_fit_runtime_state() -> Dictionary:
	return source_input_viewport_runtime_state.world_viewport_fit_runtime_state(self)

func selected_build_properties(selected) -> Dictionary:
	return source_selected_build_state.properties(selected)

func source_power_generator_get_power_production_state(enabled: bool, power_production: float, production_efficiency: float) -> Dictionary:
	return source_power_generator_state.get_power_production_state(enabled, power_production, production_efficiency)

func source_power_generator_displayed_power_production_state(power_production: float) -> Dictionary:
	return source_power_generator_state.displayed_power_production_state(power_production)

func generated_power_generator_displayed_power_production_bridge_state(power_production: float) -> Dictionary:
	return source_power_generator_state.generated_displayed_power_production_bridge_state(power_production)

func source_power_generator_build_serialization_state(production_efficiency: float, generate_time: float, revision: int, read_production_efficiency_value: float, read_generate_time_value: float) -> Dictionary:
	return source_power_generator_state.build_serialization_state(production_efficiency, generate_time, revision, read_production_efficiency_value, read_generate_time_value)

func source_solar_generator_update_tile_state(enabled: bool, solar_multiplier: float, light_env: float, lighting: bool, ambient_light_alpha: float) -> Dictionary:
	return source_power_generator_state.solar_update_tile_state(enabled, solar_multiplier, light_env, lighting, ambient_light_alpha)

func source_thermal_generator_update_tile_state(sum: float, attribute_env: float) -> Dictionary:
	return source_thermal_generator_state.update_tile_state(sum, attribute_env)

func source_thermal_generator_update_tile_effect_state(source_x: float, source_y: float, production_efficiency: float, effect_chance: float, chance_delta_result: bool, range_x: float, range_y: float, generate_effect_name: String) -> Dictionary:
	return source_thermal_generator_state.update_tile_effect_state(source_x, source_y, production_efficiency, effect_chance, chance_delta_result, range_x, range_y, generate_effect_name)

func source_thermal_generator_update_tile_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, production_efficiency: float, delta_value: float, liquid_capacity: float, current_liquid_amount: float) -> Dictionary:
	return source_thermal_generator_state.update_tile_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, production_efficiency, delta_value, liquid_capacity, current_liquid_amount)

func source_thermal_generator_displayed_power_production_state(power_production: float, display_efficiency_scale: float) -> Dictionary:
	return source_thermal_generator_state.displayed_power_production_state(power_production, display_efficiency_scale)

func source_thermal_generator_init_state(output_liquid_present: bool, light_clip_size: float, size: float) -> Dictionary:
	return source_thermal_generator_state.init_state(output_liquid_present, light_clip_size, size)

func source_thermal_generator_total_progress_state(enabled: bool, sum: float, super_total_progress: float) -> Dictionary:
	return source_thermal_generator_state.total_progress_state(enabled, sum, super_total_progress)

func source_thermal_generator_after_picked_up_state(sum: float, super_after_picked_up_state: Dictionary) -> Dictionary:
	return source_thermal_generator_state.after_picked_up_state(sum, super_after_picked_up_state)

func source_thermal_generator_on_proximity_added_state(sum_attribute: float, super_on_proximity_added_state: Dictionary) -> Dictionary:
	return source_thermal_generator_state.on_proximity_added_state(sum_attribute, super_on_proximity_added_state)

func source_thermal_generator_can_place_on_state(linked_attribute_sum: float, min_efficiency: float) -> Dictionary:
	return source_thermal_generator_state.can_place_on_state(linked_attribute_sum, min_efficiency)

func source_thermal_generator_draw_light_state(source_x: float, source_y: float, source_time: float, production_efficiency: float, size: float) -> Dictionary:
	return source_thermal_generator_state.draw_light_state(source_x, source_y, source_time, production_efficiency, size)

func source_thermal_generator_set_stats_state(power_production: float, display_efficiency_scale: float, display_efficiency: bool, size: float, floating: bool, super_set_stats_state: Dictionary) -> Dictionary:
	return source_thermal_generator_state.set_stats_state(power_production, display_efficiency_scale, display_efficiency, size, floating, super_set_stats_state)

func source_thermal_generator_set_stats_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, size: float) -> Dictionary:
	return source_thermal_generator_state.set_stats_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, size)

func source_thermal_generator_draw_place_state(x: int, y: int, rotation_value: int, valid: bool, display_efficiency: bool, sum_attribute: float, display_efficiency_scale: float) -> Dictionary:
	return source_thermal_generator_state.draw_place_state(x, y, rotation_value, valid, display_efficiency, sum_attribute, display_efficiency_scale)

func source_power_generator_warmup_state(enabled: bool, production_efficiency: float) -> Dictionary:
	return source_power_generator_state.warmup_state(enabled, production_efficiency)

func source_power_generator_should_explode_state(warmup_value: float, explosion_min_warmup: float) -> Dictionary:
	return source_power_generator_state.should_explode_state(warmup_value, explosion_min_warmup)

func source_power_generator_ambient_volume_state(production_efficiency: float) -> Dictionary:
	return source_power_generator_state.ambient_volume_state(production_efficiency)

func source_power_generator_create_explosion_gate_state(should_explode_value: bool) -> Dictionary:
	return source_power_generator_state.create_explosion_gate_state(should_explode_value)

func source_power_generator_create_explosion_damage_state(should_explode_value: bool, source_x: float, source_y: float, explosion_radius: int, explosion_damage: int, source_tilesize: int) -> Dictionary:
	return source_power_generator_state.create_explosion_damage_state(should_explode_value, source_x, source_y, explosion_radius, explosion_damage, source_tilesize)

func source_power_generator_create_explosion_effect_sound_state(should_explode_value: bool, source_x: float, source_y: float, explode_effect_value: String, explode_sound_value: String) -> Dictionary:
	return source_power_generator_state.create_explosion_effect_sound_state(should_explode_value, source_x, source_y, explode_effect_value, explode_sound_value)

func source_power_generator_create_explosion_puddle_loop_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_loop_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles)

func source_power_generator_create_explosion_puddle_vector_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_range: float, random_angle_units: Array, random_range_units: Array) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_vector_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_range, random_angle_units, random_range_units)

func source_power_generator_create_explosion_puddle_tile_world_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, source_x: float, source_y: float, source_tilesize: int, tmp_v1_vectors: Array) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_tile_world_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, source_x, source_y, source_tilesize, tmp_v1_vectors)

func source_power_generator_create_explosion_puddle_deposit_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_amount: float, tile_world_calls: Array) -> Dictionary:
	return source_power_generator_state.create_explosion_puddle_deposit_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_amount, tile_world_calls)

func source_power_generator_create_explosion_shake_state(should_explode_value: bool, source_x: float, source_y: float, explosion_shake: float, explosion_shake_duration: float) -> Dictionary:
	return source_power_generator_state.create_explosion_shake_state(should_explode_value, source_x, source_y, explosion_shake, explosion_shake_duration)

func source_power_generator_on_destroyed_reactor_explosion_state(reactor_explosions: bool = source_power_generator_state.SOURCE_RULES_REACTOR_EXPLOSIONS_DEFAULT, create_explosion_state: Dictionary = {}) -> Dictionary:
	return source_power_generator_state.on_destroyed_reactor_explosion_state(reactor_explosions, create_explosion_state)

func source_overdrive_projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	return source_overdrive_projector_state.projector_range(overdrive_projector, phase_heat)

func source_overdrive_projector_select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:
	return source_overdrive_projector_state.select_state(overdrive_projector, phase_heat)

func source_overdrive_projector_place_state(overdrive_projector) -> Dictionary:
	return source_overdrive_projector_state.place_state(overdrive_projector)

func source_overdrive_projector_target_filter_state(overdrive_projector, target_block, distance: float, phase_heat := 0.0) -> Dictionary:
	return source_overdrive_projector_state.target_filter_state(overdrive_projector, target_block, distance, phase_heat)

func source_building_apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:
	return source_building_time_state.apply_boost_state(current_time_scale, current_duration, intensity, duration, can_overdrive, source_block_defaults.TIME_SCALE_BOOST_EPSILON)

func source_building_time_scale_decay_state(current_time_scale: float, current_duration: float, source_delta: float) -> Dictionary:
	return source_building_time_state.time_scale_decay_state(current_time_scale, current_duration, source_delta, source_block_defaults.TIME_SCALE_DEFAULT)

func source_building_delta(source_delta: float, time_scale: float) -> float:
	return source_building_time_state.delta(source_delta, time_scale)

func source_building_edelta(source_delta: float, time_scale: float, efficiency: float) -> float:
	return source_building_time_state.edelta(source_delta, time_scale, efficiency)

func source_overdrive_projector_light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	return source_overdrive_projector_state.light_state(overdrive_projector, smooth_efficiency)

func source_overdrive_projector_draw_state(overdrive_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return source_overdrive_projector_state.draw_state(overdrive_projector, heat, phase_heat, source_world_defaults.TILESIZE, source_time_ticks, lod_l2, lod_alpha2)

func source_overdrive_projector_real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_overdrive_projector_state.real_boost(overdrive_projector, phase_heat, efficiency)

func source_overdrive_projector_boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_overdrive_projector_state.boost_bar_fraction(overdrive_projector, phase_heat, efficiency)

func source_mend_projector_repair_amount(mend_projector, target_block, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_mend_projector_state.repair_amount(mend_projector, target_block, phase_heat, efficiency)

func source_mend_projector_light_state(mend_projector, smooth_efficiency: float) -> Dictionary:
	return source_mend_projector_state.light_state(mend_projector, smooth_efficiency)

func source_mend_projector_reload(mend_projector) -> float:
	return source_mend_projector_state.projector_reload(mend_projector)

func source_mend_projector_use_time(mend_projector) -> float:
	return source_mend_projector_state.use_time(mend_projector)

func source_mend_projector_is_projector(block) -> bool:
	return source_selected_build_state.is_mend_projector(block)

func source_overdrive_projector_reload(overdrive_projector) -> float:
	return source_overdrive_projector_state.projector_reload(overdrive_projector)

func source_overdrive_projector_use_time(overdrive_projector) -> float:
	return source_overdrive_projector_state.use_time(overdrive_projector)

func source_overdrive_projector_has_boost(overdrive_projector) -> bool:
	return source_overdrive_projector_state.has_boost(overdrive_projector)

func source_overdrive_projector_is_projector(block) -> bool:
	return source_selected_build_state.is_overdrive_projector(block)

func source_mend_projector_progress(mend_projector, charge: float) -> float:
	return source_mend_projector_state.progress(mend_projector, charge)

func source_mend_projector_select_state(mend_projector, phase_heat := 0.0) -> Dictionary:
	return source_mend_projector_state.select_state(mend_projector, phase_heat)

func source_mend_projector_place_state(mend_projector) -> Dictionary:
	return source_mend_projector_state.place_state(mend_projector)

func source_mend_projector_draw_state(mend_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return source_mend_projector_state.draw_state(mend_projector, heat, phase_heat, float(source_world_defaults.TILESIZE), source_time_ticks, lod_l2, lod_alpha2)

func source_power_graph_add_role_state(build_present: bool, power_present: bool, graph_matches: bool, power_init: bool, old_graph_present: bool, old_graph_is_self: bool, old_graph_has_entity: bool, outputs_power: bool, consumes_power: bool, has_cons_power: bool, cons_power_buffered: bool) -> Dictionary:
	return source_power_graph_state.add_role_state(build_present, power_present, graph_matches, power_init, old_graph_present, old_graph_is_self, old_graph_has_entity, outputs_power, consumes_power, has_cons_power, cons_power_buffered)

func source_power_graph_add_graph_state(graph_is_self: bool, graph_all_size: int, all_size: int, graph_has_entity: bool, graph_tiles: Array) -> Dictionary:
	return source_power_graph_state.add_graph_state(graph_is_self, graph_all_size, all_size, graph_has_entity, graph_tiles)

func source_power_graph_check_add_state(entity_present: bool) -> Dictionary:
	return source_power_graph_state.check_add_state(entity_present)

func source_power_graph_clear_state(all: Array, producers: Array, consumers: Array, batteries: Array, entity_present: bool) -> Dictionary:
	return source_power_graph_state.clear_state(all, producers, consumers, batteries, entity_present)

func source_power_graph_reflow_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.reflow_state(tile)

func source_power_graph_remove_list_state(all: Array, producers: Array, consumers: Array, batteries: Array, build) -> Dictionary:
	return source_power_graph_state.remove_list_state(all, producers, consumers, batteries, build)

func source_power_graph_remove_branch_seed_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.remove_branch_seed_state(tile)

func source_power_graph_remove_branch_bfs_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.remove_branch_bfs_state(tile)

func source_power_graph_remove_branch_update_state(tile: Dictionary) -> Dictionary:
	return source_power_graph_state.remove_branch_update_state(tile)

func source_power_graph_remove_empty_entity_state(tile: Dictionary, entity_present: bool) -> Dictionary:
	return source_power_graph_state.remove_empty_entity_state(tile, entity_present)

func source_power_graph_get_id_state(graph_id: int) -> Dictionary:
	return source_power_graph_state.get_id_state(graph_id)

func generated_power_graph_get_id_bridge_state(graph_id: int) -> Dictionary:
	return source_power_graph_state.generated_get_id_bridge_state(graph_id)

func source_power_graph_to_string_state(producers: String, consumers: String, batteries: String, all: String, graph_id: int) -> String:
	return source_power_graph_state.to_string_state(producers, consumers, batteries, all, graph_id)

func source_consume_power_ignore_state(buffered: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.ignore_state(buffered)

func generated_consume_power_ignore_bridge_state(buffered: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_ignore_bridge_state(buffered)

func source_consume_power_apply_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.apply_state(block_has_power_before, block_cons_power_before, consume_power_state)

func generated_consume_power_apply_bridge_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_apply_bridge_state(block_has_power_before, block_cons_power_before, consume_power_state)

func source_consume_power_efficiency_state(power_status: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.efficiency_state(power_status)

func generated_consume_power_efficiency_bridge_state(power_status: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_efficiency_bridge_state(power_status)

func source_consume_power_display_state(buffered: bool, usage: float, capacity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.display_state(buffered, usage, capacity, source_time_defaults.TICK_RATE)

func generated_consume_power_display_bridge_state(buffered: bool, usage: float, capacity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_display_bridge_state(buffered, usage, capacity, source_time_defaults.TICK_RATE)

func source_consume_power_condition_requested_power_state(usage: float, consume_get: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.condition_requested_power_state(usage, consume_get)

func generated_consume_power_condition_requested_power_bridge_state(usage: float, consume_get: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_condition_requested_power_bridge_state(usage, consume_get)

func source_consume_power_dynamic_requested_power_state(usage_get: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.dynamic_requested_power_state(usage_get)

func generated_consume_power_dynamic_requested_power_bridge_state(usage_get: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_dynamic_requested_power_bridge_state(usage_get)

func source_consume_power_dynamic_display_state(displayed_power_usage: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.dynamic_display_state(displayed_power_usage, source_time_defaults.TICK_RATE)

func generated_consume_power_dynamic_display_bridge_state(displayed_power_usage: float) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_dynamic_display_bridge_state(displayed_power_usage, source_time_defaults.TICK_RATE)

func source_consume_item_flammable_item_efficiency_multiplier_state(item_flammability: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.flammable_item_efficiency_multiplier_state(item_flammability)

func generated_consume_item_flammable_item_efficiency_multiplier_bridge_state(item_flammability: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_flammable_item_efficiency_multiplier_bridge_state(item_flammability)

func source_consume_item_flammable_constructor_state(min_flammability: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.flammable_constructor_state(min_flammability)

func generated_consume_item_flammable_constructor_bridge_state(min_flammability: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_flammable_constructor_bridge_state(min_flammability)

func source_consume_item_flammable_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.flammable_default_constructor_state(source_consumer_defaults.CONSUME_ITEM_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func generated_consume_item_flammable_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_flammable_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func source_consume_item_explosive_item_efficiency_multiplier_state(item_explosiveness: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.explosive_item_efficiency_multiplier_state(item_explosiveness)

func generated_consume_item_explosive_item_efficiency_multiplier_bridge_state(item_explosiveness: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_explosive_item_efficiency_multiplier_bridge_state(item_explosiveness)

func source_consume_item_explosive_constructor_state(min_charge: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.explosive_constructor_state(min_charge)

func generated_consume_item_explosive_constructor_bridge_state(min_charge: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_explosive_constructor_bridge_state(min_charge)

func source_consume_item_explosive_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.explosive_default_constructor_state(source_consumer_defaults.CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT)

func generated_consume_item_explosive_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_explosive_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT)

func source_consume_item_radioactive_item_efficiency_multiplier_state(item_radioactivity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.radioactive_item_efficiency_multiplier_state(item_radioactivity)

func generated_consume_item_radioactive_item_efficiency_multiplier_bridge_state(item_radioactivity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_radioactive_item_efficiency_multiplier_bridge_state(item_radioactivity)

func source_consume_item_radioactive_constructor_state(min_radioactivity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.radioactive_constructor_state(min_radioactivity)

func generated_consume_item_radioactive_constructor_bridge_state(min_radioactivity: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_radioactive_constructor_bridge_state(min_radioactivity)

func source_consume_item_radioactive_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.radioactive_default_constructor_state(source_consumer_defaults.CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT)

func generated_consume_item_radioactive_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_radioactive_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT)

func source_consume_item_charged_item_efficiency_multiplier_state(item_charge: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.charged_item_efficiency_multiplier_state(item_charge)

func generated_consume_item_charged_item_efficiency_multiplier_bridge_state(item_charge: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_charged_item_efficiency_multiplier_bridge_state(item_charge)

func source_consume_item_charged_constructor_state(min_charge: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.charged_constructor_state(min_charge)

func generated_consume_item_charged_constructor_bridge_state(min_charge: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_charged_constructor_bridge_state(min_charge)

func source_consume_item_charged_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.charged_default_constructor_state(source_consumer_defaults.CONSUME_ITEM_CHARGED_MIN_CHARGE_DEFAULT)

func generated_consume_item_charged_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_attribute_state.generated_charged_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_CHARGED_MIN_CHARGE_DEFAULT)

func source_consume_item_filter_item_efficiency_multiplier_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.item_efficiency_multiplier_state()

func generated_consume_item_filter_item_efficiency_multiplier_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_item_efficiency_multiplier_bridge_state()

func source_consume_item_filter_constructor_state(item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.constructor_state(item)

func generated_consume_item_filter_constructor_bridge_state(item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_constructor_bridge_state(item)

func source_consume_item_filter_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.default_constructor_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func generated_consume_item_filter_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func source_consume_items_constructor_state(item_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.constructor_state(item_stacks)

func generated_consume_items_constructor_bridge_state(item_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.generated_constructor_bridge_state(item_stacks)

func source_consume_items_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.default_constructor_state(source_consumer_defaults.CONSUME_ITEMS_EMPTY_STACKS)

func generated_consume_items_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEMS_EMPTY_STACKS)

func source_consume_item_filter_apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.apply_state(block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids)

func generated_consume_item_filter_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_apply_bridge_state(block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids)

func source_consume_items_apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, item_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.apply_state(block_has_items_before, block_accepts_items_before, item_filter_before, item_stacks)

func generated_consume_items_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, item_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.generated_apply_bridge_state(block_has_items_before, block_accepts_items_before, item_filter_before, item_stacks)

func source_consume_items_build_state(item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.build_state(item_stacks, item_amounts, multiplier_get_build, source_ui_defaults.PAD_RIGHT)

func generated_consume_items_build_bridge_state(item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.generated_build_bridge_state(item_stacks, item_amounts, multiplier_get_build, source_ui_defaults.PAD_RIGHT)

func source_consume_items_trigger_state(item_stacks: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.trigger_state(item_stacks, multiplier_get_build)

func generated_consume_items_trigger_bridge_state(item_stacks: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.generated_trigger_bridge_state(item_stacks, multiplier_get_build)

func source_consume_items_efficiency_state(consume_trigger_valid: bool, item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.efficiency_state(consume_trigger_valid, item_stacks, item_amounts, multiplier_get_build)

func generated_consume_items_efficiency_bridge_state(consume_trigger_valid: bool, item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.generated_efficiency_bridge_state(consume_trigger_valid, item_stacks, item_amounts, multiplier_get_build)

func source_consume_items_display_state(booster: bool, stats_time_period: float, item_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.display_state(booster, stats_time_period, item_stacks)

func generated_consume_items_display_bridge_state(booster: bool, stats_time_period: float, item_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_items_state.generated_display_bridge_state(booster, stats_time_period, item_stacks)

func source_consume_item_filter_build_state(filtered_item_ids: Array, build_items_has_item_flags: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.build_state(filtered_item_ids, build_items_has_item_flags, source_ui_defaults.ICON_MED)

func generated_consume_item_filter_build_bridge_state(filtered_item_ids: Array, build_items_has_item_flags: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_build_bridge_state(filtered_item_ids, build_items_has_item_flags, source_ui_defaults.ICON_MED)

func source_consume_item_filter_update_state(build_state: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.update_state(build_state)

func generated_consume_item_filter_update_bridge_state(build_state: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_update_bridge_state(build_state)

func source_consume_item_filter_trigger_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.trigger_state(build_state, consumed_item)

func generated_consume_item_filter_trigger_bridge_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_trigger_bridge_state(build_state, consumed_item)

func source_consume_item_filter_efficiency_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.efficiency_state(consume_trigger_valid, consumed_item)

func generated_consume_item_filter_efficiency_bridge_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_efficiency_bridge_state(consume_trigger_valid, consumed_item)

func source_consume_item_filter_get_consumed_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.get_consumed_state(content_items, build_items_has_item_flags, filter_get_item_flags)

func generated_consume_item_filter_get_consumed_bridge_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_get_consumed_bridge_state(content_items, build_items_has_item_flags, filter_get_item_flags)

func source_consume_item_filter_display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.display_state(booster, stats_time_period, filtered_item_ids)

func generated_consume_item_filter_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_display_bridge_state(booster, stats_time_period, filtered_item_ids)

func source_consume_item_filter_efficiency_multiplier_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.efficiency_multiplier_state(consumed_item, item_efficiency_multiplier)

func generated_consume_item_filter_efficiency_multiplier_bridge_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_filter_state.generated_efficiency_multiplier_bridge_state(consumed_item, item_efficiency_multiplier)

func source_consume_item_list_set_multipliers_state(objects: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_state.set_multipliers_state(objects)

func generated_consume_item_list_set_multipliers_bridge_state(objects: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_state.generated_set_multipliers_bridge_state(objects)

func source_consume_item_list_efficiency_multiplier_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_state.efficiency_multiplier_state(consumed_item, item_multiplier_value)

func generated_consume_item_list_efficiency_multiplier_bridge_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_list_state.generated_efficiency_multiplier_bridge_state(consumed_item, item_multiplier_value)

func source_consume_liquid_flammable_display_state(booster: bool, amount: float, filtered_liquid_ids: Array, liquid_efficiency_values: Array, table_has_cells: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.display_state(booster, amount, filtered_liquid_ids, liquid_efficiency_values, table_has_cells, source_time_defaults.TICK_RATE)

func generated_consume_liquid_flammable_display_bridge_state(booster: bool, amount: float, filtered_liquid_ids: Array, liquid_efficiency_values: Array, table_has_cells: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.generated_display_bridge_state(booster, amount, filtered_liquid_ids, liquid_efficiency_values, table_has_cells, source_time_defaults.TICK_RATE)

func source_consume_liquid_flammable_liquid_efficiency_multiplier_state(liquid_flammability: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.liquid_efficiency_multiplier_state(liquid_flammability)

func generated_consume_liquid_flammable_liquid_efficiency_multiplier_bridge_state(liquid_flammability: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.generated_liquid_efficiency_multiplier_bridge_state(liquid_flammability)

func source_consume_liquid_flammable_constructor_state(min_flammability: float, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.constructor_state(min_flammability, amount)

func generated_consume_liquid_flammable_constructor_bridge_state(min_flammability: float, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.generated_constructor_bridge_state(min_flammability, amount)

func source_consume_liquid_flammable_amount_constructor_state(amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.amount_constructor_state(amount, source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func generated_consume_liquid_flammable_amount_constructor_bridge_state(amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.generated_amount_constructor_bridge_state(amount, source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func source_consume_liquid_flammable_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.default_constructor_state(source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT, source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func generated_consume_liquid_flammable_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_flammable_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT, source_consumer_defaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func source_consume_liquid_filter_constructor_state(filter_handle: Variant, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.constructor_state(filter_handle, amount)

func generated_consume_liquid_filter_constructor_bridge_state(filter_handle: Variant, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_constructor_bridge_state(filter_handle, amount)

func source_consume_liquid_filter_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.default_constructor_state(source_consumer_defaults.CONSUME_LIQUID_FILTER_DEFAULT_EXPR)

func generated_consume_liquid_filter_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_LIQUID_FILTER_DEFAULT_EXPR)

func source_consume_liquid_filter_apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.apply_state(block_has_liquids_before, liquid_filter_before, filtered_liquid_ids)

func generated_consume_liquid_filter_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_apply_bridge_state(block_has_liquids_before, liquid_filter_before, filtered_liquid_ids)

func source_consume_liquid_filter_build_state(filtered_liquid_ids: Array, consumed_liquid: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.build_state(filtered_liquid_ids, consumed_liquid, source_ui_defaults.ICON_MED)

func generated_consume_liquid_filter_build_bridge_state(filtered_liquid_ids: Array, consumed_liquid: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_build_bridge_state(filtered_liquid_ids, consumed_liquid, source_ui_defaults.ICON_MED)

func source_consume_liquid_filter_get_consumed_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.get_consumed_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)

func generated_consume_liquid_filter_get_consumed_bridge_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_get_consumed_bridge_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)

func source_consume_liquid_filter_update_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.update_state(consumed_liquid, amount, build_edelta, multiplier_get_build)

func generated_consume_liquid_filter_update_bridge_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_update_bridge_state(consumed_liquid, amount, build_edelta, multiplier_get_build)

func source_consume_liquid_filter_efficiency_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.efficiency_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build, source_consumer_defaults.CONSUME_EFFICIENCY_EPSILON)

func generated_consume_liquid_filter_efficiency_bridge_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_efficiency_bridge_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build, source_consumer_defaults.CONSUME_EFFICIENCY_EPSILON)

func source_consume_liquid_filter_efficiency_multiplier_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.efficiency_multiplier_state(consumed_liquid, liquid_efficiency_multiplier)

func generated_consume_liquid_filter_efficiency_multiplier_bridge_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_efficiency_multiplier_bridge_state(consumed_liquid, liquid_efficiency_multiplier)

func source_consume_liquid_filter_liquid_efficiency_multiplier_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.liquid_efficiency_multiplier_state()

func generated_consume_liquid_filter_liquid_efficiency_multiplier_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_liquid_efficiency_multiplier_bridge_state()

func source_consume_liquid_filter_display_state(booster: bool, amount: float, filtered_liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.display_state(booster, amount, filtered_liquid_ids, source_time_defaults.TICK_RATE)

func generated_consume_liquid_filter_display_bridge_state(booster: bool, amount: float, filtered_liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_display_bridge_state(booster, amount, filtered_liquid_ids, source_time_defaults.TICK_RATE)

func source_consume_liquid_filter_consumes_state(filter_get_liquid: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.consumes_state(filter_get_liquid)

func generated_consume_liquid_filter_consumes_bridge_state(filter_get_liquid: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_filter_state.generated_consumes_bridge_state(filter_get_liquid)

func source_consume_optional_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_state.optional_state(optional_value, boost_value)

func generated_consume_optional_bridge_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_optional_bridge_state(optional_value, boost_value)

func source_consume_boost_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.boost_state()

func generated_consume_boost_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_boost_bridge_state()

func source_consume_update_flag_state(update_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_state.update_flag_state(update_value)

func generated_consume_update_flag_bridge_state(update_value: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_update_flag_bridge_state(update_value)

func source_consume_ignore_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.ignore_state()

func generated_consume_ignore_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_ignore_bridge_state()

func source_consume_build_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.build_state(build, table)

func generated_consume_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_build_bridge_state(build, table)

func source_consume_item_explode_build_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_explode_state.build_state(build, table)

func generated_consume_item_explode_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_explode_state.generated_build_bridge_state(build, table)

func source_consume_apply_state(block: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.apply_state(block)

func generated_consume_apply_bridge_state(block: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_apply_bridge_state(block)

func source_consume_trigger_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.trigger_state(build)

func generated_consume_trigger_bridge_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_trigger_bridge_state(build)

func source_consume_update_build_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.update_build_state(build)

func generated_consume_update_build_bridge_state(build: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_update_build_bridge_state(build)

func source_consume_display_state(stats: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.display_state(stats)

func generated_consume_display_bridge_state(stats: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_display_bridge_state(stats)

func source_consume_efficiency_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.efficiency_state()

func generated_consume_efficiency_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_efficiency_bridge_state()

func source_consume_efficiency_multiplier_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.efficiency_multiplier_state()

func generated_consume_efficiency_multiplier_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_state.generated_efficiency_multiplier_bridge_state()

func source_consume_liquid_base_constructor_state(amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_base_state.constructor_state(amount)

func generated_consume_liquid_base_constructor_bridge_state(amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_base_state.generated_constructor_bridge_state(amount)

func source_consume_liquid_constructor_state(liquid: Variant, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.constructor_state(liquid, amount)

func generated_consume_liquid_constructor_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.generated_constructor_bridge_state(liquid, amount)

func source_consume_liquid_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.default_constructor_state(source_consumer_defaults.CONSUME_LIQUID_DEFAULT_LIQUID, source_consumer_defaults.CONSUME_LIQUID_DEFAULT_AMOUNT)

func generated_consume_liquid_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_LIQUID_DEFAULT_LIQUID, source_consumer_defaults.CONSUME_LIQUID_DEFAULT_AMOUNT)

func source_consume_liquid_base_apply_state(block_has_liquids_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_base_state.apply_state(block_has_liquids_before)

func generated_consume_liquid_base_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_base_state.generated_apply_bridge_state(block_has_liquids_before)

func source_consume_liquid_base_abstract_consumes_state(liquid: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_base_state.abstract_consumes_state(liquid)

func generated_consume_liquid_base_abstract_consumes_bridge_state(liquid: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_base_state.generated_abstract_consumes_bridge_state(liquid)

func source_consume_liquid_apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.game_apply_state(self, block_has_liquids_before, liquid_filter_before, liquid_id)

func generated_consume_liquid_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.game_generated_apply_bridge_state(self, block_has_liquids_before, liquid_filter_before, liquid_id)

func source_consume_liquid_build_state(liquid_id: int, build_liquids_get: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.build_state(liquid_id, build_liquids_get, source_ui_defaults.ICON_MED)

func generated_consume_liquid_build_bridge_state(liquid_id: int, build_liquids_get: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.generated_build_bridge_state(liquid_id, build_liquids_get, source_ui_defaults.ICON_MED)

func source_consume_liquid_display_state(booster: bool, liquid_id: int, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.display_state(booster, liquid_id, amount)

func generated_consume_liquid_display_bridge_state(booster: bool, liquid_id: int, amount: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.generated_display_bridge_state(booster, liquid_id, amount, source_time_defaults.TICK_RATE)

func source_consume_liquid_update_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.update_state(liquid_id, amount, build_edelta, multiplier_get_build)

func generated_consume_liquid_update_bridge_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.generated_update_bridge_state(liquid_id, amount, build_edelta, multiplier_get_build)

func source_consume_liquids_constructor_state(liquid_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.constructor_state(liquid_stacks)

func generated_consume_liquids_constructor_bridge_state(liquid_stacks: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.generated_constructor_bridge_state(liquid_stacks)

func source_consume_liquids_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.default_constructor_state(source_consume_module_registry.source_consume_liquids_state.SOURCE_CONSUME_LIQUIDS_EMPTY_STACKS)

func generated_consume_liquids_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.generated_default_constructor_bridge_state(source_consume_module_registry.source_consume_liquids_state.SOURCE_CONSUME_LIQUIDS_EMPTY_STACKS)

func source_consume_liquids_apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.apply_state(block_has_liquids_before, liquid_filter_before, liquid_ids)

func generated_consume_liquids_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.generated_apply_bridge_state(block_has_liquids_before, liquid_filter_before, liquid_ids)

func source_consume_liquids_build_state(liquid_ids: Array, liquid_amounts: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.build_state(liquid_ids, liquid_amounts)

func generated_consume_liquids_build_bridge_state(liquid_ids: Array, liquid_amounts: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.generated_build_bridge_state(liquid_ids, liquid_amounts)

func source_consume_liquids_update_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func generated_consume_liquids_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.generated_update_bridge_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func source_consume_liquids_efficiency_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)

func generated_consume_liquids_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.generated_efficiency_bridge_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)

func source_consume_liquid_efficiency_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.efficiency_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)

func generated_consume_liquid_efficiency_bridge_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.generated_efficiency_bridge_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)

func source_consume_liquids_display_state(booster: bool, liquid_ids: Array, liquid_stack_amounts: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.display_state(booster, liquid_ids, liquid_stack_amounts)

func generated_consume_liquids_display_bridge_state(booster: bool, liquid_ids: Array, liquid_stack_amounts: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_state.generated_display_bridge_state(booster, liquid_ids, liquid_stack_amounts, source_time_defaults.TICK_RATE)

func source_consume_liquids_dynamic_constructor_state(liquids: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.constructor_state(liquids)

func generated_consume_liquids_dynamic_constructor_bridge_state(liquids: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.generated_constructor_bridge_state(liquids)

func source_consume_item_dynamic_constructor_state(items: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.constructor_state(items)

func generated_consume_item_dynamic_constructor_bridge_state(items: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.generated_constructor_bridge_state(items)

func source_consume_item_efficiency_constructor_state(item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.constructor_state(item)

func generated_consume_item_efficiency_constructor_bridge_state(item: Variant) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.generated_constructor_bridge_state(item)

func source_consume_item_efficiency_default_constructor_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.default_constructor_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func generated_consume_item_efficiency_default_constructor_bridge_state() -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.generated_default_constructor_bridge_state(source_consumer_defaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func source_consume_item_dynamic_apply_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.apply_state(block_has_items_before, block_accepts_items_before)

func generated_consume_item_dynamic_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.generated_apply_bridge_state(block_has_items_before, block_accepts_items_before)

func source_consume_item_dynamic_build_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.build_state(current_item_ids, next_item_ids)

func generated_consume_item_dynamic_build_bridge_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.generated_build_bridge_state(current_item_ids, next_item_ids)

func source_consume_item_dynamic_rebuild_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.rebuild_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, source_ui_defaults.PAD_RIGHT)

func generated_consume_item_dynamic_rebuild_bridge_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.generated_rebuild_bridge_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, source_ui_defaults.PAD_RIGHT)

func source_consume_item_dynamic_trigger_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.trigger_state(item_ids, item_stack_amounts, multiplier_get_build)

func generated_consume_item_dynamic_trigger_bridge_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.generated_trigger_bridge_state(item_ids, item_stack_amounts, multiplier_get_build)

func source_consume_item_dynamic_efficiency_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.efficiency_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)

func generated_consume_item_dynamic_efficiency_bridge_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_item_dynamic_state.generated_efficiency_bridge_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)

func source_consume_item_efficiency_display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.display_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_time_defaults.TICK_RATE)

func generated_consume_item_efficiency_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_item_efficiency_state.generated_display_bridge_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, source_time_defaults.TICK_RATE)

func source_consume_liquids_dynamic_apply_state(block_has_liquids_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.apply_state(block_has_liquids_before)

func generated_consume_liquids_dynamic_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.generated_apply_bridge_state(block_has_liquids_before)

func source_consume_liquids_dynamic_build_state(current_liquid_ids: Array, next_liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.build_state(current_liquid_ids, next_liquid_ids)

func generated_consume_liquids_dynamic_build_bridge_state(current_liquid_ids: Array, next_liquid_ids: Array) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.generated_build_bridge_state(current_liquid_ids, next_liquid_ids)

func source_consume_liquids_dynamic_rebuild_state(liquid_ids: Array, liquid_amounts: Array, building_has_liquids: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.rebuild_state(liquid_ids, liquid_amounts, building_has_liquids, source_ui_defaults.ICON_MED, source_ui_defaults.PAD_RIGHT)

func generated_consume_liquids_dynamic_rebuild_bridge_state(liquid_ids: Array, liquid_amounts: Array, building_has_liquids: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.generated_rebuild_bridge_state(liquid_ids, liquid_amounts, building_has_liquids, source_ui_defaults.ICON_MED, source_ui_defaults.PAD_RIGHT)

func source_consume_liquids_dynamic_update_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func generated_consume_liquids_dynamic_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.generated_update_bridge_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func source_consume_liquids_dynamic_efficiency_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build)

func generated_consume_liquids_dynamic_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return source_consume_module_registry.source_consume_liquids_dynamic_state.generated_efficiency_bridge_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build)

func source_consume_liquid_consumes_state(liquid_matches_self_liquid: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.consumes_state(liquid_matches_self_liquid)

func generated_consume_liquid_consumes_bridge_state(liquid_matches_self_liquid: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_liquid_state.generated_consumes_bridge_state(liquid_matches_self_liquid)

func source_consume_power_requested_power_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.requested_power_state(buffered, usage, capacity, power_status, should_consume)

func generated_consume_power_requested_power_bridge_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	return source_consume_module_registry.source_consume_power_state.generated_requested_power_bridge_state(buffered, usage, capacity, power_status, should_consume)

func source_power_graph_power_needed_state(consumers: Array) -> Dictionary:
	return source_power_graph_state.power_needed_state(consumers)

func source_power_graph_power_produced_state(producers: Array) -> Dictionary:
	return source_power_graph_state.power_produced_state(producers)

func source_power_graph_battery_state(batteries: Array) -> Dictionary:
	return source_power_graph_state.battery_state(batteries)

func source_power_graph_use_batteries_state(batteries: Array, needed: float) -> Dictionary:
	return source_power_graph_state.use_batteries_state(batteries, needed)

func source_power_graph_charge_batteries_state(batteries: Array, excess: float) -> Dictionary:
	return source_power_graph_state.charge_batteries_state(batteries, excess)

func source_power_graph_distribute_power_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	return source_power_graph_state.distribute_power_state(consumers, needed, produced, charged, last_power_stored)

func source_power_graph_update_cheat_state(consumers: Array) -> Dictionary:
	return source_power_graph_state.update_cheat_state(consumers)

func source_power_graph_update_balance_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = []) -> Dictionary:
	return source_power_graph_state.update_balance_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)

func source_power_graph_update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	return source_power_graph_state.update_battery_distribute_state(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)

func power_graph_role_for_block(block) -> Dictionary:
	return source_building_power_state.block_power_role_state(block)

func placed_power_graph_role_counts() -> Dictionary:
	return source_placed_power_graph_state.game_role_counts_state(self)

func placed_power_needed_state() -> Dictionary:
	return source_placed_power_graph_state.game_needed_state(self, source_time_defaults.TICK_RATE)

func placed_power_produced_state() -> Dictionary:
	return source_placed_power_graph_state.game_produced_state(self, source_time_defaults.TICK_RATE)

func placed_power_battery_state() -> Dictionary:
	return source_placed_power_graph_state.game_battery_state(self)

func placed_power_battery_runtime_state() -> Dictionary:
	return source_placed_power_battery_runtime_state.game_summary_state(self, source_time_defaults.TICK_RATE)

func placed_power_distribution_runtime_state() -> Dictionary:
	return source_placed_power_distribution_runtime_state.game_summary_state(self, source_time_defaults.TICK_RATE)

func placed_power_runtime_state() -> Dictionary:
	return source_placed_power_graph_state.game_runtime_state(self, source_time_defaults.TICK_RATE)

func place_selected_block_at_mouse() -> void:
	place_selected_block_at_world(get_global_mouse_position())

func place_selected_block_at_cell(x: int, y: int) -> bool:
	return place_selected_block_at_world(grid_to_world(Vector2i(x, y)))

func place_selected_block_at_world(world_pos: Vector2) -> bool:
	return source_block_placement.place_selected_block_at_world(self, world_pos, source_playable_scenario_defaults.WORLD_SIZE)

func add_source_block(parent: Node, block_id: String, cell: Vector2i) -> void:
	source_block_placement.add_source_block(self, parent, block_id, cell)

func occupied_cells(cell: Vector2i, block) -> Array[Vector2i]:
	return source_block_footprint.occupied_cells(cell, block_size(block))

func can_place_block_at_cell(block, cell: Vector2i) -> bool:
	var state := source_block_placement.can_place_state(occupied_cells(cell, block), placed_blocks, source_playable_scenario_defaults.WORLD_SIZE)
	return bool(state.get("can_place", false))

func record_placed_block(sprite: Sprite2D, block, cell: Vector2i) -> void:
	var cell_keys: Array[String] = source_block_placement.record_cells(placed_block_origins, placed_blocks, cell, occupied_cells(cell, block), sprite)
	source_placed_block_state.initialize_sprite(sprite, block, cell, cell_keys, source_block_metadata_state.SOURCE_BLOCK_HEALTH_DEFAULT, source_block_defaults.TIME_SCALE_DEFAULT)

func block_sprite_at_cell(cell: Vector2i):
	return placed_blocks.get(cell_key(cell))

func block_from_sprite(sprite):
	return source_texture_runtime_state.block_from_sprite(self, sprite)

func source_block_health_at_cell(x: int, y: int) -> float:
	return source_placed_block_state.game_health_at_cell(self, x, y)

func source_block_time_scale_at_cell(x: int, y: int) -> float:
	return source_placed_block_state.game_time_scale_at_cell(self, x, y, source_block_defaults.TIME_SCALE_DEFAULT)

func source_block_time_scale_duration_at_cell(x: int, y: int) -> float:
	return source_placed_block_state.game_time_scale_duration_at_cell(self, x, y)

func decay_block_time_scale_sprite(sprite, source_delta: float) -> void:
	source_placed_block_state.decay_time_scale_sprite(self, sprite, source_delta, source_block_defaults.TIME_SCALE_DEFAULT)

func simulate_block_time_scales(delta: float) -> void:
	var source_delta := delta * source_time_defaults.TICK_RATE
	source_placed_block_state.simulate_time_scales(self, source_delta, source_block_defaults.TIME_SCALE_DEFAULT)

func step_block_time_scales(seconds: float) -> Dictionary:
	return source_placed_block_state.step_time_scales(self, seconds, source_time_defaults.TICK_RATE, source_block_defaults.TIME_SCALE_DEFAULT)

func damage_block_at_cell(x: int, y: int, amount: float) -> float:
	return source_placed_block_state.game_damage_at_cell(self, x, y, amount)

func repair_block_sprite(sprite, amount: float) -> float:
	return source_placed_block_state.repair_sprite(sprite, amount)

func boost_mend_projector_at_cell(x: int, y: int) -> bool:
	return source_projector_boost_state.apply_projector_boost_at_cell(self, x, y, source_projector_boost_state.PROJECTOR_KIND_MEND, mend_projector_booster_items, mend_projector_optional_efficiency)

func mend_projector_phase_heat_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.phase_heat_at_cell(self, x, y)

func mend_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.smooth_efficiency_at_cell(self, x, y)

func mend_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	return source_mend_projector_state.light_state_at_cell(self, x, y)

func mend_projector_heat_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.heat_at_cell(self, x, y)

func mend_projector_charge_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.charge_at_cell(self, x, y)

func mend_projector_progress_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.progress_at_cell(self, x, y)

func mend_projector_select_state_at_cell(x: int, y: int) -> Dictionary:
	return source_mend_projector_state.select_state_at_cell(self, x, y)
func mend_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	return source_mend_projector_state.draw_state_at_cell(self, x, y, source_time_ticks, source_world_defaults.TILESIZE)

func mend_projector_state_at_cell(x: int, y: int) -> Dictionary:
	return source_mend_projector_state.state_at_cell(self, x, y)

func boost_overdrive_projector_at_cell(x: int, y: int) -> bool:
	return source_projector_boost_state.apply_projector_boost_at_cell(self, x, y, source_projector_boost_state.PROJECTOR_KIND_OVERDRIVE, overdrive_projector_booster_items, overdrive_projector_optional_efficiency)

func overdrive_projector_phase_heat_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, overdrive_projector_phase_heat, 0.0)

func overdrive_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, overdrive_projector_smooth_efficiency, 0.0)

func overdrive_projector_heat_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, overdrive_projector_heat, 0.0)

func overdrive_projector_charge_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, overdrive_projector_charges, 0.0)

func overdrive_projector_use_progress_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, overdrive_projector_use_progress, 0.0)

func overdrive_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	return source_overdrive_projector_state.game_light_state_at_cell(self, x, y)

func overdrive_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	return source_overdrive_projector_state.game_draw_state_at_cell(self, x, y, source_time_ticks)

func overdrive_projector_state_at_cell(x: int, y: int) -> Dictionary:
	return source_overdrive_projector_state.game_capture_state_at_cell(self, x, y, overdrive_projector_heat, overdrive_projector_smooth_efficiency, overdrive_projector_phase_heat, overdrive_projector_charges, overdrive_projector_use_progress)

func block_size(block) -> int:
	return source_block_metadata_state.block_size(block)

func source_block_health(block_id: String) -> float:
	return source_block_metadata_state.block_health(block_id, content_catalog)

func source_block_item_capacity(block_id: String) -> int:
	return source_block_metadata_state.block_item_capacity(block_id, content_catalog)

func source_block_dump_time(block_id: String) -> float:
	return source_block_metadata_state.block_dump_time(block_id, content_catalog)

func source_drill_dump_interval(block_id: String, time_scale := 1.0) -> float:
	return source_drill_dump_runtime_state_script.game_dump_interval(self, block_id, time_scale)

func source_drill_ore_count(block_id: String, cell: Vector2i, item_id: String) -> int:
	return source_drill_runtime_state_script.game_ore_count(self, block_id, cell, item_id)

func source_drill_delay(block_id: String, item_id: String) -> float:
	return source_drill_runtime_state_script.drill_delay(block_id, item_id, content_catalog, source_factory_defaults.DRILL_HARDNESS_MULTIPLIER)

func generated_drill_get_drill_time_bridge_state(block_id: String, item_id: String) -> Dictionary:
	return source_drill_runtime_state_script.generated_get_drill_time_bridge_state(block_id, item_id, content_catalog, source_factory_defaults.DRILL_HARDNESS_MULTIPLIER)

func source_drill_output_rate(block_id: String, item_id: String, return_count: int) -> float:
	return source_drill_runtime_state_script.game_output_rate(self, block_id, item_id, return_count)

func source_drill_warmup_speed(block_id: String) -> float:
	return source_block_metadata_state.block_warmup_speed(block_id, content_catalog)

func source_drill_warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float) -> float:
	return source_drill_runtime_state_script.game_warmup_state(self, current_warmup, speed, warmup_speed, source_delta)

func source_drill_inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float) -> float:
	return source_drill_runtime_state_script.game_inactive_warmup_state(self, current_warmup, warmup_speed, source_delta)

func drill_warmup_at_cell(x: int, y: int) -> float:
	return float(drill_warmups.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_warmup_at_cell(x: int, y: int, warmup: float) -> void:
	drill_warmups[cell_key(Vector2i(x, y))] = warmup

func source_drill_last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_last_speed(self, block_id, item_id, ore_count, warmup, speed)

func source_drill_last_speed_for_cell(x: int, y: int, item_id: String, dominant_items: int, warmup: float, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_last_speed_for_cell(self, x, y, item_id, dominant_items, warmup, speed)

func drill_last_speed_at_cell(x: int, y: int) -> float:
	return float(drill_last_speeds.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_last_speed_at_cell(x: int, y: int, value: float) -> void:
	drill_last_speeds[cell_key(Vector2i(x, y))] = value

func source_drill_time_drilled_delta(warmup: float, seconds: float, time_scale := 1.0) -> float:
	return source_drill_runtime_state_script.game_time_drilled_delta(self, warmup, seconds, time_scale)

func drill_time_drilled_at_cell(x: int, y: int) -> float:
	return float(drill_time_drilled.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_time_drilled_at_cell(x: int, y: int, value: float) -> void:
	drill_time_drilled[cell_key(Vector2i(x, y))] = value

func step_drill_time_drilled_cell(x: int, y: int, seconds: float, warmup: float) -> float:
	return source_drill_runtime_state_script.game_step_drill_time_drilled_cell(self, x, y, seconds, warmup)

func step_drill_warmup_cell(x: int, y: int, seconds: float, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_step_drill_warmup_cell(self, x, y, seconds, speed)

func source_drill_output_delta(dominant_items: int, seconds: float, time_scale := 1.0, warmup := 1.0, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_output_delta(self, dominant_items, seconds, time_scale, warmup, speed)

func source_drill_output_delta_for_cell(x: int, y: int, dominant_items: int, seconds: float, warmup := 1.0, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_output_delta_for_cell(self, x, y, dominant_items, seconds, warmup, speed)

func source_drill_output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	return source_drill_production_runtime_state_script.output_batch(progress, delay, dominant_items, items_total, item_capacity)

func source_drill_progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	return source_drill_production_runtime_state_script.progress_fraction(progress, delay, has_dominant_item)

func source_conveyor_world_speed(block_id: String) -> float:
	return source_conveyor_runtime_state.world_speed(block_id, tile_size, content_catalog)

func source_conveyor_path_progress_rate(block_id: String) -> float:
	return source_conveyor_runtime_state.path_progress_rate(block_id, path_points.size(), tile_size, content_catalog)

func source_conveyor_path_progress_delta(block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:
	return source_conveyor_runtime_state.game_path_progress_delta(self, block_id, seconds, path_points.size(), tile_size, source_time_defaults.TICK_RATE, content_catalog, time_scale, efficiency)

func source_conveyor_path_progress_delta_for_cell(x: int, y: int, seconds: float, efficiency := 1.0) -> float:
	return source_conveyor_runtime_state.game_path_progress_delta_for_cell(self, x, y, seconds, efficiency)

func block_world_size(block) -> float:
	return source_block_geometry.block_world_size(block_size(block), tile_size)

func source_block_sprite_base_position(block, cell: Vector2i) -> Vector2:
	return source_block_geometry.block_base_position(grid_to_world(cell), block_size(block), tile_size)

func configure_block_sprite(sprite: Sprite2D, block, cell: Vector2i) -> void:
	source_texture_runtime_state.configure_block_sprite(self, sprite, block, cell)

func register_turret_cell(cell: Vector2i, block) -> void:
	source_turret_cell_registry_state.register_turret_cell(self, cell, block)

func unregister_turret_cell(cell: Vector2i) -> void:
	source_turret_cell_registry_state.unregister_turret_cell(self, cell)

func block_texture(block) -> Texture2D:
	return source_texture_runtime_state.block_texture(self, block)

func source_bullet_texture(sprite_id: String) -> Texture2D:
	var path := source_bullet_runtime_state.texture_path(sprite_id)
	return load_png_texture(path)

func can_afford(block) -> bool:
	return source_block_requirements_state.game_can_afford(self, block)

func spend_requirements(block) -> void:
	source_block_requirements_state.game_spend_requirements(self, block)

func playable_core_item_id() -> String:
	return source_playable_scenario_defaults.ITEM_COPPER

func playable_core_item_name() -> String:
	var core_item = content_catalog.get_by_id(playable_core_item_id()) if content_catalog else null
	return core_item.display_name() if core_item else source_playable_scenario_defaults.ITEM_COPPER.capitalize()

func sync_copper_inventory_alias() -> void:
	source_core_inventory_runtime_state.sync_copper_inventory_runtime_state(self)

func clamp_core_item_amount(amount: int) -> int:
	return source_core_inventory_runtime_state.clamp_item_amount(amount, core_item_capacity)

func set_core_item_count(item_id: String, amount: int) -> void:
	source_core_inventory_runtime_state.set_item_count_runtime_state(self, item_id, amount)

func add_core_item(item_id: String, amount: int) -> void:
	source_core_inventory_runtime_state.add_item_runtime_state(self, item_id, amount)

func core_item_count(item_id: String) -> int:
	return source_core_inventory_runtime_state.item_count_runtime_state(self, item_id)

func source_core_accept_item(item_id: String) -> bool:
	var state := source_core_inventory_runtime_state.accept_item_state(core_incinerates, core_item_count(item_id), core_item_capacity, item_id)
	return bool(state.get("acceptItem", false))

func source_core_handle_item(item_id: String) -> bool:
	return source_core_inventory_runtime_state.game_handle_item(self, item_id)

func source_building_handle_item_count(current_count: int) -> int:
	return current_count + 1

func source_building_accept_item_state(consumes_item: bool, item_count: int, maximum_accepted: int) -> bool:
	return source_building_item_state.accept_item_state(consumes_item, item_count, maximum_accepted)

func source_building_maximum_accepted(block_item_capacity: int) -> int:
	return source_building_item_state.maximum_accepted(block_item_capacity)

func source_building_handle_stack_count(current_count: int, amount: int) -> int:
	return source_building_item_state.handle_stack_count(current_count, amount)

func source_building_accept_stack_state(accepts_item: bool, has_items: bool, same_team_or_null_source: bool, maximum_accepted: int, item_count: int, amount: int) -> int:
	return source_building_item_state.accept_stack_state(accepts_item, has_items, same_team_or_null_source, maximum_accepted, item_count, amount)

func source_building_remove_stack_state(has_items_module: bool, item_count: int, amount: int) -> Dictionary:
	return source_building_item_state.remove_stack_state(has_items_module, item_count, amount)

func source_building_accept_payload_state() -> bool:
	return source_building_payload_state.accept_payload_state()

func source_building_handle_payload_state(payload_state: Variant) -> Variant:
	return source_building_payload_state.handle_payload_state(payload_state)

func source_payload_forward_offset(payload_block_size: int) -> int:
	return source_building_payload_state.payload_forward_offset(payload_block_size)

func source_move_payload_state(has_next_tile: bool, has_next_build: bool, same_team: bool, accepts_payload: bool) -> bool:
	return source_building_payload_state.move_payload_state(has_next_tile, has_next_build, same_team, accepts_payload)

func source_dump_payload_index(loop_index: int, dump_cursor: int, proximity_size: int) -> int:
	return source_building_payload_state.dump_payload_index(loop_index, dump_cursor, proximity_size)

func source_dump_payload_state(proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array) -> Dictionary:
	return source_building_payload_state.game_dump_payload_state(self, proximity_size, dump_cursor, accepts_payload_by_index)

func source_block_can_replace_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> bool:
	return source_building_core_state.block_can_replace_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)

func source_building_can_be_replaced_state(other_can_replace_block: bool) -> bool:
	return source_building_core_state.building_can_be_replaced_state(other_can_replace_block)

func source_building_should_consume_state(enabled_state: bool) -> Dictionary:
	return source_building_core_state.should_consume_state(enabled_state)

func source_building_production_valid_state() -> Dictionary:
	return source_building_core_state.production_valid_state()

func source_building_consume_trigger_valid_state() -> bool:
	return source_building_core_state.consume_trigger_valid_state()

func source_building_power_production_state() -> Dictionary:
	return source_building_core_state.power_production_state()

func source_building_progress_increase(base_time: float, edelta_value: float) -> float:
	return source_building_time_state.progress_increase(base_time, edelta_value)

func source_building_display_efficiency(edelta_value: float) -> float:
	return source_building_time_state.display_efficiency(edelta_value)

func generated_building_comp_get_progress_increase_bridge_state(base_time: float, edelta_value: float) -> Dictionary:
	return source_building_time_state.generated_get_progress_increase_bridge_state(base_time, edelta_value)

func generated_building_comp_get_display_efficiency_bridge_state(edelta_value: float) -> Dictionary:
	return source_building_time_state.generated_get_display_efficiency_bridge_state(edelta_value)

func generated_building_comp_should_ambient_sound_bridge_state(should_consume_state: bool) -> Dictionary:
	return source_building_time_state.generated_should_ambient_sound_bridge_state(should_consume_state)

func generated_building_comp_is_commandable_bridge_state(block_commandable: bool) -> Dictionary:
	return source_building_interaction_state.generated_is_commandable_bridge_state(block_commandable)

func generated_building_comp_is_payload_bridge_state(tile_is_empty_tile: bool) -> Dictionary:
	return source_building_interaction_state.generated_is_payload_bridge_state(tile_is_empty_tile)

func generated_building_comp_overwrote_bridge_state(previous_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_overwrote_bridge_state(previous_state)

func generated_building_comp_on_removed_bridge_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_on_removed_bridge_state(current_state)

func generated_building_comp_unit_on_bridge_state(unit_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_unit_on_bridge_state(unit_state)

func generated_building_comp_unit_on_any_bridge_state(unit_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_unit_on_any_bridge_state(unit_state)

func generated_building_comp_unit_removed_bridge_state(unit_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_unit_removed_bridge_state(unit_state)

func generated_building_comp_puddle_on_bridge_state(puddle_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_puddle_on_bridge_state(puddle_state)

func generated_building_comp_configured_type_bridge_state(value_state: Dictionary) -> Dictionary:
	return source_building_configure_state.generated_configured_type_bridge_state(value_state)

func generated_building_comp_update_last_access_bridge_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	return source_building_configure_state.generated_update_last_access_bridge_state(builder_state, current_last_accessed)

func generated_building_comp_tapped_bridge_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_tapped_bridge_state(current_state)

func generated_building_comp_get_display_name_bridge_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> Dictionary:
	return source_building_display_state.generated_building_comp_get_display_name_bridge_state(localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label)

func generated_building_comp_flow_items_bridge_state(items_module: Variant) -> Dictionary:
	return source_building_display_state.generated_building_comp_flow_items_bridge_state(items_module)

func generated_building_comp_display_consumption_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	return source_building_display_state.generated_building_comp_display_consumption_bridge_state(consumers, self_state)

func generated_building_comp_display_bars_bridge_state(bar_results: Array) -> Dictionary:
	return source_building_display_state.generated_building_comp_display_bars_bridge_state(bar_results)

func generated_building_comp_get_cursor_bridge_state(block_configurable: bool, interactable_player_team: bool) -> Dictionary:
	return source_building_meta_state.generated_cursor_bridge_state(block_configurable, interactable_player_team)

func generated_building_comp_on_configure_tapped_bridge_state(x: float, y: float) -> Dictionary:
	return source_building_configure_state.generated_on_configure_tapped_bridge_state(x, y)

func generated_building_comp_on_configure_closed_bridge_state() -> Dictionary:
	return source_building_configure_state.generated_on_configure_closed_bridge_state()

func generated_building_comp_should_show_configure_bridge_state(player: Variant) -> Dictionary:
	return source_building_configure_state.generated_should_show_configure_bridge_state(player)

func generated_building_comp_should_hide_configure_bridge_state(player: Variant) -> Dictionary:
	return source_building_configure_state.generated_should_hide_configure_bridge_state(player)

func generated_building_comp_check_solid_bridge_state() -> Dictionary:
	return source_building_core_state.generated_check_solid_bridge_state()

func generated_building_comp_handle_damage_bridge_state(amount: float) -> Dictionary:
	return source_building_damage_state.generated_handle_damage_bridge_state(amount)

func generated_building_comp_absorb_lasers_bridge_state(block_absorb_lasers: bool) -> Dictionary:
	return source_building_core_state.generated_absorb_lasers_bridge_state(block_absorb_lasers)

func generated_building_comp_is_insulated_bridge_state(block_insulated: bool) -> Dictionary:
	return source_building_core_state.generated_is_insulated_bridge_state(block_insulated)

func generated_building_comp_collide_bridge_state(other: Variant) -> Dictionary:
	return source_building_core_state.generated_collide_bridge_state(other)

func generated_building_comp_collision_bridge_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	return source_building_damage_state.generated_collision_bridge_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)

func generated_building_comp_damage_delegate_bridge_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.generated_damage_delegate_bridge_state(source_team, damage_amount)

func generated_building_comp_bullet_damage_bridge_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.generated_bullet_damage_bridge_state(bullet, source_team, damage_amount)

func generated_building_comp_delta_bridge_state(source_delta: float, time_scale: float) -> Dictionary:
	return source_building_time_state.generated_delta_bridge_state(source_delta, time_scale)

func generated_building_comp_edelta_bridge_state(source_delta: float, time_scale: float, efficiency: float) -> Dictionary:
	return source_building_time_state.generated_edelta_bridge_state(source_delta, time_scale, efficiency)

func generated_building_comp_hit_size_bridge_state(block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_geometry.generated_building_hit_size_bridge_state(block_size_value, source_tilesize)

func generated_building_comp_damage_dead_guard_bridge_state(damage_amount: float, dead_state: bool) -> Dictionary:
	return source_building_damage_state.generated_damage_dead_guard_bridge_state(damage_amount, dead_state)

func generated_building_comp_damage_block_health_scale_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	return source_building_damage_state.generated_damage_block_health_scale_bridge_state(damage_amount, health, block_health_multiplier, source_time)

func generated_building_comp_damage_handle_damage_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	return source_building_damage_state.generated_damage_handle_damage_gate_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage)

func generated_building_comp_damage_health_changed_call_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	return source_building_damage_state.generated_damage_health_changed_call_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage)

func generated_building_comp_damage_destroy_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float, self_state := {}) -> Dictionary:
	return source_building_damage_state.generated_damage_destroy_gate_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage, self_state)

func generated_building_comp_health_changed_bridge_state(net_server: bool, self_state := {}) -> Dictionary:
	return source_building_meta_state.generated_health_changed_bridge_state(net_server, self_state)

func generated_building_comp_sense_position_bridge_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_position_bridge_state(world_x, world_y, source_tilesize)

func generated_building_comp_sense_health_process_bridge_state(world_x: float, world_y: float, health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_health_process_bridge_state(world_x, world_y, health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)

func generated_building_comp_sense_totals_bridge_state(world_x: float, world_y: float, total_items: float, total_liquids: float, total_power: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_totals_bridge_state(world_x, world_y, total_items, total_liquids, total_power, source_tilesize)

func generated_building_comp_sense_capacity_power_net_bridge_state(world_x: float, world_y: float, block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_capacity_power_net_bridge_state(world_x, world_y, block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, source_tilesize)

func generated_building_comp_sense_enabled_controlled_bridge_state(world_x: float, world_y: float, enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_enabled_controlled_bridge_state(world_x, world_y, enabled_state, is_control_block, is_controlled, ctrl_player_value, source_tilesize)

func generated_building_comp_sense_payload_size_bridge_state(world_x: float, world_y: float, has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_payload_size_bridge_state(world_x, world_y, has_payload_seq, payload_seq_total, has_single_payload, block_size_value, source_tilesize)

func generated_building_comp_sense_camera_default_bridge_state(world_x: float, world_y: float, is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_camera_default_bridge_state(world_x, world_y, is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height, source_tilesize)

func generated_building_comp_sense_object_bridge_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_object_bridge_state(sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content)

func generated_building_comp_display_bridge_state(block_ui_icon: Variant, localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	return source_building_display_state.generated_building_comp_display_bridge_state(block_ui_icon, localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label, block_category, block_display_flow, net_active, has_last_accessed)

func source_building_should_ambient_sound(should_consume_state: bool) -> Dictionary:
	return source_building_time_state.should_ambient_sound(should_consume_state)

func source_building_is_commandable_state(block_commandable: bool) -> bool:
	return source_building_interaction_state.is_commandable_state(block_commandable)

func source_building_is_payload_state(tile_is_empty_tile: bool) -> bool:
	return source_building_interaction_state.is_payload_state(tile_is_empty_tile)

func source_building_overwrote_state(previous_state: Variant) -> Dictionary:
	return source_building_interaction_state.overwrote_state(previous_state)

func source_building_on_removed_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.on_removed_state(current_state)

func source_building_unit_on_state(unit_state: Variant) -> Variant:
	return source_building_interaction_state.unit_on_state(unit_state)

func source_building_unit_on_any_state(unit_state: Variant) -> Variant:
	return source_building_interaction_state.unit_on_any_state(unit_state)

func source_building_unit_removed_state(unit_state: Variant) -> Variant:
	return source_building_interaction_state.unit_removed_state(unit_state)

func source_building_puddle_on_state(puddle_state: Variant) -> Dictionary:
	return source_building_interaction_state.puddle_on_state(puddle_state)

func source_building_configured_type_state(value_state: Dictionary) -> String:
	return source_building_configure_state.configured_type_state(value_state)

func source_building_configured_last_access_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	return source_building_configure_state.configured_last_access_state(builder_state, current_last_accessed)

func source_building_configured_direct_handler_state(has_configuration: bool, configured_type: String, value_state: Variant) -> Dictionary:
	return source_building_configure_state.configured_direct_handler_state(has_configuration, configured_type, value_state)

func source_building_configured_copy_config_state(value_is_building: bool, copied_config: Variant, copied_config_is_building: bool) -> Dictionary:
	return source_building_configure_state.configured_copy_config_state(value_is_building, copied_config, copied_config_is_building)

func source_building_tapped_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.tapped_state(current_state)

func generated_construct_block_static_helpers_bridge_state(size: int, max_block_size: int, time_since_last_played_ms: int, current_millis: int, up: bool, time_since_last_time_ms: int, pitch_seq_before: int, random_pitch: float, headless: bool, visible_tile: bool) -> Dictionary:
	return source_construct_block_state.generated_construct_block_static_helpers_bridge_state(size, max_block_size, time_since_last_played_ms, current_millis, up, time_since_last_time_ms, pitch_seq_before, random_pitch, headless, visible_tile)

func construct_build_inner_runtime_state(current_solid: bool, previous_solid: bool, interactable_with_player_team: bool, current_is_placeable: bool, player_is_builder: bool, build_was_auto_paused: bool, input_is_building: bool, tile_x: int, tile_y: int, rotation_value: int, current_block: Variant, last_config: Variant, sensor: String, progress: float, active_deconstruct: bool, super_sense_value: float, super_sense_object_value: Variant, floor_solid: bool, floor_has_surface: bool, source_x: float, source_y: float, construct_build_block_size: int, current_is_air: bool, construct_color_before: float, source_delta: float) -> Dictionary:
	return source_construct_build_state.game_inner_runtime_state(self, current_solid, previous_solid, interactable_with_player_team, current_is_placeable, player_is_builder, build_was_auto_paused, input_is_building, tile_x, tile_y, rotation_value, current_block, last_config, sensor, progress, active_deconstruct, super_sense_value, super_sense_object_value, floor_solid, floor_has_surface, source_x, source_y, construct_build_block_size, current_is_air, construct_color_before, source_delta)

func construct_build_set_construct_state(previous_block: Variant, block: Variant, build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_state.set_construct_state(previous_block, block, build_cost_multiplier)

func construct_build_set_deconstruct_state(previous_block: Variant, build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_state.set_deconstruct_state(previous_block, build_cost_multiplier)

func construct_build_check_required_state(requirements: Array, inventory: Dictionary, accumulator: Array, items_left: Array, amount: float, remove: bool, build_cost_multiplier: float, team_infinite_resources: bool, state_infinite_resources: bool) -> Dictionary:
	return source_construct_build_state.check_required_state(requirements, inventory, accumulator, items_left, amount, remove, build_cost_multiplier, team_infinite_resources, state_infinite_resources)

func construct_build_construct_state(previous_block: Variant, current_block: Variant, builder_state: Variant, construct_core_inventory: Dictionary, amount: float, construct_config: Variant, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, core_present: bool, team_infinite_resources: bool, state_infinite_resources: bool, builder_is_player: bool, last_builder_present: bool, net_client: bool, rotation_value: int) -> Dictionary:
	return source_construct_build_state.construct_state(previous_block, current_block, builder_state, construct_core_inventory, amount, construct_config, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, core_present, team_infinite_resources, state_infinite_resources, builder_is_player, last_builder_present, net_client, rotation_value)

func construct_build_deconstruct_state(current_block: Variant, builder_state: Variant, deconstruct_core_inventory: Dictionary, amount: float, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, deconstruct_refund_multiplier: float, core_present: bool, state_infinite_resources: bool, builder_is_player: bool, was_constructing: bool, last_builder_present: bool, core_storage_capacity: int) -> Dictionary:
	return source_construct_build_state.deconstruct_state(current_block, builder_state, deconstruct_core_inventory, amount, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, deconstruct_refund_multiplier, core_present, state_infinite_resources, builder_is_player, was_constructing, last_builder_present, core_storage_capacity)

func construct_build_progress_state(progress_value: float) -> Dictionary:
	return source_construct_build_state.progress_state(progress_value)

func construct_build_version_state() -> Dictionary:
	return source_construct_build_state.version_state()

func construct_build_write_state(write_progress_value: float, write_previous_block_id: int, write_current_block_id: int, write_accumulator: Variant, write_total_accumulator: Variant, write_items_left: Variant) -> Dictionary:
	return source_construct_build_state.write_state(write_progress_value, write_previous_block_id, write_current_block_id, write_accumulator, write_total_accumulator, write_items_left)

func construct_build_read_state(read_progress_value: float, read_previous_block_id: int, read_current_block_id: int, read_accumulator_size: int, read_accumulator_values: Array, read_total_accumulator_values: Array, read_items_left_values: Array, read_revision_value: int, read_content_blocks: Dictionary, read_air_block: Variant, read_build_cost_multiplier: float) -> Dictionary:
	return source_construct_build_state.read_state(read_progress_value, read_previous_block_id, read_current_block_id, read_accumulator_size, read_accumulator_values, read_total_accumulator_values, read_items_left_values, read_revision_value, read_content_blocks, read_air_block, read_build_cost_multiplier)

func construct_build_draw_state(current_block: Variant, previous_block: Variant, draw_air_block: Variant, source_x: float, source_y: float, draw_rotation_degrees: float, draw_progress_value: float, draw_construct_color: float, source_time: float) -> Dictionary:
	return source_construct_build_state.draw_state(current_block, previous_block, draw_air_block, source_x, source_y, draw_rotation_degrees, draw_progress_value, draw_construct_color, source_time)

func source_building_display_name_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> String:
	return source_building_display_state.display_name_state(localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label)

func source_building_display_icon_state(block_ui_icon: Variant) -> Variant:
	return source_building_display_state.display_icon_state(block_ui_icon)

func source_building_flow_items_state(items_module: Variant) -> Variant:
	return source_building_display_state.flow_items_state(items_module)

func source_building_display_consumption_state(consumers: Array, self_state: Variant) -> Dictionary:
	return source_building_display_state.display_consumption_state(consumers, self_state)

func source_building_display_bars_state(bar_results: Array) -> Dictionary:
	return source_building_display_state.display_bars_state(bar_results)

func source_building_display_ui_gates_state(team_is_player: bool, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	return source_building_display_state.display_ui_gates_state(team_is_player, block_category, block_display_flow, net_active, has_last_accessed)

func source_arc_strings_fixed_one_decimal(value: float) -> String:
	return source_building_display_state.fixed_one_decimal(value)

func source_building_display_flow_rate_label(flow_rate: float, per_second_label: String) -> String:
	return source_building_display_state.game_display_flow_rate_label(self, flow_rate, per_second_label)

func source_building_cursor_state(block_configurable: bool, interactable_player_team: bool) -> String:
	return source_building_meta_state.cursor_state(block_configurable, interactable_player_team)

func source_building_on_configure_build_tapped_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	return source_building_configure_state.on_configure_build_tapped_state(clear_on_double_tap, same_building)

func source_building_on_configure_tapped_state(x: float, y: float) -> Dictionary:
	return source_building_configure_state.on_configure_tapped_state(x, y)

func source_building_on_configure_closed_state() -> Dictionary:
	return source_building_configure_state.on_configure_closed_state()

func source_building_configure_menu_visibility_state(_player: Variant) -> Dictionary:
	return source_building_configure_state.configure_menu_visibility_state(_player)

func source_building_should_show_configure_state(_player: Variant) -> Dictionary:
	return source_building_configure_state.should_show_configure_state(_player)

func source_building_should_hide_configure_state(_player: Variant) -> Dictionary:
	return source_building_configure_state.should_hide_configure_state(_player)

func source_building_check_solid_state() -> bool:
	return source_building_core_state.check_solid_state()

func source_building_handle_damage_state(amount: float) -> float:
	return source_building_damage_state.handle_damage_state(amount)

func source_building_absorb_lasers_state(block_absorb_lasers: bool) -> bool:
	return source_building_core_state.absorb_lasers_state(block_absorb_lasers)

func source_building_is_insulated_state(block_insulated: bool) -> bool:
	return source_building_core_state.is_insulated_state(block_insulated)

func source_building_collide_state(_other: Variant) -> bool:
	return source_building_core_state.collide_state(_other)

func source_building_collision_damage_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	return source_building_damage_state.collision_damage_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)

func source_building_damage_delegate_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.damage_delegate_state(source_team, damage_amount)

func source_building_bullet_damage_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.bullet_damage_state(bullet, source_team, damage_amount)

func source_building_hit_size(block_size_value: int, source_tilesize: float) -> float:
	return source_block_geometry.building_hit_size(block_size_value, source_tilesize)

func source_building_damage_dead_guard_state(dead_state: bool) -> Dictionary:
	return source_building_damage_state.dead_guard_state(dead_state)

func source_building_damage_block_health_scale_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	return source_building_damage_state.block_health_scale_state(damage_amount, health, block_health_multiplier, source_time)

func source_building_damage_handle_damage_gate_state(net_client: bool, health: float, damage_amount: float, handled_damage: float) -> Dictionary:
	return source_building_damage_state.handle_damage_gate_state(net_client, health, damage_amount, handled_damage)

func source_building_damage_health_changed_call_state() -> Dictionary:
	return source_building_damage_state.health_changed_call_state()

func source_building_damage_destroy_gate_state(health: float, self_state := {}) -> Dictionary:
	return source_building_damage_state.destroy_gate_state(health, self_state)

func source_building_health_changed_state(net_server: bool, self_state := {}) -> Dictionary:
	return source_building_meta_state.health_changed_state(net_server, self_state)

func source_building_sense_position_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return source_building_sense_state.sense_position_state(world_x, world_y, source_tilesize)

func source_building_sense_health_process_state(health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	return source_building_sense_state.sense_health_process_state(health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)

func source_building_sense_totals_state(total_items: float, total_liquids: float, total_power: float) -> Dictionary:
	return source_building_sense_state.sense_totals_state(total_items, total_liquids, total_power)

func source_building_sense_capacity_power_net_state(block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float) -> Dictionary:
	return source_building_sense_state.sense_capacity_power_net_state(block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, source_time_defaults.TICK_RATE)

func source_building_sense_enabled_controlled_state(enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float) -> Dictionary:
	return source_building_sense_state.sense_enabled_controlled_state(enabled_state, is_control_block, is_controlled, ctrl_player_value)

func source_building_sense_payload_size_state(has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float) -> Dictionary:
	return source_building_sense_state.sense_payload_size_state(has_payload_seq, payload_seq_total, has_single_payload, block_size_value)

func source_building_sense_object_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	return source_building_sense_state.sense_object_state(sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content)

func source_building_sense_content_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	return source_building_sense_state.sense_content_state(content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount)

func generated_building_comp_sense_content_bridge_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	return source_building_sense_state.generated_building_comp_sense_content_bridge_state(content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount)

func source_building_sense_camera_default_state(is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float) -> Dictionary:
	return source_building_sense_state.sense_camera_default_state(is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height)

func source_building_control_enabled_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:
	return source_building_control_state.control_enabled_state(current_enabled, control_type, p1, source_math_defaults.FLOAT_ROUNDING_ERROR)

func generated_building_comp_control_enabled_bridge_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:
	return source_building_control_state.generated_control_enabled_bridge_state(current_enabled, control_type, p1, source_math_defaults.FLOAT_ROUNDING_ERROR)

func source_building_control_config_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	return source_building_control_state.control_config_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)

func generated_building_comp_control_config_bridge_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	return source_building_control_state.generated_control_config_bridge_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)

func source_building_set_prop_health_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	return source_building_set_prop_state.health_state(prop, current_health, max_health_value, value, dead_state, self_state)

func generated_building_comp_set_prop_health_bridge_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	return source_building_set_prop_state.generated_health_bridge_state(prop, current_health, max_health_value, value, dead_state, self_state)

func source_building_set_prop_team_double_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	return source_building_set_prop_state.team_double_state(prop, current_team_id, value)

func generated_building_comp_set_prop_team_double_bridge_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	return source_building_set_prop_state.generated_team_double_bridge_state(prop, current_team_id, value)

func source_building_set_prop_total_power_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	return source_building_set_prop_state.total_power_state(prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value)

func generated_building_comp_set_prop_total_power_bridge_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	return source_building_set_prop_state.generated_total_power_bridge_state(prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value)

func source_building_set_prop_team_object_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	return source_building_set_prop_state.team_object_state(prop, current_team_value, value_is_team, team_value)

func generated_building_comp_set_prop_team_object_bridge_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	return source_building_set_prop_state.generated_team_object_bridge_state(prop, current_team_value, value_is_team, team_value)

func generated_building_comp_set_prop_item_content_bridge_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	return source_building_set_prop_state.generated_item_content_bridge_state(content_type, has_items_module, item_value, current_amount, value, accepted_stack)

func generated_building_comp_set_prop_liquid_content_bridge_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	return source_building_set_prop_state.generated_liquid_content_bridge_state(content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid)

func source_building_set_prop_item_content_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	return source_building_set_prop_state.item_content_state(content_type, has_items_module, item_value, current_amount, value, accepted_stack)

func source_building_set_prop_liquid_content_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	return source_building_set_prop_state.liquid_content_state(content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid)

func generated_building_comp_in_fog_initial_gate_bridge_state(same_team: bool, rules_fog: bool) -> Dictionary:
	return source_building_visibility_state.generated_in_fog_initial_gate_bridge_state(same_team, rules_fog)

func generated_building_comp_in_fog_discovery_gate_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	return source_building_visibility_state.generated_in_fog_discovery_gate_bridge_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)

func generated_building_comp_in_fog_visibility_loop_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	return source_building_visibility_state.generated_in_fog_visibility_loop_bridge_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)

func source_building_in_fog_initial_gate_state(same_team: bool, rules_fog: bool) -> Dictionary:
	return source_building_visibility_state.in_fog_initial_gate_state(same_team, rules_fog)

func source_building_in_fog_discovery_gate_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	return source_building_visibility_state.in_fog_discovery_gate_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)

func source_building_in_fog_visibility_loop_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	return source_building_visibility_state.in_fog_visibility_loop_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)

func source_building_write_base_timescale_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.write_base_timescale_state(current_time_scale, current_time_scale_duration, source_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_write_base_timescale_bridge_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.generated_write_base_timescale_bridge_state(current_time_scale, current_time_scale_duration)

func source_building_read_base_timescale_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.read_base_timescale_state(current_module_bits, read_time_scale, read_time_scale_duration, source_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_read_base_timescale_bridge_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.generated_read_base_timescale_bridge_state(current_module_bits, read_time_scale, read_time_scale_duration)

func source_building_module_bitmask_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	return source_building_time_state.module_bitmask_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler, source_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_module_bitmask_bridge_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	return source_building_time_state.generated_module_bitmask_bridge_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler)

func generated_building_comp_update_timescale_decay_bridge_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	return source_building_time_state.generated_update_timescale_decay_bridge_state(current_time_scale, current_time_scale_duration, time_delta)

func source_building_update_timescale_decay_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	return source_building_time_state.update_timescale_decay_state(current_time_scale, current_time_scale_duration, time_delta, source_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_update_ambient_sound_gate_bridge_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	return source_building_time_state.generated_update_ambient_sound_gate_bridge_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)

func source_building_update_ambient_sound_gate_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	return source_building_time_state.update_ambient_sound_gate_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)

func source_building_update_fog_visibility_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state := {}, tile_state := {}) -> Dictionary:
	return source_building_visibility_state.update_fog_visibility_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)

func generated_building_comp_update_fog_visibility_bridge_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state: Variant, tile_state: Variant) -> Dictionary:
	return source_building_visibility_state.generated_update_fog_visibility_bridge_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)

func source_building_hitbox_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_geometry.building_hitbox_state(world_x, world_y, block_size_value, source_tilesize)

func generated_building_comp_hitbox_bridge_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_geometry.generated_building_hitbox_bridge_state(world_x, world_y, block_size_value, source_tilesize)

func source_building_to_string_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> String:
	return source_building_meta_state.to_string_state(id_value, tile_x_value, tile_y_value, block_value)

func generated_building_comp_to_string_bridge_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> Dictionary:
	return source_building_meta_state.generated_to_string_bridge_state(id_value, tile_x_value, tile_y_value, block_value)

func source_building_tether_update_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	return source_building_tether_state.update_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)

func generated_building_tether_comp_update_bridge_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	return source_building_tether_state.generated_building_tether_update_bridge_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)

func source_child_add_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.add_state(child_state)

func generated_child_comp_add_bridge_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.generated_child_add_bridge_state(child_state)

func source_child_update_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.game_update_state(self, child_state)

func generated_child_comp_update_bridge_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.game_generated_child_update_bridge_state(self, child_state)

func source_pos_set_state(x_value: float, y_value: float) -> Dictionary:
	return source_basic_comp_state.pos_set_state(x_value, y_value)

func generated_pos_comp_set_bridge_state(x_value: float, y_value: float) -> Dictionary:
	return source_basic_comp_state.generated_pos_set_bridge_state(x_value, y_value)

func source_shielder_absorb_state() -> Dictionary:
	return source_basic_comp_state.shielder_absorb_state()

func generated_shielder_comp_absorb_bridge_state() -> Dictionary:
	return source_basic_comp_state.generated_shielder_absorb_bridge_state()

func source_sync_snap_sync_state() -> Dictionary:
	return source_sync_state.snap_sync_state()

func generated_sync_comp_snap_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_snap_sync_bridge_state()

func source_sync_snap_interpolation_state() -> Dictionary:
	return source_sync_state.snap_interpolation_state()

func generated_sync_comp_snap_interpolation_bridge_state() -> Dictionary:
	return source_sync_state.generated_snap_interpolation_bridge_state()

func source_sync_read_sync_state() -> Dictionary:
	return source_sync_state.read_sync_state()

func generated_sync_comp_read_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_read_sync_bridge_state()

func source_sync_write_sync_state() -> Dictionary:
	return source_sync_state.write_sync_state()

func generated_sync_comp_write_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_write_sync_bridge_state()

func source_sync_read_sync_manual_state() -> Dictionary:
	return source_sync_state.read_sync_manual_state()

func generated_sync_comp_read_sync_manual_bridge_state() -> Dictionary:
	return source_sync_state.generated_read_sync_manual_bridge_state()

func source_sync_write_sync_manual_state() -> Dictionary:
	return source_sync_state.write_sync_manual_state()

func generated_sync_comp_write_sync_manual_bridge_state() -> Dictionary:
	return source_sync_state.generated_write_sync_manual_bridge_state()

func source_sync_after_sync_state() -> Dictionary:
	return source_sync_state.after_sync_state()

func generated_sync_comp_after_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_after_sync_bridge_state()

func source_sync_interpolate_state() -> Dictionary:
	return source_sync_state.interpolate_state()

func generated_sync_comp_interpolate_bridge_state() -> Dictionary:
	return source_sync_state.generated_interpolate_bridge_state()

func source_sync_is_sync_hidden_state(player: Variant = null) -> Dictionary:
	return source_sync_state.is_sync_hidden_state(player)

func generated_sync_comp_is_sync_hidden_bridge_state(player: Variant = null) -> Dictionary:
	return source_sync_state.generated_is_sync_hidden_bridge_state(player)

func source_sync_handle_sync_hidden_state() -> Dictionary:
	return source_sync_state.handle_sync_hidden_state()

func generated_sync_comp_handle_sync_hidden_bridge_state() -> Dictionary:
	return source_sync_state.generated_handle_sync_hidden_bridge_state()

func source_sync_update_interpolate_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	return source_sync_state.update_interpolate_state(net_client, is_local, is_remote)

func generated_sync_comp_update_interpolate_bridge_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	return source_sync_state.generated_update_interpolate_bridge_state(net_client, is_local, is_remote)

func source_sync_remove_client_removed_entity_state(net_client: bool, entity_id: int) -> Dictionary:
	return source_sync_state.remove_client_removed_entity_state(net_client, entity_id)

func generated_sync_comp_remove_client_removed_entity_bridge_state(net_client: bool, entity_id: int) -> Dictionary:
	return source_sync_state.generated_remove_client_removed_entity_bridge_state(net_client, entity_id)

func source_block_unit_ammof_state(ammo: float) -> Dictionary:
	return source_block_unit_state.ammof_state(ammo)

func generated_block_unit_comp_ammof_bridge_state(ammo: float) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_ammof_bridge_state(ammo)

func source_block_unit_icon_state(tile_block_ui_icon: Variant) -> Dictionary:
	return source_block_unit_state.icon_state(tile_block_ui_icon)

func generated_block_unit_comp_icon_bridge_state(tile_block_ui_icon: Variant) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_icon_bridge_state(tile_block_ui_icon)

func source_block_unit_tile_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	return source_block_unit_state.tile_state(tile, tile_block_health, tile_health, tile_block_size, tilesize)

func generated_block_unit_comp_tile_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_tile_bridge_state(tile, tile_block_health, tile_health, tile_block_size, tilesize)

func generated_block_unit_comp_tile_source_tilesize_default_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_tile_source_tilesize_default_bridge_state(tile, tile_block_health, tile_health, tile_block_size)

func source_block_unit_add_state(tile_null: bool) -> Dictionary:
	return source_block_unit_state.add_state(tile_null)

func generated_block_unit_comp_add_bridge_state(tile_null: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_add_bridge_state(tile_null)

func source_block_unit_update_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.update_state(tile_exists, team, tile_team)

func generated_block_unit_comp_update_bridge_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_update_bridge_state(tile_exists, team, tile_team)

func source_block_unit_killed_state() -> Dictionary:
	return source_block_unit_state.killed_state()

func generated_block_unit_comp_killed_bridge_state() -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_killed_bridge_state()

func source_block_unit_damage_state(v: float, b: bool) -> Dictionary:
	return source_block_unit_state.damage_state(v, b)

func generated_block_unit_comp_damage_bridge_state(v: float, b: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_damage_bridge_state(v, b)

func source_block_unit_team_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.team_state(tile_exists, this_team, team, tile_team)

func generated_block_unit_comp_team_bridge_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_team_bridge_state(tile_exists, this_team, team, tile_team)

func source_block_unit_dead_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	return source_block_unit_state.dead_state(tile_null, tile_dead)

func generated_block_unit_comp_dead_bridge_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_dead_bridge_state(tile_null, tile_dead)

func source_block_unit_is_valid_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.is_valid_state(tile_exists, tile_is_valid)

func generated_block_unit_comp_is_valid_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_is_valid_bridge_state(tile_exists, tile_is_valid)

func source_block_unit_is_added_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.is_added_state(tile_exists, tile_is_valid)

func generated_block_unit_comp_is_added_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return source_block_unit_state.generated_block_unit_comp_is_added_bridge_state(tile_exists, tile_is_valid)

func source_builder_can_build_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	return source_builder_runtime_state.can_build_state(type_build_speed, build_speed_multiplier)

func generated_builder_comp_can_build_bridge_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_can_build_bridge_state(type_build_speed, build_speed_multiplier)

func source_builder_update_state() -> Dictionary:
	return source_builder_runtime_state.update_state()

func generated_builder_comp_update_bridge_state() -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_update_bridge_state()

func source_builder_after_read_state(plans_null: bool) -> Dictionary:
	return source_builder_runtime_state.after_read_state(plans_null)

func generated_builder_comp_after_read_bridge_state(plans_null: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_after_read_bridge_state(plans_null)

func source_builder_is_building_state(plans_size: int) -> Dictionary:
	return source_builder_runtime_state.is_building_state(plans_size)

func generated_builder_comp_is_building_bridge_state(plans_size: int) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_is_building_bridge_state(plans_size)

func source_builder_clear_building_state() -> Dictionary:
	return source_builder_runtime_state.clear_building_state()

func generated_builder_comp_clear_building_bridge_state() -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_clear_building_bridge_state()

func source_builder_draw_plan_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	return source_builder_draw_state.draw_plan_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)

func generated_builder_comp_draw_plan_bridge_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_plan_bridge_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)

func source_builder_draw_building_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	return source_builder_draw_state.draw_building_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)

func generated_builder_comp_draw_building_bridge_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_building_bridge_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)

func source_builder_draw_building_beam_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	return source_builder_draw_state.draw_building_beam_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)

func generated_builder_comp_draw_building_beam_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_building_beam_bridge_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)

func generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build)

func source_builder_draw_plan_top_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	return source_builder_draw_state.draw_plan_top_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)

func generated_builder_comp_draw_plan_top_bridge_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	return source_builder_draw_state.generated_builder_comp_draw_plan_top_bridge_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)

func source_builder_should_skip_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	return source_builder_runtime_state.should_skip_state(state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement)

func generated_builder_comp_should_skip_bridge_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_should_skip_bridge_state(state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement)

func source_builder_remove_build_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	return source_builder_runtime_state.remove_build_state(plans, x, y, breaking)

func generated_builder_comp_remove_build_bridge_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_remove_build_bridge_state(plans, x, y, breaking)

func source_builder_add_build_tail_state(place: Variant) -> Dictionary:
	return source_builder_runtime_state.add_build_tail_state(place)

func generated_builder_comp_add_build_tail_bridge_state(place: Variant) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_add_build_tail_bridge_state(place)

func source_builder_add_build_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	return source_builder_runtime_state.add_build_state(plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress)

func generated_builder_comp_add_build_bridge_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_add_build_bridge_state(plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress)

func source_builder_build_plan_state(plans_size: int, plans_first: Variant) -> Dictionary:
	return source_builder_runtime_state.build_plan_state(plans_size, plans_first)

func generated_builder_comp_build_plan_bridge_state(plans_size: int, plans_first: Variant) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_build_plan_bridge_state(plans_size, plans_first)

func source_builder_actively_building_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	return source_builder_runtime_state.actively_building_state(plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building)

func source_builder_build_step_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	return source_builder_runtime_state.build_step_state(entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current)

func generated_builder_comp_update_build_logic_bridge_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_update_build_logic_bridge_state(entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current)

func generated_builder_comp_actively_building_bridge_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	return source_builder_runtime_state.generated_builder_comp_actively_building_bridge_state(plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building)

func source_unit_tether_after_read_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.after_read_state(spawner_unit_id, groups_unit_get_by_id_result)

func generated_unit_tether_comp_after_read_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.generated_unit_tether_comp_after_read_bridge_state(spawner_unit_id, groups_unit_get_by_id_result)

func source_unit_tether_after_sync_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.after_sync_state(spawner_unit_id, groups_unit_get_by_id_result)

func generated_unit_tether_comp_after_sync_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.generated_unit_tether_comp_after_sync_bridge_state(spawner_unit_id, groups_unit_get_by_id_result)

func source_unit_tether_update_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	return source_unit_tether_state.update_state(spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id)

func generated_unit_tether_comp_update_bridge_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	return source_unit_tether_state.generated_unit_tether_comp_update_bridge_state(spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id)

func source_building_handle_liquid_amount(current_amount: float, amount: float) -> float:
	return source_building_liquid_state.handle_liquid_amount(current_amount, amount)
func source_building_accept_liquid_state(has_liquids: bool, consumes_liquid: bool) -> bool:
	return source_building_liquid_state.accept_liquid_state(has_liquids, consumes_liquid)
func source_building_dump_liquid_default_scaling_state(liquid: Variant, current_liquid_amount: float) -> Dictionary:
	return source_building_liquid_state.dump_liquid_default_scaling_state(liquid, current_liquid_amount)
func source_building_dump_liquid_campaign_unlock_state(liquid: Variant, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool) -> Dictionary:
	return source_building_liquid_state.dump_liquid_campaign_unlock_state(liquid, current_liquid_amount, net_client, state_is_campaign, team_is_default_team)
func source_building_dump_liquid_routing_gate_state(liquid: Variant, proximity_size: int, dump_cursor: int, output_dir: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array) -> Dictionary:
	return source_building_liquid_state.game_dump_liquid_routing_gate_state(self, liquid, proximity_size, dump_cursor, output_dir, rotation_value, relative_to_by_index, destination_present_by_index, other_has_liquids_by_index, can_dump_liquid_by_index, other_liquids_present_by_index)
func source_building_dump_liquid_fraction_transfer_state(liquid: Variant, scaling: float, eligible_indices: Array, current_liquid_amount: float, block_liquid_capacity: float, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array) -> Dictionary:
	return source_building_liquid_state.dump_liquid_fraction_transfer_state(liquid, scaling, eligible_indices, current_liquid_amount, block_liquid_capacity, other_liquid_amount_by_index, other_block_liquid_capacity_by_index)
func source_building_transfer_liquid_state(liquid: Variant, amount: float, next_block_liquid_capacity: float, next_liquid_amount: float, next_accepts_liquid: bool, current_liquid_amount: float) -> Dictionary:
	return source_building_liquid_state.transfer_liquid_state(liquid, amount, next_block_liquid_capacity, next_liquid_amount, next_accepts_liquid, current_liquid_amount)
func source_building_can_dump_liquid_default_state(to_state: Variant, liquid: Variant) -> Dictionary:
	return source_building_liquid_state.can_dump_liquid_default_state(to_state, liquid)
func source_building_can_dump_item_default_state(to_state: Variant, item: Variant) -> Dictionary:
	return source_building_item_dump_state.can_dump_item_default_state(to_state, item)
func source_building_on_proximity_removed_state(power_present: bool) -> Dictionary:
	return source_building_power_state.on_proximity_removed_state(power_present)

func source_building_on_proximity_added_state(power_present: bool) -> Dictionary:
	return source_building_power_state.on_proximity_added_state(power_present)

func source_building_on_proximity_update_state() -> Dictionary:
	return source_building_power_state.on_proximity_update_state()

func source_building_update_power_graph_state(other_power_present_by_index: Array) -> Dictionary:
	return source_building_power_state.update_power_graph_state(other_power_present_by_index)

func source_building_conducts_to_state(block_insulated: bool) -> Dictionary:
	return source_building_power_state.conducts_to_state(block_insulated)

func source_building_get_power_connections_empty_guard_state(power_present: bool, previous_out_count: int) -> Dictionary:
	return source_building_power_state.get_power_connections_empty_guard_state(power_present, previous_out_count)

func source_building_get_power_connections_proximity_guard_state(other_present_by_index: Array, other_power_present_by_index: Array, other_same_team_by_index: Array) -> Dictionary:
	return source_building_power_state.get_power_connections_proximity_guard_state(other_present_by_index, other_power_present_by_index, other_same_team_by_index)

func source_building_get_power_connections_power_compatibility_guard_state(block_consumes_power: bool, block_outputs_power: bool, block_conductive_power: bool, other_block_consumes_power_by_index: Array, other_block_outputs_power_by_index: Array, other_block_conductive_power_by_index: Array) -> Dictionary:
	return source_building_power_state.get_power_connections_power_compatibility_guard_state(block_consumes_power, block_outputs_power, block_conductive_power, other_block_consumes_power_by_index, other_block_outputs_power_by_index, other_block_conductive_power_by_index)

func source_building_get_power_connections_conducts_link_guard_state(conducts_to_other_by_index: Array, other_conducts_to_self_by_index: Array, power_link_contains_other_pos_by_index: Array) -> Dictionary:
	return source_building_power_state.get_power_connections_conducts_link_guard_state(conducts_to_other_by_index, other_conducts_to_self_by_index, power_link_contains_other_pos_by_index)

func source_building_get_power_connections_automatic_add_state(conducts_link_guard_pass_indices: Array, previous_out_count: int) -> Dictionary:
	return source_building_power_state.get_power_connections_automatic_add_state(conducts_link_guard_pass_indices, previous_out_count)

func source_building_get_power_connections_manual_links_loop_state(link_present_by_index: Array, link_build_present_by_index: Array, link_build_power_present_by_index: Array, link_build_same_team_by_index: Array, previous_out_count: int) -> Dictionary:
	return source_building_power_state.get_power_connections_manual_links_loop_state(link_present_by_index, link_build_present_by_index, link_build_power_present_by_index, link_build_same_team_by_index, previous_out_count)

func source_building_get_liquid_destination_default_state(from_state: Variant, liquid: Variant, self_state: Variant) -> Dictionary:
	return source_building_liquid_state.get_liquid_destination_default_state(from_state, liquid, self_state)
func source_building_get_payload_default_state() -> Dictionary:
	return source_building_payload_state.get_payload_default_state()

func source_building_take_payload_default_state() -> Dictionary:
	return source_building_payload_state.take_payload_default_state()

func source_building_get_payloads_default_state() -> Dictionary:
	return source_building_payload_state.get_payloads_default_state()

func source_building_put_item_state(item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array) -> Dictionary:
	return source_building_item_dump_state.game_put_item_state(self, item, proximity_size, dump_cursor, accepts_item_by_index, can_dump_by_index)
func source_building_produced_item_default_state(item: Variant) -> Dictionary:
	return source_building_item_dump_state.produced_item_default_state(item)
func source_building_produced_item_amount_state(item: Variant, amount: int, sector_present: bool, team_is_default_team: bool, net_client: bool) -> Dictionary:
	return source_building_item_dump_state.produced_item_amount_state(item, amount, sector_present, team_is_default_team, net_client)
func source_building_move_liquid_forward_state(leaks: bool, liquid: Variant, next_tile_present: bool, next_build_present: bool, next_block_solid: bool, next_block_has_liquids: bool, current_liquid_amount: float, move_liquid_return: float) -> Dictionary:
	return source_building_liquid_state.move_liquid_forward_state(leaks, liquid, next_tile_present, next_build_present, next_block_solid, next_block_has_liquids, current_liquid_amount, move_liquid_return)
func source_building_move_liquid_state(liquid: Variant, next_present: bool, destination_team_matches: bool, destination_block_has_liquids: bool, current_liquid_amount: float, destination_liquid_amount: float, source_block_liquid_capacity: float, source_block_liquid_pressure: float, destination_block_liquid_capacity: float, destination_accepts_liquid: bool) -> Dictionary:
	return source_building_liquid_state.move_liquid_state(liquid, next_present, destination_team_matches, destination_block_has_liquids, current_liquid_amount, destination_liquid_amount, source_block_liquid_capacity, source_block_liquid_pressure, destination_block_liquid_capacity, destination_accepts_liquid)
func source_building_move_liquid_reaction_setup_state(main_guard_passed: bool, transfer_guard_passed: bool, destination_consumes_liquid: bool, destination_current_amount: float, destination_block_liquid_capacity: float, fract_value: float, source_x: float, source_y: float, destination_x: float, destination_y: float, destination_current_liquid: Variant, other_block_reactive: bool, liquid_block_reactive: bool) -> Dictionary:
	return source_building_liquid_state.move_liquid_reaction_setup_state(main_guard_passed, transfer_guard_passed, destination_consumes_liquid, destination_current_amount, destination_block_liquid_capacity, fract_value, source_x, source_y, destination_x, destination_y, destination_current_liquid, other_block_reactive, liquid_block_reactive)
func source_building_move_liquid_fire_reaction_state(block_reactive_guard_passed: bool, other_flammability: float, liquid_temperature: float, liquid_flammability: float, other_temperature: float, fire_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return source_building_liquid_state.move_liquid_fire_reaction_state(block_reactive_guard_passed, other_flammability, liquid_temperature, liquid_flammability, other_temperature, fire_chance_delta_passed, fx, fy)
func source_building_move_liquid_steam_reaction_state(block_reactive_guard_passed: bool, fire_reaction_guard_passed: bool, liquid_temperature: float, other_temperature: float, current_liquid_amount: float, source_delta: float, steam_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return source_building_liquid_state.move_liquid_steam_reaction_state(block_reactive_guard_passed, fire_reaction_guard_passed, liquid_temperature, other_temperature, current_liquid_amount, source_delta, steam_chance_delta_passed, fx, fy)
func source_building_move_liquid_return_zero_state(next_present: bool, transfer_guard_passed: bool) -> Dictionary:
	return source_building_liquid_state.move_liquid_return_zero_state(next_present, transfer_guard_passed)
func source_move_forward_accept_state(has_front: bool, same_team: bool, front_accepts: bool) -> bool:
	return source_building_item_state.move_forward_accept_state(has_front, same_team, front_accepts)

func source_move_forward_to_core(item_id: String, has_front := true, same_team := true) -> bool:
	return source_building_item_state.move_forward_to_core_runtime_state(self, item_id, has_front, same_team)

func source_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	return source_building_item_dump_state.increment_dump_cursor_state(current_dump, proximity_size)

func set_drill_dump_cursor(value: int) -> void:
	drill_dump_cursor = value

func increment_drill_dump(proximity_size: int) -> int:
	return source_building_item_dump_state.increment_dump_cursor_runtime_state(self, proximity_size)

func source_building_dump_accumulate_default_state() -> Dictionary:
	return source_building_item_dump_state.dump_accumulate_default_state()
func source_building_dump_default_state() -> Dictionary:
	return source_building_item_dump_state.dump_default_state()
func source_building_dump_null_item_scan_state(item_ids: Array, item_present_by_index: Array) -> Dictionary:
	return source_building_item_dump_state.dump_null_item_scan_state(item_ids, item_present_by_index)
func source_building_dump_null_proximity_scan_state(proximity_size: int, dump_cursor: int) -> Dictionary:
	return source_building_item_dump_state.game_dump_null_proximity_scan_state(self, proximity_size, dump_cursor)
func source_building_dump_null_remove_item_state(item: Variant, item_amount_before: int) -> Dictionary:
	return source_building_item_dump_state.dump_null_remove_item_state(item, item_amount_before)
func source_building_dump_null_success_handoff_state(item: Variant, accepts_item: bool, can_dump: bool) -> Dictionary:
	return source_building_item_dump_state.dump_null_success_handoff_state(item, accepts_item, can_dump)
func source_building_dump_specific_proximity_scan_state(todump: Variant, proximity_size: int, dump_cursor: int) -> Dictionary:
	return source_building_item_dump_state.dump_specific_proximity_scan_state(todump, proximity_size, dump_cursor)
func source_building_dump_terminal_failure_state() -> Dictionary:
	return source_building_item_dump_state.dump_terminal_failure_state()
func source_dump_accumulate_attempt_state(current_accum: float, source_delta: float) -> Dictionary:
	return source_building_item_dump_state.dump_accumulate_state(current_accum, source_delta)

func step_building_dump_accum(source_delta: float) -> Dictionary:
	return source_building_item_dump_state.dump_accumulate_runtime_state(self, source_delta)

func drill_item_count(item_id: String) -> int:
	return source_drill_inventory_runtime_state.item_count(drill_items, item_id)

func drill_items_total() -> int:
	return source_drill_inventory_runtime_state.items_total(drill_items)

func add_drill_item(item_id: String, amount: int) -> void:
	source_drill_inventory_runtime_state.add_item_runtime_state(self, item_id, amount)

func source_offload_to_inventory(item_id: String, amount: int) -> void:
	source_drill_inventory_runtime_state.offload_to_inventory_runtime_state(self, item_id, amount)

func remove_drill_item(item_id: String, amount: int) -> int:
	return source_drill_inventory_runtime_state.remove_item_runtime_state(self, item_id, amount)

func source_dump_drill_item_to_core(item_id: String) -> bool:
	return bool(source_drill_inventory_runtime_state.game_dump_item_to_core_state(self, item_id).get("dump_success", false))

func requirements_text(block) -> String:
	return source_block_requirements_state.block_requirements_text(block)

func add_sprite(parent: Node, key: String, pos: Vector2) -> Sprite2D:
	return source_texture_runtime_state.add_sprite(parent, textures, key, pos, tile_size)

func add_ore_cell(parent: Node, key: String, item_id: String, cell: Vector2i) -> Sprite2D:
	ore_items_by_cell[cell_key(cell)] = item_id
	return add_sprite(parent, key, grid_to_world(cell))

func grid_to_world(cell: Vector2i) -> Vector2:
	return source_world_grid.grid_to_world(cell, tile_size)

func world_to_grid(pos: Vector2) -> Vector2i:
	return source_world_grid.world_to_grid(pos, tile_size)

func cell_key(cell: Vector2i) -> String:
	return source_world_grid.cell_key(cell)

func build_hud() -> void:
	update_hud()

func _process(delta: float) -> void:
	source_game_loop_runtime_state.process_tick(self, delta, mindustry_time_script)

func simulate_factory(delta: float) -> void:
	source_factory_runtime_state.simulate_factory(self, delta)

func simulate_drill_dump(delta: float) -> void:
	source_factory_runtime_state.apply_drill_dump(self, delta)

func factory_cell_context() -> Dictionary:
	return source_factory_runtime_state.cell_context(drill_pos, source_playable_scenario_defaults.conveyor_cells())

func source_factory_simulation_runtime_state(seconds: float) -> Dictionary:
	return source_factory_runtime_state.simulation_runtime_state(self, seconds)

func source_factory_simulation_apply_state(factory_state: Dictionary) -> Dictionary:
	var apply_context := source_factory_simulation_apply_state_script.runtime_context(self, drill_pos)
	return source_factory_simulation_apply_state_script.apply_state(factory_state, apply_context)

func factory_drill_dump_preview_state(seconds: float) -> Dictionary:
	return source_factory_runtime_state.drill_dump_preview_state(self, source_factory_runtime_state.drill_dump_preview_context(self, seconds, drill_pos, source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, source_time_defaults.TICK_RATE))

func step_factory_transport(seconds: float) -> Dictionary:
	return source_factory_runtime_state.transport_step_state(source_factory_runtime_state.transport_step_context(self, seconds, factory_cell_context(), drill_pos))

func step_factory_drill(seconds: float) -> Dictionary:
	return source_factory_runtime_state.drill_step_state(source_factory_runtime_state.drill_step_context(self, seconds, drill_pos))

func factory_runtime_state() -> Dictionary:
	return source_factory_runtime_state.game_summary_state(self, source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, source_playable_scenario_defaults.BLOCK_CONVEYOR)

func source_block_is_damaged(sprite) -> bool:
	return source_placed_block_state.damaged(sprite, source_block_defaults.HEALTH_DAMAGED_EPSILON)

func source_mend_projector_range(mend_projector, phase_heat := 0.0) -> float:
	return source_mend_projector_state.projector_range(mend_projector, phase_heat)

func find_damaged_block_in_mend_range(mend_cell: Vector2i, mend_projector, phase_heat := 0.0):
	return source_mend_projector_state.find_damaged_block_in_range(self, mend_cell, mend_projector, phase_heat)

func simulate_mend_projectors(delta: float) -> void:
	source_mend_projector_state.simulate_projectors(self, delta)

func step_mend_projectors(seconds: float) -> Dictionary:
	return source_mend_projector_state.step_projectors(self, seconds)

func find_overdrive_boost_target(overdrive_cell: Vector2i, overdrive_projector, phase_heat := 0.0):
	return source_overdrive_projector_state.find_overdrive_boost_target(self, overdrive_cell, overdrive_projector, phase_heat)

func apply_overdrive_boost_to_sprite(target, intensity: float, duration: float) -> Dictionary:
	return source_overdrive_projector_state.apply_overdrive_boost_to_sprite(self, target, intensity, duration)

func simulate_overdrive_projectors(delta: float) -> void:
	source_overdrive_projector_state.simulate_projectors(self, delta)

func step_overdrive_projectors(seconds: float) -> Dictionary:
	return source_overdrive_projector_state.step_projectors(self, seconds)

func selected_enemy_unit():
	return source_enemy_unit_runtime_state.selected_enemy_unit(self)

func spawn_enemy_wave() -> void:
	source_enemy_unit_runtime_state.spawn_wave(self)

func spawned_for_wave(group: Dictionary, wave_zero: int) -> int:
	return int(source_wave_spawn_runtime_state.spawned_for_wave_state(group, wave_zero).get("spawned", 0))

func spawn_enemy_unit(unit_type, index: int) -> void:
	source_enemy_unit_runtime_state.spawn_unit(self, unit_type, index)

func simulate_enemy_units(delta: float) -> void:
	source_enemy_unit_runtime_state.simulate_units(self, delta)

func source_wave_timing_runtime_state(seconds: float) -> Dictionary:
	return source_wave_timing_runtime_state_script.wave_timer_state(wave_cooldown, seconds * source_time_defaults.TICK_RATE, source_playable_scenario_defaults.PLAYABLE_WAVE_SPACING_SECONDS * source_time_defaults.TICK_RATE, enemy_units.size())

func source_game_over_core_destroyed_state(core_health_value: float, game_over_value: bool, attack_mode := false) -> Dictionary:
	return source_game_over_core_destroyed_state_script.core_destroyed_state(core_health_value, game_over_value, attack_mode)

func apply_core_damage(amount: float) -> Dictionary:
	return source_core_damage_runtime_state.game_apply_core_damage(self, amount)

func playthrough_runtime_state() -> Dictionary:
	return source_game_runtime_summary_state.playthrough_state(self)

func game_over_runtime_state() -> Dictionary:
	return source_game_runtime_summary_state.game_over_runtime_state(self)

func enemy_runtime_state() -> Dictionary:
	return source_enemy_unit_runtime_state.runtime_summary_state(self)

func source_unit_weapon_damage(unit_type) -> float:
	return source_unit_metadata_state.game_unit_weapon_damage_state(self, unit_type)

func source_unit_world_speed(unit_type) -> float:
	return source_unit_metadata_state.unit_world_speed(unit_type, source_time_defaults.TICK_RATE)

func source_unit_hit_size(unit_type) -> float:
	return source_unit_metadata_state.unit_hit_size(unit_type)

func source_unit_health(unit_type) -> float:
	return source_unit_metadata_state.unit_health(unit_type)

func source_status_apply_result(status_effect: String, duration: float, status_immune: bool) -> Dictionary:
	return source_status_apply_state.apply_result_state(status_effect, duration, status_immune)

func source_angles_angle_dist(a: float, b: float) -> float:
	return source_arc_angles_angle_dist(a, b)

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
	return source_bullet_type_update_state.game_update_homing_target_velocity_state(self, homing_initial_state, target_state, source_delta)

func source_bullet_type_update_homing_follow_aim_state(homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	return source_bullet_type_update_state.game_update_homing_follow_aim_state(self, homing_target_velocity_state, bullet_type_state, shooter_state, source_delta)

func source_bullet_type_update_weaving_state(bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	return source_bullet_type_update_state.game_update_weaving_state(self, bullet_state, bullet_type_state, random_seed_result, source_delta)

func source_bullet_type_update_weaving_rotate_speed_state(weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	return source_bullet_type_update_state.game_update_weaving_rotate_speed_state(self, weaving_state, bullet_type_state, source_delta)

func source_bullet_type_update_weaving_circle_shooter_state(rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
	return source_bullet_type_update_state.game_update_weaving_circle_shooter_state(self, rotate_speed_state, bullet_type_state, owner_health_state, source_delta)

func source_bullet_rotation_degrees(bullet_state: Dictionary) -> float:
	return source_bullet_type_update_state.game_bullet_rotation_degrees(self, bullet_state)

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
	return source_bullet_type_hit_state.entity_damage_cap_state(bullet_type_state, bullet_state, entity_state, hit_entity_state)
func source_bullet_type_hit_entity_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_state.entity_lifesteal_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, owner_health_state)
func source_bullet_type_hit_entity_armor_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, lifesteal_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_state.entity_armor_damage_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, lifesteal_state)
func source_bullet_type_hit_entity_unit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, armor_damage_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_state.entity_unit_effects_state(bullet_type_state, bullet_state, entity_state, armor_damage_state)
func source_bullet_type_hit_entity_unit_destroy_event_state(bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_effects_state: Dictionary) -> Dictionary:
	return source_bullet_type_hit_state.entity_unit_destroy_event_state(bullet_state, entity_state, damage_cap_state, unit_effects_state)
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

func source_unit_remove_state(trail_exists: bool, trail_size: int, trail_width: float, type_trail_color_exists: bool, team_color: String, type_trail_color: String) -> Dictionary:
	return source_unit_destroy_state.remove_state(trail_exists, trail_size, trail_width, type_trail_color_exists, team_color, type_trail_color)

func source_ability_update_state(unit: Variant) -> Dictionary:
	return source_ability_state.update_state(unit)

func generated_ability_update_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_state.generated_update_bridge_state(unit)

func source_ability_draw_state(unit: Variant) -> Dictionary:
	return source_ability_state.draw_state(unit)

func generated_ability_draw_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_state.generated_draw_bridge_state(unit)

func source_ability_death_state(unit: Variant) -> Dictionary:
	return source_ability_state.death_state(unit)

func generated_ability_death_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_state.generated_death_bridge_state(unit)

func source_ability_created_state(unit: Variant) -> Dictionary:
	return source_ability_state.created_state(unit)

func generated_ability_created_bridge_state(unit: Variant) -> Dictionary:
	return source_ability_state.generated_created_bridge_state(unit)

func source_ability_init_state(type_value: Variant) -> Dictionary:
	return source_ability_state.init_state(type_value)

func generated_ability_init_bridge_state(type_value: Variant) -> Dictionary:
	return source_ability_state.generated_init_bridge_state(type_value)

func source_ability_display_bars_state(unit: Variant, bars: Variant) -> Dictionary:
	return source_ability_state.display_bars_state(unit, bars)

func generated_ability_display_bars_bridge_state(unit: Variant, bars: Variant) -> Dictionary:
	return source_ability_state.generated_display_bars_bridge_state(unit, bars)

func source_ability_display_state(table_state: Variant, localized_value: String) -> Dictionary:
	return source_ability_state.display_state(table_state, localized_value)

func generated_ability_display_bridge_state(table_state: Variant, localized_value: String) -> Dictionary:
	return source_ability_state.generated_display_bridge_state(table_state, localized_value)

func source_ability_add_stats_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	return source_ability_state.add_stats_state(table_state, get_bundle_value, bundle_has_description, bundle_description)

func generated_ability_add_stats_bridge_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	return source_ability_state.generated_add_stats_bridge_state(table_state, get_bundle_value, bundle_has_description, bundle_description)

func source_ability_ability_stat_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	return source_ability_state.ability_stat_state(stat_value, values, formatted_value)

func generated_ability_ability_stat_bridge_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	return source_ability_state.generated_ability_stat_bridge_state(stat_value, values, formatted_value)

func source_ability_copy_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	return source_ability_state.copy_state(clone_supported, clone_value, exception_value)

func generated_ability_copy_bridge_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	return source_ability_state.generated_copy_bridge_state(clone_supported, clone_value, exception_value)

func source_ability_localized_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return source_ability_state.localized_state(get_bundle_value, bundle_value)

func generated_ability_localized_bridge_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return source_ability_state.generated_localized_bridge_state(get_bundle_value, bundle_value)

func source_ability_get_bundle_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	return source_ability_state.get_bundle_state(class_simple_name, is_anonymous_class, superclass_simple_name)

func generated_ability_get_bundle_bridge_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	return source_ability_state.generated_get_bundle_bridge_state(class_simple_name, is_anonymous_class, superclass_simple_name)

func source_unit_icon_state(type_ui_icon: String) -> Dictionary:
	return source_unit_metadata_state.unit_icon_state(type_ui_icon)

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

func source_arc_mathf_num(value: bool) -> int:
	return 1 if value else 0

func turret_simulation_callbacks() -> Dictionary:
	return source_turret_simulation_state.simulation_callbacks(self)

func turret_random_inaccuracy_offset(inaccuracy_range: float) -> float:
	return randf_range(-inaccuracy_range, inaccuracy_range)

func simulate_turrets(delta: float) -> void:
	source_turret_simulation_state.simulate_turrets(self, delta)

func source_block_outputs_items_state(has_items: bool) -> Dictionary:
	return source_block_query_state.outputs_items_state(has_items)

func generated_block_outputs_items_bridge_state(has_items: bool) -> Dictionary:
	return source_block_query_state.generated_block_outputs_items_bridge_state(has_items)

func source_block_can_place_on_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return source_block_query_placement_state_script.can_place_on_state(tile, team, rotation_value)

func generated_block_can_place_on_bridge_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_can_place_on_bridge_state(tile, team, rotation_value)

func source_block_can_break_state(tile: Variant) -> Dictionary:
	return source_block_query_placement_state_script.can_break_state(tile)

func generated_block_can_break_bridge_state(tile: Variant) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_can_break_bridge_state(tile)

func source_block_rotated_output_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return source_block_query_placement_state_script.rotated_output_state(rotate_value, x_value, y_value)

func generated_block_rotated_output_bridge_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_rotated_output_bridge_state(rotate_value, x_value, y_value)

func source_block_rotated_output_tile_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	return source_block_query_placement_state_script.rotated_output_tile_state(rotate_value, from_x, from_y, destination)

func generated_block_rotated_output_tile_bridge_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	return source_block_query_placement_state_script.generated_block_rotated_output_tile_bridge_state(rotate_value, from_x, from_y, destination)

func source_block_synthetic_state(update_value: bool, destructible_value: bool) -> Dictionary:
	return source_block_query_darkness_state_script.synthetic_state(update_value, destructible_value)

func generated_block_synthetic_bridge_state(update_value: bool, destructible_value: bool) -> Dictionary:
	return source_block_query_darkness_state_script.generated_block_synthetic_bridge_state(update_value, destructible_value)

func source_block_check_force_dark_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.check_force_dark_state(force_dark_value, tile)

func generated_block_check_force_dark_bridge_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.generated_block_check_force_dark_bridge_state(force_dark_value, tile)

func source_block_is_darkened_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.is_darkened_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

func generated_block_is_darkened_bridge_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	return source_block_query_darkness_state_script.generated_block_is_darkened_bridge_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

func source_block_consumes_item_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	return source_block_query_filter_state_script.consumes_item_state(item_filter, item_id, item)

func generated_block_consumes_item_bridge_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	return source_block_query_filter_state_script.generated_block_consumes_item_bridge_state(item_filter, item_id, item)

func source_block_consumes_liquid_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	return source_block_query_filter_state_script.consumes_liquid_state(liquid_filter, liquid_id, liq)

func generated_block_consumes_liquid_bridge_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	return source_block_query_filter_state_script.generated_block_consumes_liquid_bridge_state(liquid_filter, liquid_id, liq)

func source_block_has_building_state(destructible_value: bool, update_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.has_building_state(destructible_value, update_value)

func generated_block_has_building_bridge_state(destructible_value: bool, update_value: bool) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_has_building_bridge_state(destructible_value, update_value)

func source_block_is_multiblock_state(size_value: int) -> Dictionary:
	return source_block_query_basic_state_script.is_multiblock_state(size_value)

func generated_block_is_multiblock_bridge_state(size_value: int) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_multiblock_bridge_state(size_value)

func source_block_is_air_state(id_value: int) -> Dictionary:
	return source_block_query_basic_state_script.is_air_state(id_value)

func generated_block_is_air_bridge_state(id_value: int) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_air_bridge_state(id_value)

func source_block_can_be_built_state(build_visibility_value: String) -> Dictionary:
	return source_block_query_basic_state_script.can_be_built_state(build_visibility_value)

func generated_block_can_be_built_bridge_state(build_visibility_value: String) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_can_be_built_bridge_state(build_visibility_value)

func source_block_is_static_state(cache_layer_value: String) -> Dictionary:
	return source_block_query_basic_state_script.is_static_state(cache_layer_value)

func generated_block_is_static_bridge_state(cache_layer_value: String) -> Dictionary:
	return source_block_query_basic_state_script.generated_block_is_static_bridge_state(cache_layer_value)

func source_block_has_consumer_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.has_consumer_state(consume_builder_contains, cons)

func generated_block_has_consumer_bridge_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.generated_block_has_consumer_bridge_state(consume_builder_contains, cons)

func source_block_remove_consumer_state(consumers_length: int, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.remove_consumer_state(consumers_length, cons)

func generated_block_remove_consumer_bridge_state(consumers_length: int, cons: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.generated_block_remove_consumer_bridge_state(consumers_length, cons)

func source_block_remove_consumers_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.remove_consumers_state(consume_builder_contains_power_after_remove, b)

func generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	return source_block_query_consumer_state_script.generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove, b)

func source_block_setup_requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.setup_requirements_simple_state(cat, stacks)

func generated_block_setup_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_setup_requirements_simple_bridge_state(cat, stacks)

func source_block_setup_requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.setup_requirements_visible_state(cat, build_visibility, stacks)

func generated_block_setup_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_setup_requirements_visible_bridge_state(cat, build_visibility, stacks)

func source_block_requirements_unlocked_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return source_block_requirements_state.requirements_unlocked_state(cat, stacks, unlocked)

func generated_block_requirements_unlocked_bridge_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return source_block_requirements_state.generated_block_requirements_unlocked_bridge_state(cat, stacks, unlocked)

func source_block_requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.requirements_simple_state(cat, stacks)

func generated_block_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_requirements_simple_bridge_state(cat, stacks)

func source_block_requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.requirements_visible_state(cat, build_visibility, stacks)

func generated_block_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return source_block_requirements_state.generated_block_requirements_visible_bridge_state(cat, build_visibility, stacks)

func source_block_init_building_default_state(build_type_before: Variant) -> Dictionary:
	return source_block_init_building_default_state_script.building_default_state(build_type_before)

func generated_block_init_building_default_bridge_state(build_type_before: Variant) -> Dictionary:
	return source_block_init_building_default_state_script.generated_block_init_building_default_bridge_state(build_type_before)

func source_block_research_requirements_research_cost_state(research_cost: Variant) -> Dictionary:
	return source_block_research_requirements_state.research_cost_state(research_cost)

func generated_block_research_requirements_research_cost_bridge_state(research_cost: Variant) -> Dictionary:
	return source_block_research_requirements_state.generated_block_research_requirements_research_cost_bridge_state(research_cost)

func source_block_research_requirements_empty_state(research_cost: Variant, research_cost_multiplier: float) -> Dictionary:
	return source_block_research_requirements_state.empty_state(research_cost, research_cost_multiplier)

func generated_block_research_requirements_empty_bridge_state(research_cost: Variant, research_cost_multiplier: float) -> Dictionary:
	return source_block_research_requirements_state.generated_block_research_requirements_empty_bridge_state(research_cost, research_cost_multiplier)

func source_block_research_requirements_loop_shape_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array) -> Dictionary:
	return source_block_research_requirements_state.loop_shape_state(research_cost, research_cost_multiplier, requirements)

func generated_block_research_requirements_loop_shape_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array) -> Dictionary:
	return source_block_research_requirements_state.generated_block_research_requirements_loop_shape_bridge_state(research_cost, research_cost_multiplier, requirements)

func source_block_research_requirements_quantity_formula_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return source_block_research_requirements_state.quantity_formula_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func generated_block_research_requirements_quantity_formula_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return source_block_research_requirements_state.generated_block_research_requirements_quantity_formula_bridge_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func source_block_research_requirements_round_amount_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return source_block_research_requirements_state.round_amount_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func generated_block_research_requirements_round_amount_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return source_block_research_requirements_state.generated_block_research_requirements_round_amount_bridge_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func source_block_research_requirements_output_fill_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return source_block_research_requirements_state.output_fill_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func generated_block_research_requirements_output_fill_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return source_block_research_requirements_state.generated_block_research_requirements_output_fill_bridge_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func source_block_get_dependencies_requirements_state(requirements: Array) -> Dictionary:
	return source_block_get_dependencies_state.requirements_state(requirements)

func generated_block_get_dependencies_requirements_bridge_state(requirements: Array) -> Dictionary:
	return source_block_get_dependencies_state.generated_block_get_dependencies_requirements_bridge_state(requirements)

func source_block_get_dependencies_consume_builder_optional_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.consume_builder_optional_state(requirements, consume_builder)

func generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements, consume_builder)

func source_block_get_dependencies_consume_items_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.consume_items_state(requirements, consume_builder)

func generated_block_get_dependencies_consume_items_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return source_block_get_dependencies_state.generated_block_get_dependencies_consume_items_bridge_state(requirements, consume_builder)

func source_block_get_content_type_state() -> Dictionary:
	return source_block_metadata_state.content_type_state()

func generated_block_get_content_type_bridge_state() -> Dictionary:
	return source_block_metadata_state.generated_content_type_bridge_state()

func source_block_logic_visible_state(build_visibility_value: String) -> Dictionary:
	return source_block_metadata_state.logic_visible_state(build_visibility_value)

func generated_block_logic_visible_bridge_state(build_visibility_value: String) -> Dictionary:
	return source_block_metadata_state.generated_logic_visible_bridge_state(build_visibility_value)

func source_block_post_init_database_tag_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	return source_block_post_init_state.database_tag_state(database_tag_before, category_name)

func generated_block_post_init_database_tag_bridge_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	return source_block_post_init_state.generated_database_tag_bridge_state(database_tag_before, category_name)

func source_block_post_init_shown_planets_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	return source_block_post_init_state.shown_planets_state(requirements, shown_planets_before, content_planets)

func generated_block_post_init_shown_planets_bridge_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	return source_block_post_init_state.generated_shown_planets_bridge_state(requirements, shown_planets_before, content_planets)

func source_block_init_destroy_sound_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.destroy_sound_state(destroy_sound_before, size_value)

func generated_block_init_destroy_sound_bridge_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.generated_block_init_destroy_sound_bridge_state(destroy_sound_before, size_value)

func source_block_init_place_sound_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.place_sound_state(place_sound_before, size_value)

func generated_block_init_place_sound_bridge_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.generated_block_init_place_sound_bridge_state(place_sound_before, size_value)

func source_block_init_break_sound_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.break_sound_state(break_sound_before, size_value)

func generated_block_init_break_sound_bridge_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	return source_block_init_sound_state.generated_block_init_break_sound_bridge_state(break_sound_before, size_value)

func source_block_init_custom_shadow_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	return source_block_init_flags_state.custom_shadow_state(custom_shadow, has_shadow_before)

func generated_block_init_custom_shadow_bridge_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	return source_block_init_flags_state.generated_custom_shadow_bridge_state(custom_shadow, has_shadow_before)

func source_block_init_under_bullets_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	return source_block_init_flags_state.under_bullets_state(under_bullets, priority_before)

func generated_block_init_under_bullets_bridge_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	return source_block_init_flags_state.generated_under_bullets_bridge_state(under_bullets, priority_before)

func source_block_init_fog_radius_flag_state(fog_radius: int, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.fog_radius_flag_state(fog_radius, flags_before)

func generated_block_init_fog_radius_flag_bridge_state(fog_radius: int, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.generated_fog_radius_flag_bridge_state(fog_radius, flags_before)

func source_block_init_sync_flag_state(sync_value: bool, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.sync_flag_state(sync_value, flags_before)

func generated_block_init_sync_flag_bridge_state(sync_value: bool, flags_before: Array) -> Dictionary:
	return source_block_init_flags_state.generated_sync_flag_bridge_state(sync_value, flags_before)

func source_block_init_health_scaled_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	return source_block_init_health_state.health_scaled_state(health_before, size_value, scaled_health)

func generated_block_init_health_scaled_bridge_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	return source_block_init_health_state.generated_health_scaled_bridge_state(health_before, size_value, scaled_health)

func source_block_init_health_requirements_scaling_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	return source_block_init_health_state.health_requirements_scaling_state(health_before, size_value, scaled_health_before, requirement_health_scalings)

func generated_block_init_health_requirements_scaling_bridge_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	return source_block_init_health_state.generated_health_requirements_scaling_bridge_state(health_before, size_value, scaled_health_before, requirement_health_scalings)

func source_block_init_clip_size_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_clip_state.clip_size_state(clip_size_before, size_value, source_tilesize)

func generated_block_init_clip_size_bridge_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_clip_state.generated_clip_size_bridge_state(clip_size_before, size_value, source_tilesize)

func source_block_init_light_clip_size_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	return source_block_init_clip_state.light_clip_size_state(light_clip_size_before, clip_size)

func generated_block_init_light_clip_size_bridge_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	return source_block_init_clip_state.generated_light_clip_size_bridge_state(light_clip_size_before, clip_size)

func source_block_init_liquid_light_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	return source_block_init_clip_state.liquid_light_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value)

func generated_block_init_liquid_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	return source_block_init_clip_state.generated_liquid_light_bridge_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value)

func source_block_init_liquid_capacity_default_state(liquid_capacity_before: float) -> Dictionary:
	return source_block_init_clip_state.liquid_capacity_default_state(liquid_capacity_before)

func generated_block_init_liquid_capacity_default_bridge_state(liquid_capacity_before: float) -> Dictionary:
	return source_block_init_clip_state.generated_liquid_capacity_default_bridge_state(liquid_capacity_before)

func source_block_init_emit_light_radius_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	return source_block_init_clip_state.emit_light_radius_state(emit_light, light_clip_size_before, light_radius)

func generated_block_init_emit_light_radius_bridge_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	return source_block_init_clip_state.generated_emit_light_radius_bridge_state(emit_light, light_clip_size_before, light_radius)

func source_block_init_accepts_items_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	return source_block_init_placement_state.accepts_items_state(block_group, category_value, accepts_items_before)

func generated_block_init_accepts_items_bridge_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	return source_block_init_placement_state.generated_accepts_items_bridge_state(block_group, category_value, accepts_items_before)

func source_block_init_offset_state(size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_placement_state.offset_state(size_value, source_tilesize)

func generated_block_init_offset_bridge_state(size_value: int, source_tilesize: float) -> Dictionary:
	return source_block_init_placement_state.generated_offset_bridge_state(size_value, source_tilesize)

func source_block_init_build_time_requirements_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	return source_block_init_build_time_state.requirements_state(build_time_before, requirement_stacks)

func generated_block_init_build_time_requirements_bridge_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	return source_block_init_build_time_state.generated_requirements_bridge_state(build_time_before, requirement_stacks)

func source_block_init_build_time_default_state(build_time_before: float) -> Dictionary:
	return source_block_init_build_time_state.default_state(build_time_before)

func generated_block_init_build_time_default_bridge_state(build_time_before: float) -> Dictionary:
	return source_block_init_build_time_state.generated_default_bridge_state(build_time_before)

func source_block_init_build_time_multiplier_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	return source_block_init_build_time_state.multiplier_state(build_time_before, build_cost_multiplier)

func generated_block_init_build_time_multiplier_bridge_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	return source_block_init_build_time_state.generated_multiplier_bridge_state(build_time_before, build_cost_multiplier)

func source_block_init_consumer_arrays_state(consume_builder: Array) -> Dictionary:
	return source_block_init_consumer_state.arrays_state(consume_builder)

func generated_block_init_consumer_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	return source_block_init_consumer_state.generated_consumer_arrays_bridge_state(consume_builder)

func source_block_reinitialize_consumers_arrays_state(consume_builder: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.arrays_state(consume_builder)

func generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder)

func source_block_reinitialize_consumers_item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_reinitialize_consumers_state.item_liquid_filters_state(content_items_size, content_liquids_size)

func generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(content_items_size, content_liquids_size)

func source_block_reinitialize_consumers_outputs_power_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	return source_block_reinitialize_consumers_state.outputs_power_state(outputs_power, has_power_before)

func generated_block_reinitialize_consumers_outputs_power_bridge_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_outputs_power_bridge_state(outputs_power, has_power_before)

func source_block_reinitialize_consumers_apply_loop_state(consumers: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.apply_loop_state(consumers)

func generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	return source_block_reinitialize_consumers_state.generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers)

func source_block_check_content_array_capacity_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	return source_block_check_content_array_capacity_state_script.check_content_array_capacity_state(item_filter, liquid_filter, items, liquids)

func generated_block_check_content_array_capacity_bridge_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	return source_block_check_content_array_capacity_state_script.generated_block_check_content_array_capacity_bridge_state(item_filter, liquid_filter, items, liquids)

func source_block_load_base_regions_state(name_value: String) -> Dictionary:
	return source_block_load_state.base_regions_state(name_value)

func generated_block_load_base_regions_bridge_state(name_value: String) -> Dictionary:
	return source_block_load_state.generated_block_load_base_regions_bridge_state(name_value)

func source_block_load_team_regions_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	return source_block_load_state.team_regions_state(name_value, team_region_found, team_region, teams)

func generated_block_load_team_regions_bridge_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	return source_block_load_state.generated_block_load_team_regions_bridge_state(name_value, team_region_found, team_region, teams)

func source_block_load_variant_regions_state(name_value: String, variants: int) -> Dictionary:
	return source_block_load_state.variant_regions_state(name_value, variants)

func generated_block_load_variant_regions_bridge_state(name_value: String, variants: int) -> Dictionary:
	return source_block_load_state.generated_block_load_variant_regions_bridge_state(name_value, variants)

func source_block_load_variant_shadow_regions_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	return source_block_load_state.variant_shadow_regions_state(name_value, variants, custom_shadow)

func generated_block_load_variant_shadow_regions_bridge_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	return source_block_load_state.generated_block_load_variant_shadow_regions_bridge_state(name_value, variants, custom_shadow)

func source_block_is_hidden_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	return source_block_plan_state.is_hidden_state(build_visibility_visible, revealed_blocks_contains_self)

func generated_block_is_hidden_bridge_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	return source_block_plan_state.generated_block_is_hidden_bridge_state(build_visibility_visible, revealed_blocks_contains_self)

func source_block_plan_rotation_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return source_block_plan_state.plan_rotation_state(rotate_value, lock_rotation, rot)

func generated_block_plan_rotation_bridge_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return source_block_plan_state.generated_block_plan_rotation_bridge_state(rotate_value, lock_rotation, rot)

func source_block_flip_rotation_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	return source_block_plan_state.game_flip_rotation_state(self, rotation_before, x_value, invert_flip, rotate_value, lock_rotation)

func generated_block_flip_rotation_bridge_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	return source_block_plan_state.generated_block_flip_rotation_bridge_state(rotation_before, x_value, invert_flip, rotate_value, lock_rotation)

func source_block_get_plan_configs_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	return source_block_plan_state.get_plan_configs_state(options_before, item_configured, liquid_configured, content_items, content_liquids)

func generated_block_get_plan_configs_bridge_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	return source_block_plan_state.generated_block_get_plan_configs_bridge_state(options_before, item_configured, liquid_configured, content_items, content_liquids)

func source_block_sense_laccess_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	return source_block_sense_state.laccess_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

func generated_block_sense_laccess_bridge_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	return source_block_sense_state.generated_block_sense_laccess_bridge_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

func source_block_sense_content_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	return source_block_sense_state.content_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

func generated_block_sense_content_bridge_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	return source_block_sense_state.generated_block_sense_content_bridge_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

func source_block_sense_object_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	return source_block_sense_state.object_state(sensor, block_name, no_sensed)

func generated_block_sense_object_bridge_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	return source_block_sense_state.generated_block_sense_object_bridge_state(sensor, block_name, no_sensed)

func source_build_payload_block_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.block_state(build_block)

func generated_build_payload_block_bridge_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_block_bridge_state(build_block)

func source_build_payload_constructor_block_team_state(block: Variant, team: Variant) -> Dictionary:
	return source_build_payload_state.constructor_block_team_state(block, team)

func generated_build_payload_constructor_block_team_bridge_state(block: Variant, team: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_constructor_block_team_bridge_state(block, team)

func source_build_payload_constructor_build_state(build: Variant) -> Dictionary:
	return source_build_payload_state.constructor_build_state(build)

func generated_build_payload_constructor_build_bridge_state(build: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_constructor_build_bridge_state(build)

func source_unit_payload_constructor_state(unit: Variant) -> Dictionary:
	return source_unit_payload_basic_state.constructor_state(unit)

func generated_unit_payload_constructor_bridge_state(unit: Variant) -> Dictionary:
	return source_unit_payload_basic_state.generated_constructor_bridge_state(unit)

func source_unit_payload_show_overlay_texture_region_state(icon: Variant) -> Dictionary:
	return source_unit_payload_basic_state.show_overlay_texture_region_state(icon)

func generated_unit_payload_show_overlay_texture_region_bridge_state(icon: Variant) -> Dictionary:
	return source_unit_payload_basic_state.generated_show_overlay_texture_region_bridge_state(icon)

func source_unit_payload_show_overlay_drawable_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	return source_unit_payload_basic_state.show_overlay_drawable_state(icon_null, headless, region)

func generated_unit_payload_show_overlay_drawable_bridge_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	return source_unit_payload_basic_state.generated_show_overlay_drawable_bridge_state(icon_null, headless, region)

func source_unit_payload_content_equals_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.content_equals_state(other_is_unit_payload, other_unit_type, unit_type)

func generated_unit_payload_content_equals_bridge_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.generated_content_equals_bridge_state(other_is_unit_payload, other_unit_type, unit_type)

func source_unit_payload_update_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.update_state(unit_type, unit, unit_holder, building_holder)

func generated_unit_payload_update_bridge_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.generated_update_bridge_state(unit_type, unit, unit_holder, building_holder)

func source_unit_payload_content_state(unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.content_state(unit_type)

func generated_unit_payload_content_bridge_state(unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.generated_content_bridge_state(unit_type)

func source_unit_payload_requirements_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	return source_unit_payload_requirements_state_script.requirements_state(unit_type, total_requirements)

func generated_unit_payload_requirements_bridge_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	return source_unit_payload_requirements_state_script.generated_requirements_bridge_state(unit_type, total_requirements)

func source_unit_payload_build_time_state(unit_type: Variant, build_time: float) -> Dictionary:
	return source_unit_payload_requirements_state_script.build_time_state(unit_type, build_time)

func generated_unit_payload_build_time_bridge_state(unit_type: Variant, build_time: float) -> Dictionary:
	return source_unit_payload_requirements_state_script.generated_build_time_bridge_state(unit_type, build_time)

func source_unit_payload_write_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	return source_unit_payload_io_state.write_state(payload_unit, unit_class_id)

func generated_unit_payload_write_bridge_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	return source_unit_payload_io_state.generated_write_bridge_state(payload_unit, unit_class_id)

func source_unit_payload_set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_unit_payload_io_state.set_state(x, y, rotation_value)

func generated_unit_payload_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_unit_payload_io_state.generated_set_bridge_state(x, y, rotation_value)

func source_unit_payload_x_state(unit_x: float) -> Dictionary:
	return source_unit_payload_io_state.x_state(unit_x)

func generated_unit_payload_x_bridge_state(unit_x: float) -> Dictionary:
	return source_unit_payload_io_state.generated_x_bridge_state(unit_x)

func source_unit_payload_y_state(unit_y: float) -> Dictionary:
	return source_unit_payload_io_state.y_state(unit_y)

func generated_unit_payload_y_bridge_state(unit_y: float) -> Dictionary:
	return source_unit_payload_io_state.generated_y_bridge_state(unit_y)

func source_unit_payload_rotation_state(unit_rotation: float) -> Dictionary:
	return source_unit_payload_io_state.rotation_state(unit_rotation)

func generated_unit_payload_rotation_bridge_state(unit_rotation: float) -> Dictionary:
	return source_unit_payload_io_state.generated_rotation_bridge_state(unit_rotation)

func source_unit_payload_size_state(unit_hit_size: float) -> Dictionary:
	return source_unit_payload_io_state.size_state(unit_hit_size)

func generated_unit_payload_size_bridge_state(unit_hit_size: float) -> Dictionary:
	return source_unit_payload_io_state.generated_size_bridge_state(unit_hit_size)

func source_unit_payload_dump_type_null_guard_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_dump_state.type_null_guard_state(unit_type_null)

func generated_unit_payload_dump_type_null_guard_bridge_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_type_null_guard_bridge_state(unit_type_null)

func source_unit_payload_dump_can_create_guard_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	return source_unit_payload_dump_state.can_create_guard_state(unit_type_null, units_can_create)

func generated_unit_payload_dump_can_create_guard_bridge_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_can_create_guard_bridge_state(unit_type_null, units_can_create)

func source_unit_payload_dump_solidity_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	return source_unit_payload_dump_state.solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)

func generated_unit_payload_dump_solidity_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_solidity_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)

func source_unit_payload_dump_overlap_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	return source_unit_payload_dump_state.overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)

func generated_state_matches_generated_subset(result: Variant, canonical: Dictionary, ignored_keys: Array = []) -> bool:
	return source_generated_class_runtime.generated_state_matches_generated_subset_ignoring_source_owner(result, canonical, ignored_keys)

func generated_state_matches_generated_subset_or_nan(result: Variant, canonical: Dictionary, nan_key: String, identity_key: String, ignored_keys: Array = []) -> bool:
	return source_generated_class_runtime.generated_state_matches_generated_subset_or_nan_ignoring_source_owner(result, canonical, nan_key, identity_key, ignored_keys)

func generated_unit_payload_dump_overlap_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	return source_unit_payload_dump_state.generated_overlap_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)

func source_unit_payload_dump_no_client_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	return source_unit_payload_dump_state.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)

func generated_unit_payload_dump_no_client_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_no_client_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)

func source_unit_payload_dump_spawn_side_effects_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_dump_state.spawn_side_effects_runtime_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id)

func generated_unit_payload_dump_spawn_side_effects_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_dump_state.generated_spawn_side_effects_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id)

func source_unit_payload_draw_shadow_type_null_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.draw_shadow_type_null_state(unit_type_null, alpha, unit_id)

func generated_unit_payload_draw_shadow_type_null_bridge_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.generated_shadow_type_null_bridge_state(unit_type_null, alpha, unit_id)

func source_unit_payload_draw_type_null_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_draw_state.draw_type_null_state(unit_type_null)

func generated_unit_payload_draw_type_null_bridge_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_draw_state.generated_type_null_bridge_state(unit_type_null)

func source_unit_payload_draw_elevation_setup_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.draw_elevation_setup_state(unit_type_null, unit_elevation, unit_id)

func generated_unit_payload_draw_elevation_setup_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.generated_elevation_setup_bridge_state(unit_type_null, unit_elevation, unit_id)

func source_unit_payload_draw_overlay_warning_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	return source_unit_payload_draw_state.draw_overlay_warning_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)

func generated_unit_payload_draw_overlay_warning_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	return source_unit_payload_draw_state.generated_overlay_warning_bridge_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)

func source_unit_payload_icon_state(unit_type_full_icon: Variant) -> Dictionary:
	return source_unit_payload_draw_state.icon_state(unit_type_full_icon)

func generated_unit_payload_icon_bridge_state(unit_type_full_icon: Variant) -> Dictionary:
	return source_unit_payload_draw_state.generated_icon_bridge_state(unit_type_full_icon)

func source_build_payload_place_default_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.place_default_state(tile, build_block, build_team)

func generated_build_payload_place_default_bridge_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_place_default_bridge_state(tile, build_block, build_team)

func source_build_payload_place_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	return source_build_payload_lifecycle_state.place_state(tile, build_block, build_team, rotation_value)

func generated_build_payload_place_bridge_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_place_bridge_state(tile, build_block, build_team, rotation_value)

func source_build_payload_update_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.update_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)

func generated_build_payload_update_bridge_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_update_bridge_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)

func source_build_payload_destroyed_state() -> Dictionary:
	return source_build_payload_lifecycle_state.destroyed_state()

func generated_build_payload_destroyed_bridge_state() -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_destroyed_bridge_state()

func source_build_payload_content_equals_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	return source_build_payload_state.content_equals_state(other_is_build_payload, other_block, build_block)

func generated_build_payload_content_equals_bridge_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_content_equals_bridge_state(other_is_build_payload, other_block, build_block)

func source_build_payload_content_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.content_state(build_block)

func generated_build_payload_content_bridge_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_content_bridge_state(build_block)

func source_build_payload_build_time_state(build_time: float) -> Dictionary:
	return source_build_payload_state.build_time_state(build_time)

func generated_build_payload_build_time_bridge_state(build_time: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_build_time_bridge_state(build_time)

func source_build_payload_requirements_state(requirements: Variant) -> Dictionary:
	return source_build_payload_state.requirements_state(requirements)

func generated_build_payload_requirements_bridge_state(requirements: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_requirements_bridge_state(requirements)

func source_build_payload_x_state(build_x: float) -> Dictionary:
	return source_build_payload_state.x_state(build_x)

func generated_build_payload_x_bridge_state(build_x: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_x_bridge_state(build_x)

func source_build_payload_y_state(build_y: float) -> Dictionary:
	return source_build_payload_state.y_state(build_y)

func generated_build_payload_y_bridge_state(build_y: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_y_bridge_state(build_y)

func source_build_payload_size_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	return source_build_payload_state.size_state(build_block_size, source_tilesize)

func generated_build_payload_size_bridge_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_size_bridge_state(build_block_size, source_tilesize)

func generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size)

func source_build_payload_remove_state() -> Dictionary:
	return source_build_payload_lifecycle_state.remove_state()

func generated_build_payload_remove_bridge_state() -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_remove_bridge_state()

func source_build_payload_write_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	return source_build_payload_state.write_state(payload_block, build_block_id, build_version)

func generated_build_payload_write_bridge_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	return source_build_payload_state.generated_build_payload_write_bridge_state(payload_block, build_block_id, build_version)

func source_build_payload_set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_build_payload_state.set_state(x, y, rotation_value)

func generated_build_payload_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_set_bridge_state(x, y, rotation_value)

func source_build_payload_draw_shadow_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	return source_build_payload_draw_state_script.draw_shadow_state(build_x, build_y, build_block_size, source_tilesize, alpha)

func generated_build_payload_draw_shadow_bridge_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	return source_build_payload_draw_state_script.generated_build_payload_draw_shadow_bridge_state(build_x, build_y, build_block_size, source_tilesize, alpha)

func source_build_payload_draw_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	return source_build_payload_draw_state_script.draw_state(prev_z, layer_flying_unit_low, transform_z)

func generated_build_payload_draw_bridge_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	return source_build_payload_draw_state_script.generated_build_payload_draw_bridge_state(prev_z, layer_flying_unit_low, transform_z)

func source_build_payload_icon_state(full_icon: Variant) -> Dictionary:
	return source_build_payload_draw_state_script.icon_state(full_icon)

func generated_build_payload_icon_bridge_state(full_icon: Variant) -> Dictionary:
	return source_build_payload_draw_state_script.generated_build_payload_icon_bridge_state(full_icon)

func source_block_producer_icons_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	return source_block_producer_state.icons_state(region, out_region, top_region)

func generated_block_producer_icons_bridge_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	return source_block_producer_state.generated_block_producer_icons_bridge_state(region, out_region, top_region)

func source_block_producer_draw_plan_region_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	return source_block_producer_state.draw_plan_region_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)

func generated_block_producer_draw_plan_region_bridge_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	return source_block_producer_state.generated_block_producer_draw_plan_region_bridge_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)

func source_block_producer_set_bars_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_state.set_bars_state(recipe_null, entity_progress, recipe_build_time)

func generated_block_producer_set_bars_bridge_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_state.generated_block_producer_set_bars_bridge_state(recipe_null, entity_progress, recipe_build_time)

func source_block_producer_build_accept_item_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	return source_block_producer_state.build_accept_item_state(source_building, item, item_count, maximum_accepted)

func generated_block_producer_build_accept_item_bridge_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_accept_item_bridge_state(source_building, item, item_count, maximum_accepted)

func source_block_producer_build_get_maximum_accepted_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	return source_block_producer_state.build_get_maximum_accepted_state(item, recipe_null, requirements)

func generated_block_producer_build_get_maximum_accepted_bridge_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_get_maximum_accepted_bridge_state(item, recipe_null, requirements)

func source_block_producer_build_accept_payload_state(source_building: Variant, payload: Variant) -> Dictionary:
	return source_block_producer_state.build_accept_payload_state(source_building, payload)

func generated_block_producer_build_accept_payload_bridge_state(source_building: Variant, payload: Variant) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_accept_payload_bridge_state(source_building, payload)

func source_block_producer_build_should_consume_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	return source_block_producer_state.build_should_consume_state(super_should_consume, recipe_null)

func generated_block_producer_build_should_consume_bridge_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	return source_block_producer_state.generated_block_producer_build_should_consume_bridge_state(super_should_consume, recipe_null)

func source_block_producer_build_update_tile_produce_gate_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	return source_block_producer_build_update_state.produce_gate_state(recipe_null, efficiency, payload_null)

func generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null, efficiency, payload_null)

func source_block_producer_build_update_tile_progress_accumulation_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	return source_block_producer_build_update_state.progress_accumulation_state(produce, progress_before, build_speed, edelta)

func generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce, progress_before, build_speed, edelta)

func source_block_producer_build_update_tile_completion_guard_state(progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_build_update_state.completion_guard_state(progress, recipe_build_time)

func generated_block_producer_build_update_tile_completion_guard_bridge_state(progress: float, recipe_build_time: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_completion_guard_bridge_state(progress, recipe_build_time)

func source_block_producer_build_update_tile_payload_creation_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	return source_block_producer_build_update_state.payload_creation_state(completion_guard, recipe, team, x, y, payload_size, tilesize)

func generated_block_producer_build_update_tile_payload_creation_bridge_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_payload_creation_bridge_state(completion_guard, recipe, team, x, y, payload_size, tilesize)

func source_block_producer_build_update_tile_pay_vector_progress_reset_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	return source_block_producer_build_update_state.pay_vector_progress_reset_state(completion_guard, pay_vector_x, pay_vector_y, progress_before)

func generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(completion_guard, pay_vector_x, pay_vector_y, progress_before)

func source_block_producer_build_update_tile_heat_time_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	return source_block_producer_build_update_state.heat_time_state(produce, heat_before, time_before, time_delta)

func generated_block_producer_build_update_tile_heat_time_bridge_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	return source_block_producer_build_update_state.generated_block_producer_build_update_tile_heat_time_bridge_state(produce, heat_before, time_before, time_delta)

func source_block_producer_build_update_tile_move_out_payload_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	return source_block_producer_move_out_payload_state.move_out_payload_state(payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)

func generated_block_producer_build_update_tile_move_out_payload_bridge_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	return source_block_producer_move_out_payload_state.generated_block_producer_build_update_tile_move_out_payload_bridge_state(payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)

func source_block_init_item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_init_item_liquid_filters_state_script.item_liquid_filters_state(content_items_size, content_liquids_size)

func generated_block_init_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return source_block_init_item_liquid_filters_state_script.generated_block_init_item_liquid_filters_bridge_state(content_items_size, content_liquids_size)

func source_block_init_consumer_apply_loop_state(consumers: Array) -> Dictionary:
	return source_block_init_consumer_state.apply_loop_state(consumers)

func generated_block_init_consumer_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	return source_block_init_consumer_state.generated_consumer_apply_loop_bridge_state(consumers)

func source_block_init_set_bars_call_state() -> Dictionary:
	return source_block_init_set_bars_call_state_script.set_bars_call_state()

func generated_block_init_set_bars_call_bridge_state() -> Dictionary:
	return source_block_init_set_bars_call_state_script.generated_block_init_set_bars_call_bridge_state()

func source_block_init_stats_categories_state(stats_use_categories_before: bool) -> Dictionary:
	return source_block_init_stats_categories_state_script.stats_categories_state(stats_use_categories_before)

func generated_block_init_stats_categories_bridge_state(stats_use_categories_before: bool) -> Dictionary:
	return source_block_init_stats_categories_state_script.generated_block_init_stats_categories_bridge_state(stats_use_categories_before)

func source_block_init_logic_configurable_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	return source_block_init_logic_configurable_state_script.logic_configurable_state(logic_configurable_before, config_key_assignable_to_unlockable_content)

func generated_block_init_logic_configurable_bridge_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	return source_block_init_logic_configurable_state_script.generated_block_init_logic_configurable_bridge_state(logic_configurable_before, config_key_assignable_to_unlockable_content)

func source_block_init_buffered_power_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	return source_block_init_buffered_power_state_script.buffered_power_state(outputs_power, has_cons_power, cons_power_buffered_before)

func generated_block_init_buffered_power_bridge_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	return source_block_init_buffered_power_state_script.generated_block_init_buffered_power_bridge_state(outputs_power, has_cons_power, cons_power_buffered_before)

func source_block_init_sandbox_visibility_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	return source_block_init_sandbox_visibility_state_script.sandbox_visibility_state(build_visibility, hide_details_before)

func generated_block_init_sandbox_visibility_bridge_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	return source_block_init_sandbox_visibility_state_script.generated_block_init_sandbox_visibility_bridge_state(build_visibility, hide_details_before)

func source_turret_init_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	return source_turret_init_state_script.turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)

func generated_turret_init_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)

func generated_turret_init_source_tilesize_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_source_tilesize_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size)

func generated_turret_init_size_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_size_default_bridge_state(shoot_y, shoot_y_is_negative_infinity)

func generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground)

func generated_turret_init_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check)

func generated_turret_init_tracking_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float) -> Dictionary:
	return source_turret_init_state_script.generated_turret_init_tracking_range_default_bridge_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value)

func source_base_turret_init_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	return source_turret_init_state_script.base_turret_init_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)

func generated_base_turret_init_bridge_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	return source_turret_init_state_script.generated_base_turret_init_bridge_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)

func source_base_turret_reinitialize_consumers_state() -> Dictionary:
	return source_turret_init_state_script.base_turret_reinitialize_consumers_state()

func generated_base_turret_reinitialize_consumers_bridge_state() -> Dictionary:
	return source_turret_init_state_script.generated_base_turret_reinitialize_consumers_bridge_state()

func source_base_turret_check_init_coolant_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	return source_turret_init_state_script.base_turret_check_init_coolant_state(coolant_present, has_consumer)

func generated_base_turret_check_init_coolant_bridge_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	return source_turret_init_state_script.generated_base_turret_check_init_coolant_bridge_state(coolant_present, has_consumer)

func source_base_turret_draw_place_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	return source_base_turret_draw_state.draw_place_state(tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog)

func generated_base_turret_draw_place_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	return source_base_turret_draw_state.generated_base_turret_draw_place_bridge_state(tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog)

func generated_base_turret_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool) -> Dictionary:
	return source_base_turret_draw_state.generated_base_turret_draw_place_source_tilesize_default_bridge_state(tile_x, tile_y, rotation_value, valid)

func source_turret_load_state() -> Dictionary:
	return source_turret_presentation_state.load_state()

func generated_turret_load_bridge_state() -> Dictionary:
	return source_turret_presentation_state.generated_turret_load_bridge_state()

func source_turret_draw_plan_region_state(plan: Variant, list: Variant) -> Dictionary:
	return source_turret_presentation_state.draw_plan_region_state(plan, list)

func generated_turret_draw_plan_region_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	return source_turret_presentation_state.generated_turret_draw_plan_region_bridge_state(plan, list)

func source_turret_icons_state() -> Dictionary:
	return source_turret_presentation_state.icons_state()

func generated_turret_icons_bridge_state() -> Dictionary:
	return source_turret_presentation_state.generated_turret_icons_bridge_state()

func source_tractor_beam_turret_icons_state(base_region: Variant, region: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.icons_state(base_region, region)

func generated_tractor_beam_turret_icons_bridge_state(base_region: Variant, region: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_icons_bridge_state(base_region, region)

func source_tractor_beam_turret_init_state(range_value: float, source_tilesize: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.init_state(range_value, source_tilesize)

func generated_tractor_beam_turret_init_bridge_state(range_value: float, source_tilesize: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_init_bridge_state(range_value, source_tilesize)

func source_tractor_beam_turret_build_should_consume_state(super_should_consume: bool, target: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_should_consume_state(super_should_consume, target)

func generated_tractor_beam_turret_build_should_consume_bridge_state(super_should_consume: bool, target: Variant) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_should_consume_bridge_state(super_should_consume, target)

func source_tractor_beam_turret_build_estimate_dps_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_estimate_dps_state(any_state, damage, efficiency, coolant_multiplier)

func generated_tractor_beam_turret_build_estimate_dps_bridge_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_estimate_dps_bridge_state(any_state, damage, efficiency, coolant_multiplier)

func source_tractor_beam_turret_build_write_state(rotation_value: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_write_state(rotation_value)

func generated_tractor_beam_turret_build_write_bridge_state(rotation_value: float) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_write_bridge_state(rotation_value)

func source_tractor_beam_turret_build_read_state(read_f_value: float, revision_value: int) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.build_read_state(read_f_value, revision_value)

func generated_tractor_beam_turret_build_read_bridge_state(read_f_value: float, revision_value: int) -> Dictionary:
	return source_tractor_beam_turret_lifecycle_state.generated_build_read_bridge_state(read_f_value, revision_value)

func source_tractor_beam_turret_build_update_tile_activation_state(activation_timer: float, time_delta: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.activation_state(activation_timer, time_delta)

func generated_tractor_beam_turret_build_update_tile_activation_bridge_state(activation_timer: float, time_delta: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_activation_bridge_state(activation_timer, time_delta)

func source_tractor_beam_turret_build_update_tile_eff_state(activation_returned_early: bool, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.eff_state(activation_returned_early, efficiency, coolant_multiplier, delta_value)

func generated_tractor_beam_turret_build_update_tile_eff_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_eff_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value)

func source_tractor_beam_turret_build_update_tile_retarget_state(activation_returned_early: bool, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.retarget_state(activation_returned_early, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)

func generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_retarget_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)

func source_tractor_beam_turret_build_update_tile_coolant_guard_state(activation_returned_early: bool, target_after: Variant, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_guard_state(activation_returned_early, target_after, coolant_present, coolant_amount, current_liquid)

func generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid)

func source_tractor_beam_turret_build_update_tile_coolant_used_state(coolant_guard: bool, liquid_amount: float, max_used: float, time_delta: float, coolant_multiplier: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_used_state(coolant_guard, liquid_amount, max_used, time_delta, coolant_multiplier, liquid_heat_capacity)

func generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_used_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)

func source_tractor_beam_turret_build_update_tile_coolant_remove_state(coolant_guard: bool, liquid: Variant, used: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_remove_state(coolant_guard, liquid, used)

func generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_remove_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)

func source_tractor_beam_turret_build_update_tile_coolant_effect_state(coolant_guard: bool, used: float, chance_result: bool, x: float, y: float, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_effect_state(coolant_guard, used, chance_result, x, y, size, source_tilesize, range_x, range_y)

func generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_effect_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)

func source_tractor_beam_turret_build_update_tile_coolant_multiplier_state(coolant_guard: bool, used: float, liquid_heat_capacity: float, coolant_multiplier: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.coolant_multiplier_state(coolant_guard, used, liquid_heat_capacity, coolant_multiplier)

func generated_tractor_beam_turret_build_update_tile_coolant_multiplier_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_multiplier_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)

func source_tractor_beam_turret_build_update_tile_any_reset_state(activation_returned_early: bool, any_before: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.any_reset_state(activation_returned_early, any_before)

func generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_flow_state.generated_any_reset_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before)

func source_tractor_beam_turret_build_update_tile_look_target_guard_state(activation_returned_early: bool, target_after: Variant, range_value: float, target_hit_size: float, target_within_result: bool, target_team: Variant, team: Variant, target_air: bool, target_ground: bool, target_check_result: bool, efficiency: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_look_target_guard_state_script.look_target_guard_state(activation_returned_early, target_after, range_value, target_hit_size, target_within_result, target_team, team, target_air, target_ground, target_check_result, efficiency)

func generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_look_target_guard_state_script.generated_look_target_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size)

func source_tractor_beam_turret_build_update_tile_sound_loop_state(look_target_guard: bool, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_sound_loop_state_script.sound_loop_state(look_target_guard, headless, shoot_sound, shoot_sound_volume)

func generated_tractor_beam_turret_build_update_tile_sound_loop_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_sound_loop_state_script.generated_sound_loop_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume)

func source_tractor_beam_turret_build_update_tile_angle_to_target_state(look_target_guard: bool, x: float, y: float, target_after: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.game_angle_to_target_state(self, look_target_guard, x, y, target_after)

func generated_tractor_beam_turret_build_update_tile_angle_to_target_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_angle_to_target_state_script.game_generated_angle_to_target_bridge_state(self, activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume)

func source_tractor_beam_turret_build_update_tile_rotation_move_state(angle_to_target_evaluated: bool, rotation_before: float, dest: float, rotate_speed: float, edelta: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_rotation_move_state_script.game_rotation_move_state(self, angle_to_target_evaluated, rotation_before, dest, rotate_speed, edelta)

func generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_rotation_move_state_script.game_generated_rotation_move_bridge_state(self, activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed)

func source_tractor_beam_turret_build_update_tile_last_target_position_state(rotation_move_evaluated: bool, target_after: Variant, last_x_before: float, last_y_before: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_last_target_position_state_script.last_target_position_state(rotation_move_evaluated, target_after, last_x_before, last_y_before)

func generated_tractor_beam_turret_build_update_tile_last_target_position_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_last_target_position_state_script.generated_last_target_position_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before)

func source_tractor_beam_turret_build_update_tile_active_strength_state(last_target_position_evaluated: bool, strength_before: float, time_delta: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_active_strength_state_script.game_active_strength_state(self, last_target_position_evaluated, strength_before, time_delta)

func generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_active_strength_state_script.game_generated_active_strength_bridge_state(self, activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before)

func source_tractor_beam_turret_build_update_tile_inactive_strength_state(activation_returned_early: bool, look_target_guard: bool, strength_before: float, time_delta: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.game_inactive_strength_state(self, activation_returned_early, look_target_guard, strength_before, time_delta)

func generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_inactive_strength_state_script.game_generated_inactive_strength_bridge_state(self, activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before)

func source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state(strength_lerp_evaluated: bool, rotation_after: float, dest: float, shoot_cone: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.game_shoot_when_possible_guard_state(self, strength_lerp_evaluated, rotation_after, dest, shoot_cone)

func generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state_script.game_generated_shoot_when_possible_guard_bridge_state(self, activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone)

func source_tractor_beam_turret_build_update_tile_damage_pierce_state(shoot_within_guard: bool, target_after: Variant, damage: float, eff: float, time_scale: float, rules_block_damage: float, team: Variant) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_damage_pierce_state_script.damage_pierce_state(shoot_within_guard, target_after, damage, eff, time_scale, rules_block_damage, team)

func generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_damage_pierce_state_script.generated_damage_pierce_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage)

func source_tractor_beam_turret_build_update_tile_status_apply_state(shoot_within_guard: bool, target_after: Variant, status: Variant, status_duration: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_status_apply_state_script.status_apply_state(shoot_within_guard, target_after, status, status_duration)

func generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_status_apply_state_script.generated_status_apply_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration)

func source_tractor_beam_turret_build_update_tile_any_true_state(shoot_within_guard: bool, any_before_shoot: bool) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_any_true_state_script.any_true_state(shoot_within_guard, any_before_shoot)

func generated_tractor_beam_turret_build_update_tile_any_true_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_any_true_state_script.generated_any_true_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration)

func source_tractor_beam_turret_build_update_tile_impulse_net_state(shoot_within_guard: bool, target_after: Variant, x: float, y: float, range_value: float, edelta: float, force_value: float, scaled_force: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_impulse_net_state_script.impulse_net_state(shoot_within_guard, target_after, x, y, range_value, edelta, force_value, scaled_force)

func generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float, force_value: float, scaled_force: float) -> Dictionary:
	return source_tractor_beam_turret_build_update_tile_impulse_net_state_script.generated_impulse_net_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration, force_value, scaled_force)

func source_tractor_beam_turret_build_draw_state(base_region: Variant, region: Variant, x: float, y: float, rotation_value: float, size: float, any_state: bool, is_payload: bool, last_x: float, last_y: float, laser_color: Variant, mathf_absin_4_0_6: float, laser: Variant, laser_start: Variant, laser_end: Variant, shoot_length: float, strength: float, efficiency: float, laser_width: float) -> Dictionary:
	return source_tractor_beam_turret_build_draw_state_script.draw_state(base_region, region, x, y, rotation_value, size, any_state, is_payload, last_x, last_y, laser_color, mathf_absin_4_0_6, laser, laser_start, laser_end, shoot_length, strength, efficiency, laser_width)

func generated_tractor_beam_turret_build_draw_bridge_state(base_region: Variant, region: Variant, x: float, y: float, rotation_value: float, size: float, any_state: bool, is_payload: bool, last_x: float, last_y: float, laser_color: Variant, mathf_absin_4_0_6: float, laser: Variant, laser_start: Variant, laser_end: Variant, shoot_length: float, strength: float, efficiency: float, laser_width: float) -> Dictionary:
	return source_tractor_beam_turret_build_draw_state_script.generated_draw_bridge_state(base_region, region, x, y, rotation_value, size, any_state, is_payload, last_x, last_y, laser_color, mathf_absin_4_0_6, laser, laser_start, laser_end, shoot_length, strength, efficiency, laser_width)

func source_turret_get_regions_to_outline_state(out: Variant) -> Dictionary:
	return source_turret_presentation_state.get_regions_to_outline_state(out)

func generated_turret_get_regions_to_outline_bridge_state(out: Variant) -> Dictionary:
	return source_turret_presentation_state.generated_get_regions_to_outline_bridge_state(out)

func source_turret_limit_range_state(bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	return source_turret_range_state.game_limit_range_state(self, bullet, margin, turret_range)

func generated_turret_limit_range_bridge_state(bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	return source_turret_range_state.game_generated_limit_range_bridge_state(self, bullet, margin, turret_range)

@warning_ignore("shadowed_variable_base_class")
func source_turret_draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	return source_turret_placement_state.draw_place_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)

@warning_ignore("shadowed_variable_base_class")
func generated_turret_draw_place_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	return source_turret_placement_state.generated_draw_place_bridge_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)

@warning_ignore("shadowed_variable_base_class")
func generated_turret_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool) -> Dictionary:
	return source_turret_placement_state.generated_draw_place_source_tilesize_default_bridge_state(tile_x, tile_y, rotation, valid, draw_min_range, source_world_defaults.TILESIZE)

func source_turret_rotated_output_state(tile_x: int, tile_y: int) -> Dictionary:
	return source_turret_placement_state.rotated_output_state(tile_x, tile_y)

func generated_turret_rotated_output_bridge_state(tile_x: int, tile_y: int) -> Dictionary:
	return source_turret_placement_state.generated_rotated_output_bridge_state(tile_x, tile_y)

@warning_ignore("shadowed_variable_base_class")
@warning_ignore("shadowed_variable")
func source_turret_place_ended_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	return source_turret_placement_state.place_ended_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)

@warning_ignore("shadowed_variable_base_class")
@warning_ignore("shadowed_variable")
func generated_turret_place_ended_bridge_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	return source_turret_placement_state.generated_place_ended_bridge_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)

func source_power_turret_limit_range_state(shoot_type: Variant, margin: float) -> Dictionary:
	return source_turret_range_state.power_turret_limit_range_state(shoot_type, margin)

func generated_power_turret_limit_range_bridge_state(shoot_type: Variant, margin: float) -> Dictionary:
	return source_turret_range_state.generated_power_turret_limit_range_bridge_state(shoot_type, margin)

func source_power_turret_build_get_ammo_fraction_state(power_null: bool, power_status: float) -> Dictionary:
	return source_power_turret_build_state.get_ammo_fraction_state(power_null, power_status)

func generated_power_turret_build_get_ammo_fraction_bridge_state(power_null: bool, power_status: float) -> Dictionary:
	return source_power_turret_build_state.generated_get_ammo_fraction_bridge_state(power_null, power_status)

func source_power_turret_build_sense_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	return source_power_turret_build_state.sense_state(sensor, power_null, power_status, super_sense_value)

func generated_power_turret_build_sense_bridge_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	return source_power_turret_build_state.generated_sense_bridge_state(sensor, power_null, power_status, super_sense_value)

func source_power_turret_build_use_ammo_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.use_ammo_state(shoot_type)

func generated_power_turret_build_use_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.generated_use_ammo_bridge_state(shoot_type)

func source_power_turret_build_has_ammo_state() -> Dictionary:
	return source_power_turret_build_state.has_ammo_state()

func generated_power_turret_build_has_ammo_bridge_state() -> Dictionary:
	return source_power_turret_build_state.generated_has_ammo_bridge_state()

func source_power_turret_build_peek_ammo_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.peek_ammo_state(shoot_type)

func generated_power_turret_build_peek_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_power_turret_build_state.generated_peek_ammo_bridge_state(shoot_type)

func source_item_turret_limit_range_default_state() -> Dictionary:
	return source_turret_range_state.item_turret_limit_range_default_state()

func generated_item_turret_limit_range_default_bridge_state() -> Dictionary:
	return source_turret_range_state.generated_item_turret_limit_range_default_bridge_state()

func source_item_turret_limit_range_entries_state(margin: float, ammo_entries: Array) -> Dictionary:
	return source_turret_range_state.item_turret_limit_range_entries_state(margin, ammo_entries)

func generated_item_turret_limit_range_entries_bridge_state(margin: float, ammo_entries: Array) -> Dictionary:
	return source_turret_range_state.generated_item_turret_limit_range_entries_bridge_state(margin, ammo_entries)

func source_item_turret_init_ground_overlap_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	return source_item_turret_init_state.ground_overlap_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)

func generated_item_turret_init_ground_overlap_bridge_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	return source_item_turret_init_state.generated_item_turret_init_ground_overlap_bridge_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)

func generated_item_turret_init_ground_overlap_default_bridge_state() -> Dictionary:
	return source_item_turret_init_state.generated_item_turret_init_ground_overlap_default_bridge_state()

func source_item_turret_build_on_proximity_added_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return source_item_turret_build_state.on_proximity_added_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func generated_item_turret_build_on_proximity_added_bridge_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_on_proximity_added_bridge_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func source_item_turret_build_sense_object_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_item_turret_build_state.sense_object_state(sensor, ammo_size, peek_item, super_sense_object_value)

func generated_item_turret_build_sense_object_bridge_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_sense_object_bridge_state(sensor, ammo_size, peek_item, super_sense_object_value)

func source_item_turret_build_get_ammo_content_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return source_item_turret_build_state.get_ammo_content_state(ammo_size, peek_item)

func generated_item_turret_build_get_ammo_content_bridge_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_content_bridge_state(ammo_size, peek_item)

func source_item_turret_build_get_ammo_fraction_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_item_turret_build_state.get_ammo_fraction_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo: float) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo)

func source_item_turret_build_accept_stack_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.accept_stack_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_bridge_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_stack_bridge_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_default_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_stack_default_bridge_state(item, amount)

func source_item_turret_build_handle_stack_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.handle_stack_state(item, amount)

func generated_item_turret_build_handle_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_handle_stack_bridge_state(item, amount)

func source_item_turret_build_remove_stack_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.remove_stack_state(item, amount)

func generated_item_turret_build_remove_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_remove_stack_bridge_state(item, amount)

func source_item_turret_build_handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

func generated_item_turret_build_handle_item_bridge_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_handle_item_bridge_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

func source_item_turret_build_accept_item_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_accept_item_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_item_bridge_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_item_bridge_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_item_default_bridge_state(item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_item_default_bridge_state(item)

func source_item_turret_build_version_state() -> Dictionary:
	return source_item_turret_build_state.version_state()

func generated_item_turret_build_version_bridge_state() -> Dictionary:
	return source_item_turret_build_state.generated_version_bridge_state()

func source_item_turret_build_write_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.write_state(ammo_entries)

func generated_item_turret_build_write_bridge_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_write_bridge_state(ammo_entries)

func source_item_turret_build_read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_state.read_state(revision, max_ammo, read_entries)

func generated_item_turret_build_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_read_bridge_state(revision, max_ammo, read_entries)

func source_item_entry_constructor_state(item: Variant, amount: int) -> Dictionary:
	return source_item_entry_state.constructor_state(item, amount)

func generated_item_entry_constructor_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_entry_state.generated_constructor_bridge_state(item, amount)

func source_item_entry_type_state(item: Variant, ammo_type: Variant) -> Dictionary:
	return source_item_entry_state.type_state(item, ammo_type)

func generated_item_entry_type_bridge_state(item: Variant, ammo_type: Variant) -> Dictionary:
	return source_item_entry_state.generated_type_bridge_state(item, ammo_type)

func source_item_entry_to_string_state(item_string: String, amount: int) -> Dictionary:
	return source_item_entry_state.to_string_state(item_string, amount)

func generated_item_entry_to_string_bridge_state(item_string: String, amount: int) -> Dictionary:
	return source_item_entry_state.generated_to_string_bridge_state(item_string, amount)

func source_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.liquid_turret_ammo_state(objects)

func generated_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.generated_liquid_turret_ammo_bridge_state(objects)

func source_item_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_ammo_state(objects)

func generated_item_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.generated_item_turret_ammo_bridge_state(objects)

func source_continuous_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.continuous_liquid_turret_ammo_state(objects)

func generated_continuous_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.generated_continuous_liquid_turret_ammo_bridge_state(objects)

func source_liquid_turret_init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	return source_liquid_turret_init_state_script.init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin)

func generated_liquid_turret_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	return source_liquid_turret_init_state_script.generated_init_bridge_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin)

func generated_liquid_turret_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	return source_liquid_turret_init_state_script.generated_init_range_margin_default_bridge_state(ammo_entries, target_ground, place_overlap_range)

func source_continuous_liquid_turret_init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	return source_continuous_liquid_turret_init_state_script.init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier)

func generated_continuous_liquid_turret_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	return source_continuous_liquid_turret_init_state_script.generated_init_bridge_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier)

func generated_continuous_liquid_turret_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	return source_continuous_liquid_turret_init_state_script.generated_init_range_margin_default_bridge_state(ammo_entries, target_ground, place_overlap_range)

func source_liquid_turret_build_should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return source_liquid_turret_build_state.should_active_sound_state(was_shooting, enabled)

func generated_liquid_turret_build_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return source_liquid_turret_build_state.generated_should_active_sound_bridge_state(was_shooting, enabled)

func source_liquid_turret_build_get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return source_liquid_turret_build_state.get_ammo_content_state(liquids_null, current_amount, current_liquid)

func generated_liquid_turret_build_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_get_ammo_content_bridge_state(liquids_null, current_amount, current_liquid)

func source_liquid_turret_build_get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return source_liquid_turret_build_state.get_ammo_fraction_state(current_amount, liquid_capacity)

func generated_liquid_turret_build_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_get_ammo_fraction_bridge_state(current_amount, liquid_capacity)

func source_liquid_turret_build_sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_liquid_turret_build_state.sense_object_state(sensor, current_liquid, super_sense_object_value)

func generated_liquid_turret_build_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_sense_object_bridge_state(sensor, current_liquid, super_sense_object_value)

func source_liquid_turret_build_find_target_extinguish_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	return source_liquid_turret_build_state.find_target_extinguish_state(extinguish, current_liquid_can_extinguish, fire_result)

func generated_liquid_turret_build_find_target_extinguish_bridge_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_find_target_extinguish_bridge_state(extinguish, current_liquid_can_extinguish, fire_result)

func source_liquid_turret_build_use_ammo_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.use_ammo_state(cheating, current_liquid, ammo_type, ammo_multiplier)

func generated_liquid_turret_build_use_ammo_bridge_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_use_ammo_bridge_state(cheating, current_liquid, ammo_type, ammo_multiplier)

func source_liquid_turret_build_peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return source_liquid_turret_build_state.peek_ammo_state(current_liquid, ammo_type)

func generated_liquid_turret_build_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_peek_ammo_bridge_state(current_liquid, ammo_type)

func source_liquid_turret_build_has_ammo_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.has_ammo_state(current_liquid, ammo_type, current_amount, ammo_multiplier)

func generated_liquid_turret_build_has_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_has_ammo_bridge_state(current_liquid, ammo_type, current_amount, ammo_multiplier)

func source_liquid_turret_build_accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	return source_liquid_turret_build_state.accept_item_state(source_building, item)

func generated_liquid_turret_build_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_accept_item_bridge_state(source_building, item)

func source_liquid_turret_build_accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)

func generated_liquid_turret_build_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_accept_liquid_bridge_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)

func source_turret_ammo_data(turret, item_id: String) -> Dictionary:
	return source_turret_ammo_state.turret_ammo_data(turret, item_id)

func peek_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	return source_turret_ammo_state.peek_turret_ammo(self, cell, turret)

func handle_turret_item(cell: Vector2i, turret, item_id: String) -> bool:
	return source_turret_ammo_state.handle_turret_item(self, cell, turret, item_id)

func use_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	return source_turret_ammo_state.use_turret_ammo(self, cell, turret)

func bootstrap_selected_turret_ammo() -> int:
	return source_turret_ammo_state.bootstrap_selected_turret_ammo(self)

func load_selected_turret_ammo(item_id: String, amount: int) -> int:
	return source_turret_ammo_state.load_selected_turret_ammo(self, item_id, amount)

func use_selected_turret_ammo_once() -> Dictionary:
	return source_turret_ammo_state.use_selected_turret_ammo_once(self)

func source_turret_recoil_offset(turret, recoil_rotation_degrees: float, cur_recoil: float) -> Vector2:
	return source_turret_combat_state.recoil_offset(recoil_rotation_degrees, cur_recoil, source_turret_combat_state.SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_DEFAULT, source_turret_recoil(turret))

func update_turret_recoil(cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:
	source_turret_combat_state.update_turret_recoil(self, cell, turret, delta, recoil_rotation_degrees)

func apply_turret_recoil_offset(cell: Vector2i, turret, offset: Vector2) -> void:
	source_turret_combat_state.apply_turret_recoil_offset(self, cell, turret, offset)

func use_turret_shoot_x_offset(cell: Vector2i, turret) -> float:
	return source_turret_combat_state.use_turret_shoot_x_offset(self, cell, turret)

func source_turret_bullet_origin(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset := 0.0, y_offset := 0.0, x_spread := 0.0) -> Dictionary:
	return source_turret_combat_state.game_turret_bullet_origin_state(self, origin_x, origin_y, turret_rotation_degrees, turret, shoot_x_offset, y_offset, x_spread)

func source_angle_to_target(origin, target) -> float:
	return source_turret_combat_state.game_angle_to_target(self, origin, target)

func source_bullet_range_change(data: Dictionary) -> float:
	return source_bullet_runtime_state.range_change(data)

func source_bullet_extra_range_margin(data: Dictionary) -> float:
	return source_bullet_runtime_state.extra_range_margin(data)

func source_bullet_inaccuracy(data: Dictionary) -> float:
	return source_bullet_runtime_state.inaccuracy(data)

func source_turret_total_inaccuracy(turret, data: Dictionary) -> float:
	return source_turret_combat_state.total_inaccuracy(source_turret_inaccuracy(turret), source_bullet_inaccuracy(data))

func source_bullet_lifetime_seconds(data: Dictionary) -> float:
	return source_bullet_runtime_state.lifetime_seconds(data)

func source_bullet_world_speed_per_tick(data: Dictionary) -> float:
	return source_bullet_runtime_state.world_speed_per_tick(data)

func source_bullet_world_speed(data: Dictionary) -> float:
	return source_bullet_runtime_state.world_speed(data)

func source_bullet_velocity(data: Dictionary, shoot_angle_degrees: float) -> Vector2:
	return source_bullet_runtime_state.velocity(data, shoot_angle_degrees)

func source_bullet_hit_size(data: Dictionary) -> float:
	return source_bullet_runtime_state.hit_size(data)

func source_bullet_damage(data: Dictionary) -> float:
	return source_bullet_runtime_state.damage(data)

func source_bullet_ammo_multiplier(data: Dictionary) -> float:
	return source_bullet_runtime_state.ammo_multiplier(data)

func source_bullet_reload_multiplier(data: Dictionary) -> float:
	return source_bullet_runtime_state.reload_multiplier(data)

func source_bullet_dimensions(data: Dictionary) -> Dictionary:
	return source_bullet_runtime_state.dimensions(data)

func source_bullet_scale(data: Dictionary, texture_size: Vector2) -> Vector2:
	return source_bullet_runtime_state.scale(data, texture_size)

func find_enemy_target(origin: Vector2, range_pixels: float):
	var target_state := source_turret_combat_state.enemy_target_state(origin, range_pixels, enemy_units)
	return target_state.get("target", null)

func spawn_turret_bullet(origin: Vector2, target, data: Dictionary, shoot_angle_degrees := 0.0) -> void:
	source_bullet_runtime_state.spawn_turret_bullet(self, origin, target, data, shoot_angle_degrees)

func simulate_bullets(delta: float) -> void:
	source_bullet_runtime_state.simulate_bullets(self, delta)

func update_camera(delta: float) -> void:
	source_input_viewport_runtime_state.update_camera(self, delta)

func source_input_runtime_summary_state() -> Dictionary:
	return input_runtime.runtime_summary_with_source_owner(source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_RUNTIME_SUMMARY_STATE)

func get_runtime_summary() -> Dictionary:
	return source_game_runtime_summary_state.summary_state(self)

func update_hud() -> void:
	if hud_label == null:
		return
	hud_label.text = source_hud_runtime_state.game_hud_text(self)
