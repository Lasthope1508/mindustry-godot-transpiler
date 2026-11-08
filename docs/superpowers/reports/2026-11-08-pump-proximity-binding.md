# C04 pump proximity scan binding — N2086–N2087

Date: 2026-11-08. Batch: N2086–N2087 (two slices, third C04 batch).

## What changed

N2086 maps a floor block id to its liquidDrop (and liquidMultiplier), so the pump can tell whether a tile is pumpable. The mapping is the floor definitions in Blocks.java: deep-water/shallow-water/tainted-water/deep-tainted-water drop water (deep-water and deep-tainted-water have multiplier 1.5), tar drops oil, pooled-cryofluid drops cryofluid (multiplier 0.5), molten-slag drops slag, arkycite-floor drops arkycite; any other floor drops nothing (Floor.java default liquidDrop null, multiplier 1.0).

N2087 is the pump's onProximityUpdate (Pump.java:141-152): it scans the pump's linked tiles, and for each tile whose floor has a liquidDrop (canPump: `tile != null && tile.floor().liquidDrop != null`, Pump.java:106-108) it sets liquidDrop and adds the floor's liquidMultiplier to amount. The result is stored on the pump sprite's meta frame (like the drill frame), so the live-loop update (updateTile) can use it.

- `SourceWorldTerrainRuntimeState.source_floor_liquid_drop_state(floor_id) -> Dictionary` → `{liquid_drop, liquid_multiplier, is_liquid}`.
- New file `SourcePumpRuntimeState.gd` with `source_pump_proximity_state(game, cell) -> Dictionary` → `{liquid_drop, amount, stored}`. The pump at (5,14) sits on shallow-water, so its scan finds liquidDrop water with amount 1.0 (its own tile's multiplier).
- Proof `PumpProximityProof` 6/6 true on the real Main scene: the floor mapping for shallow-water (water, 1.0), deep-water (water, 1.5), tar (oil, 1.0) and stone (null, 0.0, not liquid); the pump scan returns water with amount 1.0 and stored true; the sprite frame holds the same values.

## Verification

- Targeted gate: the new binding test + the recent placement/power binding tests + `test_power_graph_live_update_binding` + `test_source_catalog_validator` + the audit/shard tests inside `test_source_symbols` + `test_liquid_consumer_hydration` + `test_playable` — **3473 tests OK in 805.660s, exit=0** (log `~/workspace/logs/targeted-n2086.log`).
- Full Python suite: **5471 tests OK in 1304.101s, exit=0** (log `~/workspace/logs/full-suite-n2086.log`).

## SSOT delta

+9 symbols / +2 slices / +2 contracts / +4 schemas. Totals: 10782 symbols / 1542 slices / 1430 contracts / 2651 schemas. Audit `totalSourceFunctions` stays 1335 (no PortGame facade function added). The N2087 owner (java_source `world/blocks/production/Pump.java`) mirrors into the production module shards — all 4 files changed (`production_api_contracts`, `production_slices`, `production_state_schema`, `production_symbols`); the N2086 owner (Blocks.java) mirrors into no shard.

## Still open

- C04: the live-loop pump update (updateTile: pumping into liquids, then dumpLiquid to the conduits), the conduit line from the pump to the drill, and the live-loop liquid flow (the C04 gate). C03 full-power live case deferred. C02 live-loop sprite wiring + per-belt clogHeat persistence. C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
