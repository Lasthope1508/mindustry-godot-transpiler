# Wave36 batch4: N2407 RED; N2408 GREEN; N2410 GREEN

Existing proofs were tested on `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch4-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `a1aeb01209121fe669bed2fe42f7b245807ef837`. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, reports and handoffs list the three proofs as unrun. N2323 UCL fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches the pushed fix branch. Main and all integration wave refs were explicitly fetched. No matching prior actual pass was found for the selected proofs.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2407 `C07PayloadDeconstructorDumpNeighbourLiveFillProof` | 3/4, 22.076s | matches false; 1 semantic false |
| N2408 `C07FrackerDumpLiquidNeighbourLiveFillProof` | 4/4, 22.14s | 9/9 true, matches true |
| N2410 `C07PumpDumpNeighbourLiveFillProof` | 4/4, 21.949s | 9/9 true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_payload_deconstructor_dump_neighbour_live_fill -v
python -m unittest tests.test_c07_fracker_dump_liquid_neighbour_live_fill -v
python -m unittest tests.test_c07_pump_dump_neighbour_live_fill -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors in every completed capture. Warning counts: N2407 120, N2408 120, N2410 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave36-batch4/) includes all targeted logs and native captures. No full gate is claimed.

These proofs exercise live item/liquid neighbour arrays, acceptance and capacity gates, no-frame handling and live dump/write-back for PayloadDeconstructor, Fracker and MechanicalPump. Only GREEN rows certify the current assertions; the raw proof keys define their precise coverage. Previous gate-watch requirements remain separate.

N2407 remains RED: `live_tick_dumps_with_live_fill`. Root cause unconfirmed; no assertion was weakened or speculative runtime/fixture repair applied.

Main added RepairTurret draw/init/icons and RepairTower heal/ozone work. Detailed Linux reports record actual proof matches:true: draw 9 keys, init 6, icons 6, heal 11, ozone 10. These five engine passes are accepted without Windows repetition. The unrelated main delta was inspected.

Only this report and six evidence additions are published. No gameplay, SSOT, ledger, PortGame, fixture or assertion edits. Dirty import/UID/project settings are preserved. N2398/N2399 and previous unrelated REDs remain pending; unchanged failures were not rerun. This batch does not clear the full integration backlog or certify newer implementations of earlier proofs.
