# Wave26 Godot validation: MassDriver GREEN, two proofs pending RED

N2369 MassDriver dump write-back passes Windows Godot 4.6.2 stable targeted tests and native MCP. N2363 BeamDrill and N2368 PayloadDeconstructor run successfully through the engine but fail semantic assertions. This batch publishes evidence only, with no runtime, fixture or assertion edits.

## Snapshot and results

- Integration: `integration/wave-advances-26-n2425-n2431`, SHA `91ee0f1dc97fc7e10ae9157289ea00ea09c1f02d`, containing wave24 and wave25. The duplicate-local parse correction is present: BeamDrill uses `dump_filled`, Fracker uses `fraction_filled` and `dump_filled`. The old wave24 snapshot remains distinct; its prior failure is not retroactively GREEN.
- Main baseline: `da7eb743f96c555e93bbb6e73ba5f977bf5cf92a`, unchanged since PR11. Integration advanced despite unchanged main.
- N2323 UCL proof file still matches the pushed fix branch exactly, including nitrogen seeding. Matching file content establishes inclusion, without requiring the original commit ancestry.
- Project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

| Proof | Targeted unittest | Native MCP |
| --- | --- | --- |
| N2369 `C07MassDriverDumpWriteBackProof` | 4/4, 21.547s | 6/6 keys true, matches true |
| N2363 `C07BeamDrillTimerDumpWriteBackProof` | 4 tests / 1 failure, 21.955s | Live neighbor write-back key false, matches false |
| N2368 `C07PayloadDeconstructorDumpWriteBackProof` | 4 tests / 1 failure, 21.871s | Both live keys false, matches false |

Commands ran sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_beam_drill_timer_dump_write_back -v
python -m unittest tests.test_c07_payload_deconstructor_dump_write_back -v
python -m unittest tests.test_c07_mass_driver_dump_write_back -v
```

The passing MassDriver module covers exact source evidence, registration, pure state/reference behavior and actual engine proof, including both neighbor delivery and frameless routing. All three native captures have zero runtime/parser errors, with existing GDScript warnings counted in raw evidence. Port7777 was checked before each engine launch; debug output inspected and only owned instances stopped. No full gate was run or claimed.

## Unresolved failures

N2363 passes the pure advance key and `live_tick_dumped_item_leaves_drill_without_frame`, but fails `live_tick_writes_dumped_item_to_neighbour_frame`. N2368 passes `advance_exposes_dump_deliveries` but fails both `live_tick_writes_dumped_item_to_neighbour_frame` and `live_tick_dumped_item_leaves_deconstructor_without_frame`. The conjunction results alone do not establish which runtime value is wrong. Both remain RED for owner diagnosis; no assertions were weakened and no GREEN certification is made for them.

Earlier N2353, N2360 and N2361 RED results remain tracked separately. Separator implementation changed in later waves, so its earlier observations must be evaluated against current behavior before a future rerun; this batch does not recertify it. Existing fixture adoption requirements remain conditional on their exact tested commits.

## Evidence and remaining queue

Targeted logs and all three native captures are in [evidence](evidence/2026-11-16-wave26-batch/). The report PR is based on main and adds only report/evidence files; it merges no integration ancestry, gameplay, SSOT, ledger, PortGame, project settings or import/UID noise.

Wave26 reports216 missing proofs plus26 reruns and30 Windows-track entries already Linux GREEN. These are migration-reported baseline counts, not independently reconciled remaining debt after our validation batches. Keep tracking main and all pushed integration branches separately, skip credible matching actual Linux/Windows evidence and select only remaining proofs or reruns justified by relevant implementation changes.
