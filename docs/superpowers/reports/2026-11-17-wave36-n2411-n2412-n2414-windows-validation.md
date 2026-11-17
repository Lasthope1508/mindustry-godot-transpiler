# Wave36 batch5: N2411 GREEN; N2412 GREEN; N2414 GREEN

Tested `integration/wave-advances-36-n2499-n2505` at `e64d277ce2c59cda828c49a820e7878fda6cb406`, isolated branch `codex/godot-wave36-batch5-validation`. Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`. Main at selection: `483f89595f7c086acced6c8d205a0792e6f686b3`. Main and integration wave refs explicitly fetched; both snapshots unchanged since batch4. Report branch is based on main; no migration ancestry or implementation is transplanted.

Exact-SHA GOAL, selected slice reports and handoffs describe these proofs as never run. No matching prior passing engine validation found. N2323 UCL UpdateTile fixture blob `cf70f15cacf250de4ab500c892ed961f6ccf0ce5` matches its pushed fix branch; no fixture transplant needed.

| Slice / native scene | Targeted tests | Native MCP |
| --- | --- | --- |
| N2411 `C07SolidPumpDumpNeighbourLiveFillProof` | 4/4, 21.892s | 9/9 true, matches true |
| N2412 `C07LiquidBridgeDodumpNeighbourLiveFillProof` | 4/4, 21.559s | 9/9 true, matches true |
| N2414 `C07FrackerLinkedTilesLiveFillProof` | 4/4, 21.892s | 9/9 true, matches true |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_solid_pump_dump_neighbour_live_fill -v
python -m unittest tests.test_c07_liquid_bridge_dodump_neighbour_live_fill -v
python -m unittest tests.test_c07_fracker_linked_tiles_live_fill -v
```

Each scene also ran natively through Godot MCP, without headless mode, Windows `4.6.2.stable.official.71f334935`. Zero runtime/parser errors. Warning counts: N2411 120, N2412 120, N2414 120. TCP7777 checked before each launch; diagnostics inspected and owned projects stopped. [Raw evidence](evidence/2026-11-17-wave36-batch5/) contains all three targeted logs and native captures. No full gate claimed.

N2411/N2412 cover their current live liquid neighbour fill assertions and dump tick, including default acceptance/capacity and no-frame probes. N2414 covers linked footprint enumeration from supplied world tile metadata and current Fracker tick assertions. Its real world-tile metadata producer remains a documented follow-through. These are current assertion passes, not certification of every later integration change or deferred dispatch/routing/geometry work.

All three selected proofs pass. Previous unrelated REDs remain pending.

Seven report/evidence additions only. No gameplay, SSOT, ledger, PortGame, fixture or assertion changes. Dirty imports/UID/project settings preserved. Existing actual Linux/Windows passes accepted; unchanged REDs, including N2407, not rerun. This batch does not clear the integration backlog.
