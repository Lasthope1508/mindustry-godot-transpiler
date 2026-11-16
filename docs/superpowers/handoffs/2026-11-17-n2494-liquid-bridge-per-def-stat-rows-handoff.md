# Handoff N2494 — LiquidBridge per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent): `source_liquid_bridge_per_def_stats_state`
returns {size, range, liquid_capacity, arrow_period,
arrow_time_scl, requirements}; unknown def → CLASS defaults.
5 files, +837/−1, commit `73ba4c09c` on
`slice/N2494-liquid-bridge-per-def-stat-rows`.

## Key facts for the next agent

- Def phase-conduit (Blocks.java:2385-2397): range 12 /
  liquidCapacity 100f / arrowPeriod 0.9f / arrowTimeScl
  2.75f / phase-fabric 5 / silicon 7 / metaglass 20 /
  titanium 10. Size 1 is Block.java:215 — the def does
  NOT set it.
- **LiquidBridge.java sets NO stat field** (only
  constructor flags :11-16) — class defaults live on the
  parents (range/arrows ItemBridge, size/capacity/
  requirements Block).
- **liquidCapacity fallback is 10.0, NOT −1.0** (coordinator
  ACCEPTED): the −1f field (Block.java:77) is a pre-init
  sentinel; Block.init() (:1418) replaces it with
  round(10f × consumeAmount) = 10f. Matches the 10.0 port
  precedent (SourceFactoryBuildState; N2412 live fill).
- **Follow-through:** the Pump precedent
  (`_liquid_capacity_for_block_id` returns −1f for unknown
  defs) CONFLICTS — no loaded block ever has −1f at
  runtime; reconcile in a later slice.
- **Family has TWO defs:** bridge-conduit (range 4 /
  capacity 100f, :2374-2384) still falls back to class
  defaults until its own entry (#38 in the 218 file) —
  deliberately NOT pinned in this proof.
  reinforced-bridge-conduit is DirectionLiquidBridge.
- Catalog quirk: bridge-conduit hasPower true in the
  catalog, but the Java def sets hasPower = false (:2380).
- SSOT +6/+1/+1/+2 (exact est). DEFERRED #42 resolved
  (225→224).

## Godot debt (this slice)

- NEW proof `C07LiquidBridgePerDefStatRowsProof` (6 keys)
  — never run. Live input feeds the N2275 transport pure
  (def flow 50.0 vs fallback 10.0).
