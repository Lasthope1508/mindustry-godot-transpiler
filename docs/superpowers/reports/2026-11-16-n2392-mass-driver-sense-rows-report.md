# Report N2392 — MassDriver sense rows

**Slice:** N2392 — MassDriver `sense()` rows: `sense(LAccess.progress)`
= clamp(1 − reloadCounter). Sense half only — draw/icons stay
deferred. **Wave:** advances-21. **Commit:** `d7ad85d79` on
`slice/N2392-mass-driver-sense-rows` (base `d35c67781`).
**Files:** 5, +873/−1.

## Source

Java: MassDriver.java:226 (`if(sensor == LAccess.progress) return
Mathf.clamp(1f - reloadCounter);`), :292 (`fire()` resets
reloadCounter to 1f), :143 (decay drains it); :230-242 (draw),
:244-264 (drawConfigure), :80-102 (drawPlace), :75-77 (icons) —
the draw half, still deferred.

## Implementation

New pure `source_mass_driver_sense_state(sensor, reload_counter,
super_value = null)` (the N2383 pattern): progress →
`clampf(1.0 - reload_counter, 0.0, 1.0)`; other sensors → the
caller-supplied `super_value` (null = the super switch default
branch). Returns `{value, is_progress}`.

**The reloadCounter counts DOWN** — `fire()` resets it to 1f
(:292), decay drains it (:143) — so a fresh reloadCounter 1.0
reads progress **0** and ready 0.0 reads **1**. NOT
reloadCounter/reload (the DEFERRED shorthand hid the formula).

**Pure-only verified:** grep `sense` in the driver finds only
comment defers — no tick call site exists, so no tick wiring.

## Commits

- Slice: `d7ad85d79` (5 files, +873/−1).
- Integration cherry-pick: `99f791086` (clean).

## Tests

Targeted (new module `tests.test_c07_mass_driver_sense_rows`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None —
NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 12053/1813/1741/3274 (2 symbols:
`source_mass_driver_sense_state_result.value`, `.is_progress`).
Audit stays 1336. DEFERRED **#47 REWRITTEN IN PLACE** — now
"MassDriver draw / drawConfigure / drawPlace / icons rows" with a
note that the sense half is live since N2392 — count stays 306.

## Godot debt

- NEW proof `C07MassDriverSenseRowsProof` (6 keys:
  `sense_progress_zero` (reloadCounter 1.0 just shot → 0, plus 1.5
  clamp), `sense_progress_half` (0.5 → 0.5), `sense_progress_full`
  (0.0 ready → 1, plus −0.5 clamp), `sense_super_sensor` (health
  80.0 / efficiency 0.75 via modeled `SourceBuildingSenseState`),
  `sense_super_default` (unknown sensor → null),
  `sense_live_frame_values` (placed mass-driver, one N2237 advance
  tick: reload_counter 1.0 → 0.995, sensed progress 0.005)) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the draw half of old #47 stays deferred (draw /
  drawConfigure / drawPlace / icons, MassDriver.java:230-242,
  244-264, 80-102, 75-77); the logic call site waits for the
  port-wide logic-executor slice; `senseObject` / `sense(Content)`
  overloads are not modeled (separate overloads,
  BuildingComp.java:2124+).
