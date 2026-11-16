# Handoff N2463 — LiquidBridge link/findLink/linkValid rows

## What this slice did

Three pure-only pures (no tick wiring, mirror N2460/N2461):
`source_liquid_bridge_link_valid_state` (10 params — the brief's 9
missed the 4th block predicate) + `source_liquid_bridge_find_link_state`
(tile Dict-or-null, not tile_exists) + `source_liquid_bridge_config_state`
(point2/integer/clear/none; config_value IS the config() getter).
5 files, +1083/−1, commit `47215d191` on
`slice/N2463-liquid-bridge-link-rows`.

## Key facts for the next agent

- **link_valid needs 10 params:** the Java block conjunct has 4
  distinct predicates. The cross-def case (tile = phase-conveyor,
  other = bridge-conduit) is INVALID in Java and reachable via
  `linked()` (:465) — pinned in the proof.
- **find_link takes the tile Dict**, not a tile_exists bool — the
  `lastBuild.tile != tile` identity check needs it.
- **ItemBridge.config() has NO null check** — null-tile
  config_value is a documented fallback (N2461 precedent), not Java.
- **LiquidBridge does NOT override** linkValid/findLink/config —
  only updateTransport/doDump. The pures port the ItemBridge
  methods (per-driver pures are the established pattern).
- **Placement pure untouched:** `auto_link_placement_state` (:364)
  is placement-time, NOT the runtime findLink.
- **Line cites:** link = -1 is :198, positionsValid :157-165,
  config() :500-501, phase-conduit range Blocks.java:2388.
- SSOT +4/+1/+3/+6 (exact est). DEFERRED #48 resolved (246→245).

## Godot debt (this slice)

- NEW proof `C07LiquidBridgeLinkRowsProof` (6 keys) — never run.
