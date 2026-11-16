# Handoff N2451 — BuildTurret warmup/stats rows

## What this slice did

Two pure-only pures (N2442 precedent, no tick wiring):
`source_build_turret_warmup_state` (accessor, verbatim) +
`source_build_turret_stats_state` (stat_key "buildSpeed",
stat_value RAW — percent formatting is display-time UI). 5 files,
+757/−1, commit `40888bad2` on
`slice/N2451-build-turret-warmup-stats-rows`.

## Key facts for the next agent

- **warmup() overrides the BuildingComp default** (return 0f);
  the field is ticked live since N2243. **Def buildSpeed 1.5f**
  (Blocks.java:2003) → displays 150%.
- SSOT +3/+1/+2/+4 (exact est). DEFERRED #85 resolved (258→257).

## Godot debt (this slice)

- NEW proof `C07BuildTurretWarmupStatsRowsProof` (6 keys) — never
  run.
