# Handoff N2492 — ShockwaveTower per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent): `source_shockwave_tower_per_def_stats_state`
returns {size, range_value, reload_value, requirements}; unknown
def → CLASS defaults. 5 files, +719/−1, commit `8ac2299da` on
`slice/N2492-shockwave-tower-per-def-stat-rows`.

## Key facts for the next agent

- Def (Blocks.java:2038-2044): size 3, range 170f, reload 80f,
  surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100.
  Single def.
- Class fallback: size 1 (Block.java:215) / range 110f
  (ShockwaveTower.java:25) / reload 90f — the EVALUATED
  `60f * 1.5f` (:26) / requirements {} (Block.java:356).
- Catalog row matches the def block exactly.
- Live input feeds the def vs class reload into the N2390
  sense pure (45/80 = 0.5625 vs 45/90 = 0.5, bare ratio,
  no clamp).
- **Follow-through:** the tick still reads reload/range
  from the catalog block, not from this pure — a future
  slice could wire the pure as the tick's def-values
  source (no DEFERRED entry, N2442 precedent).
- SSOT +4/+1/+1/+2 (exact est). DEFERRED #36 resolved
  (225→224).

## Godot debt (this slice)

- NEW proof `C07ShockwaveTowerPerDefStatRowsProof` (6 keys)
  — never run.
