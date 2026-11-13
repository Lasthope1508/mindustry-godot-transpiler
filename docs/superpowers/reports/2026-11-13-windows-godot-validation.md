# Windows Godot validation and proof fixture repair — 2026-11-13

**Result: the selected Godot-dependent coverage is GREEN after five proof fixture repairs. The immutable baseline was NOT GREEN (96 passed, 5 failed).**

## Revision, environment and scope

- Base: `Lasthope1508/mindustry-godot-transpiler` main `b969e046d0d56c22da4f7e59e8736f621a7e522e` (N2145). Remote main was checked again before publication.
- Windows, Godot `4.6.2.stable.official.71f334935`, Python 3.13.3, `javalang==0.13.0`.
- Upstream dependencies use README pins: Mindustry `2bdedfed25932ebf11330d3584092c50e2e26d96`, Arc `f30acd23ece4b626b755660d56c1b0d4aaf46aed`.
- Prior Linux gate: 5,677 tests, 96 failures attributed to unavailable Godot, 5 skips, 0 errors. This validation selected all 101 Godot-dependent methods, including helper-mediated WorldTileLifecycle calls. See the exact manifest.
- The initial 101 tests ran sequentially against unchanged base source. TCP 7777 was checked before each run; no competing game instances were used.

## Results

| Check | Result |
|---|---|
| Immutable baseline, 101 existing methods | 96 PASS, 5 FAIL, 0 errors, 0 skips |
| Final targeted proof run, including all five failures and three neighbors | 8/8 PASS |
| Distinct methods with passing evidence across baseline and final rerun | 101/101; cumulative coverage, not a new complete 101-test run |
| Static tests from the eight relevant modules | 24/24 PASS |
| Generated JSON syntax parsing | 113/113 files valid; not a schema/full gate claim |
| Godot MCP debug sessions | FactoryConsumerBinding and UnitFactoryConsumerBinding: matches=true, ping connected, no ERROR/SCRIPT ERROR |
| Graphical Godot, no --headless | FactoryConsumerBinding: exit 0, NVIDIA OpenGL renderer, matches=true, no ERROR |
| Defense stability, seeded upstream proof | 3/3 PASS: baseline plus two repeats |

The MCP launcher uses `--headless -d` on this host. The separate graphical launch is recorded in visible-factory.log. MCP debug logs include 99 existing GDScript warnings per session (shadowing, ternary types, unused parameters, integer division); these are retained, not described as an empty warning stream. Both MCP projects were stopped after checking output. The graphical process exited normally.

## Initial failures and minimal repairs

| Proof | Failure on base | Fixture repair |
|---|---|---|
| FactoryConsumerBinding | Powered efficiency/water consumption assertions fail; no producer | Add a thorium reactor and start the background battery full |
| C06FactoryCraft | Live silicon input/output counts fail | Add a thorium reactor |
| C06FactoryDumpOutputs | Live mixer water/progress/efficiency fail | Add a thorium reactor |
| C06FactoryLiquidOutput | Live mixer/electrolyzer output/consumption fail | Add a thorium reactor |
| UnitFactoryConsumerBinding | Assembler cyanogen consumption/efficiency fail | Supply tier-zero payloads (stell 4, tungsten-wall-large 10) and unitCap 10 |

- N2145 correctly folds live power.status into crafter efficiency (`ConsumePower.java:39`). The four older scenes assumed a powered graph. This follows the producer setup already used by upstream FactoryShouldConsumeProof; the current producer model supplies catalog powerProduction and does not simulate reactor fuel/coolant.
- A producer alone fixes most assertions, but FactoryConsumerBinding restoration still reads efficiency 0.9454545: the bootstrap battery absorbs surplus before PowerGraph estimates power for an idle consumer (`PowerGraph.java:205-206`). A second producer alone did not fix it. Starting the fixture battery full isolates the existing full-efficiency restoration assertion without bypassing the graph.
- Assembler shouldConsume requires payload stacks (`UnitAssembler.java:389-391`, plan `Blocks.java:6526`) and Units.canCreate (`Units.java:115-117`). Payloads alone remain blocked by the bootstrap zero unitCap default. Both are now explicit fixture inputs.
- No gameplay implementation, SSOT, assertion, timeout, skip condition or RNG seed was changed. These are proof setup repairs, not new migration slices. Temporary diagnostics were removed before the final run. Intermediate diagnostic runs remain local; committed RED evidence is the unchanged baseline, and committed GREEN evidence is the final eight-proof run.

