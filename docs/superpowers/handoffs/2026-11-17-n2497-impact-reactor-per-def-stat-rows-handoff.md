# Handoff N2497 — ImpactReactor per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent): `source_impact_reactor_per_def_stats_state`
returns {size, health, power_production, item_duration,
liquid_capacity, requirements}; unknown def → CLASS defaults.
5 files, +824/−1, commit `6f357fd2c` on
`slice/N2497-impact-reactor-per-def-stat-rows`.

## Key facts for the next agent

- Def (Blocks.java:2632-2645): size 4 / health 900 /
  powerProduction 130f / itemDuration 140f / liquidCapacity
  80f / lead 500 / silicon 300 / graphite 400 / thorium
  100 / surge-alloy 250 / metaglass 250. Single def.
- **Brief correction:** size/health are Block.java fields
  (:215/:190), NOT ImpactReactor.java / PowerGenerator.java.
- Class fallback: size 1 / health 40 post-init (same
  accepted decision as N2495/N2496) / powerProduction 0f
  (PowerGenerator.java:25, NO initializer → Java default
  0f) / itemDuration 60f (ImpactReactor.java:20) /
  liquidCapacity 30f (:26) / no requirements.
- consumePower(25f) is DEF-only (:2642) — the class has
  no ConsumePower, so the live input feeds the N2450 stats
  pure with has_cons_power=false (never divides by the 0f
  class powerProduction).
- **Catalog gap:** content_registry.json has NO
  `liquidCapacity` key for impact-reactor — the pure reads
  80f from Java. A catalog liquidCapacity-capture slice
  could follow.
- SSOT +6/+1/+1/+2 (exact est). DEFERRED #59 resolved
  (225→224).

## Godot debt (this slice)

- NEW proof `C07ImpactReactorPerDefStatRowsProof` (6 keys)
  — never run.
