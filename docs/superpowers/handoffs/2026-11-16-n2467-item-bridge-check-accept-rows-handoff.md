# Handoff N2467 — ItemBridge checkAccept facing rows

## What this slice did

One pure-only pure (no tick wiring):
`source_item_bridge_check_accept_state(tile_null, is_linked,
link_valid, rel, rel2)` → {accepts} — tile_null || is_linked →
true; link_valid → rel != rel2; else false. 5 files, +837/−1,
commit `9119630a3` on `slice/N2467-item-bridge-check-accept-rows`.

## Key facts for the next agent

- **relativeTo is the THIRD option:** BuildingComp.relativeTo(Tile)
  :526-528 → relativeTo(int,int) :545-546 → Tile.absoluteRelativeTo
  (Tile.java:114). NOT Tile.relativeTo (:82-84) and NOT
  BuildingComp.relativeTo(Building) (:530). For non-adjacent links
  (range 12), Tile.relativeTo returns −1 — the proof would be
  WRONG with it.
- **getFacingEdge(Building) is Edges.java:52-55** — :57-60 is the
  Tile overload.
- **checkAccept is :441-462** (:463 is blank). The commented-out
  incoming loop (:450-456) is NOT ported (kept-compat bug #9257).
- **linked(source)** = instanceof ItemBridgeBuild &&
  linkValid(source.tile, tile) && source.link == pos() (:464-466).
- SSOT +1/+1/+1/+2 (exact est). DEFERRED #99 resolved (246→245).

## Godot debt (this slice)

- NEW proof `C07ItemBridgeCheckAcceptRowsProof` (6 keys) — never
  run.
