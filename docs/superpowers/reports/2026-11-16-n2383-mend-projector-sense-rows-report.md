# Report N2383 — MendProjector sense rows

**Slice:** N2383 — MendProjector `sense()` rows: progress from
charge/reload, other sensors delegate to the modeled super.sense.
**Wave:** advances-20. **Commit:** `f28611cfd` on
`slice/N2383-mend-projector-sense-rows` (base `7b99d3d63`).
**Files:** 5, +888/−6.

## Source

Java: MendProjector.java:126-129 (`sense(LAccess.progress)` =
charge / reload), :26 (class reload default `250f`);
Blocks.java:1923/1936 (mender `200f` / mend-projector `250f`);
BuildingComp.java:2093-2122 (the super.sense switch, `default ->
Float.NaN; //gets converted to null in logic`); arc Mathf.java:
401-404 (`Mathf.clamp(value)` clamps [0,1]).

## Implementation

New pure `SourceMendProjectorBuildState.
source_mend_projector_sense_state(sensor, charge, reload_value,
super_value = null)` — progress → `clampf(charge / reload, 0.0,
1.0)`; any other sensor → the caller-supplied `super_value`
(null = the default branch). Returns `{value, is_progress}` +
expr strings.

**Verified before scoping (per the brief):**
- **super.sense IS modeled in the port** — no
  documented-default fallback was needed: the whole
  BuildingComp.java:2093-2122 switch (x/y/color/dead/solid/team/
  health/maxHealth/efficiency/timescale/range/rotation/totalItems/
  totalLiquids/totalPower/capacities/powerNet/enabled/controlled/
  payloadCount/size/cameraX… + default NaN) is modeled through
  `SourceBuildingSenseState` (7 pures). The pure takes an
  explicit `super_value` from the caller instead of re-modeling
  the switch — the proof demos delegation with real health +
  efficiency cases.
- **No tick call site** — grep + a full read of
  `source_mend_projector_tick_buildings_state` confirm the tick
  never calls sense. **Pure-only, like the N2372 draws:** sense
  is called by logic (the processor), not the tick. The
  logic-executor call site is port-wide, not a MendProjector
  deferral — no new DEFERRED entry.
- Deliberately did NOT reuse `SourceMendProjectorState.progress()`
  (the display helper): it has no sensor dispatch / super
  delegation and guards reload ≤ 0 → 0.0, which deviates from
  Java (charge/0 → +Inf → 1.0 after the clamp).

## Commits

- Slice: `f28611cfd` (5 files, +888/−6).
- Integration cherry-pick: `815cab21d` (clean).

## Tests

Targeted (new module
`tests.test_c07_mend_projector_sense_rows`): 3/4 PASS + proof
test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Siblings
MendProjector: 9 modules, Ran 36 — 27 PASS, 9 failures all their
own proofs (Godot-absent), 0 other errors.
Full gate (wave advances-20 integration, PID 14748, 13:27–13:50): Ran 6547 tests in 1364.438s, FAILED (failures=312, skipped=5), 0 errors — 312/312 Godot-absent `AssertionError: unexpectedly None` (306 inherited + 6 new proof tests N2377–N2381 + N2383; N2382 adds +1 pin test, N2384/N2385 add no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12040/1807/1739/3270 (2 symbols:
`source_mend_projector_sense_state_result.value`,
`.is_progress`). Audit stays 1336. DEFERRED **311 → 310**
(resolves #309, by entry TEXT; no new entry).

## Godot debt

- NEW proof `C07MendProjectorSenseRowsProof` (6 keys:
  `sense_progress_zero`, `sense_progress_half` (mender 100/200 +
  mend-projector 125/250), `sense_progress_clamped` (300/200→1.0,
  −50→0.0), `sense_super_sensor` (health 80 + efficiency 0.75
  via `SourceBuildingSenseState`), `sense_super_default` (unknown
  sensor → null), `sense_live_frame_values` (frame charge 100 →
  advance 1 tick → 101.0 → progress 0.505, reload 200f from the
  catalog)) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the logic-executor call site for `sense()`
  (port-wide, no slice yet); `senseObject` / `sense(Content)`
  are separate overloads, out of this slice.
