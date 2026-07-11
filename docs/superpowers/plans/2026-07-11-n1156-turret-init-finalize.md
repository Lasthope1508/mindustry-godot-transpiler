# N1156 Turret Init Finalization

## Totals

| Metric | Count |
| --- | ---: |
| Total N1156 tasks | 7 |
| Done | 7 |
| Not done | 0 |

## Done

- [x] Read exact upstream `Turret.init()`.
- [x] Confirm existing source helper and generated `Turret.java_method_init_3` bridge are source-backed.
- [x] Add RED status assertions for canonical ledger, `defense_slices`, and `source_slice_ledger_slices`.
- [x] Mark N1156 `status` as `done` in canonical ledger and mirrors.
- [x] Run focused source, emitter, playable, and source-parity tests.
- [x] Prove runtime behavior through Godot MCP on `/root/Main`.
- [x] Run full Python suite.

## Not Done

- None for this slice.

## Evidence

- RED: `test_generated_turret_init_slice_is_registered_with_source_backing` failed because N1156 status was `active`, expected `done`.
- Focused tests: `5 passed`.
- SSOT: `module_count=112`, `errors=[]`, `defense_slices` mirror checked `137`, `source_slice_ledger_slices` mirror checked `1073`.
- Godot MCP runtime:
  - `generated_turret_init_bridge_state(...)` defaults case returned `matches=true`, `shoot_y_after=8`, `elevation_after=1`, `recoil_time_after=60`, `cooldown_time_after=60`, `new_target_interval_after=20`, `disable_overlap_check_after=true`, and `tracking_range_after=120`.
  - `generated_turret_init_bridge_state(...)` preserve case returned `matches=true`, preserved non-default field values, kept `disable_overlap_check_after=false` when `target_ground=true`, and returned `tracking_range_after=140`.
  - `source_turret_init_state(...)` returned upstream-backed expressions for `shootY`, `elevation`, `recoilTime`, `cooldownTime`, `newTargetInterval`, `disableOverlapCheck`, `super.init()`, and `Math.max(range, trackingRange)`.
  - `source_slice_ledger_state("N1156")` and `ssot_slice_ledger_state("N1156")` returned `status=done`.
- Godot debug: `errors=[]`, final `finalErrors=[]`.
- Full suite: `4017 passed, 39290 subtests passed`.
- Ledger after slice: `1073 total`, `853 done`, `220 not done`, `79.50%`; next unfinished slice is `N1157`.
