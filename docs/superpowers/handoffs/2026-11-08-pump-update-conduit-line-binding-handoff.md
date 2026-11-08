# Handoff — C04 live-loop pump update + conduit line (N2088–N2089)

Date: 2026-11-08. Commit: pending (targeted gate running).

## Done

- N2088 `SourcePumpRuntimeState.source_pump_update_state` — the pump's updateTile production part (Pump.java:160-176): each frame it pumps maxPump into its liquids, warms up (warmupSpeed 0.019) and advances totalProgress; warmup/totalProgress persist on the pump frame. One second pumps 7/60 water. `simulate_factory` calls it for the pump each frame.
- N2089 `SourceWorldInitialBuildRuntimeState.source_conduit_line_placement_state` — the conduit line from the pump to the drill (Blocks.java:2322-2327, liquidCapacity 20, health 45): 7 conduits (5,13)-(5,8) + (6,8), adjacent to the drill's west edge. New consts `CONDUIT_CELLS`, `BLOCK_CONDUIT`, `INITIAL_BUILD_ROLE_CONDUIT`; the initial-build plan appends them after the pump.
- Proof `PumpUpdateProof` 5/5 true on the real Main scene (pump produces 7/60 per second, warmup +0.019, conduit line 7 cells live).
- Register script `tools/mindustry_godot_transpiler/register_pump_update_binding.py`; test `tools/mindustry_godot_transpiler/tests/test_pump_update_binding.py`.
- SSOT delta +14 symbols / +2 slices / +2 contracts / +4 schemas (totals 10796 / 1544 / 1432 / 2655). Audit `totalSourceFunctions` stays 1335. Production module shards mirror the N2088 owner (all 4 files); the N2089 owner (Blocks.java) mirrors into no shard.

## Verification status

- Targeted gate: first run killed by a service restart with exactly 6 stale-pin failures (the 6 power proofs pinning consumer_count 12); pins updated to 19 (origins 14 → 21, footprint keys 30 → 35, verified with a debug run); rerun 3476 tests OK in 824.690s, exit=0 (log `~/workspace/logs/targeted-n2088b.log`).
- Full Python suite: first run 5474 tests, 1 failure (`test_conveyor_queue_storage_binding`: the conduit at (6,8) broke the queue-storage proof pins); pins updated (resolve_ring found_count 3 with keys [(9,8),(6,8),(10,8)]; resolve_none now queries [(7,7),(6,9)]); binding test passes alone. Full suite rerun 5474 tests OK in 1331.645s, exit=0 (log `~/workspace/logs/full-suite-n2088b.log`).

## Next

- C04: the pump dumpLiquid step, the conduit liquid movement, then the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water as a booster).
- C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