## Earlier C06 queue

- C06DefenseProof: PASS, including two extra repeats; the upstream seed(12345) fix was already in the tested base.
- DrillProximityLifecycleProof and FactoryDumpSwapProof: PASS in the baseline, without ERROR lines.
- Other Godot-dependent methods in the manifest were exercised; this does not declare unfinished C07-C12 gameplay complete.

## Evidence and reproduction

- [Final summary](evidence/2026-11-13-windows-godot/final-summary.json), [baseline](evidence/2026-11-13-windows-godot/results.json), [manifest](evidence/2026-11-13-windows-godot/manifest.json), [environment](evidence/2026-11-13-windows-godot/environment.json), [final 8-proof results](evidence/2026-11-13-windows-godot/rerun-080853/results.json).
- [Static tests](evidence/2026-11-13-windows-godot/static-tests.log), [static/JSON summary](evidence/2026-11-13-windows-godot/static-results.json), [MCP factory](evidence/2026-11-13-windows-godot/native-factory.json), [MCP assembler](evidence/2026-11-13-windows-godot/native-unit.json), [graphical run](evidence/2026-11-13-windows-godot/visible-factory.log).
- Defense repeats: [rerun-081428](evidence/2026-11-13-windows-godot/rerun-081428/results.json), [rerun-081504](evidence/2026-11-13-windows-godot/rerun-081504/results.json).
- Run `python run_validation.py --root ABSOLUTE_REPO_ROOT` with its manifest alongside it. Optional `--only EXACT_TEST_ID ...` creates a separate evidence directory. The recorder forwards existing subprocess arguments/results unchanged and saves logs and fresh proof JSON.
- Run `python run_static_checks.py ABSOLUTE_REPO_ROOT` for the 24 neighboring static tests and generated JSON syntax parsing.
- Evidence logs normalize terminal empty lines for git diff --check; diagnostic messages and test results are retained.
- Baseline environment.json records the base SHA. Final rerun environment.json also records that HEAD because the five fixture edits were still uncommitted; the final fixture content is the content in this validation commit.
- Source-adjacent ignored proof JSON, Godot import/UID churn, project.godot and dependency junctions are excluded from the commit. Only copied evidence snapshots under this report are versioned.

## Baseline method results

