# Handoff N2326 — ForceProjector timerUse cadence + consume application

## What this slice did

Wired the ForceProjector timerUse cadence: a new pure (frame-local
Interval-equivalent at 350f/timeScale) supplies consume_tick to the N2235
advance, and the driver removes 1 phaseFabric when the advance reports
consumed. 7 files, +1190/−37, commit `6bd02bf9` on
`slice/N2326-force-projector-timer-use`.

## Key facts for the next agent

- Pure `source_force_projector_timer_use_state(elapsed, source_delta,
  time_scale, duration)` → `{consume_tick, timer_elapsed_after,
  threshold}`: accumulate UNSCALED source_delta unconditionally, fire at
  350f/time_scale, reset 0 on fire, `time_scale <= 0` → threshold INF
  (elapsed still accumulates).
- The threshold DIVIDES by timeScale here (Java `timer(timerUse,
  phaseUseTime / timeScale)`, ForceProjector.java:211-213; phaseUseTime
  350f, :32) — unlike the advances-12 timer literals (N2290 lesson does
  not apply).
- The consume application removes the stack through ConsumeItems.trigger
  (ConsumeItems.java:44-48) via the shared inventory helper.
- **Follow-through covered BOTH pins:** N2235 pin :281 AND N2261 pin :193
  — the brief missed the second pin; the worker found it.
- All brief/SCOPE cites verified correct — no scope corrections.
- Deviations: first-fire delay (DEFERRED entry); gate-closed reset +
  enabled-only clock (no separate entry, N2318/N2195 precedent).
- SSOT +3/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED 325→326 (+1:
  #180 rewritten in place + 1 first-fire deviation entry).

## Godot debt (this slice)

- NEW proof `C07ForceProjectorTimerUseProof` (6 keys) — never run.
