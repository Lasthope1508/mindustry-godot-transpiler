# Handoff N2316 — PointDefenseTurret retarget cadence

## What this slice did

Wired the PointDefenseTurret retarget timer: a frame-local
Interval-equivalent accumulates `timer_retarget_elapsed` each enabled tick
and passes a live `retarget_tick` (fire at literal 5f) into the N2229
advance, replacing the `false` literal. 6 files, +1044/−28, commit `9e2a8a3d`
on `slice/N2316-point-defense-retarget-cadence`.

## Key facts for the next agent

- Pure `source_point_defense_turret_retarget_timer_state(elapsed,
  source_delta, time_scale, duration)` → `{retarget_tick,
  timer_elapsed_after}` (N2280/N2290 pattern): UNSCALED source_delta, literal
  5f (NO `/ time_scale`), reset 0 on fire, `time_scale <= 0` → threshold INF
  (elapsed still accumulates).
- Bullets stay the empty list — no live bullet query added. Selection logic
  untouched. Java re-acquires UNCONDITIONALLY on a timer tick, even to null
  with no qualifying candidate — the N2229 advance already does this; a fire
  with the empty bullet list clears the target to null.
- **The N2229 test pin was updated in this slice** (`test_c07_point_defense_turret_update_tile.py:246`,
  `[], false` → live `retarget_tick`) — N2313 precedent.
- Older PD proofs (N2229/N2217/N2151) run ≤2 ticks per segment, so the 5-tick
  timer never fires in them — no proof changes needed.
- Brief SSOT estimate +3 was one high — the pure returns 2 keys → +2.
- SSOT +2/+1/+1/+2. DEFERRED 323 → 324: entry #181 REWRITTEN (cadence live,
  other clauses kept) + 1 new first-fire deviation entry.
- Cites: PointDefenseTurret.java:65/:20/:21, TimerComp.java:10-13, arc
  Interval.java:20-26 — all verified correct.

## Godot debt (this slice)

- NEW proof `C07PointDefenseTurretRetargetCadenceProof` (6 keys) — never run.
