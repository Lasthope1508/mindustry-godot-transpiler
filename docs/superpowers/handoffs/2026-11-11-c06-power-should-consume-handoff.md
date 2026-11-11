# Handoff — N2125: power-graph shouldConsumePower from the live frame enabled flag

Date: 2026-11-11. Batch: N2125 (single slice). Status: built, registered, proof 23/23 verified, test module 4/4 standalone. **Targeted gate 5597 tests OK** (1907.745s, log targeted-n2125.log); **full Python suite 5597 tests OK** (1890.274s, log full-suite-n2125.log).

## What this batch is

The power graph reads each consumer's `shouldConsumePower` from its placed building's live frame `enabled` flag: `ConsumePower.requestedPower` (ConsumePower.java:57-63) is `usage * (entity.shouldConsume() ? 1f : 0f)`, `BuildingComp.shouldConsume()` (BuildingComp.java:755-757) is `return enabled;`, the disabled branch (BuildingComp.java:1952-1956) clears `shouldConsumePower`, `PowerGraph.getPowerNeeded` (PowerGraph.java:105-115) sums only consumers whose `shouldConsumePower` is set. 6 symbols, 11 exprs, SSOT +6/+1/+1/+2 → 11230 / 1576 / 1500 / 2791; audit 1335.

## Files changed

- `godot-mindustry/src/game/SourcePlacedPowerGraphState.gd` (+37): `SOURCE_CONSUMER_FRAME_META_KEYS` (local string consts, the file's existing pattern — cf. `SOURCE_BATTERY_POWER_STATUS_META_KEY`) + new `source_consumer_should_consume_for_cell_state(game, cell) -> Dictionary`: null game → `{should_consume: true, shouldConsumePower: true, found: false, reason: "no_game"}`; no sprite → same with `reason: "no_sprite"`; tries frame meta keys in order `source_drill_building`, `source_turret_building`, `source_factory_building`, `source_adjacent_factory_building`, `source_unit_factory_building`, `source_continuous_liquid_turret_building` — first frame found → `enabled = bool(frame.get("enabled", true))`, returns `{should_consume: enabled, shouldConsumePower: enabled, found: true, reason: "live_frame"}`; no frame → true/true, `found: false, reason: "no_frame"`. No new owner const (N2107 precedent — the cheating helper also carries no `source_owner` / PORT_GAME const).
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (+13): `source_factory_update_power_graph_state` gains a stamp loop after the N2107 cheating loop — for each consumer with a Vector2i `origin_cell`, sets `consumer["should_consume"]` and `consumer["shouldConsumePower"]` from the helper (defaults true). The power step runs at :163 in `simulate_factory`, before the turret tick (:171) — order is safe since the frame persists on the sprite meta.
- `godot-mindustry/src/game/SourceTurretBuildState.gd` (+7): `source_turret_tick_frame_state` adds `frame["enabled"] = bool(frame.get("enabled", true))` after the cheating line, with comment citing BuildingComp.java:77 + 755-757 and the factory pattern (SourceFactoryBuildState.gd:927). Needed because the turret frame starts as `{}` and previously carried no `enabled` key (drill/factory/unit-factory/adjacent frames already preserve `enabled`; verified by grep). The tick driver preserves a disabled turret across ticks.
- `tools/mindustry_godot_transpiler/tests/test_c06_power_should_consume.py` (new, 4 tests) + `tools/mindustry_godot_transpiler/register_c06_power_should_consume.py` (new, mirrors `register_power_graph_consumer_cheating.py`).
- `godot-mindustry/src/generated/` (SSOT JSONs + `power_api_contracts.json` + `power_slices.json` shards): N2125 row, 6 symbols, 1 new contract, 2 schemas; the N2077 driver contract and N2108 turret tick-frame contract extended in place (deepcopy + extend rule/tests, source_slice kept).
- `godot-mindustry/tools/runtime_proofs/C06PowerShouldConsumeProof.gd` + `.tscn` (new, uid `uid://c6powercons12`). Proof JSON is gitignored, never stage it.
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`: totals 1575 → 1576, N2125 checklist row, Current-cube sentence, Not Done C06 leg, migration-log row (after N2122 — the table runs to N2122 at line 3648; N2123/N2124 rows are missing, not backfilled).
- `docs/superpowers/reports/2026-11-11-c06-power-should-consume.md` (this batch's report; gate/suite lines TBD — the main turn fills the real results after the gate).

## Verified numbers (do not re-derive, these are measured)

- Proof `C06PowerShouldConsumeProof`: **23/23 keys true** (counted from `godot-mindustry/tools/runtime_proofs/C06PowerShouldConsumeProof.json`, `matches: true`, 0 false). Live numbers: baseline needed 0.1 / produced 0.002 / coverage 0.02 / battery 0.0; disabled lancer → needed 0.0 / coverage 1.0; 60 live ticks disabled → frame still disabled, needed stays 0.0; 600 live ticks → battery stored > 0.0 (≈ 1.2), coverage stays 1.0; re-enabled → needed 0.1, coverage 1.0 (the charged battery covers the deficit), battery drains over the next 60 ticks.
- Test module standalone: **4/4 OK in 55.655s** (run after the register script; the proof run inside it verifies the proof JSON).
- First standalone run was 1/4 (failures=3): the driver rule said "should-consume" (hyphen) where the registration test pins `should_consume`; the live-state test looked for the frame meta keys inside the helper span while they live in the file-level const; the proof asserted re-enabled coverage 0.02, but the charged battery legitimately covers the deficit at coverage 1.0 (the N2082/N2083 discharge path) — all three fixed in the test/register/proof, not in the implementation, and the module re-ran 4/4.
- All 77 shards equal a fresh `build_extension_shard` (verified after the register run). `git diff --check` clean.
- Suite size: 5593 + 4 new tests = **5597** expected (203 modules).

## Deferred (not this slice)

- `PowerGraph.getBatteryStored` gates on `battery.enabled` (PowerGraph.java:118-126), but the battery has no tick frame in the port, so its live enabled flag cannot be read yet; the battery dict keeps its static enabled value.
- The shouldConsumePower half that clears when a non-power consumer fails (BuildingComp.java:1971-1974, first pass) is a later slice; this slice wires only the enabled half.
- `ConsumeItemDynamic.trigger` at unit completion (ConsumeItemDynamic.java:53-56).
- UnitAssembler plan dynamics (UnitAssembler.java:158-160).
- Per-building timeScale expiry plus the disabled-building updateTile gate (BuildingComp.java:2262-2276); timeScaleDuration decay already runs in `simulate_block_time_scales`.
- Source-exhaustion/output-full acts.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Next: N2126 (candidates)

The remaining C06 work, in the order the N2125 builder considered them: per-building timeScale expiry + the disabled-building updateTile gate (timeScaleDuration decay already runs in `simulate_block_time_scales`; the `enabled || !block.noUpdateDisabled` gate at BuildingComp.java:2276 is vacuous for GenericCrafter since noUpdateDisabled defaults false — the slice needs a building where it bites), source-exhaustion/output-full acts, `ConsumeItemDynamic.trigger` at unit completion, UnitAssembler plan dynamics, the battery live `enabled` stamp.
