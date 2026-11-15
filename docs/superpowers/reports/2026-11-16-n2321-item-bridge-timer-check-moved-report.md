# Report N2321 — ItemBridge timerCheckMoved snapshot

**Slice:** N2321 — ItemBridge timerCheckMoved snapshot (frame-local Interval, 30f; snapshot before advance). **Wave:** advances-12.
**Commit:** `c551588e` on `slice/N2321-item-bridge-timer-check-moved` (base `0b18eff8`).
**Files:** 5, +1048/−4.

## Source

Java snapshots the moved flag every 30 ticks: `if(timer(timerCheckMoved,
30f)){ wasMoved = moved; moved = false; }` (ItemBridge.java:320-323),
`public final int timerCheckMoved = timers++;` (:25). `TimerComp.timer`
returns false for infinite time (TimerComp.java:10-13); `Interval.get` fires
when `Time.time - times[id] >= time` (arc Interval.java:20-26). The N2225
pure reads `was_moved`/`moved` from the frame and returns `moved` but NOT
`was_moved` (SourceItemBridgeBuildState.gd:251, :257-258, :297) — the
snapshot never happened live. All brief/SCOPE cites verified correct by
grep.

## Implementation

New pure `source_item_bridge_timer_check_moved_state(...)` → `{fired,
timer_elapsed_after, was_moved}` (N2280/N2290 pattern): accumulate UNSCALED
source_delta unconditionally, fire at the literal 30f (NO `/ time_scale`),
reset 0 on fire, `time_scale <= 0` → threshold INF, elapsed still
accumulates. The timer pure runs BEFORE the advance call and stamps the
snapshot: on fire, `was_moved = moved` and `moved = false`.

**Design addition vs the brief:** the pure takes an extra input `was_moved`
— the pure returns `was_moved` even when not firing, so the driver stamps
the frame unconditionally. **Shared symbol:** `moved` is shared with N2225
(owner transport unchanged, verified) — the N2321 ledger lists 4 symbols
(fired / timer_elapsed_after / was_moved / moved) but only 3 are new; the
wave SSOT merge counts +3 for this slice. First-fire deviation documented in
the docstring + DEFERRED.

**Live tick pins the literal-30 threshold at overdrive** (time_scale 2.0:
29+1 fires, 9+1 doesn't — absolute elapsed, not scaled).

## Commits

- Slice: `c551588e` (5 files, +1048/−4).
- Integration cherry-pick: `9dc95b2e` (clean).

## Tests

Targeted (new module `tests.test_c07_item_bridge_timer_check_moved`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 16/16. Siblings:
ItemBridge 6 modules Ran 24 = 18 PASS + 6 proof + LiquidBridge 4 modules Ran
16 = 12 PASS + 4 proof, 0 other failures.
Full gate (wave advances-12 integration, PID 14401, 05:51–06:14): Ran 6342 tests in 1364.272s, FAILED (failures=262, skipped=5), 0 errors — 262/262 Godot-absent `AssertionError: unexpectedly None` (255 inherited + 7 new proof tests N2316–N2322).

## SSOT / DEFERRED

SSOT single-slice **+3 new/+1/+1/+2** → 11936/1757/1689/3170 (exactly the
SCOPE estimate): new symbols `...timer_check_moved_state_result.fired` /
`.timer_elapsed_after` / `.was_moved`; `...update_transport_state_result.moved`
is shared with N2225 (already registered); audit stays 1336. DEFERRED 323
(−1 #163 + 1 first-fire deviation).

## Godot debt

- NEW proof `C07ItemBridgeTimerCheckMovedProof` (6 keys:
  `live_tick_snapshots_before_advance`, `snapshot_clears_moved_on_fire`,
  `snapshot_copies_moved_to_was_moved`, `timer_fires_at_thirty_ticks`,
  `timer_no_fire_below_threshold`, `timer_no_fire_when_time_scale_zero`) —
  written but NEVER run; debt in GOAL.md §5.
