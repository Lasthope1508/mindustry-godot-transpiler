# Handoff N2414 — Fracker fraction linked-tiles live fill

## What this slice did

New pure `source_fracker_linked_tiles_live_fill_state(world_tiles,
cell, size)` → `{proximity_linked_tiles}` — scans the live
tile map and builds the linked-tile entries the N2305 tick
recomputes validTiles/boost from. Tick wires the fill BEFORE
the N2305 recompute; supplied arrays win + live flag refresh.
5 files, +1091/−7, commit `5d99b309d` on
`slice/N2414-fracker-linked-tiles-live-fill`.

## Key facts for the next agent

- **world_tiles does NOT carry floor fields** — the pure
  defines the minimal extension `{floor_is_liquid,
  oil_attribute, is_deep}` in its input contract; the live
  tile producer waits for its own slice (follow-through, not
  a DEFERRED entry).
- **Linked tiles = FOOTPRINT size×size, NOT the ring**
  (`Tile.getLinkedTiles`, dx outer/dy inner, sizeOffset −1
  for size 3). Empty map → empty list.
- Pure placed at end of file (after the tick) so the :633 pin
  does not shift.
- SSOT +1/+1/+1/+2. DEFERRED #247 resolved (291→290).

## Godot debt (this slice)

- NEW proof `C07FrackerLinkedTilesLiveFillProof` (6 keys) —
  never run.
