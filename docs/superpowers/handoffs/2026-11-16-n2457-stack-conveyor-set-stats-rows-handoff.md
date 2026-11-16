# Handoff N2457 — StackConveyor setStats rows

## What this slice did

One pure-only pure `source_stack_conveyor_stats_state` (no tick
wiring): items_moved_per_second = int(floor(cap*speed*60 + 0.5)) +
stat_key "itemsMoved" + stat_unit "itemsSecond" (tokens, not
localized strings). 5 files, +758/−1, commit `aa4f02419` on
`slice/N2457-stack-conveyor-set-stats-rows`.

## Key facts for the next agent

- **Brief def names were wrong:** no stack-conveyor /
  large-stack-conveyor defs — only plastanium-conveyor (40) and
  surge-conveyor (50); class default 0.
- **Mathf.round = floor(v+0.5)** for v ≥ 0 (arc Mathf.java:500-502).
- SSOT +3/+1/+1/+2 (exact est). DEFERRED #252 resolved (253→252).

## Godot debt (this slice)

- NEW proof `C07StackConveyorSetStatsRowsProof` (6 keys) — never
  run.
