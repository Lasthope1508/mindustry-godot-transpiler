# Handoff N2363 — BeamDrill timerDump neighbour write-back

## What this slice did

The BeamDrill timerDump advance exposes `dump_neighbour_index` /
`dumped_item`; the tick wires the shared N2353 helper after the
timerDump persist. 5 files, +863/−9, commit `af977d648` on
`slice/N2363-beam-drill-timerdump-write-back`.

## Key facts for the next agent

- Keys read from `dump_item_state`'s literal `handled_index` /
  `handled_item` (NOT `SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY` —
  that is the Separator offload path). −1/`""` when nothing dumps.
- Tick guard `dump_index >= 0`; reads `origin_cell` inline as
  `dump_cell` (no `cell` in scope inside the enabled block); failed
  write-back drops the item (N2353 precedent).
- SSOT +0/+1/+0/+0 (re-lists 5 N2289 symbols). DEFERRED 320→319
  (#263 1-based).
- The two key symbols + schema/contract fold landed in N2367. N2366
  later updated this slice's test pin (it pinned the N2352 gate).

## Godot debt (this slice)

- NEW proof `C07BeamDrillTimerDumpWriteBackProof` (3 keys) — never run.
