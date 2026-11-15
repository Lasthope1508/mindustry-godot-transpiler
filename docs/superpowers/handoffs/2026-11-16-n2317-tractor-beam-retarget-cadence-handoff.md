# Handoff N2317 — TractorBeamTurret retarget cadence

## What this slice did

Wired the TractorBeamTurret retarget timer: a frame-local
Interval-equivalent accumulates `timer_retarget_elapsed` each enabled tick
and passes a live `retarget_tick` (fire at literal 5f) + frame-input
`unit_candidates` (default `[]`) into the N2230 advance, replacing the
`[], false` literal. 7 files, +1111/−45, commit `8e1228b8` on
`slice/N2317-tractor-beam-retarget-cadence`.

## Key facts for the next agent

- Pure `source_tractor_beam_turret_retarget_timer_state(elapsed,
  source_delta, time_scale, duration)` → `{retarget_tick,
  timer_elapsed_after}` (N2280/N2290 pattern): UNSCALED source_delta, literal
  5f (NO timeScale division), reset 0 on fire, `time_scale <= 0` → threshold
  INF (elapsed still accumulates). Const
  `SOURCE_TRACTOR_BEAM_TURRET_RETARGET_DURATION := 5.0`.
- Candidates ride `frame["unit_candidates"]` (default `[]`) — with no frame
  key, behavior is identical to the old `[]` literal. No gating stamp needed:
  the advance ignores candidates when retarget_tick is false.
- **Activation does not stop the clock:** the timer runs in the driver BEFORE
  the advance call, matching Java (global Time.time keeps growing during
  activation; Java fires on the first check after activation ends).
- **The N2230 test pin + comments were updated in this slice** (`[], false`
  at :267 → live retarget_tick; 2 stale comments in the test, 1 stale comment
  in the N2230 proof) — N2290/N2300 precedent. The N2230 proof needs no value
  change (2 live ticks → clock 2.0 < 5, no fire) — comment-only, NO re-run.
- Parallax does not override retargetTime (Blocks.java:3640-3653) — class 5f
  is the only value.
- Brief SSOT estimate +3 was wrong — actual +2. SCOPE's DEFERRED math (−7)
  was wrong for TB (and PD): #182 is a COMBINED live-fill entry, rewritten in
  place, not removed.
- SSOT +2/+1/+1/+2. DEFERRED 323 → 324: entry #182 REWRITTEN (cadence live)
  + 1 new first-fire deviation entry.
- Cites: TractorBeamTurret.java:87/:20/:21, TimerComp.java:10-13, arc
  Interval.java:20-26, Time.java:75 — all verified correct.

## Godot debt (this slice)

- NEW proof `C07TractorBeamTurretRetargetCadenceProof` (6 keys) — never run.
