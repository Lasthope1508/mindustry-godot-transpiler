# C04 live-loop pump update + conduit line — N2088–N2089

Date: 2026-11-08. Batch: N2088–N2089 (two slices, fourth C04 batch).

## What changed

N2088 is the pump's updateTile production part (Pump.java:160-176): each frame it pumps `maxPump = min(liquidCapacity - liquids.get(liquidDrop), amount * pumpAmount * edelta())` into its own liquids, warms up toward 1 when it pumped (warmupSpeed 0.019), and advances totalProgress. The pump is enabled and consumes no power, so efficiency is 1.0 and edelta() is the frame delta. Warmup/totalProgress live on the pump building frame (like liquidDrop/amount), so they persist across frames. The dumpLiquid step (Pump.java:180-182) is a later slice. `simulate_factory` now calls the update for the pump each frame (wiring folded into the slice).

N2089 places the conduit line from the pump to the drill (Blocks.java:2322-2327, conduit liquidCapacity 20, health 45): 7 conduits from (5,13) north along x = 5, then east to (6,8), adjacent to the drill's west edge at (7,8), so the C04 gate has a liquid path from the pump to the drill. New consts `CONDUIT_CELLS`, `BLOCK_CONDUIT`, `INITIAL_BUILD_ROLE_CONDUIT`; `initial_build_plan_state` appends the 7 conduits after the pump.

- `SourcePumpRuntimeState.source_pump_update_state(game, cell, delta) -> Dictionary` → `{liquid_drop, amount_pumped, warmup, total_progress, liquid_amount}`. One second of pumping fills 7/60 water (amount 1.0 * pumpAmount 7/60 * delta 1.0).
- `SourceWorldInitialBuildRuntimeState.source_conduit_line_placement_state(tile_size) -> Dictionary` → `{block_id, role, cells, count, liquid_capacity}`.
- Proof `PumpUpdateProof` 5/5 true on the real Main scene: one second pumps 7/60 water (and a second second pumps another 7/60), warmup rises by 0.019 and totalProgress by the new warmup; the conduit line returns 7 cells incl. (5,13) and (6,8) with capacity 20, and all 7 conduit sprites are live in the world. The proof asserts deltas, not absolutes, because the live loop already ticked the pump during setup.

## Verification

- Targeted gate: the new binding test + the recent placement/power binding tests + `test_power_graph_live_update_binding` + `test_source_catalog_validator` + the audit/shard tests inside `test_source_symbols` + `test_liquid_consumer_hydration` + `test_playable` — first run killed by a service restart, showing exactly 6 stale-pin failures (the 6 power proofs pinning consumer_count 12); the pins were updated to 19 (origins 14 → 21, footprint keys 30 → 35, verified with a debug run) and the rerun is **3476 tests OK in 824.690s, exit=0** (log `~/workspace/logs/targeted-n2088b.log`).
- Full Python suite: first run **5474 tests, 1 failure** — `test_conveyor_queue_storage_binding`: the conduit at (6,8) broke `ConveyorQueueStorageProof` (`queue_storage_resolve_none` queried (6,8) expecting air; `queue_storage_resolve_ring` expected found_count 2 with keys [(9,8),(10,8)] but the ring now resolves the conduit too). Same stale-pin class: the pins were updated (resolve_ring now expects found_count 3 with keys [(9,8),(6,8),(10,8)] and (6,8) len 0; resolve_none now queries [(7,7),(6,9)], both air) and the binding test passes alone (3 tests OK). Full suite rerun **5474 tests OK in 1331.645s, exit=0** (log `~/workspace/logs/full-suite-n2088b.log`).

## SSOT delta

+14 symbols / +2 slices / +2 contracts / +4 schemas. Totals: 10796 symbols / 1544 slices / 1432 contracts / 2655 schemas. Audit `totalSourceFunctions` stays 1335 (no PortGame facade function added). The N2088 owner (java_source `world/blocks/production/Pump.java`) mirrors into the production module shards (all 4 files); the N2089 owner (Blocks.java) mirrors into no shard.

## Still open

- C04: the pump dumpLiquid step (Pump.java:180-182), the conduit liquid movement, and the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water as a booster — the mechanical drill has `consumeLiquid(Liquids.water, 0.05f).boost()`, Blocks.java:2873). C03 full-power live case deferred. C02 live-loop sprite wiring + per-belt clogHeat persistence. C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
