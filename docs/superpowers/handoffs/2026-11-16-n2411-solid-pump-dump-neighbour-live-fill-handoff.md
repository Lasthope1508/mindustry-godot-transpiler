# Handoff N2411 — SolidPump dump neighbour live fill

## What this slice did

New pure
`source_solid_pump_dump_neighbour_live_fill_state(game, cell,
size, result_liquid_id)` — mirror of the N2408 def-result
logic + N2394 liquid half; fills the 4 neighbour arrays in
ring order from live neighbour frames. DEFAULT
acceptLiquid/canDumpLiquid gates only. Tick wires the fill
BEFORE the dump reads (:642-645); supplied arrays win +
`dump_neighbour_live` flag; origin cell read inline as
`fill_cell` (N2363). 5 files, +1210/−7, commit `331d8bd47` on
`slice/N2411-solid-pump-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Result liquid is the water constant** (`advance_result_id`,
  Blocks.java:2922). Array names carry `liquid`.
- **Cell bound after the enabled block** — the fill uses the
  inline origin_cell read (N2363/N2377 precedent).
- **Catalog gap (NOT fixed):** 30 defs lack `hasLiquids` —
  Java default false.
- SSOT +4/+1/+1/+2. DEFERRED #230 resolved (291→290).

## Godot debt (this slice)

- NEW proof `C07SolidPumpDumpNeighbourLiveFillProof` (6 keys)
  — never run.
