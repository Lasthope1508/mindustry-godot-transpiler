# Report N2342 — Accelerator battery_stored graph stamp

**Slice:** N2342 — Accelerator battery_stored graph stamp (the live fill
for the N2271 canLaunch gate input). **Wave:** advances-15. **Commit:**
`06919307` on `slice/N2342-accelerator-battery-stamp` (base `c89f1d09`).
**Files:** 6, +779/−0.

## Source

Java: `getBatteryStored()` (PowerGraph.java:118-127) sums
`battery.power.status * capacity` over enabled batteries;
`useBatteries` (PowerGraph.java:154-167). The port's graph summary
computes battery_stored (SourcePlacedPowerGraphState.gd:303); the
power_status stamp precedent is SourceFactoryRuntimeState.gd:1107 (N2142).

## Implementation

New pure
`SourcePlacedPowerGraphState.source_accelerator_set_battery_stored_for_cell_state(game,
cell, battery_stored)` (:112, parallel to the N2142 power_status
write-back) → `{stored, reason}` (`live_frame` / `no_sprite` /
`not_accelerator` / `no_frame`). It stamps frame["battery_stored"] ONLY
for accelerator frames — meta key verified in code:
`source_accelerator_building` (SOURCE_ACCELERATOR_BUILDING_META_KEY,
SourceAcceleratorBuildState.gd:14), via preload; no preload cycle (the
accelerator's 55-file preload closure contains neither graph nor
FactoryRuntime — verified by script). **Wiring DONE, not deferred:** the
battery total IS available at the distribute step (`update_state` returns
post-use/charge batteries in battery_distribute_state; `battery_state()`
over them IS getBatteryStored()); the new call is at
SourceFactoryRuntimeState.gd:1129, next to the :1107 power_status stamp;
the cheat branch falls back to top-level batteries (unchanged pattern).
The stamp sees this tick's post-update total = what Java's canLaunch reads
live. Only the stamp call was added; no other shared-file logic touched;
the Accelerator driver is untouched. Generated JSON was left uncommitted
(coordinator merges at integration — the correct pattern).

## Commits

- Slice: `06919307` (6 files, +779/−0).
- Integration cherry-pick: `e9565f1e` (clean).

## Tests

Targeted (new module `tests.test_c07_accelerator_battery_stamp`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). RED confirmed (2F+2E).
Exact-evidence 6/6. Siblings 47 modules Ran 2506 = 2460 PASS + 46 proof
Godot-absent, 0 errors.
Full gate (wave advances-15 integration, PID 1755, 08:31–08:52): Ran 6415 tests in 1285.515s, FAILED (failures=280, skipped=5), 0 errors — 280/280 Godot-absent `AssertionError: unexpectedly None` (275 inherited + 5 new proof tests N2338/N2339/N2340/N2342/N2343).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11971/1777/1709/3210 (not +1 as
estimated — the pure returns 2 keys); shards power_slices +
power_api_contracts only. Audit stays 1336.
DEFERRED net 0 (#236 REWRITTEN in place — live fill live since N2342; the
entry now covers only per-battery proportional scaling,
PowerGraph.java:160-165).

## Godot debt

- NEW proof `C07AcceleratorBatteryStampProof` (6 keys:
  `accelerator_set_stamps_frame`, `accelerator_set_overwrites_stale`,
  `accelerator_set_not_accelerator`, `accelerator_set_no_frame`,
  `accelerator_set_missing_sprite`,
  `battery_stored_total_from_batteries`) — written but NEVER run; debt in
  GOAL.md §5. Fake-game pattern from N2142.
