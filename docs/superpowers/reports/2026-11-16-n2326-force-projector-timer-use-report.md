# Report N2326 — ForceProjector timerUse cadence + consume application

**Slice:** N2326 — ForceProjector timerUse (frame-local Interval-equivalent
at 350f/timeScale supplying consume_tick to the N2235 advance + driver
removes 1 phaseFabric when the advance reports consumed). **Wave:**
advances-13.
**Commit:** `6bd02bf9` on `slice/N2326-force-projector-timer-use` (base
`4349a660`).
**Files:** 7, +1190/−37.

## Source

Java gates the phase consume on the timer: `if(phaseValid && !broken &&
timer(timerUse, phaseUseTime / timeScale) && efficiency > 0){ consume(); }`
(ForceProjector.java:211-213), `phaseUseTime = 350f` (ForceProjector.java:
32). The threshold DIVIDES by timeScale (unlike the advances-12 timer
literals — N2290 lesson does not apply here; the Java expression divides).
`phaseValid` is `itemConsumer != null && itemConsumer.efficiency(this) >
0` (:207). The consume itself removes the stack through
ConsumeItems.trigger (ConsumeItems.java:44-48, `build.items.remove(
stack.item, Math.round(stack.amount * multiplier.get(build)));`).
All brief/SCOPE cites verified correct by the worker — no scope
corrections.

## Implementation

New pure `source_force_projector_timer_use_state(...)` → `{consume_tick,
timer_elapsed_after, threshold}` (frame-local Interval-equivalent,
N2266/N2269/N2273/N2280/N2281/N2283 pattern): accumulate UNSCALED
source_delta unconditionally, fire at 350f/time_scale, reset 0 on fire,
`time_scale <= 0` → threshold INF (elapsed still accumulates). The tick
passes the live `consume_tick` into the N2235 advance; when the advance
reports consumed, the driver removes 1 phaseFabric via the shared
inventory helper.

**Follow-through (2 extra test files):** BOTH the N2235 pin (:281) AND the
N2261 pin (:193) — the brief missed the second pin; the worker found it.

**Deviations:** first-fire delay (DEFERRED entry); gate-closed reset +
enabled-only clock (no separate entry, N2318/N2195 precedent).

## Commits

- Slice: `6bd02bf9` (7 files, +1190/−37).
- Integration cherry-pick: `7b10d012` (clean).

## Tests

Targeted (new module `tests.test_c07_force_projector_timer_use`): 3/4 PASS
+ proof test FAIL exactly AssertionError: unexpectedly None — NO Godot
binary on this VM (user order 2026-11-15). Exact-evidence 19/19. Siblings
Ran 20 = 15 PASS + 5 proof, 0 other failures.
Full gate (wave advances-13 integration, PID 4634, 06:38–07:02): Ran 6366 tests in 1287.324s, FAILED (failures=268, skipped=5), 0 errors — 268/268 Godot-absent `AssertionError: unexpectedly None` (262 inherited + 6 new proof tests N2324–N2329; N2323 adds no test).

## SSOT / DEFERRED

SSOT single-slice **+3/+1/+1/+2** → 11952/1764/1696/3184 (exactly the SCOPE
estimate); audit stays 1336. DEFERRED 325→326 (+1: #180 rewritten in place
+ 1 new first-fire deviation entry).

## Godot debt

- NEW proof `C07ForceProjectorTimerUseProof` (6 keys:
  `timer_fires_at_use_time_over_time_scale`,
  `timer_no_fire_below_threshold`, `timer_no_fire_when_time_scale_zero`,
  `timer_resets_elapsed_on_fire`, `live_tick_consumes_phase_fabric_on_fire`,
  `consume_tick_alone_does_not_consume`) — written but NEVER run; debt in
  GOAL.md §5.
