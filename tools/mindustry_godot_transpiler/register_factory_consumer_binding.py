"""Register the GenericCrafter family RuntimeConsumer binding (N2112).

N2110 wired the factory family's frame keys live and N2111 threaded
the cheating flag through the updateConsumption adapter, but the
machinery still ran over an empty actor list: a placed silicon-smelter
kept its coal and sand forever and a cryofluid-mixer kept its water.
N2112 binds one RuntimeConsumer actor per consumeItem/consumeLiquid
row (the drill model, N2097/N2100) into the live-loop tick and runs
them through BuildingComp.updateConsumption's first and second passes,
so the placed factory actually consumes: the liquid rows drain per
tick and the item rows gate efficiency on the stacks held.

Java: Block.consumeItems registers one ConsumeItems per call
(Block.java:1175-1177) and consumeLiquid one ConsumeLiquid per call
(Block.java:1127-1131); the registry captures each call's stacks into
properties["consumeItem"]/["consumeLiquid"] (N2095). ConsumeItems
efficiency is 1 when the building is burning a trigger consumer or
its item module holds the stack amount times the multiplier
(ConsumeItems.java:52), and its trigger removes each stack once per
craft (ConsumeItems.java:46, called from GenericCrafter.craft() via
consume(), GenericCrafter.java:301-303); Consume.update itself is
empty (Consume.java:52), so the per-tick second pass removes nothing
for items -- the craft slice owns the trigger. ConsumeLiquid.update
removes amount * edelta * multiplier every tick
(ConsumeLiquid.java:38-40). updateConsumption
(BuildingComp.java:1943-2004) runs the first pass (minimum efficiency
of the non-optional consumers) and the second pass (update every
update consumer when update, i.e. shouldConsume() &&
productionValid(), and efficiency > 0). The tick passes the frame's
enabled flag as should_consume until the shouldConsume() body slice
(GenericCrafter.java:203, output-space checks) lands; the power
consumer stays the power graph's domain (N2080/N2107).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME_ITEMS = 'core/src/mindustry/world/consumers/ConsumeItems.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
BLOCK = 'core/src/mindustry/world/Block.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
BIND_OWNER = 'SourceFactoryBuildState.source_bind_consumer_state'
ITEM_BIND_OWNER = 'SourceConsumeItemsState.source_bind_item_consumers_state'
ITEM_ACTOR_OWNER = 'SourceConsumeItemsState.source_runtime_consumer_state'
TICK_OWNER = 'SourceFactoryBuildState.source_factory_tick_buildings_state'
PROOF = '/root/FactoryConsumerBindingProof'
TESTS = ['test_factory_consumer_binding_registration', 'test_all_factory_consumer_binding_input_evidence_is_exact', 'test_tick_binds_runtime_consumers_for_factory', 'test_reference_graph_and_actual_factory_consumer_binding']
DEFERRED = [
    'The GenericCrafterBuild.shouldConsume() body (GenericCrafter.java:203, output-space checks) is a later slice; the tick passes the frame enabled flag as should_consume until then.',
    'Item stacks leave only at craft() via ConsumeItems.trigger (GenericCrafter.java:301-303); the per-tick second pass removes nothing for items, so the craft/progress slice owns the trigger.',
    'Wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer -- Block/BlockProducer builds, not GenericCrafterBuild) to the live cheating value is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class GenericCrafter extends Block{',
    'public class GenericCrafterBuild extends Building{',
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
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GENERIC_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2112_bind_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The factory frame (the port Building state) the consumers bind onto; created at placement (Block.newBuilding).', source=BLOCK),
        'block': f('Object', 'public class GenericCrafter extends Block{', 'The typed block definition; only a block carrying consumeItem/consumeLiquid rows binds consumers.'),
        'catalog': f('Object', 'protected Seq<Consume> consumeBuilder = new Seq<>();', "The content catalog the bound rows resolve their item and liquid fields against (the block's consumeBuilder).", source=BLOCK),
        'amounts': f('Dictionary', 'public void remove(Liquid liquid, float amount){', "The building's liquid module the liquid actors remove from (LiquidModule.remove).", source=LIQUID_MODULE),
    }
    n2112_bind_outputs = {
        'bound': f('bool', 'public ConsumeItems consumeItem(Item item, int amount){', 'Whether RuntimeConsumer actors were created on this call; false when the frame already carries them.', source=BLOCK),
        'consumers': f('Array', 'for(var cons : block.updateConsumers){', 'The RuntimeConsumer actors on the frame, one per bound consumeItem/consumeLiquid row.', source=BUILDING_COMP),
        'rows': f('Array', 'protected Seq<Consume> consumeBuilder = new Seq<>();', 'The bound consume rows (item stacks + liquid descriptors) the actors were built from.', source=BLOCK),
    }
    n2112_item_bind_inputs = {
        'block': f('Object', 'public ConsumeItems consumeItems(ItemStack... items){', 'The typed block definition; its consumeItem rows are the stacks to bind.', source=BLOCK),
        'content_catalog': f('Object', 'public ConsumeItems consumeItems(ItemStack... items){', 'The content catalog the bound rows resolve their item fields against (content.items()).', source=BLOCK),
    }
    n2112_item_bind_outputs = {
        'consumers': f('Array', 'return consume(new ConsumeItems(items));', 'The bound consumeItem rows (one stack dict per row, with the Consume ignore default).', source=BLOCK),
    }
    n2112_item_actor_inputs = {
        'definition': f('Dictionary', 'public final ItemStack[] items;', 'The consumeItem stack the actor gates and (at craft) removes: one item name and amount.', source=CONSUME_ITEMS),
        'items': f('Dictionary', 'public boolean has(Item item, int amount){', "The building's item module the actor reads (ItemModule.has).", source=ITEM_MODULE),
        'cost_multiplier': f('Callable', 'public Floatf<Building> multiplier = b -> 1f;', 'The per-consumer cost multiplier callback (Consume.multiplier, default 1f).', source=CONSUME),
    }
    n2112_item_actor_outputs = {
        'consumer': f('Dictionary', 'return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;', 'The RuntimeConsumer actor: efficiency 1 when the stack is held (or a trigger is burning), else 0; update is the empty Consume default.', source=CONSUME_ITEMS),
    }

    entries = [
        ('N2112', BIND_OWNER, 'source_factory_bind_consumer_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.updateTile()', n2112_bind_inputs, n2112_bind_outputs, True, 'Dictionary'),
        ('N2112', ITEM_BIND_OWNER, 'source_bind_item_consumers_state', BLOCK, 'mindustry.world.Block', 'Block.consumeItems()', n2112_item_bind_inputs, n2112_item_bind_outputs, True, 'Dictionary'),
        ('N2112', ITEM_ACTOR_OWNER, 'source_item_runtime_consumer', CONSUME_ITEMS, 'mindustry.world.consumers.ConsumeItems', 'ConsumeItems.efficiency(Building build)', n2112_item_actor_inputs, n2112_item_actor_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GenericCrafter family RuntimeConsumer binding.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GenericCrafter family RuntimeConsumer binding; the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption, so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows.'))
        all_names.extend(names)

    # The live-loop tick driver (N2110) gains the consumption half of
    # updateTile (N2106 pattern: deepcopy the existing contract and
    # extend its rule and tests, keeping the N2110 source_slice the
    # driver itself was registered under; the game+seconds params are
    # unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2112'] = sorted(all_names)
    # One slice row: the live-loop tick driver is the primary owner; the
    # bind and item-actor helpers share the slice (their symbols carry
    # their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2112', dict(status='done', java_source=GENERIC_CRAFTER, java_class='mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', java_method='GenericCrafterBuild.updateTile(); BuildingComp.updateConsumption(); ConsumeItems.efficiency()', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
