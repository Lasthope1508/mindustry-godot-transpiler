# Report N2479 — Radar canPickup / progress() rows

**Slice:** N2479 — Radar canPickup / progress() rows (DEFERRED
#33). **Wave:** advances-33. **Commit:** `02274b134` on
`slice/N2479-radar-can-pickup-progress-rows` (base `08b822909`).
**Files:** 5, +713/−4.

## Source

Radar.java (core/src/mindustry/world/blocks/defense/):
- canPickup :75-77: `public boolean canPickup(){ return false; }`
- progress() :93-95: `public float progress(){ return progress; }`
- progress is the build field :49, advanced by the N2190
  updateTile advance (Radar.java:68, `progress += edelta() /
  discoveryTime;`, clamped [0, 1] by :69).

## Implementation

One pure-only accessor (no tick wiring — the caller, the
pickup/UI path, reads it): `source_radar_can_pickup_progress_
state(progress)` → {can_pickup: false, progress: progress} —
the port's first source-backed canPickup / progress() (the
N2190 advance tracks the progress FIELD on the frame but
neither accessor itself).

**Verify-first findings:**
- **The clamp lives in updateTile, NOT in progress()** —
  `progress = Mathf.clamp(progress);` (Radar.java:69) runs in
  the tick, so this pure does NOT clamp: it returns its input
  as-is.
- canPickup is unconditionally false whatever the progress —
  the base BuildingComp.canPickup() returns block.canPickup
  (BuildingComp.java:1838-1840, default true, Block.java:176),
  so the override is what makes a radar unpickupable.
- The base BuildingComp.progress() returns 0f
  (BuildingComp.java:617-619), so the override is what exposes
  the discovery fraction. The frame progress key is `progress`
  (same name since the N2190 advance).
- **Numbering note:** the old "#34" in the brief's source was
  the 238-base numbering; in the merged 234-base this entry is
  #33 and the forceUpdate call is #127 → #123 (the read/write
  rows Radar.java:98-110 are #32 — neither in scope).

## Commits

- Slice: `02274b134` (5 files, +713/−4).
- Integration cherry-pick: `b2b035da7` (clean).

## Tests

Targeted (new module
`tests.test_c07_radar_can_pickup_progress_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (5 Radar modules) Ran 20 (15 PASS +
5 proof Godot-absent), 0 errors.
Full gate (wave advances-33 integration, PID 8956, from 01:20): Ran 6902 tests in 1769.746s, FAILED (failures=400, skipped=5), 0 errors — 400/400 Godot-absent (393 inherited + 7 new proof tests N2476–N2482; Ran 6902 = 6874 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2 → 12384/1892/1845/3482** (symbols
+1 over the +1 estimate — the pure returns 2 keys).
DEFERRED **#33 RESOLVED** (234→233, by entry TEXT).

## Godot debt

- NEW proof `C07RadarCanPickupProgressProof` (6 keys:
  `pickup_false`, `progress_zero`, `progress_half`,
  `progress_full`, `progress_clamped`, `progress_live_input`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
