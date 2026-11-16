# Handoff N2405 — BeamDrill timerDump dump neighbour live fill

## What this slice did

New pure `source_beam_drill_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only; fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames. DEFAULT acceptItem/canDump
gates only. Tick wires the fill before the N2289 dump reads
(:1079-1080), after `content_item_ids` (:1078); supplied arrays
win + `dump_neighbour_live` flag. 5 files, +1146/−5, commit
`fd9f21bb9` on `slice/N2405-beamdrill-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** accepts = consumesItem (catalog rows)
  + items < itemCapacity; canDump default true; no-frame =
  false/false; offered item = first held in content order.
- **Correction noted:** multi-press is size 3
  (Blocks.java:1059), not size 2 as the N2394 proof comment
  says.
- Regression: N2289 + N2363 modules 6/6 non-proof PASS.
- SSOT +2/+1/+1/+2. DEFERRED #240 resolved (298→297).

## Godot debt (this slice)

- NEW proof `C07BeamDrillDumpNeighbourLiveFillProof` (6 keys)
  — never run.
