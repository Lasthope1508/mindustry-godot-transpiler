# Windows Godot validation — 2026-11-27

User requested missing Windows proof coverage on latest repository state, including Linux-only coverage. Latest main reviewed: `6ac2bad528014a38f194328f74c72b0b3c21841a`. Each result below retains its actual tested SHA; the checkout was not updated while a batch was active.

658 final recorded scene results across 643 distinct scenes: **652 PASS, 6 RED**. These totals count final rows per namespace; retained RED/retry captures are additional attempts, not separately counted in the table. 46 additional scenes reuse credible passing Windows evidence with unchanged direct proof/dependency files. Scene identity and implementation evidence determine coverage; slice numbers alone do not. This is targeted/native validation, not a full suite, C01–C12 completion, or release-readiness claim.

| Run | Starting base | Executions | PASS | Native only |
| --- | --- | ---: | ---: | ---: |
| windows-20261127 | `375736358640ef3d2e8db58bae4032be3e199b75` | 368 | 368 | 0 |
| windows-20261127-latest | `5dd2907ce1569da48eb1d59f326996b536256dc2` | 10 | 10 | 0 |
| windows-20261127-other | `5dd2907ce1569da48eb1d59f326996b536256dc2` | 269 | 263 | 56 |
| windows-20261127-delta2 | `e146d4af37647e23df89e109ddaa300c85674b79` | 6 | 6 | 0 |
| windows-20261127-delta3 | `5c67738e6cb51c242c35bcc59812f4228c183dc8` | 5 | 5 | 0 |

## Evidence and method

- Windows engine: 4.6.2.stable.official.71f334935. All scenes used the actual Windows Godot executable. The MCP launcher on this host uses `--headless -d`; runtime console results are Windows engine evidence. Self-terminating scenes used a directly captured graphical process without `--headless` because MCP discards logs once that process exits. Transport is labelled per result; graphical coverage is not claimed for every scene. Native process command/exit/stdout/stderr are retained. Existing targeted modules additionally ran their own headless subprocesses.
- TCP7777 was checked before targeted suites/native launches; execution was sequential and only owned projects/processes were stopped. Debug warnings are retained and counted separately. PASS requires fresh native `matches=true` (or an exact validated diagnostic payload for the five scenes below), error-free runtime/parser output, and passing existing targeted tests where available. C07 boolean assertions are additionally checked individually, excluding the metadata string `module`. A native-only scene has no existing module directly referencing it and is labelled explicitly.
- Seven initial targeted suites failed because this fresh worktree lacked upstream Java directories. Existing pinned Mindustry/Arc directories were made accessible through junctions, then those suites reran successfully. Original ENV-RED logs are retained. Mindustry pin: `2bdedfed25932ebf11330d3584092c50e2e26d96`.
- A later drill-ore targeted import required repo-pinned javalang==0.13.0; installed it and reran successfully. The math source-text module consists of three pytest functions; unittest correctly reported zero tests, so pytest collected and passed all three. Original failures and corrected framework logs are retained. No zero-test run counts as PASS.
- Collector incidents are documented: MCP lost a quick-exit SoundControl log; graphical capture replaced it. The recorder initially treated GameHeadless's `module` metadata string as an assertion; its original classification is retained and was corrected against the unchanged scene and raw passing proof. No game/proof assertions were changed.
- Five older module scenes (ContentRegistry, CoreDamage, GameConfig, NodeBinding, SsotAccessor) emit diagnostic fields without an aggregate `matches` key. Original automatic non-pass classifications are retained. External validation compares each entire raw payload against committed registry/config/default counts, core damage clamping/accumulation and all existing boolean checks. No payload or fixture assertion was changed; the evaluator and source blob identities are retained.
- Five full-Main C06 captures initially stopped before the proof was ready (42-second collector observation versus approximately 53–56-second existing targeted runs). Original incomplete captures are retained; native-only collection reran with a longer observation window. No scene/test timeout or assertion was changed.
- Passing shared targeted modules are reused only for identical tracked runtime/test/fixture content, with explicit source-log references in status JSON. The same working-tree content before/after fixture commit was verified by byte-identical commit diff; context alias evidence is included. This avoids rerunning the large shared test_playable module for each scene. Every selected scene still has its own fresh native result.
- Six selected fixture setup/cleanup repairs in `837765f37b0800532182a7ed81ebfc0a3535ae09` and `e146d4af37647e23df89e109ddaa300c85674b79` add only thirteen lines: free five owned PortGame nodes in BuildingItemDumpStateModuleProof; clear callback event cycles in BuildingUnitPayloadModuleProof; give FakeLoopGame the production paused=false field; free the owned node-binding game; free two unattached texture sprites; free UnitComp's owned game. Initial RED captures remain; emitted proof payloads are identical before/after repairs, all assertions are unchanged, and selected/neighbor targeted/native reruns pass. Repair content was checked against the committed diff; shared module evidence reused only for byte-identical content.
- Gameplay, SSOT, ledger and PortGame were not edited. Import/UID/project noise and dependency junctions are excluded. Historical wave36's 15 RED entries remain scoped to their integration implementation; this main run does not silently close them.

## Graphical inspection through runtime MCP

The real editor was opened through MCP and the separately owned graphical Main process used OpenGL/NVIDIA RTX 3050 without `--headless`. Runtime addon commands captured the viewport and tree. Campaign shell and sample HUD/building/unit sprites render visibly ([campaign shell](evidence/2026-11-27-windows/windows-main.png), [sample playable viewport](evidence/2026-11-27-windows/windows-playable.png)). Selecting Biomass Facility and entering the playable slice changes the launch context/UI but leaves the original stone-floor and copper batches; this image does not prove campaign terrain. The dedicated terrain proof below remains authoritative. Graphical stderr was empty during inspection. See the graphics inspection note for commands and limitations.

## Pending implementation details

CampaignMapTerrainRuntimeProof preserves its original two failed render-node assertions: expected 16 batch nodes, observed 0. Diagnostic evidence found all 16 terrain/ore texture keys missing from the game's loaded texture map (12 floor keys and 4 ore keys). SourceTextureRuntimeState.add_source_tile_batch returns null for absent textures, while the data plan still reports 16 batches. This requires runtime/texture-catalog implementation work outside validation scope; no gameplay/config fix or assertion weakening was made. Temporary diagnostic printing was removed from the fixture. Other unresolved results, if any, remain in pending.json. No overall GREEN claim is made while RED remains.

