# Wave36 batch7: N2419 GREEN; N2420 GREEN; N2421 GREEN

Tested `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch7-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `cf100fd1cd75395075bc16dd7dd482b0a6869e30`. Main and integration wave refs explicitly fetched; integration unchanged since batch6; main added N2231. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, selected slice reports and handoffs describe these proofs as never run. No matching prior passing engine validation found. N2323 UCL UpdateTile fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches its pushed fix branch; no fixture transplant needed.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2419 `C07SeparatorDrawRowsProof` | 4/4, 21.806s | 12/12 true, matches true |
| N2420 `C07LaunchPadDrawRowsProof` | 4/4, 21.765s | 9/9 true, matches true |
| N2421 `C07RepairTurretDrawRowsProof` | 4/4, 21.612s | 9/9 true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_separator_draw_rows -v
python -m unittest tests.test_c07_launch_pad_draw_rows -v
python -m unittest tests.test_c07_repair_turret_draw_rows -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors. Warning counts: N2419 120, N2420 120, N2421 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave36-batch7/) contains all three targeted logs and native captures. No full gate claimed.

These proofs cover current pure presentation rows for Separator drawer composition/light/icons/plan, LaunchPad liquid/light/shadow/pod/icons and RepairTurret beam/draw/select/place/icons. They verify returned values and call descriptors, not full rendered UI output. RepairTurret random rolls are caller-supplied inputs; passing these rows does not resolve earlier runtime REDs such as Separator N2402.

All three selected proofs pass. Previous unrelated REDs remain pending.

Main delta cf100fd1 adds N2231 RepairTower drawSelect/drawPlace, its SSOT/test/proof and documentation. Detailed Linux Godot4.6.2 report records targeted4/4 16.628s, family32/32, wiring32/32,12 JSON keys with matches true and zero errors. Accepted without Windows repetition; pure UI delta does not alter selected integration snapshot. See [N2231 report](2026-11-17-c07-repair-tower-draw-select-place.md).

Seven report/evidence additions only. No gameplay, SSOT, ledger, PortGame, fixture or assertion changes. Dirty imports/UID/project settings preserved. Existing actual Linux/Windows passes accepted; unchanged REDs, including N2407, not rerun. This batch does not clear the integration backlog.
