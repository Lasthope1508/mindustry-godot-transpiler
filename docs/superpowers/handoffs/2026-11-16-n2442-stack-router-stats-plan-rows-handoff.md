# Handoff N2442 — StackRouter stats/plan rows

## What this slice did

Two pure-only pures (N2419 precedent, no tick wiring):
`source_stack_router_stats_state` (60/speed*capacity,
itemsMoved/itemsSecond) + `source_stack_router_draw_plan_state`
(base + top at rotation*90, minimap rgba int, rotatedOutput
false). 7 result symbols. 5 files, +891/−1, commit `b782ec48f`
on `slice/N2442-stack-router-stats-plan-rows`.

## Key facts for the next agent

- **No "stack-router" def** — surge-router is the only
  StackRouter def (speed 6f → 100/s; duct-router 4f → 15;
  class default 120). All three rates are in the proof.
- **Cite corrections:** speed DuctRouter.java:19 (brief :20),
  itemCapacity StackRouter.java:20 (brief :22).
- **minimap_color is the rgba8888 int**, not a string token
  (surge-alloy 0xf3e979ff = signed −202802689).
- SSOT +7/+1/+2/+4 (exact est). DEFERRED #68 resolved (266→265).

## Godot debt (this slice)

- NEW proof `C07StackRouterStatsPlanRowsProof` (6 keys) — never
  run.
