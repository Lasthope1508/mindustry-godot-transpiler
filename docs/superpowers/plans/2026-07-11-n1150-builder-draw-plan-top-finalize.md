# N1150 Builder Draw Plan Top Finalization

## Totals

| Metric | Count |
| --- | ---: |
| Total N1150 tasks | 7 |
| Done | 7 |
| Not done | 0 |

## Done

- [x] Read exact upstream `BuilderComp.drawPlanTop(BuildPlan plan, float alpha)`.
- [x] Confirm existing source helper and generated `BuilderComp.java_method_drawPlanTop_6` bridge are source-backed.
- [x] Add RED status assertions for canonical ledger, `comp_slices`, and `source_slice_ledger_slices`.
- [x] Mark N1150 `status` as `done` in canonical ledger and mirrors.
- [x] Run focused source, emitter, playable, and source-parity tests.
- [x] Prove runtime behavior through Godot MCP on `/root/Main`.
- [x] Run full Python suite.

## Not Done

- None for this slice.

## Evidence

- RED: `test_generated_builder_comp_draw_plan_top_slice_is_registered_with_source_backing` failed because N1150 status was `active`, expected `done`.
- Focused tests: `5 passed`.
- SSOT: `module_count=111`, `errors=[]`, `comp_slices` mirror checked `430`, `source_slice_ledger_slices` mirror checked `1073`.
- Godot MCP runtime:
  - `source_builder_draw_plan_top_state({"id":"duo"}, [{"id":"duo"}], false, 0.5, 0.28)` returned `draw_top=true`, `mixcol_alpha=0.52`.
  - `generated_builder_comp_draw_plan_top_bridge_state(...)` returned `matches=true`, generated/canonical `draw_top=true`, `mixcol_alpha=0.52`.
  - `source_slice_ledger_state("N1150")` and `ssot_slice_ledger_state("N1150")` returned `status=done`.
- Godot debug: `errors=[]`, final `finalErrors=[]`.
- Full suite: `4015 passed, 39285 subtests passed`.
- Ledger after slice: `1073 total`, `847 done`, `226 not done`; next unfinished slice is `N1151`.
