# Handoff — C05 Power-graph consumer live cheating value (N2107)

Date: 2026-11-10. Batch: N2107 (single slice, SSOT slice). Commit: `7f65794`.

## Done

- `SourcePlacedPowerGraphState.source_consumer_cheating_for_cell_state(game, cell)` reads a placed building's live TeamRule cheat flag from its team and the game rules (`TeamComp.cheating()`, TeamComp.java:17-19; `Team.rules()`, Team.java:88-90; `TeamRules.get`, Rules.java:391-394; `TeamRule.cheat`, Rules.java:328, default false) — the same live-rules read the drill/ContinuousLiquidTurret ticks use (N2099/N2106). A cell with no sprite returns `cheating=false, found=false`.
- `SourcePlacedPowerGraphState._group_state` stamps `origin_cell` on each grouped consumer dict (mirroring batteries), so the live-loop step can find the building's sprite.
- `SourceFactoryRuntimeState.source_factory_update_power_graph_state(game, delta)` stamps each grouped consumer dict with its building's live cheating value before the update runs (the battery pattern); a consumer without a Vector2i origin keeps the false default.
- `SourcePowerGraphState.update_state(...)` now takes the cheat branch when the first consumer cheats (PowerGraph.java:217-224): every real consumer's `power_status` is set to 1.0 and the update returns needed/produced/lasts 1.0 without running the balance or battery distribution. The cheat state was computed before but never honoured; the non-cheat path is unchanged.
- `godot-mindustry/tools/runtime_proofs/PowerGraphLiveUpdateProof.gd` extended with 7 checks: helper false on an empty cell, drill team known, helper true for the drill cell while its team cheats, first consumer (the drill) carries `cheating=true`, the gate fires with all consumer statuses 1.0, and uncheating restores the 6.0/60 / 0.12/60 balance.
- New test `tools/mindustry_godot_transpiler/tests/test_power_graph_consumer_cheating.py` (4 tests: registration, exact-evidence, source-text, proof run) and register script `tools/mindustry_godot_transpiler/register_power_graph_consumer_cheating.py`.
- Stale pin fixed (test-only): `test_playable.py:17111` pinned the old one-line consumer append (`consumers.append(source_building_power_state.block_consumer_state(block, source_delta))`); N2107 binds the consumer state to a local var first to stamp `origin_cell`, so the pin now asserts the three new lines (`var consumer_state := ...`, `consumer_state["origin_cell"] = origin`, `consumers.append(consumer_state)`), mirroring the battery pins in the same test.
- SSOT +6/+1/+1/+2 → 10871 symbols / 1558 slices / 1447 contracts / 2685 schemas; audit `totalSourceFunctions` stays 1335. Owner mirrors into the `power_*` shards (slice row + extended driver contract; the helper contract lives in the canonical file only — the shard mirrors one owner per slice).

## Verification

- New test module: 4 tests OK in 12.711s.
- Godot proof `PowerGraphLiveUpdateProof` 13/13 true on the real Main scene: the drill's team cheating flips the first consumer to `cheating=true`, the gate fires (needed/produced/lasts 1.0, all consumer `power_status` 1.0), and uncheating restores 6.0/60 needed and 0.12/60 produced.
- Targeted gate (log `~/workspace/logs/targeted-n2107c.log`): **5520 tests OK in 1524.583s, exit=0** (0 FAIL sections; exactly one summary line). The first gate run (`targeted-n2107.log`) failed on 1 stale pin — `test_playable.py:17111` pinned the old one-line consumer append; N2107 binds the consumer state to a local var first (to stamp `origin_cell`), so the pin now asserts the three new lines (test-only fix, no runtime change). The first rerun (`targeted-n2107b.log`) died at 5421 dots in the VM restart; the clean rerun is `targeted-n2107c.log`, 5520 tests OK.
- Full Python suite (log `~/workspace/logs/full-suite-n2107.log`): **5520 tests OK in 1510.748s, exit=0** (0 FAIL sections; exactly one summary line).

## Still open

- C05 next: wiring the turret and factory families' own ticks to the live cheating value (their ticks do not exist in the live loop yet). C06 factory→core→defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourcePlacedPowerGraphState.gd`
- `godot-mindustry/src/game/SourceFactoryRuntimeState.gd`
- `godot-mindustry/src/game/SourcePowerGraphState.gd`
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/power_api_contracts.json`
- `godot-mindustry/src/generated/source_modules/power_slices.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/PowerGraphLiveUpdateProof.gd`
- `tools/mindustry_godot_transpiler/register_power_graph_consumer_cheating.py`
- `tools/mindustry_godot_transpiler/tests/test_power_graph_consumer_cheating.py`
- `tools/mindustry_godot_transpiler/tests/test_playable.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-10-power-graph-consumer-cheating.md`
- `docs/superpowers/handoffs/2026-11-10-power-graph-consumer-cheating-handoff.md`
