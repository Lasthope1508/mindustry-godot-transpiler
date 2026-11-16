# Report N2359 — N2134 enabled stamp wired into factory runtime path

**Slice:** N2359 — Wire the N2134 battery enabled stamp into the factory
runtime path. **Wave:** advances-18. **Commit:** `1463f85a0` on
`slice/N2359-factory-battery-enabled-stamp` (base `1843003e2`).
**Files:** 5, +771.

## Source

Java: PowerGraph.java:163/:180 (distribute gates on live enabled);
the N2134 stamp pure (`source_battery_enabled_stamp_state`) is reused
as-is. 7 exact exprs, all verified verbatim.

## Implementation

Wiring-only: the factory live-loop power update
(`source_factory_update_power_graph_state`) now calls the N2134 stamp
pure on grouped batteries, placed BEFORE `update_state` (not after
`updated_batteries:1087`) — the pre-update stamp flows into distribute
+ drain:1122 + stored:1172 and covers the cheat branch, where
`update["batteries"]` is the stamped list. Java-exact side effect:
distribute now gates on live enabled (PowerGraph.java:163/:180), so a
disabled battery is excluded from the stored total and untouched by
the launch drain, while an all-enabled list is unchanged.

## Commits

- Slice: `1463f85a0` (5 files, +771).
- Integration cherry-pick: `e05a4bcc1` (clean).

## Tests

Targeted (new module `tests.test_c07_factory_battery_enabled_stamp`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15). Exact-evidence
7/7. Siblings Ran 20 (15 PASS + 5 proof Godot-absent), 0 other errors.
Full gate (wave advances-18 integration, PID 21965, 11:52–12:17): Ran
6493 tests in 1482.684s, FAILED (failures=299, skipped=5), 0 errors —
299/299 Godot-absent `AssertionError: unexpectedly None` (293 inherited
+ 6 new proof tests N2358–N2363; N2364 adds no new proof test).

## SSOT / DEFERRED

SSOT single-slice **+0/+1/+0/+0** → 11999/1794/1727/3246 (reuses the 4
N2134 symbols — the validator only requires `source_symbols` to be a
NON-EMPTY list; the N2127 precedent). Audit stays 1336.
DEFERRED net 0.

## Godot debt

- NEW proof `C07FactoryBatteryEnabledStampProof` (9 keys:
  `factory_stamp_all_enabled_drain_scales_both`,
  `factory_stamp_all_enabled_flags_true`,
  `factory_stamp_all_enabled_stored_total`,
  `factory_stamp_cheat_branch_disabled_untouched`,
  `factory_stamp_cheat_branch_stored_total`,
  `factory_stamp_disabled_excluded_from_stored`,
  `factory_stamp_disabled_flag_false_in_update`,
  `factory_stamp_disabled_untouched_by_drain`,
  `factory_stamp_enabled_drained` — incl. cheat-branch keys locking the
  stamp placement) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Standing limitation: in the real game `block_from_sprite` returns a
  catalog entry (no live enabled), so the stamp keeps the static value
  — the same limitation as the N2134 wiring in runtime_state. Live
  enabled for real battery buildings is a separate slice.
