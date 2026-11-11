# Report — N2125: power-graph shouldConsumePower from the live frame enabled flag (2026-11-11)

## What was built

The power graph now reads each consumer's `shouldConsumePower` from its placed building's live frame `enabled` flag instead of the static catalog. New `SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state(game, cell)` reads the frame on the building's sprite (meta keys tried in order: `source_drill_building`, `source_turret_building`, `source_factory_building`, `source_adjacent_factory_building`, `source_unit_factory_building`, `source_continuous_liquid_turret_building`) and returns both keys from `enabled`; a building with no tick frame (conduit, core) and a cell with no sprite keep the true default, the static behavior. The live-loop power-graph step `SourceFactoryRuntimeState.source_factory_update_power_graph_state` (extended in place, still N2077) stamps each grouped consumer dict's `should_consume` / `shouldConsumePower` with the helper's answer before the update runs, and `SourceTurretBuildState.source_turret_tick_frame_state` (extended in place, still N2108) preserves the frame's `enabled` flag so a disabled turret stays disabled across ticks (the drill/factory/unit-factory/adjacent frames already preserved it).

Java: `ConsumePower.requestedPower` (ConsumePower.java:57-63) charges an unbuffered consumer `usage * (entity.shouldConsume() ? 1f : 0f)`, `BuildingComp.shouldConsume()` (BuildingComp.java:755-757) is `return enabled;`, the disabled branch of `BuildingComp.updateConsumption()` (BuildingComp.java:1952-1956) clears `shouldConsumePower`, `PowerGraph.getPowerNeeded` (PowerGraph.java:105-115) sums only consumers whose `shouldConsumePower` is set, and `PowerGraph.distributePower` (PowerGraph.java:189) computes coverage 0 when needed/produced/stored are all zero and nothing charged, 1 when needed is zero, else `min(1, produced / needed)`.

The disable → battery-charges act, proven live: disabling the lancer drops `power_needed` 0.1 → 0.0, coverage 0.02 → 1.0, and 600 live ticks charge the battery above 0.0 (stored ≈ 1.2 at capacity 4000) with coverage staying 1.0; re-enabling restores needed 0.1, the charged battery covers the deficit at coverage 1.0 on the first step back (the N2082/N2083 discharge path), then drains over live ticks. Before this slice the graph's consumer dicts were rebuilt from the catalog every frame with both keys static (`has_power and consumes_power`), so a disabled lancer kept charging its full 6.0/60.

## Files

- `godot-mindustry/src/game/SourcePlacedPowerGraphState.gd` (+37): `SOURCE_CONSUMER_FRAME_META_KEYS` + `source_consumer_should_consume_for_cell_state(game, cell)`.
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (+13): the should-consume stamp loop in `source_factory_update_power_graph_state` (after the N2107 cheating loop).
- `godot-mindustry/src/game/SourceTurretBuildState.gd` (+7): `source_turret_tick_frame_state` preserves `frame["enabled"]`.
- `tools/mindustry_godot_transpiler/tests/test_c06_power_should_consume.py` (new, 4 tests) + `register_c06_power_should_consume.py` (new).
- `godot-mindustry/src/generated/`: N2125 ledger row (6 symbols, 11 exprs), 1 new contract + the N2077 driver and N2108 turret tick-frame contracts extended in place, 2 schemas, `power_*` shards rebuilt.
- `godot-mindustry/tools/runtime_proofs/C06PowerShouldConsumeProof.gd` + `.tscn` (new). Proof: **23/23 keys true**, `matches: true`.

## Gates (measured)

- Targeted gate: **5597 tests OK in 1907.745s** (log `~/workspace/logs/targeted-n2125.log`, xong ~15:58 +07).
- Full Python suite: **5597 tests OK in 1890.274s** (log `~/workspace/logs/full-suite-n2125.log`, xong ~16:41 +07).

## SSOT delta

SSOT +6/+1/+1/+2 → 11230 symbols / 1576 slices / 1500 contracts / 2791 schemas; audit `totalSourceFunctions` stays 1335.

## Still open

The battery's live `enabled` stamp (`PowerGraph.getBatteryStored` gates on `battery.enabled`, but the battery has no tick frame), the shouldConsumePower half that clears when a non-power consumer fails (BuildingComp.java:1971-1974), `ConsumeItemDynamic.trigger` at unit completion, UnitAssembler plan dynamics, per-building timeScale expiry + the disabled-building updateTile gate, source-exhaustion/output-full acts. C06–C12 remain open.