Other retained RED results are scoped explicitly: FactoryRuntimeModuleProof uses an outdated fake lacking the current live API; GeneratedClassPathHeadquarterProof fixes an expected count of 53 against runtime 54 (no assertion edited); PlacedBlockStateModuleProof has three time-scale/traversal failures; UnitFactoryConsumerBindingProof reproduces the documented efficiency/cyanogen baseline failure in both Python and native engine; WorldInitialBuildRuntimeStateModuleProof fails plan/block-count/role/key expectations. These require owner review beyond minimal fixture setup/cleanup. They are not labelled as missing-engine failures or passing work.

Evidence: `results.json` records source blobs, actual SHA, warnings/errors, targeted status and capture type. `pending.json` retains unresolved results. `inventory.json` records accepted prior Windows evidence and batch snapshots. `engine-evidence.zip` contains raw native/targeted logs, inventories and original environmental/collector failures, with namespaced entries checked against `manifest.sha256`.

## Results

| Scene | Actual SHA | Result | Targeted exit |
| --- | --- | --- | --- |
| `C07WeaponDrawOutlineProof` | `375736358` | PASS | 0 |
| `C07UnitTypeWeaponsDpsSumProof` | `375736358` | PASS | 0 |
| `C07WeaponShotsPerSecProof` | `375736358` | PASS | 0 |
| `C07WeaponDpsProof` | `375736358` | PASS | 0 |
| `C07UnitTypeEstimateDpsProof` | `375736358` | PASS | 0 |
| `C07BulletTypeEstimateDpsProof` | `375736358` | PASS | 0 |
| `C07TurretRangeProof` | `375736358` | PASS | 0 |
| `C07TurretCoolingProof` | `375736358` | PASS | 0 |
| `C07TurretControlledStampProof` | `375736358` | PASS | 0 |
| `C07TurretPowerGraphLastValuesStampProof` | `375736358` | PASS | 0 |
| `C07TurretAmmoItemsStampProof` | `375736358` | PASS | 0 |
| `C07TurretSenseFrameStampProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSenseWiringProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSenseCameraProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSensePowerNetCapacityProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSensePowerNetStoredProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSensePowerNetOutProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSensePowerNetInProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSenseTotalItemsProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSenseHealthProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSenseDeadProof` | `375736358` | PASS | 0 |
| `C07TurretLogicSenseLAccessProof` | `375736358` | PASS | 0 |
| `C07TurretLogicSenseSizeProof` | `375736358` | PASS | 0 |
| `C07WeaponInitProof` | `375736358` | PASS | 0 |
| `C07WeaponSideFlipDefaultsProof` | `375736358` | PASS | 0 |
| `C07WeaponCooldownTimeDefaultProof` | `375736358` | PASS | 0 |
| `C07WeaponUpdateAimProof` | `375736358` | PASS | 0 |
| `C07WeaponUpdateDecayProof` | `375736358` | PASS | 0 |
| `C07WeaponRangeProof` | `375736358` | PASS | 0 |
| `C07WeaponDrawProof` | `375736358` | PASS | 0 |
| `C07TurretLogicSenseContentProof` | `375736358` | PASS | 0 |
| `C07TurretLogicSenseDispatchProof` | `375736358` | PASS | 0 |
| `C07TurretSenseObjectProof` | `375736358` | PASS | 0 |
| `C07GameStateHasSectorProof` | `375736358` | PASS | 0 |
| `C07BuildTurretWarmupProof` | `375736358` | PASS | 0 |
| `C07ReloadTurretAmmoReloadMultiplierProof` | `375736358` | PASS | 0 |
| `C07BuildTurretCanControlProof` | `375736358` | PASS | 0 |
| `C07BaseTurretBuildRotationProof` | `375736358` | PASS | 0 |
| `C07BeamDrillGetDrillTimeProof` | `375736358` | PASS | 0 |
| `C07BuildTurretBuildRotationProof` | `375736358` | PASS | 0 |
| `C07ReloadTurretBaseReloadSpeedProof` | `375736358` | PASS | 0 |
| `C07BaseTurretStatusProof` | `375736358` | PASS | 0 |
| `C07GameStateIsCampaignProof` | `375736358` | PASS | 0 |
| `C07ReloadTurretCanReloadProof` | `375736358` | PASS | 0 |
| `C07RulesBuildSpeedProof` | `375736358` | PASS | 0 |
| `C07RulesBlockDamageProof` | `375736358` | PASS | 0 |
| `C07RulesBlockHealthProof` | `375736358` | PASS | 0 |
| `C07RulesIsBannedUnitProof` | `375736358` | PASS | 0 |
| `C07RulesUnitMineSpeedProof` | `375736358` | PASS | 0 |
| `C07RulesHasEnvProof` | `375736358` | PASS | 0 |
| `C07RulesUnitActivationDelayProof` | `375736358` | PASS | 0 |
| `C07RulesIsBannedProof` | `375736358` | PASS | 0 |
| `C07RulesUnitBuildSpeedProof` | `375736358` | PASS | 0 |
| `C07TeamCompareToProof` | `375736358` | PASS | 0 |
| `C07RulesUnitDamageProof` | `375736358` | PASS | 0 |
| `C07RulesBuildRadiusProof` | `375736358` | PASS | 0 |
| `C07GameStatsProof` | `375736358` | PASS | 0 |
| `C07RulesUnitHealthProof` | `375736358` | PASS | 0 |
| `C07RulesModeProof` | `375736358` | PASS | 0 |
| `C07SpawnGroupEqualsProof` | `375736358` | PASS | 0 |
| `C07TeamGetProof` | `375736358` | PASS | 0 |
| `C07WaveSpawnerGetFirstSpawnProof` | `375736358` | PASS | 0 |
| `C07RadarDrawPlaceProof` | `375736358` | PASS | 0 |
| `C07DrillDrawSelectProof` | `375736358` | PASS | 0 |
| `C07TurretMinRangeProof` | `375736358` | PASS | 0 |
| `C07RadarDrawSelectProof` | `375736358` | PASS | 0 |
| `C07DrillSetStatsProof` | `375736358` | PASS | 0 |
| `C07RadarDrawProof` | `375736358` | PASS | 0 |
| `C07DrillAmbientVolumeProof` | `375736358` | PASS | 0 |
| `C07TurretWriteReadProof` | `375736358` | PASS | 0 |
| `C07RadarFogRadiusProof` | `375736358` | PASS | 0 |
| `C07RadarUpdateTileProof` | `375736358` | PASS | 0 |
| `C07TurretTrackingRangeProof` | `375736358` | PASS | 0 |
| `C07RadarCanPickupProof` | `375736358` | PASS | 0 |
| `C07BurstDrillAmbientVolumeProof` | `375736358` | PASS | 0 |
| `C07TurretFindTargetProof` | `375736358` | PASS | 0 |
| `C07SoundControlIsDarkProof` | `375736358` | PASS | 0 |
| `C07BurstDrillDrawProof` | `375736358` | PASS | 0 |
| `C07TurretHasAmmoProof` | `375736358` | PASS | 0 |
| `C07BurstDrillIconsProof` | `375736358` | PASS | 0 |
| `C07TurretFogRadiusProof` | `375736358` | PASS | 0 |
| `C07RadarWriteReadProof` | `375736358` | PASS | 0 |
| `C07BurstDrillSetStatsProof` | `375736358` | PASS | 0 |
| `C07TurretUpdateTileWarmupProof` | `375736358` | PASS | 0 |
| `C07TurretUnitProof` | `375736358` | PASS | 0 |
| `C07SoundControlAlwaysPlayMusicProof` | `375736358` | PASS | 0 |
| `C07DrillShouldAmbientSoundProof` | `375736358` | PASS | 0 |
| `C07RadarProgressProof` | `375736358` | PASS | 0 |
| `C07BurstDrillOnProximityUpdateProof` | `375736358` | PASS | 0 |
| `C07TurretEstimateDpsProof` | `375736358` | PASS | 0 |
| `C07SoundControlShouldPlayProof` | `375736358` | PASS | 0 |
| `C07DrillSenseProof` | `375736358` | PASS | 0 |
| `C07TurretMicroAccessorsProof` | `375736358` | PASS | 0 |
| `C07BurstDrillLiquidRowsProof` | `375736358` | PASS | 0 |
| `C07BurstDrillShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07GameHeadlessProof` | `375736358` | PASS | 0 |
| `C07BurstDrillUpdateTileProof` | `375736358` | PASS | 0 |
| `C07TurretShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07RepairTurretDrawBeamPulseProof` | `375736358` | PASS | 0 |
| `C07RepairTurretDrawBeamJitterProof` | `375736358` | PASS | 0 |
| `C07RadarIconsProof` | `375736358` | PASS | 0 |
| `C07SoundControlLoopProof` | `375736358` | PASS | 0 |
| `C07BurstDrillWriteReadProof` | `375736358` | PASS | 0 |
| `C07TurretStatusProof` | `375736358` | PASS | 0 |
| `C07BuildingCompSenseProof` | `375736358` | PASS | 0 |
| `C07TurretSenseProof` | `375736358` | PASS | 0 |
| `C07TurretProgressProof` | `375736358` | PASS | 0 |
| `C07TurretIsActiveProof` | `375736358` | PASS | 0 |
| `C07TurretActivationTimerProof` | `375736358` | PASS | 0 |
| `C07TurretIsShootingProof` | `375736358` | PASS | 0 |
| `C07TurretUnitHealthProof` | `375736358` | PASS | 0 |
| `C07TurretUnitMaxHealthProof` | `375736358` | PASS | 0 |
| `C07TurretUnitWorldPositionProof` | `375736358` | PASS | 0 |
| `C07TurretChargeEffectProof` | `375736358` | PASS | 0 |
| `C07TurretCanConsumeHeatGateProof` | `375736358` | PASS | 0 |
| `C07TurretChargeStateProof` | `375736358` | PASS | 0 |
| `C07TurretPowerHeatFoldProof` | `375736358` | PASS | 0 |
| `C07TurretQueuedBulletsProof` | `375736358` | PASS | 0 |
| `C07TurretConfiguredDispatchProof` | `375736358` | PASS | 0 |
| `C07TurretSuperControlProof` | `375736358` | PASS | 0 |
| `C07TurretTargetPositionControlProof` | `375736358` | PASS | 0 |
| `C07TurretEfficiencyMultiplierProof` | `375736358` | PASS | 0 |
| `C07TurretControlProof` | `375736358` | PASS | 0 |
| `C07TurretHeatReqProof` | `375736358` | PASS | 0 |
| `C07TurretRotateSyncProof` | `375736358` | PASS | 0 |
| `C07TurretLogicControlTimeProof` | `375736358` | PASS | 0 |
| `C07TurretUnitSyncProof` | `375736358` | PASS | 0 |
| `C07TurretChargeProof` | `375736358` | PASS | 0 |
| `C07TurretRecoilOffsetProof` | `375736358` | PASS | 0 |
| `C07TurretMultiRecoilStampProof` | `375736358` | PASS | 0 |
| `C07TurretMultiRecoilProof` | `375736358` | PASS | 0 |
| `C07TurretShootStampProof` | `375736358` | PASS | 0 |
| `C07TurretRecoilHeatProof` | `375736358` | PASS | 0 |
| `C07ItemTurretBulletSpawnProof` | `375736358` | PASS | 0 |
| `C07ItemTurretValidateTargetProof` | `375736358` | PASS | 0 |
| `C07ItemTurretAimShootProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretPersistenceIntegrationProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretCoolantProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretHitSizeRemovalProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretSetStatsIconsProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretWriteReadProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretDrawProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretSpawnTeamStampProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretLiveBulletsWiringProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretShouldConsumeCoolantProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretAimShootProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretTargetAcquireProof` | `375736358` | PASS | 0 |
| `C07RepairTowerPerDefStatsProof` | `375736358` | PASS | 0 |
| `C07RepairTurretPerDefStatsProof` | `375736358` | PASS | 0 |
| `C07RepairTurretBindBlockIdProof` | `375736358` | PASS | 0 |
| `C07RepairTurretAmbientSoundVolumeProof` | `375736358` | PASS | 0 |
| `C07RepairTurretSenseObjectProof` | `375736358` | PASS | 0 |
| `C07RepairTurretRangeBuildRotationProof` | `375736358` | PASS | 0 |
| `C07RepairTowerDrawProof` | `375736358` | PASS | 0 |
| `C07RepairTowerDrawSelectPlaceProof` | `375736358` | PASS | 0 |
| `C07RepairTowerSetStatsProof` | `375736358` | PASS | 0 |
| `C07RepairTowerOzoneConsumeProof` | `375736358` | PASS | 0 |
| `C07RepairTowerHealAdvanceProof` | `375736358` | PASS | 0 |
| `C07RepairTurretIconsProof` | `375736358` | PASS | 0 |
| `C07RepairTurretInitProof` | `375736358` | PASS | 0 |
| `C07RepairTurretDrawProof` | `375736358` | PASS | 0 |
| `C07RepairTurretSetStatsProof` | `375736358` | PASS | 0 |
| `C07RepairTurretSenseRangeRotationProof` | `375736358` | PASS | 0 |
| `C07RepairTurretAmbientSoundLoopProof` | `375736358` | PASS | 0 |
| `C07RepairTurretShouldAmbientSoundStatusProof` | `375736358` | PASS | 0 |
| `C07RepairTurretDrawSelectPlaceProof` | `375736358` | PASS | 0 |
| `C07RepairTurretDrawBeamProof` | `375736358` | PASS | 0 |
| `C07AcceleratorBatteryProof` | `375736358` | PASS | 0 |
| `C07RepairTurretReadWriteProof` | `375736358` | PASS | 0 |
| `C07ImpactReactorImpactPowerProof` | `375736358` | PASS | 0 |
| `C07RepairTurretStrengthLerpProof` | `375736358` | PASS | 0 |
| `C07RepairTurretRotationSlerpProof` | `375736358` | PASS | 0 |
| `C07RepairTurretHealAdvanceProof` | `375736358` | PASS | 0 |
| `C07RepairTurretTargetAcquireProof` | `375736358` | PASS | 0 |
| `C07RepairTowerNearbyDriverProof` | `375736358` | PASS | 0 |
| `C07UnitsNearbyProof` | `375736358` | PASS | 0 |
| `C07RepairTurretCoolantProof` | `375736358` | PASS | 0 |
| `C07MassDriverSenseProgressAcceptItemProof` | `375736358` | PASS | 0 |
| `C07LaunchPadUpdateTileProof` | `375736358` | PASS | 0 |
| `C07LaunchPadSenseProgressProof` | `375736358` | PASS | 0 |
| `C07LaunchPadShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07ShieldWallUpdateTileProof` | `375736358` | PASS | 0 |
| `C07ShieldWallDamageProof` | `375736358` | PASS | 0 |
| `C07ShieldWallBrokenProof` | `375736358` | PASS | 0 |
| `C07BuildTurretShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerTimerCadenceProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerUseEventProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerHitEffectProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerFireEffectsProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerWaveDamageProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerBulletScanProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerFireProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerChargeProof` | `375736358` | PASS | 0 |
| `C07RepairTowerShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07RepairTowerTargetRefreshProof` | `375736358` | PASS | 0 |
| `C07RepairTurretShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07ImpactReactorConsumeProof` | `375736358` | PASS | 0 |
| `C07ImpactReactorPowerProductionProof` | `375736358` | PASS | 0 |
| `C07LightBlockPowerStatusProof` | `375736358` | PASS | 0 |
| `C07BuildTurretPowerStatusProof` | `375736358` | PASS | 0 |
| `C07AcceleratorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07ImpactReactorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07StackRouterPowerStatusProof` | `375736358` | PASS | 0 |
| `C07StackConveyorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07LiquidBridgePowerStatusProof` | `375736358` | PASS | 0 |
| `C07ItemBridgePowerStatusProof` | `375736358` | PASS | 0 |
| `C07ShockwaveTowerPowerStatusProof` | `375736358` | PASS | 0 |
| `C07RepairTowerPowerStatusProof` | `375736358` | PASS | 0 |
| `C07ShieldWallPowerStatusProof` | `375736358` | PASS | 0 |
| `C07RepairTurretPowerStatusProof` | `375736358` | PASS | 0 |
| `C07RadarPowerStatusProof` | `375736358` | PASS | 0 |
| `C07LaunchPadPowerStatusProof` | `375736358` | PASS | 0 |
| `C07MassDriverPowerStatusProof` | `375736358` | PASS | 0 |
| `C07WallCrafterPowerStatusProof` | `375736358` | PASS | 0 |
| `C07SeparatorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07UnitAssemblerModulePowerStatusProof` | `375736358` | PASS | 0 |
| `C07UnitFactoryPowerStatusProof` | `375736358` | PASS | 0 |
| `C07PayloadDeconstructorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07UnitCargoLoaderPowerStatusProof` | `375736358` | PASS | 0 |
| `C07PayloadMassDriverPowerStatusProof` | `375736358` | PASS | 0 |
| `C07PayloadUnloaderPowerStatusProof` | `375736358` | PASS | 0 |
| `C07PayloadLoaderPowerStatusProof` | `375736358` | PASS | 0 |
| `C07ConstructorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07RegenProjectorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07BaseShieldPowerStatusProof` | `375736358` | PASS | 0 |
| `C07ForceProjectorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07OverdriveProjectorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07MendProjectorPowerStatusProof` | `375736358` | PASS | 0 |
| `C07BeamDrillPowerStatusProof` | `375736358` | PASS | 0 |
| `C07MechanicalPumpPowerStatusProof` | `375736358` | PASS | 0 |
| `C07FrackerPowerStatusProof` | `375736358` | PASS | 0 |
| `C07TractorBeamTurretPowerStatusProof` | `375736358` | PASS | 0 |
| `C07PointDefenseTurretPowerStatusProof` | `375736358` | PASS | 0 |
| `C07SolidPumpPowerStatusProof` | `375736358` | PASS | 0 |
| `C07BurstDrillPowerStatusProof` | `375736358` | PASS | 0 |
| `C07TurretPowerStatusProof` | `375736358` | PASS | 0 |
| `C07AdjacentFactoryPowerStatusProof` | `375736358` | PASS | 0 |
| `C07AssemblerDronesInPositionProof` | `375736358` | PASS | 0 |
| `C07BaseTurretBuildDrawSelectProof` | `375736358` | PASS | 0 |
| `C07BaseTurretDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07BeamDrillCanPlaceOnSetBarsProof` | `375736358` | PASS | 0 |
| `C07BeamDrillDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07BeamDrillDrawPlaceProof` | `375736358` | PASS | 0 |
| `C07BeamDrillDrawProof` | `375736358` | PASS | 0 |
| `C07BeamDrillDrawSelectDrawPlanRegionInitProof` | `375736358` | PASS | 0 |
| `C07BeamDrillLaserDefaultsProof` | `375736358` | PASS | 0 |
| `C07BeamDrillOutputsItemsRotatedOutputIconsShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07BeamDrillSetStatsProof` | `375736358` | PASS | 0 |
| `C07BeamDrillUpdateFacingProof` | `375736358` | PASS | 0 |
| `C07BeamDrillUpdateTileProof` | `375736358` | PASS | 0 |
| `C07BeamDrillVersionWriteReadProof` | `375736358` | PASS | 0 |
| `C07BuildTurretInitUnitTypeProof` | `375736358` | PASS | 0 |
| `C07BuildTurretReadPlansProof` | `375736358` | PASS | 0 |
| `C07BuildTurretUpdateTilePlanProof` | `375736358` | PASS | 0 |
| `C07BurstDrillGetDrillTimeProof` | `375736358` | PASS | 0 |
| `C07ContinuousLiquidTurretDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretAmmoOneLinersProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretEstimateDpsHasAmmoShouldActiveSoundProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretGetAmmoFractionProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretTurnToTargetHandleBulletProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretUpdateBulletProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretUpdateShootingProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretUpdateTileProof` | `375736358` | PASS | 0 |
| `C07ContinuousTurretVersionWriteReadProof` | `375736358` | PASS | 0 |
| `C07DrillBurstDrillDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07DrillCanPlaceOnSetBarsDrawPlanConfigProof` | `375736358` | PASS | 0 |
| `C07DrillCountOreSortOpenerProof` | `375736358` | PASS | 0 |
| `C07DrillDrawPlaceProof` | `375736358` | PASS | 0 |
| `C07DrillDrawProof` | `375736358` | PASS | 0 |
| `C07DrillIconsProof` | `375736358` | PASS | 0 |
| `C07DrillInitProof` | `375736358` | PASS | 0 |
| `C07DrillPowerStatusProof` | `375736358` | PASS | 0 |
| `C07DrillSetStatsBoosterAmountProof` | `375736358` | PASS | 0 |
| `C07DrillShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07DrillUpdateTileEffectsProof` | `375736358` | PASS | 0 |
| `C07FactoryPowerStatusProof` | `375736358` | PASS | 0 |
| `C07GameLoopHasSpawnsProof` | `375736358` | PASS | 0 |
| `C07GameLoopStateAccessorsProof` | `375736358` | PASS | 0 |
| `C07ItemTurretEfficiencyProof` | `375736358` | PASS | 0 |
| `C07ItemTurretInitAmmoFilterProof` | `375736358` | PASS | 0 |
| `C07LaserTurretActiveSoundVolumeProof` | `375736358` | PASS | 0 |
| `C07LaserTurretPlacedProof` | `375736358` | PASS | 0 |
| `C07LaserTurretSetStatsInitProgressProof` | `375736358` | PASS | 0 |
| `C07LaserTurretShouldConsumeProof` | `375736358` | PASS | 0 |
| `C07LaserTurretTurnToTargetHandleBulletProof` | `375736358` | PASS | 0 |
| `C07LaserTurretUpdateShootingProof` | `375736358` | PASS | 0 |
| `C07LaserTurretUpdateTileLeg1Proof` | `375736358` | PASS | 0 |
| `C07LaserTurretUpdateTileLeg2Proof` | `375736358` | PASS | 0 |
| `C07LiquidTurretDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07LiquidTurretFindTargetScanProof` | `375736358` | PASS | 0 |
| `C07LogicCheckCampaignStatsProof` | `375736358` | PASS | 0 |
| `C07LogicCheckOverlappingPlansProof` | `375736358` | PASS | 0 |
| `C07LogicIsWaitingWaveProof` | `375736358` | PASS | 0 |
| `C07LogicRunWaveProof` | `375736358` | PASS | 0 |
| `C07LogicSkipWaveProof` | `375736358` | PASS | 0 |
| `C07LogicUpdateGameOverProof` | `375736358` | PASS | 0 |
| `C07PayloadAmmoTurretCurrentAmmoProof` | `375736358` | PASS | 0 |
| `C07PayloadAmmoTurretDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07PayloadAmmoTurretGetAmmoContentProof` | `375736358` | PASS | 0 |
| `C07PayloadAmmoTurretInitProof` | `375736358` | PASS | 0 |
| `C07PayloadAmmoTurretUseAmmoProof` | `375736358` | PASS | 0 |
| `C07PayloadTurretDisplayBarsProof` | `375736358` | PASS | 0 |
| `C07PayloadTurretLimitRangeProof` | `375736358` | PASS | 0 |
| `C07PayloadTurretPayloadIntakeProof` | `375736358` | PASS | 0 |
| `C07PayloadTurretPeekAmmoProof` | `375736358` | PASS | 0 |
| `C07PayloadTurretWriteReadProof` | `375736358` | PASS | 0 |
| `C07PowerStatusLiveProof` | `375736358` | PASS | 0 |
| `C07RadarDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07ReconstructorConstructTimeProof` | `375736358` | PASS | 0 |
| `C07SoundControlDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07SoundControlFindMusicProof` | `375736358` | PASS | 0 |
| `C07SoundControlGetMusicProof` | `375736358` | PASS | 0 |
| `C07SoundControlPlayMusicProof` | `375736358` | PASS | 0 |
| `C07SoundControlPlayRandomProof` | `375736358` | PASS | 0 |
| `C07SoundControlPlaySilenceProof` | `375736358` | PASS | 0 |
| `C07SoundControlReloadProof` | `375736358` | PASS | 0 |
| `C07SoundControlSetupFiltersProof` | `375736358` | PASS | 0 |
| `C07SoundControlStopProof` | `375736358` | PASS | 0 |
| `C07SoundControlUpdateProof` | `375736358` | PASS | 0 |
| `C07SpawnGroupCanSpawnProof` | `375736358` | PASS | 0 |
| `C07SpawnGroupGetShieldProof` | `375736358` | PASS | 0 |
| `C07SpawnGroupGetSpawnedProof` | `375736358` | PASS | 0 |
| `C07TeamDataLivenessProof` | `375736358` | PASS | 0 |
| `C07TeamDataLookupProof` | `375736358` | PASS | 0 |
| `C07TeamsAnyEnemyCoresWithinBuildRadiusProof` | `375736358` | PASS | 0 |
| `C07TeamsAnyEnemyCoresWithinProof` | `375736358` | PASS | 0 |
| `C07TeamsBlockPlanProof` | `375736358` | PASS | 0 |
| `C07TeamsClosestCoreTreeProof` | `375736358` | PASS | 0 |
| `C07TeamsClosestEnemyCoreProof` | `375736358` | PASS | 0 |
| `C07TeamsCountPayloadBranchProof` | `375736358` | PASS | 0 |
| `C07TeamsDerelictLegsProof` | `375736358` | PASS | 0 |
| `C07TeamsDerelictProof` | `375736358` | PASS | 0 |
| `C07TeamsDestroyPayloadProof` | `375736358` | PASS | 0 |
| `C07TeamsEachEnemyCoreProof` | `375736358` | PASS | 0 |
| `C07TeamsLookupProof` | `375736358` | PASS | 0 |
| `C07TeamStateProof` | `375736358` | PASS | 0 |
| `C07TeamsToStringProof` | `375736358` | PASS | 0 |
| `C07TeamsUpdateActiveProof` | `375736358` | PASS | 0 |
| `C07TeamsUpdateEnemiesProof` | `375736358` | PASS | 0 |
| `C07TeamsUpdateTeamStatsLegsProof` | `375736358` | PASS | 0 |
| `C07TeamsUpdateTeamStatsProof` | `375736358` | PASS | 0 |
| `C07TurretActiveSoundVolumeProof` | `375736358` | PASS | 0 |
| `C07TurretBulletEntryProof` | `375736358` | PASS | 0 |
| `C07TurretControlledProof` | `375736358` | PASS | 0 |
| `C07TurretDefaultConstructorProof` | `375736358` | PASS | 0 |
| `C07TurretDrawProof` | `375736358` | PASS | 0 |
| `C07TurretDrawSelectProof` | `375736358` | PASS | 0 |
| `C07TurretFindEnemyProof` | `375736358` | PASS | 0 |
| `C07TurretGetAmmoContentFractionProof` | `375736358` | PASS | 0 |
| `C07TurretHandleLiquidProof` | `375736358` | PASS | 0 |
| `C07TurretPeekAmmoProof` | `375736358` | PASS | 0 |
| `C07TurretReadSyncProof` | `375736358` | PASS | 0 |
| `C07TurretRemoveOnDestroyedProof` | `375736358` | PASS | 0 |
| `C07TurretShootBulletLegsProof` | `375736358` | PASS | 0 |
| `C07TurretShootBulletShakeProof` | `375736358` | PASS | 0 |
| `C07TurretShouldTurnProof` | `375736358` | PASS | 0 |
| `C07TurretTargetingDefaultsProof` | `375736358` | PASS | 0 |
| `C07TurretTargetPositionOffsetProof` | `375736358` | PASS | 0 |
| `C07TurretUpdateTileDriverProof` | `375736358` | PASS | 0 |
| `C07UnitGroupCountsProof` | `375736358` | PASS | 0 |
| `C07UnitsCanCreateProof` | `375736358` | PASS | 0 |
| `C07WaveSpawnerCountSpawnsProof` | `375736358` | PASS | 0 |
| `C07WaveSpawnerGetSpawnsProof` | `375736358` | PASS | 0 |
| `C07WaveSpawnerIsSpawningProof` | `375736358` | PASS | 0 |
| `C07WaveSpawnerPlayerNearProof` | `375736358` | PASS | 0 |
| `C07WaveSpawnerSpawnCountsProof` | `375736358` | PASS | 0 |
| `C07BuildTurretBuildRotationProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretCanControlProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretInitUnitTypeProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretPowerStatusProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretReadPlansProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretSenseObjectProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretSenseProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretShouldConsumeProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretUpdateTilePlanProof` | `5dd2907ce` | PASS | 0 |
| `C07BuildTurretWarmupProof` | `5dd2907ce` | PASS | 0 |
| `AbilityModuleProof` | `5dd2907ce` | PASS | 0 |
| `AttributeModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `AttributesModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BaseTurretDrawModuleProof` | `5dd2907ce` | PASS | 0 |
| `BasicCompStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BatteryPlacementProof` | `5dd2907ce` | PASS | 0 |
| `BatteryPowerStatusProof` | `5dd2907ce` | PASS | 0 |
| `BlockCanReplaceGeneratedBridgeProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockCheckContentArrayCapacityModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockConsumeModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockCreateIconsModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockDisplayQueryModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockDrawModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockDrawPlaceTextModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockDrawPotentialLinksModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockDrawSideRegionModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockGetDependenciesModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockIconModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitBufferedPowerModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitBuildingDefaultModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitBuildTimeModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitClipModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitConsumerModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitFlagsModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitHealthModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockInitItemLiquidFiltersModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockInitLogicConfigurableModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockInitPlacementModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockInitSandboxVisibilityModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockInitSetBarsCallModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockInitSoundModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockInitStatsCategoriesModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockLifecycleHookModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockLoadModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockMetadataModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockPlacementModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockPlanModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockPostInitModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockProducerModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockQueryBasicModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockQueryConsumerModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockQueryDarknessModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockQueryFilterModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockQueryModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockQueryPlacementModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockReinitializeConsumersModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockRequirementsStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockResearchRequirementsStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockRuntimeGeometryModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockSenseModuleProof` | `5dd2907ce` | PASS | 0 |
| `BlockStatsBarsModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockSumAttributeModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BlockUnitStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuilderDrawStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuilderRuntimeStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingAccessStateModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BuildingConfigureStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingControlStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingCoreStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingDamageModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingDestructionStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingDisplayStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingDrawStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingEfficiencyStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingGeometryStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingHeatStateModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BuildingInteractionModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingInteractionStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingLifecycleStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingLiquidStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingMetaStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingNavigationStateModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BuildingPlanStateModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BuildingPowerStateModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BuildingSenseModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingSetPropStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingTetherStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingTimeStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildingVersionModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BuildingVisibilityStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildPayloadLifecycleModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BuildPayloadModuleProof` | `5dd2907ce` | PASS | 0 |
| `BuildSelectionModuleProof` | `5dd2907ce` | PASS | native only; no existing module |
| `BulletRuntimeModuleProof` | `5dd2907ce` | PASS | 0 |
| `BulletTypeCallbackModuleProof` | `5dd2907ce` | PASS | 0 |
| `BulletTypeCreateCoreStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BulletTypeCreateFragsStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `BulletTypeHitStateModuleProof` | `5dd2907ce` | PASS | 0 |
| `C06ReconstructorProductionProof` | `5dd2907ce` | PASS | 0 |
| `C06SourceExhaustionProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitAssemblerCheckTierProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitAssemblerPayloadIntakeProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitAssemblerPayloadProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitAssemblerPayloadTriggerProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitAssemblerProductionProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitFactoryConsumeProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitFactoryProductionProof` | `5dd2907ce` | PASS | 0 |
| `C06UnitFactoryShouldConsumeProof` | `5dd2907ce` | PASS | 0 |
| `CampaignLaunchContextRuntimeProof` | `5dd2907ce` | PASS | 0 |
| `CampaignMapBlockLayerRuntimeProof` | `5dd2907ce` | PASS | 0 |
| `CampaignMapContentHeaderRuntimeProof` | `5dd2907ce` | PASS | 0 |
| `CampaignMapFileRuntimeProof` | `5dd2907ce` | PASS | 0 |
| `CampaignMapTerrainRuntimeProof` | `5dd2907ce` | RED | 0 |
| `CampaignMapTileRuntimeProof` | `5dd2907ce` | PASS | 0 |
| `BuildingItemDumpStateModuleProof` | `837765f37` | PASS | 0 |
| `BuildingUnitPayloadModuleProof` | `837765f37` | PASS | native only; no existing module |
| `BuildingItemStateModuleProof` | `837765f37` | PASS | 0 |
| `BuildingPayloadStateModuleProof` | `837765f37` | PASS | 0 |
| `C06BuildingUpdateProof` | `837765f37` | PASS | 0 |
| `C06DefenseProof` | `837765f37` | PASS | 0 |
| `C06PowerShouldConsumeProof` | `837765f37` | PASS | 0 |
| `C06SessionProof` | `837765f37` | PASS | 0 |
| `CampaignSectorModuleProof` | `837765f37` | PASS | 0 |
| `CampaignSectorSelectionProof` | `837765f37` | PASS | 0 |
| `CampaignShellModuleProof` | `837765f37` | PASS | 0 |
| `CampaignShellUiRuntimeProof` | `837765f37` | PASS | 0 |
| `ChildStateModuleProof` | `837765f37` | PASS | 0 |
| `ConstructBuildStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeItemAttributeGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeItemDynamicGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeItemEfficiencyGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeItemExplodeGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeItemFilterGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeItemListGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeItemsGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidApplyRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidBaseGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidFilterGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidFlammableGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidFlammableModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidsDynamicGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumeLiquidsGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ConsumePowerModuleProof` | `837765f37` | PASS | 0 |
| `ContentRegistryRuntimeModuleProof` | `837765f37` | PASS | native only; no existing module |
| `ContinuousLiquidTurretBuildModuleProof` | `837765f37` | PASS | 0 |
| `ContinuousLiquidTurretLiveLoopProof` | `837765f37` | PASS | 0 |
| `ContinuousLiquidTurretTickFrameProof` | `837765f37` | PASS | 0 |
| `ControlInputModuleProof` | `837765f37` | PASS | native only; no existing module |
| `ConveyorAdvanceProof` | `837765f37` | PASS | 0 |
| `ConveyorRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `CoreDamageRuntimeModuleProof` | `837765f37` | PASS | native only; no existing module |
| `DisplayProfileRuntimeModuleProof` | `837765f37` | PASS | native only; no existing module |
| `DrillDumpRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `DrillInventoryCallbackModuleProof` | `837765f37` | PASS | 0 |
| `DrillOreSelectionProof` | `837765f37` | PASS | 0 |
| `DrillPerDrillDumpProof` | `837765f37` | PASS | 0 |
| `DrillProductionRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `DrillProximityLifecycleProof` | `837765f37` | PASS | 0 |
| `DrillRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `EnemyUnitRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `FactoryConsumerBindingProof` | `837765f37` | PASS | 0 |
| `FactoryDumpSwapProof` | `837765f37` | PASS | 0 |
| `FactoryRuntimeModuleProof` | `837765f37` | RED | 0 |
| `FloorModuleProof` | `837765f37` | PASS | native only; no existing module |
| `GameConfigRuntimeModuleProof` | `837765f37` | PASS | native only; no existing module |
| `GameRulesStateProof` | `837765f37` | PASS | 0 |
| `GeneratedClassPathHeadquarterProof` | `837765f37` | RED | 0 |
| `GeneratedClassRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `InputEventRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `InputHandlerQueryModuleProof` | `837765f37` | PASS | native only; no existing module |
| `InputViewportRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `ItemEntryModuleProof` | `837765f37` | PASS | 0 |
| `ItemTransportRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `ItemTurretBuildModuleProof` | `837765f37` | PASS | 0 |
| `LancerPlacementProof` | `837765f37` | PASS | 0 |
| `LiquidTurretBuildModuleProof` | `837765f37` | PASS | 0 |
| `MechanicalPumpPlacementProof` | `837765f37` | PASS | 0 |
| `MendProjectorRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `OverdriveProjectorRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `PlacedBlockStateModuleProof` | `837765f37` | RED | 0 |
| `PlacedPowerBatteryRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `PlacedPowerDistributionRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `PlacedPowerGraphGroupingProof` | `837765f37` | PASS | 0 |
| `PlacedPowerGraphStateModuleProof` | `837765f37` | PASS | 0 |
| `PlayableContentDefaultsModuleProof` | `837765f37` | PASS | 0 |
| `PlayableSmokeRuntimeProof` | `837765f37` | PASS | 0 |
| `PowerGeneratedRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `PowerGeneratorModuleProof` | `837765f37` | PASS | 0 |
| `PowerGeneratorPuddleVectorModuleProof` | `837765f37` | PASS | 0 |
| `PowerGraphBatteryDistributionModuleProof` | `837765f37` | PASS | 0 |
| `PowerGraphDefaultRequestedPowerProof` | `837765f37` | PASS | 0 |
| `PowerGraphDefaultRoleCallbackProof` | `837765f37` | PASS | 0 |
| `PowerGraphLiveUpdateProof` | `837765f37` | PASS | 0 |
| `PowerNodeLinkValidationModuleProof` | `837765f37` | PASS | native only; no existing module |
| `PowerNodeOverlapModuleProof` | `837765f37` | PASS | native only; no existing module |
| `PowerNodePresentationModuleProof` | `837765f37` | PASS | native only; no existing module |
| `PowerNodeSetupModuleProof` | `837765f37` | PASS | native only; no existing module |
| `PowerTurretBuildModuleProof` | `837765f37` | PASS | 0 |
| `ProjectorBoostRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `PuddlesDepositModuleProof` | `837765f37` | PASS | native only; no existing module |
| `RootPolicyShardModuleProof` | `837765f37` | PASS | native only; no existing module |
| `RulesUnitCostProof` | `837765f37` | PASS | 0 |
| `RuntimeSummaryModuleProof` | `837765f37` | PASS | 0 |
| `ShootPatternModuleProof` | `837765f37` | PASS | 0 |
| `SolarPanelPlacementProof` | `837765f37` | PASS | 0 |
| `SourceMathAngleModuleProof` | `837765f37` | PASS | 0 |
| `SsotAccessorRuntimeModuleProof` | `837765f37` | PASS | native only; no existing module |
| `SsotHeadquarterRegistryProof` | `837765f37` | PASS | 0 |
| `StatusApplyModuleProof` | `837765f37` | PASS | 0 |
| `SyncStateModuleProof` | `837765f37` | PASS | 0 |
| `TeamCheatingStateProof` | `837765f37` | PASS | 0 |
| `TeamsCoreRegistrationProof` | `837765f37` | PASS | 0 |
| `TileModuleProof` | `837765f37` | PASS | native only; no existing module |
| `TractorBeamAngleStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamAnyTrueStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamDamagePierceStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamDrawStateModuleProof` | `837765f37` | PASS | native only; no existing module |
| `TractorBeamImpulseNetStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamLastTargetPositionStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamLifecycleModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamLookTargetGuardStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamRotationStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamShootWhenPossibleGuardStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamSoundLoopStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamStatusApplyStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamStrengthStateModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamUpdateTileFlowModuleProof` | `837765f37` | PASS | 0 |
| `TractorBeamUpdateTileRetargetModuleProof` | `837765f37` | PASS | 0 |
| `TurretAmmoModuleProof` | `837765f37` | PASS | 0 |
| `TurretCellRegistryModuleProof` | `837765f37` | PASS | native only; no existing module |
| `TurretCombatModuleProof` | `837765f37` | PASS | 0 |
| `TurretInitModuleProof` | `837765f37` | PASS | 0 |
| `TurretLiquidInitModuleProof` | `837765f37` | PASS | native only; no existing module |
| `TurretLiveLoopProof` | `837765f37` | PASS | 0 |
| `TurretOutputsItemsModuleProof` | `837765f37` | PASS | 0 |
| `TurretPlacementModuleProof` | `837765f37` | PASS | 0 |
| `TurretPresentationModuleProof` | `837765f37` | PASS | 0 |
| `TurretPropertyModuleProof` | `837765f37` | PASS | 0 |
| `TurretRangeModuleProof` | `837765f37` | PASS | 0 |
| `TurretRuntimeCallbackModuleProof` | `837765f37` | PASS | 0 |
| `TurretSimulationModuleProof` | `837765f37` | PASS | 0 |
| `TurretStatsBarsModuleProof` | `837765f37` | PASS | 0 |
| `TwoDrillGateProof` | `837765f37` | PASS | 0 |
| `UnitBuildingCommandModuleProof` | `837765f37` | PASS | native only; no existing module |
| `UnitFactoryConsumerBindingProof` | `837765f37` | RED | 1 |
| `UnitFactoryLiveLoopProof` | `837765f37` | PASS | 0 |
| `UnitFallingStateModuleProof` | `837765f37` | PASS | 0 |
| `UnitMetadataCallbackModuleProof` | `837765f37` | PASS | 0 |
| `UnitPayloadBasicModuleProof` | `837765f37` | PASS | native only; no existing module |
| `UnitPayloadContentModuleProof` | `837765f37` | PASS | native only; no existing module |
| `UnitPayloadDrawModuleProof` | `837765f37` | PASS | 0 |
| `UnitPayloadDumpModuleProof` | `837765f37` | PASS | 0 |
| `UnitPayloadDumpOverlapGuardModuleProof` | `837765f37` | PASS | 0 |
| `UnitPayloadDumpSolidityGuardModuleProof` | `837765f37` | PASS | 0 |
| `UnitPayloadIoModuleProof` | `837765f37` | PASS | 0 |
| `UnitPayloadRequirementsModuleProof` | `837765f37` | PASS | native only; no existing module |
| `UnitTetherStateModuleProof` | `837765f37` | PASS | 0 |
| `UnitTypeCoreModuleProof` | `837765f37` | PASS | native only; no existing module |
| `UnitUpdateStateModuleProof` | `837765f37` | PASS | 0 |
| `WaveTimingRuntimeModuleProof` | `837765f37` | PASS | 0 |
| `WeaponBulletEffectsModuleProof` | `837765f37` | PASS | 0 |
| `WeaponMountAutoTargetModuleProof` | `837765f37` | PASS | 0 |
| `WeaponMountKinematicsModuleProof` | `837765f37` | PASS | 0 |
| `WeaponShootModuleProof` | `837765f37` | PASS | 0 |
| `WorldInitialBuildRuntimeStateModuleProof` | `837765f37` | RED | 0 |
| `WorldTerrainRuntimeStateModuleProof` | `837765f37` | PASS | 0 |
| `WorldTileLifecycleProof` | `837765f37` | PASS | 0 |
| `C06PauseProof` | `ba47e471b` | PASS | 0 |
| `DrillOreBindingProof` | `ba47e471b` | PASS | 0 |
| `HudRuntimeStateModuleProof` | `ba47e471b` | PASS | 0 |
| `TileOreProviderProof` | `ba47e471b` | PASS | 0 |
| `UnitDestroyModuleProof` | `ba47e471b` | PASS | 0 |
| `GameLoopRuntimeStateModuleProof` | `e146d4af3` | PASS | 0 |
| `NodeBindingRuntimeModuleProof` | `e146d4af3` | PASS | native only; no existing module |
| `TextureRuntimeModuleProof` | `e146d4af3` | PASS | native only; no existing module |
| `UnitCompGeneratedRuntimeModuleProof` | `e146d4af3` | PASS | native only; no existing module |
| `SourceMathSourceTextModuleProof` | `e146d4af3` | PASS | 0 |
| `C07BaseTurretEstimateDpsProof` | `e146d4af3` | PASS | 0 |
| `C07PayloadTurretGetAmmoFractionProof` | `e146d4af3` | PASS | 0 |
| `C07TurretEstimateDpsProof` | `e146d4af3` | PASS | 0 |
| `C07BaseTurretStatusProof` | `e146d4af3` | PASS | 0 |
| `C07PayloadTurretDisplayBarsProof` | `e146d4af3` | PASS | 0 |
| `C07PayloadAmmoTurretGetAmmoContentProof` | `e146d4af3` | PASS | 0 |
| `C07TeamColoredNameProof` | `5c67738e6` | PASS | 0 |
| `C07TeamCompClosestCoreProof` | `5c67738e6` | PASS | 0 |
| `C07TeamCompareToProof` | `5c67738e6` | PASS | 0 |
| `C07TeamsClosestCoreTreeProof` | `5c67738e6` | PASS | 0 |
| `TeamCheatingStateProof` | `5c67738e6` | PASS | 0 |
