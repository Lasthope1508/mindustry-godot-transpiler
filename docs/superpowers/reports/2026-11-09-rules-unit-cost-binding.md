# C05 rules unit cost — N2096

Date: 2026-11-09. Batch: N2096 (single slice, second C05 batch). SSOT +3/+1/+1/+2 → 10822 / 1549 / 1437 / 2665; audit `totalSourceFunctions` stays 1335.

## What changed

The consumer multiplier was a default-only binding: `SourceConsumeState.source_cost_multiplier_state` returned `{"multiplier": 1.0}` unconditionally. The actual source callbacks are the unit factories' — UnitFactory, Reconstructor and UnitAssembler all set each consumer's multiplier to `b -> state.rules.unitCost(b.team)` (UnitFactory.java:109, Reconstructor.java:149, UnitAssembler.java:175). This slice is the live rules value those callbacks read.

- N2096 `SourceRulesRuntimeState.source_unit_cost_state(rules_state, team_id)` — computes `Rules.unitCost(team)` (Rules.java:275-276: `return unitCostMultiplier * teams.get(team).unitCostMultiplier;`). The global multiplier defaults to 1f (Rules.java:83) and the per-team multiplier defaults to 1f (Rules.java:361, TeamRules); both defaults live in `SourceRulesDefaults.UNIT_COST_MULTIPLIER_DEFAULT`. The rules state shape is `{"unitCostMultiplier": float, "teams": {team_id: {"unitCostMultiplier": float}}}`; team keys resolve as ints (built in GDScript) or strings (from JSON). A team with no entry falls back to the global multiplier.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_rules_unit_cost_binding.py` (registration + exact-evidence + Godot proof) — RED before the register script ran (1 failure, 2 errors), GREEN after.
- Godot proof `RulesUnitCostProof` **8/8 true** on the real Main scene: defaults 1.0, global 2.0 alone → 2.0, global 2.0 with team 0.5 → 1.0, other team 3.0, missing team falls back to global 2.0, string team key resolves to 1.0.
- Targeted gate: the rules-unit-cost + content-registry + hydration + emitter + parity + symbols + playable tests — **4958 tests OK in 720.378s, exit=0** (log `~/workspace/logs/targeted-n2096.log`).
- Full Python suite: **5487 tests OK in 1362.728s, exit=0** (log `~/workspace/logs/full-suite-n2096.log`).

## SSOT delta

+3 symbols / +1 slice / +1 contract / +2 schemas → 10822 / 1549 / 1437 / 2665; audit `totalSourceFunctions` stays 1335. The owner (`game/Rules.java`) mirrors into no module shard, same as `game/Teams.java`.

## Still open

- C05: wiring `source_cost_multiplier_state` to return `unitCost` for unit-producing blocks (the next slice — this batch is the rules value it reads), live TeamRules cheating, and the descriptor/apply/adapter cache invalidation on Block reinit/reload. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open. A live thorium-reactor placement proof (placed reactor consuming thorium + cryofluid in the world) is a future slice.
