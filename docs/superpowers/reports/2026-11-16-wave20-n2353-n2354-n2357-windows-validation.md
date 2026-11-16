# Wave20 Windows Godot validation: two GREEN, one pending RED

N2354 Accelerator launch drain and N2357 PayloadMassDriver large variant pass actual Windows Godot 4.6.2 native MCP proofs. N2357 requires the fixture-only commit below. N2353 Separator neighbor write-back remains RED and is not certified GREEN. No gameplay or SSOT implementation changed.

## Snapshots and coverage

- Integration: `integration/wave-advances-20-n2377-n2383`, SHA `d35c67781e015aa4eac62fdffcb5456fd29761a5`, containing wave19 and pushed `slice/N2323-ucl-n2234-proof-fix` ancestry.
- Main baseline: `343e9865c93db8630b4a9f75effd1b61009c3c69`. Its N2210 Units.nearby live query already has detailed actual Linux 4.6.2 GREEN evidence in `2026-11-16-c07-units-nearby-live-query.md` (targeted 4/4, postcommit 4/4, family 24/24). Accepted without repeating Windows.
- N2357 fixture commit: `33f6af53bfa158d7bda16ce71425e0c3044e27d6`, pushed separately on `codex/godot-wave20-batch-validation`. This integration-based branch must not be merged into main as a report PR; integration ownership must adopt just the fixture repair.
- Validation project: `C:/Users/Admin/.codex/worktrees/godot-integration-validation/godot-mindustry`.

| Slice / scene | Targeted unittest | Actual native MCP |
| --- | --- | --- |
| N2354 `C07AcceleratorLaunchDrainProof` | 4/4, 5.322s | 8/8 keys true, matches true, 46 warnings |
| N2357 `C07PayloadMassDriverLargeVariantProof` | Initial 4 tests / 1 failure, 13.889s (parse error); syntax-only rerun 4 tests / 1 failure, 21.043s; final 4/4, 21.468s | Final 8/8 keys true, matches true, 109 warnings |
| N2353 `C07SeparatorNeighbourWriteBackProof` | 4 tests / 1 failure, 21.730s | 2 semantic keys false, matches false; pending RED |

Commands run sequentially from `tools/mindustry_godot_transpiler`:

```text
python -m unittest tests.test_c07_separator_neighbour_write_back -v
python -m unittest tests.test_c07_accelerator_launch_drain -v
python -m unittest tests.test_c07_payload_mass_driver_large_variant -v
```

TCP 7777 was checked before each engine launch. Native runs were captured through Godot MCP, debug output inspected, and only owned instances stopped. All native captures have zero runtime/parser errors; existing GDScript warnings are reported separately. The original N2357 targeted run did have a parser error. Targeted checks exercise the pure/reference, registration and actual engine cases; final passing count is 8/8 across the two GREEN modules. No full gate was run or claimed.

## N2357 minimal fixture repair

The original fixture calls Object.get with two arguments; Godot accepts one. Removed only the invalid default argument from `game.get("tile_size", -1.0)`, retaining the comparison against 32.0 and every other assertion and expected value.

The next run parsed but failed the live-link key. Native diagnostics showed the source large driver had team 1 while its target had team 0, because map tiles supplied different teams; the same-team link guard correctly left both idle. The fixture now stamps all four driver sprites with the existing canonical team metadata key and derelict team 0 before ticking. Both intended large links enter shooting, while the small pair at 100 cells remains outside its 700-unit range. Payload size boundaries, charge, reload, positions, links and assertions remain unchanged. Rerunning the entire module checks both variants and pure/live paths. Final native pass uses exactly the committed fixture; temporary diagnostics were removed before the pass.

## N2353 unresolved RED

`advance_exposes_routed_neighbour_index` and `live_tick_writes_offloaded_item_to_neighbour_frame` are false. Native diagnostics show seed 1 selects lead, while the proof pins titanium and a final seed of 2. The routing index and cursor themselves are correct (pure index 1/cdump 2; live cdump 3), but the full-store case holds titanium while the generated lead is routed, and the live neighbor frame ends with an empty items dictionary. These observations require owner diagnosis of the random-selection expectation and live write-back persistence. They do not establish which implementation should change. Assertions and runtime code were left unchanged; no Separator repair or GREEN claim is published. Temporary diagnostic output is retained only in the raw RED capture, not committed in the fixture.

## Evidence and remaining work

Raw initial RED, intermediate and final targeted logs and native captures are in [evidence](evidence/2026-11-16-wave20-batch/). GREEN is conditional on the N2357 fixture commit; original wave20 PMD is still RED until adoption. Prior fixture adoption requirements for N2328, N2344, N2351 and N2352 remain tracked separately.

Wave20 reports 176 missing proofs plus 25 reruns, and 30 Windows-track entries already Linux GREEN. These are migration-reported baseline counts, not a reconciled remaining balance after validation batches. Main being unchanged would not clear integration debt. Continue by checking newer pushed integration waves and their reports, matching scene and implementation/dependency hashes, skipping credible matching Linux/Windows passes. This report-only change adds no migration ancestry, gameplay, ledger, SSOT, project settings or PortGame edits to main.
