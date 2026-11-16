# Report N2485 — Accelerator progress / isCoreBuilt rows

**Slice:** N2485 — Accelerator progress / isCoreBuilt rows
(DEFERRED #64). **Wave:** advances-34. **Commit:** `fd58bb692`
on `slice/N2485-accelerator-progress-is-core-built-rows` (base
`ad308cf7e`). **Files:** 5, +725/−3.

## Source

Accelerator.java (core/src/mindustry/world/blocks/campaign/ —
NOT defense/ as the brief said): progress() :149-150 (`public
float progress(){ return progress; }` — the build field `public
float progress;`, :121); isCoreBuilt() :153-154 (`return progress
>= 1f;` — the >= 1f boundary is exact: progress exactly 1f IS
core-built). The base BuildingComp.progress() returns 0f, so the
override is what exposes the build fraction. canLaunch()
(:239-240) and getMaximumAccepted() (:293-294) both gate on
isCoreBuilt. The frame progress key is advanced + clamped to 1f
by the N2191 updateTile advance (`progress += Time.delta *
efficiency / buildDuration;`, :143, then `progress =
Math.min(progress, 1f);`, :144). Serialization: `write.f(
progress);` :310, `progress = read.f();` :318.

## Implementation

One pure-only accessor (no tick wiring — the caller, the
launch/UI path, reads it): `source_accelerator_progress_is_core_built_state(progress)`
→ {progress, is_core_built} — the pure returns its input as-is
for progress and progress >= 1f for is_core_built.

**Verify-first findings:**
- **The clamp lives in updateTile (:144), NOT in progress()**
  — so the pure itself does NOT clamp: it returns its input
  as-is, and the proof's core_built_boundary key pins the pure
  passing 1.5 through unchanged (is_core_built true) plus the
  LIVE clamped input (the advance output clamped to 1.0).
- **The entry :310/:318 is RIGHT** — `write.f(progress);` is
  :310 and `progress = read.f();` is :318. The driver comment
  :305/:311 was WRONG — fixed by this slice (the same line also
  carried the wrong launchDuration cite :317/:318; the method
  is :324-325, fixed too).
- **The Java path is campaign/, NOT defense/** as the brief
  said.
- The live-input key pins the N2191 advance: 0.5 + 30/120 →
  0.75, and the advance clamp 0.999 + 60/120 → 1.0.
- Serialization DEFERS to its own slice with no new entry
  (the wave scope decision).

## Commits

- Slice: `fd58bb692` (5 files, +725/−3).
- Integration cherry-pick: `f7272e45a` (clean).

## Tests

Targeted (new module
`tests.test_c07_accelerator_progress_is_core_built_rows`): 3/4 PASS
(registration, exact-evidence, row-state) + proof test FAIL exactly
AssertionError: unexpectedly None — NO Godot binary on this VM (user
order 2026-11-15). Neighbours (9 Accelerator modules) Ran 36 (27
PASS + 9 proof Godot-absent), 0 errors.
Full gate (wave advances-34 integration): run 1 (PID 16663, from 02:12) KILLED by VM restart #18 ~02:32 (no footer); run 2 (PID 1769, 02:33–03:08): Ran 6930 tests in 1643.573s, FAILED (failures=407, skipped=5), 0 errors — 407/407 Godot-absent (400 inherited + 7 new proof tests N2484–N2490; Ran 6930 = 6902 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2 → 12403/1899/1853/3498** (exactly as
estimated). DEFERRED **#64 RESOLVED** (231→230, by entry TEXT).

## Godot debt

- NEW proof `C07AcceleratorProgressIsCoreBuiltRowsProof` (6 keys:
  `progress_zero`, `progress_half`, `progress_full`,
  `core_built_true`, `core_built_boundary`, `progress_live_input`)
  — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
