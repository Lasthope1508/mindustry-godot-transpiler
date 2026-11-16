# Handoff N2406 — MassDriver dump neighbour live fill

## What this slice did

New pure `source_mass_driver_dump_neighbour_live_fill_state` —
mirror of the N2394 pure, item-only; fills
`dump_neighbour_accepts` / `dump_neighbour_can_dump` in ring
order from live neighbour frames. DEFAULT acceptItem/canDump
gates only. Tick wires the fill AFTER the advance write-back
(offered item reads the post-advance store) and BEFORE the dump
reads (:929-930); supplied arrays win + `dump_neighbour_live`
flag. 5 files, +1141/−2, commit `4b9a4961b` on
`slice/N2406-massdriver-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** accepts = consumesItem (catalog rows)
  + items < itemCapacity; canDump default true; no-frame =
  false/false (explicit conduit guard).
- **⚠️ N2394 proof defect (flagged, fix queued for
  advances-24):** multi-press is size 3, and the N2394 proof's
  press centred on ring cell (30,20) covers ring 4 as well as
  5/6 → live-tick cdump is **5**, not the asserted 7. Fix:
  re-centre the press at (31,20) as this slice's proof does.
- Proof arithmetic validated by a Python simulation: 17/17.
- SSOT +2/+1/+1/+2. DEFERRED #247 resolved (298→297).

## Godot debt (this slice)

- NEW proof `C07MassDriverDumpNeighbourLiveFillProof` (6 keys)
  — never run.
