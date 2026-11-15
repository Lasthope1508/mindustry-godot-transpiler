# Report N2319 — PayloadLoader load timer cadence

**Slice:** N2319 — PayloadLoader load timer cadence (frame-local Interval-equivalent, 2f/efficiency; live load_tick into the N2231 advance). **Wave:** advances-12.
**Commit:** `f9e77e49` on `slice/N2319-loader-load-timer` (base `0b18eff8`).
**Files:** 6, +1045/−14.

## Source

Java loads on an efficiency-scaled timer: `timer(timerLoad, loadTime /
efficiency)` (PayloadLoader.java:157), `public final int timerLoad =
timers++;` (:20), `loadTime = 2f` (:22). `TimerComp.timer` returns false for
infinite time (TimerComp.java:10-13); `Interval.get` fires when `Time.time -
times[id] >= time` (arc Interval.java:20-26); `timeRaw += delta;`
(Time.java:75). The N2231 advance takes `load_tick: bool` but the driver
passed the `false` literal (SourcePayloadLoaderBuildState.gd:678), so no live
load ever happened. The `efficiency > 0.01 and load_tick` gate already lives
INSIDE the N2231 advance pure (:446) — the timer pure ONLY computes
load_tick, never duplicates the gate. All brief/SCOPE cites verified correct
by grep (Blocks.java:6686/6687 def cites too).

## Implementation

New pure `source_payload_loader_load_timer_state(elapsed, source_delta,
time_scale, efficiency, load_time)` → `{load_tick, timer_elapsed_after}`:
`load_tick = (eff > 0.01) and (elapsed >= loadTime / eff)`; elapsed
accumulates unconditionally (Java short-circuits: eff ≤ 0.01 never calls
timer(), but Time.time advances, so a recovered efficiency fires at once);
`time_scale <= 0` never fires (threshold INF, clock still accumulates);
eff ≤ 0 is the infinite-time branch (division guarded); reset to 0.0 on
fire. Threshold divides by **efficiency, never timeScale** (N2290 lesson;
the test pins `assertNotIn('load_time / time_scale')`). The tick accumulates
`timer_load_elapsed` after the consumption fold and passes the live
`load_tick` into the N2231 advance (no longer the `false` literal). Intake
gate N2315 / acceptPayload N2295 / dynamic power N2270 untouched.

**Brief SSOT est +3 symbols is one high** — the pure returns exactly 2 result
keys, so actual is +2 (N2280 timer precedent also added 2). **Brief "Loader
×6 modules" is one low** — 7 Loader test modules exist (accept_payload,
dynamic_power, intake_gate, live_fill, power_status, should_consume,
update_tile); all 7 run green except proofs.

**N2231 test pin updated in this commit (6th file):** the N2231 test pinned
the advance call with the `false` load_tick literal (:352), whose premise
("no timer infra") is false by design once the timer lands. Updated to the
new call text per the N2290/N2304 precedent; commit message notes it.

**Disabled-loader interaction:** Java folds efficiency to 0 when disabled
(BuildingComp.java:1955-1957); the port fold skips when disabled, leaving the
frame value stale. The timer reads the same frame efficiency as the advance
gate, so both stay mutually consistent — a shared pre-existing gap for the
driver-wide disabled-early-return slice, not a new timer deviation. Noted in
the tick comment; no extra DEFERRED entry added.

## Commits

- Slice: `f9e77e49` (6 files, +1045/−14).
- Integration cherry-pick: `776e0509` (clean).

## Tests

Targeted (new module `tests.test_c07_payload_loader_load_timer`): 3/4 PASS +
proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). RED confirmed first (KeyError 'N2319',
missing pure). Exact-evidence 17/17. Loader siblings: 7 modules, 21/28 PASS,
7 failures all proof tests failing Godot-absent, 0 errors. Live-tick proof
key: clock-1.0 loader fires → all 5 copper load + clock resets 0.0; clock-0.0
loader → no load, clock 1.0.
Full gate (wave advances-12 integration, PID 14401, 05:51–06:14): Ran 6342 tests in 1364.272s, FAILED (failures=262, skipped=5), 0 errors — 262/262 Godot-absent `AssertionError: unexpectedly None` (255 inherited + 7 new proof tests N2316–N2322).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11935/1757/1689/3170: symbols
`source_payload_loader_load_timer_state_result.load_tick` /
`.timer_elapsed_after`; shards `payload_api_contracts.json` +
`payload_slices.json`; audit stays 1336. DEFERRED 323 → 323: resolved the
#171 entry ("PayloadLoader load timer cadence…"), added 1 new entry
(first-fire deviation, documented in the driver docstring too).

## Godot debt

- NEW proof `C07PayloadLoaderLoadTimerProof` (6 keys:
  `live_tick_passes_load_tick_on_fire`,
  `timer_fires_at_load_time_over_efficiency`,
  `timer_fires_when_efficiency_recovers`, `timer_no_fire_below_threshold`,
  `timer_no_fire_when_efficiency_low`, `timer_no_fire_when_time_scale_zero`)
  — written but NEVER run; debt in GOAL.md §5.
