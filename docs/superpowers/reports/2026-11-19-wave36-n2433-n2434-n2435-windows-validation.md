# Wave36 batch11: N2433, N2434, N2435 GREEN

Tested integration/wave-advances-36-n2499-n2505 at `e64d277ce2c59cda828c49a820e7878fda6cb406` on isolated branch `codex/godot-wave36-batch11-validation`. Explicitly fetched main and integration wave refs; wave36 unchanged. Selection main: `6cfc8b8e0e2ab25be0641cef89eacc11ac6ff7f6`. Exact-SHA GOAL and all three slice reports/handoffs identify these scenes as never run; no matching passing reports on main or local checkpoint coverage.

| Slice / scene | Targeted tests | Native MCP assertions | Warnings |
| --- | --- | --- | --- |
| N2433 `C07StackRouterDrawRowsProof` | 4/4 (40.732s) | 9/9 true | 120 |
| N2434 `C07StackConveyorDrawRowsProof` | 4/4 (22.154s) | 9/9 true | 121 |
| N2435 `C07OverdriveProjectorDrawRowsProof` | 4/4 (22.068s) | 9/9 true | 120 |

Commands ran sequentially from `C:/Users/Admin/.codex/worktrees/godot-integration-validation/tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_stack_router_draw_rows -v
python -m unittest tests.test_c07_stack_conveyor_draw_rows -v
python -m unittest tests.test_c07_overdrive_projector_draw_rows -v
```

Each targeted module launched its existing actual headless proof. Each scene additionally ran through native Godot MCP (without headless mode), project `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`, Windows Godot `4.6.2.stable.official.71f334935`. TCP7777 checked before launches. Inspected native diagnostics and stopped only the owned projects. Zero runtime/parser errors; warnings retained in raw evidence. [Evidence](evidence/2026-11-19-wave36-batch11/) contains the six captures/logs.

Coverage: StackRouter cached sort/top, glow gate/alpha, selection and icons; StackConveyor cached loading/unloading, glow, stack interpolation/item size and early returns; OverdriveProjector top/ring/Lod/light/selection/placement descriptors. Existing pure draw assertions only, not full rendered presentation. No full gate or overall backlog clearance claimed.

Publication main refreshed to `a95971b827621060512b1b6074254c9adf53523b`. Inspected N2269 queued-bullets additions in SourceTurretBuildState and related registration/proof/docs: no changes to selected integration snapshot or these draw implementations. Report branch fast-forwarded to latest main before committing evidence; no behavior rerun warranted for unrelated main additions.

No initial failures, fixture repairs, behavior/assertion changes, gameplay/SSOT/ledger/PortGame changes. Seven report/evidence additions only, published on a separate main-based report branch. No integration/migration ancestry merged. Existing actual Linux/Windows passes accepted and prior unchanged RED failures preserved.
