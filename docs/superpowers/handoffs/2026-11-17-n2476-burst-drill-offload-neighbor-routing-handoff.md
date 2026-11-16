# Handoff N2476 — BurstDrill offload neighbor routing

## What this slice did

One routing pure + advance loop threading + tick refresh/
write-back: `source_burst_drill_offload_route_state` routes ONE
offloaded item (scan from the cdump snapshot, incrementDump
before each check, fallback handleItem(self())). The advance
loops it per dominant item with cdump threaded; the tick lands
routed items in neighbour stores (N2353 helper) and refreshes
the N2403 arrays for the dominant item before the advance
(probe frame `{"items": {dominant_item_name: 1}}`, live-managed
frames only). 5 files, +1164/−13, commit `e98b7a597` on
`slice/N2476-burst-drill-offload-neighbor-routing`.

## Key facts for the next agent

- **The N2403 arrays are STALE at offload time** — the tick
  refreshes them through the same fill (second call site; the
  N2403 count pin was narrowed by serial N2483 at integration).
- Cursor advances once per scanned neighbour INCLUDING the
  handling one; a full refused scan returns it to its start
  (N2286 invariant). Shared helper increment_dump_cursor_state.
- **#89 REWRITTEN IN PLACE** — routing live, per-def shake 4f
  + MultiEffect drillEffect rows still wait.
- SSOT +2/+1/+1/+2 (exact est). DEFERRED 234→234.

## Godot debt (this slice)

- NEW proof `C07BurstDrillOffloadNeighborRoutingProof` (6 keys)
  — never run. Live tick: surge-smelter takes 2 copper, melter
  0, cdump 14.
