# Wave26: MendProjector sense and Unloader item GREEN; UAM live scan RED

N2383 MendProjector sense rows and N2386 PayloadUnloader item dump write-back pass targeted tests and native Godot MCP on Windows Godot 4.6.2. N2381 UnitAssemblerModule flagged-buildings fill has three failing live keys. No runtime, fixture or assertion changes were made.

## Snapshot and results

Tested integration `integration/wave-advances-26-n2425-n2431` at `91ee0f1dc97fc7e10ae9157289ea00ea09c1f02d`, isolated branch `codex/godot-wave26-batch5-validation`. Main baseline `bd47fc2ff252df7d05fd82f448353a4bf61f1279`. Main and latest integration were unchanged at selection; this does not imply the remaining backlog is empty. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

GOAL and selected reports/handoffs at this snapshot identify all three as never run on Godot; no matching previous actual passing evidence was found. N2323 UCL scene still exactly matches pushed fixture-fix content (blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5`, content inclusion, not original commit ancestry).

| Slice / scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2381 `C07UnitAssemblerModuleFlaggedBuildingsFillProof` | 4 tests, 1 failure, 39.475s | 3 semantic keys false, matches false |
| N2383 `C07MendProjectorSenseRowsProof` | 4/4, 21.149s | 9/9 total keys true, matches true |
| N2386 `C07PayloadUnloaderDumpItemWriteBackProof` | 4/4, 21.315s | 6/6 total keys true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_unit_assembler_module_flagged_buildings_fill -v
python -m unittest tests.test_c07_mend_projector_sense_rows -v
python -m unittest tests.test_c07_payload_unloader_dump_item_write_back -v
```

Each scene also ran through native Godot MCP without headless mode. Engine output: `4.6.2.stable.official.71f334935`. Each capture has zero runtime/parser errors and 113 existing warnings. TCP7777 was checked before every engine launch, debug output inspected, and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave26-batch5/) contains all targeted logs and native captures. No full gate is claimed.

## N2381 remains RED

False keys in both targeted and native runs: `live_tick_fills_two_candidates`, `live_tick_no_fit_null`, `live_tick_refresh_adds_assembler`. The six pure scan keys and the live no-assembler, discovery-fit, supplied-candidates and seeded-candidate keys pass. These combined assertions alone do not identify the underlying wrong runtime values. Owner diagnosis is required; no assertion was weakened and no GREEN certification is made for N2381.

This batch publishes only report/evidence additions on a main-based branch. No migration ancestry, gameplay, shared SSOT, ledger, PortGame, project settings or import/UID noise is merged. Earlier REDs, including N2378/N2379/N2380 from the preceding all-RED audit, remain pending with local raw evidence; no implementation corrections are implied. Previous fixture adoption requirements remain conditional on their tested commits.

Matching actual Linux/Windows passes and unchanged REDs were not repeated. Wave26's 216 missing proofs plus26 reruns are migration-reported baseline counts, not independently reconciled remaining debt;30 Windows-track proofs already Linux GREEN are excluded from repeat work.
