# Handoff N2455 — Constructor config/filter rows

## What this slice did

Three pure-only pures (no tick wiring — the live recipe fill is
#99, a separate slice): `source_constructor_can_produce_state`
(7 Java conditions, Java order) +
`source_constructor_config_state` (set/clear/none; reset runs
BEFORE the canProduce gate :33 before :34) +
`source_constructor_stats_state` (output "@x@ ~ @x@" +
buildSpeed RAW). 5 files, +1049/−1, commit `e04f7d484` on
`slice/N2455-constructor-config-filter-rows`.

## Key facts for the next agent

- **Brief pin numbers were wrong:** #84/#86 in the merged 253 are
  LightBlock entries, not Constructor — the worker pinned #99
  (live recipe config fill) + #169 (frame items intake) instead.
- **Def overrides:** constructor filter 7 entries, buildSpeed
  0.6f, min/max 1/2; large-constructor filter empty, min 3/max 4,
  buildSpeed 0.75f; class buildSpeed default 0.4f.
- SSOT +6/+1/+3/+6 (exact est). DEFERRED #8 resolved (253→252).

## Godot debt (this slice)

- NEW proof `C07ConstructorConfigFilterRowsProof` (6 keys) — never
  run.
