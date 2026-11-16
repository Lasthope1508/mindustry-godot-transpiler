# Handoff N2360 — BurstDrill timerDump neighbour write-back

## What this slice did

The BurstDrill timerDump advance exposes `dump_neighbour_index` /
`dumped_item`; the tick wires the shared N2353 helper after the dump
frame write-back. 5 files, +905/−8, commit `93013b926` on
`slice/N2360-burst-drill-timerdump-write-back`.

## Key facts for the next agent

- SCALAR index+item (timerDump fires once per tick); index via
  `SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY`, item = port
  `handled_item`; Java-exact on both branches incl. dump(null).
- Tick wires the helper after the dump frame write-back, before the
  advance (Java order: handleItem INSIDE dump(), BurstDrill.java:83-84);
  `cell` hoisted to loop top.
- SSOT +2/+1/+0/+0 (a register with 0 new symbols fails validation —
  a wiring-only slice exposing new advance keys must register them).
  DEFERRED 320→319 (#245 1-based).
- Schema + contract fold landed in N2367.

## Godot debt (this slice)

- NEW proof `C07BurstDrillTimerDumpWriteBackProof` (3 keys) — never run.
