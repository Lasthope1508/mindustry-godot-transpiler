# Godot debt validation: 233 GREEN, 15 RED retained

Validated integration wave36 `e64d277ce2c59cda828c49a820e7878fda6cb406` on `codex/godot-all-debt-20261119`. Current main audited separately at `b21b55f22fdb0309fcb226e20f936406ce8aaf4d`. This report branch is based on main and contains reports/evidence only; no migration ancestry is merged.

## Results and selection

- Integration inventory: 308 scenes reviewed; 60 prior passing scenes accepted without duplicate runs.
- 247 unique scenes ran through their existing targeted unittest modules and native Windows Godot MCP; 233 GREEN, 14 current RED. Every selected scene has a captured result; none remains unrun in this queue.
- 1 prior unchanged RED results remain pending, making 15 unresolved scenes in this inventory. Passing validation is not equivalent to implementation parity or whole-repository GREEN.
- 61 existing evidence/pending entries retained separately. `inventory.json` identifies scene, evidence basis and prior fixture requirements. Reconciliation conservatively reran 31 scenes whose source/fixture blobs differed from prior passing evidence, including six missing fixture adoptions.
- Main added 28 proof scenes since the previous audit. Specific source-controlled Linux runtime passes were accepted, with GOAL/report excerpts in `main-audit.json`; absent-engine full-gate failures did not trigger duplicate Windows runs. N numbers overlap between main and integration: scene identity and implementation matter.
- Audited 47 pushed wave branches. Divergent wave14 has no unmatched runtime/proof patches; wave23's unique change is the duplicate-variable parser backport already fixed in wave36. N2323 UCL proof-fix content matches wave36 (original commit ancestry differs).

## Runtime and evidence

