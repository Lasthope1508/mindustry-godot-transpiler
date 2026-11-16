# Handoff N2408 — Fracker dumpLiquid neighbour live fill

## What this slice did

New pure
`source_fracker_dump_liquid_neighbour_live_fill_state(game,
cell, size, result_liquid_id)` — scans the live proximity in
ring order and builds one neighbour dict per ring cell in the
exact N2284 shape (amount / capacity / accepts / has_liquids /
can_dump / liquids_present / destination_present /
relative_to). DEFAULT acceptLiquid/canDumpLiquid gates only.
Tick wires the fill BEFORE the N2284 dump reads; supplied
entries win + `dump_liquid_neighbours_live` flag. 5 files,
+1232/−7, commit `fa77277fb` on
`slice/N2408-fracker-dump-liquid-neighbour-live-fill`.

## Key facts for the next agent

- **Default gates only:** acceptLiquid = hasLiquids &&
  consumesLiquid oil; canDumpLiquid = true; amount/capacity
  from the neighbour liquids module + def `liquidCapacity`.
- **Pin note:** the fill pure lives AFTER the tick (cite-sweep
  pins the frame-sync at driver line 633) and the frame-key
  list comes from a runtime `load()`, not a preload.
- **Catalog gap (NOT fixed):** 30 defs have consumeLiquid rows
  but no `hasLiquids` key — read as Java default false.
- SSOT +1/+1/+1/+2. DEFERRED #230 resolved (298→297).

## Godot debt (this slice)

- NEW proof `C07FrackerDumpLiquidNeighbourLiveFillProof` (6
  keys) — never run.
