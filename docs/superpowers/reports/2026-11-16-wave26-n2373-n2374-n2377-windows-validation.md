# Wave26: Accelerator and LightBlock GREEN; SolidPump neighbour proof RED

N2373 Accelerator draw rows and N2374 LightBlock draw rows pass targeted tests and native Godot MCP on Windows Godot 4.6.2 stable. N2377 SolidPump liquid dump has one failing semantic key. No runtime, fixture or assertion changes were made.

## Snapshot and results

- Integration: `integration/wave-advances-26-n2425-n2431`, tested SHA `91ee0f1dc97fc7e10ae9157289ea00ea09c1f02d`; isolated branch `codex/godot-wave26-batch3-validation`.
- Main baseline: `f704a5dc1c9c644fd90bdd223837603d34618177`. Main and latest integration were unchanged at selection; this does not imply the integration backlog is empty.
- Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.
- GOAL, reports and handoffs at the tested SHA identify these three scenes as never run. N2323 UCL proof content matches its pushed fixture fix exactly; no original-commit ancestry claim.

| Slice / scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2373 `C07AcceleratorDrawRowsProof` | 4/4, 21.633s | 9/9 total keys true, matches true |
| N2374 `C07LightBlockDrawRowsProof` | 4/4, 21.228s | 9/9 total keys true, matches true |
| N2377 `C07SolidPumpDumpLiquidWriteBackProof` | 4 tests, 1 failure, 21.329s | Neighbour write-back key false, matches false |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_accelerator_draw_rows -v
python -m unittest tests.test_c07_light_block_draw_rows -v
python -m unittest tests.test_c07_solid_pump_dump_liquid_write_back -v
```

Each scene also ran through native Godot MCP without headless mode. Captures show engine `4.6.2.stable.official.71f334935`, zero runtime/parser errors and 113 existing warnings per scene. TCP7777 was checked before every engine launch; debug output inspected and owned projects stopped. [Raw evidence](evidence/2026-11-16-wave26-batch3/) contains targeted logs and native captures. No full gate is claimed.

## N2377 remains RED

`advance_exposes_dump_neighbour_index` and `live_tick_dumped_liquid_leaves_pump_without_frame` are true. `live_tick_writes_dumped_liquid_to_neighbour_frame` is false in both targeted and native runs. This key combines neighbour position, efficiency, source water, cursor and recipient water checks; the false conjunction alone does not identify which value is wrong. Owner diagnosis is required. No assertion was weakened and no GREEN claim is made for N2377.

Only report/evidence additions are published on a main-based branch; no migration ancestry, gameplay, shared SSOT, ledger, PortGame, project settings or import/UID noise is merged. Previous REDs and conditional fixture adoption requirements remain tracked separately. Matching actual Linux/Windows passes were not repeated. Wave26's reported 216 missing proofs plus 26 reruns are migration baseline counts, not independently reconciled remaining debt; the 30 Windows-track proofs already Linux GREEN remain excluded.
