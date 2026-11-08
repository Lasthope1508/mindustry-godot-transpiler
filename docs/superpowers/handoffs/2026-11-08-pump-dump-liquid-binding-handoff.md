# Handoff — C04 pump dumpLiquid (N2090)

Date: 2026-11-08. Commit: pending (targeted gate running).

## Done

- N2090 `SourcePumpRuntimeState.source_pump_dump_liquid_state` — the pump's updateTile dump step (Pump.java:180-182; BuildingComp.java:877-878, 886-908: dumpLiquid(liquid, 2f), any output direction) — it routes the pump's water to its liquid neighbors through the bound `dump_liquid_state` and writes the pump's and each neighbor's liquids back; `simulate_factory` calls it each frame after the pump update. The pump's only liquid neighbor is the conduit at (5,13) (accept per Conduit.java:241-244); one dump moves (pump - conduit) / 2, so both end at the average. New const `CONDUIT_LIQUID_CAPACITY` (20, Blocks.java:2324).
- Proof `PumpDumpLiquidProof` 5/5 true on the real Main scene (dump moves half the difference to the conduit, cursor 0 and persisted, second dump transfers nothing).
- Register script `tools/mindustry_godot_transpiler/register_pump_dump_liquid_binding.py`; test `tools/mindustry_godot_transpiler/tests/test_pump_dump_liquid_binding.py`.
- SSOT delta +6 symbols / +1 slice / +1 contract / +2 schemas (totals 10802 / 1545 / 1433 / 2657). Audit `totalSourceFunctions` stays 1335. Production module shards mirror the N2090 owner (all 4 files).

## Verification status

- Targeted gate: 3479 tests OK in 848.990s, exit=0 (log `~/workspace/logs/targeted-n2090.log`).
- Full Python suite: 5477 tests OK in 1336.945s, exit=0 (log `~/workspace/logs/full-suite-n2090.log`).

## Next

- C04: the conduit liquid movement, then the live-loop liquid flow (the C04 gate: pump → conduit → Drill uses water as a booster).
- C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C05–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
