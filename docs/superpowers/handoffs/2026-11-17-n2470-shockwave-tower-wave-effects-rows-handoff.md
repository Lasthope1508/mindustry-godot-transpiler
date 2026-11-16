# Handoff N2470 — ShockwaveTower wave effects rows

## What this slice did

One pure-only pure (no tick wiring): `source_shockwave_tower_wave_
effects_state` reports the wave effect / shoot sound / shake /
per-target hit effect call records for the N2247 fire verdict.
5 files, +873/−2, commit `c47d68982` on
`slice/N2470-shockwave-tower-wave-effects-rows`.

## Key facts for the next agent

- **The pure does NOT recompute the fire gate** — it takes `fired`
  (the N2247 verdict) caller-evaluated (the N2397 precedent).
- **Wave damage application is NOT in scope** (#142) — the pure
  reports one hit call per target; the damage itself waits.
- Def range 170f (Blocks.java:2043) vs class 110f — range_value is
  a param, either works.
- Events.fire is :99, not :97 (guard :98) — out of scope (#40).
- SSOT +4/+1/+1/+2 (exact est). DEFERRED #141 resolved (238→237).

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerWaveEffectsRowsProof` (6 keys) — never
  run.
