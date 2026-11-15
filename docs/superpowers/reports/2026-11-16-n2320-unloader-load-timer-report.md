# Report N2320 — PayloadUnloader load timer cadence

**Slice:** N2320 — PayloadUnloader load timer cadence (2f/efficiency frame-local Interval; driver passes computed load_tick to the N2232 advance). **Wave:** advances-12.
**Commit:** `c960b4f9` on `slice/N2320-unloader-load-timer` (base `0b18eff8`).
**Files:** 5, +1097/−15.

## Source

Java unloads on an efficiency-scaled timer: `timer(timerLoad, loadTime /
efficiency)` (PayloadUnloader.java:69, hasItems guard :68); timerLoad/loadTime
inherited from PayloadLoader (:20/:22, loadTime 2f). `TimerComp.timer`
returns false for infinite time (TimerComp.java:10-13); `Interval.get` fires
when `Time.time - times[id] >= time` (arc Interval.java get :20-26 / check
:29); `timeRaw += delta;` (Time.java:75). `loadPowerDynamic = false;`
(PayloadUnloader.java:18) — no dynamic consumer (lượt 9 finding). The N2232
advance takes `load_tick: bool` but the driver passed the `false` literal
(SourcePayloadUnloaderBuildState.gd:922-925), so no live unload ever
happened. The `efficiency > 0.01 and load_tick` gate already lives INSIDE the
N2232 advance pure (:433). All brief/SCOPE cites verified correct by grep;
the test pins all of them by line number. No scope corrections.

## Implementation

New pure `source_payload_unloader_load_timer_state(elapsed, source_delta,
time_scale, efficiency, load_time)` → `{load_tick, timer_elapsed_after}`:
threshold `load_time / efficiency` (INF guard on `time_scale <= 0` or
`efficiency <= 0`); elapsed accumulates unconditionally; `load_tick = (eff >
0.01) and (elapsed >= threshold)`; reset to 0.0 only on fire — the Java
short-circuit order. No `/ time_scale` anywhere (N2290 lesson). Tick wiring:
timer runs after the consumption fold, before the advance call;
`frame["timer_load_elapsed"]` stamped each enabled tick; computed `load_tick`
passed into the N2232 advance (replacing the `false` literal). Frame key
added to `_initial_frame` (0.0) + `tick_frame_state` default. Documented
limits (4) + advance docstring (2) + tick comment updated; first-fire
deviation documented in the pure docstring.

**N2232 test pin — coordinator fix at integration (11cb9158 precedent):**
the N2232 test (:315) pinned the old call text with the literal `false`.
The worker did NOT touch that file (outside the slice's file list) and
flagged it for the coordinator; the coordinator updated the pin (`false` →
`load_tick`) + the comment at :303-304 in integration commit `d4c14912`.

**Sibling Godot-proof safety (checked by the worker, since the timer now
fires live):** N2232 + N2279 proofs assert `items_unloaded == 0` only on tick
1 (clock 0→1, no fire) and assert no items on tick 2 — safe. N2313
intake-gate proof: tick 4 fires (clock 3→4) and unloads items, but no
assertion reads item counts — safe. N2296/N2293 proofs hold no payload (eff
0 → never fires) — safe.

## Commits

- Slice: `c960b4f9` (5 files, +1097/−15).
- Integration cherry-pick: `7bf5ab0b` (clean).
- Coordinator fix: `d4c14912` (N2232 test pin follows live load_tick).

## Tests

Targeted (new module `tests.test_c07_payload_unloader_load_timer`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot binary
on this VM (user order 2026-11-15). Exact-evidence 13/13. Siblings (7
Unloader modules) Ran 28 = 20 PASS + 7 proof tests Godot-absent + 1 expected
break (the N2232 test pin, fixed by the coordinator at integration — see
above), 0 other errors.
Full gate (wave advances-12 integration, PID 14401, 05:51–06:14): Ran 6342 tests in 1364.272s, FAILED (failures=262, skipped=5), 0 errors — 262/262 Godot-absent `AssertionError: unexpectedly None` (255 inherited + 7 new proof tests N2316–N2322).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+1/+2** → 11935/1757/1689/3170: symbols
`source_payload_unloader_load_timer_state_result.load_tick` /
`.timer_elapsed_after`; shards `payload_slices` + `payload_api_contracts`;
audit stays 1336. Scope estimated +3 symbols; actual +2 — the pure has 2
outputs, matching the N2280 precedent. DEFERRED 323 → 323: resolved #180
(`PayloadUnloader updateTile timer cadence (…)`), added 1 new entry
(`PayloadUnloader load timer first-fire deviation (…)`). Live front query +
movePayload/dumpPayload entries stay verbatim.

## Godot debt

- NEW proof `C07PayloadUnloaderLoadTimerProof` (6 keys:
  `live_tick_passes_load_tick_on_fire`,
  `timer_fires_at_load_time_over_efficiency`,
  `timer_fires_when_efficiency_recovers`, `timer_no_fire_below_threshold`,
  `timer_no_fire_when_efficiency_low`, `timer_no_fire_when_time_scale_zero`)
  — written but NEVER run; debt in GOAL.md §5.
