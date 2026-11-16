# Windows Godot validation: wave16 N2344–N2346

Three selected integration proofs pass on Windows Godot 4.6.2 stable, both targeted engine tests and native MCP scenes. N2344 requires the fixture repair described below; the original snapshot remains RED for that scene. This is a validation report, not a merge of migration implementation into main.

## Snapshot and results

- Integration: `integration/wave-advances-16-n2344-n2350`, SHA `9282b27a74f44d4cf3059808c328aa0dca46d302`, containing wave15 and the N2323 UCL fixture fix.
- Report baseline: main `3119d2573c07833ef8ca9230f291275590f8cab9`.
- Validation worktree/project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`, isolated branch `codex/godot-wave16-validation-20261116`.
- Fixture commit: `268ff421505cf7d5cf83e578a2e3a7b8092e6d67` (pushed separately; the scene is absent from main, so do not merge this integration-based branch into main).

| Slice / scene | Targeted unittest | Native MCP proof |
| --- | --- | --- |
| N2344 `C07RegenProjectorPrivilegedFlagFillProof` | RED 4 tests, 1 failure, 21.389s; repaired 4/4 in 21.168s | 6/6 total keys true |
| N2345 `C07UnitAssemblerModuleCanPlaceOnProof` | 4/4 in 21.085s | 7/7 total keys true |
| N2346 `C07BeamDrillLaserOriginsProof` | 4/4 in 21.288s | 9/9 total keys true |

Commands, sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_regen_projector_privileged_flag_fill -v
python -m unittest tests.test_c07_unit_assembler_module_can_place_on -v
python -m unittest tests.test_c07_beam_drill_laser_origins -v
```

Each module's actual engine test requires exit 0, no `ERROR:`, matches true and all semantic keys true. Each scene was additionally launched through native Godot MCP, debug output inspected, and only our instance stopped. TCP 7777 was checked before each engine launch. No runtime/parser errors were present in the passing captures; existing project warnings remain and are retained. N2345 validates the pure placement gate, including link-refresh composition; it does not validate a live placement call site, which the migration handoff still defers.

## N2344 RED and fixture-only repair

Initial runtime result: `live_tick_excludes_privileged:false`, `matches:false`, while both pure privileged keys passed. A temporary diagnostic print (removed before final runs/commit) showed the placed copper-wall's maximum health was `-1`; attempted damage therefore could not establish the damaged control, `any_targets` became false and the following tick had efficiency 0. This was an invalid fixture precondition, not evidence that the privileged exclusion passed or failed.

The proof now seeds only its in-memory catalog health for two selected definitions before placement: copper-wall 320 (`Blocks.java:1704/1708`, 80 * 4), world-processor 40 (size 1 and empty requirements in `Blocks.java:6948–6959`, default-health initialization in `Block.java:1378–1394`). This models source-initialized health without changing the catalog on disk, runtime implementation, SSOT, ledger, PortGame, gameplay or any other proof. Both damaged walls share the copper-wall entry. All original assertions, health ratios, target positions, scan logic and privilege inputs remain unchanged.

The complete N2344 module passes after repair. Since the repair is local to this scene's catalog instance, it does not change neighboring scenes; no neighboring implementation was modified. General catalog health initialization remains outside this validation scope. Unmodified wave16 still needs the fixture commit to reproduce N2344 GREEN.

## Evidence and limits

Raw native debug captures, targeted RED/GREEN logs and the temporary RED diagnostic capture are in [evidence](evidence/2026-11-16-wave16-windows/). Diagnostic output identifies itself as such; final native output contains no diagnostic instrumentation.

Main N2206 LaunchPad sense(progress) already has detailed Linux Godot 4.6.2 evidence at the main baseline: targeted 4/4, post-rebase 4/4, matches true, zero false, exit0/no-ERROR assertions in its test. It is accepted without another Windows run.

No full gate was run or claimed here. Wave16 reports 151 proofs plus 20 reruns and 30 Windows-track entries already Linux GREEN. These are migration-reported baseline counts, not reconciled remaining debt after our batches. N2347–N2350 and older unvalidated proofs/reruns remain queued. Prior wave15 coverage and its separately pushed BaseShield fixture commit remain tracked independently by scene and implementation; slice numbers alone cannot transfer coverage across main and integration.
