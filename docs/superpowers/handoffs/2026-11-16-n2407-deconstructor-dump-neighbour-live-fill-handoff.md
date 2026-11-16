# Handoff N2407 — PayloadDeconstructor dump neighbour live fill

## What this slice did

New pure
`source_payload_deconstructor_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only; fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames. DEFAULT acceptItem/canDump
gates only. Tick wires the fill before the N2276 dump reads
(:1023-1025), inside the enabled block and BEFORE the progress
advance (Java order :111-115 before :117+); supplied arrays win
+ `dump_neighbour_live` flag. 5 files, +1147/−3, commit
`dcd95c0c4` on `slice/N2407-deconstructor-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** accepts = consumesItem (catalog rows)
  + items < itemCapacity; canDump default true; no-frame =
  false/false; answers for the FIRST held item in content
  order.
- **Correction noted:** multi-press is size 3
  (Blocks.java:1059); its footprint covers ring 4, 5 and 6 —
  this proof asserts all three.
- Sibling regression: N2276 + N2368 modules still 3/4.
- SSOT +2/+1/+1/+2. DEFERRED #217 resolved (298→297).

## Godot debt (this slice)

- NEW proof `C07PayloadDeconstructorDumpNeighbourLiveFillProof`
  (6 keys) — never run.
