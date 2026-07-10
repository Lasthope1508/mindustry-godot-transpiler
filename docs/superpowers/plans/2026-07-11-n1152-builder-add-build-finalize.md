# N1152 Builder Add Build Finalization

## Totals

| Metric | Count |
| --- | ---: |
| Total N1152 tasks | 7 |
| Done | 7 |
| Not done | 0 |

## Done

- [x] Read exact upstream `BuilderComp.addBuild(BuildPlan place, boolean tail)`.
- [x] Confirm existing source helper and generated `BuilderComp.java_method_addBuild_12` bridge are source-backed.
- [x] Add RED status assertions for canonical ledger, `comp_slices`, and `source_slice_ledger_slices`.
- [x] Mark N1152 `status` as `done` in canonical ledger and mirrors.
- [x] Run focused source, emitter, playable, and source-parity tests.
- [x] Prove runtime behavior through Godot MCP on `/root/Main`.
- [x] Run full Python suite.

## Not Done

- None for this slice.

## Evidence

- RED: `test_generated_builder_comp_add_build_slice_is_registered_with_source_backing` failed because N1152 status was `active`, expected `done`.
- Focused tests: `5 passed`.
- SSOT: `module_count=112`, `errors=[]`, `comp_slices` mirror checked `430`, `source_slice_ledger_slices` mirror checked `1073`.
- Godot MCP runtime:
  - `generated_builder_comp_add_build_bridge_state(..., can_build=false)` returned `matches=true`, `returned_early=true`, and unchanged `plans_after`.
  - Replacement + construct progress + tail add returned `matches=true`, `replace_index=0`, `removed_replace=true`, `progress_copied=true`, non-null `add_last_call`, and `place_after.progress=0.42`.
  - Front insert without replacement returned `matches=true`, `replace_index=-1`, non-null `add_first_call`, and `progress_copied=false`.
  - `source_slice_ledger_state("N1152")` and `ssot_slice_ledger_state("N1152")` returned `status=done`.
- Godot debug: `errors=[]`, final `finalErrors=[]`.
- Full suite: `4017 passed, 39290 subtests passed`.
- Ledger after slice: `1073 total`, `849 done`, `224 not done`, `79.12%`; next unfinished slice is `N1153`.
