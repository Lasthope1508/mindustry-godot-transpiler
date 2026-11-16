# Wave36 batch2: N2400 GREEN; N2402 RED; N2403 RED

Existing proofs were tested on `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch2-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `ac4295b00b76da7ddb7ea8f7b0fa63ceee582f5b`. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, reports and handoffs list the three proofs as unrun. N2400 includes the existing N2424 static pin correction unchanged. N2323 UCL fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches the pushed fix branch. Main and all integration wave refs were explicitly fetched. No matching prior actual pass was found for the selected proofs.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2400 `C07LaunchPadAdvancedVariantProof` | 3/3, 31.728s | 9/9 true, matches true |
| N2402 `C07SeparatorDumpNeighbourLiveFillProof` | 3/4, 21.708s | matches false; 3 semantic false |
| N2403 `C07BurstDrillDumpNeighbourLiveFillProof` | 3/4, 21.298s | matches false; 3 semantic false |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_launch_pad_advanced_variant -v
python -m unittest tests.test_c07_separator_dump_neighbour_live_fill -v
python -m unittest tests.test_c07_burst_drill_dump_neighbour_live_fill -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors in every completed capture. Warning counts: N2400 120, N2402 120, N2403 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave36-batch2/) includes all targeted logs and native captures. No full gate is claimed.

N2400 covers advanced LaunchPad catalog rows, launchTime1800 sense/advance, oil consumption, size4 hitbox and live tick stamps. Its known liquidCapacity40 supplier/store-cap discrepancy remains unresolved; these passes do not certify a capacity cap. N2402 attempts to validate Separator default accept/canDump gates and live dump neighbour fill; deferred override dispatch, per-item routing and offload fill timing are separate work. N2403 attempts to validate BurstDrill neighbour gates and live item dump to the surge-smelter, within its existing assertions and geometry.

N2402 remains RED: `fill_can_dump_from_live_neighbours`, `fill_no_frame_neighbour_reports_empty`, `live_tick_dumps_with_live_fill`. Root cause unconfirmed; no assertion was weakened or speculative runtime/fixture repair applied.

N2403 remains RED: `fill_accepts_from_live_neighbours`, `fill_can_dump_from_live_neighbours`, `live_tick_dumps_with_live_fill`. Root cause unconfirmed; no assertion was weakened or speculative runtime/fixture repair applied.

Main added N2223 RepairTurret range/rotation sense. Its detailed Linux Godot4.6.2 report records targeted4/4 14.513s, nine total keys alltrue/matches, family52/52 172.902s and wiring32/32 mainverify174.794s. Accepted without repeating Windows. The unrelated main delta was inspected.

Only this report and six evidence additions are published. No gameplay, SSOT, ledger, PortGame, fixture or assertion edits. Dirty import/UID/project settings are preserved. N2398/N2399 and previous unrelated REDs remain pending; unchanged failures were not rerun. This batch does not clear the full integration backlog or certify newer implementations of earlier proofs.
