# Handoff N2318 — ShockwaveTower timerCheck cadence

## What this slice did

Wired the ShockwaveTower timerCheck: a frame-local Interval-equivalent
accumulates `timer_check_elapsed` each enabled tick and passes a live
`check_ready` (fire at literal 8f) into the N2247 advance, replacing the
`false` literal. 5 files, +991/−6, commit `321e25c2` on
`slice/N2318-shockwave-timer-check`.

## Key facts for the next agent

- Pure `source_shockwave_tower_timer_check_state(...)` → `{check_ready,
  timer_elapsed_after, threshold}` — **3 keys, not 2:** the worker added
  `threshold` per the N2273 precedent; that is the source of this slice's +3
  symbols (the other timer slices return 2 keys and add +2).
- Literal 8f, NO `/ time_scale`. Reset 0 on fire; `time_scale <= 0` →
  threshold INF, elapsed still accumulates.
- Candidates stay the empty list — no live bullet/unit scan added.
- Live proof design: both live towers seed counter 79.0 (not 80.0) so the
  N2187 shouldConsume gate stays open and the charge lands exactly at 80.0
  before the advance gate evaluates.
- SSOT +3/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED 323 (−1+1:
  resolved the timer entry, added the first-fire deviation entry).
- Cites: ShockwaveTower.java:73/:31/:23, TimerComp.java:10-13, arc
  Interval.java:20-26 — all verified correct.

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerTimerCheckProof` (6 keys) — never run.
