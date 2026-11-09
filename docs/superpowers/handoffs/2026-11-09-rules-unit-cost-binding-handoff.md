# Handoff — C05 rules unit cost (N2096)

Date: 2026-11-09. Batch: N2096 (single slice, second C05 batch). Commit: (pending — fill in after push).

## Done

- `SourceRulesRuntimeState.source_unit_cost_state(rules_state, team_id)` — the live `Rules.unitCost(team)` value (Rules.java:275-276): global `unitCostMultiplier` (default 1f, Rules.java:83) times the per-team `unitCostMultiplier` (default 1f, Rules.java:361, TeamRules). Both defaults live in `SourceRulesDefaults.UNIT_COST_MULTIPLIER_DEFAULT`. Team keys resolve as ints or strings; a team with no entry falls back to the global multiplier.
- This is the value the unit factories' multiplier callbacks read: UnitFactory.java:109, Reconstructor.java:149, UnitAssembler.java:175 all set each consumer's multiplier to `b -> state.rules.unitCost(b.team)`. It replaces nothing yet — the wiring of `source_cost_multiplier_state` to return it for unit-producing blocks is the next slice.
- Register script `tools/mindustry_godot_transpiler/register_rules_unit_cost_binding.py`; test `tools/mindustry_godot_transpiler/tests/test_rules_unit_cost_binding.py`; proof `godot-mindustry/tools/runtime_proofs/RulesUnitCostProof.gd/.tscn`.
- SSOT +3/+1/+1/+2 → 10822 symbols / 1549 slices / 1437 contracts / 2665 schemas; audit `totalSourceFunctions` stays 1335. No module shard mirrors the owner (`game/Rules.java`, same as `game/Teams.java`).

## Verification

- Test RED before the register script (1 failure, 2 errors), GREEN after: 3 tests OK.
- Godot proof `RulesUnitCostProof` 8/8 true on the real Main scene.
- Targeted gate: **4958 tests OK in 720.378s, exit=0** (log `~/workspace/logs/targeted-n2096.log`).
- Full Python suite: **5487 tests OK in 1362.728s, exit=0** (log `~/workspace/logs/full-suite-n2096.log`).

## Still open

- C05 next: wire `source_cost_multiplier_state` to return `unitCost` for unit-producing blocks; live TeamRules cheating; cache invalidation on Block reinit/reload. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceRulesRuntimeState.gd` (new)
- `godot-mindustry/src/game/SourceRulesDefaults.gd` (`UNIT_COST_MULTIPLIER_DEFAULT`)
- `godot-mindustry/tools/runtime_proofs/RulesUnitCostProof.gd` + `.tscn` (new)
- `tools/mindustry_godot_transpiler/register_rules_unit_cost_binding.py` (new)
- `tools/mindustry_godot_transpiler/tests/test_rules_unit_cost_binding.py` (new)
- `godot-mindustry/src/generated/source_symbol_registry.json`, `source_slice_ledger.json`, `source_api_contracts.json`, `source_state_schema.json`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-09-rules-unit-cost-binding.md`, `docs/superpowers/handoffs/2026-11-09-rules-unit-cost-binding-handoff.md`
