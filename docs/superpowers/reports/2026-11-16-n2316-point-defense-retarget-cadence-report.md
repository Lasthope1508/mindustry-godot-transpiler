# Report N2316 — PointDefenseTurret retarget cadence

**Slice:** N2316 — PointDefenseTurret retarget cadence (frame-local Interval-equivalent, 5f; timer-gated retarget_tick into the N2229 advance). **Wave:** advances-12.
**Commit:** `9e2a8a3d` on `slice/N2316-point-defense-retarget-cadence` (base `0b18eff8`).
**Files:** 6, +1044/−28.

## Source

Java re-acquires the target on a 5-tick timer: `if(timer(timerTarget,
retargetTime)){` (PointDefenseTurret.java:65), `public final int timerTarget =
timers++;` (:20), `retargetTime = 5f` (:21). `TimerComp.timer` returns false
for infinite time (TimerComp.java:10-13); `Interval.get` fires when
`Time.time - times[id] >= time || Time.time < times[id]` and stamps
`times[id] = Time.time` on fire (arc Interval.java:20-26). The N2229 advance
takes `retarget_tick: bool` but the driver passed the `false` literal
(SourcePointDefenseTurretBuildState.gd:342-344), so no live retarget ever
happened. All brief/SCOPE cites verified correct by grep.

## Implementation

New pure `source_point_defense_turret_retarget_timer_state(elapsed,
source_delta, time_scale, duration)` → `{retarget_tick, timer_elapsed_after}`
(N2280/N2290 pattern): accumulate UNSCALED source_delta unconditionally, fire
at the literal 5f (NO `/ time_scale` — Java passes a plain 5f), reset 0 on
fire, `time_scale <= 0` → threshold INF, elapsed still accumulates. The tick
accumulates `frame["timer_retarget_elapsed"]` every enabled tick and passes
the timer's `retarget_tick` into the N2229 advance (replacing the `false`
literal); bullets stay the empty list — no live bullet query added. Selection
logic untouched. Documented limits updated: "timer cadence live (N2316)";
live bullet scan / coolant fill / damage application / effects still deferred.
First-fire deviation documented in the docstring + DEFERRED (Java fires nearly
immediately after placement; the frame clock delays the first fire by one full
interval).

**Brief SSOT estimate +3 symbols is one high:** the pure returns 2 result
keys → observed +2 (N2280 shape). N2318's +3 comes from its extra `threshold`
key, not from the timer shape itself.

**N2229 test pin update (N2313 precedent):** the N2229 test pinned the driver
call text with `[], false` (:246). Since this slice intentionally replaces
`false` with the live `retarget_tick`, the worker updated that pin + comment
in `test_c07_point_defense_turret_update_tile.py` (14 lines, same commit).
**Older PD proofs are safe:** N2229/N2217/N2151 proofs run ≤2 ticks per
segment, so the 5-tick timer never fires in them (target untouched, no proof
changes needed).

## Commits

- Slice: `9e2a8a3d` (6 files, +1044/−28).
- Integration cherry-pick: `ab66e4bc` (clean).

## Tests

Targeted (new module `tests.test_c07_point_defense_turret_retarget_cadence`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 12/12.
Siblings (power + should-consume + update-tile) Ran 12 = 9 PASS + 3 proof, 0
other failures. Proof pins the literal-5 threshold at overdrive
(`timer.call(4.0, 1.0, 2.0, duration)` fires, `timer.call(2.0, 1.0, 2.0,
duration)` does not).
Full gate (wave advances-12 integration, PID 14401, 05:51–06:14): Ran 6342 tests in 1364.272s, FAILED (failures=262, skipped=5), 0 errors — 262/262 Godot-absent `AssertionError: unexpectedly None` (255 inherited + 7 new proof tests N2316–N2322).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11935/1757/1689/3170: symbols
`source_point_defense_turret_retarget_timer_state_result.retarget_tick` /
`.timer_elapsed_after`; shards `defense_slices.json` +
`defense_api_contracts.json` (N2229 precedent); audit stays 1336. DEFERRED
323 → 324: entry #181 (PD live-fill) REWRITTEN — cadence clause now "live
since N2316", remaining clauses (live bullet scan, coolant fill, damage
application, effects/sound) kept; +1 NEW entry: "PointDefenseTurret retarget
first-fire deviation". Resolve-by-text at merge (N2280 precedent). Note: the
wave-scope arithmetic (−7 resolved) treats the 7 composite entries as
removed, but #181 must be *rewritten*, not removed — the remaining clauses
still defer.

## Godot debt

- NEW proof `C07PointDefenseTurretRetargetCadenceProof` (6 keys:
  `fire_with_empty_bullets_clears_target`, `live_tick_passes_retarget_on_fire`,
  `timer_fires_at_five_ticks`, `timer_no_fire_below_threshold`,
  `timer_no_fire_when_time_scale_zero`, `timer_resets_elapsed_on_fire`) —
  written but NEVER run; debt in GOAL.md §5.
