# Handoff N2319 — PayloadLoader load timer cadence

## What this slice did

Wired the PayloadLoader load timer: a frame-local Interval-equivalent
accumulates `timer_load_elapsed` after the consumption fold and passes a live
`load_tick` (fire at `loadTime / efficiency`, 2f/eff) into the N2231 advance,
replacing the `false` literal. 6 files, +1045/−14, commit `f9e77e49` on
`slice/N2319-loader-load-timer`.

## Key facts for the next agent

- Pure `source_payload_loader_load_timer_state(elapsed, source_delta,
  time_scale, efficiency, load_time)` → `{load_tick, timer_elapsed_after}`:
  `load_tick = (eff > 0.01) and (elapsed >= loadTime / eff)`; elapsed
  accumulates unconditionally (Java short-circuit: eff ≤ 0.01 never calls
  timer(), but Time.time advances, so a recovered efficiency fires at once);
  `time_scale <= 0` never fires (threshold INF); eff ≤ 0 is the infinite-time
  branch (division guarded); reset 0.0 on fire.
- **Threshold divides by efficiency, never timeScale** (N2290 lesson); the
  test pins `assertNotIn('load_time / time_scale')`.
- The `efficiency > 0.01 and load_tick` gate stays INSIDE the N2231 advance
  (:446) — the timer pure ONLY computes load_tick, never duplicates the gate.
- **The N2231 test pin was updated in this slice** (:352, `false` load_tick
  literal → new call text) — N2290/N2304 precedent.
- Disabled-loader interaction: Java folds efficiency to 0 when disabled
  (BuildingComp.java:1955-1957); the port fold skips when disabled, leaving
  the frame value stale. The timer reads the same frame efficiency as the
  advance gate, so both stay mutually consistent — a shared pre-existing gap
  for the driver-wide disabled-early-return slice, not a new timer deviation.
- Brief SSOT estimate +3 was one high — actual +2. Brief "Loader ×6 modules"
  was one low — 7 Loader test modules exist.
- SSOT +2/+1/+1/+2. DEFERRED 323 (−1 #171 + 1 first-fire deviation).
- Cites: PayloadLoader.java:157/:20/:22, TimerComp.java:10-13, arc
  Interval.java:20-26, Time.java:75, Blocks.java:6686/6687 — all verified
  correct.

## Godot debt (this slice)

- NEW proof `C07PayloadLoaderLoadTimerProof` (6 keys) — never run.
