# Report N2354 — Accelerator launch-drain per-battery scaling

**Slice:** N2354 — Accelerator launch-drain per-battery scaling (DEFERRED
#326; one-shot launch_drain_request + runtime apply via existing
`use_batteries_state`, 1-tick delay). **Wave:** advances-17. **Commit:**
`65f88ab47` on `slice/N2354-accelerator-per-battery-drain` (base `9282b27a`).
**Files:** 7, +562/−4.

## Source

Java: PowerGraph.java:118-127, :154-167 (useBatteries distribution — the
per-battery scaling the launch drain rides on). 9 exact exprs, all verified
verbatim.

## Implementation

Scope correction: the pure scaling the brief proposed was ALREADY live
(`use_batteries_state`,
SourcePowerGraphBatteryDistributionState.gd:107-143, Java-exact, already
SSOT-registered), so the slice became wiring-only: a one-shot helper
`source_accelerator_take_launch_drain_request_for_cell_state` takes the
`launch_drain_request` and applies the drain at runtime through the existing
`use_batteries_state`. The 1-tick delay launch→drain is documented (the
graph updates before the driver tick).

## Commits

- Slice: `65f88ab47` (7 files, +562/−4).
- Integration cherry-pick: `1435504ac` (clean).

## Tests

Targeted (new module `tests.test_c07_accelerator_launch_drain`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). Exact-evidence 9/9. Siblings 11 modules
Ran 40 (29 PASS + 11 proof Godot-absent); factory live-loop Ran 12 (9 PASS +
3 proof), 0 other errors.
Full gate (wave advances-17 integration, PID 12882, 10:58–11:23): Ran
6468 tests in 1457.080s, FAILED (failures=293, skipped=5), 0 errors —
293/293 Godot-absent `AssertionError: unexpectedly None` (287 inherited +
6 new proof tests N2351–N2354, N2356–N2357; N2355 has no proof test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 11987/1789/1721/3234 (3 result keys of
the helper). Audit stays 1336.
DEFERRED **326 → 325 (−1+0)**: resolved #326, no new entry.

## Godot debt

- NEW proof `C07AcceleratorLaunchDrainProof` (7 keys:
  `launch_drain_request_missing_sprite`, `launch_drain_request_no_frame`,
  `launch_drain_request_no_request`,
  `launch_drain_request_not_accelerator`, `launch_drain_request_taken`,
  `launch_drain_scales_batteries_half`, `launch_drain_zero_stored`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through (backlog): the N2134 enabled stamp is not wired into the
  factory runtime path — a disabled battery still counts as enabled in the
  live-loop distribution + drain; needs its own slice.
