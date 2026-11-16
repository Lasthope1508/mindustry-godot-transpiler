# Handoff N2486 — BurstDrill per-def shake/effect rows

## What this slice did

One pure-only per-def pure: `source_burst_drill_per_def_offload_effects_state`
returns {shake, drill_effect} — shake 4.0 + the def MultiEffect
children as an ordered token list, class defaults (shake 2.0,
["Fx.shockwave"]) for an unknown def id. NO tick wiring; the
N2469 pure is UNCHANGED. 5 files, +831/−2, commit `09ed6f8e1`
on `slice/N2486-burst-drill-per-def-shake-effect-rows`.

## Key facts for the next agent

- **The wrap 2nd arg is a ROTATION** (Effect.java:101) —
  wrap_rotation 40f/30f/45f, never a scale.
- Impact-drill: [Fx.mineImpact, Fx.drillSteam,
  Fx.mineImpactWave.wrap(Pal.redLight, 40f)]; eruption-drill:
  [Fx.mineImpact, Fx.drillSteam, Fx.dynamicSpikes.wrap(
  hydrogen.color, 30f), Fx.mineImpactWave.wrap(hydrogen.color,
  45f)]. MultiEffect children fire in order — list order IS
  firing order.
- drillSound / drillSoundVolume do NOT differ per def.
- **#88 REWRITTEN IN PLACE** — per-neighbour capacity
  refinement + produced stats still wait.
- SSOT +2/+1/+1/+2 (exact est). DEFERRED 231→231. Register
  was stale-base (N2482 list) — allowlisted at merge.

## Godot debt (this slice)

- NEW proof `C07BurstDrillPerDefShakeEffectRowsProof` (6 keys)
  — never run.
