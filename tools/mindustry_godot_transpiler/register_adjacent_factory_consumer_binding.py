"""Register the adjacent factory families RuntimeConsumer binding (N2115).

N2114 wired the Separator/Incinerator/WallCrafter/SingleBlockProducer
families into the live loop, but the machinery still ran over an empty
actor list: a placed separator kept its slag forever and a
disassembler kept its scrap and slag. N2115 binds one RuntimeConsumer
actor per consumeItem/consumeLiquid row (the drill model, N2097/N2100,
the GenericCrafter binding in N2112) into the live-loop tick and runs
them through BuildingComp.updateConsumption's first and second passes,
so the placed adjacent factory actually consumes: the liquid rows
drain per tick and the item rows gate efficiency on the stacks held.

Java: Block.consumeItems registers one ConsumeItems per call
(Block.java:1175-1177) and consumeLiquid one ConsumeLiquid per call
(Block.java:1127-1131); the registry captures each call's stacks into
properties["consumeItem"]/["consumeLiquid"] (N2095). The vanilla rows:
the separator consumes slag 4/60 per tick (Blocks.java:1244), the
disassembler scrap 1 plus slag 0.12 (Blocks.java:1263-1264), the
large-cliff-crusher hydrogen 1/60 (Blocks.java:3028); its graphite
booster is an assigned consumeItem(...).boost() row
(Blocks.java:3030), captured as boosterItem, not a consumeItem row, so
it binds no item actor; the incinerator and the cliff-crusher consume
power only (Blocks.java:1328, 3004) and bind none -- the power
consumer stays the power graph's domain (N2080/N2107). No vanilla
block uses SingleBlockProducer, whose dynamic item consumer
(BlockProducer.java:39-45, ConsumeItemDynamic) is not a consumeItem
row either. ConsumeItems efficiency is 1 when the building is burning
a trigger consumer or its item module holds the stack amount times
the multiplier (ConsumeItems.java:52), and its trigger removes each
stack once per craft (ConsumeItems.java:46, called from
Separator.craft() via consume(), Separator.java:158, and likewise
WallCrafter.java:208 and BlockProducer.java:116); Consume.update
itself is empty (Consume.java:52), so the per-tick second pass removes
nothing for items -- the craft slice owns the trigger.
ConsumeLiquid.update removes amount * edelta * multiplier every tick
(ConsumeLiquid.java:38-40). updateConsumption
(BuildingComp.java:1943-2004) runs the first pass (minimum efficiency
of the non-optional consumers) and the second pass (update every
update consumer when update, i.e. shouldConsume() &&
productionValid(), and efficiency > 0).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SEPARATOR = 'core/src/mindustry/world/blocks/production/Separator.java'
INCINERATOR = 'core/src/mindustry/world/blocks/production/Incinerator.java'
WALL_CRAFTER = 'core/src/mindustry/world/blocks/production/WallCrafter.java'
SINGLE_BLOCK_PRODUCER = 'core/src/mindustry/world/blocks/production/SingleBlockProducer.java'
BLOCK_PRODUCER = 'core/src/mindustry/world/blocks/payloads/BlockProducer.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME_ITEMS = 'core/src/mindustry/world/consumers/ConsumeItems.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BIND_OWNER = 'SourceAdjacentFactoryBuildState.source_bind_consumer_state'
TICK_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state'
PROOF = '/root/AdjacentFactoryConsumerBindingProof'
TESTS = ['test_adjacent_factory_consumer_binding_registration', 'test_all_adjacent_factory_consumer_binding_input_evidence_is_exact', 'test_tick_binds_runtime_consumers_for_adjacent_factory', 'test_reference_graph_and_actual_adjacent_factory_consumer_binding']
DEFERRED = [
    'Item stacks leave only at craft() via ConsumeItems.trigger (Separator.java:158, WallCrafter.java:208, BlockProducer.java:116); the per-tick second pass removes nothing for items, so the craft/progress slice owns the trigger.',
    'SingleBlockProducer has no vanilla block, so its dynamic item consumer (BlockProducer.java:39-45, ConsumeItemDynamic, resolved per recipe at runtime) binds no actor; a mod block using it needs a dynamic-binding slice.',
    'The C05 gate (lifecycle replacement, storage independence, consumer classification) is a later slice; the adjacent families are the last factory-adjacent work before it.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class Separator extends Block{',
    'public class SeparatorBuild extends Building{',
    'public void updateTile(){',
    'public class Incinerator extends Block{',
    'public class WallCrafter extends Block{',
    'public class SingleBlockProducer extends BlockProducer{',
    'public class SingleBlockProducerBuild extends BlockProducerBuild{',
    'consume(new ConsumeItemDynamic((BlockProducerBuild e) -> {',
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
    'consumeLiquid(Liquids.slag, 4f / 60f);',
    'consumeItem(Items.scrap);',
    'consumeLiquid(Liquids.slag, 0.12f);',
    'consumeLiquid(Liquids.hydrogen, 1f / 60f);',
    'itemConsumer = consumeItem(Items.graphite).boost();',
    'consumePower(0.50f);',
    'consumePower(11 / 60f);',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=SEPARATOR, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2115_bind_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The adjacent-factory frame (the port Building state) the consumers bind onto; created at placement (Block.newBuilding).', source=BLOCK),
        'block': f('Object', 'public class Separator extends Block{', 'The typed block definition; only a block carrying consumeItem/consumeLiquid rows binds consumers.'),
        'catalog': f('Object', 'protected Seq<Consume> consumeBuilder = new Seq<>();', "The content catalog the bound rows resolve their item and liquid fields against (the block's consumeBuilder).", source=BLOCK),
        'amounts': f('Dictionary', 'public void remove(Liquid liquid, float amount){', "The building's liquid module the liquid actors remove from (LiquidModule.remove).", source=LIQUID_MODULE),
    }
    n2115_bind_outputs = {
        'bound': f('bool', 'public ConsumeItems consumeItem(Item item, int amount){', 'Whether RuntimeConsumer actors were created on this call; false when the frame already carries them.', source=BLOCK),
        'consumers': f('Array', 'for(var cons : block.updateConsumers){', 'The RuntimeConsumer actors on the frame, one per bound consumeItem/consumeLiquid row.', source=BUILDING_COMP),
        'rows': f('Array', 'protected Seq<Consume> consumeBuilder = new Seq<>();', 'The bound consume rows (item stacks + liquid descriptors) the actors were built from.', source=BLOCK),
    }

    entries = [
        ('N2115', BIND_OWNER, 'source_adjacent_factory_bind_consumer_state', SEPARATOR, 'mindustry.world.blocks.production.Separator.SeparatorBuild', 'SeparatorBuild.updateTile()', n2115_bind_inputs, n2115_bind_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed adjacent factory family RuntimeConsumer binding.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed adjacent factory family RuntimeConsumer binding; the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption, so the placed adjacent factory consumes its liquid rows each tick and gates efficiency on its item rows.'))
        all_names.extend(names)

    # The live-loop tick driver (N2114) gains the consumption half of
    # updateTile (N2112 pattern: deepcopy the existing contract and
    # extend its rule and tests, keeping the N2114 source_slice the
    # driver itself was registered under; the game+seconds params are
    # unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed adjacent factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s adjacent factory counts everything as valid in updateConsumption, the tick gates efficiency on the family\'s own shouldConsume() body, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed adjacent factory consumes its liquid rows each tick and gates efficiency on its item rows.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2115'] = sorted(all_names)
    # One slice row: the live-loop tick driver is the primary owner; the
    # binder helper shares the slice (its symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2115', dict(status='done', java_source=SEPARATOR, java_class='mindustry.world.blocks.production.Separator.SeparatorBuild', java_method='SeparatorBuild.updateTile(); BuildingComp.updateConsumption(); ConsumeItems.efficiency(); ConsumeLiquid.update()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
