# Report N2390 — ShockwaveTower sense / warmup rows

**Slice:** N2390 — ShockwaveTower `sense()` rows: bare progress
ratio + `warmup()` = heat. **Wave:** advances-21. **Commit:**
`c990db90b` on `slice/N2390-shockwave-tower-sense-rows` (base
`d35c67781`). **Files:** 5, +940/−2.

## Source

Java: ShockwaveTower.java:109-112 (`sense(LAccess.progress)` =
`reloadCounter / reload`, NO clamp), :115-118 (`warmup()` returns
`heat`); BuildingComp.java:2094-2123 (the super.sense switch,
already modeled by `SourceBuildingSenseState`).

## Implementation

**2 pures — the clean split** (each pure has one Java method, the
N2383 single-purpose + N2356 two-pure precedents):
- `source_shockwave_tower_sense_state(sensor, reload_counter,
  reload_value, super_value = null)` — progress returns the **BARE
  ratio `reload_counter / reload_value`, NO clamp** (Java-exact,
  unlike MendProjector/LaunchPad). Other sensors return the
  caller-supplied `super_value` (null = the BuildingComp switch
  default branch — not re-modeled).
- `source_shockwave_tower_warmup_state(heat)` — returns `heat`.

**Pure-only verified:** grep `sense|warmup` in the driver finds
only comment defers — no tick call site; sense is called by logic,
warmup by UI/display. No tick changes. 13 exact exprs, all verified
verbatim in upstream (note: the sense line is `public double
sense(LAccess sensor) {` with a space before `{` — differs from
MendProjector's no-space form).

## Commits

- Slice: `c990db90b` (5 files, +940/−2).
- Integration cherry-pick: `ed2db76aa` (clean).

## Tests

Targeted (new module `tests.test_c07_shockwave_tower_sense_rows`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly
None — NO Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-21 integration, PID 20509, from 14:01):
Ran 6575 tests in 1517.133s, FAILED (failures=319, skipped=5), 0 errors — 319/319 Godot-absent `AssertionError: unexpectedly None` (312 inherited + 7 new proof tests N2386–N2392; N2393 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+2/+4** → 12054/1813/1742/3276 (3 symbols:
`source_shockwave_tower_sense_state_result.value`, `.is_progress`,
`source_shockwave_tower_warmup_state_result.warmup`). Audit stays
1336. DEFERRED **306 → 305** (resolves #65, by entry TEXT; no new
entry).

## Godot debt

- NEW proof `C07ShockwaveTowerSenseRowsProof` (6 keys:
  `sense_progress_zero`, `sense_progress_partial` (0.5 at both the
  80f def and 90f class-default reloads, plus the bare 1.5
  over-reload case proving no clamp), `warmup_value`,
  `sense_super_sensor` (health 80.0 / efficiency 0.75
  pass-through), `sense_super_default` (null),
  `sense_live_frame_values` (placed tower: counter 40.0 → progress
  0.5; one N2247 advance tick decays heat 0.6 → 0.5875, warmup
  reads 0.5875)) — written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
- Follow-through: the logic call site for `sense()` and the display
  call site for `warmup()` — port-wide logic-executor/display
  concerns, not ShockwaveTower deferrals (no DEFERRED entry added,
  per brief).
