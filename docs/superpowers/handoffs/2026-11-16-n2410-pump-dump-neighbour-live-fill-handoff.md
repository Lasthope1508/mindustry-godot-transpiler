# Handoff N2410 — Pump dump neighbour live fill

## What this slice did

New pure
`source_mechanical_pump_dump_neighbour_live_fill_state(game,
cell, size, liquid_drop, liquid_id_by_name)` — mirror of the
N2394 liquid half + N2408; fills the 4 neighbour arrays in
ring order from live neighbour frames. DEFAULT
acceptLiquid/canDumpLiquid gates only. Tick wires the fill
BEFORE the reads (:574-577); supplied arrays win +
`dump_neighbour_live` flag. 5 files, +1301/−3, commit
`f8374d855` on `slice/N2410-pump-dump-neighbour-live-fill`.

## Key facts for the next agent

- **Liquid input is the NAME** (`liquid_drop` + map) — the
  consumeLiquid rows match on the NAME; null drop → no
  accepts/no amounts, capacities still fill.
- **Driver is MechanicalPump** — `SourcePumpBuildState.gd`
  does not exist.
- **Catalog gap (NOT fixed):** 30 defs lack `hasLiquids` —
  Java default false. Electrolyzer HAS a liquids store via
  hydration despite no key.
- N2285's hardcoded has_liquids/liquids_present true is
  documented, not changed (routing is correct via accepts).
- SSOT +4/+1/+1/+2. DEFERRED #228 resolved (291→290).

## Godot debt (this slice)

- NEW proof `C07PumpDumpNeighbourLiveFillProof` (6 keys) —
  never run.
