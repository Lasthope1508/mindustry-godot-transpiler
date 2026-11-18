# Wave36 batch9: N2426 GREEN; N2427 GREEN; N2428 GREEN

Tested `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch9-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `1b08e5ff556c22c3d5a88f55ec3892a75b8df8cb`. Main and integration wave refs explicitly fetched; integration unchanged; main added N2243. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, selected slice reports and handoffs describe these proofs as never run. No matching prior passing engine validation found. N2323 UCL UpdateTile fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches its pushed fix branch; no fixture transplant needed.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2426 `C07WallCrafterDrawRowsProof` | 4/4, 21.386s | 9/9 true, matches true |
| N2427 `C07RadarDrawRowsProof` | 4/4, 21.454s | 9/9 true, matches true |
| N2428 `C07RepairTowerDrawRowsProof` | 4/4, 21.72s | 9/9 true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_wall_crafter_draw_rows -v
python -m unittest tests.test_c07_radar_draw_rows -v
python -m unittest tests.test_c07_repair_tower_draw_rows -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors. Warning counts: N2426 120, N2427 120, N2428 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-18-wave36-batch9/) contains all three targeted logs and native captures. No full gate claimed.

These proofs cover WallCrafter draw/rotators/plan/place/icons, Radar glow/rotation/select/place/icons, and RepairTower draw/stats/accessor descriptors on the integration implementation. They verify current pure function assertions, not full rendered UI output. Main RepairTower Linux passes cover a different implementation and do not replace this integration proof.

All three selected proofs pass. Previous unrelated REDs remain pending.

Main N2243 spawn-side team stamp was inspected separately. Its detailed [Linux report](2026-11-18-c07-point-defense-turret-spawn-team-stamp.md) records targeted4/4, family24/24, wiring32/32 and actual native-engine semantics under headless Linux Godot4.6.2: nine JSON keys with matches:true, zero engine errors. Accepted without Windows repetition. This manual validation run leaves the hourly schedule paused.

Seven report/evidence additions only. No gameplay, SSOT, ledger, PortGame, fixture or assertion changes. Dirty imports/UID/project settings preserved. Existing actual Linux/Windows passes accepted; unchanged REDs, including N2407, not rerun. This batch does not clear the integration backlog.