Windows Godot `4.6.2.stable.official.71f334935`, project `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Targeted commands: Python `-X utf8 -m unittest tests.<module> -v` from `tools/mindustry_godot_transpiler`; exact modules/commands, durations, exit codes and stdout/stderr are in the archive. Each proof also ran via native MCP without headless mode. TCP7777 was checked before every launch; launches were sequential and only owned projects were stopped after diagnostic capture.

GREEN requires targeted exit0, exactly one native proof, `matches:true`, all recorded assertions true and no runtime/parser errors. Warnings are retained and counted separately. No full gate ran or is claimed. Draw/sense descriptor tests do not prove full rendered UI behavior.

[Evidence](evidence/2026-11-20-all-debt/) includes readable results, inventory, pending list, accepted main evidence, fixture patch, and a ZIP containing 1199 original captures/logs/context files plus RED archives and failed trial patches. ZIP SHA256: `393c6122309523ea158d6e59dba3bb5ac22103803084e5e6a88cd0e49faa64ca`. `manifest.sha256` lists each uncompressed artifact hash.

## Passing fixture repairs

Fixture commit `80514883daae2af02e4e282927485496fe7061c0` on `codex/godot-all-debt-20261119` is pushed separately for selective adoption by the integration owner. **Do not merge that branch's integration ancestry into main.** Original RED captures are retained. Assertions/expected behavior remain unchanged; the historical PayloadMassDriver repair also corrects invalid Object.get arity while preserving its expected value.

Repairs cover the proof marker spelling, caller-supplied proximity provenance, payload block/build descriptor, missing MassDriver state arguments, non-overlapping physical footprints while preserving asserted ring contact cells, an explicit empty payload inventory slot, active deconstruction setup, Shockwave comment syntax, source-backed required liquid/item setup, source-initialized damaged-target health, and reapplication of prior isolated team/snapshot/ray/property-name fixture repairs. Exact passing file allowlist:

- `godot-mindustry/tools/runtime_proofs/C07BaseShieldScansProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BeamDrillDumpNeighbourLiveFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BeamDrillFacingTilesFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BuildTurretShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BuildTurretUpdateTileProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BurstDrillDumpNeighbourLiveFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BurstDrillOffloadNeighborRoutingProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BurstDrillShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07BurstDrillUpdateTileProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07FactoryBatteryEnabledStampProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07FrackerShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07ImpactReactorUpdateTileProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07ItemBridgeDumpNeighbourLiveFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07MassDriverAcceptItemProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07MassDriverDumpProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07OverdriveProjectorUpdateTileProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDumpNeighbourLiveFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDumpProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDumpWriteBackProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07PayloadLoaderLoadTimerProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07PayloadMassDriverLargeVariantProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07PayloadUnloaderShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RegenProjectorHealApplicationProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RegenProjectorMendMapFlushProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RegenProjectorPrivilegedFlagFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RegenProjectorShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RegenProjectorTargetsFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RegenProjectorTargetsNarrowProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RegenProjectorUpdateTileProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07RepairTurretCoolantProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07SeparatorDumpNeighbourLiveFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07SeparatorShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerBulletScanHitboxProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07StackRouterLiveProximityQueryProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07StackRouterTargetProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07UnitAssemblerCheckTierWiringProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07UnitAssemblerModuleFlaggedBuildingsFillProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderShouldConsumeProof.gd`
- `godot-mindustry/tools/runtime_proofs/C07WallCrafterShouldConsumeProof.gd`
- `tools/mindustry_godot_transpiler/tests/test_c07_stack_conveyor_blends_plan_rows.py`

RepairTurret liquid module initialization and damaged-target health are fixture setup only; general runtime catalog initialization is not fixed or certified by these proofs. Failed repair trials were archived and removed from the working tree; none is published as a passing fixture. Gameplay, SSOT, ledgers and PortGame were not changed.

## Pending RED results

The failures below are real observed results, not missing-engine skips. Unless a precise cause is established in prior evidence, root cause remains unconfirmed and needs the responsible migration work to compare implementation with source; this validation scope cannot change gameplay/SSOT. Do not weaken assertions or close these entries as GREEN.

- N2443 `C07LightBlockConfigColorRowsProof`: control_bits, matches, sense_color_double_bits
- N2222 `C07SeparatorUpdateTileProof`: craft_completes_at_progress_one, live_tick_advances_progress_and_warmup, matches, offload_picks_weighted_result
- N2343 `C07SeparatorOffloadRoutingProof`: matches, offload_falls_back_without_accepting_neighbor, offload_respects_item_capacity, offload_routes_to_accepting_neighbor
- N2353 `C07SeparatorNeighbourWriteBackProof`: advance_exposes_routed_neighbour_index, live_tick_writes_offloaded_item_to_neighbour_frame, matches
- N2283 `C07WallCrafterTimerDumpProof`: live_tick_dumps_output, matches, timer_fires_at_five_ticks
- N2284 `C07FrackerDumpLiquidProof`: dump_runs_in_both_branches, live_tick_dumps_liquid, matches
- N2360 `C07BurstDrillTimerDumpWriteBackProof`: live_tick_writes_dumped_item_to_neighbour_frame, matches
- N2361 `C07SeparatorTimerDumpWriteBackProof`: live_tick_writes_dumped_item_to_neighbour_frame, matches
- N2363 `C07BeamDrillTimerDumpWriteBackProof`: live_tick_writes_dumped_item_to_neighbour_frame, matches
- N2371 `C07LiquidNeighbourWriteBackProof`: live_tick_dumped_liquid_leaves_fracker_without_frame, live_tick_writes_dumped_liquid_to_neighbour_frame, matches
- N2377 `C07SolidPumpDumpLiquidWriteBackProof`: live_tick_writes_dumped_liquid_to_neighbour_frame, matches
- N2378 `C07PumpLiquidNeighbourWriteBackProof`: live_tick_writes_dumped_water_to_neighbour_frame, matches
- N2379 `C07LiquidBridgeDumpWriteBackProof`: live_tick_writes_dumped_liquid_to_neighbour_frame, matches
- N2380 `C07PayloadUnloaderDumpLiquidWriteBackProof`: live_tick_writes_dumped_liquid_to_neighbour_frame, matches
- N2398 `C07WallCrafterOffloadRoutingProof`: advance_exposes_offload_neighbour_index, live_tick_routes_offloaded_item_to_neighbour_frame, matches

Native diagnostics for N2361, N2363 and N2377 identify a recipient with both adjacent-factory and separator frames: shared write-back helpers select the first consumer frame, while the proof observes the separator frame. Source-side removal/cursor behavior succeeds, recipient family state diverges. Removing a valid frame in the fixture would mask this runtime dispatch issue. See DIAGNOSTIC captures and pending-diagnosis.json.

LightBlock color failures involve the denormal/double-bit encode/decode path; the fixture assertions remain intact. N2360's expanded-world fixture trial now passes its bare/no-frame assertion, but its live recipient write-back remains RED; world expansion and provenance trials are retained. Separator weighted-result and routing failures include pure assertions and cannot be resolved by merely supplying live resources. Each pending entry retains the exact false keys/errors and tested source blobs.

## Per-scene latest results

| Scene | Targeted | Native assertions | Warnings |
| --- | --- | --- | --- |
| N2176 `C07RepairTowerPowerStatusProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2177 `C07ShockwaveTowerPowerStatusProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2186 `C07LaunchPadShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2187 `C07ShockwaveTowerShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2188 `C07ItemBridgeShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2190 `C07RadarUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2191 `C07AcceleratorUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2192 `C07ImpactReactorUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2193 `C07MendProjectorUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2194 `C07OverdriveProjectorUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2195 `C07BeamDrillUpdateTileProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2197 `C07ItemBridgeLinkFrameStateProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2198 `C07LiquidBridgeShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2199 `C07ItemBridgeAutoLinkProof` | 4 tests / exit 0 | GREEN 11/11 | 120 |
| N2200 `C07SeparatorShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2201 `C07WallCrafterShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2202 `C07BeamDrillShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2203 `C07BurstDrillShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2205 `C07MechanicalPumpShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2206 `C07SolidPumpShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2207 `C07FrackerShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2208 `C07PayloadLoaderShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2209 `C07PayloadUnloaderShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2210 `C07PayloadDeconstructorShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2211 `C07UnitCargoLoaderShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2212 `C07RepairTurretShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2213 `C07RepairTowerShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2214 `C07RegenProjectorShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2215 `C07BuildTurretShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2216 `C07ConstructorShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2217 `C07PointDefenseTurretShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2218 `C07TractorBeamTurretShouldConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2219 `C07BurstDrillUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2220 `C07SolidPumpUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2221 `C07MechanicalPumpUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2222 `C07SeparatorUpdateTileProof` | 4 tests / exit 1 | RED: craft_completes_at_progress_one, live_tick_advances_progress_and_warmup, matches, offload_picks_weighted_result | 120 |
| N2223 `C07WallCrafterUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2224 `C07FrackerUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2225 `C07ItemBridgeTransportProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2226 `C07RepairTurretUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2227 `C07RepairTowerUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2228 `C07RegenProjectorUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2229 `C07PointDefenseUpdateTileProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2230 `C07TractorBeamUpdateTileProof` | 4 tests / exit 0 | GREEN 11/11 | 120 |
| N2231 `C07PayloadLoaderUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2232 `C07PayloadUnloaderUpdateTileProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2233 `C07PayloadDeconstructorUpdateTileProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2234 `C07UnitCargoLoaderUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2235 `C07ForceProjectorUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2236 `C07BaseShieldUpdateTileProof` | 5 tests / exit 0 | GREEN 9/9 | 120 |
| N2237 `C07MassDriverUpdateTileProof` | 5 tests / exit 0 | GREEN 9/9 | 120 |
| N2238 `C07LaunchPadUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2239 `C07StackConveyorUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2240 `C07StackRouterUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2241 `C07LightBlockUpdateTileProof` | 4 tests / exit 0 | GREEN 11/11 | 120 |
| N2242 `C07MendProjectorHealScanProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2243 `C07BuildTurretUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2244 `C07BuildTurretPlanLogicProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2245 `C07PayloadMassDriverUpdateTileProof` | 5 tests / exit 0 | GREEN 9/9 | 120 |
| N2246 `C07PayloadMassDriverBranchesProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2247 `C07ShockwaveTowerUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2248 `C07UnitAssemblerModuleUpdateTileProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2249 `C07UnitCargoLoaderLiquidRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2250 `C07RepairTowerLiquidRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2251 `C07BuildTurretLiquidRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2252 `C07SeparatorLiquidRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2253 `C07LaunchPadLiquidRowProof` | 4 tests / exit 0 | GREEN 11/11 | 120 |
| N2254 `C07ImpactReactorLiquidRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2255 `C07FrackerLiquidRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2256 `C07BeamDrillLiquidRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2257 `C07BurstDrillLiquidRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2258 `C07ForceProjectorCoolantProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2259 `C07RepairTurretCoolantProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2260 `C07RegenProjectorSecondConsumersProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2261 `C07ForceProjectorBoosterItemProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2262 `C07OverdriveProjectorBoosterItemsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2263 `C07MendProjectorBoosterItemsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2264 `C07WallCrafterSecondConsumersProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2265 `C07ConstructorDynamicItemRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2266 `C07ImpactReactorItemRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2267 `C07AcceleratorItemRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2268 `C07FrackerItemRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2269 `C07MendProjectorBoosterTimerProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2270 `C07PayloadLoaderDynamicPowerProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2271 `C07AcceleratorLaunchProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2272 `C07BuildTurretUpdateBuildLogicProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2273 `C07WallCrafterTimerConsumeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2274 `C07BlockProducerUpdateTileProof` | 4 tests / exit 0 | GREEN 11/11 | 120 |
| N2275 `C07LiquidBridgeUpdateTransportProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2276 `C07PayloadDeconstructorDumpProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2277 `C07RegenProjectorTargetsFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2278 `C07PayloadLoaderLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2279 `C07PayloadUnloaderLiveFillProof` | 4 tests / exit 0 | GREEN 10/10 | 121 |
| N2280 `C07RepairTurretTimerTargetProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2281 `C07SeparatorTimerDumpProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2282 `C07BurstDrillTimerDumpProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2283 `C07WallCrafterTimerDumpProof` | 4 tests / exit 1 | RED: live_tick_dumps_output, matches, timer_fires_at_five_ticks | 120 |
| N2284 `C07FrackerDumpLiquidProof` | 4 tests / exit 1 | RED: dump_runs_in_both_branches, live_tick_dumps_liquid, matches | 120 |
| N2285 `C07PumpDumpLiquidProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2286 `C07SolidPumpDumpLiquidProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2287 `C07LiquidBridgeDoDumpProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2288 `C07ItemBridgeDoDumpProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2289 `C07BeamDrillTimerDumpProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2291 `C07PayloadDeconstructorDeconstructingFillProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2292 `C07SolidPumpFractionFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2293 `C07PayloadUnloaderDumpProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2294 `C07MassDriverDumpProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2295 `C07PayloadLoaderAcceptPayloadProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2296 `C07PayloadUnloaderAcceptPayloadProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2297 `C07PayloadDeconstructorAcceptPayloadProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2298 `C07PayloadMassDriverAcceptPayloadProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2299 `C07UnitAssemblerModuleAcceptPayloadProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2301 `C07WallCrafterGetEfficiencyProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2304 `C07PayloadMassDriverPerDefThresholdProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2305 `C07FrackerFractionFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2306 `C07RepairTowerLiveScanProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2308 `C07PayloadDeconstructorIntakeGateProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2313 `C07PayloadUnloaderIntakeGateProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2314 `C07UnitAssemblerModuleHandoffGateProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2315 `C07PayloadLoaderIntakeGateProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2316 `C07PointDefenseTurretRetargetCadenceProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2317 `C07TractorBeamTurretRetargetCadenceProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2318 `C07ShockwaveTowerTimerCheckProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2319 `C07PayloadLoaderLoadTimerProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2320 `C07PayloadUnloaderLoadTimerProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2321 `C07ItemBridgeTimerCheckMovedProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2322 `C07UnitCargoLoaderCanCreateProof` | 4 tests / exit 0 | GREEN 11/11 | 120 |
| N2324 `C07StackRouterTargetProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2325 `C07RegenProjectorMendMapFlushProof` | 4 tests / exit 0 | GREEN 8/8 | 120 |
| N2326 `C07ForceProjectorTimerUseProof` | 4 tests / exit 0 | GREEN 9/9 | 121 |
| N2327 `C07ShockwaveTowerBulletScanProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2328 `C07BaseShieldScansProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2329 `C07MendProjectorHealScanRangeProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2330 `C07UnitCargoLoaderCanPlaceOnProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2331 `C07ShockwaveTowerCyanogenRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2332 `C07StackRouterAcceptItemProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2333 `C07LaunchPadAcceptItemProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2334 `C07OverdriveProjectorBoostScanProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2335 `C07MendProjectorHealScanNarrowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2336 `C07MassDriverAcceptItemProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2338 `C07RegenProjectorTargetsNarrowProof` | 4 tests / exit 0 | GREEN 8/8 | 120 |
| N2339 `C07BeamDrillFacingScanProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2340 `C07ShockwaveTowerBulletScanHitboxProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2342 `C07AcceleratorBatteryStampProof` | 4 tests / exit 0 | GREEN 7/7 | 46 |
| N2343 `C07SeparatorOffloadRoutingProof` | 4 tests / exit 1 | RED: matches, offload_falls_back_without_accepting_neighbor, offload_respects_item_capacity, offload_routes_to_accepting_neighbor | 120 |
| N2344 `C07RegenProjectorPrivilegedFlagFillProof` | 4 tests / exit 0 | GREEN 6/6 | 120 |
| N2345 `C07UnitAssemblerModuleCanPlaceOnProof` | 4 tests / exit 0 | GREEN 7/7 | 120 |
| N2346 `C07BeamDrillLaserOriginsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2347 `C07ShockwaveTowerBulletScanBroadHitboxProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2348 `C07UnitAssemblerModuleTierStampProof` | 4 tests / exit 0 | GREEN 8/8 | 120 |
| N2349 `C07SeparatorDisassemblerScrapRowProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2350 `C07MendProjectorHealScanHitboxProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2351 `C07UnitAssemblerCheckTierWiringProof` | 4 tests / exit 0 | GREEN 14/14 | 120 |
| N2352 `C07BeamDrillFacingTilesFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2353 `C07SeparatorNeighbourWriteBackProof` | 4 tests / exit 1 | RED: advance_exposes_routed_neighbour_index, live_tick_writes_offloaded_item_to_neighbour_frame, matches | 120 |
| N2354 `C07AcceleratorLaunchDrainProof` | 4 tests / exit 0 | GREEN 8/8 | 46 |
| N2356 `C07ShockwaveTowerDrawRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2357 `C07PayloadMassDriverLargeVariantProof` | 4 tests / exit 0 | GREEN 8/8 | 120 |
| N2358 `C07UnitAssemblerModuleGetLinkDiscoveryProof` | 4 tests / exit 0 | GREEN 17/17 | 120 |
| N2359 `C07FactoryBatteryEnabledStampProof` | 4 tests / exit 0 | GREEN 10/10 | 75 |
| N2360 `C07BurstDrillTimerDumpWriteBackProof` | 4 tests / exit 1 | RED: live_tick_writes_dumped_item_to_neighbour_frame, matches | 120 |
| N2361 `C07SeparatorTimerDumpWriteBackProof` | 4 tests / exit 1 | RED: live_tick_writes_dumped_item_to_neighbour_frame, matches | 120 |
| N2362 `C07ItemBridgeDoDumpWriteBackProof` | 4 tests / exit 0 | GREEN 6/6 | 120 |
| N2363 `C07BeamDrillTimerDumpWriteBackProof` | 4 tests / exit 1 | RED: live_tick_writes_dumped_item_to_neighbour_frame, matches | 120 |
| N2368 `C07PayloadDeconstructorDumpWriteBackProof` | 4 tests / exit 0 | GREEN 6/6 | 120 |
| N2369 `C07MassDriverDumpWriteBackProof` | 4 tests / exit 0 | GREEN 6/6 | 120 |
| N2370 `C07UnitAssemblerModuleHandoffFitsWiringProof` | 4 tests / exit 0 | GREEN 8/8 | 120 |
| N2371 `C07LiquidNeighbourWriteBackProof` | 4 tests / exit 1 | RED: live_tick_dumped_liquid_leaves_fracker_without_frame, live_tick_writes_dumped_liquid_to_neighbour_frame, matches | 120 |
| N2372 `C07MendProjectorDrawRowsProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2373 `C07AcceleratorDrawRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2374 `C07LightBlockDrawRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2377 `C07SolidPumpDumpLiquidWriteBackProof` | 4 tests / exit 1 | RED: live_tick_writes_dumped_liquid_to_neighbour_frame, matches | 120 |
| N2378 `C07PumpLiquidNeighbourWriteBackProof` | 4 tests / exit 1 | RED: live_tick_writes_dumped_water_to_neighbour_frame, matches | 120 |
| N2379 `C07LiquidBridgeDumpWriteBackProof` | 4 tests / exit 1 | RED: live_tick_writes_dumped_liquid_to_neighbour_frame, matches | 120 |
| N2380 `C07PayloadUnloaderDumpLiquidWriteBackProof` | 4 tests / exit 1 | RED: live_tick_writes_dumped_liquid_to_neighbour_frame, matches | 120 |
| N2381 `C07UnitAssemblerModuleFlaggedBuildingsFillProof` | 4 tests / exit 0 | GREEN 16/16 | 120 |
| N2383 `C07MendProjectorSenseRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2387 `C07PayloadDeconstructorSenseRowsProof` | 4 tests / exit 0 | GREEN 10/10 | 120 |
| N2389 `C07LaunchPadSenseRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2390 `C07ShockwaveTowerSenseRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2391 `C07ImpactReactorSenseRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2392 `C07MassDriverSenseRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2399 `C07RegenProjectorHealApplicationProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2402 `C07SeparatorDumpNeighbourLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2403 `C07BurstDrillDumpNeighbourLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2404 `C07ItemBridgeDumpNeighbourLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2405 `C07BeamDrillDumpNeighbourLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2407 `C07PayloadDeconstructorDumpNeighbourLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2436 `C07BeamDrillDrawRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2437 `C07BuildTurretSenseRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2438 `C07ImpactReactorDrawPlanRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2439 `C07LightBlockDrawPlaceRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2440 `C07ConstructorDrawRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2441 `C07BaseShieldDrawShieldRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2442 `C07StackRouterStatsPlanRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2443 `C07LightBlockConfigColorRowsProof` | 4 tests / exit 1 | RED: control_bits, matches, sense_color_double_bits | 120 |
| N2444 `C07LaunchPadLaunchEffectProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2445 `C07UnitCargoLoaderDrawPlaceRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2447 `C07UnitAssemblerModuleSelectRemoveRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2448 `C07StackConveyorBlendsPlanRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2449 `C07StackRouterConfigRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2450 `C07ImpactReactorBarStatsRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2451 `C07BuildTurretWarmupStatsRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2452 `C07AcceleratorGetCursorRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2453 `C07FrackerAttributeEnvLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2455 `C07ConstructorConfigFilterRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2456 `C07ItemBridgeDrawPlaceRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2457 `C07StackConveyorSetStatsRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2458 `C07DuctRouterHandleStackRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2459 `C07WallCrafterEdgeTilesLiveFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2460 `C07PayloadMassDriverLinkConfigRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2461 `C07MassDriverLinkConfigRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2462 `C07ConstructorRecipeConfigFillProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2463 `C07LiquidBridgeLinkRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2464 `C07PayloadDeconstructorBarRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2465 `C07WallCrafterBarRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2466 `C07LaunchPadConfigDisplayRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2467 `C07ItemBridgeCheckAcceptRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2468 `C07PayloadMassDriverEffectsRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2469 `C07BurstDrillOffloadEffectsRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2470 `C07ShockwaveTowerWaveEffectsRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2471 `C07PayloadLoaderSuperUpdateTileRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2472 `C07StackRouterLiveProximityQueryProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2473 `C07BeamDrillMultipliersBlockedItemRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2474 `C07RadarFogRadiusRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2475 `C07RepairTurretStatusRangeRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2476 `C07BurstDrillOffloadNeighborRoutingProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2477 `C07BeamDrillDropLoopProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2478 `C07BeamDrillCanPlaceOnDrawPlaceProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2479 `C07RadarCanPickupProgressProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2480 `C07DeconstructorBreakBlockFxProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2481 `C07SolidPumpUpdateEffectChanceProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2482 `C07ForceProjectorAbsorbEffectProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2484 `C07MendProjectorHealEffectRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2485 `C07AcceleratorProgressIsCoreBuiltRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2486 `C07BurstDrillPerDefShakeEffectRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2487 `C07ForceProjectorShieldConsumerAbsorbFxProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2488 `C07PayloadMassDriverSuperUpdateTileRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2489 `C07RepairTurretPerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2490 `C07RepairTowerPerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2492 `C07ShockwaveTowerPerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2493 `C07ItemBridgePerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2494 `C07LiquidBridgePerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2495 `C07StackConveyorPerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2496 `C07StackRouterPerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2497 `C07ImpactReactorPerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
| N2498 `C07AcceleratorPerDefStatRowsProof` | 4 tests / exit 0 | GREEN 9/9 | 120 |
