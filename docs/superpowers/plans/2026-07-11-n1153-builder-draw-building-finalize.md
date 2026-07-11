# N1153 Builder Draw Building Finalization

## Totals

| Metric | Count |
| --- | ---: |
| Total N1153 tasks | 7 |
| Done | 7 |
| Not done | 0 |

## Done

- [x] Read exact upstream `BuilderComp.drawBuilding()`.
- [x] Confirm existing source helper and generated `BuilderComp.java_method_drawBuilding_15` bridge are source-backed.
- [x] Add RED status assertions for canonical ledger, `comp_slices`, and `source_slice_ledger_slices`.
- [x] Mark N1153 `status` as `done` in canonical ledger and mirrors.
- [x] Run focused source, emitter, playable, and source-parity tests.
- [x] Prove runtime behavior through Godot MCP on `/root/Main`.
- [x] Run full Python suite.

## Not Done

- None for this slice.

## Evidence

- RED: `test_generated_builder_comp_draw_building_slice_is_registered_with_source_backing` failed because N1153 status was `active`, expected `done`.
- Focused tests: `5 passed`.
- SSOT: `module_count=112`, `errors=[]`, `comp_slices` mirror checked `430`, `source_slice_ledger_slices` mirror checked `1073`.
- Godot MCP runtime:
  - `generated_builder_comp_draw_building_bridge_state(..., active=false, last_active=null)` returned `matches=true` and `inactive_without_last_active=true`.
  - Outside-range case returned `matches=true`, `outside_range_blocked=true`, and no draw calls.
  - Remote plan + beam case returned `matches=true`, `remote_plan_draw=true`, non-null `draw_plan_call`, `draw_plan_top_call`, and `draw_building_beam_call`.
  - `source_slice_ledger_state("N1153")` and `ssot_slice_ledger_state("N1153")` returned `status=done`.
- Godot debug: `errors=[]`, final `finalErrors=[]`.
- Full suite: `4017 passed, 39290 subtests passed`.
- Ledger after slice: `1073 total`, `850 done`, `223 not done`, `79.22%`; next unfinished slice is `N1154`.
