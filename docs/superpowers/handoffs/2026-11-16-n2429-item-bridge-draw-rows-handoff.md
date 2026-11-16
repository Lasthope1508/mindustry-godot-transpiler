# Handoff N2429 — ItemBridge draw rows

## What this slice did

One pure-only draw pure `source_item_bridge_draw_state` (27
caller-supplied inputs, no tick wiring): warmup + linked/unlinked
draw + arrows + pulse + select/input/configure calls. 5 files,
+1318/−1, commit `78a72b08a` on
`slice/N2429-item-bridge-draw-rows`.

## Key facts for the next agent

- **Overlap confirmed: #109 ⊆ #57** (same draw family, different
  cite range) — both resolve. The warmup approach :345 is updateTile
  (live N2225), NOT ported here.
- **Both entries under-cite draw()** (only to :394) — the slice
  ports the full draw() to :420 (dist + arrows Lod.l1 :404-419).
- **No icons() override; `moveArrows` is a dead field** (:34,
  never read — not ported, not deferred).
- **`pulse = true` at the phase-conveyor def** (class default
  false) — the pulse branch is live.
- SSOT +7/+1/+1/+2 (exact est). DEFERRED #57 + #109 resolved
  (280→278).

## Godot debt (this slice)

- NEW proof `C07ItemBridgeDrawRowsProof` (6 keys) — never run.
