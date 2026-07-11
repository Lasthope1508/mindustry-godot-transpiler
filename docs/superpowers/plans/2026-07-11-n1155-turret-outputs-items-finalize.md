# N1155 Turret Outputs Items Finalization

## Totals

| Metric | Count |
| --- | ---: |
| Total N1155 tasks | 7 |
| Done | 7 |
| Not done | 0 |

## Done

- [x] Read exact upstream `Turret.outputsItems()`.
- [x] Confirm existing source helper and generated `Turret.java_method_outputsItems_0` bridge are source-backed.
- [x] Add RED status assertions for canonical ledger, `defense_slices`, and `source_slice_ledger_slices`.
- [x] Mark N1155 `status` as `done` in canonical ledger and mirrors.
- [x] Run focused source, emitter, playable, and source-parity tests.
- [x] Prove runtime behavior through Godot MCP on `/root/Main`.
- [x] Run full Python suite.

## Not Done

- None for this slice.

## Evidence

- RED: `test_generated_turret_outputs_items_slice_is_registered_with_source_backing` failed because N1155 status was `active`, expected `done`.
- Focused tests: `5 passed`.
- SSOT: `module_count=112`, `errors=[]`, `defense_slices` mirror checked `137`, `source_slice_ledger_slices` mirror checked `1073`.
- Godot MCP runtime:
  - `generated_turret_outputs_items_bridge_state()` returned `matches=true` and `outputs_items=false`.
  - `source_turret_outputs_items_state()` returned `outputs_items=false` and `return_expr="return false;"`.
  - `source_slice_ledger_state("N1155")` and `ssot_slice_ledger_state("N1155")` returned `status=done`.
- Godot debug: `errors=[]`, final `finalErrors=[]`.
- Full suite: `4017 passed, 39290 subtests passed`.
- Ledger after slice: `1073 total`, `852 done`, `221 not done`, `79.40%`; next unfinished slice is `N1156`.
