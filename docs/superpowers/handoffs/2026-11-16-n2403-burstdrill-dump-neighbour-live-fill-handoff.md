# Handoff N2403 — BurstDrill timerDump neighbour live fill

## What this slice did

New pure `source_burst_drill_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only; fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames. DEFAULT acceptItem/canDump
gates only. Tick wires the fill immediately before the dump
reads (:698-699); supplied arrays win + `dump_neighbour_live`
flag. 5 files, +1142/−3, commit `0b369f537` on
`slice/N2403-burstdrill-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** accepts = consumesItem (catalog rows)
  + items < itemCapacity; canDump default true; no-frame =
  false/false; answers for the FIRST held item in content
  order.
- **Proof neighbour:** surge-smelter is the ONLY catalog def
  consuming copper (cap 20, size 3); size-5 ring = 20 cells,
  ring 0 = (25,19) melter, ring 14 = (28,23) surge-smelter.
- Sibling regression: 18/18 non-proof BurstDrill tests pass.
- SSOT +2/+1/+1/+2. DEFERRED #228 resolved (298→297).

## Godot debt (this slice)

- NEW proof `C07BurstDrillDumpNeighbourLiveFillProof` (6 keys)
  — never run.
