# Handoff N2472 — StackRouter live proximity query

## What this slice did

One live-fill pure + tick wiring (the N2394 pattern):
`source_stack_router_proximity_neighbours_live_fill_state` scans
the Edges proximity ring live from frame["world_tiles"] and stamps
frame["proximity_neighbours"] before the N2240 advance. 5 files,
+1345/−3, commit `d89e6457d` on
`slice/N2472-stack-router-live-proximity-query`.

## Key facts for the next agent

- **Ring order is Edges scan order, NOT the shared helper's** —
  the helper sorts atan2 WITHOUT normalizing (south first); Java
  sorts Mathf.angle normalized [0,360) (east first). The fill
  generates the ring inline. A shared ring-geometry follow-through
  is open; do NOT "fix" the helper inside another slice without
  scoping it.
- **team_map presence = building exists** — world_tiles has no
  team field (N2459 precedent); accepts_map missing key → false.
- **The signature takes `team`** — the same-team filter (:1887)
  needs it; an enemy entry would rotate cdump off Java.
- **Java's final order is ObjectSet hash order** — the port uses
  deterministic Edges scan order (documented deviation).
- **handleItem application is NOT ported** — the N2240 advance
  returns handed_off/handed_to as pure results and writes into no
  other building frame (cross-frame write waits for its own slice).
- Cite fix: trailing `target = target();` is StackRouter.java:52,
  not :51.
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #210 rewritten in place
  (238→238).

## Godot debt (this slice)

- NEW proof `C07StackRouterLiveProximityQueryProof` (6 keys) —
  never run. Live tick: 10 copper handoffs east/north alternating,
  cdump 2.
