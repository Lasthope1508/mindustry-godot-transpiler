# Windows Godot validation: N2351, N2352 and N2339 on wave19

Three selected proofs pass on Windows Godot 4.6.2 stable: 12/12 targeted tests after two isolated fixture repairs, plus three native MCP scenes. Original wave19 remains RED for N2351 and N2352 until the fixture commit is applied. No gameplay implementation was changed.

## Snapshot and results

- Integration: `integration/wave-advances-19-n2368-n2374`, implementation SHA `7b99d3d63dbb9486156af5566eb2aedc93e300ae`, containing wave18 and the N2323 UCL fixture fix.
- Fixture commit: `beb8fcb5bdc32bae75c6206a09e38e038910bd94`, pushed on `codex/godot-wave19-batch-validation`. This branch includes migration ancestry and must not be merged into main as a report PR.
- Main baseline: `b03f69bbce8f26e00a4a958839267da2645de293` (unchanged since the previous audit).
- Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

| Integration slice / scene | Targeted result | Native result |
| --- | --- | --- |
| N2351 `C07UnitAssemblerCheckTierWiringProof` | RED 4 tests / 1 failure, 21.566s; repaired 4/4, 21.294s | 14/14 keys true |
| N2352 `C07BeamDrillFacingTilesFillProof` | RED 4 tests / 1 failure, 21.503s; repaired 4/4, 21.553s | 9/9 keys true |
| N2339 `C07BeamDrillFacingScanProof` | 4/4, 21.389s; affected-neighbor rerun 4/4, 21.500s | 9/9 keys true |

Commands, sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_unit_assembler_check_tier_wiring -v
python -m unittest tests.test_c07_beam_drill_facing_tiles_fill -v
python -m unittest tests.test_c07_beam_drill_facing_scan -v
```

Actual engine tests require exit 0, no `ERROR:`, matches true and all semantic keys true. Native MCP scenes additionally ran with the runtime server on TCP 7777. Debug output was inspected and only our instances stopped; port 7777 was checked before each launch. Final captures have zero runtime/parser errors and 109 existing warning messages each. All proof assertion assignments are byte-identical to the original implementation snapshot.

## RED retained and minimal fixture repairs

**N2351:** only `helper_add_writes_frame` failed. `get_meta` returns the live Dictionary; the proof retained it as its “after add” observation, then called remove, which mutates that same frame. The assertion consequently observed the removed state twice. The repair deep-copies the after-add observation before remove. The helper, event ordering, add/remove inputs and all assertions are unchanged. The same full module rechecks its pure event cases, cell-helper cases and live two-module add/unlink wiring.

**N2352:** only `rotation_changes_ray_direction` failed; the live-tick key already passed. The north/south fixtures placed both ray origins on x=30, so both rays traversed the control tile while the assertion expected the second ray to stay empty. The repair moves only the second input origin to x=31 in those two pure cases. First-ray origins, rotation values, world tiles and expected arrays/assertions are unchanged. Horizontal, wrapped, bounds, scan-count and live-tick cases remain unchanged. N2339 was rerun as the neighboring BeamDrill proof and passes without edits.

N2366 had already migrated N2339 to world_tiles input and removed N2352's empty-world fill gate. This batch validates those current fixtures, including N2352's live tick 3 empty-world result; it does not restore the removed gate.

Both repaired scenes are absent from the main baseline. Their fixture-only commit is pushed separately for scoped adoption by the integration owner. This report-only PR adds no migration scenes, runtime code, SSOT, ledger or PortGame changes to main.

## Evidence and remaining queue

Raw initial RED logs, final targeted logs and native captures are in [evidence](evidence/2026-11-16-wave19-batch/). No full gate was run or claimed. Main was unchanged, but integration advanced; this is not a claim that the repository has no remaining proof debt.

Wave19 reports 170 proofs plus 23 reruns and 30 Windows-track entries already Linux GREEN. These are migration-reported baseline counts, not independently reconciled remaining debt after our batches. N2357's revised fixture, remaining wave17/wave18/wave19 proofs and older missing scenes remain queued. The earlier BaseShield and RegenProjector fixture commits remain separately tracked. Historical coverage must be checked against the current scene, implementation and relevant dependencies.
