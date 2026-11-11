# Handoff — N2124: per-class shouldConsume() bodies

Date: 2026-11-11. Batch: N2124 (single slice). Status: built, registered, proof 42/42 verified, test module 4/4 standalone. **Targeted gate 5593 tests OK** (log `~/workspace/logs/targeted-n2123-n2124.log`, 1831.774s); **full Python suite 5593 tests OK** (log `~/workspace/logs/full-suite-n2123-n2124.log`, 1846.009s). Joint gate with N2123: the first gate run was killed by the ~12:56 +07 VM restart; re-run green on both logs. Commit: pending (this handoff's commit step).

## What this batch is

The per-class shouldConsume() bodies: UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389 — a dispatcher plus `activate` / `hasUpgrade` / `assembler-plan` / `assembler-cons-item-efficiency` helpers, driven live through updateConsumption's second pass with the live cheating flag. 42 symbols, 31 exprs, SSOT +42/+1/+5/+10 → 11224 / 1575 / 1499 / 2789; audit 1335.

## Files changed

- `godot-mindustry/src/game/SourceUnitFactoryBuildState.gd` (+263): `source_unit_factory_should_consume_state(frame, block, game)` dispatcher — UnitFactory: `enabled && payload == null && team.activateUnitFactories()` (and `currentPlan == -1` → false); Reconstructor: `constructing && enabled && team.activateUnitFactories()`, with `constructing()` = `payload != null && hasUpgrade(payload.unit.type)`; UnitAssembler: `enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories()` — plus `source_unit_factory_activate_state` (`Team.activateUnitFactories`, Team.java:127-129: `state.tick >= state.rules.unitActivationDelay(team)`, `Rules.unitFactoryActivationDelay` + `TeamRule.unitFactoryActivationDelay`, both default 0f), `source_unit_factory_has_upgrade_state` (Reconstructor.java:367-369, `unlockedNowHost() || team.isAI()`, `!type.isBanned()`), `source_unit_factory_assembler_plan_state` (UnitAssembler.java:158-160, `plans.get(min(currentTier, plans.size - 1))` with item/liquid reqs + time + unit) and `source_unit_factory_assembler_cons_item_efficiency_state` (`ConsumeItemDynamic.efficiency`, `consumeTriggerValid() || items.has(...) ? 1f : 0f`).
- `godot-mindustry/src/game/SourceRulesDefaults.gd`: `UNIT_FACTORY_ACTIVATION_DELAY_DEFAULT := 0.0` (Rules.java:93, TeamRule Rules.java:351).
- `godot-mindustry/src/game/SourceRuntimeOwnerUnitBuildingRegistry.gd`: `PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_SHOULD_CONSUME_STATE`, `_ACTIVATE_STATE`, `_HAS_UPGRADE_STATE`, `_ASSEMBLER_PLAN_STATE`, `_ASSEMBLER_CONS_ITEM_EFFICIENCY_STATE`.
- `godot-mindustry/tools/runtime_proofs/UnitFactoryConsumerBindingProof.gd`: the N2124 live section now holds a dagger payload on the reconstructor frame (additive-reconstructor upgrades dagger → mace, Blocks.java:6311-6319) — without it the dispatcher reads should_consume false and every reconstructor efficiency key reads 0. Also fixed a one-line compile-breaker in the N2123 pause agent's `SourceGameLoopRuntimeState.gd:19` (`Object.get()` takes at most 1 arg) — that fix turned the pause module 3/4 → 4/4 and its proof green.
- `tools/mindustry_godot_transpiler/mindustry_port/content_registry.py` (+106): emitter captures `_unit_factory_plans()` in both `Seq.with(...)` and `plans.add(new UnitPlan(...))` forms — all 6 UnitFactory blocks' plans (ground 3, air 2, naval 2, tank/ship/mech-fabricator 1 each) — plus reconstructor `upgrades` and assembler `assemblerPlans`; `content_registry_blocks` shard rebuilt.
- `tools/mindustry_godot_transpiler/tests/test_content_registry.py` (+88) + `tools/mindustry_godot_transpiler/tests/test_unit_factory_should_consume.py` (new, 4 tests) + `tools/mindustry_godot_transpiler/register_unit_factory_should_consume.py` (new).
- `godot-mindustry/src/generated/` (SSOT JSONs + `content_registry.json` + `content_registry_blocks.json` shard + `MindustryContentRegistry.gd` + `unit_building_*` shards): N2124 row, 42 symbols, 5 contracts, 10 schemas.
- `godot-mindustry/tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.gd` + `.tscn` (new). Proof JSON is gitignored, never stage it.
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`: totals 1574 → 1575, N2124 checklist row.
- `docs/superpowers/reports/2026-11-11-c06-unit-factory-should-consume.md` (this batch's report; gate lines filled with the real re-gate results: targeted + full suite 5593 OK).

## Verified numbers (do not re-derive, these are measured)

- Proof `C06UnitFactoryShouldConsumeProof`: **42/42 keys true** (counted from `godot-mindustry/tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.json`, `matches: true`).
- Test module standalone: 4/4 OK (verified in the builders' run; the joint gate covers it).
- Suite size: 5584 + 9 new tests = 5593 tests (4 pause + 4 shouldConsume + 1 content-registry test).

## Deferred (not this slice)

- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch reads `frame["can_create"]`, default true, until then.
- `consPayload.efficiency` (needs the payload module); the assembler branch reads `frame["payload_efficiency"]`, default 1.0, until then.
- The payload frame key is never set by the live loop yet (the unit is created at completion, UnitFactory.java:432-436, and moved out by `moveOutPayload`); the production slice owns it.
- `UnitAssemblerBuild.wasOccupied` is never set by the live loop yet (updateTile's checkSolid spawn check, UnitAssembler.java:514); the frame defaults it false.
- `ConsumeItemDynamic.trigger` at unit completion (plan stacks leave only then, ConsumeItemDynamic.java:53-56).
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Next: N2125 (candidate)

The remaining C06 work: `ConsumeItemDynamic.trigger` at unit completion, UnitAssembler plan dynamics, shouldConsumePower-from-frame, timeScale/disable/removal, source-exhaustion/output-full acts.

## Commit

Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, proof `.json`): `SourceUnitFactoryBuildState.gd`, `SourceRulesDefaults.gd`, `SourceRuntimeOwnerUnitBuildingRegistry.gd`, `UnitFactoryConsumerBindingProof.gd`, `content_registry.py`, `test_content_registry.py`, `test_unit_factory_should_consume.py`, `register_unit_factory_should_consume.py`, `C06UnitFactoryShouldConsumeProof.gd` + `.tscn`, the generated SSOT JSONs + registry + shards, the design spec, the report + this handoff. Gates already green (targeted + full suite 5593 OK, logs `targeted-n2123-n2124.log` / `full-suite-n2123-n2124.log`). Commit: pending, then the MEMORY.md N2124 entry.
