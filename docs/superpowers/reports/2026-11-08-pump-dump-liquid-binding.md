# C04 pump dumpLiquid — N2090

Date: 2026-11-08. Batch: N2090 (single slice, fifth C04 batch).

## What changed

N2090 is the pump's updateTile dump step (Pump.java:180-182: `if(liquidDrop != null) dumpLiquid(liquidDrop)`). BuildingComp.java:877-878: `dumpLiquid(liquid)` calls `dumpLiquid(liquid, 2f)` — scaling 2, any output direction (-1) — which routes the pump's water to its liquid neighbors through the bound `dump_liquid_state` (routing gate + fraction transfer), then writes the pump's and each neighbor's liquids back. `simulate_factory` now calls the dump for the pump each frame after the pump update (wiring folded into the slice).

The pump's proximity is its neighboring buildings (the 4 adjacent cells that hold a block with a liquids module). In the bootstrap world the only liquid neighbor is the conduit at (5,13); the neighbor accept check is the conduit's acceptLiquid (Conduit.java:241-244: its current liquid matches, or its current amount is under 0.2, and the pump is not on the side the conduit outputs to). The dump cursor (cdump) is stored on the pump frame and persists across frames; with one neighbor it stays 0. New const `CONDUIT_LIQUID_CAPACITY` (20, Blocks.java:2324).

- `SourcePumpRuntimeState.source_pump_dump_liquid_state(game, cell) -> Dictionary` → `{liquid_drop, amount_dumped, liquid_amount, dump_cursor}`. One dump moves (pump - conduit) / 2, so both end at the average; a second dump right after transfers nothing (fract == ofract).
- Proof `PumpDumpLiquidProof` 5/5 true on the real Main scene: one second of pumping fills 7/60 water, the dump moves half the difference to the conduit at (5,13) and both end at the average, the dump cursor is 0 and persisted on the frame, and a second dump transfers nothing. The proof asserts deltas, not absolutes, because the live loop already ticked the pump (and its dump) during setup.

## Verification

- Targeted gate: the new binding test + the recent placement/power binding tests + `test_power_graph_live_update_binding` + `test_source_catalog_validator` + the audit/shard tests inside `test_source_symbols` + `test_liquid_consumer_hydration` + `test_playable` — **3479 tests OK in 848.990s, exit=0** (log `~/workspace/logs/targeted-n2090.log`).
- Full Python suite: **5477 tests OK in 1336.945s, exit=0** (log `~/workspace/logs/full-suite-n2090.log`).

## SSOT delta

+6 symbols / +1 slice / +1 contract / +2 schemas. Totals: 10802 symbols / 1545 slices / 1433 contracts / 2657 schemas. Audit `totalSourceFunctions` stays 1335 (no PortGame facade function added). The N2090 owner (java_source `world/blocks/production/Pump.java`) mirrors into the production module shards (all 4 files).

## Still open

- C04: the conduit liquid movement, and the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water as a booster — the mechanical drill has `consumeLiquid(Liquids.water, 0.05f).boost()`, Blocks.java:2873). C03 full-power live case deferred. C02 live-loop sprite wiring + per-belt clogHeat persistence. C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
