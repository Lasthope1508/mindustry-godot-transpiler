# Handoff — C05 per-block cost multiplier (N2097)

Date: 2026-11-09. Batch: N2097 (single slice, third C05 batch). Commit: (pending — fill in after push).

## Done

- `SourceConsumeState.source_cost_multiplier_for_block_state(build)` — the per-block multiplier callback: `Consume.multiplier` is a per-consumer callback (Consume.java:18, default `b -> 1f`); unit factories override it with `b -> state.rules.unitCost(b.team)` (UnitFactory.java:109, Reconstructor.java:149, UnitAssembler.java:175). The function reads `block_implementation`, `team_id` and `rules_state` from the build dict (the building frame) and returns `Rules.unitCost` (N2096) for UnitFactory/Reconstructor/UnitAssembler blocks, 1.0 otherwise; a build without the keys keeps the 1.0 default.
- The drill's tick sets the three frame keys before the consumers are created (block implementation, team from the sprite's `team_id` meta, rules from the game's `rules_state` or `{}`) and passes this function as the consumer Callable. The drill keeps 1.0 through the new path, proven live.
- Register script `tools/mindustry_godot_transpiler/register_cost_multiplier_for_block_binding.py`; test `tools/mindustry_godot_transpiler/tests/test_cost_multiplier_for_block_binding.py`; proof `godot-mindustry/tools/runtime_proofs/CostMultiplierForBlockProof.gd/.tscn`.
- SSOT +2/+1/+1/+2 → 10824 symbols / 1550 slices / 1438 contracts / 2667 schemas; audit `totalSourceFunctions` stays 1335. The owner mirrors into the `unit_building_*` module shards (all 4 files).

## Verification

- Test RED before the register script (1 failure, 2 errors), GREEN after: 3 tests OK. Fixes: the proof read the frame consumer as a dict (`["consumer"]`) but the frame holds the RuntimeConsumer directly; a rerun without `godot` on PATH failed fast at `shutil.which` (PATH export must be in the same command).
- Godot proof `CostMultiplierForBlockProof` 14/14 true on the real Main scene.
- Targeted gate: **4961 tests OK in 723.240s, exit=0** (log `~/workspace/logs/targeted-n2097.log`).
- Full Python suite: **5490 tests OK in 1369.931s, exit=0** (log `~/workspace/logs/full-suite-n2097b.log`). The first run died mid-run after the VM restarted (~09:37); the rerun is clean.

## Still open

- C05 next: the game rules state (live, mutable rules dict on the game); live TeamRules cheating; cache invalidation on Block reinit/reload. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceConsumeState.gd` (new function + `SOURCE_UNIT_FACTORY_IMPLEMENTATIONS`)
- `godot-mindustry/src/game/SourceDrillConsumptionRuntimeState.gd` (frame keys + new Callable)
- `godot-mindustry/tools/runtime_proofs/CostMultiplierForBlockProof.gd` + `.tscn` (new)
- `tools/mindustry_godot_transpiler/register_cost_multiplier_for_block_binding.py` (new)
- `tools/mindustry_godot_transpiler/tests/test_cost_multiplier_for_block_binding.py` (new)
- `godot-mindustry/src/generated/source_symbol_registry.json`, `source_slice_ledger.json`, `source_api_contracts.json`, `source_state_schema.json`, `source_modules/unit_building_*.json`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-09-cost-multiplier-for-block-binding.md`, `docs/superpowers/handoffs/2026-11-09-cost-multiplier-for-block-binding-handoff.md`
