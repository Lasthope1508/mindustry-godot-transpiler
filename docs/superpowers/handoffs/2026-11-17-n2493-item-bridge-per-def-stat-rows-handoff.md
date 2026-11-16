# Handoff N2493 — ItemBridge per-def stat rows

## What this slice did

One pure-only per-def stats pure (VERIFICATION slice, N2304 /
N2442 precedent): `source_item_bridge_per_def_stats_state`
returns {size, range_value, transport_time, arrow_period,
arrow_time_scl, requirements}; unknown def → CLASS defaults.
5 files, +777/−1, commit `65471c416` on
`slice/N2493-item-bridge-per-def-stat-rows`.

## Key facts for the next agent

- Def phase-conveyor (Blocks.java:2116-2125): range 12 /
  transportTime 2f / arrowPeriod 0.9f / arrowTimeScl 2.75f /
  phase-fabric 5 / silicon 7 / lead 10 / graphite 10.
  The def sets NO size — size 1 is the class default.
- Class fallback: range 0 / transportTime 0f (fields have
  NO initializer — Java defaults, ItemBridge.java:27/:28),
  arrowPeriod 0.4f / arrowTimeScl 6.2f (:37/:38).
- **Key is `range_value`, not `range`** — `range` shadows
  the GDScript builtin (N2490 precedent, N2456 lesson).
  Symbol type is `int` (Java `public int range`).
- Family = 1 def; bridge-conveyor is BufferedItemBridge
  (a different class, out of scope).
- Live input feeds the rows into the N2197 linkValid pure
  (12-cell link validates under def range 12, fails under
  class range 0).
- SSOT +6/+1/+1/+2 (exact est). DEFERRED #39 resolved
  (225→224).

## Godot debt (this slice)

- NEW proof `C07ItemBridgePerDefStatRowsProof` (6 keys)
  — never run.
