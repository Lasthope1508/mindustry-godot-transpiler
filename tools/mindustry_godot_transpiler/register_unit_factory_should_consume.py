"""Register the UnitFactory family per-class shouldConsume() bodies (N2124).

N2120 wired the unit-factory family's RuntimeConsumer binding into
the live loop, but the tick still passed the frame's enabled flag as
should_consume: a plan-less ground factory, a payload-less
reconstructor and an occupied assembler all consumed at full
efficiency. N2124 wires the real per-class bodies
(UnitFactory.java:445-448, Reconstructor.java:367-369,
UnitAssembler.java:389-391) into the tick driver, so
updateConsumption gates efficiency on them exactly like Java.

UnitFactoryBuild.shouldConsume() is `currentPlan != -1 && enabled
&& payload == null && team.activateUnitFactories()`: the frame's
current plan (-1 when no plan is set, UnitFactory.java:60-62), the
held payload (UnitFactoryBuild.payload, null until the production
slice creates one at unit completion) and the activation gate
(Team.activateUnitFactories(), Team.java:127-129: `state.tick >=
state.rules.unitActivationDelay(this)`, Rules.java:315-317, both
delays default 0f, Rules.java:93/351).

ReconstructorBuild.shouldConsume() is `constructing && enabled &&
team.activateUnitFactories()`, with constructing()
(Reconstructor.java:383-385) `payload != null &&
hasUpgrade(payload.unit.type)` and hasUpgrade()
(Reconstructor.java:388-391): the upgrade map holds a pair for the
held type (Reconstructor.upgrades, Reconstructor.java:37; the
registry captures it as `upgrades`, N2124 emitter change,
Blocks.java `upgrades.addAll(...)`), the upgrade target is unlocked
for the team (UnlockableContent.unlockedNowHost(),
UnlockableContent.java:261-263; isCampaign is `rules.sector !=
null`, GameState.java:73-75; the port has no persistent unlock
store, so a campaign session reads Rules.researched,
Rules.java:187) or the team is AI-controlled (Team.isAI(),
Team.java:111-114), and the held type is not banned
(Rules.isBanned, Rules.java:310-312).

UnitAssemblerBuild.shouldConsume() is `enabled && !wasOccupied &&
Units.canCreate(team, plan().unit) && consPayload.efficiency(this)
> 0 && consItem.efficiency(this) > 0 &&
team.activateUnitFactories()`: wasOccupied is the frame's
UnitAssemblerBuild.wasOccupied (set by updateTile's spawn check,
which the port does not model yet, so the frame defaults it
false); plan() (UnitAssembler.java:386-389) reads the current
tier's AssemblerUnitPlan from the registry's `assemblerPlans`
(N2124 emitter change, Blocks.java `plans.add(new
AssemblerUnitPlan(...))`); consItem.efficiency is
ConsumeItemDynamic.efficiency (ConsumeItemDynamic.java:57-59) over
the plan's itemReq (null in vanilla, so ItemStack.empty and 1.0).
Two conjuncts are deferred to their owning slices and read from
the frame with permissive defaults that preserve the current live
behavior until then: Units.canCreate (Units.java:115-117) needs
live per-type unit counts and the unit cap (the unit-group system,
C07) and consPayload.efficiency
(ConsumePayloadDynamic.java:24-32) needs the building's payload
module (a later slice).

Java: BuildingComp.updateConsumption runs the first pass (minimum
efficiency of the non-optional consumers) and the second pass
(update every update consumer when update, i.e. shouldConsume()
&& productionValid(), and efficiency > 0)
(BuildingComp.java:1943-2004). The tick driver (N2109, extended in
place here) now passes the per-class body instead of the enabled
flag. The N2120 proof harness holds a dagger payload on its
reconstructor through the live ticks (a payload-less reconstructor
no longer consumes), so its efficiency keys still read 1.0.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
UNIT_FACTORY = 'core/src/mindustry/world/blocks/units/UnitFactory.java'
RECONSTRUCTOR = 'core/src/mindustry/world/blocks/units/Reconstructor.java'
UNIT_ASSEMBLER = 'core/src/mindustry/world/blocks/units/UnitAssembler.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME_ITEM_DYNAMIC = 'core/src/mindustry/world/consumers/ConsumeItemDynamic.java'
CONSUME_PAYLOAD_DYNAMIC = 'core/src/mindustry/world/consumers/ConsumePayloadDynamic.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
TEAM = 'core/src/mindustry/game/Team.java'
RULES = 'core/src/mindustry/game/Rules.java'
UNLOCKABLE = 'core/src/mindustry/ctype/UnlockableContent.java'
UNITS = 'core/src/mindustry/entities/Units.java'
UNIT_TYPE = 'core/src/mindustry/type/UnitType.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
SHOULD_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_should_consume_state'
ACTIVATE_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_activate_state'
UPGRADE_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_has_upgrade_state'
PLAN_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_assembler_plan_state'
CONS_ITEM_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_assembler_cons_item_efficiency_state'
TICK_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state'
PROOF = '/root/C06UnitFactoryShouldConsumeProof'
TESTS = ['test_unit_factory_should_consume_registration', 'test_all_unit_factory_should_consume_input_evidence_is_exact', 'test_tick_uses_per_class_should_consume_for_unit_factory', 'test_reference_graph_and_actual_unit_factory_should_consume']
DEFERRED = [
    'Units.canCreate(team, plan().unit) (Units.java:115-117) needs live per-type unit counts and the unit cap (the unit-group system, C07); the assembler branch reads frame["can_create"], default true, until then.',
    'consPayload.efficiency (ConsumePayloadDynamic.java:24-32) needs the building\'s payload module (the payload stacks held); the assembler branch reads frame["payload_efficiency"], default 1.0, until then.',
    'The payload frame key is never set by the live loop yet (the unit is created at completion, UnitFactory.java:432-436, and moved out by moveOutPayload); the production slice owns it.',
    'UnitAssemblerBuild.wasOccupied is never set by the live loop yet (updateTile\'s checkSolid spawn check, UnitAssembler.java:514); the frame defaults it false.',
    'The plan stacks leave only at unit completion via ConsumeItemDynamic.trigger (ConsumeItemDynamic.java:53-56); the per-tick second pass removes nothing for items, so the production slice owns the trigger.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public boolean shouldConsume(){',
    'if(currentPlan == -1) return false;',
    'return enabled && payload == null && team.activateUnitFactories();',
    'return constructing && enabled && team.activateUnitFactories();',
    'return payload != null && hasUpgrade(payload.unit.type);',
    'return t != null && (t.unlockedNowHost() || team.isAI()) && !type.isBanned();',
    'return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();',
    'public boolean activateUnitFactories(){',
    'return state.tick >= state.rules.unitActivationDelay(this);',
    'return unitFactoryActivationDelay + teams.get(team).unitFactoryActivationDelay;',
    'public float unitFactoryActivationDelay = 0f;',
    'public boolean isCampaign(){',
    'return rules.sector != null;',
    'public boolean unlockedNowHost(){',
    'return !state.isCampaign() || unlockedHost();',
    'public boolean isAI(){',
    'return (state.rules.waves || state.rules.attackMode || state.isCampaign()) && this != state.rules.defaultTeam && !state.rules.pvp;',
    'public boolean isBanned(UnitType unit){',
    'return unitWhitelist != bannedUnits.contains(unit);',
    'public static boolean canCreate(Team team, UnitType type){',
    'return !type.useUnitCap || (team.data().countType(type) < getCap(team) && !type.isBanned());',
    'public UnitType unit(){',
    'public AssemblerUnitPlan plan(){',
    'return plans.get(Math.min(currentTier, plans.size - 1));',
    'return build.consumeTriggerValid() || build.items.has(items.get(build), multiplier.get(build)) ? 1f : 0f;',
    'public boolean consumeTriggerValid(){',
    'public float efficiency(Building build){',
    'upgrades.addAll(',
    'new UnitType[]{UnitTypes.nova, UnitTypes.pulsar},',
    'plans.add(',
    'new AssemblerUnitPlan(UnitTypes.vanquish, 60f * 50f, PayloadStack.list(UnitTypes.stell, 4, Blocks.tungstenWallLarge, 10))',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=UNIT_FACTORY, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2124_should_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The unit-factory frame (the port Building state); carries current_plan, payload, was_occupied, current_tier and the deferred-term inputs the bodies read.', source='core/src/mindustry/world/Block.java'),
        'block': f('Object', 'public class UnitFactoryBuild extends UnitBuild{', 'The typed block definition; its implementation selects the per-class body and its registry properties carry the upgrade map and the assembler plans.'),
        'game': f('Object', 'public boolean activateUnitFactories(){', 'The live game; its rules_state is what Team.activateUnitFactories() reads as state.rules.', source=TEAM),
    }
    n2124_should_outputs = {
        'should_consume': f('bool', 'public boolean shouldConsume(){', 'The per-class body for this frame and block: the UnitFactory plan/payload/activation gate, the Reconstructor constructing gate, or the UnitAssembler occupied/plan/can-create/payload/item gate.'),
        'enabled': f('bool', 'return enabled && payload == null && team.activateUnitFactories();', 'The frame enabled flag (BuildingComp.enabled); every body ANDs it in.'),
        'current_plan': f('int', 'if(currentPlan == -1) return false;', 'The frame current plan (UnitFactoryBuild.currentPlan, -1 when no plan is set); the UnitFactory body returns false at -1.'),
        'has_payload': f('bool', 'return payload != null && hasUpgrade(payload.unit.type);', 'Whether the frame holds a payload (UnitFactoryBuild/ReconstructorBuild.payload); the UnitFactory body needs none held and the Reconstructor body needs one held.', source=RECONSTRUCTOR),
        'activate_unit_factories': f('bool', 'return state.tick >= state.rules.unitActivationDelay(this);', 'Whether the team activates factories at the live tick (Team.activateUnitFactories()).', source=TEAM),
        'unit_activation_delay': f('float', 'return unitFactoryActivationDelay + teams.get(team).unitFactoryActivationDelay;', 'The activation delay in ticks (Rules.unitActivationDelay).', source=RULES),
        'tick': f('float', 'return state.tick >= state.rules.unitActivationDelay(this);', 'The live game tick (state.tick, time * 60).', source=TEAM),
        'constructing': f('bool', 'return payload != null && hasUpgrade(payload.unit.type);', 'Whether the reconstructor is constructing (ReconstructorBuild.constructing()).', source=RECONSTRUCTOR),
        'has_upgrade': f('bool', 'return t != null && (t.unlockedNowHost() || team.isAI()) && !type.isBanned();', 'Whether the held unit upgrades (ReconstructorBuild.hasUpgrade()).', source=RECONSTRUCTOR),
        'upgrade_unit': f('String', 'public UnitType upgrade(UnitType type){', 'The upgrade target for the held unit, or empty when the map holds no pair for it.', source=RECONSTRUCTOR),
        'was_occupied': f('bool', 'return enabled && !wasOccupied && Units.canCreate(team, plan().unit) && consPayload.efficiency(this) > 0 && consItem.efficiency(this) > 0 && team.activateUnitFactories();', 'Whether the assembler spawn is occupied (UnitAssemblerBuild.wasOccupied).', source=UNIT_ASSEMBLER),
        'plan_unit': f('String', 'public AssemblerUnitPlan plan(){', 'The current tier plan unit (UnitAssemblerBuild.plan().unit).', source=UNIT_ASSEMBLER),
        'can_create': f('bool', 'public static boolean canCreate(Team team, UnitType type){', 'Whether the team can create the plan unit (Units.canCreate); the port has no unit counts yet, so the frame input defaults true.', source=UNITS),
        'payload_efficiency': f('float', 'public float efficiency(Building build){', 'The payload-consumer efficiency (ConsumePayloadDynamic.efficiency); the port has no payload module yet, so the frame input defaults 1.0.', source=CONSUME_PAYLOAD_DYNAMIC),
        'item_efficiency': f('float', 'return build.consumeTriggerValid() || build.items.has(items.get(build), multiplier.get(build)) ? 1f : 0f;', 'The item-consumer efficiency (ConsumeItemDynamic.efficiency) over the plan itemReq.', source=CONSUME_ITEM_DYNAMIC),
    }
    n2124_activate_inputs = {
        'rules_state': f('Dictionary', 'return unitFactoryActivationDelay + teams.get(team).unitFactoryActivationDelay;', 'The live rules state (state.rules); carries the global unitFactoryActivationDelay and the per-team TeamRule.', source=RULES),
        'team_id': f('int', 'public boolean activateUnitFactories(){', 'The building team id (b.team); selects the TeamRule whose delay adds to the global one.', source=TEAM),
    }
    n2124_activate_outputs = {
        'activate_unit_factories': f('bool', 'return state.tick >= state.rules.unitActivationDelay(this);', 'Whether the team activates factories at the live tick.', source=TEAM),
        'unit_activation_delay': f('float', 'return unitFactoryActivationDelay + teams.get(team).unitFactoryActivationDelay;', 'The activation delay in ticks.', source=RULES),
        'tick': f('float', 'return state.tick >= state.rules.unitActivationDelay(this);', 'The live game tick (state.tick, time * 60).', source=TEAM),
    }
    n2124_upgrade_inputs = {
        'block': f('Object', 'public UnitType upgrade(UnitType type){', 'The typed block definition; its registry `upgrades` map is what hasUpgrade() reads.', source=RECONSTRUCTOR),
        'payload_unit': f('String', 'return payload != null && hasUpgrade(payload.unit.type);', 'The held payload unit type (payload.unit.type); the map pair is found by its from-unit.', source=RECONSTRUCTOR),
        'rules_state': f('Dictionary', 'public boolean isBanned(UnitType unit){', 'The live rules state (state.rules); carries sector, researched, waves, attackMode, pvp, defaultTeam, unitWhitelist and bannedUnits.', source=RULES),
        'team_id': f('int', 'public boolean isAI(){', 'The building team id (b.team); isAI() is false for the default team by definition.', source=TEAM),
    }
    n2124_upgrade_outputs = {
        'has_upgrade': f('bool', 'return t != null && (t.unlockedNowHost() || team.isAI()) && !type.isBanned();', 'Whether the held unit upgrades (ReconstructorBuild.hasUpgrade()).', source=RECONSTRUCTOR),
        'upgrade_unit': f('String', 'public UnitType upgrade(UnitType type){', 'The upgrade target for the held unit, or empty when the map holds no pair for it.', source=RECONSTRUCTOR),
        'unlocked': f('bool', 'return !state.isCampaign() || unlockedHost();', 'Whether the upgrade target is unlocked for the host (UnlockableContent.unlockedNowHost()).', source=UNLOCKABLE),
        'is_ai': f('bool', 'return (state.rules.waves || state.rules.attackMode || state.isCampaign()) && this != state.rules.defaultTeam && !state.rules.pvp;', 'Whether the team is AI-controlled (Team.isAI()).', source=TEAM),
        'banned': f('bool', 'return unitWhitelist != bannedUnits.contains(unit);', 'Whether the held unit type is banned (Rules.isBanned).', source=RULES),
    }
    n2124_plan_inputs = {
        'block': f('Object', 'public AssemblerUnitPlan plan(){', 'The typed block definition; its registry `assemblerPlans` are the tier plans.', source=UNIT_ASSEMBLER),
        'tier': f('int', 'return plans.get(Math.min(currentTier, plans.size - 1));', 'The frame current tier (UnitAssemblerBuild.currentTier); clamped to the last plan.', source=UNIT_ASSEMBLER),
    }
    n2124_plan_outputs = {
        'unit': f('String', 'public UnitType unit;', 'The plan unit type (AssemblerUnitPlan.unit).', source=UNIT_ASSEMBLER),
        'time': f('float', 'public float time;', 'The plan build time in ticks (AssemblerUnitPlan.time).', source=UNIT_ASSEMBLER),
        'requirements': f('Array', 'public Seq<PayloadStack> requirements;', 'The plan payload requirements (AssemblerUnitPlan.requirements), the ConsumePayloadDynamic rows.', source=UNIT_ASSEMBLER),
        'item_req': f('Array', 'public ItemStack[] itemReq;', 'The plan item requirements (AssemblerUnitPlan.itemReq); empty in vanilla, so the dynamic item check reads ItemStack.empty.', source=UNIT_ASSEMBLER),
        'liquid_req': f('Array', 'public LiquidStack[] liquidReq;', 'The plan liquid requirements (AssemblerUnitPlan.liquidReq); empty in vanilla.', source=UNIT_ASSEMBLER),
    }
    n2124_cons_item_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The assembler frame; carries the item module and the block_implementation/team_id/rules_state the unitCost multiplier reads.', source='core/src/mindustry/world/Block.java'),
        'plan': f('Dictionary', 'public AssemblerUnitPlan plan(){', 'The current tier plan (AssemblerUnitPlan); its item_req is what the dynamic item check reads.', source=UNIT_ASSEMBLER),
    }
    n2124_cons_item_outputs = {
        'item_efficiency': f('float', 'return build.consumeTriggerValid() || build.items.has(items.get(build), multiplier.get(build)) ? 1f : 0f;', 'The dynamic item efficiency (ConsumeItemDynamic.efficiency): 1.0 when the frame holds every itemReq stack at the unitCost multiplier, 0.0 otherwise; 1.0 for an empty itemReq.', source=CONSUME_ITEM_DYNAMIC),
    }

    entries = [
        ('N2124', SHOULD_OWNER, 'source_unit_factory_should_consume_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'UnitFactoryBuild.shouldConsume(); ReconstructorBuild.shouldConsume(); UnitAssemblerBuild.shouldConsume()', n2124_should_inputs, n2124_should_outputs, True, 'Dictionary'),
        ('N2124', ACTIVATE_OWNER, 'source_unit_factory_activate_state', TEAM, 'mindustry.game.Team', 'Team.activateUnitFactories()', n2124_activate_inputs, n2124_activate_outputs, True, 'Dictionary'),
        ('N2124', UPGRADE_OWNER, 'source_unit_factory_has_upgrade_state', RECONSTRUCTOR, 'mindustry.world.blocks.units.Reconstructor.ReconstructorBuild', 'ReconstructorBuild.hasUpgrade()', n2124_upgrade_inputs, n2124_upgrade_outputs, True, 'Dictionary'),
        ('N2124', PLAN_OWNER, 'source_unit_factory_assembler_plan_state', UNIT_ASSEMBLER, 'mindustry.world.blocks.units.UnitAssembler.UnitAssemblerBuild', 'UnitAssemblerBuild.plan()', n2124_plan_inputs, n2124_plan_outputs, True, 'Dictionary'),
        ('N2124', CONS_ITEM_OWNER, 'source_unit_factory_assembler_cons_item_efficiency_state', CONSUME_ITEM_DYNAMIC, 'mindustry.world.consumers.ConsumeItemDynamic', 'ConsumeItemDynamic.efficiency()', n2124_cons_item_inputs, n2124_cons_item_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed per-class shouldConsume() bodies for the UnitFactory family.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed per-class shouldConsume() bodies for the UnitFactory family; the tick driver passes the per-class body to updateConsumption instead of the frame enabled flag.'))
        all_names.extend(names)

    # The live-loop tick driver (N2109) gains the per-class
    # shouldConsume() bodies (N2112/N2120 pattern: deepcopy the
    # existing contract and extend its rule and tests, keeping the
    # N2109 source_slice the driver itself was registered under; the
    # game+seconds params are unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and per current-plan requirement through the reinitialize path and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows, with shouldConsume now the per-class body (UnitFactory plan/payload/activation, Reconstructor constructing, UnitAssembler occupied/plan/can-create/payload/item) instead of the frame enabled flag.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2124'] = sorted(all_names)
    # One slice row: the live-loop tick driver is the primary owner; the
    # shouldConsume, activate, has-upgrade, assembler-plan and
    # cons-item helpers share the slice (their symbols carry their own
    # owner).
    source_symbols.upsert_source_slice(GODOT, 'N2124', dict(status='done', java_source=UNIT_FACTORY, java_class='mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', java_method='UnitFactoryBuild.shouldConsume(); ReconstructorBuild.shouldConsume(); UnitAssemblerBuild.shouldConsume(); Team.activateUnitFactories(); ReconstructorBuild.hasUpgrade(); UnitAssemblerBuild.plan(); ConsumeItemDynamic.efficiency()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
