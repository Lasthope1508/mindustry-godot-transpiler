# Report N2389 — LaunchPad sense rows

**Slice:** N2389 — LaunchPad `sense()` rows: `sense(LAccess.progress)`
= launchCounter / launchTime, clamped. **Wave:** advances-21.
**Commit:** `6006da177` on `slice/N2389-launch-pad-sense-rows`
(base `d35c67781`). **Files:** 5, +884/−1.

## Source

Java: LaunchPad.java:98-101 (`sense(LAccess.progress)` =
`Mathf.clamp(launchCounter / launchTime)`), :32 (class default
`launchTime = 1f`); Blocks.java:6794 (launch-pad `60f * 20` =
1200f), :6804 (advanced-launch-pad `60f * 30` = 1800f);
BuildingComp.java:2123 (the super.sense `default -> Float.NaN`).

## Implementation

New pure `source_launch_pad_sense_state(sensor, launch_counter,
launch_time, super_value = null)` (the N2383 pure-only pattern):
progress → `clampf(launch_counter / launch_time, 0.0, 1.0)`
(CLAMPED, Java-exact per LaunchPad.java:99); other sensors → the
caller-supplied `super_value` (null = the `Float.NaN` default
branch). `launchTime` is a def input: 1200f (launch-pad), 1800f
(advanced-launch-pad), 1f (class default). Edge covered in the
proof: counter 0 at launchTime 1f → 0.0.

**No tick changes:** grep confirms the driver has ZERO sense call
sites — sense is called by logic, not the tick. Documented limits
updated with "(7) Sense rows live (N2389)". Advanced-def
verification itself is a separate slice (#49) — untouched.

## Commits

- Slice: `6006da177` (5 files, +884/−1).
- Integration cherry-pick: `4a6c1b6dc` (clean).

## Tests

Targeted (new module `tests.test_c07_launch_pad_sense_rows`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12053/1813/1741/3274 (2 symbols:
`source_launch_pad_sense_state_result.value`, `.is_progress`).
Audit stays 1336. DEFERRED **306 → 305** (resolves #50, by entry
TEXT; no new entry).

## Godot debt

- NEW proof `C07LaunchPadSenseRowsProof` (6 keys:
  `sense_progress_zero`, `sense_progress_half`,
  `sense_progress_clamped`, `sense_super_sensor`,
  `sense_super_default`, `sense_live_frame_values` (placed
  launch-pad, counter 600.0 + one N2238 advance tick (edelta 1.0)
  → 601.0, sensed progress 601.0/1200.0, no launch (empty pad)))
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the logic call site that calls `sense()` waits
  for the port-wide logic-executor slice (not a LaunchPad
  deferral); advanced-launch-pad def verification is slice #49.
