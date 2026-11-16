# Report N2373 — Accelerator draw rows

**Slice:** N2373 — Accelerator draw / drawLight / drawSelect pures.
**Wave:** advances-19. **Commit:** `4bd69a218` on
`slice/N2373-accelerator-draw-rows` (base `46b1b951b`). **Files:** 5,
+1189/−1.

## Source

Java: Accelerator.java:157-... (draw: arrows / launchBlock icons /
charge rings / landing), :180-194 (launching branch — still deferred,
launchTime untracked), :236-238 (drawLight), :249-256 (drawSelect
battery warning), :242-244 (getCursor). 59 exact exprs, all verified
verbatim.

## Implementation

3 pures (draw + drawLight + drawSelect; draw = arrows 4 layers × 4 +
build shadow r80 + rings heat-gated ≥0.0001f; drawLight r70 Pal.accent
launchHeat; drawSelect battery warning when stored < 1,000,000 &&
!launching). Proof values verified numerically in Python.

⚠️ SCOPE CORRECTIONS: core-nucleus size 5 (shadow r80, not 4);
chargeRings belong to drawLaunchGlobalZ, NOT draw(); drawSelect is
:249-256 (the old #107 cite :250-255 was off by one).

## Commits

- Slice: `4bd69a218` (5 files, +1189/−1).
- Integration cherry-pick: `7927d0b31` (clean).

## Tests

Targeted (new module `tests.test_c07_accelerator_draw_rows`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 59/59.
Siblings Ran 24 (18 PASS + 6 proof Godot-absent), 0 other errors.
Full gate (wave advances-19 integration, PID 7308, 12:44–13:09): Ran 6522 tests in 1485.371s, FAILED (failures=306, skipped=5), 0 errors — 306/306 Godot-absent `AssertionError: unexpectedly None` (299 inherited + 7 new proof tests N2368–N2374; N2375 adds +1 pin test, N2376 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+3/+6** → 12023/1800/1732/3256 (above the
estimate — drawLight separates cleanly + the draw pure has 3 distinct
calls). Audit stays 1336. DEFERRED **316 → 316** (net 0; #106 + #107
rewritten in place — the launching branch :180-194 still defers,
launchTime untracked).

## Godot debt

- NEW proof `C07AcceleratorDrawRowsProof` (6 keys:
  `draw_arrows_status_lerp_pulse`, `draw_shadow_blockbuild`,
  `draw_charge_rings_heat_gate`, `draw_light_launch_heat`,
  `draw_select_battery_warning`, `draw_live_frame_values`) — written
  but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the launching branch waits on the launchTime /
  cloudSeed slice (#175); getCursor waits on the canLaunch
  environment-half slice; drawLaunch / drawLaunchGlobalZ / drawLanding
  wait on the launch-sequence slice.
