# Handoff N2449 — StackRouter config rows

## What this slice did

One pure-only config pure `source_stack_router_config_state`
(no tick wiring): sort_item (set/clear/unchanged) + recache_called
+ minimap_updated + configure_call (CALL record). 5 files, commit
`bd1987909` on `slice/N2449-stack-router-config-rows`.

## Key facts for the next agent

- **recache() = BuildingComp.recache** (:1285-1287, CALL flag) —
  not Tile.recache. **No equality condition:** same-item configure
  still recaches + updates the minimap (N2443 lesson).
- **#65 also listed handleStack/handleItem/removeStack** (not
  config) — handleItem stays under N2324/N2332; the coordinator
  added a narrow handleStack/removeStack entry at merge.
- SSOT +4/+1/+1/+2 (exact est). DEFERRED #65 resolved (258→257).

## Godot debt (this slice)

- NEW proof `C07StackRouterConfigRowsProof` (6 keys) — never run.