| # | Existing unittest method | Baseline | Final targeted |
|---:|---|---|---|
| 1 | `tests.test_adjacent_factory_consumer_binding.AdjacentFactoryConsumerBindingTests.test_reference_graph_and_actual_adjacent_factory_consumer_binding` | [PASS](evidence/2026-11-13-windows-godot/test-001.log) | Not rerun |
| 2 | `tests.test_adjacent_factory_live_loop.AdjacentFactoryLiveLoopTests.test_reference_graph_and_actual_adjacent_factory_live_loop` | [PASS](evidence/2026-11-13-windows-godot/test-002.log) | Not rerun |
| 3 | `tests.test_battery_placement_binding.BatteryPlacementBindingTests.test_reference_graph_and_actual_battery_placement` | [PASS](evidence/2026-11-13-windows-godot/test-003.log) | Not rerun |
| 4 | `tests.test_battery_power_status_binding.BatteryPowerStatusBindingTests.test_reference_graph_and_actual_battery_power_status` | [PASS](evidence/2026-11-13-windows-godot/test-004.log) | Not rerun |
| 5 | `tests.test_building_dump_binding.BuildingDumpBindingTests.test_reference_graph_and_actual_building_dump` | [PASS](evidence/2026-11-13-windows-godot/test-005.log) | Not rerun |
| 6 | `tests.test_building_proximity_mutation.BuildingProximityMutationTests.test_reference_graph_and_actual_tile_pre_change` | [PASS](evidence/2026-11-13-windows-godot/test-006.log) | Not rerun |
| 7 | `tests.test_building_update_consumption_generated_delegate.BuildingUpdateConsumptionGeneratedDelegateTests.test_consumption_runtime_matrix_against_java_expectations` | [PASS](evidence/2026-11-13-windows-godot/test-007.log) | Not rerun |
| 8 | `tests.test_c05_gate.C05GateTests.test_reference_graph_and_actual_c05_gate` | [PASS](evidence/2026-11-13-windows-godot/test-008.log) | Not rerun |
| 9 | `tests.test_c06_battery_enabled_stamp.C06BatteryEnabledStampTests.test_reference_graph_and_actual_c06_battery_enabled_stamp` | [PASS](evidence/2026-11-13-windows-godot/test-009.log) | Not rerun |
| 10 | `tests.test_c06_building_update_halves.C06BuildingUpdateHalvesTests.test_reference_graph_and_actual_c06_building_update_halves` | [PASS](evidence/2026-11-13-windows-godot/test-010.log) | Not rerun |
| 11 | `tests.test_c06_defense_leg.C06DefenseLegTests.test_reference_graph_and_actual_c06_defense_leg` | [PASS](evidence/2026-11-13-windows-godot/test-011.log) | Not rerun |
| 12 | `tests.test_c06_disabled_belt_efficiency.C06DisabledBeltEfficiencyTests.test_reference_graph_and_actual_c06_disabled_belt_efficiency` | [PASS](evidence/2026-11-13-windows-godot/test-012.log) | Not rerun |
| 13 | `tests.test_c06_pause_gate.C06PauseGateTests.test_reference_graph_and_actual_c06_pause_gate` | [PASS](evidence/2026-11-13-windows-godot/test-013.log) | Not rerun |
| 14 | `tests.test_c06_power_should_consume.C06PowerShouldConsumeTests.test_reference_graph_and_actual_c06_power_should_consume` | [PASS](evidence/2026-11-13-windows-godot/test-014.log) | Not rerun |
| 15 | `tests.test_c06_reconstructor_production_tick.C06ReconstructorProductionTickTests.test_reference_graph_and_actual_c06_reconstructor_production_tick` | [PASS](evidence/2026-11-13-windows-godot/test-015.log) | Not rerun |
| 16 | `tests.test_c06_session_snapshot.C06SessionSnapshotTests.test_reference_graph_and_actual_c06_session_snapshot` | [PASS](evidence/2026-11-13-windows-godot/test-016.log) | Not rerun |
| 17 | `tests.test_c06_source_exhaustion_output_full.C06SourceExhaustionOutputFullTests.test_reference_graph_and_actual_c06_source_exhaustion_output_full` | [PASS](evidence/2026-11-13-windows-godot/test-017.log) | Not rerun |
| 18 | `tests.test_c06_unit_assembler_check_tier.C06UnitAssemblerCheckTierTests.test_reference_graph_and_actual_c06_unit_assembler_check_tier` | [PASS](evidence/2026-11-13-windows-godot/test-018.log) | Not rerun |
| 19 | `tests.test_c06_unit_assembler_payload.C06UnitAssemblerPayloadTests.test_reference_graph_and_actual_c06_unit_assembler_payload` | [PASS](evidence/2026-11-13-windows-godot/test-019.log) | Not rerun |
| 20 | `tests.test_c06_unit_assembler_payload_intake.C06UnitAssemblerPayloadIntakeTests.test_reference_graph_and_actual_c06_unit_assembler_payload_intake` | [PASS](evidence/2026-11-13-windows-godot/test-020.log) | Not rerun |
| 21 | `tests.test_c06_unit_assembler_payload_should_consume.C06UnitAssemblerPayloadShouldConsumeTests.test_reference_graph_and_actual_c06_unit_assembler_payload_should_consume` | [PASS](evidence/2026-11-13-windows-godot/test-021.log) | Not rerun |
| 22 | `tests.test_c06_unit_assembler_payload_trigger.C06UnitAssemblerPayloadTriggerTests.test_reference_graph_and_actual_c06_unit_assembler_payload_trigger` | [PASS](evidence/2026-11-13-windows-godot/test-022.log) | Not rerun |
| 23 | `tests.test_c06_unit_assembler_production_tick.C06UnitAssemblerProductionTickTests.test_reference_graph_and_actual_c06_unit_assembler_production_tick` | [PASS](evidence/2026-11-13-windows-godot/test-023.log) | Not rerun |
| 24 | `tests.test_c06_unit_factory_consume_trigger.C06UnitFactoryConsumeTriggerTests.test_reference_graph_and_actual_c06_unit_factory_consume_trigger` | [PASS](evidence/2026-11-13-windows-godot/test-024.log) | Not rerun |
| 25 | `tests.test_c06_unit_factory_production_tick.C06UnitFactoryProductionTickTests.test_reference_graph_and_actual_c06_unit_factory_production_tick` | [PASS](evidence/2026-11-13-windows-godot/test-025.log) | Not rerun |
| 26 | `tests.test_c06_unit_factory_should_consume_power_stamp.C06UnitFactoryShouldConsumePowerStampTests.test_reference_graph_and_actual_c06_unit_factory_should_consume_power_stamp` | [PASS](evidence/2026-11-13-windows-godot/test-026.log) | Not rerun |
| 27 | `tests.test_c07_assembler_drones_in_position.C07AssemblerDronesInPositionTests.test_reference_graph_and_actual_c07_assembler_drones_in_position` | [PASS](evidence/2026-11-13-windows-godot/test-027.log) | Not rerun |
| 28 | `tests.test_c07_factory_power_status.C07FactoryPowerStatusTests.test_reference_graph_and_actual_c07_factory_power_status` | [PASS](evidence/2026-11-13-windows-godot/test-028.log) | PASS |
| 29 | `tests.test_c07_power_status_live.C07PowerStatusLiveTests.test_reference_graph_and_actual_c07_power_status_live` | [PASS](evidence/2026-11-13-windows-godot/test-029.log) | Not rerun |
| 30 | `tests.test_c07_reconstructor_construct_time.C07ReconstructorConstructTimeTests.test_reference_graph_and_actual_c07_reconstructor_construct_time` | [PASS](evidence/2026-11-13-windows-godot/test-030.log) | Not rerun |
| 31 | `tests.test_c07_unit_group_counts.C07UnitGroupCountsTests.test_reference_graph_and_actual_c07_unit_group_counts` | [PASS](evidence/2026-11-13-windows-godot/test-031.log) | Not rerun |
| 32 | `tests.test_c07_units_can_create.C07UnitsCanCreateTests.test_reference_graph_and_actual_c07_units_can_create` | [PASS](evidence/2026-11-13-windows-godot/test-032.log) | Not rerun |
| 33 | `tests.test_conduit_update_binding.ConduitUpdateBindingTests.test_reference_graph_and_actual_conduit_update` | [PASS](evidence/2026-11-13-windows-godot/test-033.log) | Not rerun |
| 34 | `tests.test_consume_liquid_generated_delegate.ConsumeLiquidGeneratedDelegateTests.test_consume_liquid_golden_runtime_and_building_composition` | [PASS](evidence/2026-11-13-windows-godot/test-034.log) | Not rerun |
| 35 | `tests.test_consumer_cache_invalidation.ConsumerCacheInvalidationBindingTests.test_reference_graph_and_actual_consumer_cache_invalidation` | [PASS](evidence/2026-11-13-windows-godot/test-035.log) | Not rerun |
| 36 | `tests.test_continuous_liquid_turret_ammo_registry.ContinuousLiquidTurretAmmoRegistryTests.test_reference_graph_and_actual_continuous_liquid_turret_ammo_registry` | [PASS](evidence/2026-11-13-windows-godot/test-036.log) | Not rerun |
| 37 | `tests.test_continuous_liquid_turret_consumer_binding.ContinuousLiquidTurretConsumerBindingTests.test_reference_graph_and_actual_continuous_liquid_turret_consumer_binding` | [PASS](evidence/2026-11-13-windows-godot/test-037.log) | Not rerun |
| 38 | `tests.test_continuous_liquid_turret_cost_multiplier.ContinuousLiquidTurretCostMultiplierTests.test_reference_graph_and_actual_continuous_liquid_turret_cost_multiplier` | [PASS](evidence/2026-11-13-windows-godot/test-038.log) | Not rerun |
| 39 | `tests.test_continuous_liquid_turret_live_loop.ContinuousLiquidTurretLiveLoopTests.test_reference_graph_and_actual_continuous_liquid_turret_live_loop` | [PASS](evidence/2026-11-13-windows-godot/test-039.log) | Not rerun |
| 40 | `tests.test_continuous_liquid_turret_registry_ammo_tick.ContinuousLiquidTurretRegistryAmmoTickTests.test_reference_graph_and_actual_continuous_liquid_turret_registry_ammo_tick` | [PASS](evidence/2026-11-13-windows-godot/test-040.log) | Not rerun |
| 41 | `tests.test_continuous_liquid_turret_tick_frame.ContinuousLiquidTurretTickFrameTests.test_reference_graph_and_actual_continuous_liquid_turret_tick_frame` | [PASS](evidence/2026-11-13-windows-godot/test-041.log) | Not rerun |
| 42 | `tests.test_conveyor_advance_binding.ConveyorAdvanceBindingTests.test_reference_graph_and_actual_conveyor_advance` | [PASS](evidence/2026-11-13-windows-godot/test-042.log) | Not rerun |
| 43 | `tests.test_conveyor_draw_positions_binding.ConveyorDrawPositionsBindingTests.test_reference_graph_and_actual_conveyor_draw_positions` | [PASS](evidence/2026-11-13-windows-godot/test-043.log) | Not rerun |
| 44 | `tests.test_conveyor_intake_binding.ConveyorIntakeBindingTests.test_reference_graph_and_actual_conveyor_intake` | [PASS](evidence/2026-11-13-windows-godot/test-044.log) | Not rerun |
| 45 | `tests.test_conveyor_queue_binding.ConveyorQueueBindingTests.test_reference_graph_and_actual_conveyor_queue` | [PASS](evidence/2026-11-13-windows-godot/test-045.log) | Not rerun |
| 46 | `tests.test_conveyor_queue_storage_binding.ConveyorQueueStorageBindingTests.test_reference_graph_and_actual_conveyor_queue_storage` | [PASS](evidence/2026-11-13-windows-godot/test-046.log) | Not rerun |
| 47 | `tests.test_conveyor_stack_binding.ConveyorStackBindingTests.test_reference_graph_and_actual_conveyor_stack` | [PASS](evidence/2026-11-13-windows-godot/test-047.log) | Not rerun |
| 48 | `tests.test_cost_multiplier_for_block_binding.CostMultiplierForBlockBindingTests.test_reference_graph_and_actual_cost_multiplier_for_block` | [PASS](evidence/2026-11-13-windows-godot/test-048.log) | Not rerun |
| 49 | `tests.test_drill_booster_binding.DrillBoosterBindingTests.test_reference_graph_and_actual_drill_booster` | [PASS](evidence/2026-11-13-windows-godot/test-049.log) | Not rerun |
| 50 | `tests.test_drill_bridge_dominant_binding.DrillBridgeDominantBindingTests.test_reference_graph_and_actual_drill_bridge_dominant` | [PASS](evidence/2026-11-13-windows-godot/test-050.log) | Not rerun |
| 51 | `tests.test_drill_conveyor_dump_binding.DrillConveyorDumpBindingTests.test_reference_graph_and_actual_drill_conveyor_dump` | [PASS](evidence/2026-11-13-windows-godot/test-051.log) | Not rerun |
| 52 | `tests.test_drill_dump_step_binding.DrillDumpStepBindingTests.test_reference_graph_and_actual_drill_dump_step` | [PASS](evidence/2026-11-13-windows-godot/test-052.log) | Not rerun |
| 53 | `tests.test_drill_live_consumption.DrillLiveConsumptionTests.test_real_process_drives_two_multicell_drills_and_concrete_adapter` | [PASS](evidence/2026-11-13-windows-godot/test-053.log) | Not rerun |
| 54 | `tests.test_drill_ore_binding.DrillOreBindingTests.test_real_catalog_drill_binding_in_godot` | [PASS](evidence/2026-11-13-windows-godot/test-054.log) | Not rerun |
| 55 | `tests.test_drill_ore_selection.DrillOreSelectionTests.test_independent_ore_selection_matrix_in_godot` | [PASS](evidence/2026-11-13-windows-godot/test-055.log) | Not rerun |
| 56 | `tests.test_drill_per_drill_dump_binding.DrillPerDrillDumpBindingTests.test_reference_graph_and_actual_drill_per_drill_dump` | [PASS](evidence/2026-11-13-windows-godot/test-056.log) | Not rerun |
| 57 | `tests.test_drill_proximity_lifecycle.DrillProximityLifecycleTests.test_actual_proximity_mutation_and_dominant_production` | [PASS](evidence/2026-11-13-windows-godot/test-057.log) | Not rerun |
| 58 | `tests.test_factory_consumer_binding.FactoryConsumerBindingTests.test_reference_graph_and_actual_factory_consumer_binding` | [FAIL](evidence/2026-11-13-windows-godot/test-058.log) | PASS |
| 59 | `tests.test_factory_craft.FactoryCraftTests.test_reference_graph_and_actual_c06_factory_craft_gate` | [FAIL](evidence/2026-11-13-windows-godot/test-059.log) | PASS |
| 60 | `tests.test_factory_dump_outputs.FactoryDumpOutputsTests.test_reference_graph_and_actual_c06_factory_dump_outputs_gate` | [FAIL](evidence/2026-11-13-windows-godot/test-060.log) | PASS |
| 61 | `tests.test_factory_dump_swap_binding.FactoryDumpSwapBindingTests.test_reference_graph_and_actual_factory_dump_swap` | [PASS](evidence/2026-11-13-windows-godot/test-061.log) | Not rerun |
| 62 | `tests.test_factory_liquid_output.FactoryLiquidOutputTests.test_reference_graph_and_actual_c06_factory_liquid_output_gate` | [FAIL](evidence/2026-11-13-windows-godot/test-062.log) | PASS |
| 63 | `tests.test_factory_live_loop.FactoryLiveLoopTests.test_reference_graph_and_actual_factory_live_loop` | [PASS](evidence/2026-11-13-windows-godot/test-063.log) | Not rerun |
| 64 | `tests.test_factory_should_consume.FactoryShouldConsumeTests.test_reference_graph_and_actual_factory_should_consume` | [PASS](evidence/2026-11-13-windows-godot/test-064.log) | PASS |
| 65 | `tests.test_factory_update_consumption.FactoryUpdateConsumptionTests.test_reference_graph_and_actual_factory_update_consumption` | [PASS](evidence/2026-11-13-windows-godot/test-065.log) | Not rerun |
| 66 | `tests.test_game_rules_state_binding.GameRulesStateBindingTests.test_reference_graph_and_actual_game_rules_state` | [PASS](evidence/2026-11-13-windows-godot/test-066.log) | Not rerun |
| 67 | `tests.test_lancer_placement_binding.LancerPlacementBindingTests.test_reference_graph_and_actual_lancer_placement` | [PASS](evidence/2026-11-13-windows-godot/test-067.log) | Not rerun |
| 68 | `tests.test_liquid_consumer_apply_hydration.LiquidConsumerApplyHydrationTests.test_live_partial_apply_filter_cache_and_real_placement` | [PASS](evidence/2026-11-13-windows-godot/test-068.log) | Not rerun |
| 69 | `tests.test_liquid_consumer_hydration.LiquidConsumerHydrationTests.test_live_block_shared_consumers_and_optional_efficiency_runtime` | [PASS](evidence/2026-11-13-windows-godot/test-069.log) | Not rerun |
| 70 | `tests.test_liquid_module_lifecycle.LiquidModuleLifecycleTests.test_lifecycle_golden_runtime_and_initialized_consumption` | [PASS](evidence/2026-11-13-windows-godot/test-070.log) | Not rerun |
| 71 | `tests.test_liquid_module_storage.LiquidModuleStorageTests.test_storage_golden_runtime_and_consumption_mutation` | [PASS](evidence/2026-11-13-windows-godot/test-071.log) | Not rerun |
| 72 | `tests.test_loadout_place_binding.LoadoutPlaceBindingTests.test_reference_graph_and_actual_loadout_place` | [PASS](evidence/2026-11-13-windows-godot/test-072.log) | Not rerun |
| 73 | `tests.test_mechanical_pump_placement_binding.MechanicalPumpPlacementBindingTests.test_reference_graph_and_actual_mechanical_pump_placement` | [PASS](evidence/2026-11-13-windows-godot/test-073.log) | Not rerun |
| 74 | `tests.test_no_sleep_wake_binding.NoSleepWakeBindingTests.test_reference_graph_and_actual_no_sleep_wake` | [PASS](evidence/2026-11-13-windows-godot/test-074.log) | Not rerun |
| 75 | `tests.test_placed_liquid_ownership.PlacedLiquidOwnershipTests.test_live_building_storage_and_typed_catalog_runtime` | [PASS](evidence/2026-11-13-windows-godot/test-075.log) | Not rerun |
| 76 | `tests.test_placed_power_graph_grouping_binding.PlacedPowerGraphGroupingBindingTests.test_reference_graph_and_actual_placed_power_graph_grouping` | [PASS](evidence/2026-11-13-windows-godot/test-076.log) | Not rerun |
| 77 | `tests.test_placed_tile_set_block_binding.PlacedTileSetBlockBindingTests.test_reference_graph_and_actual_placed_tile_set_block` | [PASS](evidence/2026-11-13-windows-godot/test-077.log) | Not rerun |
| 78 | `tests.test_power_graph_consumer_cheating.PowerGraphConsumerCheatingTests.test_reference_graph_and_actual_power_graph_consumer_cheating` | [PASS](evidence/2026-11-13-windows-godot/test-078.log) | Not rerun |
| 79 | `tests.test_power_graph_live_update_binding.PowerGraphLiveUpdateBindingTests.test_reference_graph_and_actual_power_graph_live_update` | [PASS](evidence/2026-11-13-windows-godot/test-079.log) | Not rerun |
| 80 | `tests.test_pump_dump_liquid_binding.PumpDumpLiquidBindingTests.test_reference_graph_and_actual_pump_dump_liquid` | [PASS](evidence/2026-11-13-windows-godot/test-080.log) | Not rerun |
| 81 | `tests.test_pump_proximity_binding.PumpProximityBindingTests.test_reference_graph_and_actual_pump_proximity` | [PASS](evidence/2026-11-13-windows-godot/test-081.log) | Not rerun |
| 82 | `tests.test_pump_update_binding.PumpUpdateBindingTests.test_reference_graph_and_actual_pump_update` | [PASS](evidence/2026-11-13-windows-godot/test-082.log) | Not rerun |
| 83 | `tests.test_rules_unit_cost_binding.RulesUnitCostBindingTests.test_reference_graph_and_actual_rules_unit_cost` | [PASS](evidence/2026-11-13-windows-godot/test-083.log) | Not rerun |
| 84 | `tests.test_schematic_place_binding.SchematicPlaceBindingTests.test_reference_graph_and_actual_schematic_place` | [PASS](evidence/2026-11-13-windows-godot/test-084.log) | Not rerun |
| 85 | `tests.test_solar_panel_placement_binding.SolarPanelPlacementBindingTests.test_reference_graph_and_actual_solar_panel_placement` | [PASS](evidence/2026-11-13-windows-godot/test-085.log) | Not rerun |
| 86 | `tests.test_team_cheating_state.TeamCheatingStateBindingTests.test_reference_graph_and_actual_team_cheating_state` | [PASS](evidence/2026-11-13-windows-godot/test-086.log) | Not rerun |
| 87 | `tests.test_teams_core_registration_binding.TeamsCoreRegistrationBindingTests.test_reference_graph_and_actual_teams_core_registration` | [PASS](evidence/2026-11-13-windows-godot/test-087.log) | Not rerun |
| 88 | `tests.test_terrain_mutation_lifecycle.TerrainMutationLifecycleTests.test_live_terrain_notifications_and_ordered_mutations` | [PASS](evidence/2026-11-13-windows-godot/test-088.log) | Not rerun |
| 89 | `tests.test_tile_change_build_set_block.TileChangeBuildSetBlockTests.test_reference_graph_and_actual_tile_set_block` | [PASS](evidence/2026-11-13-windows-godot/test-089.log) | Not rerun |
| 90 | `tests.test_tile_ore_provider.TileOreProviderTests.test_actual_tile_and_linked_provider_in_godot` | [PASS](evidence/2026-11-13-windows-godot/test-090.log) | Not rerun |
| 91 | `tests.test_tile_ore_provider.TileOreProviderTests.test_missing_tile_metadata_is_rejected` | [PASS](evidence/2026-11-13-windows-godot/test-091.log) | Not rerun |
| 92 | `tests.test_turret_live_loop.TurretLiveLoopTests.test_reference_graph_and_actual_turret_live_loop` | [PASS](evidence/2026-11-13-windows-godot/test-092.log) | Not rerun |
| 93 | `tests.test_two_drill_gate_binding.TwoDrillGateBindingTests.test_reference_graph_and_actual_two_drill_gate` | [PASS](evidence/2026-11-13-windows-godot/test-093.log) | Not rerun |
| 94 | `tests.test_unit_factory_consumer_binding.UnitFactoryConsumerBindingTests.test_reference_graph_and_actual_unit_factory_consumer_binding` | [FAIL](evidence/2026-11-13-windows-godot/test-094.log) | PASS |
| 95 | `tests.test_unit_factory_live_loop.UnitFactoryLiveLoopTests.test_reference_graph_and_actual_unit_factory_live_loop` | [PASS](evidence/2026-11-13-windows-godot/test-095.log) | Not rerun |
| 96 | `tests.test_unit_factory_should_consume.UnitFactoryShouldConsumeTests.test_reference_graph_and_actual_unit_factory_should_consume` | [PASS](evidence/2026-11-13-windows-godot/test-096.log) | PASS |
| 97 | `tests.test_valid_place_binding.ValidPlaceBindingTests.test_reference_graph_and_actual_valid_place` | [PASS](evidence/2026-11-13-windows-godot/test-097.log) | Not rerun |
| 98 | `tests.test_water_region_binding.WaterRegionBindingTests.test_reference_graph_and_actual_water_region` | [PASS](evidence/2026-11-13-windows-godot/test-098.log) | Not rerun |
| 99 | `tests.test_world_tile_lifecycle.WorldTileLifecycleTests.test_actual_world_bootstrap_and_placement` | [PASS](evidence/2026-11-13-windows-godot/test-099.log) | Not rerun |
| 100 | `tests.test_world_tile_lifecycle.WorldTileLifecycleTests.test_unknown_map_content_rejected` | [PASS](evidence/2026-11-13-windows-godot/test-100.log) | Not rerun |
| 101 | `tests.test_world_tile_lifecycle.WorldTileLifecycleTests.test_incomplete_map_terrain_rejected` | [PASS](evidence/2026-11-13-windows-godot/test-101.log) | Not rerun |

## Limits

- The complete 5,677-test Python gate was not rerun. The unchanged baseline passes plus affected/neighbor reruns provide cumulative coverage; do not advertise this as a full-suite green result.
- No production code changed, so SSOT/checklist slice totals are unchanged. Passing proofs validate their assertions, not full gameplay or release readiness.
- Publication is a branch/PR for review; main is not merged by this task.
