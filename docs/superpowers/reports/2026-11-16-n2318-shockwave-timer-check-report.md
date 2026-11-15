# Report N2318 — ShockwaveTower timerCheck cadence

**Slice:** N2318 — ShockwaveTower timerCheck cadence (frame-local Interval, 8f literal; tick passes check_ready into the N2247 advance). **Wave:** advances-12.
**Commit:** `321e25c2` on `slice/N2318-shockwave-timer-check` (base `0b18eff8`).
**Files:** 5, +991/−6.

## Source

Java checks for a firing opportunity on an 8-tick timer:
`if(timer(timerCheck, checkInterval)){` (ShockwaveTower.java:73),
`checkInterval = 8f` (:31), `public final int timerCheck = timers++;` (:23).
`TimerComp.timer` returns false for infinite time (TimerComp.java:10-13);
`Interval.get` fires when `Time.time - times[id] >= time` (arc
Interval.java:20-26). The N2247 advance takes `check_ready` but the driver
passed `false` + an empty candidate list
(SourceShockwaveTowerBuildState.gd:197), so the check never fired live. All
brief/SCOPE cites verified correct by grep.

## Implementation

New pure `source_shockwave_tower_timer_check_state(...)` →
`{check_ready, timer_elapsed_after, threshold}` (N2280/N2290 pattern):
accumulate UNSCALED source_delta unconditionally, fire at the literal 8f (NO
`/ time_scale` — Java passes a plain 8f), reset 0 on fire, `time_scale <= 0`
→ threshold INF, elapsed still accumulates. The tick accumulates
`frame["timer_check_elapsed"]` every enabled tick and passes the timer's
`check_ready` into the N2247 advance (replacing the `false` literal).
Candidates stay the empty list — no live bullet/unit scan added.

**The pure returns 3 keys, not 2:** the brief named only `check_ready` /
`timer_elapsed_after`, but the worker added `threshold` per the N2273
precedent — and that is the source of the +3 symbols (the other timer slices
in this wave return 2 keys and add +2). First-fire deviation documented in
the docstring + DEFERRED.

**Live proof design:** both live towers seed counter 79.0 (not 80.0) so the
N2187 shouldConsume gate stays open and the charge lands exactly at 80.0
before the advance gate evaluates.

## Commits

- Slice: `321e25c2` (5 files, +991/−6).
- Integration cherry-pick: `b61202b3` (clean).

## Tests

Targeted (new module `tests.test_c07_shockwave_tower_timer_check`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). Exact-evidence 11/11. Siblings Ran 12 =
9 PASS + 3 proof, 0 other failures.
Full gate (wave advances-12 integration, PID 14401, 05:51–06:14): Ran 6342 tests in 1364.272s, FAILED (failures=262, skipped=5), 0 errors — 262/262 Godot-absent `AssertionError: unexpectedly None` (255 inherited + 7 new proof tests N2316–N2322).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 11936/1757/1689/3170 (exactly the SCOPE
estimate): symbols
`source_shockwave_tower_timer_check_state_result.check_ready` /
`.timer_elapsed_after` / `.threshold`; audit stays 1336. DEFERRED 323 (−1+1:
resolved the timer entry, added the first-fire deviation entry).

## Godot debt

- NEW proof `C07ShockwaveTowerTimerCheckProof` (6 keys:
  `live_tick_passes_check_ready_on_fire`,
  `timer_fire_alone_does_not_fire_wave`, `timer_fires_at_eight_ticks`,
  `timer_no_fire_below_threshold`, `timer_no_fire_when_time_scale_zero`,
  `timer_resets_elapsed_on_fire`) — written but NEVER run; debt in GOAL.md §5.
