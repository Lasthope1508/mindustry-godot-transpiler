# N1160 Turret Get Regions To Outline Finalization

## Totals

| Metric | Count |
| --- | ---: |
| Total N1160 tasks | 7 |
| Done | 7 |
| Not done | 0 |

## Done

- [x] Read exact upstream `Turret.getRegionsToOutline(Seq<TextureRegion> out)`.
- [x] Confirm existing source helper and generated `Turret.java_method_getRegionsToOutline_7` bridge are source-backed.
- [x] Add RED status assertions for canonical ledger, `defense_slices`, and `source_slice_ledger_slices`.
- [x] Mark N1160 `status` as `done` in canonical ledger and mirrors.
- [x] Run focused source, emitter, playable, and source-parity tests.
- [x] Prove runtime behavior through Godot MCP on `/root/Main`.
- [x] Run full Python suite.

## Not Done

- None for this slice.

## Evidence

- RED: `test_generated_turret_get_regions_to_outline_slice_is_registered_with_source_backing` failed because N1160 status was `active`, expected `done`.
- Focused tests: `5 passed`.
- SSOT: `module_count=112`, `errors=[]`, `defense_slices` mirror checked `137`, `source_slice_ledger_slices` mirror checked `1073`.
- Godot MCP runtime:
  - `generated_turret_get_regions_to_outline_bridge_state(out)` returned `matches=true`, `drawer_get_regions_to_outline_called=true`, and `drawer_get_regions_to_outline_expr="drawer.getRegionsToOutline(this, out);"`.
  - `source_turret_get_regions_to_outline_state(out)` returned the same `out` and `drawer_get_regions_to_outline_call`.
  - `source_slice_ledger_state("N1160")` and `ssot_slice_ledger_state("N1160")` returned `status=done`.
- Godot debug: `errors=[]`, final `finalErrors=[]`.
- Full suite: `4017 passed, 39290 subtests passed`.
- Ledger after slice: `1073 total`, `857 done`, `216 not done`, `79.87%`; next unfinished slice is `N1161`.
