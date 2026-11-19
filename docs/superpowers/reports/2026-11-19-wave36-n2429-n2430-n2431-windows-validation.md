# Wave36 batch10: N2429, N2430, N2431 GREEN

Tested integration/wave-advances-36-n2499-n2505 at `e64d277ce2c59cda828c49a820e7878fda6cb406` on isolated branch `codex/godot-wave36-batch10-validation`. Explicitly fetched main and integration wave refs; wave36 unchanged. Selection main: `d2d8b6b4aaa2f3fd18ed5df6d67d8b7be05b3b64`. Exact-SHA GOAL and all three slice reports/handoffs identify these scenes as never run; no matching passing reports on main or local checkpoint coverage. Later integration BuildTurret icons addition N2446 is included in this tested snapshot.

| Slice / scene | Targeted tests | Native MCP assertions | Warnings |
| --- | --- | --- | --- |
| N2429 `C07ItemBridgeDrawRowsProof` | 4/4 (40.746s) | 9/9 true | 120 |
| N2430 `C07ImpactReactorDrawRowsProof` | 4/4 (22.019s) | 9/9 true | 120 |
| N2431 `C07BuildTurretDrawRowsProof` | 4/4 (22.225s) | 9/9 true | 120 |

Commands ran sequentially from `C:/Users/Admin/.codex/worktrees/godot-integration-validation/tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_item_bridge_draw_rows -v
python -m unittest tests.test_c07_impact_reactor_draw_rows -v
python -m unittest tests.test_c07_build_turret_draw_rows -v
```

Each targeted module launched its existing actual headless proof. Each scene additionally ran through native Godot MCP (without headless mode), project `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`, Windows Godot `4.6.2.stable.official.71f334935`. TCP7777 checked before launches. Inspected native diagnostics and stopped only the owned projects. Zero runtime/parser errors; warnings retained in raw evidence. [Evidence](evidence/2026-11-19-wave36-batch10/) contains the six captures/logs.

Coverage: ItemBridge warmup, linked/unlinked draw/arrows/pulse and selection/configuration descriptors; ImpactReactor bottom/plasma/base/light descriptors including cold/time-peak cases; BuildTurret shadow/glow/build-call/rotation/elevation descriptors. Existing pure draw assertions only, not full rendered presentation. No full gate or overall backlog clearance claimed.

No initial failures, fixture repairs, behavior/assertion changes, gameplay/SSOT/ledger/PortGame changes. Seven report/evidence additions only, published on a separate main-based report branch. No integration/migration ancestry merged. Existing actual Linux/Windows passes accepted and prior unchanged RED failures preserved.
