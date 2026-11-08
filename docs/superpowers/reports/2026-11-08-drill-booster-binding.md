# C04 drill water booster — N2093

Date: 2026-11-08. Batch: N2093 (single slice, seventh C04 batch). **Closes the C04 gate.**

## What changed

N2093 is the drill's water booster: the mechanical drill consumes water 0.05f as an optional booster (Blocks.java:2873, `consumeLiquid(Liquids.water, 0.05f).boost()`), and its updateTile speed is `lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency` (Drill.java:301), with `liquidBoostIntensity = 1.6f` (Drill.java:38). The tick state already computed `frame["speed"]` from `frame["optional_efficiency"]`; this slice reads that booster state back — the drill's water, optional_efficiency and speed — so the gate can prove the drill runs 1.6x faster when water reaches it.

- `SourceDrillConsumptionRuntimeState.source_drill_booster_state(game, cell) -> Dictionary` → `{water, optional_efficiency, speed, boosted}`. Reads the drill sprite's liquid module and drill frame.
- Proof `DrillBoosterProof` 5/5 true on the real Main scene: before water the drill runs unboosted (speed 1.0); after 15 seconds of live-loop game time the drill holds water, the booster is engaged (optional_efficiency > 0) and speed is 1.6; the pump + first conduit hold far more than 5.0 water.

## Pump rate correction (N2088 bug, found by the gate debug)

The gate debug showed the drill's water stayed at 0.0 after 15 seconds even though water reached the line: the pump produced 7/60 water per second, but the drill's booster drains 0.05f per frame (3.0/sec), so the drill could never accumulate water and the booster never engaged. Root cause: the pump's `source_pump_update_state` used the Godot delta in seconds directly, but Java's `edelta()` is in ticks — Arc `Time.delta` is `getDeltaTime() * 60f` (Time.java:26), so 1.0 per frame at 60fps. The pump produced 7/60 per second instead of 7.0 per second (60x too slow). The fix: `source_pump_update_state` now uses the tick-edelta (`delta * TICK_RATE`, 60.0) for maxPump, warmup and totalProgress. The N2088 PumpUpdateProof now calls it with a frame delta (1/60s) and keeps the same assertions (7/60 per frame, warmup +0.019, progress +warmup). The PumpDumpLiquidProof and ConduitUpdateProof comments are corrected to 7.0 per second (their assertions are delta-based and unchanged).

## Verification

- Targeted gate: the new binding test + the recent placement/power binding tests + `test_power_graph_live_update_binding` + `test_source_catalog_validator` + the audit/shard tests inside `test_source_symbols` + `test_liquid_consumer_hydration` + `test_playable` — **3485 tests OK in 856.636s, exit=0** (log `~/workspace/logs/targeted-n2093.log`).
- Full Python suite: **5483 tests OK in 1344.253s, exit=0** (log `~/workspace/logs/full-suite-n2093.log`).

## SSOT delta

+6 symbols / +1 slice / +1 contract / +2 schemas. Totals: 10819 symbols / 1548 slices / 1436 contracts / 2663 schemas. Audit `totalSourceFunctions` stays 1335 (no PortGame facade function added). The N2093 owner (Drill.java) mirrors into the production module shards (all 4 files).

## Still open

- **C04 is closed** (pump → conduit → Drill uses water at 1.6x). C03 full-power live case deferred (needs 4 large solar panels; the coverage-1.0 math is proven at the module level). C02 live-loop sprite wiring + per-belt clogHeat persistence. C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
