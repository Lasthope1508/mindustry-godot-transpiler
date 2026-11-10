"""Register the C05 gate (N2116): lifecycle replacement, storage
independence, consumer classification.

The C05 consumer work (N2094-N2115) bound one RuntimeConsumer actor
per consumeItem/consumeLiquid row and ran the actors through
BuildingComp.updateConsumption's first and second passes, but the
live loop never re-initialized them: when the same sprite was
re-recorded with a different block, initialize_sprite overwrote the
block-id meta while the family frame (with the old block's actors)
stayed put, so the tick kept running the old block's actors against
the new block's rows -- and indexed past the end of the actor list
when the new block had more rows. N2116 adds the reinitialize path
to both production families' tick drivers: a frame stamped for
another block drops its old actors (N2100's invalidate), clears its
item and liquid stores for the fresh Building's own empty modules,
and rebinds from the new block's consumeBuilder.

Java: Tile.changeBuild (Tile.java:636-657) removes the old Building
(`build.remove()`) and inits a brand-new one
(`entityprov.get().init(...)`, Block.newBuilding(),
Block.java:1002), so a replaced building gets fresh consumers from
Block.reinitializeConsumers() (Block.java:1481-1497: the
consumeBuilder is re-read, the optional / non-optional / update
arrays are rebuilt, and each consumer is applied again); init
creates a fresh ItemModule/LiquidModule per Building
(BuildingComp.java:145-146). updateConsumption
(BuildingComp.java:1943-2004) runs the first pass (minimum
efficiency of the non-optional consumers) and the second pass
(update every update consumer when update, i.e. shouldConsume() &&
productionValid(), and efficiency > 0). Consume carries the
classification itself (Consume.java:12 optional, :16 update
defaults true, :43 ignore). The vanilla rows: the silicon smelter
consumes coal 1 + sand 2 (Blocks.java:1081), the graphite press
coal 2 (Blocks.java:1050), the separator slag 4/60 per tick
(Blocks.java:1244); the thorium reactor's cryofluid row is
update:false at 0.04 (Blocks.java:2629, N2094).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TILE = 'core/src/mindustry/world/Tile.java'
BLOCK = 'core/src/mindustry/world/Block.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
CONSUME_ITEMS = 'core/src/mindustry/world/consumers/ConsumeItems.java'
CONSUME_LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
SEPARATOR = 'core/src/mindustry/world/blocks/production/Separator.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
FACTORY_REINIT_OWNER = 'SourceFactoryBuildState.source_factory_reinitialize_consumers_state'
ADJACENT_REINIT_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_reinitialize_consumers_state'
FACTORY_TICK_OWNER = 'SourceFactoryBuildState.source_factory_tick_buildings_state'
ADJACENT_TICK_OWNER = 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state'
PROOF = '/root/C05GateProof'
TESTS = ['test_c05_gate_registration', 'test_all_c05_gate_input_evidence_is_exact', 'test_tick_reinitializes_consumers_on_block_replacement', 'test_reference_graph_and_actual_c05_gate']
DEFERRED = [
    'UnitFactory-family RuntimeConsumer binding is still open: unit factories tick with the live cheating flag (N2109) but bind no actors, so a non-cheating unit factory pays nothing per tick.',
    'The drill and ContinuousLiquidTurret binders have the same stale-frame shape on sprite reuse (their bind is once-only); their reinitialize path is a later slice, one per driver.',
    'ConsumeItems.trigger at craft() (GenericCrafter.java:301-303) is still open: item stacks leave only at craft, so a producing factory holds its inputs until the craft slice lands.',
    'C06 factory->core->defense loop is next after C05 closes. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06-C12 still open. Editor parse, deterministic replay and native MCP proof still open.',
]

EXACT_EXPRS = [
    'protected void changeBuild(Team team, Prov<Building> entityprov, int rotation){',
    'build.remove();',
    'build = entityprov.get().init(this, team, block.update && !state.isEditor(), rotation);',
    'public void reinitializeConsumers(){',
    'consumers = consumeBuilder.toArray(Consume.class);',
    'optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);',
    'nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);',
    'updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);',
    'public final Building newBuilding(){',
    'public void updateConsumption(){',
    'if(!block.hasConsumers || cheating()){',
    'for(var cons : block.updateConsumers){',
    'cons.update(self());',
    'public boolean optional;',
    'public boolean update = true;',
    'public boolean ignore(){',
    'public void update(Building build){}',
    'public ConsumeItems consumeItems(ItemStack... items){',
    'public ConsumeItems consumeItem(Item item, int amount){',
    'return consume(new ConsumeItems(items));',
    'return build.consumeTriggerValid() || build.items.has(items, multiplier.get(build)) ? 1f : 0f;',
    'build.liquids.remove(liquid, amount * build.edelta() * multiplier.get(build));',
    'protected Seq<Consume> consumeBuilder = new Seq<>();',
    'if(block.hasItems) items = new ItemModule();',
    'if(block.hasLiquids) liquids = new LiquidModule();',
    'public boolean has(Item item, int amount){',
    'public void remove(Liquid liquid, float amount){',
    'consumeItems(with(Items.coal, 1, Items.sand, 2));',
    'consumeItem(Items.coal, 2);',
    'consumeLiquid(Liquids.slag, 4f / 60f);',
    'public class GenericCrafter extends Block{',
    'public class Separator extends Block{',
    'public void updateTile(){',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=TILE, **extra):
        return backed(typ, source, expr, rule, **extra)

    reinit_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The family frame (the port Building state) whose actors are reinitialized; created at placement (Block.newBuilding).', source=BLOCK),
        'block': f('Object', 'protected void changeBuild(Team team, Prov<Building> entityprov, int rotation){', 'The block the frame is (re)bound to; a frame stamped for another block is reinitialized from this block\'s consumeBuilder.'),
        'catalog': f('Object', 'protected Seq<Consume> consumeBuilder = new Seq<>();', "The content catalog the rebound rows resolve their item and liquid fields against (the block's consumeBuilder).", source=BLOCK),
        'amounts': f('Dictionary', 'public void remove(Liquid liquid, float amount){', "The building's liquid module the liquid actors remove from (LiquidModule.remove); cleared on reinitialization, like a fresh Building's empty module.", source=LIQUID_MODULE),
    }
    reinit_outputs = {
        'reinitialized': f('bool', 'public void reinitializeConsumers(){', 'Whether the frame was stamped for another block and its old actors were dropped and rebound; false for a fresh frame or a frame already on this block.', source=BLOCK),
        'bound': f('bool', 'public ConsumeItems consumeItem(Item item, int amount){', 'Whether RuntimeConsumer actors were created on this call; false when the frame already carries them for this block.', source=BLOCK),
        'consumers': f('Array', 'for(var cons : block.updateConsumers){', 'The RuntimeConsumer actors on the frame after the call, one per bound consumeItem/consumeLiquid row.', source=BUILDING_COMP),
        'rows': f('Array', 'protected Seq<Consume> consumeBuilder = new Seq<>();', 'The bound consume rows (item stacks + liquid descriptors) the actors were built from.', source=BLOCK),
    }

    entries = [
        ('N2116', FACTORY_REINIT_OWNER, 'source_factory_reinitialize_consumers_state', TILE, 'mindustry.world.Tile', 'Tile.changeBuild(); Block.reinitializeConsumers(); BuildingComp.updateConsumption()', reinit_inputs, reinit_outputs, True, 'Dictionary'),
        ('N2116', ADJACENT_REINIT_OWNER, 'source_adjacent_factory_reinitialize_consumers_state', TILE, 'mindustry.world.Tile', 'Tile.changeBuild(); Block.reinitializeConsumers(); BuildingComp.updateConsumption()', reinit_inputs, reinit_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        inputs = copy.deepcopy(inputs)
        outputs = copy.deepcopy(outputs)
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed C05 gate lifecycle replacement: the tick reinitializes a replaced building\'s consumers from the new block\'s consumeBuilder.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed C05 gate lifecycle replacement; a frame stamped for another block drops its old RuntimeConsumer actors, clears its item and liquid stores, and rebinds from the new block\'s consumeBuilder, so a replaced building consumes like a fresh Building.'))
        all_names.extend(names)

    # The live-loop tick drivers (N2110 factory, N2114 adjacent) gain
    # the reinitialize path (deepcopy the existing contracts and
    # extend their rules and tests, keeping the source_slice each
    # driver was registered under; the game+seconds params are
    # unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    for tick_owner, rule in [
        (FACTORY_TICK_OWNER, 'Source-backed GenericCrafter family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, the tick gates efficiency on the family\'s own shouldConsume() body, the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows, and a sprite re-recorded with a different block reinitializes its consumers from the new block\'s consumeBuilder.'),
        (ADJACENT_TICK_OWNER, 'Source-backed adjacent factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s adjacent factory counts everything as valid in updateConsumption, the tick gates efficiency on the family\'s own shouldConsume() body, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed adjacent factory consumes its liquid rows each tick and gates efficiency on its item rows, and a sprite re-recorded with a different block reinitializes its consumers from the new block\'s consumeBuilder.'),
    ]:
        tick_contract = copy.deepcopy(contracts[tick_owner])
        tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
        tick_contract['rule'] = rule
        source_symbols.upsert_source_api_contract(GODOT, tick_owner, tick_contract)

    by_slice['N2116'] = sorted(all_names)
    # One slice row: the factory tick driver is the primary owner; the
    # adjacent reinitialize helper shares the slice (its symbols carry
    # their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2116', dict(status='done', java_source=TILE, java_class='mindustry.world.Tile', java_method='Tile.changeBuild(); Block.reinitializeConsumers(); BuildingComp.updateConsumption(); ConsumeItems.efficiency(); ConsumeLiquid.update()', godot_owner=FACTORY_TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
