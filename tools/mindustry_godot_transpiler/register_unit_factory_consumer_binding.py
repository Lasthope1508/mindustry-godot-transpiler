"""Register the UnitFactory family RuntimeConsumer binding (N2120).

N2109 wired the unit-factory family's frame keys live and the
consumption adapter runs the shared updateConsumption machinery with
that live flag, but the machinery still ran over an empty actor list:
a placed additive-reconstructor kept its silicon and graphite forever
and a tank-assembler kept its cyanogen. N2120 binds one
RuntimeConsumer actor per consumeItem/consumeLiquid row (the drill
model, N2097/N2100; the GenericCrafter binding in N2112) into the
live-loop tick and runs them through BuildingComp.updateConsumption's
first and second passes, so the placed factory actually consumes: the
liquid rows drain per tick and the item rows gate efficiency on the
stacks held. The tick binds through the N2116 reinitialize path, so a
sprite re-recorded with a different block (Tile.changeBuild) or a
factory whose current plan changed (UnitFactory config) drops the old
actors and rebinds from the new rows.

The UnitFactory class itself carries no static consumeItem rows: its
items come from the ConsumeItemDynamic over the current plan's
requirements (UnitFactory.java:84), so one more item actor binds per
requirement of the frame's current plan (frame["current_plan"], -1
when no plan is set; the config handler clamps an out-of-range index
to -1, UnitFactory.java:60-62). The registry captures each plan as
unitPlans (N2120 emitter change: `plans = Seq.with(new
UnitPlan(...))` for the ground/air/naval factories and
`plans.add(new UnitPlan(...))` for the single-plan Erekir
fabricators). The UnitAssembler's plan dynamics
(ConsumePayloadDynamic, ConsumeItemDynamic over plan().itemReq,
ConsumeLiquidsDynamic over plan().liquidReq, UnitAssembler.java:158-
160) are a later slice; the registry captures no assembler plans yet.

Java: Block.consumeItems registers one ConsumeItems per call
(Block.java:1175-1177) and consumeLiquid one ConsumeLiquid per call
(Block.java:1127-1131); the registry captures each call's stacks into
properties["consumeItem"]/["consumeLiquid"] (N2095). ConsumeItems
efficiency is 1 when the building is burning a trigger consumer or
its item module holds the stack amount times the multiplier
(ConsumeItems.java:52), and its trigger removes each stack once per
craft (ConsumeItems.java:46); Consume.update itself is empty
(Consume.java:52), so the per-tick second pass removes nothing for
items. ConsumeItemDynamic.efficiency is the same formula over the
current plan's requirements (ConsumeItemDynamic.java:57-59) and its
trigger removes the plan stacks when the unit finishes
(ConsumeItemDynamic.java:53-56). ConsumeLiquid.update removes amount
* edelta * multiplier every tick (ConsumeLiquid.java:38-40).
updateConsumption (BuildingComp.java:1943-2004) runs the first pass
(minimum efficiency of the non-optional consumers) and the second
pass (update every update consumer when update, i.e. shouldConsume()
&& productionValid(), and efficiency > 0). The three classes all set
each consumer's multiplier to Rules.unitCost (UnitFactory.java:109,
Reconstructor.java:149, UnitAssembler.java:175, bound by N2096-N2097),
so a reconstructor's stacks cost amount * unitCost. The tick passes
the frame enabled flag as should_consume until the per-class
shouldConsume() bodies (UnitFactory.java:446, Reconstructor.java:368,
UnitAssembler.java:389) land; the power consumer stays the power
graph's domain (N2080/N2107).
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
CONSUME_ITEMS = 'core/src/mindustry/world/consumers/ConsumeItems.java'
CONSUME_ITEM_DYNAMIC = 'core/src/mindustry/world/consumers/ConsumeItemDynamic.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
BLOCK = 'core/src/mindustry/world/Block.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BIND_OWNER = 'SourceUnitFactoryBuildState.source_bind_consumer_state'
PLAN_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_plan_requirements_state'
REINIT_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_reinitialize_consumers_state'
TICK_OWNER = 'SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state'
PROOF = '/root/UnitFactoryConsumerBindingProof'
TESTS = ['test_unit_factory_consumer_binding_registration', 'test_all_unit_factory_consumer_binding_input_evidence_is_exact', 'test_tick_binds_runtime_consumers_for_unit_factory', 'test_reference_graph_and_actual_unit_factory_consumer_binding']
DEFERRED = [
    'The three per-class shouldConsume() bodies (UnitFactory.java:446, Reconstructor.java:368, UnitAssembler.java:389) are later slices; the tick passes the frame enabled flag as should_consume until then.',
    'The plan stacks leave only at unit completion via ConsumeItemDynamic.trigger (ConsumeItemDynamic.java:53-56); the per-tick second pass removes nothing for items, so the production slice owns the trigger.',
    'The UnitAssembler plan dynamics (ConsumePayloadDynamic, ConsumeItemDynamic over plan().itemReq, ConsumeLiquidsDynamic over plan().liquidReq, UnitAssembler.java:158-160) are later slices; the registry captures no assembler plans yet, so no dynamic rows bind for them.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class UnitFactoryBuild extends UnitBuild{',
    'public class ReconstructorBuild extends UnitBuild{',
    'public class UnitAssemblerBuild extends PayloadBlockBuild<Payload>{',
    'public void updateTile(){',
    'public void updateConsumption(){',
    'if(!block.hasConsumers || cheating()){',
    'for(var cons : block.updateConsumers){',
    'cons.update(self());',
    'public ConsumeItems consumeItems(ItemStack... items){',
    'public ConsumeItems consumeItem(Item item, int amount){',
    'return consume(new ConsumeItems(items));',
    'return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;',
    'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));',
    'public void update(Building build){}',
    'public Floatf<Building> multiplier = b -> 1f;',
    'public boolean ignore(){',
    'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));',
    'public boolean consumeTriggerValid(){',
    'protected Seq<Consume> consumeBuilder = new Seq<>();',
    'public final Building newBuilding(){',
    'public boolean has(Item item, int amount){',
    'public void remove(Liquid liquid, float amount){',
    'consumeBuilder.each(c -> c.multiplier = b -> state.rules.unitCost(b.team));',
    'consumeItems(with(Items.silicon, 40, Items.graphite, 40));',
    'consumeLiquid(Liquids.cyanogen, 9f / 60f);',
    'public void reinitializeConsumers(){',
    'public static class UnitPlan{',
    'public UnitType unit;',
    'public ItemStack[] requirements;',
    'public float time;',
    'plans = Seq.with(',
    'plans.add(new UnitPlan(UnitTypes.stell, 60f * 35f, with(Items.beryllium, 40, Items.silicon, 50)));',
    'build.currentPlan = i < 0 || i >= plans.size ? -1 : i;',
    'return build.consumeTriggerValid() || build.items.has(items.get(build), multiplier.get(build)) ? 1f : 0f;',
    'public boolean shouldConsume(){',
    'public void trigger(Building build){',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=UNIT_FACTORY, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2120_bind_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The unit-factory frame (the port Building state) the consumers bind onto; created at placement (Block.newBuilding).', source=BLOCK),
        'block': f('Object', 'public class UnitFactoryBuild extends UnitBuild{', 'The typed block definition; only a block carrying consumeItem/consumeLiquid rows, or a current plan with requirements, binds consumers.'),
        'catalog': f('Object', 'protected Seq<Consume> consumeBuilder = new Seq<>();', "The content catalog the bound rows resolve their item and liquid fields against (the block's consumeBuilder).", source=BLOCK),
        'amounts': f('Dictionary', 'public void remove(Liquid liquid, float amount){', "The building's liquid module the liquid actors remove from (LiquidModule.remove).", source=LIQUID_MODULE),
    }
    n2120_bind_outputs = {
        'bound': f('bool', 'public ConsumeItems consumeItem(Item item, int amount){', 'Whether RuntimeConsumer actors were created on this call; false when the frame already carries them.', source=BLOCK),
        'consumers': f('Array', 'for(var cons : block.updateConsumers){', 'The RuntimeConsumer actors on the frame, one per bound consumeItem/consumeLiquid row and per current-plan requirement.', source=BUILDING_COMP),
        'rows': f('Array', 'protected Seq<Consume> consumeBuilder = new Seq<>();', 'The bound consume rows (item stacks + liquid descriptors + plan requirements) the actors were built from.', source=BLOCK),
    }
    n2120_plan_inputs = {
        'block': f('Object', 'public static class UnitPlan{', "The typed block definition; its unitPlans are the plans the current plan's requirements come from (UnitPlan holds the unit, the build time and the ItemStack[] requirements)."),
        'plan_index': f('int', 'plans.get(Math.min(e.currentPlan, plans.size - 1)).requirements', "The frame's current plan index (UnitFactoryBuild.currentPlan, -1 when no plan is set); the ConsumeItemDynamic reads plans.get(currentPlan).requirements, or ItemStack.empty when there is none."),
    }
    n2120_plan_outputs = {
        'unit': f('String', 'public UnitType unit;', 'The planned unit type (UnitPlan.unit), kebab-cased from UnitTypes.'),
        'time': f('float', 'public float time;', 'The planned build time in ticks (UnitPlan.time).'),
        'items': f('Array', 'public ItemStack[] requirements;', 'The plan requirements as item stacks (UnitPlan.requirements), the ConsumeItemDynamic rows for the current plan.'),
    }
    n2120_reinit_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The unit-factory frame (the port Building state) the consumers bind onto; created at placement (Block.newBuilding).', source=BLOCK),
        'block': f('Object', 'public class UnitFactoryBuild extends UnitBuild{', 'The typed block definition; only a block carrying consumeItem/consumeLiquid rows, or a current plan with requirements, binds consumers.'),
        'catalog': f('Object', 'protected Seq<Consume> consumeBuilder = new Seq<>();', "The content catalog the bound rows resolve their item and liquid fields against (the block's consumeBuilder).", source=BLOCK),
        'amounts': f('Dictionary', 'public void remove(Liquid liquid, float amount){', "The building's liquid module the liquid actors remove from (LiquidModule.remove).", source=LIQUID_MODULE),
    }
    n2120_reinit_outputs = {
        'reinitialized': f('bool', 'public void reinitializeConsumers(){', 'Whether the frame dropped stale RuntimeConsumer actors and rebound (a replaced block, or a changed plan with actors already bound).', source=BLOCK),
        'bound': f('bool', 'public ConsumeItems consumeItem(Item item, int amount){', 'Whether RuntimeConsumer actors were created on this call; false when the frame already carries them.', source=BLOCK),
        'consumers': f('Array', 'for(var cons : block.updateConsumers){', 'The RuntimeConsumer actors on the frame, one per bound consumeItem/consumeLiquid row and per current-plan requirement.', source=BUILDING_COMP),
        'rows': f('Array', 'protected Seq<Consume> consumeBuilder = new Seq<>();', 'The bound consume rows (item stacks + liquid descriptors + plan requirements) the actors were built from.', source=BLOCK),
    }

    entries = [
        ('N2120', BIND_OWNER, 'source_unit_factory_bind_consumer_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'UnitFactoryBuild.updateTile()', n2120_bind_inputs, n2120_bind_outputs, True, 'Dictionary'),
        ('N2120', PLAN_OWNER, 'source_unit_factory_plan_requirements_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'UnitFactoryBuild.unit()', n2120_plan_inputs, n2120_plan_outputs, True, 'Dictionary'),
        ('N2120', REINIT_OWNER, 'source_unit_factory_reinitialize_consumers_state', UNIT_FACTORY, 'mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', 'Block.reinitializeConsumers()', n2120_reinit_inputs, n2120_reinit_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed UnitFactory family RuntimeConsumer binding.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed UnitFactory family RuntimeConsumer binding; the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and per current-plan requirement and runs the bound actors through updateConsumption, so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows.'))
        all_names.extend(names)

    # The live-loop tick driver (N2109) gains the consumption half of
    # updateTile (N2112 pattern: deepcopy the existing contract and
    # extend its rule and tests, keeping the N2109 source_slice the
    # driver itself was registered under; the game+seconds params are
    # unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and per current-plan requirement through the reinitialize path and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2120'] = sorted(all_names)
    # One slice row: the live-loop tick driver is the primary owner; the
    # bind, plan-requirements and reinitialize helpers share the slice
    # (their symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2120', dict(status='done', java_source=UNIT_FACTORY, java_class='mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild', java_method='UnitFactoryBuild.updateTile(); BuildingComp.updateConsumption(); ConsumeItemDynamic.efficiency()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
