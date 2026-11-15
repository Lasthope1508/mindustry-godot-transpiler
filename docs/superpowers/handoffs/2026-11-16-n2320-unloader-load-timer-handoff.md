# Handoff N2320 — PayloadUnloader load timer cadence

## What this slice did

Wired the PayloadUnloader load timer: a frame-local Interval-equivalent
accumulates `timer_load_elapsed` after the consumption fold and passes a live
`load_tick` (fire at `loadTime / efficiency`, 2f/eff) into the N2232 advance,
replacing the `false` literal. 5 files, +1097/−15, commit `c960b4f9` on
`slice/N2320-unloader-load-timer`.

## Key facts for the next agent

- Pure `source_payload_unloader_load_timer_state(elapsed, source_delta,
  time_scale, efficiency, load_time)` → `{load_tick, timer_elapsed_after}`:
  threshold `load_time / efficiency` (INF guard on `time_scale <= 0` or
  `efficiency <= 0`); elapsed accumulates unconditionally; `load_tick = (eff
  > 0.01) and (elapsed >= threshold)`; reset to 0.0 only on fire — the Java
  short-circuit order. No `/ time_scale` anywhere (N2290 lesson).
- Frame key added to `_initial_frame` (0.0) + `tick_frame_state` default.
- The `efficiency > 0.01 and load_tick` gate stays INSIDE the N2232 advance
  (:433) — the timer pure ONLY computes load_tick.
- **The N2232 test pin was fixed by the COORDINATOR at integration**
  (d4c14912, 11cb9158 precedent): the worker flagged it and did not touch the
  file (outside the slice's file list). Pin :315 (`false` → `load_tick`) +
  comment :303-304.
- Sibling proof safety checked: N2232/N2279 (tick 1 only, no fire),
  N2313 (tick 4 fires but no assertion reads item counts), N2296/N2293 (no
  payload, eff 0, never fires) — all safe, no proof changes.
- Scope estimated +3 symbols; actual +2 (2 outputs, N2280 precedent).
- SSOT +2/+1/+1/+2. DEFERRED 323 (−1 #180 + 1 first-fire deviation).
- Cites: PayloadUnloader.java:69/:68/:18, PayloadLoader.java:20/:22,
  TimerComp.java:10-13, arc Interval.java:20-26/:29, Time.java:75 — all
  verified correct; the test pins them by line number.

## Godot debt (this slice)

- NEW proof `C07PayloadUnloaderLoadTimerProof` (6 keys) — never run.
