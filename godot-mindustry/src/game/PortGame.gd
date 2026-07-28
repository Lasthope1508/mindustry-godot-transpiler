extends Node2D
class_name PortGame

const ContentRegistry := preload("res://src/generated/MindustryContentRegistry.gd")
const GeneratedClassRegistry := preload("res://src/generated/GeneratedClassRegistry.gd")
const SourceSsotAccessorRuntimeState := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const SourceMathDefaults := preload("res://src/game/SourceMathDefaults.gd")
const SourceMathState := preload("res://src/game/SourceMathState.gd")
const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")
const MindustryTime := preload("res://src/runtime/Time.gd")
const SourceRulesDefaults := preload("res://src/game/SourceRulesDefaults.gd")
const SourceWorldDefaults := preload("res://src/game/SourceWorldDefaults.gd")
const SourceWorldGrid := preload("res://src/game/SourceWorldGrid.gd")
const SourceWorldTerrainRuntimeState := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const SourceWorldInitialBuildRuntimeState := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const SourceWorldViewport := preload("res://src/game/SourceWorldViewport.gd")
const SourceItemTransportRuntimeState := preload("res://src/game/SourceItemTransportRuntimeState.gd")
const SourceConveyorRuntimeState := preload("res://src/game/SourceConveyorRuntimeState.gd")
const SourceDrillDumpRuntimeState := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const SourceDrillProductionRuntimeState := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const SourceDrillRuntimeState := preload("res://src/game/SourceDrillRuntimeState.gd")
const SourceDrillInventoryRuntimeState := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const SourceCoreInventoryRuntimeState := preload("res://src/game/SourceCoreInventoryRuntimeState.gd")
const SourceWaveSpawnRuntimeState := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const SourceWaveTimingRuntimeState := preload("res://src/game/SourceWaveTimingRuntimeState.gd")
const SourceEnemyUnitRuntimeState := preload("res://src/game/SourceEnemyUnitRuntimeState.gd")
const SourceInputDefaults := preload("res://src/game/SourceInputDefaults.gd")
const SourceInputRuntime := preload("res://src/game/SourceInputRuntime.gd")
const SourceGameConfigRuntimeState := preload("res://src/game/SourceGameConfigRuntimeState.gd")
const SourceTextureRuntimeState := preload("res://src/game/SourceTextureRuntimeState.gd")
const SourceContentRegistryRuntimeState := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const SourceInputViewportRuntimeState := preload("res://src/game/SourceInputViewportRuntimeState.gd")
const SourceGameRuntimeSummaryState := preload("res://src/game/SourceGameRuntimeSummaryState.gd")
const SourceGameOverCoreDestroyedState := preload("res://src/game/SourceGameOverCoreDestroyedState.gd")
const SourceCoreDamageRuntimeState := preload("res://src/game/SourceCoreDamageRuntimeState.gd")
const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceUiDefaults := preload("res://src/game/SourceUiDefaults.gd")
const SourceNodeBindingRuntimeState := preload("res://src/game/SourceNodeBindingRuntimeState.gd")
const SourceHudRuntimeState := preload("res://src/game/SourceHudRuntimeState.gd")
const SourcePlayableScenarioDefaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const SourceBlockDefaults := preload("res://src/game/SourceBlockDefaults.gd")
const SourceLiquidReactionState := preload("res://src/game/SourceLiquidReactionState.gd")
const SourceCoreDefaults := preload("res://src/game/SourceCoreDefaults.gd")
const SourceConsumerDefaults := preload("res://src/game/SourceConsumerDefaults.gd")
const SourceFactoryDefaults := preload("res://src/game/SourceFactoryDefaults.gd")
const SourceFactoryRuntimeState := preload("res://src/game/SourceFactoryRuntimeState.gd")
const SourceFactorySimulationRuntimeState := preload("res://src/game/SourceFactorySimulationRuntimeState.gd")
const SourceFactorySimulationApplyState := preload("res://src/game/SourceFactorySimulationApplyState.gd")
const SourcePowerDefaults := preload("res://src/game/SourcePowerDefaults.gd")
const SourceProjectorDefaults := preload("res://src/game/SourceProjectorDefaults.gd")
const SourceBulletDefaults := preload("res://src/game/SourceBulletDefaults.gd")
const SourceBulletRuntimeState := preload("res://src/game/SourceBulletRuntimeState.gd")
const SourcePlacedPowerGraphState := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const SourcePlacedPowerBatteryRuntimeState := preload("res://src/game/SourcePlacedPowerBatteryRuntimeState.gd")
const SourcePlacedPowerDistributionRuntimeState := preload("res://src/game/SourcePlacedPowerDistributionRuntimeState.gd")
const SourceBulletTypeCreateState := preload("res://src/game/SourceBulletTypeCreateState.gd")
const SourceBulletTypeCreateIncendState := preload("res://src/game/SourceBulletTypeCreateIncendState.gd")
const SourceBulletTypeCreateUnitsState := preload("res://src/game/SourceBulletTypeCreateUnitsState.gd")
const SourceBulletTypeCreateSplashDamageState := preload("res://src/game/SourceBulletTypeCreateSplashDamageState.gd")
const SourceBulletTypeCreateFragsState := preload("res://src/game/SourceBulletTypeCreateFragsState.gd")
const SourceBulletTypeCreatePuddlesState := preload("res://src/game/SourceBulletTypeCreatePuddlesState.gd")
const SourceBulletTypeHitState := preload("res://src/game/SourceBulletTypeHitState.gd")
const SourceBulletTypeDrawState := preload("res://src/game/SourceBulletTypeDrawState.gd")
const SourceBulletTypeDamageState := preload("res://src/game/SourceBulletTypeDamageState.gd")
const SourceBulletTypeLifecycleState := preload("res://src/game/SourceBulletTypeLifecycleState.gd")
const SourceBulletTypeHitCoreState := preload("res://src/game/SourceBulletTypeHitCoreState.gd")
const SourceBulletTypeHitTileState := preload("res://src/game/SourceBulletTypeHitTileState.gd")
const SourceBulletTypeInitRangeState := preload("res://src/game/SourceBulletTypeInitRangeState.gd")
const SourceBulletTypeInitState := preload("res://src/game/SourceBulletTypeInitState.gd")
const SourceBulletTypeUpdateState := preload("res://src/game/SourceBulletTypeUpdateState.gd")
const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")
const SourceTurretRuntimeState := preload("res://src/game/SourceTurretRuntimeState.gd")
const SourceTurretPropertyState := preload("res://src/game/SourceTurretPropertyState.gd")
const SourceTurretSimulationState := preload("res://src/game/SourceTurretSimulationState.gd")
const SourceTurretCombatState := preload("res://src/game/SourceTurretCombatState.gd")
const SourceTurretInitState := preload("res://src/game/SourceTurretInitState.gd")
const SourceTurretPresentationState := preload("res://src/game/SourceTurretPresentationState.gd")
const SourceTurretPlacementState := preload("res://src/game/SourceTurretPlacementState.gd")
const SourceTurretRangeState := preload("res://src/game/SourceTurretRangeState.gd")
const SourceTurretStatsBarsState := preload("res://src/game/SourceTurretStatsBarsState.gd")
const SourceLiquidTurretInitState := preload("res://src/game/SourceLiquidTurretInitState.gd")
const SourceLiquidTurretBuildState := preload("res://src/game/SourceLiquidTurretBuildState.gd")
const SourceContinuousLiquidTurretInitState := preload("res://src/game/SourceContinuousLiquidTurretInitState.gd")
const SourceContinuousLiquidTurretBuildState := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")
const SourcePowerTurretBuildState := preload("res://src/game/SourcePowerTurretBuildState.gd")
const SourceItemTurretBuildState := preload("res://src/game/SourceItemTurretBuildState.gd")
const SourceItemTurretInitState := preload("res://src/game/SourceItemTurretInitState.gd")
const SourceItemEntryState := preload("res://src/game/SourceItemEntryState.gd")
const SourceTurretAmmoState := preload("res://src/game/SourceTurretAmmoState.gd")
const SourceAbilityState := preload("res://src/game/SourceAbilityState.gd")
const SourceBaseTurretDrawState := preload("res://src/game/SourceBaseTurretDrawState.gd")
const SourceTractorBeamTurretLifecycleState := preload("res://src/game/SourceTractorBeamTurretLifecycleState.gd")
const SourceTractorBeamTurretBuildUpdateTileFlowState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileFlowState.gd")
const SourceTractorBeamTurretBuildUpdateTileLookTargetGuardState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileLookTargetGuardState.gd")
const SourceTractorBeamTurretBuildUpdateTileSoundLoopState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileSoundLoopState.gd")
const SourceTractorBeamTurretBuildUpdateTileAngleToTargetState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.gd")
const SourceTractorBeamTurretBuildUpdateTileRotationMoveState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileRotationMoveState.gd")
const SourceTractorBeamTurretBuildUpdateTileLastTargetPositionState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileLastTargetPositionState.gd")
const SourceTractorBeamTurretBuildUpdateTileActiveStrengthState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.gd")
const SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.gd")
const SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState.gd")
const SourceTractorBeamTurretBuildUpdateTileDamagePierceState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileDamagePierceState.gd")
const SourceTractorBeamTurretBuildUpdateTileStatusApplyState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileStatusApplyState.gd")
const SourceTractorBeamTurretBuildUpdateTileAnyTrueState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileAnyTrueState.gd")
const SourceTractorBeamTurretBuildUpdateTileImpulseNetState := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileImpulseNetState.gd")
const SourceTractorBeamTurretBuildDrawState := preload("res://src/game/SourceTractorBeamTurretBuildDrawState.gd")
const SourcePointDefenseTurretDefaults := preload("res://src/game/SourcePointDefenseTurretDefaults.gd")
const SourceWeaponDefaults := preload("res://src/game/SourceWeaponDefaults.gd")
const SourceWeaponsState := preload("res://src/game/SourceWeaponsState.gd")
const SourceStatusApplyState := preload("res://src/game/SourceStatusApplyState.gd")
const SourceShootPatternDefaults := preload("res://src/game/SourceShootPatternDefaults.gd")
const SourceChildState := preload("res://src/game/SourceChildState.gd")
const SourceBasicCompState := preload("res://src/game/SourceBasicCompState.gd")
const SourceUnitDefaults := preload("res://src/game/SourceUnitDefaults.gd")
const SourceUnitMetadataState := preload("res://src/game/SourceUnitMetadataState.gd")
const SourceItemDefaults := preload("res://src/game/SourceItemDefaults.gd")
const SourceItemMetadataState := preload("res://src/game/SourceItemMetadataState.gd")
const SourceBlockGeometry := preload("res://src/game/SourceBlockGeometry.gd")
const SourceBlockFootprint := preload("res://src/game/SourceBlockFootprint.gd")
const SourceBlockPlacement := preload("res://src/game/SourceBlockPlacement.gd")
const SourceBuildSelectionRuntimeState := preload("res://src/game/SourceBuildSelectionRuntimeState.gd")
const SourcePlacedBlockState := preload("res://src/game/SourcePlacedBlockState.gd")
const SourceSelectedBuildState := preload("res://src/game/SourceSelectedBuildState.gd")
const SourceBuildingTimeState := preload("res://src/game/SourceBuildingTimeState.gd")
const SourceBuildingEfficiencyState := preload("res://src/game/SourceBuildingEfficiencyState.gd")
const SourceBuildingMetaState := preload("res://src/game/SourceBuildingMetaState.gd")
const SourceBuildingControlState := preload("res://src/game/SourceBuildingControlState.gd")
const SourceBuilderRuntimeState := preload("res://src/game/SourceBuilderRuntimeState.gd")
const SourceBuilderDrawState := preload("res://src/game/SourceBuilderDrawState.gd")
const SourceBuildingLifecycleState := preload("res://src/game/SourceBuildingLifecycleState.gd")
const SourceBuildingDamageState := preload("res://src/game/SourceBuildingDamageState.gd")
const SourceBuildingSenseState := preload("res://src/game/SourceBuildingSenseState.gd")
const SourceBuildingSetPropState := preload("res://src/game/SourceBuildingSetPropState.gd")
const SourceBuildingVisibilityState := preload("res://src/game/SourceBuildingVisibilityState.gd")
const SourceBuildingCoreState := preload("res://src/game/SourceBuildingCoreState.gd")
const SourceBuildingItemState := preload("res://src/game/SourceBuildingItemState.gd")
const SourceBuildingItemDumpState := preload("res://src/game/SourceBuildingItemDumpState.gd")
const SourceBuildingLiquidState := preload("res://src/game/SourceBuildingLiquidState.gd")
const SourceBuildingPayloadState := preload("res://src/game/SourceBuildingPayloadState.gd")
const SourceBuildingPowerState := preload("res://src/game/SourceBuildingPowerState.gd")
const SourceBuildingDrawState := preload("res://src/game/SourceBuildingDrawState.gd")
const SourceBuildingDestructionState := preload("res://src/game/SourceBuildingDestructionState.gd")
const SourceConstructBlockState := preload("res://src/game/SourceConstructBlockState.gd")
const SourceConstructBuildState := preload("res://src/game/SourceConstructBuildState.gd")
const SourceBuildingDisplayState := preload("res://src/game/SourceBuildingDisplayState.gd")
const SourceBuildingConfigureState := preload("res://src/game/SourceBuildingConfigureState.gd")
const SourceBuildingInteractionState := preload("res://src/game/SourceBuildingInteractionState.gd")
const SourceOverdriveBoostState := preload("res://src/game/SourceOverdriveBoostState.gd")
const SourceOverdriveProjectorState := preload("res://src/game/SourceOverdriveProjectorState.gd")
const SourceMendProjectorState := preload("res://src/game/SourceMendProjectorState.gd")
const SourceProjectorBoostState := preload("res://src/game/SourceProjectorBoostState.gd")
const SourcePowerGeneratorState := preload("res://src/game/SourcePowerGeneratorState.gd")
const SourcePowerGraphState := preload("res://src/game/SourcePowerGraphState.gd")
const SourceConsumeState := preload("res://src/game/SourceConsumeState.gd")
const SourceConsumePowerState := preload("res://src/game/SourceConsumePowerState.gd")
const SourceConsumeItemFilterState := preload("res://src/game/SourceConsumeItemFilterState.gd")
const SourceConsumeItemListState := preload("res://src/game/SourceConsumeItemListState.gd")
const SourceConsumeItemExplodeState := preload("res://src/game/SourceConsumeItemExplodeState.gd")
const SourceConsumeLiquidBaseState := preload("res://src/game/SourceConsumeLiquidBaseState.gd")
const SourceConsumeLiquidState := preload("res://src/game/SourceConsumeLiquidState.gd")
const SourceConsumeLiquidFlammableState := preload("res://src/game/SourceConsumeLiquidFlammableState.gd")
const SourceConsumeLiquidFilterState := preload("res://src/game/SourceConsumeLiquidFilterState.gd")
const SourceConsumeLiquidsState := preload("res://src/game/SourceConsumeLiquidsState.gd")
const SourceConsumeLiquidsDynamicState := preload("res://src/game/SourceConsumeLiquidsDynamicState.gd")
const SourceConsumeItemDynamicState := preload("res://src/game/SourceConsumeItemDynamicState.gd")
const SourceConsumeItemEfficiencyState := preload("res://src/game/SourceConsumeItemEfficiencyState.gd")
const SourceConsumeItemsState := preload("res://src/game/SourceConsumeItemsState.gd")
const SourceConsumeItemAttributeState := preload("res://src/game/SourceConsumeItemAttributeState.gd")
const SourceThermalGeneratorState := preload("res://src/game/SourceThermalGeneratorState.gd")
const SourceUnitPayloadDumpState := preload("res://src/game/SourceUnitPayloadDumpState.gd")
const SourceUnitDestroyState := preload("res://src/game/SourceUnitDestroyState.gd")
const SourceUnitUpdateState := preload("res://src/game/SourceUnitUpdateState.gd")
const SourceUnitTetherState := preload("res://src/game/SourceUnitTetherState.gd")
const SourceBlockUnitState := preload("res://src/game/SourceBlockUnitState.gd")
const SourceBlockQueryState := preload("res://src/game/SourceBlockQueryState.gd")
const SourceBlockConsumeState := preload("res://src/game/SourceBlockConsumeState.gd")
const SourceBlockRequirementsState := preload("res://src/game/SourceBlockRequirementsState.gd")
const SourceBlockResearchRequirementsState := preload("res://src/game/SourceBlockResearchRequirementsState.gd")
const SourceBlockGetDependenciesState := preload("res://src/game/SourceBlockGetDependenciesState.gd")
const SourceBlockMetadataState := preload("res://src/game/SourceBlockMetadataState.gd")
const SourceBlockPostInitState := preload("res://src/game/SourceBlockPostInitState.gd")
const SourceBlockInitSoundState := preload("res://src/game/SourceBlockInitSoundState.gd")
const SourceBlockInitFlagsState := preload("res://src/game/SourceBlockInitFlagsState.gd")
const SourceBlockInitHealthState := preload("res://src/game/SourceBlockInitHealthState.gd")
const SourceBlockInitClipState := preload("res://src/game/SourceBlockInitClipState.gd")
const SourceBlockInitPlacementState := preload("res://src/game/SourceBlockInitPlacementState.gd")
const SourceBlockInitBuildTimeState := preload("res://src/game/SourceBlockInitBuildTimeState.gd")
const SourceBlockInitConsumerState := preload("res://src/game/SourceBlockInitConsumerState.gd")
const SourceBlockInitRuntimeState := preload("res://src/game/SourceBlockInitRuntimeState.gd")
const SourceBlockReinitializeConsumersState := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")
const SourceBlockLoadState := preload("res://src/game/SourceBlockLoadState.gd")
const SourceBlockPlanState := preload("res://src/game/SourceBlockPlanState.gd")
const SourceBlockSenseState := preload("res://src/game/SourceBlockSenseState.gd")
const SourceBuildPayloadState := preload("res://src/game/SourceBuildPayloadState.gd")
const SourceBuildPayloadDrawState := preload("res://src/game/SourceBuildPayloadDrawState.gd")
const SourceBuildPayloadLifecycleState := preload("res://src/game/SourceBuildPayloadLifecycleState.gd")
const SourceBlockProducerState := preload("res://src/game/SourceBlockProducerState.gd")
const SourceBlockProducerBuildUpdateState := preload("res://src/game/SourceBlockProducerBuildUpdateState.gd")
const SourceBlockProducerMoveOutPayloadState := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const SourceUnitPayloadBasicState := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const SourceUnitPayloadContentState := preload("res://src/game/SourceUnitPayloadContentState.gd")
const SourceUnitPayloadRequirementsState := preload("res://src/game/SourceUnitPayloadRequirementsState.gd")
const SourceUnitPayloadIoState := preload("res://src/game/SourceUnitPayloadIoState.gd")
const SourceUnitPayloadDrawState := preload("res://src/game/SourceUnitPayloadDrawState.gd")
const SourceSyncState := preload("res://src/game/SourceSyncState.gd")
const SourceBuildingTetherState := preload("res://src/game/SourceBuildingTetherState.gd")
const ContentCatalog := preload("res://src/mindustry/content/ContentCatalog.gd")

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
var rules_build_cost_multiplier := SourceRulesDefaults.BUILD_COST_MULTIPLIER_DEFAULT
var core_incinerates := SourceCoreDefaults.RULES_CORE_INCINERATES_DEFAULT
var core_incinerate_non_buildable := SourceCoreDefaults.INCINERATE_NON_BUILDABLE_DEFAULT
var core_max_health := 0.0
var core_health := 0.0
var core_damage_taken_total := 0.0
var game_over := false
var last_game_over_winner := ""
var drill_output_item_id := SourcePlayableScenarioDefaults.ITEM_COPPER
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
var input_runtime := SourceInputRuntime.new()
var drill_pos := SourcePlayableScenarioDefaults.DRILL_POS
var core_pos := SourcePlayableScenarioDefaults.CORE_POS
var duo_pos := SourcePlayableScenarioDefaults.DUO_POS

func _ready() -> void:
	SourceInputDefaults.ensure_input_map()
	load_config()
	load_content_registry()
	load_textures()
	bind_nodes()
	build_block_palette()
	build_world()
	build_hud()
	call_deferred("apply_world_viewport_fit")

func load_config() -> void:
	SourceGameConfigRuntimeState.load_config(self)

func playable_content_block_state(block_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.playable_content_block_state(block_id)

func playable_content_item_state(item_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.playable_content_item_state(item_id)

func playable_content_skin_override_state(skin_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.playable_content_skin_override_state(skin_id)

func source_symbol_registry_state(symbol: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.source_symbol_registry_state(symbol)

func ssot_symbol_registry_symbol_state(symbol: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_symbol_registry_symbol_state(symbol)

func source_symbol_audit_state() -> Dictionary:
	return SourceSsotAccessorRuntimeState.audit_summary_state()

func ssot_audit_registered_owner_state(owner_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_audit_registered_owner_state(owner_index)

func ssot_audit_function_state(function_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_audit_function_state(function_index)

func ssot_audit_exempt_owner_state(owner_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_audit_exempt_owner_state(owner_index)

func ssot_audit_legacy_unregistered_owner_state(owner_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_audit_legacy_unregistered_owner_state(owner_index)

func source_slice_ledger_state(slice_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.source_slice_ledger_state(slice_id)

func ssot_slice_ledger_state(slice_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_slice_ledger_state(slice_id)

func source_api_contract_state(contract_owner: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.source_api_contract_state(contract_owner)

func ssot_api_contract_state(contract_owner: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_api_contract_state(contract_owner)

func source_state_schema_state(schema_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.source_state_schema_state(schema_name)

func ssot_state_schema_state(schema_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_state_schema_state(schema_name)

func helper_state_schema_state(schema_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.helper_state_schema_state(schema_name)

func ssot_modules_state(module_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_modules_state(module_name)

func ssot_headquarter_registry_state(module_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.canonical_headquarter_registry_state(module_name)

func ssot_headquarter_lookup_state(alias_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.canonical_headquarter_lookup_state(alias_name)

func ssot_module_entry_state(module_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ssot_module_entry_state(module_name)

func asset_manifest_state() -> Dictionary:
	return SourceSsotAccessorRuntimeState.asset_manifest_state()

func asset_manifest_asset_state(target_path: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.asset_manifest_asset_state(target_path)

func source_manifest_state() -> Dictionary:
	return SourceSsotAccessorRuntimeState.source_manifest_state()

func source_manifest_file_state(file_path: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.source_manifest_file_state(file_path)

func ast_manifest_state() -> Dictionary:
	return SourceSsotAccessorRuntimeState.ast_manifest_state()

func ast_manifest_file_state(file_path: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ast_manifest_file_state(file_path)

func ast_manifest_failure_state(file_path: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.ast_manifest_failure_state(file_path)

func content_registry_state() -> Dictionary:
	return SourceSsotAccessorRuntimeState.content_registry_state()

func content_registry_item_state(item_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.content_registry_item_state(item_id)

func content_registry_liquid_state(liquid_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.content_registry_liquid_state(liquid_id)

func content_registry_unit_state(unit_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.content_registry_unit_state(unit_id)

func content_registry_block_state(block_id: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.content_registry_block_state(block_id)

func content_registry_count_state(count_name: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.content_registry_count_state(count_name)

func content_registry_wave_group_state(group_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.content_registry_wave_group_state(group_index)

func emitted_classes_state() -> Dictionary:
	return SourceSsotAccessorRuntimeState.emitted_classes_state()

func emitted_class_file_state(file_path: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.emitted_class_file_state(file_path)

func emitted_class_failure_state(failure_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.emitted_class_failure_state(failure_index)

func port_report_state() -> Dictionary:
	return SourceSsotAccessorRuntimeState.port_report_state()

func port_report_unsupported_state(unsupported_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.port_report_unsupported_state(unsupported_index)

func port_report_unsupported_feature_state(feature_index: String = "") -> Dictionary:
	return SourceSsotAccessorRuntimeState.port_report_unsupported_feature_state(feature_index)

func load_content_registry() -> void:
	SourceContentRegistryRuntimeState.load_content_registry(self)

func load_all_generated_scripts() -> void:
	SourceContentRegistryRuntimeState.load_all_generated_scripts(self)

func load_selected_generated_scripts() -> void:
	SourceContentRegistryRuntimeState.load_selected_generated_scripts(self)

func load_textures() -> void:
	SourceTextureRuntimeState.load_textures(self)

func build_block_palette() -> void:
	SourceBuildSelectionRuntimeState.build_block_palette(self)


func load_png_texture(path: String) -> Texture2D:
	return SourceTextureRuntimeState.load_png_texture(path)

func bind_nodes() -> void:
	SourceNodeBindingRuntimeState.bind_nodes(self)

func build_world() -> void:
	SourceWorldInitialBuildRuntimeState.build_world(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		select_build_slot(event.keycode)
	elif event is InputEventScreenDrag:
		set_touch_move_axis(SourceInputDefaults.touch_axis_from_drag(event.relative))
	elif event is InputEventScreenTouch and not event.pressed:
		set_touch_move_axis(Vector2.ZERO)
	elif event is InputEventMouseButton and event.pressed:
		var zoom_factor := SourceInputDefaults.zoom_factor_from_event(event)
		if zoom_factor != 1.0:
			var zoom_state := source_input_viewport_camera_zoom_state(camera.zoom, zoom_factor)
			camera.zoom = Vector2(float(zoom_state.get("x", camera.zoom.x)), float(zoom_state.get("y", camera.zoom.y)))
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var click_world_state := source_input_viewport_screen_to_world_state(event.position)
			place_selected_block_at_world(Vector2(float(click_world_state.get("x", event.position.x)), float(click_world_state.get("y", event.position.y))))

func set_touch_move_axis(axis: Vector2) -> void:
	input_runtime.set_touch_move_axis(axis)

func set_roblox_move_axis(axis: Vector2) -> void:
	input_runtime.set_roblox_move_axis(axis)

func set_virtual_input_axes(touch_x: float, touch_y: float, roblox_x: float, roblox_y: float) -> void:
	input_runtime.set_virtual_input_axes(touch_x, touch_y, roblox_x, roblox_y)

func source_input_viewport_camera_pan_delta(movement: Vector2, boosted: bool, delta: float) -> Vector2:
	return SourceInputViewportRuntimeState.camera_pan_delta(movement, boosted, delta, SourceTimeDefaults.TICK_RATE)

func source_input_viewport_camera_zoom_state(current_zoom: Vector2, zoom_factor: float) -> Dictionary:
	return SourceInputViewportRuntimeState.camera_zoom_state(current_zoom, zoom_factor)

func source_input_viewport_fit_camera_state(viewport_size: Vector2) -> Dictionary:
	return SourceInputViewportRuntimeState.viewport_fit_camera_state(SourcePlayableScenarioDefaults.WORLD_SIZE, tile_size, viewport_size)

func source_input_viewport_screen_to_world_state(screen_position: Vector2) -> Dictionary:
	if camera == null:
		return {"x": screen_position.x, "y": screen_position.y}
	return SourceInputViewportRuntimeState.screen_to_world_state(screen_position, camera.position, camera.zoom, get_viewport().get_visible_rect().size)

func source_input_viewport_clamped_camera_position_state(proposed_position: Vector2, viewport_size: Vector2) -> Dictionary:
	if camera == null:
		return {"x": proposed_position.x, "y": proposed_position.y, "clamped": false}
	return SourceInputViewportRuntimeState.clamped_camera_position_state(proposed_position, SourcePlayableScenarioDefaults.WORLD_SIZE, tile_size, viewport_size, camera.zoom)

func source_world_terrain_runtime_state() -> Dictionary:
	return SourceWorldTerrainRuntimeState.terrain_plan_state(SourcePlayableScenarioDefaults.world_cells(), SourcePlayableScenarioDefaults.ore_copper_cells(), SourcePlayableScenarioDefaults.BLOCK_STONE_FLOOR, SourcePlayableScenarioDefaults.BLOCK_ORE_COPPER, SourcePlayableScenarioDefaults.ITEM_COPPER, tile_size)

func source_world_initial_build_runtime_state() -> Dictionary:
	return SourceWorldInitialBuildRuntimeState.initial_build_plan_state(drill_pos, SourcePlayableScenarioDefaults.conveyor_cells(), core_pos, duo_pos, SourcePlayableScenarioDefaults.BLOCK_MECHANICAL_DRILL, SourcePlayableScenarioDefaults.BLOCK_CONVEYOR, SourcePlayableScenarioDefaults.BLOCK_CORE_SHARD, SourcePlayableScenarioDefaults.BLOCK_DUO, SourcePlayableScenarioDefaults.path_points(tile_size), tile_size)

func source_item_transport_bootstrap_state() -> Dictionary:
	return SourceItemTransportRuntimeState.bootstrap_state(path_points, SourceItemTransportRuntimeState.ITEM_SPRITE_COUNT_DEFAULT, SourceItemTransportRuntimeState.ITEM_SPRITE_KEY_DEFAULT)

func source_item_transport_runtime_state(progress_before: float, progress_delta: float) -> Dictionary:
	return SourceItemTransportRuntimeState.transport_positions_state(path_points, item_sprites.size(), progress_before, progress_delta)

func source_drill_dump_runtime_state(current_timer: float, source_delta: float, dump_interval: float) -> Dictionary:
	return SourceDrillDumpRuntimeState.dump_timer_state(current_timer, source_delta, dump_interval)

func source_drill_production_runtime_state(current_progress_fraction: float, drill_delay: float, output_delta: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	var callbacks := SourceDrillProductionRuntimeState.default_callbacks_state(self)
	return SourceDrillProductionRuntimeState.production_state(
		current_progress_fraction,
		drill_delay,
		output_delta,
		dominant_items,
		items_total,
		item_capacity,
		callbacks.get("output_batch", Callable()),
		callbacks.get("progress_fraction", Callable())
	)

func source_drill_runtime_state(seconds: float) -> Dictionary:
	return SourceDrillRuntimeState.runtime_state(SourceDrillRuntimeState.runtime_context(self, seconds, drill_pos, SourcePlayableScenarioDefaults.BLOCK_MECHANICAL_DRILL, drill_output_item_id, drill_ore_cell_count, SourceTimeDefaults.TICK_RATE), SourceDrillRuntimeState.runtime_callbacks(self))

func apply_world_viewport_fit() -> void:
	if camera == null:
		return
	var fit := source_input_viewport_fit_camera_state(get_viewport().get_visible_rect().size)
	var camera_position: Dictionary = fit.get("camera_position", {})
	var camera_zoom: Dictionary = fit.get("camera_zoom", {})
	camera.position = Vector2(float(camera_position.get("x", 0.0)), float(camera_position.get("y", 0.0)))
	camera.zoom = Vector2(float(camera_zoom.get("x", 1.0)), float(camera_zoom.get("y", 1.0)))

func world_viewport_fit_runtime_state() -> Dictionary:
	var fit := source_input_viewport_fit_camera_state(get_viewport().get_visible_rect().size)
	fit["camera_position_actual"] = {"x": camera.position.x if camera else 0.0, "y": camera.position.y if camera else 0.0}
	fit["camera_zoom_actual"] = {"x": camera.zoom.x if camera else 1.0, "y": camera.zoom.y if camera else 1.0}
	fit["camera_bounds"] = source_input_viewport_clamped_camera_position_state(camera.position if camera else Vector2.ZERO, get_viewport().get_visible_rect().size).get("camera_bounds", {})
	return fit

func select_build_slot(keycode: Key) -> void:
	SourceBuildSelectionRuntimeState.select_build_slot(self, keycode)

func select_next_build_slot() -> void:
	SourceBuildSelectionRuntimeState.select_next_build_slot(self)

func select_previous_build_slot() -> void:
	SourceBuildSelectionRuntimeState.select_previous_build_slot(self)

func select_build_block_by_id(block_id: String) -> bool:
	return SourceBuildSelectionRuntimeState.select_build_block_by_id(self, block_id)

func selected_build_properties(selected) -> Dictionary:
	return SourceSelectedBuildState.properties(selected)

func selected_build_health() -> float:
	if build_palette.is_empty():
		return SourceBlockMetadataState.SOURCE_BLOCK_HEALTH_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.health(selected)

func selected_build_scaled_health() -> float:
	if build_palette.is_empty():
		return SourceSelectedBuildState.SOURCE_BLOCK_SCALED_HEALTH_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.scaled_health(selected)

func selected_build_heal_percent() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.heal_percent(selected)

func selected_build_phase_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.phase_boost(selected)

func selected_build_phase_range_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.phase_range_boost(selected)

func selected_build_can_overdrive() -> bool:
	if build_palette.is_empty():
		return SourceBlockDefaults.CAN_OVERDRIVE_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.can_overdrive(selected)

func selected_build_has_power() -> bool:
	if build_palette.is_empty():
		return SourceSelectedBuildState.SOURCE_BLOCK_HAS_POWER_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.has_power(selected)

func selected_build_consumes_power() -> bool:
	if build_palette.is_empty():
		return SourceSelectedBuildState.SOURCE_BLOCK_CONSUMES_POWER_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.consumes_power(selected)

func selected_build_outputs_power() -> bool:
	if build_palette.is_empty():
		return SourceSelectedBuildState.SOURCE_BLOCK_OUTPUTS_POWER_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.outputs_power(selected)

func selected_build_power_usage() -> float:
	if build_palette.is_empty():
		return SourceBlockDefaults.SOURCE_BLOCK_POWER_USAGE_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.power_usage(selected)

func selected_build_power_capacity() -> float:
	if build_palette.is_empty():
		return SourceBlockDefaults.SOURCE_BLOCK_POWER_CAPACITY_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.power_capacity(selected)

func selected_build_power_buffered() -> bool:
	if build_palette.is_empty():
		return SourceBlockDefaults.SOURCE_BLOCK_POWER_BUFFERED_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.power_buffered(selected)

func selected_build_power_production() -> float:
	if build_palette.is_empty():
		return SourceBlockDefaults.SOURCE_BLOCK_POWER_PRODUCTION_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.power_production(selected)

func source_power_generator_get_power_production_state(enabled: bool, power_production: float, production_efficiency: float) -> Dictionary:
	return SourcePowerGeneratorState.get_power_production_state(enabled, power_production, production_efficiency)

func source_power_generator_displayed_power_production_state(power_production: float) -> Dictionary:
	return SourcePowerGeneratorState.displayed_power_production_state(power_production)

func generated_power_generator_displayed_power_production_bridge_state(power_production: float) -> Dictionary:
	return SourcePowerGeneratorState.generated_displayed_power_production_bridge_state(power_production)

func source_power_generator_build_serialization_state(production_efficiency: float, generate_time: float, revision: int, read_production_efficiency_value: float, read_generate_time_value: float) -> Dictionary:
	return SourcePowerGeneratorState.build_serialization_state(production_efficiency, generate_time, revision, read_production_efficiency_value, read_generate_time_value)

func source_solar_generator_update_tile_state(enabled: bool, solar_multiplier: float, light_env: float, lighting: bool, ambient_light_alpha: float) -> Dictionary:
	return SourcePowerGeneratorState.solar_update_tile_state(enabled, solar_multiplier, light_env, lighting, ambient_light_alpha)

func source_thermal_generator_update_tile_state(sum: float, attribute_env: float) -> Dictionary:
	return SourceThermalGeneratorState.update_tile_state(sum, attribute_env)

func source_thermal_generator_update_tile_effect_state(source_x: float, source_y: float, production_efficiency: float, effect_chance: float, chance_delta_result: bool, range_x: float, range_y: float, generate_effect_name: String) -> Dictionary:
	return SourceThermalGeneratorState.update_tile_effect_state(source_x, source_y, production_efficiency, effect_chance, chance_delta_result, range_x, range_y, generate_effect_name)

func source_thermal_generator_update_tile_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, production_efficiency: float, delta_value: float, liquid_capacity: float, current_liquid_amount: float) -> Dictionary:
	return SourceThermalGeneratorState.update_tile_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, production_efficiency, delta_value, liquid_capacity, current_liquid_amount)

func source_thermal_generator_displayed_power_production_state(power_production: float, display_efficiency_scale: float) -> Dictionary:
	return SourceThermalGeneratorState.displayed_power_production_state(power_production, display_efficiency_scale)

func source_thermal_generator_init_state(output_liquid_present: bool, light_clip_size: float, size: float) -> Dictionary:
	return SourceThermalGeneratorState.init_state(output_liquid_present, light_clip_size, size)

func source_thermal_generator_total_progress_state(enabled: bool, sum: float, super_total_progress: float) -> Dictionary:
	return SourceThermalGeneratorState.total_progress_state(enabled, sum, super_total_progress)

func source_thermal_generator_after_picked_up_state(sum: float, super_after_picked_up_state: Dictionary) -> Dictionary:
	return SourceThermalGeneratorState.after_picked_up_state(sum, super_after_picked_up_state)

func source_thermal_generator_on_proximity_added_state(sum_attribute: float, super_on_proximity_added_state: Dictionary) -> Dictionary:
	return SourceThermalGeneratorState.on_proximity_added_state(sum_attribute, super_on_proximity_added_state)

func source_thermal_generator_can_place_on_state(linked_attribute_sum: float, min_efficiency: float) -> Dictionary:
	return SourceThermalGeneratorState.can_place_on_state(linked_attribute_sum, min_efficiency)

func source_thermal_generator_draw_light_state(source_x: float, source_y: float, source_time: float, production_efficiency: float, size: float) -> Dictionary:
	return SourceThermalGeneratorState.draw_light_state(source_x, source_y, source_time, production_efficiency, size)

func source_thermal_generator_set_stats_state(power_production: float, display_efficiency_scale: float, display_efficiency: bool, size: float, floating: bool, super_set_stats_state: Dictionary) -> Dictionary:
	return SourceThermalGeneratorState.set_stats_state(power_production, display_efficiency_scale, display_efficiency, size, floating, super_set_stats_state)

func source_thermal_generator_set_stats_output_liquid_state(output_liquid_present: bool, output_liquid_liquid: String, output_liquid_amount: float, size: float) -> Dictionary:
	return SourceThermalGeneratorState.set_stats_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, size)

func source_thermal_generator_draw_place_state(x: int, y: int, rotation_value: int, valid: bool, display_efficiency: bool, sum_attribute: float, display_efficiency_scale: float) -> Dictionary:
	return SourceThermalGeneratorState.draw_place_state(x, y, rotation_value, valid, display_efficiency, sum_attribute, display_efficiency_scale)

func source_power_generator_warmup_state(enabled: bool, production_efficiency: float) -> Dictionary:
	return SourcePowerGeneratorState.warmup_state(enabled, production_efficiency)

func source_power_generator_should_explode_state(warmup_value: float, explosion_min_warmup: float) -> Dictionary:
	return SourcePowerGeneratorState.should_explode_state(warmup_value, explosion_min_warmup)

func source_power_generator_ambient_volume_state(production_efficiency: float) -> Dictionary:
	return SourcePowerGeneratorState.ambient_volume_state(production_efficiency)

func source_power_generator_create_explosion_gate_state(should_explode_value: bool) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_gate_state(should_explode_value)

func source_power_generator_create_explosion_damage_state(should_explode_value: bool, source_x: float, source_y: float, explosion_radius: int, explosion_damage: int, source_tilesize: int) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_damage_state(should_explode_value, source_x, source_y, explosion_radius, explosion_damage, source_tilesize)

func source_power_generator_create_explosion_effect_sound_state(should_explode_value: bool, source_x: float, source_y: float, explode_effect_value: String, explode_sound_value: String) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_effect_sound_state(should_explode_value, source_x, source_y, explode_effect_value, explode_sound_value)

func source_power_generator_create_explosion_puddle_loop_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_puddle_loop_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles)

func source_power_generator_create_explosion_puddle_vector_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_range: float, random_angle_units: Array, random_range_units: Array) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_puddle_vector_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_range, random_angle_units, random_range_units)

func source_power_generator_create_explosion_puddle_tile_world_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, source_x: float, source_y: float, source_tilesize: int, tmp_v1_vectors: Array) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_puddle_tile_world_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, source_x, source_y, source_tilesize, tmp_v1_vectors)

func source_power_generator_create_explosion_puddle_deposit_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_amount: float, tile_world_calls: Array) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_puddle_deposit_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_amount, tile_world_calls)

func source_power_generator_create_explosion_shake_state(should_explode_value: bool, source_x: float, source_y: float, explosion_shake: float, explosion_shake_duration: float) -> Dictionary:
	return SourcePowerGeneratorState.create_explosion_shake_state(should_explode_value, source_x, source_y, explosion_shake, explosion_shake_duration)

func source_power_generator_on_destroyed_reactor_explosion_state(reactor_explosions: bool = SourcePowerGeneratorState.SOURCE_RULES_REACTOR_EXPLOSIONS_DEFAULT, create_explosion_state: Dictionary = {}) -> Dictionary:
	return SourcePowerGeneratorState.on_destroyed_reactor_explosion_state(reactor_explosions, create_explosion_state)

func selected_build_item_duration() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.item_duration(selected)

func selected_build_max_nodes() -> int:
	if build_palette.is_empty():
		return 0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.max_nodes(selected)

func selected_build_laser_range() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.laser_range(selected)

func source_overdrive_projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	return SourceOverdriveProjectorState.projector_range(overdrive_projector, phase_heat)

func source_overdrive_projector_select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:
	return SourceOverdriveProjectorState.select_state(overdrive_projector, phase_heat)

func source_overdrive_projector_place_state(overdrive_projector) -> Dictionary:
	return SourceOverdriveProjectorState.place_state(overdrive_projector)

func source_overdrive_projector_target_filter_state(overdrive_projector, target_block, distance: float, phase_heat := 0.0) -> Dictionary:
	return SourceOverdriveProjectorState.target_filter_state(overdrive_projector, target_block, distance, phase_heat)

func selected_build_overdrive_target_filter_state_for_block_id(target_block_id: String, distance: float, phase_heat := 0.0) -> Dictionary:
	if build_palette.is_empty() or content_catalog == null:
		return {"real_range": 0.0, "distance": distance, "can_overdrive": false, "in_range": false, "eligible": false}
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	var target = content_catalog.get_by_id(target_block_id)
	return SourceSelectedBuildState.overdrive_target_filter_state(selected, target, distance, phase_heat)

func source_building_apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:
	return SourceBuildingTimeState.apply_boost_state(current_time_scale, current_duration, intensity, duration, can_overdrive, SourceBlockDefaults.TIME_SCALE_BOOST_EPSILON)

func source_building_time_scale_decay_state(current_time_scale: float, current_duration: float, source_delta: float) -> Dictionary:
	return SourceBuildingTimeState.time_scale_decay_state(current_time_scale, current_duration, source_delta, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func source_building_delta(source_delta: float, time_scale: float) -> float:
	return SourceBuildingTimeState.delta(source_delta, time_scale)

func source_building_edelta(source_delta: float, time_scale: float, efficiency: float) -> float:
	return SourceBuildingTimeState.edelta(source_delta, time_scale, efficiency)

func source_overdrive_projector_light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	return SourceOverdriveProjectorState.light_state(overdrive_projector, smooth_efficiency)

func source_overdrive_projector_draw_state(overdrive_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return SourceOverdriveProjectorState.draw_state(overdrive_projector, heat, phase_heat, SourceWorldDefaults.TILESIZE, source_time_ticks, lod_l2, lod_alpha2)

func source_overdrive_projector_real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return SourceOverdriveProjectorState.real_boost(overdrive_projector, phase_heat, efficiency)

func source_overdrive_projector_boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return SourceOverdriveProjectorState.boost_bar_fraction(overdrive_projector, phase_heat, efficiency)

func selected_build_overdrive_real_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_real_boost(selected)

func selected_build_overdrive_phase_real_boost() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_phase_real_boost(selected)

func selected_build_overdrive_boost_bar_fraction() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_boost_bar_fraction(selected)

func selected_build_overdrive_phase_boost_bar_fraction() -> float:
	if build_palette.is_empty():
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_phase_boost_bar_fraction(selected)

func selected_build_overdrive_place_state() -> Dictionary:
	if build_palette.is_empty():
		return {"range": 0.0, "color": ""}
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_place_state(selected)

func selected_build_overdrive_phase_select_state() -> Dictionary:
	if build_palette.is_empty():
		return {"range": 0.0, "color": ""}
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_phase_select_state(selected)

func selected_build_overdrive_light_state_for_smooth_efficiency(smooth_efficiency: float) -> Dictionary:
	if build_palette.is_empty():
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_light_state_for_smooth_efficiency(selected, smooth_efficiency)

func selected_build_overdrive_draw_state_for_inputs(heat: float, phase_heat: float, source_time_ticks := 0.0) -> Dictionary:
	if build_palette.is_empty():
		return {"visible": false, "f": 0.0, "base_color": "", "phase_color": "", "phase_heat": phase_heat, "top_alpha": 0.0, "top_rect": false, "lod_alpha2": 0.0, "stroke": 0.0, "line_r": 0.0, "line_w": 0.0}
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.overdrive_draw_state_for_inputs(selected, heat, phase_heat, SourceWorldDefaults.TILESIZE, source_time_ticks)

func selected_build_booster_item() -> String:
	if build_palette.is_empty():
		return ""
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.booster_item(selected)

func selected_build_booster_use_time() -> float:
	if build_palette.is_empty():
		return SourceSelectedBuildState.SOURCE_BUILD_BOOSTER_USE_TIME_DEFAULT
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.booster_use_time(selected)

func selected_build_place_state() -> Dictionary:
	if build_palette.is_empty():
		return {"range": 0.0, "color": ""}
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	return SourceSelectedBuildState.place_state(selected)

func source_mend_projector_repair_amount(mend_projector, target_block, phase_heat := 0.0, efficiency := 1.0) -> float:
	return SourceMendProjectorState.repair_amount(mend_projector, target_block, phase_heat, efficiency)

func source_mend_projector_light_state(mend_projector, smooth_efficiency: float) -> Dictionary:
	return SourceMendProjectorState.light_state(mend_projector, smooth_efficiency)

func source_mend_projector_reload(mend_projector) -> float:
	return SourceMendProjectorState.projector_reload(mend_projector)

func source_mend_projector_use_time(mend_projector) -> float:
	return SourceMendProjectorState.use_time(mend_projector)

func source_mend_projector_is_projector(block) -> bool:
	return SourceSelectedBuildState.is_mend_projector(block)

func source_overdrive_projector_reload(overdrive_projector) -> float:
	return SourceOverdriveProjectorState.projector_reload(overdrive_projector)

func source_overdrive_projector_use_time(overdrive_projector) -> float:
	return SourceOverdriveProjectorState.use_time(overdrive_projector)

func source_overdrive_projector_has_boost(overdrive_projector) -> bool:
	return SourceOverdriveProjectorState.has_boost(overdrive_projector)

func source_overdrive_projector_is_projector(block) -> bool:
	return SourceSelectedBuildState.is_overdrive_projector(block)

func source_mend_projector_progress(mend_projector, charge: float) -> float:
	return SourceMendProjectorState.progress(mend_projector, charge)

func source_mend_projector_select_state(mend_projector, phase_heat := 0.0) -> Dictionary:
	return SourceMendProjectorState.select_state(mend_projector, phase_heat)

func source_mend_projector_place_state(mend_projector) -> Dictionary:
	return SourceMendProjectorState.place_state(mend_projector)

func source_mend_projector_draw_state(mend_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return SourceMendProjectorState.draw_state(mend_projector, heat, phase_heat, float(SourceWorldDefaults.TILESIZE), source_time_ticks, lod_l2, lod_alpha2)

func source_absin(value: float, scl: float, mag: float) -> float:
	return SourceMathState.source_absin(value, scl, mag)

func source_approach(from_value: float, to_value: float, speed: float) -> float:
	return SourceMathState.source_approach(from_value, to_value, speed)

func source_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:
	return SourceMathState.source_approach_delta(from_value, to_value, speed, source_delta)

func source_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return SourceMathState.source_lerp_delta(from_value, to_value, progress, source_delta)

func selected_build_repair_amount() -> float:
	if build_palette.is_empty() or content_catalog == null:
		return 0.0
	var selected = SourceSelectedBuildState.selected_build(build_palette, selected_build_index)
	var mend_projector = content_catalog.get_by_id(SourceProjectorDefaults.MEND_PROJECTOR_BLOCK_ID)
	return source_mend_projector_repair_amount(mend_projector, selected)

func source_power_graph_add_role_state(build_present: bool, power_present: bool, graph_matches: bool, power_init: bool, old_graph_present: bool, old_graph_is_self: bool, old_graph_has_entity: bool, outputs_power: bool, consumes_power: bool, has_cons_power: bool, cons_power_buffered: bool) -> Dictionary:
	return SourcePowerGraphState.add_role_state(build_present, power_present, graph_matches, power_init, old_graph_present, old_graph_is_self, old_graph_has_entity, outputs_power, consumes_power, has_cons_power, cons_power_buffered)

func source_power_graph_add_graph_state(graph_is_self: bool, graph_all_size: int, all_size: int, graph_has_entity: bool, graph_tiles: Array) -> Dictionary:
	return SourcePowerGraphState.add_graph_state(graph_is_self, graph_all_size, all_size, graph_has_entity, graph_tiles)

func source_power_graph_check_add_state(entity_present: bool) -> Dictionary:
	return SourcePowerGraphState.check_add_state(entity_present)

func source_power_graph_clear_state(all: Array, producers: Array, consumers: Array, batteries: Array, entity_present: bool) -> Dictionary:
	return SourcePowerGraphState.clear_state(all, producers, consumers, batteries, entity_present)

func source_power_graph_reflow_state(tile: Dictionary) -> Dictionary:
	return SourcePowerGraphState.reflow_state(tile)

func source_power_graph_remove_list_state(all: Array, producers: Array, consumers: Array, batteries: Array, build) -> Dictionary:
	return SourcePowerGraphState.remove_list_state(all, producers, consumers, batteries, build)

func source_power_graph_remove_branch_seed_state(tile: Dictionary) -> Dictionary:
	return SourcePowerGraphState.remove_branch_seed_state(tile)

func source_power_graph_remove_branch_bfs_state(tile: Dictionary) -> Dictionary:
	return SourcePowerGraphState.remove_branch_bfs_state(tile)

func source_power_graph_remove_branch_update_state(tile: Dictionary) -> Dictionary:
	return SourcePowerGraphState.remove_branch_update_state(tile)

func source_power_graph_remove_empty_entity_state(tile: Dictionary, entity_present: bool) -> Dictionary:
	return SourcePowerGraphState.remove_empty_entity_state(tile, entity_present)

func source_power_graph_get_id_state(graph_id: int) -> Dictionary:
	return SourcePowerGraphState.get_id_state(graph_id)

func generated_power_graph_get_id_bridge_state(graph_id: int) -> Dictionary:
	return SourcePowerGraphState.generated_get_id_bridge_state(graph_id)

func source_power_graph_to_string_state(producers: String, consumers: String, batteries: String, all: String, graph_id: int) -> String:
	return SourcePowerGraphState.to_string_state(producers, consumers, batteries, all, graph_id)

func source_consume_power_ignore_state(buffered: bool) -> Dictionary:
	return SourceConsumePowerState.ignore_state(buffered)

func generated_consume_power_ignore_bridge_state(buffered: bool) -> Dictionary:
	return SourceConsumePowerState.generated_ignore_bridge_state(buffered)

func source_consume_power_apply_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return SourceConsumePowerState.apply_state(block_has_power_before, block_cons_power_before, consume_power_state)

func generated_consume_power_apply_bridge_state(block_has_power_before: bool, block_cons_power_before: Variant, consume_power_state: Variant) -> Dictionary:
	return SourceConsumePowerState.generated_apply_bridge_state(block_has_power_before, block_cons_power_before, consume_power_state)

func source_consume_power_efficiency_state(power_status: float) -> Dictionary:
	return SourceConsumePowerState.efficiency_state(power_status)

func generated_consume_power_efficiency_bridge_state(power_status: float) -> Dictionary:
	return SourceConsumePowerState.generated_efficiency_bridge_state(power_status)

func source_consume_power_display_state(buffered: bool, usage: float, capacity: float) -> Dictionary:
	return SourceConsumePowerState.display_state(buffered, usage, capacity, SourceTimeDefaults.TICK_RATE)

func generated_consume_power_display_bridge_state(buffered: bool, usage: float, capacity: float) -> Dictionary:
	return SourceConsumePowerState.generated_display_bridge_state(buffered, usage, capacity, SourceTimeDefaults.TICK_RATE)

func source_consume_power_condition_requested_power_state(usage: float, consume_get: bool) -> Dictionary:
	return SourceConsumePowerState.condition_requested_power_state(usage, consume_get)

func generated_consume_power_condition_requested_power_bridge_state(usage: float, consume_get: bool) -> Dictionary:
	return SourceConsumePowerState.generated_condition_requested_power_bridge_state(usage, consume_get)

func source_consume_power_dynamic_requested_power_state(usage_get: float) -> Dictionary:
	return SourceConsumePowerState.dynamic_requested_power_state(usage_get)

func generated_consume_power_dynamic_requested_power_bridge_state(usage_get: float) -> Dictionary:
	return SourceConsumePowerState.generated_dynamic_requested_power_bridge_state(usage_get)

func source_consume_power_dynamic_display_state(displayed_power_usage: float) -> Dictionary:
	return SourceConsumePowerState.dynamic_display_state(displayed_power_usage, SourceTimeDefaults.TICK_RATE)

func generated_consume_power_dynamic_display_bridge_state(displayed_power_usage: float) -> Dictionary:
	return SourceConsumePowerState.generated_dynamic_display_bridge_state(displayed_power_usage, SourceTimeDefaults.TICK_RATE)

func source_consume_item_flammable_item_efficiency_multiplier_state(item_flammability: float) -> Dictionary:
	return SourceConsumeItemAttributeState.flammable_item_efficiency_multiplier_state(item_flammability)

func generated_consume_item_flammable_item_efficiency_multiplier_bridge_state(item_flammability: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_flammable_item_efficiency_multiplier_bridge_state(item_flammability)

func source_consume_item_flammable_constructor_state(min_flammability: float) -> Dictionary:
	return SourceConsumeItemAttributeState.flammable_constructor_state(min_flammability)

func generated_consume_item_flammable_constructor_bridge_state(min_flammability: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_flammable_constructor_bridge_state(min_flammability)

func source_consume_item_flammable_default_constructor_state() -> Dictionary:
	return SourceConsumeItemAttributeState.flammable_default_constructor_state(SourceConsumerDefaults.CONSUME_ITEM_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func generated_consume_item_flammable_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeItemAttributeState.generated_flammable_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_ITEM_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func source_consume_item_explosive_item_efficiency_multiplier_state(item_explosiveness: float) -> Dictionary:
	return SourceConsumeItemAttributeState.explosive_item_efficiency_multiplier_state(item_explosiveness)

func generated_consume_item_explosive_item_efficiency_multiplier_bridge_state(item_explosiveness: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_explosive_item_efficiency_multiplier_bridge_state(item_explosiveness)

func source_consume_item_explosive_constructor_state(min_charge: float) -> Dictionary:
	return SourceConsumeItemAttributeState.explosive_constructor_state(min_charge)

func generated_consume_item_explosive_constructor_bridge_state(min_charge: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_explosive_constructor_bridge_state(min_charge)

func source_consume_item_explosive_default_constructor_state() -> Dictionary:
	return SourceConsumeItemAttributeState.explosive_default_constructor_state(SourceConsumerDefaults.CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT)

func generated_consume_item_explosive_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeItemAttributeState.generated_explosive_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_ITEM_EXPLOSIVE_MIN_CHARGE_DEFAULT)

func source_consume_item_radioactive_item_efficiency_multiplier_state(item_radioactivity: float) -> Dictionary:
	return SourceConsumeItemAttributeState.radioactive_item_efficiency_multiplier_state(item_radioactivity)

func generated_consume_item_radioactive_item_efficiency_multiplier_bridge_state(item_radioactivity: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_radioactive_item_efficiency_multiplier_bridge_state(item_radioactivity)

func source_consume_item_radioactive_constructor_state(min_radioactivity: float) -> Dictionary:
	return SourceConsumeItemAttributeState.radioactive_constructor_state(min_radioactivity)

func generated_consume_item_radioactive_constructor_bridge_state(min_radioactivity: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_radioactive_constructor_bridge_state(min_radioactivity)

func source_consume_item_radioactive_default_constructor_state() -> Dictionary:
	return SourceConsumeItemAttributeState.radioactive_default_constructor_state(SourceConsumerDefaults.CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT)

func generated_consume_item_radioactive_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeItemAttributeState.generated_radioactive_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_ITEM_RADIOACTIVE_MIN_RADIOACTIVITY_DEFAULT)

func source_consume_item_charged_item_efficiency_multiplier_state(item_charge: float) -> Dictionary:
	return SourceConsumeItemAttributeState.charged_item_efficiency_multiplier_state(item_charge)

func generated_consume_item_charged_item_efficiency_multiplier_bridge_state(item_charge: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_charged_item_efficiency_multiplier_bridge_state(item_charge)

func source_consume_item_charged_constructor_state(min_charge: float) -> Dictionary:
	return SourceConsumeItemAttributeState.charged_constructor_state(min_charge)

func generated_consume_item_charged_constructor_bridge_state(min_charge: float) -> Dictionary:
	return SourceConsumeItemAttributeState.generated_charged_constructor_bridge_state(min_charge)

func source_consume_item_charged_default_constructor_state() -> Dictionary:
	return SourceConsumeItemAttributeState.charged_default_constructor_state(SourceConsumerDefaults.CONSUME_ITEM_CHARGED_MIN_CHARGE_DEFAULT)

func generated_consume_item_charged_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeItemAttributeState.generated_charged_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_ITEM_CHARGED_MIN_CHARGE_DEFAULT)

func source_consume_item_filter_item_efficiency_multiplier_state() -> Dictionary:
	return SourceConsumeItemFilterState.item_efficiency_multiplier_state()

func generated_consume_item_filter_item_efficiency_multiplier_bridge_state() -> Dictionary:
	return SourceConsumeItemFilterState.generated_item_efficiency_multiplier_bridge_state()

func source_consume_item_filter_constructor_state(item: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.constructor_state(item)

func generated_consume_item_filter_constructor_bridge_state(item: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.generated_constructor_bridge_state(item)

func source_consume_item_filter_default_constructor_state() -> Dictionary:
	return SourceConsumeItemFilterState.default_constructor_state(SourceConsumerDefaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func generated_consume_item_filter_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeItemFilterState.generated_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func source_consume_items_constructor_state(item_stacks: Array) -> Dictionary:
	return SourceConsumeItemsState.constructor_state(item_stacks)

func generated_consume_items_constructor_bridge_state(item_stacks: Array) -> Dictionary:
	return SourceConsumeItemsState.generated_constructor_bridge_state(item_stacks)

func source_consume_items_default_constructor_state() -> Dictionary:
	return SourceConsumeItemsState.default_constructor_state(SourceConsumerDefaults.CONSUME_ITEMS_EMPTY_STACKS)

func generated_consume_items_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeItemsState.generated_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_ITEMS_EMPTY_STACKS)

func source_consume_item_filter_apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	return SourceConsumeItemFilterState.apply_state(block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids)

func generated_consume_item_filter_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, filtered_item_ids: Array) -> Dictionary:
	return SourceConsumeItemFilterState.generated_apply_bridge_state(block_has_items_before, block_accepts_items_before, item_filter_before, filtered_item_ids)

func source_consume_items_apply_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, item_stacks: Array) -> Dictionary:
	return SourceConsumeItemsState.apply_state(block_has_items_before, block_accepts_items_before, item_filter_before, item_stacks)

func generated_consume_items_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool, item_filter_before: Array, item_stacks: Array) -> Dictionary:
	return SourceConsumeItemsState.generated_apply_bridge_state(block_has_items_before, block_accepts_items_before, item_filter_before, item_stacks)

func source_consume_items_build_state(item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemsState.build_state(item_stacks, item_amounts, multiplier_get_build, SourceUiDefaults.PAD_RIGHT)

func generated_consume_items_build_bridge_state(item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemsState.generated_build_bridge_state(item_stacks, item_amounts, multiplier_get_build, SourceUiDefaults.PAD_RIGHT)

func source_consume_items_trigger_state(item_stacks: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemsState.trigger_state(item_stacks, multiplier_get_build)

func generated_consume_items_trigger_bridge_state(item_stacks: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemsState.generated_trigger_bridge_state(item_stacks, multiplier_get_build)

func source_consume_items_efficiency_state(consume_trigger_valid: bool, item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemsState.efficiency_state(consume_trigger_valid, item_stacks, item_amounts, multiplier_get_build)

func generated_consume_items_efficiency_bridge_state(consume_trigger_valid: bool, item_stacks: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemsState.generated_efficiency_bridge_state(consume_trigger_valid, item_stacks, item_amounts, multiplier_get_build)

func source_consume_items_display_state(booster: bool, stats_time_period: float, item_stacks: Array) -> Dictionary:
	return SourceConsumeItemsState.display_state(booster, stats_time_period, item_stacks)

func generated_consume_items_display_bridge_state(booster: bool, stats_time_period: float, item_stacks: Array) -> Dictionary:
	return SourceConsumeItemsState.generated_display_bridge_state(booster, stats_time_period, item_stacks)

func source_consume_item_filter_build_state(filtered_item_ids: Array, build_items_has_item_flags: Array) -> Dictionary:
	return SourceConsumeItemFilterState.build_state(filtered_item_ids, build_items_has_item_flags, SourceUiDefaults.ICON_MED)

func generated_consume_item_filter_build_bridge_state(filtered_item_ids: Array, build_items_has_item_flags: Array) -> Dictionary:
	return SourceConsumeItemFilterState.generated_build_bridge_state(filtered_item_ids, build_items_has_item_flags, SourceUiDefaults.ICON_MED)

func source_consume_item_filter_update_state(build_state: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.update_state(build_state)

func generated_consume_item_filter_update_bridge_state(build_state: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.generated_update_bridge_state(build_state)

func source_consume_item_filter_trigger_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.trigger_state(build_state, consumed_item)

func generated_consume_item_filter_trigger_bridge_state(build_state: Variant, consumed_item: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.generated_trigger_bridge_state(build_state, consumed_item)

func source_consume_item_filter_efficiency_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.efficiency_state(consume_trigger_valid, consumed_item)

func generated_consume_item_filter_efficiency_bridge_state(consume_trigger_valid: bool, consumed_item: Variant) -> Dictionary:
	return SourceConsumeItemFilterState.generated_efficiency_bridge_state(consume_trigger_valid, consumed_item)

func source_consume_item_filter_get_consumed_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	return SourceConsumeItemFilterState.get_consumed_state(content_items, build_items_has_item_flags, filter_get_item_flags)

func generated_consume_item_filter_get_consumed_bridge_state(content_items: Array, build_items_has_item_flags: Array, filter_get_item_flags: Array) -> Dictionary:
	return SourceConsumeItemFilterState.generated_get_consumed_bridge_state(content_items, build_items_has_item_flags, filter_get_item_flags)

func source_consume_item_filter_display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	return SourceConsumeItemFilterState.display_state(booster, stats_time_period, filtered_item_ids)

func generated_consume_item_filter_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array) -> Dictionary:
	return SourceConsumeItemFilterState.generated_display_bridge_state(booster, stats_time_period, filtered_item_ids)

func source_consume_item_filter_efficiency_multiplier_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	return SourceConsumeItemFilterState.efficiency_multiplier_state(consumed_item, item_efficiency_multiplier)

func generated_consume_item_filter_efficiency_multiplier_bridge_state(consumed_item: Variant, item_efficiency_multiplier: float) -> Dictionary:
	return SourceConsumeItemFilterState.generated_efficiency_multiplier_bridge_state(consumed_item, item_efficiency_multiplier)

func source_consume_item_list_set_multipliers_state(objects: Array) -> Dictionary:
	return SourceConsumeItemListState.set_multipliers_state(objects)

func generated_consume_item_list_set_multipliers_bridge_state(objects: Array) -> Dictionary:
	return SourceConsumeItemListState.generated_set_multipliers_bridge_state(objects)

func source_consume_item_list_efficiency_multiplier_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	return SourceConsumeItemListState.efficiency_multiplier_state(consumed_item, item_multiplier_value)

func generated_consume_item_list_efficiency_multiplier_bridge_state(consumed_item: Variant, item_multiplier_value: float) -> Dictionary:
	return SourceConsumeItemListState.generated_efficiency_multiplier_bridge_state(consumed_item, item_multiplier_value)

func source_consume_liquid_flammable_display_state(booster: bool, amount: float, filtered_liquid_ids: Array, liquid_efficiency_values: Array, table_has_cells: bool) -> Dictionary:
	return SourceConsumeLiquidFlammableState.display_state(booster, amount, filtered_liquid_ids, liquid_efficiency_values, table_has_cells, SourceTimeDefaults.TICK_RATE)

func generated_consume_liquid_flammable_display_bridge_state(booster: bool, amount: float, filtered_liquid_ids: Array, liquid_efficiency_values: Array, table_has_cells: bool) -> Dictionary:
	return SourceConsumeLiquidFlammableState.generated_display_bridge_state(booster, amount, filtered_liquid_ids, liquid_efficiency_values, table_has_cells, SourceTimeDefaults.TICK_RATE)

func source_consume_liquid_flammable_liquid_efficiency_multiplier_state(liquid_flammability: float) -> Dictionary:
	return SourceConsumeLiquidFlammableState.liquid_efficiency_multiplier_state(liquid_flammability)

func generated_consume_liquid_flammable_liquid_efficiency_multiplier_bridge_state(liquid_flammability: float) -> Dictionary:
	return SourceConsumeLiquidFlammableState.generated_liquid_efficiency_multiplier_bridge_state(liquid_flammability)

func source_consume_liquid_flammable_constructor_state(min_flammability: float, amount: float) -> Dictionary:
	return SourceConsumeLiquidFlammableState.constructor_state(min_flammability, amount)

func generated_consume_liquid_flammable_constructor_bridge_state(min_flammability: float, amount: float) -> Dictionary:
	return SourceConsumeLiquidFlammableState.generated_constructor_bridge_state(min_flammability, amount)

func source_consume_liquid_flammable_amount_constructor_state(amount: float) -> Dictionary:
	return SourceConsumeLiquidFlammableState.amount_constructor_state(amount, SourceConsumerDefaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func generated_consume_liquid_flammable_amount_constructor_bridge_state(amount: float) -> Dictionary:
	return SourceConsumeLiquidFlammableState.generated_amount_constructor_bridge_state(amount, SourceConsumerDefaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func source_consume_liquid_flammable_default_constructor_state() -> Dictionary:
	return SourceConsumeLiquidFlammableState.default_constructor_state(SourceConsumerDefaults.CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT, SourceConsumerDefaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func generated_consume_liquid_flammable_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeLiquidFlammableState.generated_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_LIQUID_FLAMMABLE_AMOUNT_DEFAULT, SourceConsumerDefaults.CONSUME_LIQUID_FLAMMABLE_MIN_FLAMMABILITY_DEFAULT)

func source_consume_liquid_filter_constructor_state(filter_handle: Variant, amount: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.constructor_state(filter_handle, amount)

func generated_consume_liquid_filter_constructor_bridge_state(filter_handle: Variant, amount: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_constructor_bridge_state(filter_handle, amount)

func source_consume_liquid_filter_default_constructor_state() -> Dictionary:
	return SourceConsumeLiquidFilterState.default_constructor_state(SourceConsumerDefaults.CONSUME_LIQUID_FILTER_DEFAULT_EXPR)

func generated_consume_liquid_filter_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_LIQUID_FILTER_DEFAULT_EXPR)

func source_consume_liquid_filter_apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidFilterState.apply_state(block_has_liquids_before, liquid_filter_before, filtered_liquid_ids)

func generated_consume_liquid_filter_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, filtered_liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_apply_bridge_state(block_has_liquids_before, liquid_filter_before, filtered_liquid_ids)

func source_consume_liquid_filter_build_state(filtered_liquid_ids: Array, consumed_liquid: Variant) -> Dictionary:
	return SourceConsumeLiquidFilterState.build_state(filtered_liquid_ids, consumed_liquid, SourceUiDefaults.ICON_MED)

func generated_consume_liquid_filter_build_bridge_state(filtered_liquid_ids: Array, consumed_liquid: Variant) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_build_bridge_state(filtered_liquid_ids, consumed_liquid, SourceUiDefaults.ICON_MED)

func source_consume_liquid_filter_get_consumed_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	return SourceConsumeLiquidFilterState.get_consumed_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)

func generated_consume_liquid_filter_get_consumed_bridge_state(current_liquid: Variant, current_filter_get_liquid: bool, current_amount: float, content_liquids: Array, filter_get_liquid_flags: Array, build_liquid_amounts: Array) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_get_consumed_bridge_state(current_liquid, current_filter_get_liquid, current_amount, content_liquids, filter_get_liquid_flags, build_liquid_amounts)

func source_consume_liquid_filter_update_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.update_state(consumed_liquid, amount, build_edelta, multiplier_get_build)

func generated_consume_liquid_filter_update_bridge_state(consumed_liquid: Variant, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_update_bridge_state(consumed_liquid, amount, build_edelta, multiplier_get_build)

func source_consume_liquid_filter_efficiency_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.efficiency_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build, SourceConsumerDefaults.CONSUME_EFFICIENCY_EPSILON)

func generated_consume_liquid_filter_efficiency_bridge_state(consumed_liquid: Variant, build_liquids_get: float, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_efficiency_bridge_state(consumed_liquid, build_liquids_get, amount, build_edelta, multiplier_get_build, SourceConsumerDefaults.CONSUME_EFFICIENCY_EPSILON)

func source_consume_liquid_filter_efficiency_multiplier_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.efficiency_multiplier_state(consumed_liquid, liquid_efficiency_multiplier)

func generated_consume_liquid_filter_efficiency_multiplier_bridge_state(consumed_liquid: Variant, liquid_efficiency_multiplier: float) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_efficiency_multiplier_bridge_state(consumed_liquid, liquid_efficiency_multiplier)

func source_consume_liquid_filter_liquid_efficiency_multiplier_state() -> Dictionary:
	return SourceConsumeLiquidFilterState.liquid_efficiency_multiplier_state()

func generated_consume_liquid_filter_liquid_efficiency_multiplier_bridge_state() -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_liquid_efficiency_multiplier_bridge_state()

func source_consume_liquid_filter_display_state(booster: bool, amount: float, filtered_liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidFilterState.display_state(booster, amount, filtered_liquid_ids, SourceTimeDefaults.TICK_RATE)

func generated_consume_liquid_filter_display_bridge_state(booster: bool, amount: float, filtered_liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_display_bridge_state(booster, amount, filtered_liquid_ids, SourceTimeDefaults.TICK_RATE)

func source_consume_liquid_filter_consumes_state(filter_get_liquid: bool) -> Dictionary:
	return SourceConsumeLiquidFilterState.consumes_state(filter_get_liquid)

func generated_consume_liquid_filter_consumes_bridge_state(filter_get_liquid: bool) -> Dictionary:
	return SourceConsumeLiquidFilterState.generated_consumes_bridge_state(filter_get_liquid)

func source_consume_optional_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return SourceConsumeState.optional_state(optional_value, boost_value)

func generated_consume_optional_bridge_state(optional_value: bool, boost_value: bool) -> Dictionary:
	return SourceConsumeState.generated_optional_bridge_state(optional_value, boost_value)

func source_consume_boost_state() -> Dictionary:
	return SourceConsumeState.boost_state()

func generated_consume_boost_bridge_state() -> Dictionary:
	return SourceConsumeState.generated_boost_bridge_state()

func source_consume_update_flag_state(update_value: bool) -> Dictionary:
	return SourceConsumeState.update_flag_state(update_value)

func generated_consume_update_flag_bridge_state(update_value: bool) -> Dictionary:
	return SourceConsumeState.generated_update_flag_bridge_state(update_value)

func source_consume_ignore_state() -> Dictionary:
	return SourceConsumeState.ignore_state()

func generated_consume_ignore_bridge_state() -> Dictionary:
	return SourceConsumeState.generated_ignore_bridge_state()

func source_consume_build_state(build: Variant, table: Variant) -> Dictionary:
	return SourceConsumeState.build_state(build, table)

func generated_consume_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	return SourceConsumeState.generated_build_bridge_state(build, table)

func source_consume_item_explode_build_state(build: Variant, table: Variant) -> Dictionary:
	return SourceConsumeItemExplodeState.build_state(build, table)

func generated_consume_item_explode_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	return SourceConsumeItemExplodeState.generated_build_bridge_state(build, table)

func source_consume_apply_state(block: Variant) -> Dictionary:
	return SourceConsumeState.apply_state(block)

func generated_consume_apply_bridge_state(block: Variant) -> Dictionary:
	return SourceConsumeState.generated_apply_bridge_state(block)

func source_consume_trigger_state(build: Variant) -> Dictionary:
	return SourceConsumeState.trigger_state(build)

func generated_consume_trigger_bridge_state(build: Variant) -> Dictionary:
	return SourceConsumeState.generated_trigger_bridge_state(build)

func source_consume_update_build_state(build: Variant) -> Dictionary:
	return SourceConsumeState.update_build_state(build)

func generated_consume_update_build_bridge_state(build: Variant) -> Dictionary:
	return SourceConsumeState.generated_update_build_bridge_state(build)

func source_consume_display_state(stats: Variant) -> Dictionary:
	return SourceConsumeState.display_state(stats)

func generated_consume_display_bridge_state(stats: Variant) -> Dictionary:
	return SourceConsumeState.generated_display_bridge_state(stats)

func source_consume_efficiency_state() -> Dictionary:
	return SourceConsumeState.efficiency_state()

func generated_consume_efficiency_bridge_state() -> Dictionary:
	return SourceConsumeState.generated_efficiency_bridge_state()

func source_consume_efficiency_multiplier_state() -> Dictionary:
	return SourceConsumeState.efficiency_multiplier_state()

func generated_consume_efficiency_multiplier_bridge_state() -> Dictionary:
	return SourceConsumeState.generated_efficiency_multiplier_bridge_state()

func source_consume_liquid_base_constructor_state(amount: float) -> Dictionary:
	return SourceConsumeLiquidBaseState.constructor_state(amount)

func generated_consume_liquid_base_constructor_bridge_state(amount: float) -> Dictionary:
	return SourceConsumeLiquidBaseState.generated_constructor_bridge_state(amount)

func source_consume_liquid_constructor_state(liquid: Variant, amount: float) -> Dictionary:
	return SourceConsumeLiquidState.constructor_state(liquid, amount)

func generated_consume_liquid_constructor_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	return SourceConsumeLiquidState.generated_constructor_bridge_state(liquid, amount)

func source_consume_liquid_default_constructor_state() -> Dictionary:
	return SourceConsumeLiquidState.default_constructor_state(SourceConsumerDefaults.CONSUME_LIQUID_DEFAULT_LIQUID, SourceConsumerDefaults.CONSUME_LIQUID_DEFAULT_AMOUNT)

func generated_consume_liquid_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeLiquidState.generated_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_LIQUID_DEFAULT_LIQUID, SourceConsumerDefaults.CONSUME_LIQUID_DEFAULT_AMOUNT)

func source_consume_liquid_base_apply_state(block_has_liquids_before: bool) -> Dictionary:
	return SourceConsumeLiquidBaseState.apply_state(block_has_liquids_before)

func generated_consume_liquid_base_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	return SourceConsumeLiquidBaseState.generated_apply_bridge_state(block_has_liquids_before)

func source_consume_liquid_base_abstract_consumes_state(liquid: Variant) -> Dictionary:
	return SourceConsumeLiquidBaseState.abstract_consumes_state(liquid)

func generated_consume_liquid_base_abstract_consumes_bridge_state(liquid: Variant) -> Dictionary:
	return SourceConsumeLiquidBaseState.generated_abstract_consumes_bridge_state(liquid)

func source_consume_liquid_apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int) -> Dictionary:
	return SourceConsumeLiquidState.apply_state(block_has_liquids_before, liquid_filter_before, liquid_id, SourceConsumeLiquidState.default_callbacks_state(self).get("base_apply_state", Callable()))

func generated_consume_liquid_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_id: int) -> Dictionary:
	return SourceConsumeLiquidState.generated_apply_bridge_state(block_has_liquids_before, liquid_filter_before, liquid_id, SourceConsumeLiquidState.default_callbacks_state(self).get("base_apply_state", Callable()))

func source_consume_liquid_build_state(liquid_id: int, build_liquids_get: float) -> Dictionary:
	return SourceConsumeLiquidState.build_state(liquid_id, build_liquids_get, SourceUiDefaults.ICON_MED)

func generated_consume_liquid_build_bridge_state(liquid_id: int, build_liquids_get: float) -> Dictionary:
	return SourceConsumeLiquidState.generated_build_bridge_state(liquid_id, build_liquids_get, SourceUiDefaults.ICON_MED)

func source_consume_liquid_display_state(booster: bool, liquid_id: int, amount: float) -> Dictionary:
	return SourceConsumeLiquidState.display_state(booster, liquid_id, amount)

func generated_consume_liquid_display_bridge_state(booster: bool, liquid_id: int, amount: float) -> Dictionary:
	return SourceConsumeLiquidState.generated_display_bridge_state(booster, liquid_id, amount, SourceTimeDefaults.TICK_RATE)

func source_consume_liquid_update_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidState.update_state(liquid_id, amount, build_edelta, multiplier_get_build)

func generated_consume_liquid_update_bridge_state(liquid_id: int, amount: float, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidState.generated_update_bridge_state(liquid_id, amount, build_edelta, multiplier_get_build)

func source_consume_liquids_constructor_state(liquid_stacks: Array) -> Dictionary:
	return SourceConsumeLiquidsState.constructor_state(liquid_stacks)

func generated_consume_liquids_constructor_bridge_state(liquid_stacks: Array) -> Dictionary:
	return SourceConsumeLiquidsState.generated_constructor_bridge_state(liquid_stacks)

func source_consume_liquids_default_constructor_state() -> Dictionary:
	return SourceConsumeLiquidsState.default_constructor_state(SourceConsumeLiquidsState.SOURCE_CONSUME_LIQUIDS_EMPTY_STACKS)

func generated_consume_liquids_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeLiquidsState.generated_default_constructor_bridge_state(SourceConsumeLiquidsState.SOURCE_CONSUME_LIQUIDS_EMPTY_STACKS)

func source_consume_liquids_apply_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidsState.apply_state(block_has_liquids_before, liquid_filter_before, liquid_ids)

func generated_consume_liquids_apply_bridge_state(block_has_liquids_before: bool, liquid_filter_before: Array, liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidsState.generated_apply_bridge_state(block_has_liquids_before, liquid_filter_before, liquid_ids)

func source_consume_liquids_build_state(liquid_ids: Array, liquid_amounts: Array) -> Dictionary:
	return SourceConsumeLiquidsState.build_state(liquid_ids, liquid_amounts)

func generated_consume_liquids_build_bridge_state(liquid_ids: Array, liquid_amounts: Array) -> Dictionary:
	return SourceConsumeLiquidsState.generated_build_bridge_state(liquid_ids, liquid_amounts)

func source_consume_liquids_update_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsState.update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func generated_consume_liquids_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsState.generated_update_bridge_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func source_consume_liquids_efficiency_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsState.efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)

func generated_consume_liquids_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsState.generated_efficiency_bridge_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, build_efficiency_scale, multiplier_get_build)

func source_consume_liquid_efficiency_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidState.efficiency_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)

func generated_consume_liquid_efficiency_bridge_state(build_liquids_get: float, amount: float, build_edelta: float, build_efficiency_scale: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidState.generated_efficiency_bridge_state(build_liquids_get, amount, build_edelta, build_efficiency_scale, multiplier_get_build)

func source_consume_liquids_display_state(booster: bool, liquid_ids: Array, liquid_stack_amounts: Array) -> Dictionary:
	return SourceConsumeLiquidsState.display_state(booster, liquid_ids, liquid_stack_amounts)

func generated_consume_liquids_display_bridge_state(booster: bool, liquid_ids: Array, liquid_stack_amounts: Array) -> Dictionary:
	return SourceConsumeLiquidsState.generated_display_bridge_state(booster, liquid_ids, liquid_stack_amounts, SourceTimeDefaults.TICK_RATE)

func source_consume_liquids_dynamic_constructor_state(liquids: Variant) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.constructor_state(liquids)

func generated_consume_liquids_dynamic_constructor_bridge_state(liquids: Variant) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.generated_constructor_bridge_state(liquids)

func source_consume_item_dynamic_constructor_state(items: Variant) -> Dictionary:
	return SourceConsumeItemDynamicState.constructor_state(items)

func generated_consume_item_dynamic_constructor_bridge_state(items: Variant) -> Dictionary:
	return SourceConsumeItemDynamicState.generated_constructor_bridge_state(items)

func source_consume_item_efficiency_constructor_state(item: Variant) -> Dictionary:
	return SourceConsumeItemEfficiencyState.constructor_state(item)

func generated_consume_item_efficiency_constructor_bridge_state(item: Variant) -> Dictionary:
	return SourceConsumeItemEfficiencyState.generated_constructor_bridge_state(item)

func source_consume_item_efficiency_default_constructor_state() -> Dictionary:
	return SourceConsumeItemEfficiencyState.default_constructor_state(SourceConsumerDefaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func generated_consume_item_efficiency_default_constructor_bridge_state() -> Dictionary:
	return SourceConsumeItemEfficiencyState.generated_default_constructor_bridge_state(SourceConsumerDefaults.CONSUME_ITEM_FILTER_DEFAULT_EXPR)

func source_consume_item_dynamic_apply_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return SourceConsumeItemDynamicState.apply_state(block_has_items_before, block_accepts_items_before)

func generated_consume_item_dynamic_apply_bridge_state(block_has_items_before: bool, block_accepts_items_before: bool) -> Dictionary:
	return SourceConsumeItemDynamicState.generated_apply_bridge_state(block_has_items_before, block_accepts_items_before)

func source_consume_item_dynamic_build_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	return SourceConsumeItemDynamicState.build_state(current_item_ids, next_item_ids)

func generated_consume_item_dynamic_build_bridge_state(current_item_ids: Array, next_item_ids: Array) -> Dictionary:
	return SourceConsumeItemDynamicState.generated_build_bridge_state(current_item_ids, next_item_ids)

func source_consume_item_dynamic_rebuild_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemDynamicState.rebuild_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, SourceUiDefaults.PAD_RIGHT)

func generated_consume_item_dynamic_rebuild_bridge_state(item_ids: Array, item_stack_amounts: Array, item_amounts: Array, building_has_items: bool, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemDynamicState.generated_rebuild_bridge_state(item_ids, item_stack_amounts, item_amounts, building_has_items, multiplier_get_build, SourceUiDefaults.PAD_RIGHT)

func source_consume_item_dynamic_trigger_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemDynamicState.trigger_state(item_ids, item_stack_amounts, multiplier_get_build)

func generated_consume_item_dynamic_trigger_bridge_state(item_ids: Array, item_stack_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemDynamicState.generated_trigger_bridge_state(item_ids, item_stack_amounts, multiplier_get_build)

func source_consume_item_dynamic_efficiency_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemDynamicState.efficiency_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)

func generated_consume_item_dynamic_efficiency_bridge_state(consume_trigger_valid: bool, item_ids: Array, item_stack_amounts: Array, item_amounts: Array, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeItemDynamicState.generated_efficiency_bridge_state(consume_trigger_valid, item_ids, item_stack_amounts, item_amounts, multiplier_get_build)

func source_consume_item_efficiency_display_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool) -> Dictionary:
	return SourceConsumeItemEfficiencyState.display_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, SourceTimeDefaults.TICK_RATE)

func generated_consume_item_efficiency_display_bridge_state(booster: bool, stats_time_period: float, filtered_item_ids: Array, item_efficiency_multipliers: Array, item_duration_multipliers: Array, table_has_cells: bool) -> Dictionary:
	return SourceConsumeItemEfficiencyState.generated_display_bridge_state(booster, stats_time_period, filtered_item_ids, item_efficiency_multipliers, item_duration_multipliers, table_has_cells, SourceTimeDefaults.TICK_RATE)

func source_consume_liquids_dynamic_apply_state(block_has_liquids_before: bool) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.apply_state(block_has_liquids_before)

func generated_consume_liquids_dynamic_apply_bridge_state(block_has_liquids_before: bool) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.generated_apply_bridge_state(block_has_liquids_before)

func source_consume_liquids_dynamic_build_state(current_liquid_ids: Array, next_liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.build_state(current_liquid_ids, next_liquid_ids)

func generated_consume_liquids_dynamic_build_bridge_state(current_liquid_ids: Array, next_liquid_ids: Array) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.generated_build_bridge_state(current_liquid_ids, next_liquid_ids)

func source_consume_liquids_dynamic_rebuild_state(liquid_ids: Array, liquid_amounts: Array, building_has_liquids: bool) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.rebuild_state(liquid_ids, liquid_amounts, building_has_liquids, SourceUiDefaults.ICON_MED, SourceUiDefaults.PAD_RIGHT)

func generated_consume_liquids_dynamic_rebuild_bridge_state(liquid_ids: Array, liquid_amounts: Array, building_has_liquids: bool) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.generated_rebuild_bridge_state(liquid_ids, liquid_amounts, building_has_liquids, SourceUiDefaults.ICON_MED, SourceUiDefaults.PAD_RIGHT)

func source_consume_liquids_dynamic_update_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.update_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func generated_consume_liquids_dynamic_update_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.generated_update_bridge_state(liquid_ids, liquid_stack_amounts, build_edelta, multiplier_get_build)

func source_consume_liquids_dynamic_efficiency_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.efficiency_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build)

func generated_consume_liquids_dynamic_efficiency_bridge_state(liquid_ids: Array, liquid_stack_amounts: Array, liquid_amounts: Array, build_edelta: float, multiplier_get_build: float) -> Dictionary:
	return SourceConsumeLiquidsDynamicState.generated_efficiency_bridge_state(liquid_ids, liquid_stack_amounts, liquid_amounts, build_edelta, multiplier_get_build)

func source_consume_liquid_consumes_state(liquid_matches_self_liquid: bool) -> Dictionary:
	return SourceConsumeLiquidState.consumes_state(liquid_matches_self_liquid)

func generated_consume_liquid_consumes_bridge_state(liquid_matches_self_liquid: bool) -> Dictionary:
	return SourceConsumeLiquidState.generated_consumes_bridge_state(liquid_matches_self_liquid)

func source_consume_power_requested_power_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	return SourceConsumePowerState.requested_power_state(buffered, usage, capacity, power_status, should_consume)

func generated_consume_power_requested_power_bridge_state(buffered: bool, usage: float, capacity: float, power_status: float, should_consume: bool) -> Dictionary:
	return SourceConsumePowerState.generated_requested_power_bridge_state(buffered, usage, capacity, power_status, should_consume)

func source_power_graph_power_needed_state(consumers: Array) -> Dictionary:
	return SourcePowerGraphState.power_needed_state(consumers)

func source_power_graph_power_produced_state(producers: Array) -> Dictionary:
	return SourcePowerGraphState.power_produced_state(producers)

func source_power_graph_battery_state(batteries: Array) -> Dictionary:
	return SourcePowerGraphState.battery_state(batteries)

func source_power_graph_use_batteries_state(batteries: Array, needed: float) -> Dictionary:
	return SourcePowerGraphState.use_batteries_state(batteries, needed)

func source_power_graph_charge_batteries_state(batteries: Array, excess: float) -> Dictionary:
	return SourcePowerGraphState.charge_batteries_state(batteries, excess)

func source_power_graph_distribute_power_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	return SourcePowerGraphState.distribute_power_state(consumers, needed, produced, charged, last_power_stored)

func source_power_graph_update_cheat_state(consumers: Array) -> Dictionary:
	return SourcePowerGraphState.update_cheat_state(consumers)

func source_power_graph_update_balance_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = []) -> Dictionary:
	return SourcePowerGraphState.update_balance_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)

func source_power_graph_update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	return SourcePowerGraphState.update_battery_distribute_state(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)

func power_graph_role_for_block(block) -> Dictionary:
	return SourceBuildingPowerState.block_power_role_state(block)

func placed_power_graph_role_counts() -> Dictionary:
	return SourcePlacedPowerGraphState.role_counts_state(placed_block_origins, Callable(self, "block_from_sprite"), Callable(self, "power_graph_role_for_block"))

func placed_power_needed_state() -> Dictionary:
	return SourcePlacedPowerGraphState.needed_state(placed_block_origins, Callable(self, "block_from_sprite"), Callable(self, "power_graph_role_for_block"), SourceTimeDefaults.TICK_RATE)

func placed_power_produced_state() -> Dictionary:
	return SourcePlacedPowerGraphState.produced_state(placed_block_origins, Callable(self, "block_from_sprite"), Callable(self, "power_graph_role_for_block"), SourceTimeDefaults.TICK_RATE)

func placed_power_battery_state() -> Dictionary:
	return SourcePlacedPowerGraphState.battery_state(placed_block_origins, Callable(self, "block_from_sprite"), Callable(self, "power_graph_role_for_block"))

func placed_power_battery_runtime_state() -> Dictionary:
	var defaults := {
		"power_capacity": SourceBlockDefaults.SOURCE_BLOCK_POWER_CAPACITY_DEFAULT,
	}
	return SourcePlacedPowerBatteryRuntimeState.summary_state(
		placed_block_origins,
		SourcePlacedPowerBatteryRuntimeState.default_callbacks_state(self),
		defaults,
		SourceTimeDefaults.TICK_RATE
	)

func placed_power_distribution_runtime_state() -> Dictionary:
	var defaults := {
		"power_buffered": SourceBlockDefaults.SOURCE_BLOCK_POWER_BUFFERED_DEFAULT,
		"power_usage": SourceBlockDefaults.SOURCE_BLOCK_POWER_USAGE_DEFAULT,
		"power_capacity": SourceBlockDefaults.SOURCE_BLOCK_POWER_CAPACITY_DEFAULT,
		"power_production": SourceBlockDefaults.SOURCE_BLOCK_POWER_PRODUCTION_DEFAULT,
	}
	return SourcePlacedPowerDistributionRuntimeState.summary_state(
		placed_block_origins,
		SourcePlacedPowerDistributionRuntimeState.default_callbacks_state(self),
		defaults,
		SourceTimeDefaults.TICK_RATE
	)

func placed_power_runtime_state() -> Dictionary:
	return SourcePlacedPowerGraphState.runtime_state(placed_block_origins, Callable(self, "block_from_sprite"), Callable(self, "power_graph_role_for_block"), SourceTimeDefaults.TICK_RATE)

func place_selected_block_at_mouse() -> void:
	place_selected_block_at_world(get_global_mouse_position())

func place_selected_block_at_cell(x: int, y: int) -> bool:
	return place_selected_block_at_world(grid_to_world(Vector2i(x, y)))

func place_selected_block_at_world(world_pos: Vector2) -> bool:
	return SourceBlockPlacement.place_selected_block_at_world(self, world_pos, SourcePlayableScenarioDefaults.WORLD_SIZE)

func add_source_block(parent: Node, block_id: String, cell: Vector2i) -> void:
	SourceBlockPlacement.add_source_block(self, parent, block_id, cell)

func occupied_cells(cell: Vector2i, block) -> Array[Vector2i]:
	return SourceBlockFootprint.occupied_cells(cell, block_size(block))

func can_place_block_at_cell(block, cell: Vector2i) -> bool:
	var state := SourceBlockPlacement.can_place_state(occupied_cells(cell, block), placed_blocks, SourcePlayableScenarioDefaults.WORLD_SIZE)
	return bool(state.get("can_place", false))

func record_placed_block(sprite: Sprite2D, block, cell: Vector2i) -> void:
	var cell_keys: Array[String] = SourceBlockPlacement.record_cells(placed_block_origins, placed_blocks, cell, occupied_cells(cell, block), sprite)
	SourcePlacedBlockState.initialize_sprite(sprite, block, cell, cell_keys, SourceBlockMetadataState.SOURCE_BLOCK_HEALTH_DEFAULT, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func block_sprite_at_cell(cell: Vector2i):
	return placed_blocks.get(cell_key(cell))

func block_from_sprite(sprite):
	if content_catalog == null or not is_instance_valid(sprite):
		return null
	return content_catalog.get_by_id(str(sprite.get_meta("source_block_id", "")))

func source_block_health_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourcePlacedBlockState.health(sprite)

func source_block_time_scale_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourcePlacedBlockState.time_scale(sprite, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func source_block_time_scale_duration_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourcePlacedBlockState.time_scale_duration(sprite)

func decay_block_time_scale_sprite(sprite, source_delta: float) -> void:
	if not is_instance_valid(sprite):
		return
	var result := source_building_time_scale_decay_state(float(sprite.get_meta("source_block_time_scale", SourceBlockDefaults.TIME_SCALE_DEFAULT)), float(sprite.get_meta("source_block_time_scale_duration", 0.0)), source_delta)
	SourcePlacedBlockState.apply_time_scale_decay(sprite, result, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func simulate_block_time_scales(delta: float) -> void:
	var source_delta := delta * SourceTimeDefaults.TICK_RATE
	for key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(key)
		decay_block_time_scale_sprite(sprite, source_delta)

func step_block_time_scales(seconds: float) -> Dictionary:
	simulate_block_time_scales(seconds)
	return {
		"last_overdrive_projector_boosted_block_id": last_overdrive_projector_boosted_block_id,
		"last_overdrive_projector_boosted_cell": {"x": last_overdrive_projector_boosted_cell.x, "y": last_overdrive_projector_boosted_cell.y},
		"time_scale": source_block_time_scale_at_cell(last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y),
		"time_scale_duration": source_block_time_scale_duration_at_cell(last_overdrive_projector_boosted_cell.x, last_overdrive_projector_boosted_cell.y),
	}

func damage_block_at_cell(x: int, y: int, amount: float) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	sprite.set_meta("source_block_health", max(0.0, float(sprite.get_meta("source_block_health", 0.0)) - amount))
	return float(sprite.get_meta("source_block_health", 0.0))

func repair_block_sprite(sprite, amount: float) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	var before := float(sprite.get_meta("source_block_health", 0.0))
	var after: float = min(float(sprite.get_meta("source_block_max_health", 0.0)), before + amount)
	sprite.set_meta("source_block_health", after)
	return after - before

func boost_mend_projector_at_cell(x: int, y: int) -> bool:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_mend_projector(block):
		return false
	var boost_input := SourceProjectorBoostState.boost_input(sprite, block)
	var item_id := str(boost_input.get("item_id", ""))
	if not bool(boost_input.get("has_booster_item", false)) or core_item_count(item_id) <= 0:
		return false
	SourceProjectorBoostState.apply_boost_stock(core_items, mend_projector_booster_items, mend_projector_optional_efficiency, boost_input)
	return true

func mend_projector_phase_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceMendProjectorState.state_value(sprite, mend_projector_phase_heat, 0.0)

func mend_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceMendProjectorState.state_value(sprite, mend_projector_smooth_efficiency, 0.0)

func mend_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_mend_projector(block):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return source_mend_projector_light_state(block, mend_projector_smooth_efficiency_at_cell(x, y))

func mend_projector_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceMendProjectorState.state_value(sprite, mend_projector_heat, 0.0)

func mend_projector_charge_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceMendProjectorState.state_value(sprite, mend_projector_charges, 0.0)

func mend_projector_progress_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_mend_projector(block):
		return 0.0
	return source_mend_projector_progress(block, mend_projector_charge_at_cell(x, y))

func mend_projector_select_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_mend_projector(block):
		return {"range": 0.0, "color": ""}
	return source_mend_projector_select_state(block, mend_projector_phase_heat_at_cell(x, y))
func mend_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_mend_projector(block):
		return source_mend_projector_draw_state(null, 0.0, 0.0, source_time_ticks, false, 0.0)
	return source_mend_projector_draw_state(block, mend_projector_heat_at_cell(x, y), mend_projector_phase_heat_at_cell(x, y), source_time_ticks)

func mend_projector_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var mend_state := SourceMendProjectorState.capture_state(sprite, mend_projector_heat, mend_projector_smooth_efficiency, mend_projector_phase_heat, mend_projector_charges)
	var block = block_from_sprite(sprite)
	mend_state["progress"] = source_mend_projector_progress(block, float(mend_state.get("charge", 0.0))) if SourceSelectedBuildState.is_mend_projector(block) else 0.0
	return mend_state

func boost_overdrive_projector_at_cell(x: int, y: int) -> bool:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_overdrive_projector(block):
		return false
	var boost_input := SourceProjectorBoostState.boost_input(sprite, block)
	var item_id := str(boost_input.get("item_id", ""))
	if not bool(boost_input.get("has_booster_item", false)) or core_item_count(item_id) <= 0:
		return false
	SourceProjectorBoostState.apply_boost_stock(core_items, overdrive_projector_booster_items, overdrive_projector_optional_efficiency, boost_input)
	return true

func overdrive_projector_phase_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceOverdriveProjectorState.state_value(sprite, overdrive_projector_phase_heat, 0.0)

func overdrive_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceOverdriveProjectorState.state_value(sprite, overdrive_projector_smooth_efficiency, 0.0)

func overdrive_projector_heat_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceOverdriveProjectorState.state_value(sprite, overdrive_projector_heat, 0.0)

func overdrive_projector_charge_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceOverdriveProjectorState.state_value(sprite, overdrive_projector_charges, 0.0)

func overdrive_projector_use_progress_at_cell(x: int, y: int) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceOverdriveProjectorState.state_value(sprite, overdrive_projector_use_progress, 0.0)

func overdrive_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_overdrive_projector(block):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return source_overdrive_projector_light_state(block, overdrive_projector_smooth_efficiency_at_cell(x, y))

func overdrive_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	var block = block_from_sprite(sprite)
	if not SourceSelectedBuildState.is_overdrive_projector(block):
		return source_overdrive_projector_draw_state(null, 0.0, 0.0, source_time_ticks, false, 0.0)
	return source_overdrive_projector_draw_state(block, overdrive_projector_heat_at_cell(x, y), overdrive_projector_phase_heat_at_cell(x, y), source_time_ticks)

func overdrive_projector_state_at_cell(x: int, y: int) -> Dictionary:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	return SourceOverdriveProjectorState.capture_state(sprite, overdrive_projector_heat, overdrive_projector_smooth_efficiency, overdrive_projector_phase_heat, overdrive_projector_charges, overdrive_projector_use_progress)

func block_size(block) -> int:
	return SourceBlockMetadataState.block_size(block)

func source_block_health(block_id: String) -> float:
	return SourceBlockMetadataState.block_health(block_id, content_catalog)

func source_block_item_capacity(block_id: String) -> int:
	return SourceBlockMetadataState.block_item_capacity(block_id, content_catalog)

func source_block_dump_time(block_id: String) -> float:
	return SourceBlockMetadataState.block_dump_time(block_id, content_catalog)

func source_drill_dump_interval(block_id: String, time_scale := 1.0) -> float:
	return SourceDrillDumpRuntimeState.dump_interval(block_id, time_scale, SourceDrillDumpRuntimeState.default_callbacks_state(self).get("block_dump_time", Callable()))

func source_drill_ore_count(block_id: String, cell: Vector2i, item_id: String) -> int:
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(self)
	return SourceDrillRuntimeState.ore_count(block_id, cell, item_id, content_catalog, ore_items_by_cell, callbacks.get("occupied_cells", Callable()), callbacks.get("cell_key", Callable()))

func source_drill_delay(block_id: String, item_id: String) -> float:
	return SourceDrillRuntimeState.drill_delay(block_id, item_id, content_catalog, SourceFactoryDefaults.DRILL_HARDNESS_MULTIPLIER)

func generated_drill_get_drill_time_bridge_state(block_id: String, item_id: String) -> Dictionary:
	return SourceDrillRuntimeState.generated_get_drill_time_bridge_state(block_id, item_id, content_catalog, SourceFactoryDefaults.DRILL_HARDNESS_MULTIPLIER)

func source_drill_output_rate(block_id: String, item_id: String, return_count: int) -> float:
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(self)
	return SourceDrillRuntimeState.output_rate(block_id, item_id, return_count, SourceTimeDefaults.TICK_RATE, callbacks.get("delay", Callable()))

func source_drill_warmup_speed(block_id: String) -> float:
	return SourceBlockMetadataState.block_warmup_speed(block_id, content_catalog)

func source_drill_warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float) -> float:
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(self)
	return SourceDrillRuntimeState.warmup_state(current_warmup, speed, warmup_speed, source_delta, callbacks.get("approach_delta", Callable()))

func source_drill_inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float) -> float:
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(self)
	return SourceDrillRuntimeState.inactive_warmup_state(current_warmup, warmup_speed, source_delta, callbacks.get("approach_delta", Callable()))

func drill_warmup_at_cell(x: int, y: int) -> float:
	return float(drill_warmups.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_warmup_at_cell(x: int, y: int, warmup: float) -> void:
	drill_warmups[cell_key(Vector2i(x, y))] = warmup

func source_drill_last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed := 1.0) -> float:
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(self)
	return SourceDrillRuntimeState.last_speed(block_id, item_id, ore_count, warmup, speed, callbacks.get("delay", Callable()))

func source_drill_last_speed_for_cell(x: int, y: int, item_id: String, dominant_items: int, warmup: float, speed := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_drill_last_speed(str(sprite.get_meta("source_block_id", "")), item_id, dominant_items, warmup, speed)

func drill_last_speed_at_cell(x: int, y: int) -> float:
	return float(drill_last_speeds.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_last_speed_at_cell(x: int, y: int, value: float) -> void:
	drill_last_speeds[cell_key(Vector2i(x, y))] = value

func source_drill_time_drilled_delta(warmup: float, seconds: float, time_scale := 1.0) -> float:
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(self)
	return SourceDrillRuntimeState.time_drilled_delta(warmup, seconds, time_scale, SourceTimeDefaults.TICK_RATE, callbacks.get("building_delta", Callable()))

func drill_time_drilled_at_cell(x: int, y: int) -> float:
	return float(drill_time_drilled.get(cell_key(Vector2i(x, y)), 0.0))

func set_drill_time_drilled_at_cell(x: int, y: int, value: float) -> void:
	drill_time_drilled[cell_key(Vector2i(x, y))] = value

func step_drill_time_drilled_cell(x: int, y: int, seconds: float, warmup: float) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var key := cell_key(Vector2i(x, y))
	var value := float(drill_time_drilled.get(key, 0.0)) + source_drill_time_drilled_delta(warmup, seconds, float(sprite.get_meta("source_block_time_scale", SourceBlockDefaults.TIME_SCALE_DEFAULT)))
	drill_time_drilled[key] = value
	return value

func step_drill_warmup_cell(x: int, y: int, seconds: float, speed := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	var key := cell_key(Vector2i(x, y))
	var source_delta := seconds * SourceTimeDefaults.TICK_RATE
	var warmup := source_drill_warmup_state(float(drill_warmups.get(key, 0.0)), speed, source_drill_warmup_speed(str(sprite.get_meta("source_block_id", ""))), source_delta)
	drill_warmups[key] = warmup
	return warmup

func source_drill_output_delta(dominant_items: int, seconds: float, time_scale := 1.0, warmup := 1.0, speed := 1.0) -> float:
	var callbacks := SourceDrillRuntimeState.default_callbacks_state(self)
	return SourceDrillRuntimeState.output_delta(dominant_items, seconds, time_scale, warmup, speed, SourceTimeDefaults.TICK_RATE, callbacks.get("building_delta", Callable()))

func source_drill_output_delta_for_cell(x: int, y: int, dominant_items: int, seconds: float, warmup := 1.0, speed := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_drill_output_delta(dominant_items, seconds, float(sprite.get_meta("source_block_time_scale", SourceBlockDefaults.TIME_SCALE_DEFAULT)), warmup, speed)

func source_drill_output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	return SourceDrillProductionRuntimeState.output_batch(progress, delay, dominant_items, items_total, item_capacity)

func source_drill_progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	return SourceDrillProductionRuntimeState.progress_fraction(progress, delay, has_dominant_item)

func source_conveyor_world_speed(block_id: String) -> float:
	return SourceConveyorRuntimeState.world_speed(block_id, tile_size, content_catalog)

func source_conveyor_path_progress_rate(block_id: String) -> float:
	return SourceConveyorRuntimeState.path_progress_rate(block_id, path_points.size(), tile_size, content_catalog)

func source_conveyor_path_progress_delta(block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:
	var callbacks := SourceConveyorRuntimeState.default_callbacks_state(self)
	return SourceConveyorRuntimeState.path_progress_delta(block_id, seconds, path_points.size(), tile_size, SourceTimeDefaults.TICK_RATE, content_catalog, time_scale, efficiency, callbacks.get("edelta_provider", Callable()))

func source_conveyor_path_progress_delta_for_cell(x: int, y: int, seconds: float, efficiency := 1.0) -> float:
	var sprite = block_sprite_at_cell(Vector2i(x, y))
	if not is_instance_valid(sprite):
		return 0.0
	return source_conveyor_path_progress_delta(str(sprite.get_meta("source_block_id", "")), seconds, float(sprite.get_meta("source_block_time_scale", SourceBlockDefaults.TIME_SCALE_DEFAULT)), efficiency)

func block_world_size(block) -> float:
	return SourceBlockGeometry.block_world_size(block_size(block), tile_size)

func source_block_sprite_base_position(block, cell: Vector2i) -> Vector2:
	return SourceBlockGeometry.block_base_position(grid_to_world(cell), block_size(block), tile_size)

func configure_block_sprite(sprite: Sprite2D, block, cell: Vector2i) -> void:
	sprite.texture = block_texture(block)
	sprite.position = source_block_sprite_base_position(block, cell)
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = SourceBlockGeometry.block_sprite_scale(size, block_size(block), tile_size)

func register_turret_cell(cell: Vector2i, block) -> void:
	if block == null or not block.is_turret():
		return
	var key := cell_key(cell)
	if not turret_cooldowns.has(key):
		turret_cells.append(cell)
	turret_cooldowns[key] = 0.0
	if not turret_ammo_stacks.has(key):
		turret_ammo_stacks[key] = []
	if not turret_total_ammo.has(key):
		turret_total_ammo[key] = 0
	if not turret_barrel_counters.has(key):
		turret_barrel_counters[key] = 0
	if not turret_rotations.has(key):
		turret_rotations[key] = 0.0
	if not turret_recoils.has(key):
		turret_recoils[key] = 0.0

func unregister_turret_cell(cell: Vector2i) -> void:
	var key := cell_key(cell)
	if not turret_cooldowns.has(key):
		return
	turret_cooldowns.erase(key)
	turret_barrel_counters.erase(key)
	turret_rotations.erase(key)
	turret_recoils.erase(key)
	var kept: Array = []
	for existing in turret_cells:
		if cell_key(existing) != key:
			kept.append(existing)
	turret_cells = kept
	turret_ammo_stacks.erase(key)
	turret_total_ammo.erase(key)

func block_texture(block) -> Texture2D:
	if block_texture_cache.has(block.id):
		return block_texture_cache[block.id]
	var texture := load_png_texture(block.texture_path)
	block_texture_cache[block.id] = texture
	return texture

func source_bullet_texture(sprite_id: String) -> Texture2D:
	var resolved_sprite := sprite_id if sprite_id != "" else SourceBulletRuntimeState.SOURCE_BULLET_TEXTURE_DEFAULT
	var path := "%s/%s.png" % [SourceBulletRuntimeState.SOURCE_BULLET_TEXTURE_ASSET_ROOT, resolved_sprite]
	return load_png_texture(path)

func can_afford(block) -> bool:
	sync_copper_inventory_alias()
	var callbacks := SourceBlockRequirementsState.default_callbacks_state(self)
	var state := SourceBlockRequirementsState.can_afford_state(SourceBlockRequirementsState.block_requirements(block), rules_build_cost_multiplier, callbacks.get("core_item_count", Callable()))
	return bool(state.get("can_afford", false))

func spend_requirements(block) -> void:
	sync_copper_inventory_alias()
	var callbacks := SourceBlockRequirementsState.default_callbacks_state(self)
	var state := SourceBlockRequirementsState.spend_requirements_state(SourceBlockRequirementsState.block_requirements(block), rules_build_cost_multiplier, callbacks.get("core_item_count", Callable()))
	for spend_call in state.get("spend_calls", []):
		set_core_item_count(str(spend_call.get("item_id", "")), int(spend_call.get("next_amount", 0)))

func playable_core_item_id() -> String:
	return SourcePlayableScenarioDefaults.ITEM_COPPER

func playable_core_item_name() -> String:
	var core_item = content_catalog.get_by_id(playable_core_item_id()) if content_catalog else null
	return core_item.display_name() if core_item else SourcePlayableScenarioDefaults.ITEM_COPPER.capitalize()

func sync_copper_inventory_alias() -> void:
	var state := SourceCoreInventoryRuntimeState.sync_copper_inventory_alias_state(core_items, core_inventory, playable_core_item_id(), core_item_capacity)
	var next_items: Dictionary = state.get("core_items", core_items)
	core_items = next_items.duplicate(true)
	core_inventory = int(state.get("core_inventory", core_inventory))

func clamp_core_item_amount(amount: int) -> int:
	return SourceCoreInventoryRuntimeState.clamp_item_amount(amount, core_item_capacity)

func set_core_item_count(item_id: String, amount: int) -> void:
	var state := SourceCoreInventoryRuntimeState.set_item_count_state(core_items, item_id, amount, core_item_capacity, playable_core_item_id(), core_inventory)
	var next_items: Dictionary = state.get("core_items", core_items)
	core_items = next_items.duplicate(true)
	core_inventory = int(state.get("core_inventory", core_inventory))

func add_core_item(item_id: String, amount: int) -> void:
	var state := SourceCoreInventoryRuntimeState.add_item_state(core_items, item_id, amount, core_item_capacity, playable_core_item_id(), core_inventory)
	var next_items: Dictionary = state.get("core_items", core_items)
	core_items = next_items.duplicate(true)
	core_inventory = int(state.get("core_inventory", core_inventory))

func core_item_count(item_id: String) -> int:
	var state := SourceCoreInventoryRuntimeState.item_count_state(core_items, core_inventory, item_id, playable_core_item_id())
	var next_items: Dictionary = state.get("core_items", core_items)
	core_items = next_items.duplicate(true)
	return int(state.get("itemCount", 0))

func source_core_accept_item(item_id: String) -> bool:
	var state := SourceCoreInventoryRuntimeState.accept_item_state(core_incinerates, core_item_count(item_id), core_item_capacity, item_id)
	return bool(state.get("acceptItem", false))

func source_core_handle_item(item_id: String) -> bool:
	if not source_core_accept_item(item_id):
		return false
	var item_buildable := SourceItemMetadataState.item_buildable(item_id, content_catalog)
	var state := SourceCoreInventoryRuntimeState.handle_item_state(core_incinerate_non_buildable, item_buildable, core_item_count(item_id), core_item_capacity, source_core_accept_item(item_id), item_id)
	if bool(state.get("should_add", false)):
		add_core_item(item_id, 1)
	return bool(state.get("handled", false))

func source_building_handle_item_count(current_count: int) -> int:
	return current_count + 1

func source_building_accept_item_state(consumes_item: bool, item_count: int, maximum_accepted: int) -> bool:
	return SourceBuildingItemState.accept_item_state(consumes_item, item_count, maximum_accepted)

func source_building_maximum_accepted(block_item_capacity: int) -> int:
	return SourceBuildingItemState.maximum_accepted(block_item_capacity)

func source_building_handle_stack_count(current_count: int, amount: int) -> int:
	return SourceBuildingItemState.handle_stack_count(current_count, amount)

func source_building_accept_stack_state(accepts_item: bool, has_items: bool, same_team_or_null_source: bool, maximum_accepted: int, item_count: int, amount: int) -> int:
	return SourceBuildingItemState.accept_stack_state(accepts_item, has_items, same_team_or_null_source, maximum_accepted, item_count, amount)

func source_building_remove_stack_state(has_items_module: bool, item_count: int, amount: int) -> Dictionary:
	return SourceBuildingItemState.remove_stack_state(has_items_module, item_count, amount)

func source_building_accept_payload_state() -> bool:
	return SourceBuildingPayloadState.accept_payload_state()

func source_building_handle_payload_state(payload_state: Variant) -> Variant:
	return SourceBuildingPayloadState.handle_payload_state(payload_state)

func source_payload_forward_offset(payload_block_size: int) -> int:
	return SourceBuildingPayloadState.payload_forward_offset(payload_block_size)

func source_move_payload_state(has_next_tile: bool, has_next_build: bool, same_team: bool, accepts_payload: bool) -> bool:
	return SourceBuildingPayloadState.move_payload_state(has_next_tile, has_next_build, same_team, accepts_payload)

func source_dump_payload_index(loop_index: int, dump_cursor: int, proximity_size: int) -> int:
	return SourceBuildingPayloadState.dump_payload_index(loop_index, dump_cursor, proximity_size)

func source_dump_payload_state(proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array) -> Dictionary:
	return SourceBuildingPayloadState.dump_payload_state(proximity_size, dump_cursor, accepts_payload_by_index, SourceBuildingPayloadState.default_callbacks_state(self).get("increment_dump_cursor", Callable()))

func source_block_can_replace_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> bool:
	return SourceBuildingCoreState.block_can_replace_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)

func source_building_can_be_replaced_state(other_can_replace_block: bool) -> bool:
	return SourceBuildingCoreState.building_can_be_replaced_state(other_can_replace_block)

func source_building_should_consume_state(enabled_state: bool) -> Dictionary:
	return SourceBuildingCoreState.should_consume_state(enabled_state)

func source_building_production_valid_state() -> Dictionary:
	return SourceBuildingCoreState.production_valid_state()

func source_building_consume_trigger_valid_state() -> bool:
	return SourceBuildingCoreState.consume_trigger_valid_state()

func source_building_power_production_state() -> Dictionary:
	return SourceBuildingCoreState.power_production_state()

func source_building_progress_increase(base_time: float, edelta_value: float) -> float:
	return SourceBuildingTimeState.progress_increase(base_time, edelta_value)

func source_building_display_efficiency(edelta_value: float) -> float:
	return SourceBuildingTimeState.display_efficiency(edelta_value)

func generated_building_comp_get_progress_increase_bridge_state(base_time: float, edelta_value: float) -> Dictionary:
	return SourceBuildingTimeState.generated_get_progress_increase_bridge_state(base_time, edelta_value)

func generated_building_comp_get_display_efficiency_bridge_state(edelta_value: float) -> Dictionary:
	return SourceBuildingTimeState.generated_get_display_efficiency_bridge_state(edelta_value)

func generated_building_comp_should_ambient_sound_bridge_state(should_consume_state: bool) -> Dictionary:
	return SourceBuildingTimeState.generated_should_ambient_sound_bridge_state(should_consume_state)

func generated_building_comp_draw_status_bridge_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_status_bridge_state(enable_draw_status, consumers_length, block_size_value, source_x, source_y, source_tilesize)

func generated_building_comp_draw_cracks_bridge_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_cracks_bridge_state(draw_cracks, damaged_state, block_size_value, max_crack_size, health_fraction, crack_regions, position_id)

func generated_building_comp_draw_select_bridge_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_select_bridge_state(block_status, source_x, source_y, source_rotation, tile_x, tile_y, unit_activation_delay, state_tick)

func generated_building_comp_draw_item_selection_bridge_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_item_selection_bridge_state(has_selection, source_x, source_y, block_size_value, source_tilesize, icon_small, selection_icon_ratio)

func generated_building_comp_draw_disabled_bridge_state(source_x: float, source_y: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_disabled_bridge_state(source_x, source_y)

func generated_building_comp_draw_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_bridge_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func generated_building_comp_draw_cached_bridge_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_cached_bridge_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func generated_building_comp_recache_bridge_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	return SourceBuildingDrawState.generated_recache_bridge_state(headless, building_cache_layer, tile_state)

func generated_building_comp_payload_draw_bridge_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	return SourceBuildingDrawState.generated_payload_draw_bridge_state(draw_cached, draw_dynamic, current_z, building_cache_layer_z, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants)

func generated_building_comp_draw_team_top_bridge_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_team_top_bridge_state(team_region_found, team_region_matches_team, team_color, source_x, source_y)

func generated_building_comp_draw_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_light_bridge_state(has_liquids, draw_liquid_light, light_liquid_is_null, current_liquid_color, current_liquid_alpha, light_liquid_color, light_liquid_alpha, selected_liquid_amount, visual_liquid, source_delta, source_x, source_y, block_size_value)

func generated_building_comp_draw_liquid_light_bridge_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_liquid_light_bridge_state(source_x, source_y, block_size_value, light_color, light_alpha, amount)

func generated_building_comp_draw_team_bridge_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_team_bridge_state(team_color, source_x, source_y, block_size_value, source_tilesize)

func generated_building_comp_check_suppression_bridge_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	return SourceBuildingLifecycleState.generated_check_suppression_bridge_state(block_suppressable, source_time, heal_suppression_time, source_delta, source_x, source_y, block_size_value, source_tilesize, suppress_color)

func generated_building_comp_player_placed_bridge_state(config_state: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.generated_player_placed_bridge_state(config_state)

func generated_building_comp_placed_bridge_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	return SourceBuildingLifecycleState.generated_placed_bridge_state(net_client, consumes_power, outputs_power, has_power, connected_power, linked_to_self, source_pos)

func generated_building_comp_on_repaired_bridge_state(has_fog_radius: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_on_repaired_bridge_state(has_fog_radius)

func generated_building_comp_is_commandable_bridge_state(block_commandable: bool) -> Dictionary:
	return SourceBuildingInteractionState.generated_is_commandable_bridge_state(block_commandable)

func generated_building_comp_is_payload_bridge_state(tile_is_empty_tile: bool) -> Dictionary:
	return SourceBuildingInteractionState.generated_is_payload_bridge_state(tile_is_empty_tile)

func generated_building_comp_overwrote_bridge_state(previous_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.generated_overwrote_bridge_state(previous_state)

func generated_building_comp_on_removed_bridge_state(current_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.generated_on_removed_bridge_state(current_state)

func generated_building_comp_unit_on_bridge_state(unit_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.generated_unit_on_bridge_state(unit_state)

func generated_building_comp_unit_on_any_bridge_state(unit_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.generated_unit_on_any_bridge_state(unit_state)

func generated_building_comp_unit_removed_bridge_state(unit_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.generated_unit_removed_bridge_state(unit_state)

func generated_building_comp_puddle_on_bridge_state(puddle_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.generated_puddle_on_bridge_state(puddle_state)

func generated_building_comp_configured_type_bridge_state(value_state: Dictionary) -> Dictionary:
	return SourceBuildingConfigureState.generated_configured_type_bridge_state(value_state)

func generated_building_comp_update_last_access_bridge_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	return SourceBuildingConfigureState.generated_update_last_access_bridge_state(builder_state, current_last_accessed)

func generated_building_comp_tapped_bridge_state(current_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.generated_tapped_bridge_state(current_state)

func generated_building_comp_after_destroyed_bridge_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	return SourceBuildingDestructionState.generated_after_destroyed_bridge_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id)

func generated_building_comp_explosion_item_cap_bridge_state(item_capacity: int) -> Dictionary:
	return SourceBuildingDestructionState.generated_explosion_item_cap_bridge_state(item_capacity)

func generated_building_comp_splash_liquid_bridge_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_splash_liquid_bridge_state(liquid, amount, source_block_size, source_tilesize)

func generated_building_comp_splash_liquid_source_tilesize_default_bridge_state(liquid: Variant, amount: float, source_block_size: int) -> Dictionary:
	return SourceBuildingDestructionState.generated_splash_liquid_source_tilesize_default_bridge_state(liquid, amount, source_block_size)

func generated_building_comp_splash_liquid_source_block_size_default_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_splash_liquid_source_block_size_default_bridge_state(liquid, amount)

func generated_building_comp_on_deconstructed_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_deconstructed_bridge_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)

func generated_building_comp_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid)

func generated_building_comp_on_destroyed_item_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_item_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap)

func generated_building_comp_on_destroyed_liquid_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_liquid_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states)

func generated_building_comp_on_destroyed_buffered_power_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_buffered_power_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity)

func generated_building_comp_on_destroyed_splash_liquid_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_splash_liquid_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions)

func generated_building_comp_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake)

func generated_building_comp_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale)

func generated_building_comp_on_destroyed_source_block_size_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_source_block_size_default_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize)

func generated_building_comp_on_destroyed_rubble_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_rubble_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid)

func generated_building_comp_on_destroyed_base_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_base_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func generated_building_comp_on_destroyed_reactive_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_reactive_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func generated_building_comp_on_destroyed_power_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_on_destroyed_power_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func generated_building_comp_play_destroy_sound_bridge_state(destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return SourceBuildingDestructionState.generated_play_destroy_sound_bridge_state(destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func generated_building_comp_get_display_name_bridge_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> Dictionary:
	return SourceBuildingDisplayState.generated_building_comp_get_display_name_bridge_state(localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label)

func generated_building_comp_flow_items_bridge_state(items_module: Variant) -> Dictionary:
	return SourceBuildingDisplayState.generated_building_comp_flow_items_bridge_state(items_module)

func generated_building_comp_display_consumption_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	return SourceBuildingDisplayState.generated_building_comp_display_consumption_bridge_state(consumers, self_state)

func generated_building_comp_display_bars_bridge_state(bar_results: Array) -> Dictionary:
	return SourceBuildingDisplayState.generated_building_comp_display_bars_bridge_state(bar_results)

func generated_building_comp_get_cursor_bridge_state(block_configurable: bool, interactable_player_team: bool) -> Dictionary:
	return SourceBuildingMetaState.generated_cursor_bridge_state(block_configurable, interactable_player_team)

func generated_building_comp_on_configure_tapped_bridge_state(x: float, y: float) -> Dictionary:
	return SourceBuildingConfigureState.generated_on_configure_tapped_bridge_state(x, y)

func generated_building_comp_on_configure_closed_bridge_state() -> Dictionary:
	return SourceBuildingConfigureState.generated_on_configure_closed_bridge_state()

func generated_building_comp_should_show_configure_bridge_state(player: Variant) -> Dictionary:
	return SourceBuildingConfigureState.generated_should_show_configure_bridge_state(player)

func generated_building_comp_should_hide_configure_bridge_state(player: Variant) -> Dictionary:
	return SourceBuildingConfigureState.generated_should_hide_configure_bridge_state(player)

func generated_building_comp_draw_configure_bridge_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_configure_bridge_state(source_x, source_y, block_size_value, source_tilesize)

func generated_building_comp_draw_configure_source_tilesize_default_bridge_state(source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	return SourceBuildingDrawState.generated_draw_configure_source_tilesize_default_bridge_state(source_x, source_y, block_size_value)

func generated_building_comp_check_solid_bridge_state() -> Dictionary:
	return SourceBuildingCoreState.generated_check_solid_bridge_state()

func generated_building_comp_handle_damage_bridge_state(amount: float) -> Dictionary:
	return SourceBuildingDamageState.generated_handle_damage_bridge_state(amount)

func generated_building_comp_absorb_lasers_bridge_state(block_absorb_lasers: bool) -> Dictionary:
	return SourceBuildingCoreState.generated_absorb_lasers_bridge_state(block_absorb_lasers)

func generated_building_comp_is_insulated_bridge_state(block_insulated: bool) -> Dictionary:
	return SourceBuildingCoreState.generated_is_insulated_bridge_state(block_insulated)

func generated_building_comp_collide_bridge_state(other: Variant) -> Dictionary:
	return SourceBuildingCoreState.generated_collide_bridge_state(other)

func generated_building_comp_collision_bridge_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	return SourceBuildingDamageState.generated_collision_bridge_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)

func generated_building_comp_damage_delegate_bridge_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return SourceBuildingDamageState.generated_damage_delegate_bridge_state(source_team, damage_amount)

func generated_building_comp_bullet_damage_bridge_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return SourceBuildingDamageState.generated_bullet_damage_bridge_state(bullet, source_team, damage_amount)

func generated_building_comp_change_team_delegate_bridge_state(next_team: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.generated_change_team_delegate_bridge_state(next_team)

func generated_building_comp_change_team_initial_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_change_team_initial_bridge_state(current_team, next_team, force_team, was_valid)

func generated_building_comp_change_team_power_proximity_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.generated_change_team_power_proximity_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph)

func generated_building_comp_change_team_power_links_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	return SourceBuildingLifecycleState.generated_change_team_power_links_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count)

func generated_building_comp_change_team_final_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	return SourceBuildingLifecycleState.generated_change_team_final_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count)

func generated_building_comp_can_pickup_bridge_state(block_can_pickup: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_can_pickup_bridge_state(block_can_pickup)

func generated_building_comp_picked_up_bridge_state(previous_state: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.generated_picked_up_bridge_state(previous_state)

func generated_building_comp_after_picked_up_bridge_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return SourceBuildingLifecycleState.generated_after_picked_up_bridge_state(power_present, has_cons_power, cons_power_buffered, current_status)

func generated_building_comp_remove_from_proximity_bridge_state(nearby_count: int, removable_count: int) -> Dictionary:
	return SourceBuildingLifecycleState.generated_remove_from_proximity_bridge_state(nearby_count, removable_count)

func generated_building_comp_update_proximity_bridge_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_update_proximity_bridge_state(nearby_count, same_team_count, headless, draw_cached)

func generated_building_comp_on_nearby_build_added_bridge_state(other_state: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.generated_on_nearby_build_added_bridge_state(other_state)

func generated_building_comp_consume_bridge_state(consumers: Array, self_state: Variant) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_consume_bridge_state(consumers, self_state)

func generated_building_comp_can_consume_bridge_state(potential_efficiency: float) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_can_consume_bridge_state(potential_efficiency)

func generated_building_comp_delta_bridge_state(source_delta: float, time_scale: float) -> Dictionary:
	return SourceBuildingTimeState.generated_delta_bridge_state(source_delta, time_scale)

func generated_building_comp_edelta_bridge_state(source_delta: float, time_scale: float, efficiency: float) -> Dictionary:
	return SourceBuildingTimeState.generated_edelta_bridge_state(source_delta, time_scale, efficiency)

func generated_building_comp_update_efficiency_multiplier_bridge_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_efficiency_multiplier_bridge_state(efficiency, optional_efficiency, efficiency_scale)

func generated_building_comp_efficiency_scale_bridge_state() -> Dictionary:
	return SourceBuildingEfficiencyState.generated_efficiency_scale_bridge_state()

func generated_building_comp_update_consumption_initial_bridge_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_initial_bridge_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)

func generated_building_comp_update_consumption_disabled_bridge_state(enabled_state: bool) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_disabled_bridge_state(enabled_state)

func generated_building_comp_update_consumption_setup_bridge_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_setup_bridge_state(should_consume_state, production_valid)

func generated_building_comp_update_consumption_non_optional_bridge_state(non_optional_consumer_results: Array) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_non_optional_bridge_state(non_optional_consumer_results)

func generated_building_comp_update_consumption_optional_bridge_state(optional_consumer_results: Array) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_optional_bridge_state(optional_consumer_results)

func generated_building_comp_update_consumption_efficiency_bridge_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_efficiency_bridge_state(min_efficiency, optional_efficiency, update)

func generated_building_comp_update_consumption_second_pass_bridge_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_second_pass_bridge_state(update, efficiency, update_consumers, self_state)

func generated_building_comp_ambient_volume_bridge_state(efficiency: float) -> Dictionary:
	return SourceBuildingEfficiencyState.generated_ambient_volume_bridge_state(efficiency)

func generated_building_comp_config_default_bridge_state() -> Dictionary:
	return SourceBuildingLifecycleState.generated_config_default_bridge_state()

func generated_building_comp_is_valid_bridge_state(tile_build_matches_self: bool, dead_state: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_is_valid_bridge_state(tile_build_matches_self, dead_state)

func generated_building_comp_heal_bridge_state(amount: Variant = null) -> Dictionary:
	return SourceBuildingLifecycleState.generated_heal_bridge_state(amount)

func generated_building_comp_hit_size_bridge_state(block_size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBlockGeometry.generated_building_hit_size_bridge_state(block_size_value, source_tilesize)

func generated_building_comp_kill_bridge_state(self_state := {}) -> Dictionary:
	return SourceBuildingLifecycleState.generated_kill_bridge_state(self_state)

func generated_building_comp_damage_dead_guard_bridge_state(damage_amount: float, dead_state: bool) -> Dictionary:
	return SourceBuildingDamageState.generated_damage_dead_guard_bridge_state(damage_amount, dead_state)

func generated_building_comp_damage_block_health_scale_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	return SourceBuildingDamageState.generated_damage_block_health_scale_bridge_state(damage_amount, health, block_health_multiplier, source_time)

func generated_building_comp_damage_handle_damage_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	return SourceBuildingDamageState.generated_damage_handle_damage_gate_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage)

func generated_building_comp_damage_health_changed_call_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	return SourceBuildingDamageState.generated_damage_health_changed_call_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage)

func generated_building_comp_damage_destroy_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float, self_state := {}) -> Dictionary:
	return SourceBuildingDamageState.generated_damage_destroy_gate_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage, self_state)

func generated_building_comp_health_changed_bridge_state(net_server: bool, self_state := {}) -> Dictionary:
	return SourceBuildingMetaState.generated_health_changed_bridge_state(net_server, self_state)

func generated_building_comp_sense_position_bridge_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_position_bridge_state(world_x, world_y, source_tilesize)

func generated_building_comp_sense_health_process_bridge_state(world_x: float, world_y: float, health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_health_process_bridge_state(world_x, world_y, health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)

func generated_building_comp_sense_totals_bridge_state(world_x: float, world_y: float, total_items: float, total_liquids: float, total_power: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_totals_bridge_state(world_x, world_y, total_items, total_liquids, total_power, source_tilesize)

func generated_building_comp_sense_capacity_power_net_bridge_state(world_x: float, world_y: float, block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_capacity_power_net_bridge_state(world_x, world_y, block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, source_tilesize)

func generated_building_comp_sense_enabled_controlled_bridge_state(world_x: float, world_y: float, enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_enabled_controlled_bridge_state(world_x, world_y, enabled_state, is_control_block, is_controlled, ctrl_player_value, source_tilesize)

func generated_building_comp_sense_payload_size_bridge_state(world_x: float, world_y: float, has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_payload_size_bridge_state(world_x, world_y, has_payload_seq, payload_seq_total, has_single_payload, block_size_value, source_tilesize)

func generated_building_comp_sense_camera_default_bridge_state(world_x: float, world_y: float, is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_camera_default_bridge_state(world_x, world_y, is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height, source_tilesize)

func generated_building_comp_sense_object_bridge_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_object_bridge_state(sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content)

func generated_building_comp_display_bridge_state(block_ui_icon: Variant, localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	return SourceBuildingDisplayState.generated_building_comp_display_bridge_state(block_ui_icon, localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label, block_category, block_display_flow, net_active, has_last_accessed)

func source_building_should_ambient_sound(should_consume_state: bool) -> Dictionary:
	return SourceBuildingTimeState.should_ambient_sound(should_consume_state)

func source_building_draw_status_state(enable_draw_status: bool, consumers_length: int, block_size_value: int, source_x: float, source_y: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingDrawState.draw_status_state(enable_draw_status, consumers_length, block_size_value, source_x, source_y, source_tilesize)

func source_building_draw_cracks_state(draw_cracks: bool, damaged_state: bool, block_size_value: int, max_crack_size: int, health_fraction: float, crack_regions: int, position_id: int) -> Dictionary:
	return SourceBuildingDrawState.draw_cracks_state(draw_cracks, damaged_state, block_size_value, max_crack_size, health_fraction, crack_regions, position_id)

func source_building_draw_select_state(block_status: String, source_x: float, source_y: float, source_rotation: float, tile_x: int, tile_y: int, unit_activation_delay: float, state_tick: float) -> Dictionary:
	return SourceBuildingDrawState.draw_select_state(block_status, source_x, source_y, source_rotation, tile_x, tile_y, unit_activation_delay, state_tick)

func source_building_draw_item_selection_state(has_selection: bool, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, icon_small: float, selection_icon_ratio: float) -> Dictionary:
	return SourceBuildingDrawState.draw_item_selection_state(has_selection, source_x, source_y, block_size_value, source_tilesize, icon_small, selection_icon_ratio)

func source_building_draw_disabled_state(source_x: float, source_y: float) -> Dictionary:
	return SourceBuildingDrawState.draw_disabled_state(source_x, source_y)

func source_building_drawrot_state(block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> float:
	return SourceBuildingDrawState.drawrot_state(block_rotate, block_rotate_draw, rotation_quadrants)

func source_arc_is_power_of_two(value: int) -> bool:
	return SourceMathState.is_power_of_two(value)

func source_arc_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:
	return SourceMathState.random_seed_int(source_seed, min_value, max_value)

func source_arc_random_seed_float_max(source_seed: int, max_value: float) -> float:
	return SourceMathState.random_seed_float_max(source_seed, max_value)

func source_arc_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return SourceMathState.source_arc_lerp_delta(from_value, to_value, progress, source_delta)

func source_arc_chance_delta_threshold(chance: float, source_delta: float) -> float:
	return SourceMathState.source_arc_chance_delta_threshold(chance, source_delta)

func source_arc_mathf_sin_table_value(index: int) -> float:
	return SourceMathState.source_arc_mathf_sin_table_value(index)

func source_arc_mathf_sin_lookup(radians: float) -> float:
	return SourceMathState.source_arc_mathf_sin_lookup(radians)

func source_arc_mathf_cos_lookup(radians: float) -> float:
	return SourceMathState.source_arc_mathf_cos_lookup(radians)

func source_arc_mathf_sin_scaled(radians: float, scl: float, mag: float) -> float:
	return SourceMathState.source_arc_mathf_sin_scaled(radians, scl, mag)

func source_arc_mathf_cos_scaled(radians: float, scl: float, mag: float) -> float:
	return SourceMathState.source_arc_mathf_cos_scaled(radians, scl, mag)

func source_arc_vec2_limit(vec: Vector2, limit: float) -> Vector2:
	return SourceMathState.source_arc_vec2_limit(vec, limit)

func source_building_draw_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var callbacks := SourceBuildingDrawState.default_callbacks_state(self)
	return SourceBuildingDrawState.draw_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants, callbacks.get("random_seed_int", Callable()))

func source_building_draw_cached_state(variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var callbacks := SourceBuildingDrawState.default_callbacks_state(self)
	return SourceBuildingDrawState.draw_cached_state(variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants, callbacks.get("random_seed_int", Callable()))

func source_building_recache_state(headless: bool, building_cache_layer: Variant, tile_state: Variant) -> Dictionary:
	return SourceBuildingDrawState.recache_state(headless, building_cache_layer, tile_state)

func source_building_payload_draw_state(draw_cached: bool, draw_dynamic: bool, current_z: float, building_cache_layer_z: float, variants: int, has_variant_regions: bool, variant_region_count: int, tile_pos: int, source_x: float, source_y: float, block_rotate: bool, block_rotate_draw: bool, rotation_quadrants: int) -> Dictionary:
	var callbacks := SourceBuildingDrawState.default_callbacks_state(self)
	return SourceBuildingDrawState.payload_draw_state(draw_cached, draw_dynamic, current_z, building_cache_layer_z, variants, has_variant_regions, variant_region_count, tile_pos, source_x, source_y, block_rotate, block_rotate_draw, rotation_quadrants, callbacks.get("random_seed_int", Callable()))

func source_building_draw_team_top_state(team_region_found: bool, team_region_matches_team: bool, team_color: String, source_x: float, source_y: float) -> Dictionary:
	return SourceBuildingDrawState.draw_team_top_state(team_region_found, team_region_matches_team, team_color, source_x, source_y)

func source_building_draw_liquid_light_state(source_x: float, source_y: float, block_size_value: int, light_color: String, light_alpha: float, amount: float) -> Dictionary:
	return SourceBuildingDrawState.draw_liquid_light_state(source_x, source_y, block_size_value, light_color, light_alpha, amount)

func source_building_draw_light_state(has_liquids: bool, draw_liquid_light: bool, light_liquid_is_null: bool, current_liquid_color: String, current_liquid_alpha: float, light_liquid_color: String, light_liquid_alpha: float, selected_liquid_amount: float, visual_liquid: float, source_delta: float, source_x: float, source_y: float, block_size_value: int) -> Dictionary:
	var callbacks := SourceBuildingDrawState.default_callbacks_state(self)
	return SourceBuildingDrawState.draw_light_state(has_liquids, draw_liquid_light, light_liquid_is_null, current_liquid_color, current_liquid_alpha, light_liquid_color, light_liquid_alpha, selected_liquid_amount, visual_liquid, source_delta, source_x, source_y, block_size_value, callbacks.get("lerp_delta", Callable()))

func source_building_draw_team_state(team_color: String, source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBuildingDrawState.draw_team_state(team_color, source_x, source_y, block_size_value, source_tilesize)

func source_building_is_heal_suppressed_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> bool:
	return SourceBuildingLifecycleState.is_heal_suppressed_state(block_suppressable, source_time, heal_suppression_time)

func source_building_check_suppression_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	var callbacks := SourceBuildingLifecycleState.default_callbacks_state(self)
	return SourceBuildingLifecycleState.check_suppression_state(block_suppressable, source_time, heal_suppression_time, source_delta, source_x, source_y, block_size_value, source_tilesize, suppress_color, callbacks.get("chance_delta_threshold", Callable()))

func source_building_player_placed_state(config_state: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.player_placed_state(config_state)

func source_building_placed_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	return SourceBuildingLifecycleState.placed_state(net_client, consumes_power, outputs_power, has_power, connected_power, linked_to_self, source_pos)

func source_building_on_repaired_state(has_fog_radius: bool) -> Dictionary:
	return SourceBuildingLifecycleState.on_repaired_state(has_fog_radius)

func source_building_is_commandable_state(block_commandable: bool) -> bool:
	return SourceBuildingInteractionState.is_commandable_state(block_commandable)

func source_building_is_payload_state(tile_is_empty_tile: bool) -> bool:
	return SourceBuildingInteractionState.is_payload_state(tile_is_empty_tile)

func source_building_overwrote_state(previous_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.overwrote_state(previous_state)

func source_building_on_removed_state(current_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.on_removed_state(current_state)

func source_building_unit_on_state(unit_state: Variant) -> Variant:
	return SourceBuildingInteractionState.unit_on_state(unit_state)

func source_building_unit_on_any_state(unit_state: Variant) -> Variant:
	return SourceBuildingInteractionState.unit_on_any_state(unit_state)

func source_building_unit_removed_state(unit_state: Variant) -> Variant:
	return SourceBuildingInteractionState.unit_removed_state(unit_state)

func source_building_puddle_on_state(puddle_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.puddle_on_state(puddle_state)

func source_building_configured_type_state(value_state: Dictionary) -> String:
	return SourceBuildingConfigureState.configured_type_state(value_state)

func source_building_configured_last_access_state(builder_state: Dictionary, current_last_accessed: String) -> Dictionary:
	return SourceBuildingConfigureState.configured_last_access_state(builder_state, current_last_accessed)

func source_building_configured_direct_handler_state(has_configuration: bool, configured_type: String, value_state: Variant) -> Dictionary:
	return SourceBuildingConfigureState.configured_direct_handler_state(has_configuration, configured_type, value_state)

func source_building_configured_copy_config_state(value_is_building: bool, copied_config: Variant, copied_config_is_building: bool) -> Dictionary:
	return SourceBuildingConfigureState.configured_copy_config_state(value_is_building, copied_config, copied_config_is_building)

func source_building_tapped_state(current_state: Variant) -> Dictionary:
	return SourceBuildingInteractionState.tapped_state(current_state)

func source_building_after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	var callbacks := SourceBuildingDestructionState.default_callbacks_state(self)
	return SourceBuildingDestructionState.after_destroyed_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id, callbacks.get("random_seed_float_max", Callable()))

func source_building_explosion_item_cap_state(item_capacity: int) -> int:
	return SourceBuildingDestructionState.explosion_item_cap_state(item_capacity)

func source_building_splash_liquid_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	return SourceBuildingDestructionState.splash_liquid_state(liquid, amount, source_block_size, source_tilesize)

func build_begin_break_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	return SourceBuildingDestructionState.begin_break_state(valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name)

func generated_build_begin_break_bridge_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	return SourceBuildingDestructionState.generated_build_begin_break_bridge_state(valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name)

func construct_block_deconstruct_finish_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	return SourceBuildingDestructionState.construct_block_deconstruct_finish_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)

func generated_construct_block_deconstruct_finish_bridge_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	return SourceBuildingDestructionState.generated_construct_block_deconstruct_finish_bridge_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)

func construct_block_construct_finish_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	return SourceBuildingDestructionState.construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)

func generated_construct_block_construct_finish_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	return SourceBuildingDestructionState.generated_construct_block_construct_finish_bridge_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)

func construct_block_constructed_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	return SourceBuildingDestructionState.construct_block_constructed_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)

func generated_construct_block_constructed_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	return SourceBuildingDestructionState.generated_construct_block_constructed_bridge_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)

func generated_construct_block_static_helpers_bridge_state(size: int, max_block_size: int, time_since_last_played_ms: int, current_millis: int, up: bool, time_since_last_time_ms: int, pitch_seq_before: int, random_pitch: float, headless: bool, visible_tile: bool) -> Dictionary:
	return SourceConstructBlockState.generated_construct_block_static_helpers_bridge_state(size, max_block_size, time_since_last_played_ms, current_millis, up, time_since_last_time_ms, pitch_seq_before, random_pitch, headless, visible_tile)

func construct_build_inner_runtime_state(current_solid: bool, previous_solid: bool, interactable_with_player_team: bool, current_is_placeable: bool, player_is_builder: bool, build_was_auto_paused: bool, input_is_building: bool, tile_x: int, tile_y: int, rotation_value: int, current_block: Variant, last_config: Variant, sensor: String, progress: float, active_deconstruct: bool, super_sense_value: float, super_sense_object_value: Variant, floor_solid: bool, floor_has_surface: bool, source_x: float, source_y: float, construct_build_block_size: int, current_is_air: bool, construct_color_before: float, source_delta: float) -> Dictionary:
	var callbacks := SourceConstructBuildState.default_callbacks_state(self)
	return SourceConstructBuildState.inner_runtime_state(current_solid, previous_solid, interactable_with_player_team, current_is_placeable, player_is_builder, build_was_auto_paused, input_is_building, tile_x, tile_y, rotation_value, current_block, last_config, sensor, progress, active_deconstruct, super_sense_value, super_sense_object_value, floor_solid, floor_has_surface, source_x, source_y, construct_build_block_size, current_is_air, construct_color_before, source_delta, callbacks.get("lerp_delta", Callable()))

func construct_build_set_construct_state(previous_block: Variant, block: Variant, build_cost_multiplier: float) -> Dictionary:
	return SourceConstructBuildState.set_construct_state(previous_block, block, build_cost_multiplier)

func construct_build_set_deconstruct_state(previous_block: Variant, build_cost_multiplier: float) -> Dictionary:
	return SourceConstructBuildState.set_deconstruct_state(previous_block, build_cost_multiplier)

func construct_build_check_required_state(requirements: Array, inventory: Dictionary, accumulator: Array, items_left: Array, amount: float, remove: bool, build_cost_multiplier: float, team_infinite_resources: bool, state_infinite_resources: bool) -> Dictionary:
	return SourceConstructBuildState.check_required_state(requirements, inventory, accumulator, items_left, amount, remove, build_cost_multiplier, team_infinite_resources, state_infinite_resources)

func construct_build_construct_state(previous_block: Variant, current_block: Variant, builder_state: Variant, construct_core_inventory: Dictionary, amount: float, construct_config: Variant, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, core_present: bool, team_infinite_resources: bool, state_infinite_resources: bool, builder_is_player: bool, last_builder_present: bool, net_client: bool, rotation_value: int) -> Dictionary:
	return SourceConstructBuildState.construct_state(previous_block, current_block, builder_state, construct_core_inventory, amount, construct_config, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, core_present, team_infinite_resources, state_infinite_resources, builder_is_player, last_builder_present, net_client, rotation_value)

func construct_build_deconstruct_state(current_block: Variant, builder_state: Variant, deconstruct_core_inventory: Dictionary, amount: float, progress_before: float, accumulator: Variant, total_accumulator: Variant, items_left: Variant, build_cost_multiplier: float, deconstruct_refund_multiplier: float, core_present: bool, state_infinite_resources: bool, builder_is_player: bool, was_constructing: bool, last_builder_present: bool, core_storage_capacity: int) -> Dictionary:
	return SourceConstructBuildState.deconstruct_state(current_block, builder_state, deconstruct_core_inventory, amount, progress_before, accumulator, total_accumulator, items_left, build_cost_multiplier, deconstruct_refund_multiplier, core_present, state_infinite_resources, builder_is_player, was_constructing, last_builder_present, core_storage_capacity)

func construct_build_progress_state(progress_value: float) -> Dictionary:
	return SourceConstructBuildState.progress_state(progress_value)

func construct_build_version_state() -> Dictionary:
	return SourceConstructBuildState.version_state()

func construct_build_write_state(write_progress_value: float, write_previous_block_id: int, write_current_block_id: int, write_accumulator: Variant, write_total_accumulator: Variant, write_items_left: Variant) -> Dictionary:
	return SourceConstructBuildState.write_state(write_progress_value, write_previous_block_id, write_current_block_id, write_accumulator, write_total_accumulator, write_items_left)

func construct_build_read_state(read_progress_value: float, read_previous_block_id: int, read_current_block_id: int, read_accumulator_size: int, read_accumulator_values: Array, read_total_accumulator_values: Array, read_items_left_values: Array, read_revision_value: int, read_content_blocks: Dictionary, read_air_block: Variant, read_build_cost_multiplier: float) -> Dictionary:
	return SourceConstructBuildState.read_state(read_progress_value, read_previous_block_id, read_current_block_id, read_accumulator_size, read_accumulator_values, read_total_accumulator_values, read_items_left_values, read_revision_value, read_content_blocks, read_air_block, read_build_cost_multiplier)

func construct_build_draw_state(current_block: Variant, previous_block: Variant, draw_air_block: Variant, source_x: float, source_y: float, draw_rotation_degrees: float, draw_progress_value: float, draw_construct_color: float, source_time: float) -> Dictionary:
	return SourceConstructBuildState.draw_state(current_block, previous_block, draw_air_block, source_x, source_y, draw_rotation_degrees, draw_progress_value, draw_construct_color, source_time)

func source_building_on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	return SourceBuildingDestructionState.on_deconstructed_liquid_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)

func source_building_on_destroyed_item_explosion_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)

func source_building_on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_liquid_explosion_state(current_explosiveness, current_flammability, has_liquids, liquid_states)

func source_building_on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_buffered_power_state(current_power, has_cons_power, cons_power_buffered, power_status, cons_power_capacity)

func source_building_on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)

func source_building_on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_dynamic_explosion_call_state(source_x, source_y, flammability, explosiveness, power, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)

func source_building_on_destroyed_rubble_state(source_x: float, source_y: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, source_block_size: int) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)

func source_building_on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func source_building_on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_reactive_sound_state(headless, explosiveness, flammability, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func source_building_on_destroyed_power_sound_state(headless: bool, power: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return SourceBuildingDestructionState.on_destroyed_power_sound_state(headless, power, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func source_building_display_name_state(localized_name: String, team_is_derelict: bool, team_is_player: bool, team_emoji: String, derelict_label: String) -> String:
	return SourceBuildingDisplayState.display_name_state(localized_name, team_is_derelict, team_is_player, team_emoji, derelict_label)

func source_building_display_icon_state(block_ui_icon: Variant) -> Variant:
	return SourceBuildingDisplayState.display_icon_state(block_ui_icon)

func source_building_flow_items_state(items_module: Variant) -> Variant:
	return SourceBuildingDisplayState.flow_items_state(items_module)

func source_building_display_consumption_state(consumers: Array, self_state: Variant) -> Dictionary:
	return SourceBuildingDisplayState.display_consumption_state(consumers, self_state)

func source_building_display_bars_state(bar_results: Array) -> Dictionary:
	return SourceBuildingDisplayState.display_bars_state(bar_results)

func source_building_display_ui_gates_state(team_is_player: bool, block_category: String, block_display_flow: bool, net_active: bool, has_last_accessed: bool) -> Dictionary:
	return SourceBuildingDisplayState.display_ui_gates_state(team_is_player, block_category, block_display_flow, net_active, has_last_accessed)

func source_arc_strings_fixed_one_decimal(value: float) -> String:
	var negative: bool = value < 0.0
	var abs_value: float = absf(value)
	var scaled: int = int(floor(abs_value * 10.0 + 0.0001))
	var whole: int = int(float(scaled) / 10.0)
	var decimal: int = scaled % 10
	var prefix: String = "-" if negative else ""
	return prefix + str(whole) + "." + str(decimal)

func source_building_display_flow_rate_label(flow_rate: float, per_second_label: String) -> String:
	var callbacks := SourceBuildingDisplayState.default_callbacks_state(self)
	return SourceBuildingDisplayState.display_flow_rate_label(flow_rate, per_second_label, callbacks.get("fixed_one_decimal", Callable()))

func source_building_cursor_state(block_configurable: bool, interactable_player_team: bool) -> String:
	return SourceBuildingMetaState.cursor_state(block_configurable, interactable_player_team)

func source_building_on_configure_build_tapped_state(clear_on_double_tap: bool, same_building: bool) -> Dictionary:
	return SourceBuildingConfigureState.on_configure_build_tapped_state(clear_on_double_tap, same_building)

func source_building_on_configure_tapped_state(x: float, y: float) -> Dictionary:
	return SourceBuildingConfigureState.on_configure_tapped_state(x, y)

func source_building_on_configure_closed_state() -> Dictionary:
	return SourceBuildingConfigureState.on_configure_closed_state()

func source_building_configure_menu_visibility_state(_player: Variant) -> Dictionary:
	return SourceBuildingConfigureState.configure_menu_visibility_state(_player)

func source_building_should_show_configure_state(_player: Variant) -> Dictionary:
	return SourceBuildingConfigureState.should_show_configure_state(_player)

func source_building_should_hide_configure_state(_player: Variant) -> Dictionary:
	return SourceBuildingConfigureState.should_hide_configure_state(_player)

func source_building_block_half_extent(block_size_value: int, source_tilesize: float) -> float:
	return SourceBuildingDrawState.block_half_extent(block_size_value, source_tilesize)

func source_building_draw_configure_state(source_x: float, source_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBuildingDrawState.draw_configure_state(source_x, source_y, block_size_value, source_tilesize)
func source_building_check_solid_state() -> bool:
	return SourceBuildingCoreState.check_solid_state()

func source_building_handle_damage_state(amount: float) -> float:
	return SourceBuildingDamageState.handle_damage_state(amount)

func source_building_absorb_lasers_state(block_absorb_lasers: bool) -> bool:
	return SourceBuildingCoreState.absorb_lasers_state(block_absorb_lasers)

func source_building_is_insulated_state(block_insulated: bool) -> bool:
	return SourceBuildingCoreState.is_insulated_state(block_insulated)

func source_building_collide_state(_other: Variant) -> bool:
	return SourceBuildingCoreState.collide_state(_other)

func source_building_collision_damage_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	return SourceBuildingDamageState.collision_damage_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)

func source_building_damage_delegate_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return SourceBuildingDamageState.damage_delegate_state(source_team, damage_amount)

func source_building_bullet_damage_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return SourceBuildingDamageState.bullet_damage_state(bullet, source_team, damage_amount)

func source_building_change_team_delegate_state(next_team: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.change_team_delegate_state(next_team)

func source_building_change_team_initial_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	return SourceBuildingLifecycleState.change_team_initial_state(current_team, next_team, force_team, was_valid)

func source_building_change_team_power_proximity_state(power_present: bool, update_power: bool, old_graph: Variant, team: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.change_team_power_proximity_state(power_present, update_power, old_graph, team)

func source_building_change_team_power_links_state(link_count: int, team: Variant, old_graph: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.change_team_power_links_state(link_count, team, old_graph)

func source_building_change_team_final_state(was: bool, last_team: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.change_team_final_state(was, last_team)

func source_building_can_pickup_state(block_can_pickup: bool) -> bool:
	return SourceBuildingLifecycleState.can_pickup_state(block_can_pickup)

func source_building_picked_up_state(previous_state: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.picked_up_state(previous_state)

func source_building_after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return SourceBuildingLifecycleState.after_picked_up_state(power_present, has_cons_power, cons_power_buffered, current_status)

func source_building_remove_from_proximity_state(nearby_count: int, removable_count: int) -> Dictionary:
	return SourceBuildingLifecycleState.remove_from_proximity_state(nearby_count, removable_count)

func source_building_update_proximity_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return SourceBuildingLifecycleState.update_proximity_state(nearby_count, same_team_count, headless, draw_cached)

func source_building_on_nearby_build_added_state(other_state: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.on_nearby_build_added_state(other_state)

func source_building_consume_state(consumers: Array, self_state: Variant) -> Dictionary:
	return SourceBuildingEfficiencyState.consume_state(consumers, self_state)

func source_building_can_consume_state(potential_efficiency: float) -> bool:
	return SourceBuildingEfficiencyState.can_consume_state(potential_efficiency)

func source_building_efficiency_scale_state() -> float:
	return SourceBuildingEfficiencyState.efficiency_scale_state()

func source_building_update_efficiency_multiplier_state(efficiency: float, optional_efficiency: float, efficiency_scale := 1.0) -> Dictionary:
	return SourceBuildingEfficiencyState.update_efficiency_multiplier_state(efficiency, optional_efficiency, efficiency_scale)

func source_building_update_consumption_initial_state(has_consumers: bool, cheating: bool, enabled_state: bool, production_valid: bool, should_consume_state: bool, efficiency_scale := 1.0) -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)

func source_building_update_consumption_disabled_state(enabled_state: bool) -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_disabled_state(enabled_state)

func source_building_update_consumption_setup_state(should_consume_state: bool, production_valid: bool) -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_setup_state(should_consume_state, production_valid)

func source_building_update_consumption_non_optional_pass_state(non_optional_consumer_results: Array) -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_non_optional_pass_state(non_optional_consumer_results)

func source_building_update_consumption_optional_pass_state(optional_consumer_results: Array) -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_optional_pass_state(optional_consumer_results)

func source_building_update_consumption_efficiency_state(min_efficiency: float, optional_efficiency: float, update: bool) -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_efficiency_state(min_efficiency, optional_efficiency, update)

func source_building_update_consumption_second_pass_state(update: bool, efficiency: float, update_consumers: Array, self_state := {}) -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_second_pass_state(update, efficiency, update_consumers, self_state)

func source_building_ambient_volume(efficiency: float) -> float:
	return SourceBuildingEfficiencyState.ambient_volume(efficiency)

func source_building_config_default() -> Variant:
	return SourceBuildingLifecycleState.config_default()

func source_building_is_valid(tile_build_matches_self: bool, dead_state: bool) -> bool:
	return SourceBuildingLifecycleState.is_valid(tile_build_matches_self, dead_state)

func source_building_heal_state(_amount: Variant = null) -> Dictionary:
	return SourceBuildingLifecycleState.heal_state(_amount)

func source_building_hit_size(block_size_value: int, source_tilesize: float) -> float:
	return SourceBlockGeometry.building_hit_size(block_size_value, source_tilesize)

func source_building_kill_state(self_state := {}) -> Dictionary:
	return SourceBuildingLifecycleState.kill_state(self_state)

func source_building_damage_dead_guard_state(dead_state: bool) -> Dictionary:
	return SourceBuildingDamageState.dead_guard_state(dead_state)

func source_building_damage_block_health_scale_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	return SourceBuildingDamageState.block_health_scale_state(damage_amount, health, block_health_multiplier, source_time)

func source_building_damage_handle_damage_gate_state(net_client: bool, health: float, damage_amount: float, handled_damage: float) -> Dictionary:
	return SourceBuildingDamageState.handle_damage_gate_state(net_client, health, damage_amount, handled_damage)

func source_building_damage_health_changed_call_state() -> Dictionary:
	return SourceBuildingDamageState.health_changed_call_state()

func source_building_damage_destroy_gate_state(health: float, self_state := {}) -> Dictionary:
	return SourceBuildingDamageState.destroy_gate_state(health, self_state)

func source_building_health_changed_state(net_server: bool, self_state := {}) -> Dictionary:
	return SourceBuildingMetaState.health_changed_state(net_server, self_state)

func source_building_sense_position_state(world_x: float, world_y: float, source_tilesize: float) -> Dictionary:
	return SourceBuildingSenseState.sense_position_state(world_x, world_y, source_tilesize)

func source_building_sense_health_process_state(health: float, max_health: float, efficiency: float, time_scale: float, ranged_range: float, source_tilesize: float, has_range: bool, rotation_value: float) -> Dictionary:
	return SourceBuildingSenseState.sense_health_process_state(health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)

func source_building_sense_totals_state(total_items: float, total_liquids: float, total_power: float) -> Dictionary:
	return SourceBuildingSenseState.sense_totals_state(total_items, total_liquids, total_power)

func source_building_sense_capacity_power_net_state(block_has_items: bool, block_item_capacity: float, block_has_liquids: bool, block_liquid_capacity: float, has_cons_power: bool, cons_power_capacity: float, has_power_module: bool, last_scaled_power_in: float, last_scaled_power_out: float, last_power_stored: float, last_power_capacity: float) -> Dictionary:
	return SourceBuildingSenseState.sense_capacity_power_net_state(block_has_items, block_item_capacity, block_has_liquids, block_liquid_capacity, has_cons_power, cons_power_capacity, has_power_module, last_scaled_power_in, last_scaled_power_out, last_power_stored, last_power_capacity, SourceTimeDefaults.TICK_RATE)

func source_building_sense_enabled_controlled_state(enabled_state: bool, is_control_block: bool, is_controlled: bool, ctrl_player_value: float) -> Dictionary:
	return SourceBuildingSenseState.sense_enabled_controlled_state(enabled_state, is_control_block, is_controlled, ctrl_player_value)

func source_building_sense_payload_size_state(has_payload_seq: bool, payload_seq_total: float, has_single_payload: bool, block_size_value: float) -> Dictionary:
	return SourceBuildingSenseState.sense_payload_size_state(has_payload_seq, payload_seq_total, has_single_payload, block_size_value)

func source_building_sense_object_state(sensor: String, block_value: Variant, has_items_module: bool, first_item_value: Variant, config_senseable: bool, config_value: Variant, single_payload_kind: String, single_payload_content: Variant) -> Dictionary:
	return SourceBuildingSenseState.sense_object_state(sensor, block_value, has_items_module, first_item_value, config_senseable, config_value, single_payload_kind, single_payload_content)

func source_building_sense_content_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	return SourceBuildingSenseState.sense_content_state(content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount)

func generated_building_comp_sense_content_bridge_state(content_type: String, has_items_module: bool, item_amount: float, has_liquids_module: bool, liquid_amount: float, has_payloads: bool, payload_amount: float) -> Dictionary:
	return SourceBuildingSenseState.generated_building_comp_sense_content_bridge_state(content_type, has_items_module, item_amount, has_liquids_module, liquid_amount, has_payloads, payload_amount)

func source_building_sense_camera_default_state(is_control_block: bool, unit_camera_x: float, unit_camera_y: float, unit_camera_width: float, unit_camera_height: float) -> Dictionary:
	return SourceBuildingSenseState.sense_camera_default_state(is_control_block, unit_camera_x, unit_camera_y, unit_camera_width, unit_camera_height)

func source_building_control_enabled_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:
	return SourceBuildingControlState.control_enabled_state(current_enabled, control_type, p1, SourceMathDefaults.FLOAT_ROUNDING_ERROR)

func generated_building_comp_control_enabled_bridge_state(current_enabled: bool, control_type: String, p1: float) -> Dictionary:
	return SourceBuildingControlState.generated_control_enabled_bridge_state(current_enabled, control_type, p1, SourceMathDefaults.FLOAT_ROUNDING_ERROR)

func source_building_control_config_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	return SourceBuildingControlState.control_config_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)

func generated_building_comp_control_config_bridge_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	return SourceBuildingControlState.generated_control_config_bridge_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)

func source_building_set_prop_health_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	return SourceBuildingSetPropState.health_state(prop, current_health, max_health_value, value, dead_state, self_state)

func generated_building_comp_set_prop_health_bridge_state(prop: String, current_health: float, max_health_value: float, value: float, dead_state: bool, self_state: Variant) -> Dictionary:
	return SourceBuildingSetPropState.generated_health_bridge_state(prop, current_health, max_health_value, value, dead_state, self_state)

func source_building_set_prop_team_double_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	return SourceBuildingSetPropState.team_double_state(prop, current_team_id, value)

func generated_building_comp_set_prop_team_double_bridge_state(prop: String, current_team_id: int, value: float) -> Dictionary:
	return SourceBuildingSetPropState.generated_team_double_bridge_state(prop, current_team_id, value)

func source_building_set_prop_total_power_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	return SourceBuildingSetPropState.total_power_state(prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value)

func generated_building_comp_set_prop_total_power_bridge_state(prop: String, current_power_status: float, has_power: bool, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, value: float) -> Dictionary:
	return SourceBuildingSetPropState.generated_total_power_bridge_state(prop, current_power_status, has_power, has_cons_power, cons_power_buffered, cons_power_capacity, value)

func source_building_set_prop_team_object_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	return SourceBuildingSetPropState.team_object_state(prop, current_team_value, value_is_team, team_value)

func generated_building_comp_set_prop_team_object_bridge_state(prop: String, current_team_value: Variant, value_is_team: bool, team_value: Variant) -> Dictionary:
	return SourceBuildingSetPropState.generated_team_object_bridge_state(prop, current_team_value, value_is_team, team_value)

func generated_building_comp_set_prop_item_content_bridge_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	return SourceBuildingSetPropState.generated_item_content_bridge_state(content_type, has_items_module, item_value, current_amount, value, accepted_stack)

func generated_building_comp_set_prop_liquid_content_bridge_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	return SourceBuildingSetPropState.generated_liquid_content_bridge_state(content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid)

func source_building_set_prop_item_content_state(content_type: String, has_items_module: bool, item_value: Variant, current_amount: int, value: float, accepted_stack: int) -> Dictionary:
	return SourceBuildingSetPropState.item_content_state(content_type, has_items_module, item_value, current_amount, value, accepted_stack)

func source_building_set_prop_liquid_content_state(content_type: String, has_liquids_module: bool, liquid_value: Variant, current_amount: float, value: float, block_liquid_capacity: float, accept_liquid_result: bool, current_liquid_matches: bool, current_liquid_amount: float, block_consumes_liquid: bool) -> Dictionary:
	return SourceBuildingSetPropState.liquid_content_state(content_type, has_liquids_module, liquid_value, current_amount, value, block_liquid_capacity, accept_liquid_result, current_liquid_matches, current_liquid_amount, block_consumes_liquid)

func generated_building_comp_in_fog_initial_gate_bridge_state(same_team: bool, rules_fog: bool) -> Dictionary:
	return SourceBuildingVisibilityState.generated_in_fog_initial_gate_bridge_state(same_team, rules_fog)

func generated_building_comp_in_fog_discovery_gate_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	return SourceBuildingVisibilityState.generated_in_fog_discovery_gate_bridge_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)

func generated_building_comp_in_fog_visibility_loop_bridge_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	return SourceBuildingVisibilityState.generated_in_fog_visibility_loop_bridge_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)

func source_building_in_fog_initial_gate_state(same_team: bool, rules_fog: bool) -> Dictionary:
	return SourceBuildingVisibilityState.in_fog_initial_gate_state(same_team, rules_fog)

func source_building_in_fog_discovery_gate_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, is_discovered: bool) -> Dictionary:
	return SourceBuildingVisibilityState.in_fog_discovery_gate_state(block_size_value, block_size_offset, tile_x, tile_y, is_discovered)

func source_building_in_fog_visibility_loop_state(block_size_value: int, block_size_offset: int, tile_x: int, tile_y: int, visible_tiles: Array) -> Dictionary:
	return SourceBuildingVisibilityState.in_fog_visibility_loop_state(block_size_value, block_size_offset, tile_x, tile_y, visible_tiles)

func generated_building_comp_killed_initial_side_effects_bridge_state(tile_value: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.generated_killed_initial_side_effects_bridge_state(tile_value)

func generated_building_comp_killed_removal_side_effects_bridge_state(tile_value: Variant, tile_not_empty_tile: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_killed_removal_side_effects_bridge_state(tile_value, tile_not_empty_tile)

func source_building_killed_initial_side_effects_state(tile_value: Variant) -> Dictionary:
	return SourceBuildingLifecycleState.killed_initial_side_effects_state(tile_value)

func source_building_killed_removal_side_effects_state(tile_not_empty_tile: bool) -> Dictionary:
	return SourceBuildingLifecycleState.killed_removal_side_effects_state(tile_not_empty_tile)

func generated_building_comp_check_allow_update_bridge_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_check_allow_update_bridge_state(current_enabled, allow_update_result)

func source_building_check_allow_update_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	return SourceBuildingLifecycleState.check_allow_update_state(current_enabled, allow_update_result)

func source_building_write_base_timescale_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	return SourceBuildingTimeState.write_base_timescale_state(current_time_scale, current_time_scale_duration, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func generated_building_comp_write_base_timescale_bridge_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	return SourceBuildingTimeState.generated_write_base_timescale_bridge_state(current_time_scale, current_time_scale_duration)

func source_building_read_base_timescale_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	return SourceBuildingTimeState.read_base_timescale_state(current_module_bits, read_time_scale, read_time_scale_duration, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func generated_building_comp_read_base_timescale_bridge_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	return SourceBuildingTimeState.generated_read_base_timescale_bridge_state(current_module_bits, read_time_scale, read_time_scale_duration)

func source_building_module_bitmask_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	return SourceBuildingTimeState.module_bitmask_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func generated_building_comp_module_bitmask_bridge_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	return SourceBuildingTimeState.generated_module_bitmask_bridge_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler)

func generated_building_comp_update_timescale_decay_bridge_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	return SourceBuildingTimeState.generated_update_timescale_decay_bridge_state(current_time_scale, current_time_scale_duration, time_delta)

func source_building_update_timescale_decay_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	return SourceBuildingTimeState.update_timescale_decay_state(current_time_scale, current_time_scale_duration, time_delta, SourceBlockDefaults.TIME_SCALE_DEFAULT)

func generated_building_comp_update_ambient_sound_gate_bridge_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	return SourceBuildingTimeState.generated_update_ambient_sound_gate_bridge_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)

func source_building_update_ambient_sound_gate_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	return SourceBuildingTimeState.update_ambient_sound_gate_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)

func source_building_update_consumption_call_state() -> Dictionary:
	return SourceBuildingEfficiencyState.update_consumption_call_state()

func generated_building_comp_update_consumption_call_bridge_state() -> Dictionary:
	return SourceBuildingEfficiencyState.generated_update_consumption_call_bridge_state()

func source_building_update_tile_gate_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	return SourceBuildingLifecycleState.update_tile_gate_state(enabled_state, block_no_update_disabled)

func generated_building_comp_update_tile_gate_bridge_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	return SourceBuildingLifecycleState.generated_update_tile_gate_bridge_state(enabled_state, block_no_update_disabled)

func source_building_update_fog_visibility_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state := {}, tile_state := {}) -> Dictionary:
	return SourceBuildingVisibilityState.update_fog_visibility_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)

func generated_building_comp_update_fog_visibility_bridge_state(was_visible: bool, in_fog_to_player_team: bool, visible_flags: int, player_team_id: int, self_state: Variant, tile_state: Variant) -> Dictionary:
	return SourceBuildingVisibilityState.generated_update_fog_visibility_bridge_state(was_visible, in_fog_to_player_team, visible_flags, player_team_id, self_state, tile_state)

func source_building_hitbox_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBlockGeometry.building_hitbox_state(world_x, world_y, block_size_value, source_tilesize)

func generated_building_comp_hitbox_bridge_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBlockGeometry.generated_building_hitbox_bridge_state(world_x, world_y, block_size_value, source_tilesize)

func source_building_to_string_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> String:
	return SourceBuildingMetaState.to_string_state(id_value, tile_x_value, tile_y_value, block_value)

func generated_building_comp_to_string_bridge_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> Dictionary:
	return SourceBuildingMetaState.generated_to_string_bridge_state(id_value, tile_x_value, tile_y_value, block_value)

func source_building_tether_update_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	return SourceBuildingTetherState.update_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)

func generated_building_tether_comp_update_bridge_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	return SourceBuildingTetherState.generated_building_tether_update_bridge_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)

func source_child_add_state(child_state: Dictionary) -> Dictionary:
	return SourceChildState.add_state(child_state)

func generated_child_comp_add_bridge_state(child_state: Dictionary) -> Dictionary:
	return SourceChildState.generated_child_add_bridge_state(child_state)

func source_child_update_state(child_state: Dictionary) -> Dictionary:
	var callbacks := SourceChildState.default_callbacks_state(self)
	return SourceChildState.update_state(child_state, callbacks.get("trns_vec", Callable()))

func generated_child_comp_update_bridge_state(child_state: Dictionary) -> Dictionary:
	return SourceChildState.generated_child_update_bridge_state(child_state)

func source_pos_set_state(x_value: float, y_value: float) -> Dictionary:
	return SourceBasicCompState.pos_set_state(x_value, y_value)

func generated_pos_comp_set_bridge_state(x_value: float, y_value: float) -> Dictionary:
	return SourceBasicCompState.generated_pos_set_bridge_state(x_value, y_value)

func source_shielder_absorb_state() -> Dictionary:
	return SourceBasicCompState.shielder_absorb_state()

func generated_shielder_comp_absorb_bridge_state() -> Dictionary:
	return SourceBasicCompState.generated_shielder_absorb_bridge_state()

func source_sync_snap_sync_state() -> Dictionary:
	return SourceSyncState.snap_sync_state()

func generated_sync_comp_snap_sync_bridge_state() -> Dictionary:
	return SourceSyncState.generated_snap_sync_bridge_state()

func source_sync_snap_interpolation_state() -> Dictionary:
	return SourceSyncState.snap_interpolation_state()

func generated_sync_comp_snap_interpolation_bridge_state() -> Dictionary:
	return SourceSyncState.generated_snap_interpolation_bridge_state()

func source_sync_read_sync_state() -> Dictionary:
	return SourceSyncState.read_sync_state()

func generated_sync_comp_read_sync_bridge_state() -> Dictionary:
	return SourceSyncState.generated_read_sync_bridge_state()

func source_sync_write_sync_state() -> Dictionary:
	return SourceSyncState.write_sync_state()

func generated_sync_comp_write_sync_bridge_state() -> Dictionary:
	return SourceSyncState.generated_write_sync_bridge_state()

func source_sync_read_sync_manual_state() -> Dictionary:
	return SourceSyncState.read_sync_manual_state()

func generated_sync_comp_read_sync_manual_bridge_state() -> Dictionary:
	return SourceSyncState.generated_read_sync_manual_bridge_state()

func source_sync_write_sync_manual_state() -> Dictionary:
	return SourceSyncState.write_sync_manual_state()

func generated_sync_comp_write_sync_manual_bridge_state() -> Dictionary:
	return SourceSyncState.generated_write_sync_manual_bridge_state()

func source_sync_after_sync_state() -> Dictionary:
	return SourceSyncState.after_sync_state()

func generated_sync_comp_after_sync_bridge_state() -> Dictionary:
	return SourceSyncState.generated_after_sync_bridge_state()

func source_sync_interpolate_state() -> Dictionary:
	return SourceSyncState.interpolate_state()

func generated_sync_comp_interpolate_bridge_state() -> Dictionary:
	return SourceSyncState.generated_interpolate_bridge_state()

func source_sync_is_sync_hidden_state(player: Variant = null) -> Dictionary:
	return SourceSyncState.is_sync_hidden_state(player)

func generated_sync_comp_is_sync_hidden_bridge_state(player: Variant = null) -> Dictionary:
	return SourceSyncState.generated_is_sync_hidden_bridge_state(player)

func source_sync_handle_sync_hidden_state() -> Dictionary:
	return SourceSyncState.handle_sync_hidden_state()

func generated_sync_comp_handle_sync_hidden_bridge_state() -> Dictionary:
	return SourceSyncState.generated_handle_sync_hidden_bridge_state()

func source_sync_update_interpolate_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	return SourceSyncState.update_interpolate_state(net_client, is_local, is_remote)

func generated_sync_comp_update_interpolate_bridge_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	return SourceSyncState.generated_update_interpolate_bridge_state(net_client, is_local, is_remote)

func source_sync_remove_client_removed_entity_state(net_client: bool, entity_id: int) -> Dictionary:
	return SourceSyncState.remove_client_removed_entity_state(net_client, entity_id)

func generated_sync_comp_remove_client_removed_entity_bridge_state(net_client: bool, entity_id: int) -> Dictionary:
	return SourceSyncState.generated_remove_client_removed_entity_bridge_state(net_client, entity_id)

func source_block_unit_ammof_state(ammo: float) -> Dictionary:
	return SourceBlockUnitState.ammof_state(ammo)

func generated_block_unit_comp_ammof_bridge_state(ammo: float) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_ammof_bridge_state(ammo)

func source_block_unit_icon_state(tile_block_ui_icon: Variant) -> Dictionary:
	return SourceBlockUnitState.icon_state(tile_block_ui_icon)

func generated_block_unit_comp_icon_bridge_state(tile_block_ui_icon: Variant) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_icon_bridge_state(tile_block_ui_icon)

func source_block_unit_tile_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	return SourceBlockUnitState.tile_state(tile, tile_block_health, tile_health, tile_block_size, tilesize)

func generated_block_unit_comp_tile_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float, tilesize: float) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_tile_bridge_state(tile, tile_block_health, tile_health, tile_block_size, tilesize)

func generated_block_unit_comp_tile_source_tilesize_default_bridge_state(tile: Variant, tile_block_health: float, tile_health: float, tile_block_size: float) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_tile_source_tilesize_default_bridge_state(tile, tile_block_health, tile_health, tile_block_size)

func source_block_unit_add_state(tile_null: bool) -> Dictionary:
	return SourceBlockUnitState.add_state(tile_null)

func generated_block_unit_comp_add_bridge_state(tile_null: bool) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_add_bridge_state(tile_null)

func source_block_unit_update_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	return SourceBlockUnitState.update_state(tile_exists, team, tile_team)

func generated_block_unit_comp_update_bridge_state(tile_exists: bool, team: Variant, tile_team: Variant) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_update_bridge_state(tile_exists, team, tile_team)

func source_block_unit_killed_state() -> Dictionary:
	return SourceBlockUnitState.killed_state()

func generated_block_unit_comp_killed_bridge_state() -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_killed_bridge_state()

func source_block_unit_damage_state(v: float, b: bool) -> Dictionary:
	return SourceBlockUnitState.damage_state(v, b)

func generated_block_unit_comp_damage_bridge_state(v: float, b: bool) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_damage_bridge_state(v, b)

func source_block_unit_team_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	return SourceBlockUnitState.team_state(tile_exists, this_team, team, tile_team)

func generated_block_unit_comp_team_bridge_state(tile_exists: bool, this_team: Variant, team: Variant, tile_team: Variant) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_team_bridge_state(tile_exists, this_team, team, tile_team)

func source_block_unit_dead_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	return SourceBlockUnitState.dead_state(tile_null, tile_dead)

func generated_block_unit_comp_dead_bridge_state(tile_null: bool, tile_dead: bool) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_dead_bridge_state(tile_null, tile_dead)

func source_block_unit_is_valid_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return SourceBlockUnitState.is_valid_state(tile_exists, tile_is_valid)

func generated_block_unit_comp_is_valid_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_is_valid_bridge_state(tile_exists, tile_is_valid)

func source_block_unit_is_added_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return SourceBlockUnitState.is_added_state(tile_exists, tile_is_valid)

func generated_block_unit_comp_is_added_bridge_state(tile_exists: bool, tile_is_valid: bool) -> Dictionary:
	return SourceBlockUnitState.generated_block_unit_comp_is_added_bridge_state(tile_exists, tile_is_valid)

func source_builder_can_build_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	return SourceBuilderRuntimeState.can_build_state(type_build_speed, build_speed_multiplier)

func generated_builder_comp_can_build_bridge_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_can_build_bridge_state(type_build_speed, build_speed_multiplier)

func source_builder_update_state() -> Dictionary:
	return SourceBuilderRuntimeState.update_state()

func generated_builder_comp_update_bridge_state() -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_update_bridge_state()

func source_builder_after_read_state(plans_null: bool) -> Dictionary:
	return SourceBuilderRuntimeState.after_read_state(plans_null)

func generated_builder_comp_after_read_bridge_state(plans_null: bool) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_after_read_bridge_state(plans_null)

func source_builder_is_building_state(plans_size: int) -> Dictionary:
	return SourceBuilderRuntimeState.is_building_state(plans_size)

func generated_builder_comp_is_building_bridge_state(plans_size: int) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_is_building_bridge_state(plans_size)

func source_builder_clear_building_state() -> Dictionary:
	return SourceBuilderRuntimeState.clear_building_state()

func generated_builder_comp_clear_building_bridge_state() -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_clear_building_bridge_state()

func source_builder_draw_plan_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	return SourceBuilderDrawState.draw_plan_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)

func generated_builder_comp_draw_plan_bridge_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	return SourceBuilderDrawState.generated_builder_comp_draw_plan_bridge_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)

func source_builder_draw_building_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	return SourceBuilderDrawState.draw_building_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)

func generated_builder_comp_draw_building_bridge_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	return SourceBuilderDrawState.generated_builder_comp_draw_building_bridge_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)

func source_builder_draw_building_beam_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	return SourceBuilderDrawState.draw_building_beam_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)

func generated_builder_comp_draw_building_beam_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	return SourceBuilderDrawState.generated_builder_comp_draw_building_beam_bridge_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)

func generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool) -> Dictionary:
	return SourceBuilderDrawState.generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build)

func source_builder_draw_plan_top_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	return SourceBuilderDrawState.draw_plan_top_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)

func generated_builder_comp_draw_plan_top_bridge_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	return SourceBuilderDrawState.generated_builder_comp_draw_plan_top_bridge_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)

func source_builder_should_skip_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	return SourceBuilderRuntimeState.should_skip_state(state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement)

func generated_builder_comp_should_skip_bridge_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_should_skip_bridge_state(state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement)

func source_builder_remove_build_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	return SourceBuilderRuntimeState.remove_build_state(plans, x, y, breaking)

func generated_builder_comp_remove_build_bridge_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_remove_build_bridge_state(plans, x, y, breaking)

func source_builder_add_build_tail_state(place: Variant) -> Dictionary:
	return SourceBuilderRuntimeState.add_build_tail_state(place)

func generated_builder_comp_add_build_tail_bridge_state(place: Variant) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_add_build_tail_bridge_state(place)

func source_builder_add_build_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	return SourceBuilderRuntimeState.add_build_state(plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress)

func generated_builder_comp_add_build_bridge_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_add_build_bridge_state(plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress)

func source_builder_build_plan_state(plans_size: int, plans_first: Variant) -> Dictionary:
	return SourceBuilderRuntimeState.build_plan_state(plans_size, plans_first)

func generated_builder_comp_build_plan_bridge_state(plans_size: int, plans_first: Variant) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_build_plan_bridge_state(plans_size, plans_first)

func source_builder_actively_building_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	return SourceBuilderRuntimeState.actively_building_state(plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building)

func source_builder_build_step_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	return SourceBuilderRuntimeState.build_step_state(entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current)

func generated_builder_comp_update_build_logic_bridge_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_update_build_logic_bridge_state(entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current)

func generated_builder_comp_actively_building_bridge_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	return SourceBuilderRuntimeState.generated_builder_comp_actively_building_bridge_state(plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building)

func source_unit_tether_after_read_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return SourceUnitTetherState.after_read_state(spawner_unit_id, groups_unit_get_by_id_result)

func generated_unit_tether_comp_after_read_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return SourceUnitTetherState.generated_unit_tether_comp_after_read_bridge_state(spawner_unit_id, groups_unit_get_by_id_result)

func source_unit_tether_after_sync_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return SourceUnitTetherState.after_sync_state(spawner_unit_id, groups_unit_get_by_id_result)

func generated_unit_tether_comp_after_sync_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return SourceUnitTetherState.generated_unit_tether_comp_after_sync_bridge_state(spawner_unit_id, groups_unit_get_by_id_result)

func source_unit_tether_update_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	return SourceUnitTetherState.update_state(spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id)

func generated_unit_tether_comp_update_bridge_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	return SourceUnitTetherState.generated_unit_tether_comp_update_bridge_state(spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id)

func source_building_handle_liquid_amount(current_amount: float, amount: float) -> float:
	return SourceBuildingLiquidState.handle_liquid_amount(current_amount, amount)
func source_building_accept_liquid_state(has_liquids: bool, consumes_liquid: bool) -> bool:
	return SourceBuildingLiquidState.accept_liquid_state(has_liquids, consumes_liquid)
func source_building_dump_liquid_default_scaling_state(liquid: Variant, current_liquid_amount: float) -> Dictionary:
	return SourceBuildingLiquidState.dump_liquid_default_scaling_state(liquid, current_liquid_amount)
func source_building_dump_liquid_campaign_unlock_state(liquid: Variant, current_liquid_amount: float, net_client: bool, state_is_campaign: bool, team_is_default_team: bool) -> Dictionary:
	return SourceBuildingLiquidState.dump_liquid_campaign_unlock_state(liquid, current_liquid_amount, net_client, state_is_campaign, team_is_default_team)
func source_building_dump_liquid_routing_gate_state(liquid: Variant, proximity_size: int, dump_cursor: int, output_dir: int, rotation_value: int, relative_to_by_index: Array, destination_present_by_index: Array, other_has_liquids_by_index: Array, can_dump_liquid_by_index: Array, other_liquids_present_by_index: Array) -> Dictionary:
	return SourceBuildingLiquidState.dump_liquid_routing_gate_state(
		liquid,
		proximity_size,
		dump_cursor,
		output_dir,
		rotation_value,
		relative_to_by_index,
		destination_present_by_index,
		other_has_liquids_by_index,
		can_dump_liquid_by_index,
		other_liquids_present_by_index,
		SourceBuildingLiquidState.default_callbacks_state(self).get("increment_dump_cursor", Callable())
	)
func source_building_dump_liquid_fraction_transfer_state(liquid: Variant, scaling: float, eligible_indices: Array, current_liquid_amount: float, block_liquid_capacity: float, other_liquid_amount_by_index: Array, other_block_liquid_capacity_by_index: Array) -> Dictionary:
	return SourceBuildingLiquidState.dump_liquid_fraction_transfer_state(liquid, scaling, eligible_indices, current_liquid_amount, block_liquid_capacity, other_liquid_amount_by_index, other_block_liquid_capacity_by_index)
func source_building_transfer_liquid_state(liquid: Variant, amount: float, next_block_liquid_capacity: float, next_liquid_amount: float, next_accepts_liquid: bool, current_liquid_amount: float) -> Dictionary:
	return SourceBuildingLiquidState.transfer_liquid_state(liquid, amount, next_block_liquid_capacity, next_liquid_amount, next_accepts_liquid, current_liquid_amount)
func source_building_can_dump_liquid_default_state(to_state: Variant, liquid: Variant) -> Dictionary:
	return SourceBuildingLiquidState.can_dump_liquid_default_state(to_state, liquid)
func source_building_can_dump_item_default_state(to_state: Variant, item: Variant) -> Dictionary:
	return SourceBuildingItemDumpState.can_dump_item_default_state(to_state, item)
func source_building_on_proximity_removed_state(power_present: bool) -> Dictionary:
	return SourceBuildingPowerState.on_proximity_removed_state(power_present)

func source_building_on_proximity_added_state(power_present: bool) -> Dictionary:
	return SourceBuildingPowerState.on_proximity_added_state(power_present)

func source_building_on_proximity_update_state() -> Dictionary:
	return SourceBuildingPowerState.on_proximity_update_state()

func source_building_update_power_graph_state(other_power_present_by_index: Array) -> Dictionary:
	return SourceBuildingPowerState.update_power_graph_state(other_power_present_by_index)

func source_building_conducts_to_state(block_insulated: bool) -> Dictionary:
	return SourceBuildingPowerState.conducts_to_state(block_insulated)

func source_building_get_power_connections_empty_guard_state(power_present: bool, previous_out_count: int) -> Dictionary:
	return SourceBuildingPowerState.get_power_connections_empty_guard_state(power_present, previous_out_count)

func source_building_get_power_connections_proximity_guard_state(other_present_by_index: Array, other_power_present_by_index: Array, other_same_team_by_index: Array) -> Dictionary:
	return SourceBuildingPowerState.get_power_connections_proximity_guard_state(other_present_by_index, other_power_present_by_index, other_same_team_by_index)

func source_building_get_power_connections_power_compatibility_guard_state(block_consumes_power: bool, block_outputs_power: bool, block_conductive_power: bool, other_block_consumes_power_by_index: Array, other_block_outputs_power_by_index: Array, other_block_conductive_power_by_index: Array) -> Dictionary:
	return SourceBuildingPowerState.get_power_connections_power_compatibility_guard_state(block_consumes_power, block_outputs_power, block_conductive_power, other_block_consumes_power_by_index, other_block_outputs_power_by_index, other_block_conductive_power_by_index)

func source_building_get_power_connections_conducts_link_guard_state(conducts_to_other_by_index: Array, other_conducts_to_self_by_index: Array, power_link_contains_other_pos_by_index: Array) -> Dictionary:
	return SourceBuildingPowerState.get_power_connections_conducts_link_guard_state(conducts_to_other_by_index, other_conducts_to_self_by_index, power_link_contains_other_pos_by_index)

func source_building_get_power_connections_automatic_add_state(conducts_link_guard_pass_indices: Array, previous_out_count: int) -> Dictionary:
	return SourceBuildingPowerState.get_power_connections_automatic_add_state(conducts_link_guard_pass_indices, previous_out_count)

func source_building_get_power_connections_manual_links_loop_state(link_present_by_index: Array, link_build_present_by_index: Array, link_build_power_present_by_index: Array, link_build_same_team_by_index: Array, previous_out_count: int) -> Dictionary:
	return SourceBuildingPowerState.get_power_connections_manual_links_loop_state(link_present_by_index, link_build_present_by_index, link_build_power_present_by_index, link_build_same_team_by_index, previous_out_count)

func source_building_get_liquid_destination_default_state(from_state: Variant, liquid: Variant, self_state: Variant) -> Dictionary:
	return SourceBuildingLiquidState.get_liquid_destination_default_state(from_state, liquid, self_state)
func source_building_get_payload_default_state() -> Dictionary:
	return SourceBuildingPayloadState.get_payload_default_state()

func source_building_take_payload_default_state() -> Dictionary:
	return SourceBuildingPayloadState.take_payload_default_state()

func source_building_get_payloads_default_state() -> Dictionary:
	return SourceBuildingPayloadState.get_payloads_default_state()

func source_building_put_item_state(item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array) -> Dictionary:
	return SourceBuildingItemDumpState.put_item_state(
		item,
		proximity_size,
		dump_cursor,
		accepts_item_by_index,
		can_dump_by_index,
		SourceBuildingItemDumpState.default_callbacks_state(self).get("increment_dump_cursor", Callable())
	)
func source_building_produced_item_default_state(item: Variant) -> Dictionary:
	return SourceBuildingItemDumpState.produced_item_default_state(item)
func source_building_produced_item_amount_state(item: Variant, amount: int, sector_present: bool, team_is_default_team: bool, net_client: bool) -> Dictionary:
	return SourceBuildingItemDumpState.produced_item_amount_state(item, amount, sector_present, team_is_default_team, net_client)
func source_building_move_liquid_forward_state(leaks: bool, liquid: Variant, next_tile_present: bool, next_build_present: bool, next_block_solid: bool, next_block_has_liquids: bool, current_liquid_amount: float, move_liquid_return: float) -> Dictionary:
	return SourceBuildingLiquidState.move_liquid_forward_state(leaks, liquid, next_tile_present, next_build_present, next_block_solid, next_block_has_liquids, current_liquid_amount, move_liquid_return)
func source_building_move_liquid_state(liquid: Variant, next_present: bool, destination_team_matches: bool, destination_block_has_liquids: bool, current_liquid_amount: float, destination_liquid_amount: float, source_block_liquid_capacity: float, source_block_liquid_pressure: float, destination_block_liquid_capacity: float, destination_accepts_liquid: bool) -> Dictionary:
	return SourceBuildingLiquidState.move_liquid_state(liquid, next_present, destination_team_matches, destination_block_has_liquids, current_liquid_amount, destination_liquid_amount, source_block_liquid_capacity, source_block_liquid_pressure, destination_block_liquid_capacity, destination_accepts_liquid)
func source_building_move_liquid_reaction_setup_state(main_guard_passed: bool, transfer_guard_passed: bool, destination_consumes_liquid: bool, destination_current_amount: float, destination_block_liquid_capacity: float, fract_value: float, source_x: float, source_y: float, destination_x: float, destination_y: float, destination_current_liquid: Variant, other_block_reactive: bool, liquid_block_reactive: bool) -> Dictionary:
	return SourceBuildingLiquidState.move_liquid_reaction_setup_state(main_guard_passed, transfer_guard_passed, destination_consumes_liquid, destination_current_amount, destination_block_liquid_capacity, fract_value, source_x, source_y, destination_x, destination_y, destination_current_liquid, other_block_reactive, liquid_block_reactive)
func source_building_move_liquid_fire_reaction_state(block_reactive_guard_passed: bool, other_flammability: float, liquid_temperature: float, liquid_flammability: float, other_temperature: float, fire_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return SourceBuildingLiquidState.move_liquid_fire_reaction_state(block_reactive_guard_passed, other_flammability, liquid_temperature, liquid_flammability, other_temperature, fire_chance_delta_passed, fx, fy)
func source_building_move_liquid_steam_reaction_state(block_reactive_guard_passed: bool, fire_reaction_guard_passed: bool, liquid_temperature: float, other_temperature: float, current_liquid_amount: float, source_delta: float, steam_chance_delta_passed: bool, fx: float, fy: float) -> Dictionary:
	return SourceBuildingLiquidState.move_liquid_steam_reaction_state(block_reactive_guard_passed, fire_reaction_guard_passed, liquid_temperature, other_temperature, current_liquid_amount, source_delta, steam_chance_delta_passed, fx, fy)
func source_building_move_liquid_return_zero_state(next_present: bool, transfer_guard_passed: bool) -> Dictionary:
	return SourceBuildingLiquidState.move_liquid_return_zero_state(next_present, transfer_guard_passed)
func source_move_forward_accept_state(has_front: bool, same_team: bool, front_accepts: bool) -> bool:
	return SourceBuildingItemState.move_forward_accept_state(has_front, same_team, front_accepts)

func source_move_forward_to_core(item_id: String, has_front := true, same_team := true) -> bool:
	if not source_move_forward_accept_state(has_front, same_team, source_core_accept_item(item_id)):
		return false
	return source_core_handle_item(item_id)

func source_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	if proximity_size != 0:
		return (current_dump + 1) % proximity_size
	return current_dump

func set_drill_dump_cursor(value: int) -> void:
	drill_dump_cursor = value

func increment_drill_dump(proximity_size: int) -> int:
	drill_dump_cursor = source_increment_dump_cursor(drill_dump_cursor, proximity_size)
	return drill_dump_cursor

func source_building_dump_accumulate_default_state() -> Dictionary:
	return SourceBuildingItemDumpState.dump_accumulate_default_state()
func source_building_dump_default_state() -> Dictionary:
	return SourceBuildingItemDumpState.dump_default_state()
func source_building_dump_null_item_scan_state(item_ids: Array, item_present_by_index: Array) -> Dictionary:
	return SourceBuildingItemDumpState.dump_null_item_scan_state(item_ids, item_present_by_index)
func source_building_dump_null_proximity_scan_state(proximity_size: int, dump_cursor: int) -> Dictionary:
	return SourceBuildingItemDumpState.dump_null_proximity_scan_state(
		proximity_size,
		dump_cursor,
		SourceBuildingItemDumpState.default_callbacks_state(self).get("increment_dump_cursor", Callable())
	)
func source_building_dump_null_remove_item_state(item: Variant, item_amount_before: int) -> Dictionary:
	return SourceBuildingItemDumpState.dump_null_remove_item_state(item, item_amount_before)
func source_building_dump_null_success_handoff_state(item: Variant, accepts_item: bool, can_dump: bool) -> Dictionary:
	return SourceBuildingItemDumpState.dump_null_success_handoff_state(item, accepts_item, can_dump)
func source_building_dump_specific_proximity_scan_state(todump: Variant, proximity_size: int, dump_cursor: int) -> Dictionary:
	return SourceBuildingItemDumpState.dump_specific_proximity_scan_state(todump, proximity_size, dump_cursor)
func source_building_dump_terminal_failure_state() -> Dictionary:
	return SourceBuildingItemDumpState.dump_terminal_failure_state()
func source_dump_accumulate_attempt_state(current_accum: float, source_delta: float) -> Dictionary:
	return SourceBuildingItemDumpState.dump_accumulate_state(current_accum, source_delta)

func step_building_dump_accum(source_delta: float) -> Dictionary:
	var state := source_dump_accumulate_attempt_state(building_dump_accum, source_delta)
	building_dump_accum = float(state["dump_accum"])
	return state

func drill_item_count(item_id: String) -> int:
	return SourceDrillInventoryRuntimeState.item_count(drill_items, item_id)

func drill_items_total() -> int:
	return SourceDrillInventoryRuntimeState.items_total(drill_items)

func add_drill_item(item_id: String, amount: int) -> void:
	var state := SourceDrillInventoryRuntimeState.add_item_state(drill_items, item_id, amount)
	drill_items = state.get("drill_items", drill_items).duplicate(true)

func source_offload_to_inventory(item_id: String, amount: int) -> void:
	var state := SourceDrillInventoryRuntimeState.offload_to_inventory_state(drill_items, item_id, amount)
	drill_items = state.get("drill_items", drill_items).duplicate(true)

func remove_drill_item(item_id: String, amount: int) -> int:
	var state := SourceDrillInventoryRuntimeState.remove_item_state(drill_items, item_id, amount)
	drill_items = state.get("drill_items", drill_items).duplicate(true)
	return int(state.get("removed", 0))

func source_dump_drill_item_to_core(item_id: String) -> bool:
	var callbacks := SourceDrillInventoryRuntimeState.default_callbacks_state(self)
	return bool(SourceDrillInventoryRuntimeState.dump_item_to_core_state(item_id, callbacks.get("item_count", Callable()), callbacks.get("core_accept", Callable()), callbacks.get("core_handle", Callable()), callbacks.get("remove_item", Callable()), callbacks.get("increment_dump", Callable())).get("dump_success", false))

func requirements_text(block) -> String:
	return SourceBlockRequirementsState.block_requirements_text(block)

func add_sprite(parent: Node, key: String, pos: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = textures.get(key)
	sprite.position = pos
	if sprite.texture:
		var size := sprite.texture.get_size()
		if size.x > 0 and size.y > 0:
			sprite.scale = SourceWorldGrid.sprite_tile_scale(size, tile_size)
	parent.add_child(sprite)
	return sprite

func add_ore_cell(parent: Node, key: String, item_id: String, cell: Vector2i) -> Sprite2D:
	ore_items_by_cell[cell_key(cell)] = item_id
	return add_sprite(parent, key, grid_to_world(cell))

func grid_to_world(cell: Vector2i) -> Vector2:
	return SourceWorldGrid.grid_to_world(cell, tile_size)

func world_to_grid(pos: Vector2) -> Vector2i:
	return SourceWorldGrid.world_to_grid(pos, tile_size)

func cell_key(cell: Vector2i) -> String:
	return SourceWorldGrid.cell_key(cell)

func build_hud() -> void:
	update_hud()

func _process(delta: float) -> void:
	MindustryTime.update(delta)
	simulate_block_time_scales(delta)
	simulate_factory(delta)
	simulate_mend_projectors(delta)
	simulate_overdrive_projectors(delta)
	simulate_turrets(delta)
	simulate_bullets(delta)
	simulate_enemy_units(delta)
	update_camera(delta)
	update_hud()

func simulate_factory(delta: float) -> void:
	SourceFactoryRuntimeState.simulate_factory(self, delta)

func simulate_drill_dump(delta: float) -> void:
	var dump_state := factory_drill_dump_preview_state(delta)
	drill_dump_timer = float(dump_state.get("drill_dump_timer", drill_dump_timer))
	if bool(dump_state.get("should_dump", false)):
		source_dump_drill_item_to_core(drill_output_item_id)

func factory_cell_context() -> Dictionary:
	return SourceFactoryRuntimeState.cell_context(drill_pos, SourcePlayableScenarioDefaults.conveyor_cells())

func source_factory_simulation_runtime_state(seconds: float) -> Dictionary:
	var cell_context := factory_cell_context()
	var factory_context := SourceFactoryRuntimeState.simulation_context(seconds, transport_progress, cell_context, drill_pos)
	return SourceFactorySimulationRuntimeState.simulation_state(factory_context, SourceFactoryRuntimeState.simulation_callbacks(self))

func source_factory_simulation_apply_state(factory_state: Dictionary) -> Dictionary:
	var apply_context := SourceFactorySimulationApplyState.runtime_context(self, drill_pos)
	return SourceFactorySimulationApplyState.apply_state(factory_state, apply_context)

func factory_drill_dump_preview_state(seconds: float) -> Dictionary:
	return SourceFactoryRuntimeState.drill_dump_preview_state(self, SourceFactoryRuntimeState.drill_dump_preview_context(self, seconds, drill_pos, SourcePlayableScenarioDefaults.BLOCK_MECHANICAL_DRILL, SourceTimeDefaults.TICK_RATE))

func step_factory_transport(seconds: float) -> Dictionary:
	return SourceFactoryRuntimeState.transport_step_state(SourceFactoryRuntimeState.transport_step_context(self, seconds, factory_cell_context(), drill_pos))

func step_factory_drill(seconds: float) -> Dictionary:
	return SourceFactoryRuntimeState.drill_step_state(SourceFactoryRuntimeState.drill_step_context(self, seconds, drill_pos))

func factory_runtime_state() -> Dictionary:
	var factory_context := SourceFactoryRuntimeState.summary_context(
		self,
		factory_cell_context(),
		drill_pos,
		SourcePlayableScenarioDefaults.BLOCK_MECHANICAL_DRILL,
		SourcePlayableScenarioDefaults.BLOCK_CONVEYOR
	)
	return SourceFactoryRuntimeState.summary_state(factory_context, SourceFactoryRuntimeState.summary_callbacks(self))

func source_block_is_damaged(sprite) -> bool:
	if not is_instance_valid(sprite):
		return false
	return float(sprite.get_meta("source_block_health", 0.0)) < float(sprite.get_meta("source_block_max_health", 0.0)) - SourceBlockDefaults.HEALTH_DAMAGED_EPSILON

func source_mend_projector_range(mend_projector, phase_heat := 0.0) -> float:
	return SourceMendProjectorState.projector_range(mend_projector, phase_heat)

func find_damaged_block_in_mend_range(mend_cell: Vector2i, mend_projector, phase_heat := 0.0):
	var mend_origin := source_block_sprite_base_position(mend_projector, mend_cell)
	var real_range := source_mend_projector_range(mend_projector, phase_heat)
	for origin_key in placed_block_origins.keys():
		var sprite = placed_block_origins.get(origin_key)
		if not source_block_is_damaged(sprite):
			continue
		var target_block = block_from_sprite(sprite)
		if target_block == null:
			continue
		var target_cell: Vector2i = sprite.get_meta("origin_cell", Vector2i.ZERO)
		var target_origin := source_block_sprite_base_position(target_block, target_cell)
		if mend_origin.distance_to(target_origin) <= real_range:
			return sprite
	return null

func simulate_mend_projectors(delta: float) -> void:
	SourceMendProjectorState.simulate_projectors(self, delta)

func step_mend_projectors(seconds: float) -> Dictionary:
	return SourceMendProjectorState.step_projectors(self, seconds)

func find_overdrive_boost_target(overdrive_cell: Vector2i, overdrive_projector, phase_heat := 0.0):
	return SourceOverdriveProjectorState.find_overdrive_boost_target(self, overdrive_cell, overdrive_projector, phase_heat)

func apply_overdrive_boost_to_sprite(target, intensity: float, duration: float) -> Dictionary:
	return SourceOverdriveProjectorState.apply_overdrive_boost_to_sprite(self, target, intensity, duration)

func simulate_overdrive_projectors(delta: float) -> void:
	SourceOverdriveProjectorState.simulate_projectors(self, delta)

func step_overdrive_projectors(seconds: float) -> Dictionary:
	return SourceOverdriveProjectorState.step_projectors(self, seconds)

func selected_enemy_unit():
	return SourceEnemyUnitRuntimeState.selected_enemy_unit(self)

func spawn_enemy_wave() -> void:
	SourceEnemyUnitRuntimeState.spawn_wave(self)

func spawned_for_wave(group: Dictionary, wave_zero: int) -> int:
	return int(SourceWaveSpawnRuntimeState.spawned_for_wave_state(group, wave_zero).get("spawned", 0))

func spawn_enemy_unit(unit_type, index: int) -> void:
	SourceEnemyUnitRuntimeState.spawn_unit(self, unit_type, index)

func simulate_enemy_units(delta: float) -> void:
	SourceEnemyUnitRuntimeState.simulate_units(self, delta)

func source_wave_timing_runtime_state(seconds: float) -> Dictionary:
	return SourceWaveTimingRuntimeState.wave_timer_state(wave_cooldown, seconds * SourceTimeDefaults.TICK_RATE, SourcePlayableScenarioDefaults.PLAYABLE_WAVE_SPACING_SECONDS * SourceTimeDefaults.TICK_RATE, enemy_units.size())

func source_game_over_core_destroyed_state(core_health_value: float, game_over_value: bool, attack_mode := false) -> Dictionary:
	return SourceGameOverCoreDestroyedState.core_destroyed_state(core_health_value, game_over_value, attack_mode)

func apply_core_damage(amount: float) -> Dictionary:
	var game_over_state := source_game_over_core_destroyed_state(core_health, game_over)
	var damage_state := SourceCoreDamageRuntimeState.apply_state(amount, core_health, core_damage_taken_total, game_over, game_over_state, last_game_over_winner)
	core_health = float(damage_state.get("core_health", core_health))
	core_damage_taken_total = float(damage_state.get("core_damage_taken_total", core_damage_taken_total))
	game_over = bool(damage_state.get("game_over", game_over))
	last_game_over_winner = str(damage_state.get("winner", last_game_over_winner))
	return damage_state

func playthrough_runtime_state() -> Dictionary:
	return SourceGameRuntimeSummaryState.playthrough_state(self)

func game_over_runtime_state() -> Dictionary:
	return {
		"game_over": game_over,
		"last_game_over_winner": last_game_over_winner,
		"core_health": core_health,
		"core_damage_taken_total": core_damage_taken_total,
		"source_game_over": source_game_over_core_destroyed_state(core_health, game_over),
	}

func enemy_runtime_state() -> Dictionary:
	return SourceEnemyUnitRuntimeState.runtime_summary_state(self)

func source_unit_weapon_damage(unit_type) -> float:
	var callbacks := SourceUnitMetadataState.default_callbacks_state(self)
	return SourceUnitMetadataState.unit_weapon_damage(unit_type, callbacks.get("bullet_damage", Callable()))

func source_unit_world_speed(unit_type) -> float:
	return SourceUnitMetadataState.unit_world_speed(unit_type, SourceTimeDefaults.TICK_RATE)

func source_unit_hit_size(unit_type) -> float:
	return SourceUnitMetadataState.unit_hit_size(unit_type)

func source_unit_health(unit_type) -> float:
	return SourceUnitMetadataState.unit_health(unit_type)

func source_unit_is_grounded(elevation_value: float) -> bool:
	return SourceUnitUpdateState.is_grounded(elevation_value)

func source_unit_is_flying(elevation_value: float) -> bool:
	return SourceUnitUpdateState.is_flying(elevation_value)

func source_unit_check_target_state(elevation_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return SourceUnitUpdateState.check_target_state(elevation_value, target_air, target_ground)

func source_unit_can_drown_state(elevation_value: float, type_can_drown: bool) -> Dictionary:
	return SourceUnitUpdateState.can_drown_state(elevation_value, type_can_drown)

func source_unit_drown_floor_state(floor_on_value: Variant) -> Variant:
	return SourceUnitUpdateState.drown_floor_state(floor_on_value)

func source_unit_wobble_state(current_x: float, current_y: float, source_time: float, source_delta: float, elevation_value: float, unit_id: int) -> Dictionary:
	var callbacks := SourceUnitUpdateState.default_callbacks_state(self)
	return SourceUnitUpdateState.wobble_state(current_x, current_y, source_time, source_delta, elevation_value, unit_id, callbacks.get("sin_scaled", Callable()), callbacks.get("cos_scaled", Callable()))

func source_unit_move_at_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, acceleration: float, source_delta: float) -> Dictionary:
	var callbacks := SourceUnitUpdateState.default_callbacks_state(self)
	return SourceUnitUpdateState.move_at_state(vel_x, vel_y, vector_x, vector_y, acceleration, source_delta, callbacks.get("vec2_limit", Callable()))

func source_unit_move_at_default_accel_state(vector_x: float, vector_y: float, type_accel: float) -> Dictionary:
	return SourceUnitUpdateState.move_at_default_accel_state(vector_x, vector_y, type_accel)

func source_unit_approach_state(vel_x: float, vel_y: float, vector_x: float, vector_y: float, type_accel: float, speed_value: float, source_delta: float) -> Dictionary:
	return SourceUnitUpdateState.approach_state(vel_x, vel_y, vector_x, vector_y, type_accel, speed_value, source_delta)

func source_unit_rotate_move_motion_state(unit_rotation_degrees: float, vec_x: float, vec_y: float) -> Dictionary:
	return SourceUnitUpdateState.rotate_move_motion_state(unit_rotation_degrees, vec_x, vec_y)

func source_arc_mathf_mod_float(value: float, divisor: float) -> float:
	return SourceMathState.source_mod_float(value, divisor)

func source_arc_angles_forward_distance(angle1: float, angle2: float) -> float:
	return SourceMathState.source_angles_forward_distance(angle1, angle2)

func source_arc_angles_backward_distance(angle1: float, angle2: float) -> float:
	return SourceMathState.source_angles_backward_distance(angle1, angle2)

func source_arc_angles_angle_dist(angle_a: float, angle_b: float) -> float:
	return SourceMathState.source_angles_angle_dist(angle_a, angle_b)

func source_arc_angles_move_toward(angle: float, to: float, speed: float) -> float:
	return SourceMathState.source_angles_move_toward(angle, to, speed)

func source_unit_vec2_angle(vec_x: float, vec_y: float) -> float:
	return SourceMathState.source_vec2_angle(vec_x, vec_y)

func source_unit_rotate_move_rotation_state(current_rotation: float, vec_x: float, vec_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := SourceUnitUpdateState.default_callbacks_state(self)
	return SourceUnitUpdateState.rotate_move_rotation_state(current_rotation, vec_x, vec_y, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get("vec2_angle", Callable()), callbacks.get("angles_move_toward", Callable()))

func source_unit_aim_look_position_state(pos_x: float, pos_y: float) -> Dictionary:
	return SourceUnitUpdateState.aim_look_position_state(pos_x, pos_y)

func source_unit_aim_look_xy_state(target_x: float, target_y: float) -> Dictionary:
	return SourceUnitUpdateState.aim_look_xy_state(target_x, target_y)

func source_unit_look_at_angle_state(current_rotation: float, target_angle: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := SourceUnitUpdateState.default_callbacks_state(self)
	return SourceUnitUpdateState.look_at_angle_state(current_rotation, target_angle, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get("angles_move_toward", Callable()))

func source_arc_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	return SourceMathState.source_angles_angle(from_x, from_y, to_x, to_y)

func source_unit_look_at_position_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := SourceUnitUpdateState.default_callbacks_state(self)
	return SourceUnitUpdateState.look_at_position_state(current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get("angles_angle", Callable()), callbacks.get("angles_move_toward", Callable()))

func source_unit_look_at_xy_state(current_rotation: float, unit_x: float, unit_y: float, target_x: float, target_y: float, type_rotate_speed: float, speed_multiplier_value: float, source_delta: float) -> Dictionary:
	var callbacks := SourceUnitUpdateState.default_callbacks_state(self)
	return SourceUnitUpdateState.look_at_xy_state(current_rotation, unit_x, unit_y, target_x, target_y, type_rotate_speed, speed_multiplier_value, source_delta, callbacks.get("angles_angle", Callable()), callbacks.get("angles_move_toward", Callable()))

func source_unit_controller_predicates_state(controller_is_ai_controller: bool, controller_is_command_ai: bool) -> Dictionary:
	return SourceUnitUpdateState.controller_predicates_state(controller_is_ai_controller, controller_is_command_ai)

func source_unit_can_target_state(other_exists: bool, other_is_unit: bool, other_unit_check_target_result: bool, other_is_building: bool, type_target_air: bool, type_target_ground: bool) -> Dictionary:
	return SourceUnitUpdateState.can_target_state(other_exists, other_is_unit, other_unit_check_target_result, other_is_building, type_target_air, type_target_ground)

func source_unit_command_state(controller_is_command_ai: bool) -> Dictionary:
	return SourceUnitUpdateState.command_state(controller_is_command_ai)

func source_unit_is_missile_state(unit_is_timed_killc: bool) -> Dictionary:
	return SourceUnitUpdateState.is_missile_state(unit_is_timed_killc)

func source_unit_count_state(team_data_count_type_result: int, type_id: int) -> Dictionary:
	return SourceUnitUpdateState.count_state(team_data_count_type_result, type_id)

func source_unit_cap_state(team_is_wave_team: bool, rules_pvp: bool, state_is_campaign: bool, rules_disable_unit_cap: bool, team_ignore_unit_cap: bool, rules_unit_cap_variable: bool, rules_unit_cap: int, team_data_unit_cap: int) -> Dictionary:
	return SourceUnitUpdateState.cap_state(team_is_wave_team, rules_pvp, state_is_campaign, rules_disable_unit_cap, team_ignore_unit_cap, rules_unit_cap_variable, rules_unit_cap, team_data_unit_cap)

func source_unit_set_type_state(type_id: int, type_health: float, type_drag: float, type_armor: float, type_hit_size: float, mounts_length: int, type_weapons_size: int, abilities_length: int, type_abilities_size: int, first_ability_is_empty_data_ability: bool, controller_is_null: bool) -> Dictionary:
	return SourceUnitUpdateState.set_type_state(type_id, type_health, type_drag, type_armor, type_hit_size, mounts_length, type_weapons_size, abilities_length, type_abilities_size, first_ability_is_empty_data_ability, controller_is_null)

func source_weapons_setup_mounts_state(weapon_states: Array) -> Dictionary:
	return SourceWeaponsState.setup_mounts_state(weapon_states)

func source_weapons_set_rotation_state(mount_states: Array, source_rotation: float) -> Dictionary:
	return SourceWeaponsState.set_rotation_state(mount_states, source_rotation)

func source_weapons_control_state(mount_states: Array, rotate_value: bool, shoot_value: bool) -> Dictionary:
	return SourceWeaponsState.control_state(mount_states, rotate_value, shoot_value)

func source_weapons_control_rotate_shoot_state(mount_states: Array, rotate_shoot: bool) -> Dictionary:
	return SourceWeaponsState.control_rotate_shoot_state(mount_states, rotate_shoot)

func source_weapons_aim_state(mount_states: Array, unit_x: float, unit_y: float, target_x: float, target_y: float, aim_dst: float) -> Dictionary:
	return SourceWeaponsState.aim_state(mount_states, unit_x, unit_y, target_x, target_y, aim_dst)

func source_weapons_aim_position_state(mount_states: Array, unit_x: float, unit_y: float, position_x: float, position_y: float, aim_dst: float) -> Dictionary:
	return SourceWeaponsState.aim_position_state(mount_states, unit_x, unit_y, position_x, position_y, aim_dst)

func source_weapons_can_shoot_state(disarmed_value: bool) -> Dictionary:
	return SourceWeaponsState.can_shoot_state(disarmed_value)

func source_weapons_remove_continuous_bullet_cleanup_state(mount_states: Array, unit_id: int) -> Dictionary:
	return SourceWeaponsState.remove_continuous_bullet_cleanup_state(mount_states, unit_id)

func source_weapons_remove_sound_stop_state(mount_states: Array) -> Dictionary:
	return SourceWeaponsState.remove_sound_stop_state(mount_states)

func source_weapons_update_dispatch_state(mount_states: Array, unit_id: int) -> Dictionary:
	return SourceWeaponsState.update_dispatch_state(mount_states, unit_id)

func source_mathf_approach_delta(from_value: float, to_value: float, speed: float, source_delta: float) -> float:
	return SourceMathState.source_approach_delta(from_value, to_value, speed, source_delta)

func source_mathf_dst(x1: float, y1: float, x2: float, y2: float) -> float:
	return SourceMathState.source_dst(x1, y1, x2, y2)

func source_mathf_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return SourceMathState.source_lerp_delta(from_value, to_value, progress, source_delta)

func source_weapon_update_passive_timers_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_passive_timers_state(mount_state, weapon_state, unit_state, source_delta, callbacks.get("approach_delta", Callable()), callbacks.get("lerp_delta", Callable()))

func source_arc_angles_trns_vec(angle_degrees: float, x_value: float, y_value: float) -> Dictionary:
	return SourceMathState.source_angles_trns_vec(angle_degrees, x_value, y_value)

func source_weapon_update_mount_origin_state(unit_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_mount_origin_state(unit_state, weapon_state, callbacks.get("trns_vec", Callable()))

func source_weapon_update_auto_target_retarget_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, mount_x: float, mount_y: float, find_target_result_exists: bool) -> Dictionary:
	return SourceWeaponsState.update_auto_target_retarget_state(mount_state, weapon_state, bullet_state, source_delta, mount_x, mount_y, find_target_result_exists)

func source_weapon_update_auto_target_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, mount_x: float, mount_y: float, check_target_result: bool) -> Dictionary:
	return SourceWeaponsState.update_auto_target_invalidation_state(mount_state, weapon_state, bullet_state, mount_x, mount_y, check_target_result)

func source_weapon_update_auto_target_shoot_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, mount_x: float, mount_y: float, target_within_result: bool, predicted_aim: Dictionary) -> Dictionary:
	return SourceWeaponsState.update_auto_target_shoot_aim_state(mount_state, weapon_state, bullet_state, can_shoot, mount_x, mount_y, target_within_result, predicted_aim)

func source_weapon_update_rotate_toward_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, can_shoot: bool, source_delta: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_rotate_toward_state(mount_state, weapon_state, unit_state, can_shoot, source_delta, callbacks.get("trns_vec", Callable()), callbacks.get("angles_angle", Callable()), callbacks.get("move_toward_angle", Callable()), callbacks.get("angle_dist", Callable()))

func source_weapon_update_bullet_origin_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, mount_x: float, mount_y: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_bullet_origin_state(mount_state, weapon_state, unit_state, mount_x, mount_y, callbacks.get("trns_vec", Callable()), callbacks.get("angles_angle", Callable()))

func source_weapon_update_always_shooting_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.update_always_shooting_state(mount_state, weapon_state)

func source_weapon_update_continuous_invalidation_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.update_continuous_invalidation_state(mount_state, weapon_state, bullet_state)

func source_weapon_update_continuous_live_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, weapon_rotation: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_continuous_live_state(mount_state, weapon_state, unit_state, bullet_state, source_delta, bullet_x, bullet_y, weapon_rotation, callbacks.get("trns_vec", Callable()))

func source_weapon_update_continuous_sound_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, runtime_state: Dictionary, bullet_x: float, bullet_y: float) -> Dictionary:
	return SourceWeaponsState.update_continuous_sound_state(mount_state, weapon_state, bullet_state, runtime_state, bullet_x, bullet_y)

func source_weapon_update_continuous_laser_aim_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float, shoot_angle: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_continuous_laser_aim_state(mount_state, weapon_state, bullet_state, source_delta, bullet_x, bullet_y, shoot_angle, callbacks.get("mathf_dst", Callable()), callbacks.get("approach_delta", Callable()), callbacks.get("trns_vec", Callable()))

func source_status_apply_result(status_effect: String, duration: float, status_immune: bool) -> Dictionary:
	return SourceStatusApplyState.apply_result_state(status_effect, duration, status_immune)

func source_weapon_update_always_continuous_keepalive_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_always_continuous_keepalive_state(mount_state, weapon_state, bullet_state, unit_state, callbacks.get("status_apply_result", Callable()))

func source_weapon_update_continuous_idle_heat_sound_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary, source_delta: float, bullet_x: float, bullet_y: float) -> Dictionary:
	return SourceWeaponsState.update_continuous_idle_heat_sound_state(mount_state, weapon_state, unit_state, source_delta, bullet_x, bullet_y)

func source_weapon_update_alternating_side_flip_state(mount_state: Dictionary, weapon_state: Dictionary, unit_mount_states: Array) -> Dictionary:
	return SourceWeaponsState.update_alternating_side_flip_state(mount_state, weapon_state, unit_mount_states)

func source_weapon_update_active_sound_loop_state(mount_state: Dictionary, weapon_state: Dictionary, runtime_state: Dictionary, can_shoot: bool, unit_id: int) -> Dictionary:
	return SourceWeaponsState.update_active_sound_loop_state(mount_state, weapon_state, runtime_state, can_shoot, unit_id)

func source_weapon_update_velocity_length_state(unit_state: Dictionary, source_delta: float) -> Dictionary:
	return SourceWeaponsState.update_velocity_length_state(unit_state, source_delta)

func source_weapon_update_shoot_gate_prefix_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, can_shoot: bool, was_flipped: bool, vel_len: float) -> Dictionary:
	return SourceWeaponsState.update_shoot_gate_prefix_state(mount_state, weapon_state, bullet_state, can_shoot, was_flipped, vel_len)

func source_weapon_update_reload_gate_state(mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.update_reload_gate_state(mount_state, weapon_state)

func source_angles_angle_dist(a: float, b: float) -> float:
	return source_arc_angles_angle_dist(a, b)

func source_weapon_update_cone_gate_state(mount_state: Dictionary, weapon_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.update_cone_gate_state(mount_state, weapon_state, unit_state, callbacks.get("angle_dist", Callable()))

func source_weapon_update_shoot_call_reload_state(mount_state: Dictionary, weapon_state: Dictionary, unit_id: int, bullet_x: float, bullet_y: float, shoot_angle: float, shoot_gate: bool) -> Dictionary:
	return SourceWeaponsState.update_shoot_call_reload_state(mount_state, weapon_state, unit_id, bullet_x, bullet_y, shoot_angle, shoot_gate)

func source_weapon_shoot_charge_start_state(mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary, shoot_x: float, shoot_y: float, charge_rotation: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.shoot_charge_start_state(mount_state, weapon_state, bullet_state, unit_state, shoot_x, shoot_y, charge_rotation, callbacks.get("status_apply_result", Callable()))

func source_shoot_pattern_default_events(shoot_state: Dictionary) -> Array:
	return SourceWeaponsState.shoot_pattern_default_events(shoot_state)

func generated_shoot_pattern_default_events_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	return SourceWeaponsState.generated_shoot_pattern_default_events_bridge_state(shots, first_shot_delay, shot_delay)

func generated_shoot_pattern_default_events_default_bridge_state() -> Dictionary:
	return SourceWeaponsState.generated_shoot_pattern_default_events_default_bridge_state()

func generated_shoot_pattern_compat_dispatch_bridge_state(total_shots: int, shots: int, first_shot_delay: float, shot_delay: float, barrel_incrementer_present: bool) -> Dictionary:
	return SourceWeaponsState.generated_shoot_pattern_compat_dispatch_bridge_state(total_shots, shots, first_shot_delay, shot_delay, barrel_incrementer_present)

func generated_shoot_pattern_flip_bridge_state() -> Dictionary:
	return SourceWeaponsState.generated_shoot_pattern_flip_bridge_state()

func generated_shoot_pattern_copy_bridge_state(shots: int, first_shot_delay: float, shot_delay: float) -> Dictionary:
	return SourceWeaponsState.generated_shoot_pattern_copy_bridge_state(shots, first_shot_delay, shot_delay)

func source_weapon_shoot_default_pattern_dispatch_state(mount_state: Dictionary, shoot_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.shoot_default_pattern_dispatch_state(mount_state, shoot_state)

func source_weapon_bullet_initial_guard_state(unit_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.bullet_initial_guard_state(unit_state, mount_state)

func source_weapon_bullet_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.bullet_geometry_state(unit_state, mount_state, weapon_state, x_offset, y_offset, x_spread, y_spread, callbacks.get("trns_vec", Callable()))

func source_weapon_bullet_angle_life_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.bullet_angle_life_state(unit_state, mount_state, weapon_state, bullet_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, callbacks.get("trns_vec", Callable()), callbacks.get("bullet_origin_state", Callable()), callbacks.get("mathf_dst", Callable()))

func source_weapon_bullet_shooter_state(unit_state: Dictionary, controller_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.bullet_shooter_state(unit_state, controller_state)

func source_weapon_bullet_create_call_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, controller_state: Dictionary, x_offset: float, y_offset: float, x_spread: float, y_spread: float, angle_offset: float, angle_spread: float, velocity_random: float, mover: Variant) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.bullet_create_call_state(unit_state, mount_state, weapon_state, bullet_state, controller_state, x_offset, y_offset, x_spread, y_spread, angle_offset, angle_spread, velocity_random, mover, callbacks.get("trns_vec", Callable()), callbacks.get("bullet_origin_state", Callable()), callbacks.get("mathf_dst", Callable()))

func source_weapon_bullet_handle_call_state(unit_state: Dictionary, mount_state: Dictionary, create_call_state: Dictionary, created_bullet: Variant) -> Dictionary:
	return SourceWeaponsState.bullet_handle_call_state(unit_state, mount_state, create_call_state, created_bullet)

func source_weapon_handle_bullet_continuous_geometry_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.handle_bullet_continuous_geometry_state(unit_state, mount_state, weapon_state, callbacks.get("trns_vec", Callable()))

func source_weapon_handle_bullet_aim_update_state(unit_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.handle_bullet_aim_update_state(unit_state, mount_state, weapon_state, bullet_state, callbacks.get("trns_vec", Callable()), callbacks.get("bullet_origin_state", Callable()))

func source_weapon_bullet_sound_state(create_call_state: Dictionary, weapon_state: Dictionary, sound_pitch: float) -> Dictionary:
	return SourceWeaponsState.bullet_sound_state(create_call_state, weapon_state, sound_pitch)

func source_weapon_bullet_effects_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary, bullet_state: Dictionary, unit_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.bullet_effects_state(create_call_state, mount_state, weapon_state, bullet_state, unit_state)

func source_weapon_bullet_recoil_velocity_state(create_call_state: Dictionary, unit_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var callbacks := SourceWeaponsState.default_callbacks_state(self)
	return SourceWeaponsState.bullet_recoil_velocity_state(create_call_state, unit_state, bullet_state, callbacks.get("trns_vec", Callable()))

func source_weapon_bullet_shake_state(create_call_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.bullet_shake_state(create_call_state, weapon_state)

func source_weapon_bullet_mount_recoil_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.bullet_mount_recoil_state(create_call_state, mount_state)

func source_weapon_bullet_recoil_slots_state(create_call_state: Dictionary, mount_state: Dictionary, weapon_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.bullet_recoil_slots_state(create_call_state, mount_state, weapon_state)

func source_weapon_bullet_heat_state(create_call_state: Dictionary, mount_state: Dictionary) -> Dictionary:
	return SourceWeaponsState.bullet_heat_state(create_call_state, mount_state)

func source_bullet_type_create_initial_gate_state(create_call_state: Dictionary, bullet_type_state: Dictionary, random_angle_offset: float, create_chance_roll: float) -> Dictionary:
	return SourceBulletTypeCreateState.initial_gate_state(create_call_state, bullet_type_state, random_angle_offset, create_chance_roll)

func source_bullet_type_create_spawn_unit_state(initial_gate_state: Dictionary, bullet_type_state: Dictionary, net_client: bool, owner_health_state: Dictionary, shooter_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateState.spawn_unit_state(initial_gate_state, bullet_type_state, net_client, owner_health_state, shooter_state)

func source_bullet_type_create_bullet_identity_state(create_call_state: Dictionary, initial_gate_state: Dictionary, spawn_unit_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateState.bullet_identity_state(create_call_state, initial_gate_state, spawn_unit_state, bullet_type_state)

func source_bullet_type_create_aim_state(identity_state: Dictionary, create_call_state: Dictionary, target_state: Dictionary, world_tile_from_aim: Variant) -> Dictionary:
	return SourceBulletTypeCreateState.aim_state(identity_state, create_call_state, target_state, world_tile_from_aim)

func source_bullet_type_create_velocity_position_state(aim_state: Dictionary, initial_gate_state: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, velocity_scale_random_factor: float) -> Dictionary:
	return SourceBulletTypeCreateState.velocity_position_state(aim_state, initial_gate_state, create_call_state, bullet_type_state, velocity_scale_random_factor)

func source_bullet_type_create_lifetime_payload_damage_state(velocity_position_state: Dictionary, create_call_state: Dictionary, bullet_type_state: Dictionary, life_scale_random_factor: float, damage_multiplier_factor: float) -> Dictionary:
	return SourceBulletTypeCreateState.lifetime_payload_damage_state(velocity_position_state, create_call_state, bullet_type_state, life_scale_random_factor, damage_multiplier_factor)

func source_bullet_type_create_trail_add_state(lifetime_payload_damage_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateState.trail_add_state(lifetime_payload_damage_state)

func source_bullet_velocity_vector_state(velocity_state: Dictionary) -> Dictionary:
	var callbacks := SourceBulletTypeCreateState.default_callbacks_state(self)
	return SourceBulletTypeCreateState.velocity_vector_state(velocity_state, callbacks.get("trns_vec", Callable()))

func source_bullet_type_create_keep_velocity_state(trail_add_state: Dictionary, bullet_type_state: Dictionary, owner_state: Dictionary) -> Dictionary:
	var callbacks := SourceBulletTypeCreateState.default_callbacks_state(self)
	return SourceBulletTypeCreateState.keep_velocity_state(trail_add_state, bullet_type_state, owner_state, callbacks.get("trns_vec", Callable()))

func source_bullet_type_init_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitState.init_initial_state(bullet_state, bullet_type_state, owner_health_state)

func source_bullet_type_init_spawn_bullets_state(init_initial_state: Dictionary, bullet_type_state: Dictionary, spawn_bullet_random_offsets: Array) -> Dictionary:
	return SourceBulletTypeInitState.init_spawn_bullets_state(init_initial_state, bullet_type_state, spawn_bullet_random_offsets)

func source_bullet_type_update_dispatch_state(bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeUpdateState.update_dispatch_state(bullet_state)

func source_bullet_type_update_bullet_interval_state(bullet_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, interval_random_offsets: Array) -> Dictionary:
	return SourceBulletTypeUpdateState.update_bullet_interval_state(bullet_state, bullet_type_state, timer_get_result, interval_random_offsets)

func source_bullet_type_update_trail_state(bullet_state: Dictionary, bullet_type_state: Dictionary, headless_value: bool, trail_interp_value: float, absin_value: float, source_delta: float) -> Dictionary:
	return SourceBulletTypeUpdateState.update_trail_state(bullet_state, bullet_type_state, headless_value, trail_interp_value, absin_value, source_delta)

func source_bullet_type_update_homing_initial_state(bullet_state: Dictionary, bullet_type_state: Dictionary) -> Dictionary:
	return SourceBulletTypeUpdateState.update_homing_initial_state(bullet_state, bullet_type_state)

func source_bullet_type_update_homing_target_velocity_state(homing_initial_state: Dictionary, target_state: Variant, source_delta: float) -> Dictionary:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.update_homing_target_velocity_state(homing_initial_state, target_state, source_delta, callbacks.get("angles_angle", Callable()), callbacks.get("move_toward_angle", Callable()), callbacks.get("trns_vec", Callable()))

func source_bullet_type_update_homing_follow_aim_state(homing_target_velocity_state: Dictionary, bullet_type_state: Dictionary, shooter_state: Variant, source_delta: float) -> Dictionary:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.update_homing_follow_aim_state(homing_target_velocity_state, bullet_type_state, shooter_state, source_delta, callbacks.get("angles_angle", Callable()), callbacks.get("move_toward_angle", Callable()), callbacks.get("trns_vec", Callable()))

func source_bullet_type_update_weaving_state(bullet_state: Dictionary, bullet_type_state: Dictionary, random_seed_result: int, source_delta: float) -> Dictionary:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.update_weaving_state(bullet_state, bullet_type_state, random_seed_result, source_delta, callbacks.get("angles_angle", Callable()))

func source_bullet_type_update_weaving_rotate_speed_state(weaving_state: Dictionary, bullet_type_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.update_weaving_rotate_speed_state(weaving_state, bullet_type_state, source_delta, callbacks.get("angles_angle", Callable()))

func source_vec2_limit(vector_state: Dictionary, limit: float) -> Dictionary:
	return SourceMathState.source_vec2_limit(vector_state, limit)

func source_bullet_type_update_weaving_circle_shooter_state(rotate_speed_state: Dictionary, bullet_type_state: Dictionary, owner_health_state: Dictionary, source_delta: float) -> Dictionary:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.update_weaving_circle_shooter_state(rotate_speed_state, bullet_type_state, owner_health_state, source_delta, callbacks.get("vec2_limit", Callable()), callbacks.get("angles_angle", Callable()))

func source_bullet_rotation_degrees(bullet_state: Dictionary) -> float:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.bullet_rotation_degrees(bullet_state, callbacks.get("angles_angle", Callable()))

func source_bullet_type_update_trail_effects_chance_state(bullet_state: Dictionary, bullet_type_state: Dictionary, chance_delta_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.update_trail_effects_chance_state(bullet_state, bullet_type_state, chance_delta_result, random_offset_state, callbacks.get("bullet_rotation_degrees", Callable()))

func source_bullet_type_update_trail_effects_interval_state(chance_state: Dictionary, bullet_type_state: Dictionary, timer_get_result: bool, random_offset_state: Dictionary) -> Dictionary:
	var callbacks := SourceBulletTypeUpdateState.default_callbacks_state(self)
	return SourceBulletTypeUpdateState.update_trail_effects_interval_state(chance_state, bullet_type_state, timer_get_result, random_offset_state, callbacks.get("bullet_rotation_degrees", Callable()))

func source_bullet_type_init_type_defaults_state(bullet_type_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.init_type_defaults_state(bullet_type_state)

func source_bullet_type_init_frag_velocity_state(type_defaults_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.init_frag_velocity_state(type_defaults_state)

func source_bullet_type_init_lightning_type_state(frag_velocity_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.init_lightning_type_state(frag_velocity_state)

func source_bullet_type_init_light_radius_state(lightning_type_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.init_light_radius_state(lightning_type_state)

func source_bullet_type_init_draw_size_state(light_radius_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.init_draw_size_state(light_radius_state)

func source_bullet_type_init_range_assignment_state(draw_size_state: Dictionary, calculate_range_result: float) -> Dictionary:
	return SourceBulletTypeInitRangeState.init_range_assignment_state(draw_size_state, calculate_range_result)

func source_bullet_type_calculate_range_override_state(bullet_type_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.calculate_range_override_state(bullet_type_state)

func source_bullet_type_calculate_range_spawn_unit_state(override_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.calculate_range_spawn_unit_state(override_state)

func source_bullet_type_calculate_range_despawn_unit_state(spawn_unit_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.calculate_range_despawn_unit_state(spawn_unit_state)

func source_bullet_type_calculate_range_fallback_state(despawn_unit_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.calculate_range_fallback_state(despawn_unit_state)

func source_bullet_type_continuous_damage_default_state(bullet_type_state: Dictionary) -> Dictionary:
	return SourceBulletTypeInitRangeState.continuous_damage_default_state(bullet_type_state)

func source_bullet_type_heals_state(bullet_type_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitTileState.heals_state(bullet_type_state)

func source_bullet_type_test_collision_state(bullet_type_state: Dictionary, bullet_state: Dictionary, tile_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitTileState.test_collision_state(bullet_type_state, bullet_state, tile_state)

func source_bullet_type_hit_tile_fire_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitTileState.hit_tile_fire_state(bullet_type_state, bullet_state, build_state)

func source_bullet_type_hit_tile_heal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitTileState.hit_tile_heal_state(bullet_type_state, bullet_state, build_state)

func source_bullet_type_hit_tile_enemy_direct_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitTileState.hit_tile_enemy_direct_state(bullet_type_state, bullet_state, build_state, hit_tile_state)

func source_bullet_type_hit_tile_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, build_state: Dictionary, hit_tile_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitTileState.hit_tile_lifesteal_state(bullet_type_state, bullet_state, build_state, hit_tile_state, owner_health_state)

func source_bullet_type_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, pierce_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitTileState.handle_pierce_state(bullet_type_state, bullet_state, pierce_state)

func source_bullet_type_damage_multiplier_state(bullet_state: Dictionary, bullet_owner_state: Dictionary, rules_state: Dictionary) -> Dictionary:
	return SourceBulletTypeDamageState.damage_multiplier_state(bullet_state, bullet_owner_state, rules_state)

func source_bullet_type_hit_default_state(bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitCoreState.hit_default_state(bullet_state)

func source_bullet_type_hit_xy_default_state(bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitCoreState.hit_xy_default_state(bullet_state, hit_xy_state)

func source_bullet_type_hit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitCoreState.hit_effects_state(bullet_type_state, bullet_state, hit_xy_state)

func source_bullet_type_hit_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitCoreState.hit_frag_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, hit_frag_state)

func source_bullet_type_hit_post_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_frag_dispatch_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitCoreState.hit_post_frag_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, hit_frag_dispatch_state)

func source_bullet_type_create_incend_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_incend_state: Dictionary, incend_random_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateIncendState.create_state(bullet_type_state, bullet_state, create_incend_state, incend_random_state)

func source_bullet_type_create_units_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_state: Dictionary, create_units_random_state: Dictionary, net_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateUnitsState.initial_state(bullet_type_state, bullet_state, create_units_state, create_units_random_state, net_state)

func source_bullet_type_create_units_random_offset_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_initial_state: Dictionary, create_units_random_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateUnitsState.random_offset_state(bullet_type_state, bullet_state, create_units_initial_state, create_units_random_state)

func source_bullet_type_create_units_spawn_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_random_offset_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateUnitsState.spawn_state(bullet_type_state, bullet_state, create_units_random_offset_state)

func source_bullet_type_create_units_rotation_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_spawn_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateUnitsState.rotation_state(bullet_type_state, bullet_state, create_units_spawn_state)

func source_bullet_type_create_units_notify_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_units_rotation_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateUnitsState.notify_state(bullet_type_state, bullet_state, create_units_rotation_state)

func source_bullet_type_despawned_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeLifecycleState.despawned_dispatch_state(bullet_type_state, bullet_state)

func source_bullet_type_despawned_effect_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_dispatch_state: Dictionary) -> Dictionary:
	return SourceBulletTypeLifecycleState.despawned_effect_state(bullet_type_state, bullet_state, despawned_dispatch_state)

func source_bullet_type_despawned_sound_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_effect_state: Dictionary, despawn_sound_random_state: Dictionary) -> Dictionary:
	return SourceBulletTypeLifecycleState.despawned_sound_state(bullet_type_state, bullet_state, despawned_effect_state, despawn_sound_random_state)

func source_bullet_type_despawned_shake_state(bullet_type_state: Dictionary, bullet_state: Dictionary, despawned_sound_state: Dictionary) -> Dictionary:
	return SourceBulletTypeLifecycleState.despawned_shake_state(bullet_type_state, bullet_state, despawned_sound_state)

func source_bullet_type_removed_trail_fade_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeLifecycleState.removed_trail_fade_state(bullet_type_state, bullet_state)

func source_bullet_type_removed_frag_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, removed_trail_fade_state: Dictionary) -> Dictionary:
	return SourceBulletTypeLifecycleState.removed_frag_dispatch_state(bullet_type_state, bullet_state, removed_trail_fade_state)

func source_bullet_type_hit_suppression_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_post_frag_dispatch_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitCoreState.hit_suppression_state(bullet_type_state, bullet_state, hit_xy_state, hit_post_frag_dispatch_state)

func source_bullet_type_hit_splash_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_xy_state: Dictionary, hit_suppression_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitCoreState.hit_splash_damage_dispatch_state(bullet_type_state, bullet_state, hit_xy_state, hit_suppression_state)

func source_bullet_type_create_splash_damage_damage_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, hit_splash_damage_dispatch_state: Dictionary, damage_multiplier_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateSplashDamageState.damage_dispatch_state(bullet_type_state, bullet_state, hit_splash_damage_dispatch_state, damage_multiplier_state)

func source_bullet_type_create_splash_damage_status_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_damage_dispatch_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateSplashDamageState.status_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_damage_dispatch_state)

func source_bullet_type_create_splash_damage_heal_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_status_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateSplashDamageState.heal_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_status_dispatch_state, nearby_blocks_state)

func source_bullet_type_create_splash_damage_make_fire_dispatch_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_splash_damage_heal_dispatch_state: Dictionary, nearby_blocks_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateSplashDamageState.make_fire_dispatch_state(bullet_type_state, bullet_state, create_splash_damage_heal_dispatch_state, nearby_blocks_state)

func source_bullet_type_create_frags_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateFragsState.initial_state(bullet_type_state, bullet_state, create_frags_state)

func source_bullet_type_create_frags_random_geometry_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_initial_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateFragsState.random_geometry_state(bullet_type_state, bullet_state, create_frags_initial_state, frag_random_state)

func source_bullet_type_create_frags_create_call_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_frags_random_geometry_state: Dictionary, frag_random_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateFragsState.create_call_state(bullet_type_state, bullet_state, create_frags_random_geometry_state, frag_random_state, Callable(self, "source_arc_angles_trns_vec"))

func source_bullet_type_create_frags_increment_state(bullet_state: Dictionary, create_frags_create_call_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreateFragsState.increment_state(bullet_state, create_frags_create_call_state)

func source_bullet_type_create_puddles_initial_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreatePuddlesState.initial_state(bullet_type_state, bullet_state, create_puddles_state)

func source_bullet_type_create_puddles_tile_world_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_initial_state: Dictionary, puddle_random_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreatePuddlesState.tile_world_state(bullet_type_state, bullet_state, create_puddles_initial_state, puddle_random_state)

func source_bullet_type_create_puddles_deposit_state(bullet_type_state: Dictionary, bullet_state: Dictionary, create_puddles_tile_world_state: Dictionary) -> Dictionary:
	return SourceBulletTypeCreatePuddlesState.deposit_state(bullet_type_state, bullet_state, create_puddles_tile_world_state)

func source_bullet_type_hit_entity_damage_cap_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitState.entity_damage_cap_state(bullet_type_state, bullet_state, entity_state, hit_entity_state)
func source_bullet_type_hit_entity_lifesteal_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, owner_health_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitState.entity_lifesteal_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, owner_health_state)
func source_bullet_type_hit_entity_armor_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, hit_entity_state: Dictionary, damage_cap_state: Dictionary, lifesteal_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitState.entity_armor_damage_state(bullet_type_state, bullet_state, entity_state, hit_entity_state, damage_cap_state, lifesteal_state)
func source_bullet_type_hit_entity_unit_effects_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, armor_damage_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitState.entity_unit_effects_state(bullet_type_state, bullet_state, entity_state, armor_damage_state)
func source_bullet_type_hit_entity_unit_destroy_event_state(bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_effects_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitState.entity_unit_destroy_event_state(bullet_state, entity_state, damage_cap_state, unit_effects_state)
func source_bullet_type_hit_entity_handle_pierce_state(bullet_type_state: Dictionary, bullet_state: Dictionary, entity_state: Dictionary, damage_cap_state: Dictionary, unit_destroy_event_state: Dictionary) -> Dictionary:
	return SourceBulletTypeHitState.entity_handle_pierce_state(bullet_type_state, bullet_state, entity_state, damage_cap_state, unit_destroy_event_state, Callable(self, "source_bullet_type_handle_pierce_state"))
func source_bullet_type_building_damage_state(bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeDamageState.building_damage_state(bullet_state)

func source_bullet_type_shield_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeDamageState.shield_damage_state(bullet_type_state, bullet_state)

func source_bullet_type_draw_state(bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeDrawState.draw_state(bullet_state)

func source_bullet_type_draw_trail_state(bullet_type_state: Dictionary, bullet_state: Dictionary, current_draw_z: float) -> Dictionary:
	return SourceBulletTypeDrawState.draw_trail_state(bullet_type_state, bullet_state, current_draw_z)

func source_bullet_type_draw_parts_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeDrawState.draw_parts_state(bullet_type_state, bullet_state)

func source_bullet_type_draw_light_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	return SourceBulletTypeDrawState.draw_light_state(bullet_type_state, bullet_state)

func source_unit_player_controllable_state(type_player_controllable: bool, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_block_privileged: bool) -> Dictionary:
	return SourceUnitUpdateState.player_controllable_state(type_player_controllable, controller_is_logic_ai, logic_controller_exists, logic_controller_block_privileged)

func source_unit_targetable_state(type_targetable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, targeter_id: int) -> Dictionary:
	return SourceUnitUpdateState.targetable_state(type_targetable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, targeter_id)

func source_unit_killable_state(type_killable: bool) -> Dictionary:
	return SourceUnitUpdateState.killable_state(type_killable)

func source_unit_hittable_state(type_hittable: bool, type_vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool) -> Dictionary:
	return SourceUnitUpdateState.hittable_state(type_hittable, type_vulnerable_with_payloads, unit_is_payloadc, unit_has_payload)

func source_unit_after_sync_state(type_id: int, controller_exists: bool) -> Dictionary:
	return SourceUnitUpdateState.after_sync_state(type_id, controller_exists)

func source_unit_after_read_state(type_id: int, controller_is_ai_controller: bool, ai_keep_state: bool, controller_exists: bool) -> Dictionary:
	return SourceUnitUpdateState.after_read_state(type_id, controller_is_ai_controller, ai_keep_state, controller_exists)

func source_unit_after_read_all_state(controller_exists: bool) -> Dictionary:
	return SourceUnitUpdateState.after_read_all_state(controller_exists)

func source_unit_add_state(type_use_unit_cap: bool, count_after_add: int, cap_value: int, spawned_by_core: bool, dead: bool, rules_editor: bool) -> Dictionary:
	return SourceUnitUpdateState.add_state(type_use_unit_cap, count_after_add, cap_value, spawned_by_core, dead, rules_editor)

func source_unit_remove_state(trail_exists: bool, trail_size: int, trail_width: float, type_trail_color_exists: bool, team_color: String, type_trail_color: String) -> Dictionary:
	return SourceUnitDestroyState.remove_state(trail_exists, trail_size, trail_width, type_trail_color_exists, team_color, type_trail_color)

func source_unit_landed_state(type_mech_land_shake: float) -> Dictionary:
	return SourceUnitUpdateState.landed_state(type_mech_land_shake)

func source_unit_heal_state(current_health: float, max_health: float, amount: float, current_was_healed: bool) -> Dictionary:
	return SourceUnitUpdateState.heal_state(current_health, max_health, amount, current_was_healed)

func source_unit_update_heal_time_state(was_healed_value: bool, current_heal_time: float, source_delta: float) -> Dictionary:
	return SourceUnitUpdateState.heal_time_state(was_healed_value, current_heal_time, source_delta)

func source_unit_update_captured_sector_death_state(team_is_only_ai: bool, state_is_campaign: bool, sector_is_captured: bool) -> Dictionary:
	return SourceUnitUpdateState.captured_sector_death_state(team_is_only_ai, state_is_campaign, sector_is_captured)

func source_unit_update_sound_loop_state(headless_value: bool, type_loop_sound: String, type_loop_sound_volume: float, type_move_sound: String, type_move_sound_volume: float, type_move_sound_pitch_min: float, type_move_sound_pitch_max: float, velocity_x: float, velocity_y: float, type_speed: float) -> Dictionary:
	return SourceUnitUpdateState.sound_loop_state(headless_value, type_loop_sound, type_loop_sound_volume, type_move_sound, type_move_sound_volume, type_move_sound_pitch_min, type_move_sound_pitch_max, velocity_x, velocity_y, type_speed)

func source_unit_update_unsupported_env_state(type_supports_env: bool, dead_value: bool) -> Dictionary:
	return SourceUnitUpdateState.unsupported_env_state(type_supports_env, dead_value)

func source_unit_update_abilities_loop_state(ability_ids: Array) -> Dictionary:
	return SourceUnitUpdateState.abilities_loop_state(ability_ids)

func source_ability_update_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.update_state(unit)

func generated_ability_update_bridge_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.generated_update_bridge_state(unit)

func source_ability_draw_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.draw_state(unit)

func generated_ability_draw_bridge_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.generated_draw_bridge_state(unit)

func source_ability_death_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.death_state(unit)

func generated_ability_death_bridge_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.generated_death_bridge_state(unit)

func source_ability_created_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.created_state(unit)

func generated_ability_created_bridge_state(unit: Variant) -> Dictionary:
	return SourceAbilityState.generated_created_bridge_state(unit)

func source_ability_init_state(type_value: Variant) -> Dictionary:
	return SourceAbilityState.init_state(type_value)

func generated_ability_init_bridge_state(type_value: Variant) -> Dictionary:
	return SourceAbilityState.generated_init_bridge_state(type_value)

func source_ability_display_bars_state(unit: Variant, bars: Variant) -> Dictionary:
	return SourceAbilityState.display_bars_state(unit, bars)

func generated_ability_display_bars_bridge_state(unit: Variant, bars: Variant) -> Dictionary:
	return SourceAbilityState.generated_display_bars_bridge_state(unit, bars)

func source_ability_display_state(table_state: Variant, localized_value: String) -> Dictionary:
	return SourceAbilityState.display_state(table_state, localized_value)

func generated_ability_display_bridge_state(table_state: Variant, localized_value: String) -> Dictionary:
	return SourceAbilityState.generated_display_bridge_state(table_state, localized_value)

func source_ability_add_stats_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	return SourceAbilityState.add_stats_state(table_state, get_bundle_value, bundle_has_description, bundle_description)

func generated_ability_add_stats_bridge_state(table_state: Variant, get_bundle_value: String, bundle_has_description: bool, bundle_description: String) -> Dictionary:
	return SourceAbilityState.generated_add_stats_bridge_state(table_state, get_bundle_value, bundle_has_description, bundle_description)

func source_ability_ability_stat_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	return SourceAbilityState.ability_stat_state(stat_value, values, formatted_value)

func generated_ability_ability_stat_bridge_state(stat_value: String, values: Array, formatted_value: String) -> Dictionary:
	return SourceAbilityState.generated_ability_stat_bridge_state(stat_value, values, formatted_value)

func source_ability_copy_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	return SourceAbilityState.copy_state(clone_supported, clone_value, exception_value)

func generated_ability_copy_bridge_state(clone_supported: bool, clone_value: Variant, exception_value: Variant) -> Dictionary:
	return SourceAbilityState.generated_copy_bridge_state(clone_supported, clone_value, exception_value)

func source_ability_localized_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return SourceAbilityState.localized_state(get_bundle_value, bundle_value)

func generated_ability_localized_bridge_state(get_bundle_value: String, bundle_value: String) -> Dictionary:
	return SourceAbilityState.generated_localized_bridge_state(get_bundle_value, bundle_value)

func source_ability_get_bundle_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	return SourceAbilityState.get_bundle_state(class_simple_name, is_anonymous_class, superclass_simple_name)

func generated_ability_get_bundle_bridge_state(class_simple_name: String, is_anonymous_class: bool, superclass_simple_name: String) -> Dictionary:
	return SourceAbilityState.generated_get_bundle_bridge_state(class_simple_name, is_anonymous_class, superclass_simple_name)

func source_unit_update_trail_position_state(trail_exists: bool, type_trail_length: int, type_use_engine_elevation: bool, elevation_value: float, type_engine_offset: float, x_value: float, y_value: float, source_rotation_degrees: float) -> Dictionary:
	return SourceUnitUpdateState.trail_position_state(trail_exists, type_trail_length, type_use_engine_elevation, elevation_value, type_engine_offset, x_value, y_value, source_rotation_degrees)

func source_unit_update_drag_formula_state(type_drag: float, grounded_value: bool, floor_drag_multiplier: float, unit_drag_multiplier: float, rules_drag_multiplier: float) -> Dictionary:
	return SourceUnitUpdateState.drag_formula_state(type_drag, grounded_value, floor_drag_multiplier, unit_drag_multiplier, rules_drag_multiplier)

func source_unit_update_spawn_knockback_state(team_is_wave_team: bool, state_has_spawns_value: bool, net_client_value: bool, is_local_value: bool, hittable_value: bool, drop_zone_radius: float, hit_size: float, unit_x: float, unit_y: float, spawns: Array, source_delta: float) -> Dictionary:
	return SourceUnitUpdateState.spawn_knockback_state(team_is_wave_team, state_has_spawns_value, net_client_value, is_local_value, hittable_value, drop_zone_radius, hit_size, unit_x, unit_y, spawns, source_delta)

func source_unit_update_falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	return SourceUnitUpdateState.falling_drag_state(dead_value, health_value, current_drag)

func source_unit_update_falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	return SourceUnitUpdateState.falling_smoke_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, hit_size, tmp_v1_x, tmp_v1_y)

func source_unit_update_falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	return SourceUnitUpdateState.falling_engine_trail_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, source_rotation_degrees, elevation_value, type_engine_offset, type_engine_size, engine_range_value, x_range_value, y_range_value, random_rotation_value)

func source_unit_update_falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	return SourceUnitUpdateState.falling_descent_state(dead_value, health_value, elevation_value, type_fall_speed, source_delta, is_grounded_value, max_health, type_wreck_health_multiplier, unit_id)

func source_unit_update_tile_unit_on_any_state(tile_exists: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return SourceUnitUpdateState.tile_unit_on_any_state(tile_exists, tile_build_exists, unit_id)

func source_unit_update_tile_unit_on_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	return SourceUnitUpdateState.tile_unit_on_state(tile_exists, is_grounded_value, type_hovering, tile_build_exists, unit_id)

func source_unit_update_floor_damage_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, floor_damage_taken: float, source_delta: float, hit_time: float, hit_duration: float) -> Dictionary:
	return SourceUnitUpdateState.floor_damage_state(tile_exists, is_grounded_value, type_hovering, floor_damage_taken, source_delta, hit_time, hit_duration)

func source_unit_update_solid_tile_response_state(tile_exists: bool, can_pass_on_value: bool, type_can_boost: bool, current_elevation: float, net_client_value: bool, headless_value: bool, is_remote_value: bool, unit_id: int) -> Dictionary:
	return SourceUnitUpdateState.solid_tile_response_state(tile_exists, can_pass_on_value, type_can_boost, current_elevation, net_client_value, headless_value, is_remote_value, unit_id)

func source_unit_update_ai_controller_server_gate_state(net_client_value: bool, dead_value: bool, should_update_controller_value: bool, unit_id: int) -> Dictionary:
	return SourceUnitUpdateState.ai_controller_server_gate_state(net_client_value, dead_value, should_update_controller_value, unit_id)

func source_unit_update_invalid_controller_reset_state(controller_is_valid_value: bool, unit_id: int) -> Dictionary:
	return SourceUnitUpdateState.invalid_controller_reset_state(controller_is_valid_value, unit_id)

func source_unit_update_spawned_core_despawn_state(spawned_by_core_value: bool, is_player_value: bool, dead_value: bool, unit_id: int) -> Dictionary:
	return SourceUnitUpdateState.spawned_core_despawn_state(spawned_by_core_value, is_player_value, dead_value, unit_id)

func source_unit_icon_state(type_ui_icon: String) -> Dictionary:
	return SourceUnitMetadataState.unit_icon_state(type_ui_icon)

func source_unit_destroy_initial_payload_state(is_added_value: bool, killable_value: bool, item_explosiveness: float, item_flammability: float, item_charge: float, stack_amount: int) -> Dictionary:
	return SourceUnitDestroyState.initial_payload_state(is_added_value, killable_value, item_explosiveness, item_flammability, item_charge, stack_amount)

func source_unit_destroy_explosion_dispatch_state(spawned_by_core_value: bool, source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, bounds_value: float, type_leg_length: float, rules_damage_explosions: bool, rules_unit_crash_damage: float, item_flammability: float, team_id: int, death_explosion_effect: String) -> Dictionary:
	return SourceUnitDestroyState.explosion_dispatch_state(spawned_by_core_value, source_x, source_y, flammability, explosiveness, power, bounds_value, type_leg_length, rules_damage_explosions, rules_unit_crash_damage, item_flammability, team_id, death_explosion_effect)

func source_unit_destroy_visual_effects_state(source_x: float, source_y: float, hit_size: float, type_death_shake: float, type_create_scorch: bool, unit_id: int) -> Dictionary:
	return SourceUnitDestroyState.visual_effects_state(source_x, source_y, hit_size, type_death_shake, type_create_scorch, unit_id)

func source_unit_destroy_sound_and_event_state(death_sound: String, death_sound_volume: float, unit_id: int) -> Dictionary:
	return SourceUnitDestroyState.sound_and_event_state(death_sound, death_sound_volume, unit_id)

func source_unit_destroy_suicide_bomb_trigger_state(explosiveness: float, is_local_value: bool, was_player_value: bool) -> Dictionary:
	return SourceUnitDestroyState.suicide_bomb_trigger_state(explosiveness, is_local_value, was_player_value)

func source_unit_destroy_shoot_on_death_mounts_state(mount_states: Array, has_target_value: bool, source_x: float, source_y: float, source_rotation_degrees: float, unit_id: int) -> Dictionary:
	return SourceUnitDestroyState.shoot_on_death_mounts_state(mount_states, has_target_value, source_x, source_y, source_rotation_degrees, unit_id)

func source_unit_destroy_crash_landing_damage_state(type_flying: bool, spawned_by_core_value: bool, type_create_wreck: bool, rules_unit_crash_damage: float, hit_size: float, type_crash_damage_multiplier: float, shields_empty: bool, shield_absorbed: bool, team_id: int, source_x: float, source_y: float) -> Dictionary:
	return SourceUnitDestroyState.crash_landing_damage_state(type_flying, spawned_by_core_value, type_create_wreck, rules_unit_crash_damage, hit_size, type_crash_damage_multiplier, shields_empty, shield_absorbed, team_id, source_x, source_y)

func source_unit_destroy_wreck_decal_state(headless_value: bool, type_create_scorch: bool, wreck_regions: Array, tmp_offsets: Array, source_x: float, source_y: float, source_rotation_degrees: float, type_hit_size: float) -> Dictionary:
	return SourceUnitDestroyState.wreck_decal_state(headless_value, type_create_scorch, wreck_regions, tmp_offsets, source_x, source_y, source_rotation_degrees, type_hit_size)

func source_unit_destroy_ability_death_state(ability_states: Array, unit_id: int) -> Dictionary:
	return SourceUnitDestroyState.ability_death_state(ability_states, unit_id)

func source_unit_destroy_type_killed_remove_state(unit_id: int) -> Dictionary:
	return SourceUnitDestroyState.type_killed_remove_state(unit_id)

func source_unit_killed_state(is_local_value: bool, current_health: float, type_flying: bool, type_create_wreck: bool, wreck_sound: String, wreck_sound_volume: float, unit_id: int) -> Dictionary:
	return SourceUnitDestroyState.killed_state(is_local_value, current_health, type_flying, type_create_wreck, wreck_sound, wreck_sound_volume, unit_id)

func source_unit_kill_sync_state(dead_value: bool, net_client: bool, killable_value: bool, unit_id: int) -> Dictionary:
	return SourceUnitDestroyState.kill_sync_state(dead_value, net_client, killable_value, unit_id)

func source_unit_update_drowning_state(floor_exists: bool, floor_is_liquid: bool, floor_drown_time: float, can_drown_value: bool, current_drown_time: float, source_delta: float, hit_size: float, type_drown_time_multiplier: float, chance_delta_result: bool, net_client: bool) -> Dictionary:
	return SourceUnitUpdateState.drowning_state(floor_exists, floor_is_liquid, floor_drown_time, can_drown_value, current_drown_time, source_delta, hit_size, type_drown_time_multiplier, chance_delta_result, net_client)

func source_unit_update_type_hook_state() -> Dictionary:
	return SourceUnitUpdateState.type_hook_state()

func source_unit_update_bounds_state(type_bounded: bool, world_unit_height: float, world_unit_width: float, rules_limit_map_area: bool, team_is_ai: bool, rules_limit_x: int, rules_limit_y: int, rules_limit_width: int, rules_limit_height: int, current_x: float, current_y: float, elevation_value: float, net_client: bool, is_local: bool, source_delta: float) -> Dictionary:
	return SourceUnitUpdateState.bounds_state(type_bounded, world_unit_height, world_unit_width, rules_limit_map_area, team_is_ai, rules_limit_x, rules_limit_y, rules_limit_width, rules_limit_height, current_x, current_y, elevation_value, net_client, is_local, source_delta)

func source_unit_update_nan_health_state(current_health: float) -> Dictionary:
	return SourceUnitUpdateState.nan_health_state(current_health)

func source_unit_update_flying_transition_state(is_flying_value: bool, was_flying_value: bool, tile_exists: bool, floor_is_liquid: bool, tile_floor_color: String) -> Dictionary:
	return SourceUnitUpdateState.flying_transition_state(is_flying_value, was_flying_value, tile_exists, floor_is_liquid, tile_floor_color)

func source_unit_update_walk_effect_state(type_hovering: bool, elevation_value: float, type_emit_walk_effect: bool, type_emit_walk_sound: bool, current_splash_timer: float, delta_x: float, delta_y: float, hit_size_value: float, tile_exists: bool, tile_floor_color: String, floor_map_color: String, floor_walk_sound_pitch_min: float, floor_walk_sound_pitch_max: float, floor_walk_sound_volume: float, random_pitch_value: float) -> Dictionary:
	return SourceUnitUpdateState.walk_effect_state(type_hovering, elevation_value, type_emit_walk_effect, type_emit_walk_sound, current_splash_timer, delta_x, delta_y, hit_size_value, tile_exists, tile_floor_color, floor_map_color, floor_walk_sound_pitch_min, floor_walk_sound_pitch_max, floor_walk_sound_volume, random_pitch_value)

func source_unit_move_pref_state(type_omni_movement: bool, movement_x: float, movement_y: float) -> Dictionary:
	return SourceUnitUpdateState.move_pref_state(type_omni_movement, movement_x, movement_y)

func source_unit_floor_speed_multiplier_state(elevation_value: float, type_hovering: bool, floor_on_speed_multiplier: float, type_floor_multiplier: float, speed_multiplier_value: float) -> Dictionary:
	return SourceUnitUpdateState.floor_speed_multiplier_state(elevation_value, type_hovering, floor_on_speed_multiplier, type_floor_multiplier, speed_multiplier_value)

func source_unit_unloaded_state(unit_state: Variant) -> Variant:
	return SourceUnitUpdateState.unloaded_state(unit_state)

func source_unit_update_boosting_default_event_state(boost: bool) -> Dictionary:
	return SourceUnitUpdateState.boosting_default_event_state(boost)

func source_unit_update_boosting_guard_state(type_can_boost: bool, dead_state: bool, elevation_value: float) -> Dictionary:
	return SourceUnitUpdateState.boosting_guard_state(type_can_boost, dead_state, elevation_value)

func source_unit_update_boosting_should_boost_state(boost: bool, on_solid_result: bool, elevation_value: float, can_land_result: bool) -> Dictionary:
	return SourceUnitUpdateState.boosting_should_boost_state(boost, on_solid_result, elevation_value, can_land_result)

func source_arc_mathf_num(value: bool) -> int:
	return 1 if value else 0

func source_unit_update_boosting_elevation_state(current_elevation: float, type_can_boost: bool, should_boost: bool, type_rise_speed: float, type_descent_speed: float, source_delta: float) -> Dictionary:
	return SourceUnitUpdateState.boosting_elevation_state(current_elevation, type_can_boost, should_boost, type_rise_speed, type_descent_speed, source_delta)

func source_unit_update_boosting_event_state(event: bool) -> Dictionary:
	return SourceUnitUpdateState.boosting_event_state(event)

func selected_playable_turret():
	if content_catalog == null:
		return null
	return content_catalog.get_by_id(SourcePlayableScenarioDefaults.BLOCK_DUO)

func turret_simulation_callbacks() -> Dictionary:
	return SourceTurretSimulationState.simulation_callbacks(self)

func turret_random_inaccuracy_offset(inaccuracy_range: float) -> float:
	return randf_range(-inaccuracy_range, inaccuracy_range)

func simulate_turrets(delta: float) -> void:
	SourceTurretSimulationState.simulate_turrets(self, delta)

func selected_turret_ammo_sprite() -> String:
	return SourceTurretRuntimeState.selected_ammo_sprite(selected_playable_turret(), SourceBulletRuntimeState.SOURCE_BULLET_TEXTURE_DEFAULT)

func selected_turret_ammo_lifetime_seconds() -> float:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_lifetime_seconds(selected_playable_turret(), callbacks.get("lifetime_seconds", Callable()))

func selected_turret_limit_range_margin() -> float:
	return SourceTurretRuntimeState.selected_limit_range_margin(selected_playable_turret(), SourceTurretRuntimeState.SOURCE_TURRET_LIMIT_RANGE_MARGIN_DEFAULT)

func selected_turret_ammo_world_speed() -> float:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_world_speed(selected_playable_turret(), callbacks.get("world_speed", Callable()))

func selected_turret_ammo_dimensions() -> Dictionary:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_dimensions(selected_playable_turret(), callbacks.get("dimensions", Callable()))

func selected_turret_ammo_hit_size() -> float:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_hit_size(selected_playable_turret(), callbacks.get("hit_size", Callable()))

func selected_turret_ammo_damage() -> float:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_damage(selected_playable_turret(), callbacks.get("damage", Callable()))

func selected_turret_ammo_multiplier() -> float:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_multiplier(selected_playable_turret(), callbacks.get("ammo_multiplier", Callable()))

func selected_turret_ammo_reload_multiplier() -> float:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_reload_multiplier(selected_playable_turret(), callbacks.get("reload_multiplier", Callable()))

func selected_turret_ammo_range_change() -> float:
	var callbacks := SourceTurretRuntimeState.default_callbacks_state(self)
	return SourceTurretRuntimeState.selected_ammo_range_change(selected_playable_turret(), callbacks.get("range_change", Callable()))

func selected_turret_ammo_count() -> int:
	return SourceTurretRuntimeState.selected_ammo_count(selected_playable_turret())

func selected_turret_max_ammo() -> int:
	return SourceTurretRuntimeState.selected_max_ammo(selected_playable_turret(), SourceTurretDefaults.MAX_AMMO_DEFAULT)

func selected_turret_ammo_per_shot() -> int:
	return SourceTurretRuntimeState.selected_ammo_per_shot(selected_playable_turret(), SourceTurretDefaults.AMMO_PER_SHOT_DEFAULT)

func selected_turret_consume_ammo_once() -> bool:
	return SourceTurretRuntimeState.selected_consume_ammo_once(selected_playable_turret(), SourceTurretRuntimeState.SOURCE_TURRET_CONSUME_AMMO_ONCE_DEFAULT)

func selected_turret_total_ammo() -> int:
	return SourceTurretRuntimeState.selected_total_ammo(turret_total_ammo, cell_key(duo_pos))

func selected_turret_cooldown_seconds() -> float:
	return SourceTurretRuntimeState.selected_cooldown_seconds(turret_cooldowns, cell_key(duo_pos))

func selected_turret_ammo_stack_count() -> int:
	return SourceTurretRuntimeState.selected_ammo_stack_count(turret_ammo_stacks, cell_key(duo_pos))

func selected_turret_loaded_ammo_item() -> String:
	return SourceTurretRuntimeState.selected_loaded_ammo_item(turret_ammo_stacks, cell_key(duo_pos))

func source_turret_outputs_items_state() -> Dictionary:
	return SourceTurretRuntimeState.outputs_items_state()

func generated_turret_outputs_items_bridge_state() -> Dictionary:
	return SourceTurretRuntimeState.generated_outputs_items_bridge_state()

func source_block_outputs_items_state(has_items: bool) -> Dictionary:
	return SourceBlockQueryState.outputs_items_state(has_items)

func generated_block_outputs_items_bridge_state(has_items: bool) -> Dictionary:
	return SourceBlockQueryState.generated_block_outputs_items_bridge_state(has_items)

func source_block_can_place_on_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return SourceBlockQueryState.can_place_on_state(tile, team, rotation_value)

func generated_block_can_place_on_bridge_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return SourceBlockQueryState.generated_block_can_place_on_bridge_state(tile, team, rotation_value)

func source_block_can_break_state(tile: Variant) -> Dictionary:
	return SourceBlockQueryState.can_break_state(tile)

func generated_block_can_break_bridge_state(tile: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_can_break_bridge_state(tile)

func source_block_rotated_output_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return SourceBlockQueryState.rotated_output_state(rotate_value, x_value, y_value)

func generated_block_rotated_output_bridge_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return SourceBlockQueryState.generated_block_rotated_output_bridge_state(rotate_value, x_value, y_value)

func source_block_rotated_output_tile_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	return SourceBlockQueryState.rotated_output_tile_state(rotate_value, from_x, from_y, destination)

func generated_block_rotated_output_tile_bridge_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_rotated_output_tile_bridge_state(rotate_value, from_x, from_y, destination)

func source_block_synthetic_state(update_value: bool, destructible_value: bool) -> Dictionary:
	return SourceBlockQueryState.synthetic_state(update_value, destructible_value)

func generated_block_synthetic_bridge_state(update_value: bool, destructible_value: bool) -> Dictionary:
	return SourceBlockQueryState.generated_block_synthetic_bridge_state(update_value, destructible_value)

func source_block_check_force_dark_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return SourceBlockQueryState.check_force_dark_state(force_dark_value, tile)

func generated_block_check_force_dark_bridge_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_check_force_dark_bridge_state(force_dark_value, tile)

func source_block_is_darkened_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	return SourceBlockQueryState.is_darkened_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

func generated_block_is_darkened_bridge_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_is_darkened_bridge_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)

func source_block_consumes_item_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	return SourceBlockQueryState.consumes_item_state(item_filter, item_id, item)

func generated_block_consumes_item_bridge_state(item_filter: Array, item_id: int, item: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_consumes_item_bridge_state(item_filter, item_id, item)

func source_block_consumes_liquid_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	return SourceBlockQueryState.consumes_liquid_state(liquid_filter, liquid_id, liq)

func generated_block_consumes_liquid_bridge_state(liquid_filter: Array, liquid_id: int, liq: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_consumes_liquid_bridge_state(liquid_filter, liquid_id, liq)

func source_block_has_building_state(destructible_value: bool, update_value: bool) -> Dictionary:
	return SourceBlockQueryState.has_building_state(destructible_value, update_value)

func generated_block_has_building_bridge_state(destructible_value: bool, update_value: bool) -> Dictionary:
	return SourceBlockQueryState.generated_block_has_building_bridge_state(destructible_value, update_value)

func source_block_is_multiblock_state(size_value: int) -> Dictionary:
	return SourceBlockQueryState.is_multiblock_state(size_value)

func generated_block_is_multiblock_bridge_state(size_value: int) -> Dictionary:
	return SourceBlockQueryState.generated_block_is_multiblock_bridge_state(size_value)

func source_block_is_air_state(id_value: int) -> Dictionary:
	return SourceBlockQueryState.is_air_state(id_value)

func generated_block_is_air_bridge_state(id_value: int) -> Dictionary:
	return SourceBlockQueryState.generated_block_is_air_bridge_state(id_value)

func source_block_can_be_built_state(build_visibility_value: String) -> Dictionary:
	return SourceBlockQueryState.can_be_built_state(build_visibility_value)

func generated_block_can_be_built_bridge_state(build_visibility_value: String) -> Dictionary:
	return SourceBlockQueryState.generated_block_can_be_built_bridge_state(build_visibility_value)

func source_block_is_static_state(cache_layer_value: String) -> Dictionary:
	return SourceBlockQueryState.is_static_state(cache_layer_value)

func generated_block_is_static_bridge_state(cache_layer_value: String) -> Dictionary:
	return SourceBlockQueryState.generated_block_is_static_bridge_state(cache_layer_value)

func source_block_has_consumer_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return SourceBlockQueryState.has_consumer_state(consume_builder_contains, cons)

func generated_block_has_consumer_bridge_state(consume_builder_contains: bool, cons: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_has_consumer_bridge_state(consume_builder_contains, cons)

func source_block_remove_consumer_state(consumers_length: int, cons: Variant) -> Dictionary:
	return SourceBlockQueryState.remove_consumer_state(consumers_length, cons)

func generated_block_remove_consumer_bridge_state(consumers_length: int, cons: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_remove_consumer_bridge_state(consumers_length, cons)

func source_block_remove_consumers_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	return SourceBlockQueryState.remove_consumers_state(consume_builder_contains_power_after_remove, b)

func generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove: bool, b: Variant) -> Dictionary:
	return SourceBlockQueryState.generated_block_remove_consumers_bridge_state(consume_builder_contains_power_after_remove, b)

func source_block_consume_liquid_state(liquid: Variant, amount: float) -> Dictionary:
	return SourceBlockConsumeState.consume_liquid_state(liquid, amount)

func generated_block_consume_liquid_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_liquid_bridge_state(liquid, amount)

func source_block_consume_liquids_state(stacks: Variant) -> Dictionary:
	return SourceBlockConsumeState.consume_liquids_state(stacks)

func generated_block_consume_liquids_bridge_state(stacks: Variant) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_liquids_bridge_state(stacks)

func source_block_consume_power_state(power_per_tick: float) -> Dictionary:
	return SourceBlockConsumeState.consume_power_state(power_per_tick)

func generated_block_consume_power_bridge_state(power_per_tick: float) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_power_bridge_state(power_per_tick)

func source_block_consume_power_cond_state(usage: float, cons: Variant) -> Dictionary:
	return SourceBlockConsumeState.consume_power_cond_state(usage, cons)

func generated_block_consume_power_cond_bridge_state(usage: float, cons: Variant) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_power_cond_bridge_state(usage, cons)

func source_block_consume_power_dynamic_state(usage: Variant) -> Dictionary:
	return SourceBlockConsumeState.consume_power_dynamic_state(usage)

func generated_block_consume_power_dynamic_bridge_state(usage: Variant) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_power_dynamic_bridge_state(usage)

func source_block_consume_power_dynamic_displayed_state(displayed: float, usage: Variant) -> Dictionary:
	return SourceBlockConsumeState.consume_power_dynamic_displayed_state(displayed, usage)

func generated_block_consume_power_dynamic_displayed_bridge_state(displayed: float, usage: Variant) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_power_dynamic_displayed_bridge_state(displayed, usage)

func source_block_consume_power_buffered_state(power_capacity: float) -> Dictionary:
	return SourceBlockConsumeState.consume_power_buffered_state(power_capacity)

func generated_block_consume_power_buffered_bridge_state(power_capacity: float) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_power_buffered_bridge_state(power_capacity)

func source_block_consume_item_single_state(item: Variant) -> Dictionary:
	return SourceBlockConsumeState.consume_item_single_state(item)

func generated_block_consume_item_single_bridge_state(item: Variant) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_item_single_bridge_state(item)

func source_block_consume_item_amount_state(item: Variant, amount: int) -> Dictionary:
	return SourceBlockConsumeState.consume_item_amount_state(item, amount)

func generated_block_consume_item_amount_bridge_state(item: Variant, amount: int) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_item_amount_bridge_state(item, amount)

func source_block_consume_items_varargs_state(items: Array) -> Dictionary:
	return SourceBlockConsumeState.consume_items_varargs_state(items)

func generated_block_consume_items_varargs_bridge_state(items: Array) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_items_varargs_bridge_state(items)

func source_block_consume_coolant_single_state(amount: float) -> Dictionary:
	return SourceBlockConsumeState.consume_coolant_single_state(amount)

func generated_block_consume_coolant_single_bridge_state(amount: float) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_coolant_single_bridge_state(amount)

func source_block_consume_coolant_filtered_state(amount: float, allow_liquid: bool, allow_gas: bool) -> Dictionary:
	return SourceBlockConsumeState.consume_coolant_filtered_state(amount, allow_liquid, allow_gas)

func generated_block_consume_coolant_filtered_bridge_state(amount: float, allow_liquid: bool, allow_gas: bool) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_coolant_filtered_bridge_state(amount, allow_liquid, allow_gas)

func source_block_consume_generic_state(consume: Variant, consume_is_power: bool, consume_builder_before: Array, consume_builder_without_power: Array, cons_power_before: Variant) -> Dictionary:
	return SourceBlockConsumeState.consume_generic_state(consume, consume_is_power, consume_builder_before, consume_builder_without_power, cons_power_before)

func generated_block_consume_generic_bridge_state(consume: Variant, consume_is_power: bool, consume_builder_before: Array, consume_builder_without_power: Array, cons_power_before: Variant) -> Dictionary:
	return SourceBlockConsumeState.generated_block_consume_generic_bridge_state(consume, consume_is_power, consume_builder_before, consume_builder_without_power, cons_power_before)

func source_block_setup_requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.setup_requirements_simple_state(cat, stacks)

func generated_block_setup_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.generated_block_setup_requirements_simple_bridge_state(cat, stacks)

func source_block_setup_requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.setup_requirements_visible_state(cat, build_visibility, stacks)

func generated_block_setup_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.generated_block_setup_requirements_visible_bridge_state(cat, build_visibility, stacks)

func source_block_requirements_unlocked_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return SourceBlockRequirementsState.requirements_unlocked_state(cat, stacks, unlocked)

func generated_block_requirements_unlocked_bridge_state(cat: Variant, stacks: Variant, unlocked: bool) -> Dictionary:
	return SourceBlockRequirementsState.generated_block_requirements_unlocked_bridge_state(cat, stacks, unlocked)

func source_block_requirements_simple_state(cat: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.requirements_simple_state(cat, stacks)

func generated_block_requirements_simple_bridge_state(cat: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.generated_block_requirements_simple_bridge_state(cat, stacks)

func source_block_requirements_visible_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.requirements_visible_state(cat, build_visibility, stacks)

func generated_block_requirements_visible_bridge_state(cat: Variant, build_visibility: Variant, stacks: Variant) -> Dictionary:
	return SourceBlockRequirementsState.generated_block_requirements_visible_bridge_state(cat, build_visibility, stacks)

func source_block_init_building_default_state(build_type_before: Variant) -> Dictionary:
	return SourceBlockInitRuntimeState.building_default_state(build_type_before)

func generated_block_init_building_default_bridge_state(build_type_before: Variant) -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_init_building_default_bridge_state(build_type_before)

func source_block_research_requirements_research_cost_state(research_cost: Variant) -> Dictionary:
	return SourceBlockResearchRequirementsState.research_cost_state(research_cost)

func generated_block_research_requirements_research_cost_bridge_state(research_cost: Variant) -> Dictionary:
	return SourceBlockResearchRequirementsState.generated_block_research_requirements_research_cost_bridge_state(research_cost)

func source_block_research_requirements_empty_state(research_cost: Variant, research_cost_multiplier: float) -> Dictionary:
	return SourceBlockResearchRequirementsState.empty_state(research_cost, research_cost_multiplier)

func generated_block_research_requirements_empty_bridge_state(research_cost: Variant, research_cost_multiplier: float) -> Dictionary:
	return SourceBlockResearchRequirementsState.generated_block_research_requirements_empty_bridge_state(research_cost, research_cost_multiplier)

func source_block_research_requirements_loop_shape_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array) -> Dictionary:
	return SourceBlockResearchRequirementsState.loop_shape_state(research_cost, research_cost_multiplier, requirements)

func generated_block_research_requirements_loop_shape_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array) -> Dictionary:
	return SourceBlockResearchRequirementsState.generated_block_research_requirements_loop_shape_bridge_state(research_cost, research_cost_multiplier, requirements)

func source_block_research_requirements_quantity_formula_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return SourceBlockResearchRequirementsState.quantity_formula_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func generated_block_research_requirements_quantity_formula_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return SourceBlockResearchRequirementsState.generated_block_research_requirements_quantity_formula_bridge_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func source_block_research_requirements_round_amount_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return SourceBlockResearchRequirementsState.round_amount_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func generated_block_research_requirements_round_amount_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return SourceBlockResearchRequirementsState.generated_block_research_requirements_round_amount_bridge_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func source_block_research_requirements_output_fill_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return SourceBlockResearchRequirementsState.output_fill_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func generated_block_research_requirements_output_fill_bridge_state(research_cost: Variant, research_cost_multiplier: float, requirements: Array, research_cost_multipliers: Dictionary) -> Dictionary:
	return SourceBlockResearchRequirementsState.generated_block_research_requirements_output_fill_bridge_state(research_cost, research_cost_multiplier, requirements, research_cost_multipliers)

func source_block_get_dependencies_requirements_state(requirements: Array) -> Dictionary:
	return SourceBlockGetDependenciesState.requirements_state(requirements)

func generated_block_get_dependencies_requirements_bridge_state(requirements: Array) -> Dictionary:
	return SourceBlockGetDependenciesState.generated_block_get_dependencies_requirements_bridge_state(requirements)

func source_block_get_dependencies_consume_builder_optional_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return SourceBlockGetDependenciesState.consume_builder_optional_state(requirements, consume_builder)

func generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return SourceBlockGetDependenciesState.generated_block_get_dependencies_consume_builder_optional_bridge_state(requirements, consume_builder)

func source_block_get_dependencies_consume_items_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return SourceBlockGetDependenciesState.consume_items_state(requirements, consume_builder)

func generated_block_get_dependencies_consume_items_bridge_state(requirements: Array, consume_builder: Array) -> Dictionary:
	return SourceBlockGetDependenciesState.generated_block_get_dependencies_consume_items_bridge_state(requirements, consume_builder)

func source_block_get_content_type_state() -> Dictionary:
	return SourceBlockMetadataState.content_type_state()

func generated_block_get_content_type_bridge_state() -> Dictionary:
	return SourceBlockMetadataState.generated_content_type_bridge_state()

func source_block_logic_visible_state(build_visibility_value: String) -> Dictionary:
	return SourceBlockMetadataState.logic_visible_state(build_visibility_value)

func generated_block_logic_visible_bridge_state(build_visibility_value: String) -> Dictionary:
	return SourceBlockMetadataState.generated_logic_visible_bridge_state(build_visibility_value)

func source_block_post_init_database_tag_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	return SourceBlockPostInitState.database_tag_state(database_tag_before, category_name)

func generated_block_post_init_database_tag_bridge_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	return SourceBlockPostInitState.generated_database_tag_bridge_state(database_tag_before, category_name)

func source_block_post_init_shown_planets_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	return SourceBlockPostInitState.shown_planets_state(requirements, shown_planets_before, content_planets)

func generated_block_post_init_shown_planets_bridge_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	return SourceBlockPostInitState.generated_shown_planets_bridge_state(requirements, shown_planets_before, content_planets)

func source_block_init_destroy_sound_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	return SourceBlockInitSoundState.destroy_sound_state(destroy_sound_before, size_value)

func generated_block_init_destroy_sound_bridge_state(destroy_sound_before: Variant, size_value: int) -> Dictionary:
	return SourceBlockInitSoundState.generated_block_init_destroy_sound_bridge_state(destroy_sound_before, size_value)

func source_block_init_place_sound_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	return SourceBlockInitSoundState.place_sound_state(place_sound_before, size_value)

func generated_block_init_place_sound_bridge_state(place_sound_before: Variant, size_value: int) -> Dictionary:
	return SourceBlockInitSoundState.generated_block_init_place_sound_bridge_state(place_sound_before, size_value)

func source_block_init_break_sound_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	return SourceBlockInitSoundState.break_sound_state(break_sound_before, size_value)

func generated_block_init_break_sound_bridge_state(break_sound_before: Variant, size_value: int) -> Dictionary:
	return SourceBlockInitSoundState.generated_block_init_break_sound_bridge_state(break_sound_before, size_value)

func source_block_init_custom_shadow_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	return SourceBlockInitFlagsState.custom_shadow_state(custom_shadow, has_shadow_before)

func generated_block_init_custom_shadow_bridge_state(custom_shadow: bool, has_shadow_before: bool) -> Dictionary:
	return SourceBlockInitFlagsState.generated_custom_shadow_bridge_state(custom_shadow, has_shadow_before)

func source_block_init_under_bullets_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	return SourceBlockInitFlagsState.under_bullets_state(under_bullets, priority_before)

func generated_block_init_under_bullets_bridge_state(under_bullets: bool, priority_before: Variant) -> Dictionary:
	return SourceBlockInitFlagsState.generated_under_bullets_bridge_state(under_bullets, priority_before)

func source_block_init_fog_radius_flag_state(fog_radius: int, flags_before: Array) -> Dictionary:
	return SourceBlockInitFlagsState.fog_radius_flag_state(fog_radius, flags_before)

func generated_block_init_fog_radius_flag_bridge_state(fog_radius: int, flags_before: Array) -> Dictionary:
	return SourceBlockInitFlagsState.generated_fog_radius_flag_bridge_state(fog_radius, flags_before)

func source_block_init_sync_flag_state(sync_value: bool, flags_before: Array) -> Dictionary:
	return SourceBlockInitFlagsState.sync_flag_state(sync_value, flags_before)

func generated_block_init_sync_flag_bridge_state(sync_value: bool, flags_before: Array) -> Dictionary:
	return SourceBlockInitFlagsState.generated_sync_flag_bridge_state(sync_value, flags_before)

func source_block_init_health_scaled_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	return SourceBlockInitHealthState.health_scaled_state(health_before, size_value, scaled_health)

func generated_block_init_health_scaled_bridge_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	return SourceBlockInitHealthState.generated_health_scaled_bridge_state(health_before, size_value, scaled_health)

func source_block_init_health_requirements_scaling_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	return SourceBlockInitHealthState.health_requirements_scaling_state(health_before, size_value, scaled_health_before, requirement_health_scalings)

func generated_block_init_health_requirements_scaling_bridge_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	return SourceBlockInitHealthState.generated_health_requirements_scaling_bridge_state(health_before, size_value, scaled_health_before, requirement_health_scalings)

func source_block_init_clip_size_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBlockInitClipState.clip_size_state(clip_size_before, size_value, source_tilesize)

func generated_block_init_clip_size_bridge_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBlockInitClipState.generated_clip_size_bridge_state(clip_size_before, size_value, source_tilesize)

func source_block_init_light_clip_size_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	return SourceBlockInitClipState.light_clip_size_state(light_clip_size_before, clip_size)

func generated_block_init_light_clip_size_bridge_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	return SourceBlockInitClipState.generated_light_clip_size_bridge_state(light_clip_size_before, clip_size)

func source_block_init_liquid_light_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	return SourceBlockInitClipState.liquid_light_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value)

func generated_block_init_liquid_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	return SourceBlockInitClipState.generated_liquid_light_bridge_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value)

func source_block_init_liquid_capacity_default_state(liquid_capacity_before: float) -> Dictionary:
	return SourceBlockInitClipState.liquid_capacity_default_state(liquid_capacity_before)

func generated_block_init_liquid_capacity_default_bridge_state(liquid_capacity_before: float) -> Dictionary:
	return SourceBlockInitClipState.generated_liquid_capacity_default_bridge_state(liquid_capacity_before)

func source_block_init_emit_light_radius_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	return SourceBlockInitClipState.emit_light_radius_state(emit_light, light_clip_size_before, light_radius)

func generated_block_init_emit_light_radius_bridge_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	return SourceBlockInitClipState.generated_emit_light_radius_bridge_state(emit_light, light_clip_size_before, light_radius)

func source_block_init_accepts_items_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	return SourceBlockInitPlacementState.accepts_items_state(block_group, category_value, accepts_items_before)

func generated_block_init_accepts_items_bridge_state(block_group: Variant, category_value: Variant, accepts_items_before: bool) -> Dictionary:
	return SourceBlockInitPlacementState.generated_accepts_items_bridge_state(block_group, category_value, accepts_items_before)

func source_block_init_offset_state(size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBlockInitPlacementState.offset_state(size_value, source_tilesize)

func generated_block_init_offset_bridge_state(size_value: int, source_tilesize: float) -> Dictionary:
	return SourceBlockInitPlacementState.generated_offset_bridge_state(size_value, source_tilesize)

func source_block_init_build_time_requirements_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	return SourceBlockInitBuildTimeState.requirements_state(build_time_before, requirement_stacks)

func generated_block_init_build_time_requirements_bridge_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	return SourceBlockInitBuildTimeState.generated_requirements_bridge_state(build_time_before, requirement_stacks)

func source_block_init_build_time_default_state(build_time_before: float) -> Dictionary:
	return SourceBlockInitBuildTimeState.default_state(build_time_before)

func generated_block_init_build_time_default_bridge_state(build_time_before: float) -> Dictionary:
	return SourceBlockInitBuildTimeState.generated_default_bridge_state(build_time_before)

func source_block_init_build_time_multiplier_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	return SourceBlockInitBuildTimeState.multiplier_state(build_time_before, build_cost_multiplier)

func generated_block_init_build_time_multiplier_bridge_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	return SourceBlockInitBuildTimeState.generated_multiplier_bridge_state(build_time_before, build_cost_multiplier)

func source_block_init_consumer_arrays_state(consume_builder: Array) -> Dictionary:
	return SourceBlockInitConsumerState.arrays_state(consume_builder)

func generated_block_init_consumer_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	return SourceBlockInitConsumerState.generated_consumer_arrays_bridge_state(consume_builder)

func source_block_reinitialize_consumers_arrays_state(consume_builder: Array) -> Dictionary:
	return SourceBlockReinitializeConsumersState.arrays_state(consume_builder)

func generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder: Array) -> Dictionary:
	return SourceBlockReinitializeConsumersState.generated_block_reinitialize_consumers_arrays_bridge_state(consume_builder)

func source_block_reinitialize_consumers_item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return SourceBlockReinitializeConsumersState.item_liquid_filters_state(content_items_size, content_liquids_size)

func generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return SourceBlockReinitializeConsumersState.generated_block_reinitialize_consumers_item_liquid_filters_bridge_state(content_items_size, content_liquids_size)

func source_block_reinitialize_consumers_outputs_power_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	return SourceBlockReinitializeConsumersState.outputs_power_state(outputs_power, has_power_before)

func generated_block_reinitialize_consumers_outputs_power_bridge_state(outputs_power: bool, has_power_before: bool) -> Dictionary:
	return SourceBlockReinitializeConsumersState.generated_block_reinitialize_consumers_outputs_power_bridge_state(outputs_power, has_power_before)

func source_block_reinitialize_consumers_apply_loop_state(consumers: Array) -> Dictionary:
	return SourceBlockReinitializeConsumersState.apply_loop_state(consumers)

func generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	return SourceBlockReinitializeConsumersState.generated_block_reinitialize_consumers_apply_loop_bridge_state(consumers)

func source_block_check_content_array_capacity_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	return SourceBlockInitRuntimeState.check_content_array_capacity_state(item_filter, liquid_filter, items, liquids)

func generated_block_check_content_array_capacity_bridge_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_check_content_array_capacity_bridge_state(item_filter, liquid_filter, items, liquids)

func source_block_load_base_regions_state(name_value: String) -> Dictionary:
	return SourceBlockLoadState.base_regions_state(name_value)

func generated_block_load_base_regions_bridge_state(name_value: String) -> Dictionary:
	return SourceBlockLoadState.generated_block_load_base_regions_bridge_state(name_value)

func source_block_load_team_regions_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	return SourceBlockLoadState.team_regions_state(name_value, team_region_found, team_region, teams)

func generated_block_load_team_regions_bridge_state(name_value: String, team_region_found: bool, team_region: Variant, teams: Array) -> Dictionary:
	return SourceBlockLoadState.generated_block_load_team_regions_bridge_state(name_value, team_region_found, team_region, teams)

func source_block_load_variant_regions_state(name_value: String, variants: int) -> Dictionary:
	return SourceBlockLoadState.variant_regions_state(name_value, variants)

func generated_block_load_variant_regions_bridge_state(name_value: String, variants: int) -> Dictionary:
	return SourceBlockLoadState.generated_block_load_variant_regions_bridge_state(name_value, variants)

func source_block_load_variant_shadow_regions_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	return SourceBlockLoadState.variant_shadow_regions_state(name_value, variants, custom_shadow)

func generated_block_load_variant_shadow_regions_bridge_state(name_value: String, variants: int, custom_shadow: bool) -> Dictionary:
	return SourceBlockLoadState.generated_block_load_variant_shadow_regions_bridge_state(name_value, variants, custom_shadow)

func source_block_is_hidden_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	return SourceBlockPlanState.is_hidden_state(build_visibility_visible, revealed_blocks_contains_self)

func generated_block_is_hidden_bridge_state(build_visibility_visible: bool, revealed_blocks_contains_self: bool) -> Dictionary:
	return SourceBlockPlanState.generated_block_is_hidden_bridge_state(build_visibility_visible, revealed_blocks_contains_self)

func source_block_plan_rotation_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return SourceBlockPlanState.plan_rotation_state(rotate_value, lock_rotation, rot)

func generated_block_plan_rotation_bridge_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return SourceBlockPlanState.generated_block_plan_rotation_bridge_state(rotate_value, lock_rotation, rot)

func source_block_flip_rotation_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	return SourceBlockPlanState.flip_rotation_state(rotation_before, x_value, invert_flip, rotate_value, lock_rotation, Callable(self, "source_arc_mathf_mod_float"), Callable(self, "source_block_plan_rotation_state"))

func generated_block_flip_rotation_bridge_state(rotation_before: int, x_value: bool, invert_flip: bool, rotate_value: bool, lock_rotation: bool) -> Dictionary:
	return SourceBlockPlanState.generated_block_flip_rotation_bridge_state(rotation_before, x_value, invert_flip, rotate_value, lock_rotation)

func source_block_get_plan_configs_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	return SourceBlockPlanState.get_plan_configs_state(options_before, item_configured, liquid_configured, content_items, content_liquids)

func generated_block_get_plan_configs_bridge_state(options_before: Array, item_configured: bool, liquid_configured: bool, content_items: Array, content_liquids: Array) -> Dictionary:
	return SourceBlockPlanState.generated_block_get_plan_configs_bridge_state(options_before, item_configured, liquid_configured, content_items, content_liquids)

func source_block_sense_laccess_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	return SourceBlockSenseState.laccess_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

func generated_block_sense_laccess_bridge_state(sensor: String, map_color_double_bits: float, health_value: float, solid_value: bool, size_value: int, item_capacity: int, liquid_capacity: float, has_cons_power: bool, cons_power_buffered: bool, cons_power_capacity: float, logic_id: int) -> Dictionary:
	return SourceBlockSenseState.generated_block_sense_laccess_bridge_state(sensor, map_color_double_bits, health_value, solid_value, size_value, item_capacity, liquid_capacity, has_cons_power, cons_power_buffered, cons_power_capacity, logic_id)

func source_block_sense_content_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	return SourceBlockSenseState.content_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

func generated_block_sense_content_bridge_state(content_type: String, content_item: Variant, state_rules_infinite_resources: bool, requirements: Array, build_cost_multiplier: float) -> Dictionary:
	return SourceBlockSenseState.generated_block_sense_content_bridge_state(content_type, content_item, state_rules_infinite_resources, requirements, build_cost_multiplier)

func source_block_sense_object_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	return SourceBlockSenseState.object_state(sensor, block_name, no_sensed)

func generated_block_sense_object_bridge_state(sensor: String, block_name: Variant, no_sensed: Variant) -> Dictionary:
	return SourceBlockSenseState.generated_block_sense_object_bridge_state(sensor, block_name, no_sensed)

func source_build_payload_block_state(build_block: Variant) -> Dictionary:
	return SourceBuildPayloadState.block_state(build_block)

func generated_build_payload_block_bridge_state(build_block: Variant) -> Dictionary:
	return SourceBuildPayloadState.generated_build_payload_block_bridge_state(build_block)

func source_build_payload_constructor_block_team_state(block: Variant, team: Variant) -> Dictionary:
	return SourceBuildPayloadState.constructor_block_team_state(block, team)

func generated_build_payload_constructor_block_team_bridge_state(block: Variant, team: Variant) -> Dictionary:
	return SourceBuildPayloadState.generated_build_payload_constructor_block_team_bridge_state(block, team)

func source_build_payload_constructor_build_state(build: Variant) -> Dictionary:
	return SourceBuildPayloadState.constructor_build_state(build)

func generated_build_payload_constructor_build_bridge_state(build: Variant) -> Dictionary:
	return SourceBuildPayloadState.generated_build_payload_constructor_build_bridge_state(build)

func source_unit_payload_constructor_state(unit: Variant) -> Dictionary:
	return SourceUnitPayloadBasicState.constructor_state(unit)

func generated_unit_payload_constructor_bridge_state(unit: Variant) -> Dictionary:
	return SourceUnitPayloadBasicState.generated_constructor_bridge_state(unit)

func source_unit_payload_show_overlay_texture_region_state(icon: Variant) -> Dictionary:
	return SourceUnitPayloadBasicState.show_overlay_texture_region_state(icon)

func generated_unit_payload_show_overlay_texture_region_bridge_state(icon: Variant) -> Dictionary:
	return SourceUnitPayloadBasicState.generated_show_overlay_texture_region_bridge_state(icon)

func source_unit_payload_show_overlay_drawable_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	return SourceUnitPayloadBasicState.show_overlay_drawable_state(icon_null, headless, region)

func generated_unit_payload_show_overlay_drawable_bridge_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	return SourceUnitPayloadBasicState.generated_show_overlay_drawable_bridge_state(icon_null, headless, region)

func source_unit_payload_content_equals_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	return SourceUnitPayloadContentState.content_equals_state(other_is_unit_payload, other_unit_type, unit_type)

func generated_unit_payload_content_equals_bridge_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_contentEquals_2", [other_is_unit_payload, other_unit_type, unit_type], null)
	var canonical = source_unit_payload_content_equals_state(other_is_unit_payload, other_unit_type, unit_type)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_content_equals_state",
		"generated_owner": "UnitPayload.java_method_contentEquals_2",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_update_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return SourceUnitPayloadContentState.update_state(unit_type, unit, unit_holder, building_holder)

func generated_unit_payload_update_bridge_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_update_3", [unit_type, unit, unit_holder, building_holder], null)
	var canonical = source_unit_payload_update_state(unit_type, unit, unit_holder, building_holder)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_update_state",
		"generated_owner": "UnitPayload.java_method_update_3",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_content_state(unit_type: Variant) -> Dictionary:
	return SourceUnitPayloadContentState.content_state(unit_type)

func generated_unit_payload_content_bridge_state(unit_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_content_4", [unit_type], null)
	var canonical = source_unit_payload_content_state(unit_type)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_content_state",
		"generated_owner": "UnitPayload.java_method_content_4",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_requirements_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	return SourceUnitPayloadRequirementsState.requirements_state(unit_type, total_requirements)

func generated_unit_payload_requirements_bridge_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_requirements_5", [unit_type, total_requirements], null)
	var canonical = source_unit_payload_requirements_state(unit_type, total_requirements)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_requirements_state",
		"generated_owner": "UnitPayload.java_method_requirements_5",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_build_time_state(unit_type: Variant, build_time: float) -> Dictionary:
	return SourceUnitPayloadRequirementsState.build_time_state(unit_type, build_time)

func generated_unit_payload_build_time_bridge_state(unit_type: Variant, build_time: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_buildTime_6", [unit_type, build_time], null)
	var canonical = source_unit_payload_build_time_state(unit_type, build_time)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_build_time_state",
		"generated_owner": "UnitPayload.java_method_buildTime_6",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_write_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	return SourceUnitPayloadIoState.write_state(payload_unit, unit_class_id)

func generated_unit_payload_write_bridge_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_write_7", [payload_unit, unit_class_id], null)
	var canonical = source_unit_payload_write_state(payload_unit, unit_class_id)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_write_state",
		"generated_owner": "UnitPayload.java_method_write_7",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return SourceUnitPayloadIoState.set_state(x, y, rotation_value)

func generated_unit_payload_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_set_8", [x, y, rotation_value], null)
	var canonical = source_unit_payload_set_state(x, y, rotation_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_set_state",
		"generated_owner": "UnitPayload.java_method_set_8",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_x_state(unit_x: float) -> Dictionary:
	return SourceUnitPayloadIoState.x_state(unit_x)

func generated_unit_payload_x_bridge_state(unit_x: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_x_9", [unit_x], null)
	var canonical = source_unit_payload_x_state(unit_x)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_x_state",
		"generated_owner": "UnitPayload.java_method_x_9",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_y_state(unit_y: float) -> Dictionary:
	return SourceUnitPayloadIoState.y_state(unit_y)

func generated_unit_payload_y_bridge_state(unit_y: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_y_10", [unit_y], null)
	var canonical = source_unit_payload_y_state(unit_y)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_y_state",
		"generated_owner": "UnitPayload.java_method_y_10",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_rotation_state(unit_rotation: float) -> Dictionary:
	return SourceUnitPayloadIoState.rotation_state(unit_rotation)

func generated_unit_payload_rotation_bridge_state(unit_rotation: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_rotation_11", [unit_rotation], null)
	var canonical = source_unit_payload_rotation_state(unit_rotation)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_rotation_state",
		"generated_owner": "UnitPayload.java_method_rotation_11",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_size_state(unit_hit_size: float) -> Dictionary:
	return SourceUnitPayloadIoState.size_state(unit_hit_size)

func generated_unit_payload_size_bridge_state(unit_hit_size: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_size_12", [unit_hit_size], null)
	var canonical = source_unit_payload_size_state(unit_hit_size)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_size_state",
		"generated_owner": "UnitPayload.java_method_size_12",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_dump_type_null_guard_state(unit_type_null: bool) -> Dictionary:
	return SourceUnitPayloadDumpState.type_null_guard_state(unit_type_null)

func generated_unit_payload_dump_type_null_guard_bridge_state(unit_type_null: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null], null)
	var canonical = source_unit_payload_dump_type_null_guard_state(unit_type_null)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SourceUnitPayloadDumpState.SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_type_null_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_dump_can_create_guard_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	return SourceUnitPayloadDumpState.can_create_guard_state(unit_type_null, units_can_create)

func generated_unit_payload_dump_can_create_guard_bridge_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create], null)
	var canonical = source_unit_payload_dump_can_create_guard_state(unit_type_null, units_can_create)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_can_create_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_dump_solidity_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	return SourceUnitPayloadDumpState.solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)

func generated_unit_payload_dump_solidity_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid], null)
	var canonical = source_unit_payload_dump_solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SourceUnitPayloadDumpState.SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_solidity_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_dump_overlap_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	return SourceUnitPayloadDumpState.overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)

func generated_state_matches_generated_subset(result: Variant, canonical: Dictionary, ignored_keys: Array = []) -> bool:
	if not result is Dictionary:
		return false
	for key in canonical.keys():
		if key == "source_owner" or ignored_keys.has(key):
			continue
		if not result.has(key) or result.get(key) != canonical.get(key):
			return false
	return true

func generated_state_matches_generated_subset_or_nan(result: Variant, canonical: Dictionary, nan_key: String, identity_key: String, ignored_keys: Array = []) -> bool:
	if generated_state_matches_generated_subset(result, canonical, ignored_keys):
		return true
	if not result is Dictionary:
		return false
	var result_nan: bool = bool(result.get(nan_key, false))
	var canonical_nan: bool = bool(canonical.get(nan_key, false))
	return result_nan and canonical_nan and result.get(identity_key, "") == canonical.get(identity_key, "")

func generated_unit_payload_dump_overlap_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count], null)
	var canonical = source_unit_payload_dump_overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SourceUnitPayloadDumpState.SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_overlap_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_dump_no_client_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	return SourceUnitPayloadDumpState.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)

func generated_unit_payload_dump_no_client_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client], null)
	var canonical = source_unit_payload_dump_no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_no_client_guard_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_dump_spawn_side_effects_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	var state := source_unit_payload_dump_no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	return SourceUnitPayloadDumpState.spawn_side_effects_state(state, range_x, range_y, unit_id)

func generated_unit_payload_dump_spawn_side_effects_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_dump_13", [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id], null)
	var canonical = source_unit_payload_dump_spawn_side_effects_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id)
	var matches: bool = generated_state_matches_generated_subset(result, canonical, SourceUnitPayloadDumpState.SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_SIDE_EFFECTS_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": "PortGame.source_unit_payload_dump_spawn_side_effects_state",
		"generated_owner": "UnitPayload.java_method_dump_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_draw_shadow_type_null_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	return SourceUnitPayloadDrawState.draw_shadow_type_null_state(unit_type_null, alpha, unit_id)

func generated_unit_payload_draw_shadow_type_null_bridge_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_drawShadow_14", [unit_type_null, alpha, unit_id], null)
	var canonical = source_unit_payload_draw_shadow_type_null_state(unit_type_null, alpha, unit_id)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_draw_shadow_type_null_state",
		"generated_owner": "UnitPayload.java_method_drawShadow_14",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_draw_type_null_state(unit_type_null: bool) -> Dictionary:
	return SourceUnitPayloadDrawState.draw_type_null_state(unit_type_null)

func generated_unit_payload_draw_type_null_bridge_state(unit_type_null: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_draw_15", [unit_type_null], null)
	var canonical = source_unit_payload_draw_type_null_state(unit_type_null)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_draw_type_null_state",
		"generated_owner": "UnitPayload.java_method_draw_15",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_draw_elevation_setup_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	return SourceUnitPayloadDrawState.draw_elevation_setup_state(unit_type_null, unit_elevation, unit_id)

func generated_unit_payload_draw_elevation_setup_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_draw_15", [unit_type_null, unit_elevation, unit_id], null)
	var canonical = source_unit_payload_draw_elevation_setup_state(unit_type_null, unit_elevation, unit_id)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_draw_elevation_setup_state",
		"generated_owner": "UnitPayload.java_method_draw_15",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_draw_overlay_warning_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	return SourceUnitPayloadDrawState.draw_overlay_warning_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)

func generated_unit_payload_draw_overlay_warning_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_draw_15", [unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time], null)
	var canonical = source_unit_payload_draw_overlay_warning_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_draw_overlay_warning_state",
		"generated_owner": "UnitPayload.java_method_draw_15",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_unit_payload_icon_state(unit_type_full_icon: Variant) -> Dictionary:
	return SourceUnitPayloadDrawState.icon_state(unit_type_full_icon)

func generated_unit_payload_icon_bridge_state(unit_type_full_icon: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_icon_16", [unit_type_full_icon], null)
	var canonical = source_unit_payload_icon_state(unit_type_full_icon)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_icon_state",
		"generated_owner": "UnitPayload.java_method_icon_16",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_place_default_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	return SourceBuildPayloadLifecycleState.place_default_state(tile, build_block, build_team)

func generated_build_payload_place_default_bridge_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_place_1", [tile, build_block, build_team], null)
	var canonical = source_build_payload_place_default_state(tile, build_block, build_team)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_place_default_state",
		"generated_owner": "BuildPayload.java_method_place_1",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_place_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	return SourceBuildPayloadLifecycleState.place_state(tile, build_block, build_team, rotation_value)

func generated_build_payload_place_bridge_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_place_2", [tile, build_block, build_team, rotation_value], null)
	var canonical = source_build_payload_place_state(tile, build_block, build_team, rotation_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_place_state",
		"generated_owner": "BuildPayload.java_method_place_2",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_update_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return SourceBuildPayloadLifecycleState.update_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)

func generated_build_payload_update_bridge_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_update_5", [unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder], null)
	var canonical = source_build_payload_update_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_update_state",
		"generated_owner": "BuildPayload.java_method_update_5",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_destroyed_state() -> Dictionary:
	return SourceBuildPayloadLifecycleState.destroyed_state()

func generated_build_payload_destroyed_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_destroyed_6", [], null)
	var canonical = source_build_payload_destroyed_state()
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_destroyed_state",
		"generated_owner": "BuildPayload.java_method_destroyed_6",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_content_equals_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	return SourceBuildPayloadState.content_equals_state(other_is_build_payload, other_block, build_block)

func generated_build_payload_content_equals_bridge_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_contentEquals_3", [other_is_build_payload, other_block, build_block], null)
	var canonical = source_build_payload_content_equals_state(other_is_build_payload, other_block, build_block)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_content_equals_state",
		"generated_owner": "BuildPayload.java_method_contentEquals_3",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_content_state(build_block: Variant) -> Dictionary:
	return SourceBuildPayloadState.content_state(build_block)

func generated_build_payload_content_bridge_state(build_block: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_content_4", [build_block], null)
	var canonical = source_build_payload_content_state(build_block)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_content_state",
		"generated_owner": "BuildPayload.java_method_content_4",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_build_time_state(build_time: float) -> Dictionary:
	return SourceBuildPayloadState.build_time_state(build_time)

func generated_build_payload_build_time_bridge_state(build_time: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_buildTime_8", [build_time], null)
	var canonical = source_build_payload_build_time_state(build_time)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_build_time_state",
		"generated_owner": "BuildPayload.java_method_buildTime_8",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_requirements_state(requirements: Variant) -> Dictionary:
	return SourceBuildPayloadState.requirements_state(requirements)

func generated_build_payload_requirements_bridge_state(requirements: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_requirements_7", [requirements], null)
	var canonical = source_build_payload_requirements_state(requirements)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_requirements_state",
		"generated_owner": "BuildPayload.java_method_requirements_7",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_x_state(build_x: float) -> Dictionary:
	return SourceBuildPayloadState.x_state(build_x)

func generated_build_payload_x_bridge_state(build_x: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_x_9", [build_x], null)
	var canonical = source_build_payload_x_state(build_x)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_x_state",
		"generated_owner": "BuildPayload.java_method_x_9",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_y_state(build_y: float) -> Dictionary:
	return SourceBuildPayloadState.y_state(build_y)

func generated_build_payload_y_bridge_state(build_y: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_y_10", [build_y], null)
	var canonical = source_build_payload_y_state(build_y)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_y_state",
		"generated_owner": "BuildPayload.java_method_y_10",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_size_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	return SourceBuildPayloadState.size_state(build_block_size, source_tilesize)

func generated_build_payload_size_bridge_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_size_11", [build_block_size, source_tilesize], null)
	var canonical = source_build_payload_size_state(build_block_size, source_tilesize)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_size_state",
		"generated_owner": "BuildPayload.java_method_size_11",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_size_11", [build_block_size], null)
	var canonical = source_build_payload_size_state(build_block_size, SourceWorldDefaults.TILESIZE)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_size_state",
		"generated_owner": "BuildPayload.java_method_size_11",
		"defaulted_arg": "source_tilesize",
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_remove_state() -> Dictionary:
	return SourceBuildPayloadLifecycleState.remove_state()

func generated_build_payload_remove_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_remove_12", [], null)
	var canonical = source_build_payload_remove_state()
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_remove_state",
		"generated_owner": "BuildPayload.java_method_remove_12",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_write_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	return SourceBuildPayloadState.write_state(payload_block, build_block_id, build_version)

func generated_build_payload_write_bridge_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_write_13", [payload_block, build_block_id, build_version], null)
	var canonical = source_build_payload_write_state(payload_block, build_block_id, build_version)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_write_state",
		"generated_owner": "BuildPayload.java_method_write_13",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return SourceBuildPayloadState.set_state(x, y, rotation_value)

func generated_build_payload_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_set_14", [x, y, rotation_value], null)
	var canonical = source_build_payload_set_state(x, y, rotation_value)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_set_state",
		"generated_owner": "BuildPayload.java_method_set_14",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_draw_shadow_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	return SourceBuildPayloadDrawState.draw_shadow_state(build_x, build_y, build_block_size, source_tilesize, alpha)

func generated_build_payload_draw_shadow_bridge_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_drawShadow_15", [build_x, build_y, build_block_size, source_tilesize, alpha], null)
	var canonical = source_build_payload_draw_shadow_state(build_x, build_y, build_block_size, source_tilesize, alpha)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_draw_shadow_state",
		"generated_owner": "BuildPayload.java_method_drawShadow_15",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_draw_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	return SourceBuildPayloadDrawState.draw_state(prev_z, layer_flying_unit_low, transform_z)

func generated_build_payload_draw_bridge_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_draw_16", [prev_z, layer_flying_unit_low, transform_z], null)
	var canonical = source_build_payload_draw_state(prev_z, layer_flying_unit_low, transform_z)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_draw_state",
		"generated_owner": "BuildPayload.java_method_draw_16",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_build_payload_icon_state(full_icon: Variant) -> Dictionary:
	return SourceBuildPayloadDrawState.icon_state(full_icon)

func generated_build_payload_icon_bridge_state(full_icon: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BuildPayload.gd", "java_method_icon_17", [full_icon], null)
	var canonical = source_build_payload_icon_state(full_icon)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_build_payload_icon_state",
		"generated_owner": "BuildPayload.java_method_icon_17",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_icons_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	return SourceBlockProducerState.icons_state(region, out_region, top_region)

func generated_block_producer_icons_bridge_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_method_icons_0", [region, out_region, top_region], null)
	var canonical = source_block_producer_icons_state(region, out_region, top_region)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_icons_state",
		"generated_owner": "BlockProducer.java_method_icons_0",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_draw_plan_region_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	return SourceBlockProducerState.draw_plan_region_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)

func generated_block_producer_draw_plan_region_bridge_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_method_drawPlanRegion_1", [region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation], null)
	var canonical = source_block_producer_draw_plan_region_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_draw_plan_region_state",
		"generated_owner": "BlockProducer.java_method_drawPlanRegion_1",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_set_bars_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	return SourceBlockProducerState.set_bars_state(recipe_null, entity_progress, recipe_build_time)

func generated_block_producer_set_bars_bridge_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_method_setBars_2", [recipe_null, entity_progress, recipe_build_time], null)
	var canonical = source_block_producer_set_bars_state(recipe_null, entity_progress, recipe_build_time)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_set_bars_state",
		"generated_owner": "BlockProducer.java_method_setBars_2",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_accept_item_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	return SourceBlockProducerState.build_accept_item_state(source_building, item, item_count, maximum_accepted)

func generated_block_producer_build_accept_item_bridge_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_acceptItem_1", [source_building, item, item_count, maximum_accepted], null)
	var canonical = source_block_producer_build_accept_item_state(source_building, item, item_count, maximum_accepted)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_accept_item_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_get_maximum_accepted_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	return SourceBlockProducerState.build_get_maximum_accepted_state(item, recipe_null, requirements)

func generated_block_producer_build_get_maximum_accepted_bridge_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_getMaximumAccepted_2", [item, recipe_null, requirements], null)
	var canonical = source_block_producer_build_get_maximum_accepted_state(item, recipe_null, requirements)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_get_maximum_accepted_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.getMaximumAccepted",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_accept_payload_state(source_building: Variant, payload: Variant) -> Dictionary:
	return SourceBlockProducerState.build_accept_payload_state(source_building, payload)

func generated_block_producer_build_accept_payload_bridge_state(source_building: Variant, payload: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_acceptPayload_3", [source_building, payload], null)
	var canonical = source_block_producer_build_accept_payload_state(source_building, payload)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_accept_payload_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.acceptPayload",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_should_consume_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	return SourceBlockProducerState.build_should_consume_state(super_should_consume, recipe_null)

func generated_block_producer_build_should_consume_bridge_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_shouldConsume_4", [super_should_consume, recipe_null], null)
	var canonical = source_block_producer_build_should_consume_state(super_should_consume, recipe_null)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_should_consume_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.shouldConsume",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_update_tile_produce_gate_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	return SourceBlockProducerBuildUpdateState.produce_gate_state(recipe_null, efficiency, payload_null)

func generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_5", [recipe_null, efficiency, payload_null], null)
	var canonical = source_block_producer_build_update_tile_produce_gate_state(recipe_null, efficiency, payload_null)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_update_tile_produce_gate_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.updateTile.produceGate",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_update_tile_progress_accumulation_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	return SourceBlockProducerBuildUpdateState.progress_accumulation_state(produce, progress_before, build_speed, edelta)

func generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_progress_accumulation_5", [produce, progress_before, build_speed, edelta], null)
	var canonical = source_block_producer_build_update_tile_progress_accumulation_state(produce, progress_before, build_speed, edelta)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_update_tile_progress_accumulation_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.updateTile.progressAccumulation",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_update_tile_completion_guard_state(progress: float, recipe_build_time: float) -> Dictionary:
	return SourceBlockProducerBuildUpdateState.completion_guard_state(progress, recipe_build_time)

func generated_block_producer_build_update_tile_completion_guard_bridge_state(progress: float, recipe_build_time: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_completion_guard_5", [progress, recipe_build_time], null)
	var canonical = source_block_producer_build_update_tile_completion_guard_state(progress, recipe_build_time)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_update_tile_completion_guard_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.updateTile.completionGuard",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_update_tile_payload_creation_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	return SourceBlockProducerBuildUpdateState.payload_creation_state(completion_guard, recipe, team, x, y, payload_size, tilesize)

func generated_block_producer_build_update_tile_payload_creation_bridge_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_payload_creation_5", [completion_guard, recipe, team, x, y, payload_size, tilesize], null)
	var canonical = source_block_producer_build_update_tile_payload_creation_state(completion_guard, recipe, team, x, y, payload_size, tilesize)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_update_tile_payload_creation_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.updateTile.payloadCreation",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_update_tile_pay_vector_progress_reset_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	return SourceBlockProducerBuildUpdateState.pay_vector_progress_reset_state(completion_guard, pay_vector_x, pay_vector_y, progress_before)

func generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_pay_vector_progress_reset_5", [completion_guard, pay_vector_x, pay_vector_y, progress_before], null)
	var canonical = source_block_producer_build_update_tile_pay_vector_progress_reset_state(completion_guard, pay_vector_x, pay_vector_y, progress_before)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_update_tile_pay_vector_progress_reset_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.updateTile.payVectorProgressReset",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_update_tile_heat_time_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	return SourceBlockProducerBuildUpdateState.heat_time_state(produce, heat_before, time_before, time_delta)

func generated_block_producer_build_update_tile_heat_time_bridge_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_heat_time_5", [produce, heat_before, time_before, time_delta], null)
	var canonical = source_block_producer_build_update_tile_heat_time_state(produce, heat_before, time_before, time_delta)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_update_tile_heat_time_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.updateTile.heatTime",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_producer_build_update_tile_move_out_payload_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	return SourceBlockProducerMoveOutPayloadState.move_out_payload_state(payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)

func generated_block_producer_build_update_tile_move_out_payload_bridge_state(payload_present: bool, pay_vector_x: float, pay_vector_y: float, pay_rotation_before: float, rotdeg_value: float, size_value: float, tilesize: float, payload_rotate_speed: float, payload_speed: float, time_delta: float, front_present: bool, front_solid: bool, front_outputs_payload: bool, front_accepts_payload: bool, move_payload_result: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_move_out_payload_5", [payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result], null)
	var canonical = source_block_producer_build_update_tile_move_out_payload_state(payload_present, pay_vector_x, pay_vector_y, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)
	var matches: bool = generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_block_producer_build_update_tile_move_out_payload_state",
		"generated_owner": "BlockProducer.BlockProducerBuild.updateTile.moveOutPayload",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

func source_block_init_item_liquid_filters_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return SourceBlockInitRuntimeState.item_liquid_filters_state(content_items_size, content_liquids_size)

func generated_block_init_item_liquid_filters_bridge_state(content_items_size: int, content_liquids_size: int) -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_init_item_liquid_filters_bridge_state(content_items_size, content_liquids_size)

func source_block_init_consumer_apply_loop_state(consumers: Array) -> Dictionary:
	return SourceBlockInitConsumerState.apply_loop_state(consumers)

func generated_block_init_consumer_apply_loop_bridge_state(consumers: Array) -> Dictionary:
	return SourceBlockInitConsumerState.generated_consumer_apply_loop_bridge_state(consumers)

func source_block_init_set_bars_call_state() -> Dictionary:
	return SourceBlockInitRuntimeState.set_bars_call_state()

func generated_block_init_set_bars_call_bridge_state() -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_init_set_bars_call_bridge_state()

func source_block_init_stats_categories_state(stats_use_categories_before: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.stats_categories_state(stats_use_categories_before)

func generated_block_init_stats_categories_bridge_state(stats_use_categories_before: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_init_stats_categories_bridge_state(stats_use_categories_before)

func source_block_init_logic_configurable_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.logic_configurable_state(logic_configurable_before, config_key_assignable_to_unlockable_content)

func generated_block_init_logic_configurable_bridge_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_init_logic_configurable_bridge_state(logic_configurable_before, config_key_assignable_to_unlockable_content)

func source_block_init_buffered_power_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.buffered_power_state(outputs_power, has_cons_power, cons_power_buffered_before)

func generated_block_init_buffered_power_bridge_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_init_buffered_power_bridge_state(outputs_power, has_cons_power, cons_power_buffered_before)

func source_block_init_sandbox_visibility_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.sandbox_visibility_state(build_visibility, hide_details_before)

func generated_block_init_sandbox_visibility_bridge_state(build_visibility: String, hide_details_before: bool) -> Dictionary:
	return SourceBlockInitRuntimeState.generated_block_init_sandbox_visibility_bridge_state(build_visibility, hide_details_before)

func source_turret_init_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	return SourceTurretInitState.turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)

func generated_turret_init_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float, tracking_range: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_init_3", [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range], null)
	var canonical = source_turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, tracking_range)
	return {
		"source_owner": "PortGame.source_turret_init_state",
		"generated_owner": "Turret.java_method_init_3",
		"result": result,
		"canonical": canonical,
		"matches": result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null) and result.get("elevation_after", null) == canonical.get("elevation_after", null) and result.get("tracking_range_after", null) == canonical.get("tracking_range_after", null) and result.get("disable_overlap_check_after", null) == canonical.get("disable_overlap_check_after", null),
	}

func generated_turret_init_source_tilesize_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_init_3", [shoot_y, shoot_y_is_negative_infinity, size], null)
	var canonical = source_turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, SourceWorldDefaults.TILESIZE, SourceTurretDefaults.ELEVATION_DEFAULT, SourceTurretDefaults.RECOIL_TIME_DEFAULT, SourceTurretDefaults.RELOAD_DEFAULT, SourceTurretDefaults.COOLDOWN_TIME_DEFAULT, SourceTurretDefaults.NEW_TARGET_INTERVAL_DEFAULT, SourceTurretDefaults.TARGET_INTERVAL_DEFAULT, SourceTurretDefaults.TARGET_GROUND_DEFAULT, SourceTurretDefaults.DISABLE_OVERLAP_CHECK_DEFAULT, 0.0, 0.0)
	return {
		"source_owner": "PortGame.source_turret_init_state",
		"generated_owner": "Turret.java_method_init_3",
		"defaulted_arg": "source_tilesize",
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("source_tilesize", null) == canonical.get("source_tilesize", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null) and result.get("elevation_after", null) == canonical.get("elevation_after", null),
	}

func generated_turret_init_size_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_init_3", [shoot_y, shoot_y_is_negative_infinity], null)
	var canonical = source_turret_init_state(shoot_y, shoot_y_is_negative_infinity, SourceBlockDefaults.SIZE_DEFAULT, SourceWorldDefaults.TILESIZE, SourceTurretDefaults.ELEVATION_DEFAULT, SourceTurretDefaults.RECOIL_TIME_DEFAULT, SourceTurretDefaults.RELOAD_DEFAULT, SourceTurretDefaults.COOLDOWN_TIME_DEFAULT, SourceTurretDefaults.NEW_TARGET_INTERVAL_DEFAULT, SourceTurretDefaults.TARGET_INTERVAL_DEFAULT, SourceTurretDefaults.TARGET_GROUND_DEFAULT, SourceTurretDefaults.DISABLE_OVERLAP_CHECK_DEFAULT, 0.0, 0.0)
	return {
		"source_owner": "PortGame.source_turret_init_state",
		"generated_owner": "Turret.java_method_init_3",
		"defaulted_arg": "size",
		"size": result.get("size", null),
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("size", null) == canonical.get("size", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null) and result.get("elevation_after", null) == canonical.get("elevation_after", null),
	}

func generated_turret_init_disable_overlap_check_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_init_3", [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground], null)
	var canonical = source_turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, SourceTurretDefaults.DISABLE_OVERLAP_CHECK_DEFAULT, 0.0, 0.0)
	return {
		"source_owner": "PortGame.source_turret_init_state",
		"generated_owner": "Turret.java_method_init_3",
		"defaulted_arg": "disable_overlap_check",
		"disable_overlap_check": result.get("disable_overlap_check", null),
		"disable_overlap_check_after": result.get("disable_overlap_check_after", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("disable_overlap_check", null) == canonical.get("disable_overlap_check", null) and result.get("disable_overlap_check_after", null) == canonical.get("disable_overlap_check_after", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null),
	}

func generated_turret_init_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_init_3", [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check], null)
	var canonical = source_turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, SourceTurretDefaults.RANGE_DEFAULT, 0.0)
	return {
		"source_owner": "PortGame.source_turret_init_state",
		"generated_owner": "Turret.java_method_init_3",
		"defaulted_arg": "range",
		"range": result.get("range", null),
		"tracking_range_after": result.get("tracking_range_after", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("range", null) == canonical.get("range", null) and result.get("tracking_range_after", null) == canonical.get("tracking_range_after", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null),
	}

func generated_turret_init_tracking_range_default_bridge_state(shoot_y: float, shoot_y_is_negative_infinity: bool, size: float, source_tilesize: float, elevation: float, recoil_time: float, reload: float, cooldown_time: float, new_target_interval: float, target_interval: float, target_ground: bool, disable_overlap_check: bool, range_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_init_3", [shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value], null)
	var canonical = source_turret_init_state(shoot_y, shoot_y_is_negative_infinity, size, source_tilesize, elevation, recoil_time, reload, cooldown_time, new_target_interval, target_interval, target_ground, disable_overlap_check, range_value, SourceTurretDefaults.TRACKING_RANGE_DEFAULT)
	return {
		"source_owner": "PortGame.source_turret_init_state",
		"generated_owner": "Turret.java_method_init_3",
		"defaulted_arg": "tracking_range",
		"tracking_range": result.get("tracking_range", null),
		"tracking_range_after": result.get("tracking_range_after", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("tracking_range", null) == canonical.get("tracking_range", null) and result.get("tracking_range_after", null) == canonical.get("tracking_range_after", null) and result.get("shoot_y_after", null) == canonical.get("shoot_y_after", null),
	}

func source_base_turret_init_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	return SourceTurretInitState.base_turret_init_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)

func generated_base_turret_init_bridge_state(coolant_present: bool, found_consume_coolant: bool, disable_overlap_check: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, source_tilesize: float, fog_radius_multiplier: float, fog_radius: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_init_0", [coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius], null)
	var canonical = source_base_turret_init_state(coolant_present, found_consume_coolant, disable_overlap_check, place_overlap_range, range_value, place_overlap_margin, source_tilesize, fog_radius_multiplier, fog_radius)
	return {
		"source_owner": "PortGame.source_base_turret_init_state",
		"generated_owner": "BaseTurret.java_method_init_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("coolant_present_after", null) == canonical.get("coolant_present_after", null) and result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null) and result.get("fog_radius_after", null) == canonical.get("fog_radius_after", null),
	}

func source_base_turret_reinitialize_consumers_state() -> Dictionary:
	return SourceTurretInitState.base_turret_reinitialize_consumers_state()

func generated_base_turret_reinitialize_consumers_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_reinitializeConsumers_1", [], null)
	var canonical = source_base_turret_reinitialize_consumers_state()
	return {
		"source_owner": "PortGame.source_base_turret_reinitialize_consumers_state",
		"generated_owner": "BaseTurret.java_method_reinitializeConsumers_1",
		"result": result,
		"canonical": canonical,
		"matches": result.get("check_init_coolant_called", null) == canonical.get("check_init_coolant_called", null) and result.get("super_reinitialize_consumers_called", null) == canonical.get("super_reinitialize_consumers_called", null),
	}

func source_base_turret_check_init_coolant_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	return SourceTurretInitState.base_turret_check_init_coolant_state(coolant_present, has_consumer)

func generated_base_turret_check_init_coolant_bridge_state(coolant_present: bool, has_consumer: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_checkInitCoolant_2", [coolant_present, has_consumer], null)
	var canonical = source_base_turret_check_init_coolant_state(coolant_present, has_consumer)
	return {
		"source_owner": "PortGame.source_base_turret_check_init_coolant_state",
		"generated_owner": "BaseTurret.java_method_checkInitCoolant_2",
		"result": result,
		"canonical": canonical,
		"matches": result.get("consume_called", null) == canonical.get("consume_called", null) and result.get("update_after", null) == canonical.get("update_after", null) and result.get("booster_after", null) == canonical.get("booster_after", null) and result.get("optional_after", null) == canonical.get("optional_after", null),
	}

func source_base_turret_draw_place_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	return SourceBaseTurretDrawState.draw_place_state(tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog)

func generated_base_turret_draw_place_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool, source_tilesize: float, block_offset: float, range_value: float, fog_radius_multiplier: float, rules_fog: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_drawPlace_3", [tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog], null)
	var canonical = source_base_turret_draw_place_state(tile_x, tile_y, rotation_value, valid, source_tilesize, block_offset, range_value, fog_radius_multiplier, rules_fog)
	return {
		"source_owner": "PortGame.source_base_turret_draw_place_state",
		"generated_owner": "BaseTurret.java_method_drawPlace_3",
		"result": result,
		"canonical": canonical,
		"matches": result.get("dash_circle_call", null) == canonical.get("dash_circle_call", null) and result.get("fog_dash_circle_call", null) == canonical.get("fog_dash_circle_call", null) and result.get("super_draw_place_called", null) == canonical.get("super_draw_place_called", null),
	}

func generated_base_turret_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation_value: int, valid: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/BaseTurret.gd", "java_method_drawPlace_3", [tile_x, tile_y, rotation_value, valid], null)
	var canonical = source_base_turret_draw_place_state(tile_x, tile_y, rotation_value, valid, SourceWorldDefaults.TILESIZE, 0.0, SourceTurretDefaults.RANGE_DEFAULT, SourceTurretDefaults.FOG_RADIUS_MULTIPLIER_DEFAULT, false)
	return {
		"source_owner": "PortGame.source_base_turret_draw_place_state",
		"generated_owner": "BaseTurret.java_method_drawPlace_3",
		"defaulted_arg": "source_tilesize",
		"source_tilesize": result.get("source_tilesize", null),
		"result": result,
		"canonical": canonical,
		"matches": result.get("dash_circle_call", null) == canonical.get("dash_circle_call", null) and result.get("fog_dash_circle_call", null) == canonical.get("fog_dash_circle_call", null) and result.get("super_draw_place_called", null) == canonical.get("super_draw_place_called", null),
	}

func source_base_turret_set_stats_state(range_value: float, source_tilesize: float, activation_time: float) -> Dictionary:
	return SourceTurretStatsBarsState.base_turret_set_stats_state(range_value, source_tilesize, activation_time, SourceTimeDefaults.TICK_RATE)

func generated_base_turret_set_stats_bridge_state(range_value: float, source_tilesize: float, activation_time: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_base_turret_set_stats_bridge_state(range_value, source_tilesize, activation_time, SourceTimeDefaults.TICK_RATE)

func source_base_turret_set_bars_state(activation_time: float, entity_activation_timer: float) -> Dictionary:
	return SourceTurretStatsBarsState.base_turret_set_bars_state(activation_time, entity_activation_timer, SourceTimeDefaults.TICK_RATE)

func generated_base_turret_set_bars_bridge_state(activation_time: float, entity_activation_timer: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_base_turret_set_bars_bridge_state(activation_time, entity_activation_timer, SourceTimeDefaults.TICK_RATE)

func source_turret_set_stats_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float) -> Dictionary:
	return SourceTurretStatsBarsState.set_stats_state(inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency, SourceTimeDefaults.TICK_RATE)

func generated_turret_set_stats_bridge_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_turret_set_stats_bridge_state(inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency)

func source_point_defense_turret_set_stats_state(bullet_damage: float, reload_value: float) -> Dictionary:
	return SourceTurretStatsBarsState.point_defense_set_stats_state(bullet_damage, reload_value, SourceTimeDefaults.TICK_RATE)

func generated_point_defense_turret_set_stats_default_bridge_state() -> Dictionary:
	return SourceTurretStatsBarsState.generated_point_defense_turret_set_stats_default_bridge_state(SourcePointDefenseTurretDefaults.BULLET_DAMAGE_DEFAULT, SourceTurretDefaults.RELOAD_DEFAULT)

func source_turret_set_bars_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	return SourceTurretStatsBarsState.set_bars_state(heat_requirement, entity_heat_req, max_heat_efficiency)

func generated_turret_set_bars_bridge_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_turret_set_bars_bridge_state(heat_requirement, entity_heat_req, max_heat_efficiency)

func source_turret_load_state() -> Dictionary:
	return SourceTurretPresentationState.load_state()

func generated_turret_load_bridge_state() -> Dictionary:
	return SourceTurretPresentationState.generated_turret_load_bridge_state()

func source_turret_draw_plan_region_state(plan: Variant, list: Variant) -> Dictionary:
	return SourceTurretPresentationState.draw_plan_region_state(plan, list)

func generated_turret_draw_plan_region_bridge_state(plan: Variant, list: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_drawPlanRegion_5", [plan, list], null)
	var canonical = source_turret_draw_plan_region_state(plan, list)
	return {
		"source_owner": "PortGame.source_turret_draw_plan_region_state",
		"generated_owner": "Turret.java_method_drawPlanRegion_5",
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_draw_plan_called", null) == canonical.get("drawer_draw_plan_called", null) and result.get("plan", null) == canonical.get("plan", null) and result.get("list", null) == canonical.get("list", null),
	}

func source_turret_icons_state() -> Dictionary:
	return SourceTurretPresentationState.icons_state()

func generated_turret_icons_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_icons_6", [], null)
	var canonical = source_turret_icons_state()
	return {
		"source_owner": "PortGame.source_turret_icons_state",
		"generated_owner": "Turret.java_method_icons_6",
		"result": result,
		"canonical": canonical,
		"matches": result.get("drawer_final_icons_called", null) == canonical.get("drawer_final_icons_called", null) and result.get("icons", null) == canonical.get("icons", null),
	}

func source_tractor_beam_turret_icons_state(base_region: Variant, region: Variant) -> Dictionary:
	return SourceTractorBeamTurretLifecycleState.icons_state(base_region, region)

func generated_tractor_beam_turret_icons_bridge_state(base_region: Variant, region: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_method_icons_0", [base_region, region], null)
	var canonical = source_tractor_beam_turret_icons_state(base_region, region)
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_icons_state",
		"generated_owner": "TractorBeamTurret.java_method_icons_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("icons", null) == canonical.get("icons", null)
			and result.get("base_region", null) == canonical.get("base_region", null)
			and result.get("region", null) == canonical.get("region", null),
	}

func source_tractor_beam_turret_set_stats_state(target_air: bool, target_ground: bool, damage: float) -> Dictionary:
	return SourceTurretStatsBarsState.tractor_beam_turret_set_stats_state(target_air, target_ground, damage, SourceTimeDefaults.TICK_RATE)

func generated_tractor_beam_turret_set_stats_bridge_state(target_air: bool, target_ground: bool, damage: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_tractor_beam_turret_set_stats_bridge_state(target_air, target_ground, damage, SourceTimeDefaults.TICK_RATE)

func source_tractor_beam_turret_init_state(range_value: float, source_tilesize: float) -> Dictionary:
	return SourceTractorBeamTurretLifecycleState.init_state(range_value, source_tilesize)

func generated_tractor_beam_turret_init_bridge_state(range_value: float, source_tilesize: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_method_init_2", [range_value, source_tilesize], null)
	var canonical = source_tractor_beam_turret_init_state(range_value, source_tilesize)
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_init_state",
		"generated_owner": "TractorBeamTurret.java_method_init_2",
		"result": result,
		"canonical": canonical,
		"matches": result.get("clip_radius", null) == canonical.get("clip_radius", null) and result.get("update_clip_radius_call", null) == canonical.get("update_clip_radius_call", null)
			and result.get("range", null) == canonical.get("range", null)
			and result.get("tilesize", null) == canonical.get("tilesize", null)
			and result.get("super_init_called", null) == canonical.get("super_init_called", null)
			and result.get("update_clip_radius_called", null) == canonical.get("update_clip_radius_called", null),
	}

func source_tractor_beam_turret_build_should_consume_state(super_should_consume: bool, target: Variant) -> Dictionary:
	return SourceTractorBeamTurretLifecycleState.build_should_consume_state(super_should_consume, target)

func generated_tractor_beam_turret_build_should_consume_bridge_state(super_should_consume: bool, target: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_shouldConsume_1", [super_should_consume, target], null)
	var canonical = source_tractor_beam_turret_build_should_consume_state(super_should_consume, target)
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_should_consume_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.shouldConsume",
		"result": result,
		"canonical": canonical,
		"matches": result.get("should_consume", null) == canonical.get("should_consume", null) and result.get("target_present", null) == canonical.get("target_present", null)
			and result.get("super_should_consume", null) == canonical.get("super_should_consume", null)
			and result.get("target", null) == canonical.get("target", null),
	}

func source_tractor_beam_turret_build_estimate_dps_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	return SourceTractorBeamTurretLifecycleState.build_estimate_dps_state(any_state, damage, efficiency, coolant_multiplier)

func generated_tractor_beam_turret_build_estimate_dps_bridge_state(any_state: bool, damage: float, efficiency: float, coolant_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_estimateDps_2", [any_state, damage, efficiency, coolant_multiplier, SourceTimeDefaults.TICK_RATE], null)
	var canonical = source_tractor_beam_turret_build_estimate_dps_state(any_state, damage, efficiency, coolant_multiplier)
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_estimate_dps_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.estimateDps",
		"result": result,
		"canonical": canonical,
		"matches": result.get("estimate_dps", null) == canonical.get("estimate_dps", null) and result.get("zero_guard", null) == canonical.get("zero_guard", null)
			and result.get("any_state", null) == canonical.get("any_state", null)
			and result.get("damage", null) == canonical.get("damage", null)
			and result.get("efficiency", null) == canonical.get("efficiency", null)
			and result.get("coolant_multiplier", null) == canonical.get("coolant_multiplier", null),
	}

func source_tractor_beam_turret_build_write_state(rotation_value: float) -> Dictionary:
	return SourceTractorBeamTurretLifecycleState.build_write_state(rotation_value)

func generated_tractor_beam_turret_build_write_bridge_state(rotation_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_write_4", [rotation_value], null)
	var canonical = source_tractor_beam_turret_build_write_state(rotation_value)
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_write_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.write",
		"result": result,
		"canonical": canonical,
		"matches": result.get("write_f_call", null) == canonical.get("write_f_call", null) and result.get("super_write_called", null) == canonical.get("super_write_called", null)
			and result.get("rotation", null) == canonical.get("rotation", null),
	}

func source_tractor_beam_turret_build_read_state(read_f_value: float, revision_value: int) -> Dictionary:
	return SourceTractorBeamTurretLifecycleState.build_read_state(read_f_value, revision_value)

func generated_tractor_beam_turret_build_read_bridge_state(read_f_value: float, revision_value: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_read_5", [read_f_value, revision_value], null)
	var canonical = source_tractor_beam_turret_build_read_state(read_f_value, revision_value)
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_read_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.read",
		"result": result,
		"canonical": canonical,
		"matches": result.get("rotation_after", null) == canonical.get("rotation_after", null) and result.get("read_f_call", null) == canonical.get("read_f_call", null)
			and result.get("super_read_call", null) == canonical.get("super_read_call", null)
			and result.get("read_f_value", null) == canonical.get("read_f_value", null)
			and result.get("revision_value", null) == canonical.get("revision_value", null),
	}

func source_tractor_beam_turret_build_update_tile_activation_state(activation_timer: float, time_delta: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.activation_state(activation_timer, time_delta)

func generated_tractor_beam_turret_build_update_tile_activation_bridge_state(activation_timer: float, time_delta: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_activation_bridge_state(activation_timer, time_delta)

func source_tractor_beam_turret_build_update_tile_eff_state(activation_returned_early: bool, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.eff_state(activation_returned_early, efficiency, coolant_multiplier, delta_value)

func generated_tractor_beam_turret_build_update_tile_eff_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd", "java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value], null)
	var eff_result := {
		"returned_early": result.get("returned_early", false),
		"eff_calculated": result.get("eff_calculated", false),
		"efficiency": result.get("efficiency", efficiency),
		"coolant_multiplier": result.get("coolant_multiplier", coolant_multiplier),
		"delta_value": result.get("delta_value", delta_value),
		"eff": result.get("eff", 0.0),
		"edelta": result.get("edelta", 0.0),
	}
	var canonical = source_tractor_beam_turret_build_update_tile_eff_state(result.get("returned_early", false), efficiency, coolant_multiplier, delta_value)
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_eff_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.updateTile.eff",
		"result": eff_result,
		"canonical": canonical,
		"matches": eff_result.get("eff", null) == canonical.get("eff", null) and eff_result.get("edelta", null) == canonical.get("edelta", null)
			and eff_result.get("eff_calculated", null) == canonical.get("eff_calculated", null)
			and eff_result.get("efficiency", null) == canonical.get("efficiency", null)
			and eff_result.get("coolant_multiplier", null) == canonical.get("coolant_multiplier", null)
			and eff_result.get("delta_value", null) == canonical.get("delta_value", null),
	}

func source_tractor_beam_turret_build_update_tile_retarget_state(activation_returned_early: bool, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.retarget_state(activation_returned_early, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)

func generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_retarget_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)

func source_tractor_beam_turret_build_update_tile_coolant_guard_state(activation_returned_early: bool, target_after: Variant, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.coolant_guard_state(activation_returned_early, target_after, coolant_present, coolant_amount, current_liquid)

func generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_coolant_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid)

func source_tractor_beam_turret_build_update_tile_coolant_used_state(coolant_guard: bool, liquid_amount: float, max_used: float, time_delta: float, coolant_multiplier: float, liquid_heat_capacity: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.coolant_used_state(coolant_guard, liquid_amount, max_used, time_delta, coolant_multiplier, liquid_heat_capacity)

func generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_coolant_used_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)

func source_tractor_beam_turret_build_update_tile_coolant_remove_state(coolant_guard: bool, liquid: Variant, used: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.coolant_remove_state(coolant_guard, liquid, used)

func generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_coolant_remove_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)

func source_tractor_beam_turret_build_update_tile_coolant_effect_state(coolant_guard: bool, used: float, chance_result: bool, x: float, y: float, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.coolant_effect_state(coolant_guard, used, chance_result, x, y, size, source_tilesize, range_x, range_y)

func generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_coolant_effect_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)

func source_tractor_beam_turret_build_update_tile_coolant_multiplier_state(coolant_guard: bool, used: float, liquid_heat_capacity: float, coolant_multiplier: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.coolant_multiplier_state(coolant_guard, used, liquid_heat_capacity, coolant_multiplier)

func generated_tractor_beam_turret_build_update_tile_coolant_multiplier_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_coolant_multiplier_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)

func source_tractor_beam_turret_build_update_tile_any_reset_state(activation_returned_early: bool, any_before: bool) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.any_reset_state(activation_returned_early, any_before)

func generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileFlowState.generated_any_reset_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before)

func source_tractor_beam_turret_build_update_tile_look_target_guard_state(activation_returned_early: bool, target_after: Variant, range_value: float, target_hit_size: float, target_within_result: bool, target_team: Variant, team: Variant, target_air: bool, target_ground: bool, target_check_result: bool, efficiency: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileLookTargetGuardState.look_target_guard_state(activation_returned_early, target_after, range_value, target_hit_size, target_within_result, target_team, team, target_air, target_ground, target_check_result, efficiency)

func generated_tractor_beam_turret_build_update_tile_look_target_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileLookTargetGuardState.generated_look_target_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size)

func source_tractor_beam_turret_build_update_tile_sound_loop_state(look_target_guard: bool, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileSoundLoopState.sound_loop_state(look_target_guard, headless, shoot_sound, shoot_sound_volume)

func generated_tractor_beam_turret_build_update_tile_sound_loop_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileSoundLoopState.generated_sound_loop_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume)

func source_tractor_beam_turret_build_update_tile_angle_to_target_state(look_target_guard: bool, x: float, y: float, target_after: Variant) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.angle_to_target_state(look_target_guard, x, y, target_after, callbacks.get("angle_to_target", Callable()))

func generated_tractor_beam_turret_build_update_tile_angle_to_target_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileAngleToTargetState.generated_angle_to_target_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, callbacks.get("angle_to_target", Callable()))

func source_tractor_beam_turret_build_update_tile_rotation_move_state(angle_to_target_evaluated: bool, rotation_before: float, dest: float, rotate_speed: float, edelta: float) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileRotationMoveState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileRotationMoveState.rotation_move_state(angle_to_target_evaluated, rotation_before, dest, rotate_speed, edelta, callbacks.get("move_toward_angle", Callable()))

func generated_tractor_beam_turret_build_update_tile_rotation_move_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileRotationMoveState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileRotationMoveState.generated_rotation_move_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, callbacks.get("move_toward_angle", Callable()))

func source_tractor_beam_turret_build_update_tile_last_target_position_state(rotation_move_evaluated: bool, target_after: Variant, last_x_before: float, last_y_before: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileLastTargetPositionState.last_target_position_state(rotation_move_evaluated, target_after, last_x_before, last_y_before)

func generated_tractor_beam_turret_build_update_tile_last_target_position_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileLastTargetPositionState.generated_last_target_position_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before)

func source_tractor_beam_turret_build_update_tile_active_strength_state(last_target_position_evaluated: bool, strength_before: float, time_delta: float) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.active_strength_state(last_target_position_evaluated, strength_before, time_delta, callbacks.get("lerp_delta", Callable()))

func generated_tractor_beam_turret_build_update_tile_active_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileActiveStrengthState.generated_active_strength_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, callbacks.get("lerp_delta", Callable()))

func source_tractor_beam_turret_build_update_tile_inactive_strength_state(activation_returned_early: bool, look_target_guard: bool, strength_before: float, time_delta: float) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.inactive_strength_state(activation_returned_early, look_target_guard, strength_before, time_delta, callbacks.get("lerp_delta", Callable()))

func generated_tractor_beam_turret_build_update_tile_inactive_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float) -> Dictionary:
	var callbacks := SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.default_callbacks_state(self)
	return SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState.generated_inactive_strength_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, callbacks.get("lerp_delta", Callable()))

func source_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_state(strength_lerp_evaluated: bool, rotation_after: float, dest: float, shoot_cone: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState.shoot_when_possible_guard_state(strength_lerp_evaluated, rotation_after, dest, shoot_cone, Callable(self, "source_angles_angle_dist"))

func generated_tractor_beam_turret_build_update_tile_shoot_when_possible_guard_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileShootWhenPossibleGuardState.generated_shoot_when_possible_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, Callable(self, "source_angles_angle_dist"))

func source_tractor_beam_turret_build_update_tile_damage_pierce_state(shoot_within_guard: bool, target_after: Variant, damage: float, eff: float, time_scale: float, rules_block_damage: float, team: Variant) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileDamagePierceState.damage_pierce_state(shoot_within_guard, target_after, damage, eff, time_scale, rules_block_damage, team)

func generated_tractor_beam_turret_build_update_tile_damage_pierce_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileDamagePierceState.generated_damage_pierce_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage)

func source_tractor_beam_turret_build_update_tile_status_apply_state(shoot_within_guard: bool, target_after: Variant, status: Variant, status_duration: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileStatusApplyState.status_apply_state(shoot_within_guard, target_after, status, status_duration)

func generated_tractor_beam_turret_build_update_tile_status_apply_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileStatusApplyState.generated_status_apply_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration)

func source_tractor_beam_turret_build_update_tile_any_true_state(shoot_within_guard: bool, any_before_shoot: bool) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileAnyTrueState.any_true_state(shoot_within_guard, any_before_shoot)

func generated_tractor_beam_turret_build_update_tile_any_true_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileAnyTrueState.generated_any_true_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration)

func source_tractor_beam_turret_build_update_tile_impulse_net_state(shoot_within_guard: bool, target_after: Variant, x: float, y: float, range_value: float, edelta: float, force_value: float, scaled_force: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileImpulseNetState.impulse_net_state(shoot_within_guard, target_after, x, y, range_value, edelta, force_value, scaled_force)

func generated_tractor_beam_turret_build_update_tile_impulse_net_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, shoot_cone: float, damage: float, time_scale: float, rules_block_damage: float, status: Variant, status_duration: float, force_value: float, scaled_force: float) -> Dictionary:
	return SourceTractorBeamTurretBuildUpdateTileImpulseNetState.generated_impulse_net_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, shoot_cone, damage, time_scale, rules_block_damage, status, status_duration, force_value, scaled_force)

func source_tractor_beam_turret_build_draw_state(base_region: Variant, region: Variant, x: float, y: float, rotation_value: float, size: float, any_state: bool, is_payload: bool, last_x: float, last_y: float, laser_color: Variant, mathf_absin_4_0_6: float, laser: Variant, laser_start: Variant, laser_end: Variant, shoot_length: float, strength: float, efficiency: float, laser_width: float) -> Dictionary:
	return SourceTractorBeamTurretBuildDrawState.draw_state(base_region, region, x, y, rotation_value, size, any_state, is_payload, last_x, last_y, laser_color, mathf_absin_4_0_6, laser, laser_start, laser_end, shoot_length, strength, efficiency, laser_width)

func generated_tractor_beam_turret_build_draw_bridge_state(base_region: Variant, region: Variant, x: float, y: float, rotation_value: float, size: float, any_state: bool, is_payload: bool, last_x: float, last_y: float, laser_color: Variant, mathf_absin_4_0_6: float, laser: Variant, laser_start: Variant, laser_end: Variant, shoot_length: float, strength: float, efficiency: float, laser_width: float) -> Dictionary:
	return SourceTractorBeamTurretBuildDrawState.generated_draw_bridge_state(base_region, region, x, y, rotation_value, size, any_state, is_payload, last_x, last_y, laser_color, mathf_absin_4_0_6, laser, laser_start, laser_end, shoot_length, strength, efficiency, laser_width)

func source_turret_get_regions_to_outline_state(out: Variant) -> Dictionary:
	return SourceTurretPresentationState.get_regions_to_outline_state(out)

func generated_turret_get_regions_to_outline_bridge_state(out: Variant) -> Dictionary:
	return SourceTurretPresentationState.generated_get_regions_to_outline_bridge_state(out)

func source_turret_limit_range_state(bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	var bullet_range_change: float = source_bullet_range_change(bullet)
	var bullet_extra_range_margin: float = source_bullet_extra_range_margin(bullet)
	var bullet_speed: float = source_bullet_world_speed_per_tick(bullet)
	return SourceTurretRangeState.limit_range_state(bullet, margin, turret_range, bullet_range_change, bullet_extra_range_margin, bullet_speed)

func generated_turret_limit_range_bridge_state(bullet: Dictionary, margin: float, turret_range: float) -> Dictionary:
	var canonical_bullet := bullet.duplicate(true)
	var bullet_range_change: float = source_bullet_range_change(canonical_bullet)
	var bullet_extra_range_margin: float = source_bullet_extra_range_margin(canonical_bullet)
	var bullet_speed: float = source_bullet_world_speed_per_tick(canonical_bullet)
	return SourceTurretRangeState.generated_limit_range_bridge_state(bullet, margin, turret_range, bullet_range_change, bullet_extra_range_margin, bullet_speed)

@warning_ignore("shadowed_variable_base_class")
func source_turret_draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	return SourceTurretPlacementState.draw_place_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)

@warning_ignore("shadowed_variable_base_class")
func generated_turret_draw_place_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool, source_tilesize: float, block_offset: float, min_range: float) -> Dictionary:
	return SourceTurretPlacementState.generated_draw_place_bridge_state(tile_x, tile_y, rotation, valid, draw_min_range, source_tilesize, block_offset, min_range)

@warning_ignore("shadowed_variable_base_class")
func generated_turret_draw_place_source_tilesize_default_bridge_state(tile_x: int, tile_y: int, rotation: int, valid: bool, draw_min_range: bool) -> Dictionary:
	return SourceTurretPlacementState.generated_draw_place_source_tilesize_default_bridge_state(tile_x, tile_y, rotation, valid, draw_min_range, SourceWorldDefaults.TILESIZE)

func source_turret_rotated_output_state(tile_x: int, tile_y: int) -> Dictionary:
	return SourceTurretPlacementState.rotated_output_state(tile_x, tile_y)

func generated_turret_rotated_output_bridge_state(tile_x: int, tile_y: int) -> Dictionary:
	return SourceTurretPlacementState.generated_rotated_output_bridge_state(tile_x, tile_y)

@warning_ignore("shadowed_variable_base_class")
@warning_ignore("shadowed_variable")
func source_turret_place_ended_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	return SourceTurretPlacementState.place_ended_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)

@warning_ignore("shadowed_variable_base_class")
@warning_ignore("shadowed_variable")
func generated_turret_place_ended_bridge_state(tile: Variant, builder: Variant, rotation: int, config: Variant, rotate: bool, tile_build_is_turret_build: bool, turret_rotation: float, tile_build_rotdeg: float) -> Dictionary:
	return SourceTurretPlacementState.generated_place_ended_bridge_state(tile, builder, rotation, config, rotate, tile_build_is_turret_build, turret_rotation, tile_build_rotdeg)

func source_reload_turret_set_stats_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	return SourceTurretStatsBarsState.reload_turret_set_stats_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)

func generated_reload_turret_set_stats_bridge_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_reload_turret_set_stats_bridge_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)

func source_power_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	return SourceTurretStatsBarsState.power_turret_set_stats_state(shoot_type)

func generated_power_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	return SourceTurretStatsBarsState.generated_power_turret_set_stats_bridge_state(shoot_type)

func source_continuous_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	return SourceTurretStatsBarsState.continuous_turret_set_stats_state(shoot_type)

func generated_continuous_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	return SourceTurretStatsBarsState.generated_continuous_turret_set_stats_bridge_state(shoot_type)

func source_power_turret_limit_range_state(shoot_type: Variant, margin: float) -> Dictionary:
	return SourceTurretRangeState.power_turret_limit_range_state(shoot_type, margin)

func generated_power_turret_limit_range_bridge_state(shoot_type: Variant, margin: float) -> Dictionary:
	return SourceTurretRangeState.generated_power_turret_limit_range_bridge_state(shoot_type, margin)

func source_power_turret_build_get_ammo_fraction_state(power_null: bool, power_status: float) -> Dictionary:
	return SourcePowerTurretBuildState.get_ammo_fraction_state(power_null, power_status)

func generated_power_turret_build_get_ammo_fraction_bridge_state(power_null: bool, power_status: float) -> Dictionary:
	return SourcePowerTurretBuildState.generated_get_ammo_fraction_bridge_state(power_null, power_status)

func source_power_turret_build_sense_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	return SourcePowerTurretBuildState.sense_state(sensor, power_null, power_status, super_sense_value)

func generated_power_turret_build_sense_bridge_state(sensor: String, power_null: bool, power_status: float, super_sense_value: float) -> Dictionary:
	return SourcePowerTurretBuildState.generated_sense_bridge_state(sensor, power_null, power_status, super_sense_value)

func source_power_turret_build_use_ammo_state(shoot_type: Variant) -> Dictionary:
	return SourcePowerTurretBuildState.use_ammo_state(shoot_type)

func generated_power_turret_build_use_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	return SourcePowerTurretBuildState.generated_use_ammo_bridge_state(shoot_type)

func source_power_turret_build_has_ammo_state() -> Dictionary:
	return SourcePowerTurretBuildState.has_ammo_state()

func generated_power_turret_build_has_ammo_bridge_state() -> Dictionary:
	return SourcePowerTurretBuildState.generated_has_ammo_bridge_state()

func source_power_turret_build_peek_ammo_state(shoot_type: Variant) -> Dictionary:
	return SourcePowerTurretBuildState.peek_ammo_state(shoot_type)

func generated_power_turret_build_peek_ammo_bridge_state(shoot_type: Variant) -> Dictionary:
	return SourcePowerTurretBuildState.generated_peek_ammo_bridge_state(shoot_type)

func source_item_turret_limit_range_default_state() -> Dictionary:
	return SourceTurretRangeState.item_turret_limit_range_default_state()

func generated_item_turret_limit_range_default_bridge_state() -> Dictionary:
	return SourceTurretRangeState.generated_item_turret_limit_range_default_bridge_state()

func source_item_turret_limit_range_entries_state(margin: float, ammo_entries: Array) -> Dictionary:
	return SourceTurretRangeState.item_turret_limit_range_entries_state(margin, ammo_entries)

func generated_item_turret_limit_range_entries_bridge_state(margin: float, ammo_entries: Array) -> Dictionary:
	return SourceTurretRangeState.generated_item_turret_limit_range_entries_bridge_state(margin, ammo_entries)

func source_item_turret_set_stats_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	return SourceTurretStatsBarsState.item_turret_set_stats_state(ammo_types, name_value, max_ammo, ammo_per_shot)

func generated_item_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_item_turret_set_stats_bridge_state(ammo_types, name_value, max_ammo, ammo_per_shot)

func generated_item_turret_set_stats_default_bridge_state() -> Dictionary:
	return SourceTurretStatsBarsState.generated_item_turret_set_stats_default_bridge_state(SourceTurretDefaults.MAX_AMMO_DEFAULT, SourceTurretDefaults.AMMO_PER_SHOT_DEFAULT)

func source_item_turret_set_bars_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return SourceTurretStatsBarsState.item_turret_set_bars_state(total_ammo, max_ammo)

func generated_item_turret_set_bars_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_item_turret_set_bars_bridge_state(total_ammo, max_ammo)

func generated_item_turret_set_bars_default_bridge_state(total_ammo: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_item_turret_set_bars_default_bridge_state(total_ammo, SourceTurretDefaults.MAX_AMMO_DEFAULT)

func source_item_turret_init_ground_overlap_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	return SourceItemTurretInitState.ground_overlap_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)

func generated_item_turret_init_ground_overlap_bridge_state(target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, ammo_entries: Array) -> Dictionary:
	return SourceItemTurretInitState.generated_item_turret_init_ground_overlap_bridge_state(target_ground, place_overlap_range, range_value, place_overlap_margin, ammo_entries)

func generated_item_turret_init_ground_overlap_default_bridge_state() -> Dictionary:
	return SourceItemTurretInitState.generated_item_turret_init_ground_overlap_default_bridge_state()

func source_item_turret_build_on_proximity_added_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return SourceItemTurretBuildState.on_proximity_added_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func generated_item_turret_build_on_proximity_added_bridge_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_on_proximity_added_bridge_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func source_item_turret_build_sense_object_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return SourceItemTurretBuildState.sense_object_state(sensor, ammo_size, peek_item, super_sense_object_value)

func generated_item_turret_build_sense_object_bridge_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_sense_object_bridge_state(sensor, ammo_size, peek_item, super_sense_object_value)

func source_item_turret_build_get_ammo_content_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return SourceItemTurretBuildState.get_ammo_content_state(ammo_size, peek_item)

func generated_item_turret_build_get_ammo_content_bridge_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_get_ammo_content_bridge_state(ammo_size, peek_item)

func source_item_turret_build_get_ammo_fraction_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return SourceItemTurretBuildState.get_ammo_fraction_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo: float) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo)

func source_item_turret_build_accept_stack_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return SourceItemTurretBuildState.accept_stack_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_bridge_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_accept_stack_bridge_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_default_bridge_state(item: Variant, amount: int) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_accept_stack_default_bridge_state(item, amount)

func source_item_turret_build_handle_stack_state(item: Variant, amount: int) -> Dictionary:
	return SourceItemTurretBuildState.handle_stack_state(item, amount)

func generated_item_turret_build_handle_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_handle_stack_bridge_state(item, amount)

func source_item_turret_build_remove_stack_state(item: Variant, amount: int) -> Dictionary:
	return SourceItemTurretBuildState.remove_stack_state(item, amount)

func generated_item_turret_build_remove_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_remove_stack_bridge_state(item, amount)

func source_item_turret_build_handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return SourceTurretAmmoState.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

func generated_item_turret_build_handle_item_bridge_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_handle_item_bridge_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

func source_item_turret_build_accept_item_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return SourceTurretAmmoState.item_turret_build_accept_item_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_item_bridge_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_accept_item_bridge_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_item_default_bridge_state(item: Variant) -> Dictionary:
	return SourceItemTurretBuildState.generated_item_turret_build_accept_item_default_bridge_state(item)

func source_item_turret_build_version_state() -> Dictionary:
	return SourceItemTurretBuildState.version_state()

func generated_item_turret_build_version_bridge_state() -> Dictionary:
	return SourceItemTurretBuildState.generated_version_bridge_state()

func source_item_turret_build_write_state(ammo_entries: Array) -> Dictionary:
	return SourceItemTurretBuildState.write_state(ammo_entries)

func generated_item_turret_build_write_bridge_state(ammo_entries: Array) -> Dictionary:
	return SourceItemTurretBuildState.generated_write_bridge_state(ammo_entries)

func source_item_turret_build_read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return SourceItemTurretBuildState.read_state(revision, max_ammo, read_entries)

func generated_item_turret_build_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return SourceItemTurretBuildState.generated_read_bridge_state(revision, max_ammo, read_entries)

func source_item_entry_constructor_state(item: Variant, amount: int) -> Dictionary:
	return SourceItemEntryState.constructor_state(item, amount)

func generated_item_entry_constructor_bridge_state(item: Variant, amount: int) -> Dictionary:
	return SourceItemEntryState.generated_constructor_bridge_state(item, amount)

func source_item_entry_type_state(item: Variant, ammo_type: Variant) -> Dictionary:
	return SourceItemEntryState.type_state(item, ammo_type)

func generated_item_entry_type_bridge_state(item: Variant, ammo_type: Variant) -> Dictionary:
	return SourceItemEntryState.generated_type_bridge_state(item, ammo_type)

func source_item_entry_to_string_state(item_string: String, amount: int) -> Dictionary:
	return SourceItemEntryState.to_string_state(item_string, amount)

func generated_item_entry_to_string_bridge_state(item_string: String, amount: int) -> Dictionary:
	return SourceItemEntryState.generated_to_string_bridge_state(item_string, amount)

func source_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return SourceTurretAmmoState.liquid_turret_ammo_state(objects)

func generated_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return SourceTurretAmmoState.generated_liquid_turret_ammo_bridge_state(objects)

func source_item_turret_ammo_state(objects: Array) -> Dictionary:
	return SourceTurretAmmoState.item_turret_ammo_state(objects)

func generated_item_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return SourceTurretAmmoState.generated_item_turret_ammo_bridge_state(objects)

func source_continuous_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return SourceTurretAmmoState.continuous_liquid_turret_ammo_state(objects)

func generated_continuous_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return SourceTurretAmmoState.generated_continuous_liquid_turret_ammo_bridge_state(objects)

func source_continuous_liquid_turret_set_stats_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	return SourceTurretStatsBarsState.continuous_liquid_turret_set_stats_state(ammo_types, liquid_consumed)

func generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	return SourceTurretStatsBarsState.generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types, liquid_consumed)

func source_liquid_turret_set_stats_state(ammo_types: Variant, name_value: String) -> Dictionary:
	return SourceTurretStatsBarsState.liquid_turret_set_stats_state(ammo_types, name_value)

func generated_liquid_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String) -> Dictionary:
	return SourceTurretStatsBarsState.generated_liquid_turret_set_stats_bridge_state(ammo_types, name_value)

func source_liquid_turret_init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	return SourceLiquidTurretInitState.init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin)

func generated_liquid_turret_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_method_init_2", [ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin], null)
	var canonical = source_liquid_turret_init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin)
	return {
		"source_owner": "PortGame.source_liquid_turret_init_state",
		"generated_owner": "LiquidTurret.init",
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("overlap_updates", []) == canonical.get("overlap_updates", [])
			and result.get("consume_call", {}) == canonical.get("consume_call", {})
			and result.get("super_init_called", false) == canonical.get("super_init_called", false),
	}

func generated_liquid_turret_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_method_init_2", [ammo_entries, target_ground, place_overlap_range], null)
	var canonical = source_liquid_turret_init_state(ammo_entries, target_ground, place_overlap_range, SourceTurretDefaults.RANGE_DEFAULT, SourceTurretDefaults.PLACE_OVERLAP_MARGIN_DEFAULT)
	return {
		"source_owner": "PortGame.source_liquid_turret_init_state",
		"generated_owner": "LiquidTurret.init",
		"defaulted_args": ["range", "place_overlap_margin"],
		"range_value": SourceTurretDefaults.RANGE_DEFAULT,
		"place_overlap_margin": SourceTurretDefaults.PLACE_OVERLAP_MARGIN_DEFAULT,
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("overlap_updates", []) == canonical.get("overlap_updates", []),
	}

func source_continuous_liquid_turret_init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	return SourceContinuousLiquidTurretInitState.init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier)

func generated_continuous_liquid_turret_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_method_init_2", [ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier], null)
	var canonical = source_continuous_liquid_turret_init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_init_state",
		"generated_owner": "ContinuousLiquidTurret.init",
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("multiplier_result", null) == canonical.get("multiplier_result", null)
			and result.get("consume_call", {}) == canonical.get("consume_call", {})
			and result.get("super_init_called", false) == canonical.get("super_init_called", false),
	}

func generated_continuous_liquid_turret_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_method_init_2", [ammo_entries, target_ground, place_overlap_range], null)
	var canonical = source_continuous_liquid_turret_init_state(ammo_entries, target_ground, place_overlap_range, SourceTurretDefaults.RANGE_DEFAULT, SourceTurretDefaults.PLACE_OVERLAP_MARGIN_DEFAULT, 0.0, null, null)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_init_state",
		"generated_owner": "ContinuousLiquidTurret.init",
		"defaulted_args": ["range", "place_overlap_margin"],
		"range_value": SourceTurretDefaults.RANGE_DEFAULT,
		"place_overlap_margin": SourceTurretDefaults.PLACE_OVERLAP_MARGIN_DEFAULT,
		"result": result,
		"canonical": canonical,
		"matches": result.get("place_overlap_range_after", null) == canonical.get("place_overlap_range_after", null)
			and result.get("overlap_updates", []) == canonical.get("overlap_updates", []),
	}

func source_continuous_liquid_turret_build_should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.should_active_sound_state(was_shooting, enabled)

func generated_continuous_liquid_turret_build_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_shouldActiveSound_0", [was_shooting, enabled], null)
	var canonical = source_continuous_liquid_turret_build_should_active_sound_state(was_shooting, enabled)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_should_active_sound_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.shouldActiveSound",
		"result": result,
		"canonical": canonical,
		"matches": result.get("should_active_sound", null) == canonical.get("should_active_sound", null)
			and result.get("was_shooting", null) == canonical.get("was_shooting", null)
			and result.get("enabled", null) == canonical.get("enabled", null),
	}

func source_continuous_liquid_turret_build_get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.get_ammo_content_state(liquids_null, current_amount, current_liquid)

func generated_continuous_liquid_turret_build_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoContent_1", [liquids_null, current_amount, current_liquid], null)
	var canonical = source_continuous_liquid_turret_build_get_ammo_content_state(liquids_null, current_amount, current_liquid)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_content_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.getAmmoContent",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_content", null) == canonical.get("ammo_content", null)
			and result.get("liquids_null", null) == canonical.get("liquids_null", null)
			and result.get("current_amount", null) == canonical.get("current_amount", null)
			and result.get("current_liquid", null) == canonical.get("current_liquid", null),
	}

func source_continuous_liquid_turret_build_get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.get_ammo_fraction_state(current_amount, liquid_capacity)

func generated_continuous_liquid_turret_build_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_getAmmoFraction_2", [current_amount, liquid_capacity], null)
	var canonical = source_continuous_liquid_turret_build_get_ammo_fraction_state(current_amount, liquid_capacity)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_get_ammo_fraction_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null)
			and result.get("current_amount", null) == canonical.get("current_amount", null)
			and result.get("liquid_capacity", null) == canonical.get("liquid_capacity", null),
	}

func source_continuous_liquid_turret_build_update_tile_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.update_tile_state(current_amount, liquid_consumed, activated_before)

func generated_continuous_liquid_turret_build_update_tile_bridge_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_updateTile_3", [current_amount, liquid_consumed, activated_before], null)
	var canonical = source_continuous_liquid_turret_build_update_tile_state(current_amount, liquid_consumed, activated_before)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_update_tile_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.updateTile",
		"result": result,
		"canonical": canonical,
		"matches": result.get("activated_after", null) == canonical.get("activated_after", null)
			and result.get("current_amount", null) == canonical.get("current_amount", null)
			and result.get("liquid_consumed", null) == canonical.get("liquid_consumed", null)
			and result.get("activated_before", null) == canonical.get("activated_before", null)
			and result.get("super_update_tile_called", false) == canonical.get("super_update_tile_called", false),
	}

func source_continuous_liquid_turret_build_sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.sense_object_state(sensor, current_liquid, super_sense_object_value)

func generated_continuous_liquid_turret_build_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_senseObject_4", [sensor, current_liquid, super_sense_object_value], null)
	var canonical = source_continuous_liquid_turret_build_sense_object_state(sensor, current_liquid, super_sense_object_value)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_sense_object_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.senseObject",
		"result": result,
		"canonical": canonical,
		"matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null)
			and result.get("sensor", null) == canonical.get("sensor", null)
			and result.get("current_liquid", null) == canonical.get("current_liquid", null)
			and result.get("super_sense_object_value", null) == canonical.get("super_sense_object_value", null),
	}

func source_continuous_liquid_turret_build_can_consume_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.can_consume_state(has_correct_ammo, super_can_consume)

func generated_continuous_liquid_turret_build_can_consume_bridge_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_canConsume_5", [has_correct_ammo, super_can_consume], null)
	var canonical = source_continuous_liquid_turret_build_can_consume_state(has_correct_ammo, super_can_consume)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_can_consume_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.canConsume",
		"result": result,
		"canonical": canonical,
		"matches": result.get("can_consume", null) == canonical.get("can_consume", null)
			and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null)
			and result.get("super_can_consume", null) == canonical.get("super_can_consume", null),
	}

func source_continuous_liquid_turret_build_should_consume_state(super_should_consume: bool, activated: bool) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.should_consume_state(super_should_consume, activated)

func generated_continuous_liquid_turret_build_should_consume_bridge_state(super_should_consume: bool, activated: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_shouldConsume_6", [super_should_consume, activated], null)
	var canonical = source_continuous_liquid_turret_build_should_consume_state(super_should_consume, activated)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_should_consume_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.shouldConsume",
		"result": result,
		"canonical": canonical,
		"matches": result.get("should_consume", null) == canonical.get("should_consume", null)
			and result.get("super_should_consume", null) == canonical.get("super_should_consume", null)
			and result.get("activated", null) == canonical.get("activated", null),
	}

func source_continuous_liquid_turret_build_use_ammo_state(peek_ammo: Variant) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.use_ammo_state(peek_ammo)

func generated_continuous_liquid_turret_build_use_ammo_bridge_state(peek_ammo: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_useAmmo_7", [peek_ammo], null)
	var canonical = source_continuous_liquid_turret_build_use_ammo_state(peek_ammo)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_use_ammo_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.useAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_ammo", null) == canonical.get("returned_ammo", null)
			and result.get("peek_ammo", null) == canonical.get("peek_ammo", null),
	}

func source_continuous_liquid_turret_build_peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.peek_ammo_state(current_liquid, ammo_type)

func generated_continuous_liquid_turret_build_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_peekAmmo_8", [current_liquid, ammo_type], null)
	var canonical = source_continuous_liquid_turret_build_peek_ammo_state(current_liquid, ammo_type)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_peek_ammo_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.peekAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("peek_ammo", null) == canonical.get("peek_ammo", null)
			and result.get("current_liquid", null) == canonical.get("current_liquid", null),
	}

func source_continuous_liquid_turret_build_has_ammo_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.has_ammo_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)

func generated_continuous_liquid_turret_build_has_ammo_bridge_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_hasAmmo_9", [has_correct_ammo, current_liquid, ammo_type, current_amount, activated], null)
	var canonical = source_continuous_liquid_turret_build_has_ammo_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_has_ammo_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.hasAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("has_ammo", null) == canonical.get("has_ammo", null)
			and result.get("ammo_type_present", null) == canonical.get("ammo_type_present", null)
			and result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null)
			and result.get("activated", null) == canonical.get("activated", null),
	}

func source_continuous_liquid_turret_build_has_correct_ammo_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.has_correct_ammo_state(bullets_any, first_bullet_type, peek_ammo)

func generated_continuous_liquid_turret_build_has_correct_ammo_bridge_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_hasCorrectAmmo_10", [bullets_any, first_bullet_type, peek_ammo], null)
	var canonical = source_continuous_liquid_turret_build_has_correct_ammo_state(bullets_any, first_bullet_type, peek_ammo)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_has_correct_ammo_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.hasCorrectAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("has_correct_ammo", null) == canonical.get("has_correct_ammo", null)
			and result.get("bullets_any", null) == canonical.get("bullets_any", null)
			and result.get("first_bullet_type", null) == canonical.get("first_bullet_type", null)
			and result.get("peek_ammo", null) == canonical.get("peek_ammo", null),
	}

func source_continuous_liquid_turret_build_accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.accept_item_state(source_building, item)

func generated_continuous_liquid_turret_build_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_acceptItem_11", [source_building, item], null)
	var canonical = source_continuous_liquid_turret_build_accept_item_state(source_building, item)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_item_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_item", null) == canonical.get("accept_item", null)
			and result.get("source_building", null) == canonical.get("source_building", null)
			and result.get("item", null) == canonical.get("item", null),
	}

func source_continuous_liquid_turret_build_accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return SourceContinuousLiquidTurretBuildState.accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)

func generated_continuous_liquid_turret_build_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.gd", "java_inner_class_ContinuousLiquidTurretBuild_method_acceptLiquid_12", [source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier], null)
	var canonical = source_continuous_liquid_turret_build_accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	return {
		"source_owner": "PortGame.source_continuous_liquid_turret_build_accept_liquid_state",
		"generated_owner": "ContinuousLiquidTurret.ContinuousLiquidTurretBuild.acceptLiquid",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_liquid", null) == canonical.get("accept_liquid", null)
			and result.get("replacement_allowed", null) == canonical.get("replacement_allowed", null)
			and result.get("current_required_with_epsilon", null) == canonical.get("current_required_with_epsilon", null),
	}

func source_liquid_turret_build_should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return SourceLiquidTurretBuildState.should_active_sound_state(was_shooting, enabled)

func generated_liquid_turret_build_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_shouldActiveSound_0", [was_shooting, enabled], null)
	var canonical = source_liquid_turret_build_should_active_sound_state(was_shooting, enabled)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_should_active_sound_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.shouldActiveSound",
		"result": result,
		"canonical": canonical,
		"matches": result.get("should_active_sound", null) == canonical.get("should_active_sound", null)
			and result.get("was_shooting", null) == canonical.get("was_shooting", null)
			and result.get("enabled", null) == canonical.get("enabled", null),
	}

func source_liquid_turret_build_get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return SourceLiquidTurretBuildState.get_ammo_content_state(liquids_null, current_amount, current_liquid)

func generated_liquid_turret_build_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_getAmmoContent_1", [liquids_null, current_amount, current_liquid], null)
	var canonical = source_liquid_turret_build_get_ammo_content_state(liquids_null, current_amount, current_liquid)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_get_ammo_content_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.getAmmoContent",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_content", null) == canonical.get("ammo_content", null)
			and result.get("liquids_null", null) == canonical.get("liquids_null", null)
			and result.get("current_amount", null) == canonical.get("current_amount", null)
			and result.get("current_liquid", null) == canonical.get("current_liquid", null),
	}

func source_liquid_turret_build_get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return SourceLiquidTurretBuildState.get_ammo_fraction_state(current_amount, liquid_capacity)

func generated_liquid_turret_build_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_getAmmoFraction_2", [current_amount, liquid_capacity], null)
	var canonical = source_liquid_turret_build_get_ammo_fraction_state(current_amount, liquid_capacity)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_get_ammo_fraction_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null)
			and result.get("current_amount", null) == canonical.get("current_amount", null)
			and result.get("liquid_capacity", null) == canonical.get("liquid_capacity", null),
	}

func source_liquid_turret_build_sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return SourceLiquidTurretBuildState.sense_object_state(sensor, current_liquid, super_sense_object_value)

func generated_liquid_turret_build_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_senseObject_3", [sensor, current_liquid, super_sense_object_value], null)
	var canonical = source_liquid_turret_build_sense_object_state(sensor, current_liquid, super_sense_object_value)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_sense_object_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.senseObject",
		"result": result,
		"canonical": canonical,
		"matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null)
			and result.get("sensor", null) == canonical.get("sensor", null)
			and result.get("current_liquid", null) == canonical.get("current_liquid", null)
			and result.get("super_sense_object_value", null) == canonical.get("super_sense_object_value", null),
	}

func source_liquid_turret_build_find_target_extinguish_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	return SourceLiquidTurretBuildState.find_target_extinguish_state(extinguish, current_liquid_can_extinguish, fire_result)

func generated_liquid_turret_build_find_target_extinguish_bridge_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_findTarget_4", [extinguish, current_liquid_can_extinguish, fire_result], null)
	var canonical = source_liquid_turret_build_find_target_extinguish_state(extinguish, current_liquid_can_extinguish, fire_result)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_find_target_extinguish_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.findTarget",
		"result": result,
		"canonical": canonical,
		"matches": result.get("target_after", null) == canonical.get("target_after", null)
			and result.get("target_assigned", null) == canonical.get("target_assigned", null)
			and result.get("super_find_target_called", null) == canonical.get("super_find_target_called", null)
			and result.get("should_scan_fires", null) == canonical.get("should_scan_fires", null),
	}

func source_liquid_turret_build_use_ammo_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	return SourceLiquidTurretBuildState.use_ammo_state(cheating, current_liquid, ammo_type, ammo_multiplier)

func generated_liquid_turret_build_use_ammo_bridge_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_useAmmo_5", [cheating, current_liquid, ammo_type, ammo_multiplier], null)
	var canonical = source_liquid_turret_build_use_ammo_state(cheating, current_liquid, ammo_type, ammo_multiplier)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_use_ammo_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.useAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("returned_ammo", null) == canonical.get("returned_ammo", null)
			and result.get("liquid_remove_amount", null) == canonical.get("liquid_remove_amount", null)
			and result.get("remove_liquid_call", {}) == canonical.get("remove_liquid_call", {})
			and result.get("cheating", null) == canonical.get("cheating", null),
	}

func source_liquid_turret_build_peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return SourceLiquidTurretBuildState.peek_ammo_state(current_liquid, ammo_type)

func generated_liquid_turret_build_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_peekAmmo_6", [current_liquid, ammo_type], null)
	var canonical = source_liquid_turret_build_peek_ammo_state(current_liquid, ammo_type)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_peek_ammo_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.peekAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("peek_ammo", null) == canonical.get("peek_ammo", null),
	}

func source_liquid_turret_build_has_ammo_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	return SourceLiquidTurretBuildState.has_ammo_state(current_liquid, ammo_type, current_amount, ammo_multiplier)

func generated_liquid_turret_build_has_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_hasAmmo_7", [current_liquid, ammo_type, current_amount, ammo_multiplier], null)
	var canonical = source_liquid_turret_build_has_ammo_state(current_liquid, ammo_type, current_amount, ammo_multiplier)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_has_ammo_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.hasAmmo",
		"result": result,
		"canonical": canonical,
		"matches": result.get("has_ammo", null) == canonical.get("has_ammo", null)
			and result.get("required_amount", null) == canonical.get("required_amount", null)
			and result.get("ammo_type_present", null) == canonical.get("ammo_type_present", null),
	}

func source_liquid_turret_build_accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	return SourceLiquidTurretBuildState.accept_item_state(source_building, item)

func generated_liquid_turret_build_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_acceptItem_8", [source_building, item], null)
	var canonical = source_liquid_turret_build_accept_item_state(source_building, item)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_accept_item_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_item", null) == canonical.get("accept_item", null),
	}

func source_liquid_turret_build_accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return SourceLiquidTurretBuildState.accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)

func generated_liquid_turret_build_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/LiquidTurret.gd", "java_inner_class_LiquidTurretBuild_method_acceptLiquid_9", [source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier], null)
	var canonical = source_liquid_turret_build_accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
	return {
		"source_owner": "PortGame.source_liquid_turret_build_accept_liquid_state",
		"generated_owner": "LiquidTurret.LiquidTurretBuild.acceptLiquid",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_liquid", null) == canonical.get("accept_liquid", null)
			and result.get("replacement_allowed", null) == canonical.get("replacement_allowed", null)
			and result.get("current_required_with_epsilon", null) == canonical.get("current_required_with_epsilon", null),
	}

func source_turret_ammo_data(turret, item_id: String) -> Dictionary:
	return SourceTurretAmmoState.turret_item_turret_ammo_data(turret, item_id)

func peek_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	return SourceTurretAmmoState.peek_turret_ammo(self, cell, turret)

func handle_turret_item(cell: Vector2i, turret, item_id: String) -> bool:
	return SourceTurretAmmoState.handle_turret_item(self, cell, turret, item_id)

func use_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	return SourceTurretAmmoState.use_turret_ammo(self, cell, turret)

func bootstrap_selected_turret_ammo() -> int:
	return SourceTurretAmmoState.bootstrap_selected_turret_ammo(self)

func load_selected_turret_ammo(item_id: String, amount: int) -> int:
	return SourceTurretAmmoState.load_selected_turret_ammo(self, item_id, amount)

func use_selected_turret_ammo_once() -> Dictionary:
	return SourceTurretAmmoState.use_selected_turret_ammo_once(self)

func selected_turret_reload_seconds() -> float:
	return SourceTurretRuntimeState.selected_turret_float_stat(self, "source_turret_reload_seconds")

func selected_turret_range() -> float:
	return SourceTurretRuntimeState.selected_turret_float_stat(self, "source_turret_range")

func selected_turret_shoot_y() -> float:
	return SourceTurretRuntimeState.selected_turret_float_stat(self, "source_turret_shoot_y")

func selected_turret_shoot_pattern() -> Dictionary:
	return SourceTurretRuntimeState.selected_turret_dict_stat(self, "source_turret_shoot_pattern")

func selected_turret_inaccuracy() -> float:
	return SourceTurretRuntimeState.selected_turret_float_stat(self, "source_turret_inaccuracy")

func selected_turret_rotate_speed() -> float:
	return SourceTurretRuntimeState.selected_turret_float_stat(self, "source_turret_rotate_speed")

func selected_turret_shoot_cone() -> float:
	return SourceTurretRuntimeState.selected_turret_float_stat(self, "source_turret_shoot_cone")

func selected_turret_recoil() -> float:
	return SourceTurretRuntimeState.selected_turret_float_stat(self, "source_turret_recoil")

func selected_turret_recoils() -> int:
	return SourceTurretRuntimeState.selected_turret_int_stat(self, "source_turret_recoils")

func source_turret_reload_seconds(turret) -> float:
	return SourceTurretRuntimeState.turret_reload_seconds(turret, SourceTurretPropertyState.SOURCE_TURRET_RELOAD_KEY, SourceTurretDefaults.RELOAD_DEFAULT, SourceTimeDefaults.TICK_RATE)

func source_turret_reload_seconds_for_ammo(turret, data: Dictionary) -> float:
	return SourceTurretRuntimeState.turret_reload_seconds_for_ammo(source_turret_reload_seconds(turret), data, source_bullet_reload_multiplier(data))

func source_turret_range(turret) -> float:
	return SourceTurretRuntimeState.turret_range(turret, SourceTurretPropertyState.SOURCE_TURRET_RANGE_KEY, SourceTurretDefaults.RANGE_DEFAULT)

func source_turret_shoot_y(turret) -> float:
	return SourceTurretRuntimeState.turret_shoot_y(turret, SourceTurretPropertyState.SOURCE_TURRET_SHOOT_Y_KEY, SourceTurretDefaults.SHOOT_Y_DEFAULT)

func source_turret_inaccuracy(turret) -> float:
	return SourceTurretRuntimeState.turret_inaccuracy(turret, SourceTurretPropertyState.SOURCE_TURRET_INACCURACY_KEY, SourceTurretDefaults.INACCURACY_DEFAULT)

func source_turret_rotate_speed(turret) -> float:
	return SourceTurretRuntimeState.turret_rotate_speed(turret, SourceTurretPropertyState.SOURCE_TURRET_ROTATE_SPEED_KEY, SourceTurretDefaults.ROTATE_SPEED_DEFAULT)

func source_turret_shoot_cone(turret) -> float:
	return SourceTurretRuntimeState.turret_shoot_cone(turret, SourceTurretPropertyState.SOURCE_TURRET_SHOOT_CONE_KEY, SourceTurretDefaults.SHOOT_CONE_DEFAULT)

func source_turret_recoil(turret) -> float:
	return SourceTurretRuntimeState.turret_recoil(turret, SourceTurretPropertyState.SOURCE_TURRET_RECOIL_KEY, SourceTurretDefaults.RECOIL_DEFAULT)

func source_turret_recoils(turret) -> int:
	return SourceTurretRuntimeState.turret_recoils(turret, SourceTurretPropertyState.SOURCE_TURRET_RECOILS_KEY, SourceTurretDefaults.RECOILS_DEFAULT)

func source_turret_recoil_time(turret) -> float:
	return SourceTurretRuntimeState.turret_recoil_time(turret, SourceTurretPropertyState.SOURCE_TURRET_RECOIL_TIME_KEY, SourceTurretDefaults.RECOIL_TIME_DEFAULT, SourceTurretPropertyState.SOURCE_TURRET_RELOAD_KEY, SourceTurretDefaults.RELOAD_DEFAULT, SourceTimeDefaults.TICK_RATE)

func source_turret_recoil_offset(turret, recoil_rotation_degrees: float, cur_recoil: float) -> Vector2:
	return SourceTurretCombatState.recoil_offset(recoil_rotation_degrees, cur_recoil, SourceTurretCombatState.SOURCE_TURRET_RECOIL_OFFSET_RECOIL_POW_DEFAULT, source_turret_recoil(turret))

func update_turret_recoil(cell: Vector2i, turret, delta: float, recoil_rotation_degrees: float) -> void:
	SourceTurretCombatState.update_turret_recoil(self, cell, turret, delta, recoil_rotation_degrees)

func apply_turret_recoil_offset(cell: Vector2i, turret, offset: Vector2) -> void:
	SourceTurretCombatState.apply_turret_recoil_offset(self, cell, turret, offset)

func source_turret_shoot_pattern(turret) -> Dictionary:
	return SourceTurretRuntimeState.turret_shoot_pattern(turret, SourceTurretPropertyState.SOURCE_TURRET_SHOOT_PATTERN_KEY)

func use_turret_shoot_x_offset(cell: Vector2i, turret) -> float:
	return SourceTurretCombatState.use_turret_shoot_x_offset(self, cell, turret)

func source_turret_bullet_origin(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset := 0.0, y_offset := 0.0, x_spread := 0.0) -> Dictionary:
	return SourceTurretCombatState.turret_bullet_origin_state(
		origin_x,
		origin_y,
		turret_rotation_degrees,
		turret,
		shoot_x_offset,
		y_offset,
		x_spread,
		SourceTurretCombatState.SOURCE_TURRET_SHOOT_X_DEFAULT,
		SourceBlockDefaults.SIZE_DEFAULT,
		int(SourceWorldDefaults.TILESIZE),
		Callable(self, "source_arc_angles_trns_vec")
	)

func source_angle_to_target(origin, target) -> float:
	return SourceTurretCombatState.angle_to_target(origin, target, Callable(self, "source_arc_angles_angle"))

func source_angle_distance(current_degrees: float, target_degrees: float) -> float:
	return SourceMathState.source_angles_angle_dist(current_degrees, target_degrees)

func source_move_angle_toward(current_degrees: float, target_degrees: float, max_delta: float) -> float:
	return SourceMathState.source_angles_move_toward(current_degrees, target_degrees, max_delta)

func source_bullet_range_change(data: Dictionary) -> float:
	return SourceBulletRuntimeState.range_change(data)

func source_bullet_extra_range_margin(data: Dictionary) -> float:
	return SourceBulletRuntimeState.extra_range_margin(data)

func source_bullet_inaccuracy(data: Dictionary) -> float:
	return SourceBulletRuntimeState.inaccuracy(data)

func source_turret_total_inaccuracy(turret, data: Dictionary) -> float:
	return SourceTurretCombatState.total_inaccuracy(source_turret_inaccuracy(turret), source_bullet_inaccuracy(data))

func source_turret_range_for_ammo(turret, data: Dictionary) -> float:
	return SourceTurretRuntimeState.turret_range_for_ammo(source_turret_range(turret), data, source_bullet_range_change(data))

func source_bullet_lifetime_seconds(data: Dictionary) -> float:
	return SourceBulletRuntimeState.lifetime_seconds(data)

func source_bullet_world_speed_per_tick(data: Dictionary) -> float:
	return SourceBulletRuntimeState.world_speed_per_tick(data)

func source_bullet_world_speed(data: Dictionary) -> float:
	return SourceBulletRuntimeState.world_speed(data)

func source_bullet_velocity(data: Dictionary, shoot_angle_degrees: float) -> Vector2:
	return SourceBulletRuntimeState.velocity(data, shoot_angle_degrees)

func source_bullet_hit_size(data: Dictionary) -> float:
	return SourceBulletRuntimeState.hit_size(data)

func source_bullet_damage(data: Dictionary) -> float:
	return SourceBulletRuntimeState.damage(data)

func source_bullet_ammo_multiplier(data: Dictionary) -> float:
	return SourceBulletRuntimeState.ammo_multiplier(data)

func source_bullet_reload_multiplier(data: Dictionary) -> float:
	return SourceBulletRuntimeState.reload_multiplier(data)

func source_bullet_dimensions(data: Dictionary) -> Dictionary:
	return SourceBulletRuntimeState.dimensions(data)

func source_bullet_scale(data: Dictionary, texture_size: Vector2) -> Vector2:
	return SourceBulletRuntimeState.scale(data, texture_size)

func find_enemy_target(origin: Vector2, range_pixels: float):
	var target_state := SourceTurretCombatState.enemy_target_state(origin, range_pixels, enemy_units)
	return target_state.get("target", null)

func spawn_turret_bullet(origin: Vector2, target, data: Dictionary, shoot_angle_degrees := 0.0) -> void:
	SourceBulletRuntimeState.spawn_turret_bullet(self, origin, target, data, shoot_angle_degrees)

func simulate_bullets(delta: float) -> void:
	SourceBulletRuntimeState.simulate_bullets(self, delta)

func update_camera(delta: float) -> void:
	SourceInputViewportRuntimeState.update_camera(self, delta)

func source_input_runtime_summary_state() -> Dictionary:
	return input_runtime.runtime_summary_with_source_owner("PortGame.source_input_runtime_summary_state")

func get_runtime_summary() -> Dictionary:
	return SourceGameRuntimeSummaryState.summary_state(self)

func update_hud() -> void:
	if hud_label == null:
		return
	hud_label.text = SourceHudRuntimeState.hud_text(self, Callable(self, "requirements_text"))
