# Wave22 Windows Godot validation: N2356, N2358, N2359

Three selected proofs pass Windows Godot 4.6.2 stable native MCP: 12/12 final targeted tests and all native proof keys true. N2359 requires a minimal fixture repair; original wave22 remains RED for that scene until adoption. No gameplay implementation changed.

## Snapshots and results

- Integration: `integration/wave-advances-22-n2394-n2400`, SHA `49af8435b64dcffa9b3a74bbbdbd326c840f36bc`, containing wave21 and wave20 by ancestry.
- Main baseline: `92cf1f808b33ca98579f56ae71b49a4ed85d3dd5`. New N2211 RepairTower nearby driver has credible actual Linux 4.6.2 proof evidence in `2026-11-16-c07-repair-tower-nearby-driver.md`: targeted 4/4 (15.470s; rerun 17.066s), family 20/20, wiring 32/32, nine proof keys true and zero false. Accepted without repeating Windows despite its missing-engine full gate and Windows debt label.
- N2323 UCL fixture comparison: `C07UnitCargoLoaderUpdateTileProof.gd` is byte-identical to the pushed `slice/N2323-ucl-n2234-proof-fix` scene. The original fix commit is not itself an ancestor; inclusion is established by matching file content, not ancestry.
- N2359 fixture-only commit: `4c84698a323f4449a732758cb63365cc75564c41`, pushed on `codex/godot-wave22-batch-validation`. This branch has integration ancestry and must not be merged to main as a report PR. Adopt only the selected fixture repair on the integration track.
- Actual project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

| Slice / scene | Targeted tests | Native MCP result |
| --- | --- | --- |
| N2356 `C07ShockwaveTowerDrawRowsProof` | 4/4, 21.708s | 9/9 keys true; 111 warnings |
| N2358 `C07UnitAssemblerModuleGetLinkDiscoveryProof` | 4/4, 21.600s | 17/17 keys true; 111 warnings |
| N2359 `C07FactoryBatteryEnabledStampProof` | Initial 4 tests / 1 failure, 8.518s; repaired 4/4, 8.616s | Initial matches false; final 10/10 keys true; 66 warnings |

Sequential commands from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_shockwave_tower_draw_rows -v
python -m unittest tests.test_c07_unit_assembler_module_get_link_discovery -v
python -m unittest tests.test_c07_factory_battery_enabled_stamp -v
```

Native MCP captures all report zero runtime/parser errors. Existing GDScript warnings remain and are counted above. TCP 7777 was checked before each engine launch; native debug output was inspected and only owned instances stopped. No full gate was run or claimed. Proof assertions in all three scenes are byte-identical to the integration snapshot.

## N2359 RED and fixture repair

The fake catalog used snake-case keys (`has_power`, `outputs_power`, `consumes_power`, `power_buffered`, `power_usage`, `power_capacity`) while `SourceBuildingPowerSourceTextState` defines the runtime catalog keys as `hasPower`, `outputsPower`, `consumesPower`, `powerBuffered`, `powerUsage`, `powerCapacity`. `block_power_role_state` therefore saw the defaults and did not form the intended graph; eight semantic assertions failed, with only the disabled battery remaining untouched passing.

The repair renames only those six keys in each of three fake catalog entries. It preserves every numeric/boolean value, enabled/disabled setup, one-shot launch request, cheat branch, assertion and expected result. Rerunning the whole module verifies mixed enabled/disabled batteries, the all-enabled control and cheat-return path. Native GREEN uses the exact committed fixture. Runtime code, SSOT, ledger, PortGame, import/UID noise and project settings were untouched.

## Evidence and pending work

Initial targeted/native RED and final targeted/native captures are in [evidence](evidence/2026-11-16-wave22-batch/). This report PR contains only report/evidence files; the fixture commit is separate because its scene is absent from the main baseline. N2355 is a cite-only sweep with no new proof, so it was not counted as missing runtime coverage.

N2353 Separator remains pending from the previous batch: no relevant random-selection or offload write-back correction was found in the wave21/22 changes, so the same known RED was not repeated this hour. New Separator sense/canDump pures do not resolve the observed seed/item and neighbor persistence failures. Earlier fixture adoption requirements remain conditional on their recorded commits; this batch does not certify unmodified versions GREEN.

Wave22 reports 190 missing proofs plus 25 reruns, with 30 Windows-track entries already Linux GREEN. These are migration-reported baseline counts, not a reconciled remaining balance after our validation batches. Continue auditing pushed integration branches even when main has no migration changes; skip credible matching Linux/Windows evidence and run only the remaining proof queue.
