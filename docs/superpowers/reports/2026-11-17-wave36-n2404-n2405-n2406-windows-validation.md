# Wave36 batch3: N2404 RED; N2405 RED; N2406 GREEN

Existing proofs were tested on `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch3-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `59dd100a8604d9bead886065836c88ae9a79aa60`. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, reports and handoffs list the three proofs as unrun. N2323 UCL fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches the pushed fix branch. Main and all integration wave refs were explicitly fetched. No matching prior actual pass was found for the selected proofs.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2404 `C07ItemBridgeDumpNeighbourLiveFillProof` | 3/4, 21.909s | matches false; 3 semantic false |
| N2405 `C07BeamDrillDumpNeighbourLiveFillProof` | 3/4, 21.293s | matches false; 3 semantic false |
| N2406 `C07MassDriverDumpNeighbourLiveFillProof` | 4/4, 21.313s | 9/9 true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_item_bridge_dump_neighbour_live_fill -v
python -m unittest tests.test_c07_beam_drill_dump_neighbour_live_fill -v
python -m unittest tests.test_c07_mass_driver_dump_neighbour_live_fill -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors in every completed capture. Warning counts: N2404 120, N2405 120, N2406 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave36-batch3/) includes all targeted logs and native captures. No full gate is claimed.

These proofs attempt to validate live item dump neighbour arrays, default accept/canDump gates, capacity/consumesItem gates, no-frame handling and live dump/write-back for ItemBridge, BeamDrill and MassDriver. Only GREEN rows certify the current assertions. Per-block override dispatch, per-item routing and ring dedup/team filtering remain deferred. N2404 gate-watch N2225/N2321 is not independently cleared by this batch.

N2404 remains RED: `fill_accepts_from_live_neighbour`, `fill_can_dump_from_live_neighbour`, `live_tick_dumps_with_live_fill`. Root cause unconfirmed; no assertion was weakened or speculative runtime/fixture repair applied.

N2405 remains RED: `fill_can_dump_from_live_neighbours`, `fill_no_frame_neighbour_reports_empty`, `live_tick_dumps_with_live_fill`. Root cause unconfirmed; no assertion was weakened or speculative runtime/fixture repair applied.

Main added N2224 RepairTurret setStats. Its detailed Linux Godot4.6.2 report records targeted4/4 15.865s, eleven total keys alltrue/matches, family56/56 191.297s and wiring32/32 about123.6s. Accepted without repeating Windows. The unrelated main delta was inspected.

Only this report and six evidence additions are published. No gameplay, SSOT, ledger, PortGame, fixture or assertion edits. Dirty import/UID/project settings are preserved. N2398/N2399 and previous unrelated REDs remain pending; unchanged failures were not rerun. This batch does not clear the full integration backlog or certify newer implementations of earlier proofs.
