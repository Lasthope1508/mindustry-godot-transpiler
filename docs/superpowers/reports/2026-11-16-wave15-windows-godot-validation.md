# Windows Godot validation: integration wave15

Three selected proofs passed on Windows Godot 4.6.2 stable, including native MCP launches with the runtime server on TCP 7777. This report validates an integration snapshot; it does not merge that implementation into main or claim the entire backlog is complete.

## Exact scope

- Integration branch: `integration/wave-advances-15-n2337-n2343`.
- Tested implementation: `4f31a09993f74a33976ee98ae51634fe1facfe5a`.
- Main baseline for this report: `7fac96a2073d6a1a9a309a70e6339c18149f74c7`.
- Validation fixture commit: `9690056229a0b329fbd260e7ded1f2b8a070bd04`, pushed on `codex/godot-integration-validation-20261116`. This branch contains the integration ancestry and must not be merged into main as a report PR.
- Validation project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

Slice numbers below are integration identities. Main reuses some numbers for different work; coverage must be matched by implementation and scene, never number alone.

| Integration slice / scene | Targeted unittest result | Native proof result |
| --- | --- | --- |
| N2204 Drill shouldConsume / `C07DrillShouldConsumeProof` | 4/4, 21.779s | 9/9 keys true, matches true |
| N2236 BaseShield updateTile / `C07BaseShieldUpdateTileProof` | 5/5, 22.868s; neighbor rerun 5/5, 22.240s | 9/9 keys true, matches true |
| N2328 BaseShield scans / `C07BaseShieldScansProof` | RED 4 tests, 1 failure, 21.230s; repaired 4/4, 21.301s | 9/9 keys true, matches true after fixture repair |

Commands, run sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_drill_should_consume -v
python -m unittest tests.test_c07_base_shield_update_tile -v
python -m unittest tests.test_c07_base_shield_scans -v
```

Each module includes a real engine subprocess assertion for exit status 0, no `ERROR:`, matches true and semantic keys true. Native scenes were additionally launched through Godot MCP, debug output inspected, and only our project stopped. TCP 7777 was checked before launches. Native captures contain existing project warnings (107 warning messages in the BaseShield captures), but no runtime/parser errors. Warnings are not claimed to be absent.

## RED and repair

The previous integration blocker, nonexistent GDScript `sqrtf()`, was repaired by migration N2337 using `sqrt()` on wave15. This validation agent made no gameplay change.

N2328 initially failed only `live_tick_passes_scanned_lists`: its scenario and assertions define own team 0, enemy team 1, while `record_placed_block` defaults to team 1 (`PortGame.gd` forwards that default). The minimal fixture repair passes explicit team 0 when placing the shield. All assertions, candidate positions, power values and expected repel/absorb results are unchanged. The repaired proof and BaseShield updateTile neighbor both passed. Raw targeted RED is retained alongside GREEN evidence.

The repaired fixture is absent from the current main baseline. Its commit is available for a scoped cherry-pick by the integration owner; this report-only PR deliberately adds no missing migration scene or implementation to main. The unmodified wave15 snapshot remains RED for N2328 until that fixture commit is applied.

## Evidence and remaining queue

Raw native captures and targeted logs: [evidence directory](evidence/2026-11-16-wave15-windows/). The three `*-native.json` files contain MCP output including engine version, proof dictionaries and warnings.

No full gate was run or claimed in this audit. Wave15's migration report lists 144 missing proofs plus 19 reruns and 30 Windows-track proofs already Linux GREEN; those are reported counts, not an independently reconciled remaining total after this batch. Existing actual Linux passes are accepted without Windows repetition. Continue with missing proofs and implementation-dependent reruns on the newest containing integration wave. Main N2205 LaunchPad shouldConsume already has detailed Linux 4.6.2 evidence (4/4 targeted, matches true, no false), so it requires no repeat here.
