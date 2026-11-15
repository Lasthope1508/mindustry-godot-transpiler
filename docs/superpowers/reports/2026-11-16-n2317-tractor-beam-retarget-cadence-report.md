# Report N2317 — TractorBeamTurret retarget cadence

**Slice:** N2317 — TractorBeamTurret retarget cadence (frame-local Interval-equivalent, 5f; live retarget_tick + frame-input unit_candidates into the N2230 advance). **Wave:** advances-12.
**Commit:** `8e1228b8` on `slice/N2317-tractor-beam-retarget-cadence` (base `0b18eff8`).
**Files:** 7, +1111/−45.

## Source

Java re-acquires the target on a 5-tick timer: `if(timer(timerTarget,
retargetTime)){` (TractorBeamTurret.java:87), `public final int timerTarget =
timers++;` (:20), `retargetTime = 5f` (:21). Parallax does not override
retargetTime (Blocks.java:3640-3653), so class 5f is the only value.
`TimerComp.timer` returns false for infinite time (TimerComp.java:10-13);
`Interval.get` fires when `Time.time - times[id] >= time` (arc
Interval.java:20-26); `timeRaw += delta;` (Time.java:75). The N2230 advance
takes `retarget_tick: bool` but the driver passed the `false` literal
(SourceTractorBeamTurretBuildState.gd:390-392), so no live retarget ever
happened. All brief/SCOPE cites verified correct by grep.

## Implementation

New pure `source_tractor_beam_turret_retarget_timer_state(elapsed,
source_delta, time_scale, duration)` → `{retarget_tick, timer_elapsed_after}`
(N2280/N2290 pattern): frame key `timer_retarget_elapsed`, accumulate
UNSCALED source_delta unconditionally, fire at elapsed ≥ literal 5f (NO
timeScale division), reset 0 on fire; `time_scale <= 0` → threshold INF,
never fires, elapsed still accumulates. Const
`SOURCE_TRACTOR_BEAM_TURRET_RETARGET_DURATION := 5.0`. Tick wiring (driver,
before the advance call): timer runs, elapsed written back, live
`retarget_tick` + frame-input `unit_candidates` (default `[]`) passed into
the N2230 advance. Selection logic untouched; dead
`SourceTractorBeamTurretBuildUpdateTile*State.gd` modules untouched.
Documented limits updated (cadence live N2317; live unit query still defers).

**Design decision:** the driver reads candidates from
`frame["unit_candidates"]` (default `[]`) and passes them as the advance's
explicit param — the brief's "candidates là frame input" read literally,
following the N2280 frame-key precedent. With no frame key, behavior is
identical to the old `[]` literal. No gating stamp is needed (unlike N2280):
the advance ignores candidates when retarget_tick is false.

**Activation-early-return verification (brief asked to verify):** the timer
runs in the driver BEFORE the advance call, so activation does not stop the
clock — and that matches Java: global Time.time keeps growing during
activation, so Java fires on the first check after activation ends; the
port's accumulated elapsed fires the same way. Noted in the pure's docstring.

**Brief SSOT estimate +3 symbols is wrong for this slice: actual +2** (2
result symbols, same as N2280). **SCOPE's DEFERRED math (−7) is wrong for TB
(and PD):** the #182 entry is a COMBINED live-fill entry (cadence + scan +
coolant + application + sound/draw), not a standalone cadence entry —
rewritten in place per the N2280 precedent, not removed. This slice is +1
net, not −1.

**Follow-through (brief did not flag the N2230 test pin, unlike the N2280
brief's N2226 warning):** `test_c07_tractor_beam_update_tile.py:267` pinned
the driver call with `[], false`. Passing the live retarget_tick necessarily
changes that text, so this slice updates the pin + 2 stale comments in the
N2230 test and 1 stale comment in the N2230 proof (N2290/N2300 precedent).
The N2230 proof needs no value change: its 2 live ticks accumulate the clock
to 2.0 < 5, so no fire happens inside it — comment-only, NO re-run.

## Commits

- Slice: `8e1228b8` (7 files, +1111/−45).
- Integration cherry-pick: `f60961ef` (clean).

## Tests

Targeted (new module `tests.test_c07_tractor_beam_turret_retarget_cadence`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 12/12.
Siblings (power + should-consume + update-tile) Ran 12 = 9 PASS + 3 proof, 0
other failures. Only these 4 modules read the driver — no other test touches
it. Live proof uses 3 parallaxes (fire+acquire at clock 4.0, fire+empty→target
null at clock 4.0, no-fire at clock 0.0). Overdrive pins: 4+1 fires at
time_scale 2.0, 2+1 does NOT (literal-5 threshold).
Full gate (wave advances-12 integration, PID 14401, 05:51–06:14): Ran 6342 tests in 1364.272s, FAILED (failures=262, skipped=5), 0 errors — 262/262 Godot-absent `AssertionError: unexpectedly None` (255 inherited + 7 new proof tests N2316–N2322).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11935/1757/1689/3170: symbols
`source_tractor_beam_turret_retarget_timer_state_result.retarget_tick` /
`.timer_elapsed_after`; shards `defense_api_contracts` + `defense_slices`
(N2230 precedent); audit stays 1336. DEFERRED 323 → 324 (+1): the TB
live-fill entry (#182) rewritten in place — cadence clause now "live since
N2317"; +1 new entry: `TractorBeamTurret retarget timer first-fire deviation`
(frame clock delays first fire by a full 5-tick interval; Java fires nearly
immediately after placement).

## Godot debt

- NEW proof `C07TractorBeamTurretRetargetCadenceProof` (6 keys:
  `fire_with_empty_candidates_clears_target`,
  `live_tick_passes_retarget_on_fire`, `timer_fires_at_five_ticks`,
  `timer_no_fire_below_threshold`, `timer_no_fire_when_time_scale_zero`,
  `timer_resets_elapsed_on_fire`) — written but NEVER run; debt in GOAL.md §5.
