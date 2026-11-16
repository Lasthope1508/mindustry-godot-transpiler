# Handoff N2404 — ItemBridge doDump neighbour live fill

## What this slice did

New pure `source_item_bridge_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only; fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames. DEFAULT acceptItem/canDump
gates only. Tick wires the fill after the transport advance
write-back, BEFORE the doDump reads (:740-741); the fill runs
regardless of the link gate (doDump self-gates on
`had_valid_link`). Supplied arrays win + `dump_neighbour_live`
flag. 5 files, +1143/−4, commit `dc40f7f14` on
`slice/N2404-itembridge-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** accepts = consumesItem (catalog rows)
  + items < itemCapacity; canDump default true; no-frame =
  false/false.
- **⚠️ GATE-WATCH:** proofs N2225/N2321 tick an unlinked
  bridge holding an item ≥60 ticks near an accepting neighbour
  and may see new dumps appear — only observable on the Godot
  side.
- SSOT +2/+1/+1/+2. DEFERRED #238 resolved (298→297).

## Godot debt (this slice)

- NEW proof `C07ItemBridgeDumpNeighbourLiveFillProof` (6 keys)
  — never run.
