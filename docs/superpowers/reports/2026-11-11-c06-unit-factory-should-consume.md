# Report — N2124: per-class shouldConsume() bodies (2026-11-11)

## What was built

The per-class shouldConsume() bodies, so the live tick stops passing the frame `enabled` flag as should_consume for unit factories: UnitFactory.java:446 (`enabled && payload == null && team.activateUnitFactories()`, `currentPlan == -1` → false), Reconstructor.java:368 (`constructing && enabled && team.activateUnitFactories()`, `constructing()` = `payload != null && hasUpgrade(payload.unit.type)`), UnitAssembler.java:389 (`enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories()`). The dispatcher plus `activate` / `hasUpgrade` / `assembler-plan` / `assembler-cons-item-efficiency` helpers live in `SourceUnitFactoryBuildState.gd`, and the tick driver runs them through updateConsumption's second pass with the live cheating flag. The emitter now captures `_unit_factory_plans()` in both `Seq.with(...)` and `plans.add(new UnitPlan(...))` forms (all 6 UnitFactory blocks' plans), plus reconstructor `upgrades` and assembler `assemblerPlans`; the `content_registry_blocks` shard was rebuilt.

## Files

- `godot-mindustry/src/game/SourceUnitFactoryBuildState.gd` (+263): shouldConsume dispatcher + 4 helpers.
- `godot-mindustry/src/game/SourceRulesDefaults.gd`: `UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT := 0.0` (Rules.java:93, TeamRule Rules.java:351).
- `godot-mindustry/src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd`: 5 new port constants.
- `godot-mindustry/tools/runtime_proofs/UnitFactoryConsumerBindingProof.gd`: the live section now holds a dagger payload on the reconstructor frame (additive-reconstructor upgrades dagger → mace); also fixed a one-line compile-breaker in the N2123 pause agent's `SourceGameLoopRuntimeState.gd:19` (`Object.get()` takes at most 1 arg).
- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py` (+106) + `tests/test_content_registry.py` (+88).
- `tools/mindustry_godot_transpiler/tests/test_unit_factory_should_consume.py` (new, 4 tests) + `register_unit_factory_should_consume.py` (new).
- `godot-mindustry/src/generated/`: N2124 ledger row (42 symbols, 31 exprs), 5 contracts, 10 schemas, registry + `content_registry_blocks` shard rebuilt.
- `godot-mindustry/tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.gd` + `.tscn` (new). Proof: **42/42 keys true**, `matches: true`.

## Gates (measured)

- Targeted gate: **5593 tests OK** (log `~/workspace/logs/targeted-n2123-n2124.log`, 1831.774s). First run killed by the ~12:56 +07 VM restart; re-run green.
- Full Python suite: **5593 tests OK** (log `~/workspace/logs/full-suite-n2123-n2124.log`, 1846.009s). Suite size: 5584 + 9 new tests = 5593.

## SSOT delta

SSOT +42/+1/+5/+10 → 11224 symbols / 1575 slices / 1499 contracts / 2789 schemas; audit `totalSourceFunctions` stays 1335.

## Still open

`Units.canCreate` live evaluation (needs C07), `consPayload.efficiency` (needs the payload module), the payload frame key and `UnitAssemblerBuild.wasOccupied` are not set by the live loop yet, `ConsumeItemDynamic.trigger` at unit completion; timeScale/disable/removal, source-exhaustion/output-full acts. C06–C12 remain open.
