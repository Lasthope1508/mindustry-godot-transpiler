# Handoff N2412 — LiquidBridge doDump live neighbour fill

## What this slice did

New pure
`source_liquid_bridge_dodump_neighbour_live_fill_state(game,
cell, size, liquids, liquid_names_by_id)` — fills all **8**
neighbour arrays in ring order from live neighbour frames
(N2394 liquid half + N2408 8-field shape, as parallel arrays).
DEFAULT acceptLiquid/canDumpLiquid gates only. Tick wires the
fill in the UNLINKED branch only, BEFORE the dump reads (:540);
supplied arrays win (all 8 `frame.has` checks) +
`dump_neighbour_live` flag. 5 files, +1362/−5, commit
`d3b8b1fd6` on `slice/N2412-liquid-bridge-dodump-neighbour-live-fill`.

## Key facts for the next agent

- **8 arrays, not 3** — the DEFERRED entry text was STALE;
  the tick builds 8 at :540 (verified).
- **Dumped liquid is `liquids.current()`** — read from the
  advanced store like the N2287 pure.
- **Footprint trap:** size-3 footprints are CENTRED (the N2394
  lesson) — the proof's electrolyzer origin (27,23) covers
  ring 2 only.
- Runtime `load()` calls, not preloads (cycle risk + :540
  line-shift avoidance).
- SSOT +8/+1/+1/+2. DEFERRED #232 resolved (291→290).

## Godot debt (this slice)

- NEW proof `C07LiquidBridgeDodumpNeighbourLiveFillProof` (6
  keys) — never run.
