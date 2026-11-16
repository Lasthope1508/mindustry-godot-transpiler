# Handoff N2402 — Separator timerDump dump neighbour live fill

## What this slice did

New pure `source_separator_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only; fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames. DEFAULT acceptItem/canDump
gates only. Tick wires the fill immediately before the N2281
timerDump reads (:905-907); supplied arrays win +
`dump_neighbour_live` flag. 5 files, +1159/−6, commit
`bf1917e32` on `slice/N2402-separator-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** accepts = consumesItem (catalog rows)
  + items < itemCapacity (default 10); canDump default true;
  no-frame = false/false.
- **Offload one-tick lag:** N2343 offload routing reads the
  frame arrays BEFORE the fill runs in the same tick — it sees
  the previous tick's arrays (documented in the driver
  comment).
- SSOT +2/+1/+1/+2. DEFERRED #226 resolved (298→297).

## Godot debt (this slice)

- NEW proof `C07SeparatorDumpNeighbourLiveFillProof` (6 keys)
  — never run.
