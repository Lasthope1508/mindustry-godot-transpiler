# Handoff N2496 — StackRouter per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent): `source_stack_router_per_def_stats_state`
returns {size, speed, item_capacity, health, glow_alpha,
glow_color, requirements}; unknown def → CLASS defaults.
5 files, +976/−1, commit `eaa6633f1` on
`slice/N2496-stack-router-per-def-stat-rows`.

## Key facts for the next agent

- Def surge-router (Blocks.java:2255-2268): speed 6f /
  health 130 / surge-alloy 5 / tungsten 1. Speed is the
  plain 6f form (updateTile charge cap), NOT the
  StackConveyor 5f/60f form.
- **Class defaults span THREE files:** size 1 / health /
  requirements Block.java (:215/:190/:356), speed 5f
  DuctRouter.java:19 (overrides Router.java:13's 8f);
  only itemCapacity 10 + glow 1f/Pal.redLight from
  StackRouter.java itself. The def sets NO size/
  itemCapacity/glow → the row carries class values.
- Health fallback 40 init-resolved — same accepted
  decision as N2495/N2497 (sentinel −1 → Block.init 40).
- Single def; catalog has no size/itemCapacity/glow rows
  → the driver reads header constants.
- Only the 4 canonical JSON files changed — NO shard
  changes (no shard selector matches this owner).
- SSOT +7/+1/+1/+2 (exact est). DEFERRED #55 resolved
  (225→224).

## Godot debt (this slice)

- NEW proof `C07StackRouterPerDefStatRowsProof` (6 keys)
  — never run. Live input composes the N2442 stats pure,
  the N2433 draw glow, and the N2240 advance.
