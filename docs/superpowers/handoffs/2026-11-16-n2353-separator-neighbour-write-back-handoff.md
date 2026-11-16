# Handoff N2353 — Separator offload neighbour write-back

## What this slice did

Added a shared neighbour item write-back helper and wired the Separator
offload through it (offload before dump, Java order). 6 files, +1160/−11,
commit `77454fd69` on `slice/N2353-neighbour-write-back-separator`.

## Key facts for the next agent

- Shared helper `source_neighbour_item_write_back_state` on
  SourceBuildingItemState: writes an offloaded item into the neighbour's
  frame; belt neighbour queues via the conveyor queue meta key; no frame →
  `no_frame`; no sprite → `no_sprite`.
- Separator advance exposes `offload_neighbour_index` / `offload_routed`
  (unregistered API shape, the N2343 precedent — a schema-sync slice later
  folds them into the advance result schema). Tick wires the helper after
  the advance.
- **Index↔ring convention:** index i = ring cell i — live-fill slices must
  fill `dump_neighbour_*` in ring order.
- Belt vs building is distinguished by the conveyor queue meta key (checked
  first); meta-key coverage is 41 keys, enough for every family with a tick
  frame (core/conduit/wall → no_frame).
- SSOT +3/+1/+1/+2 (helper returns 3 keys). DEFERRED 326→326 (−1 #322 +1
  write-back follow-ups entry).
- Backlog: the other write-backs (#251/#248/#238/#266/#269/#279 + liquid
  helper #254/#257/#260/#263/#276) follow the N2353 helper in later waves.

## Godot debt (this slice)

- NEW proof `C07SeparatorNeighbourWriteBackProof` (7 keys) — never run.
