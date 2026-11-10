"""Register the GenericCrafter progress + craft() live-loop slice (N2117).

N2110 wired the factory family's frame keys live, N2111 threaded the
cheating flag through updateConsumption, N2112 bound one
RuntimeConsumer actor per consumeItem/consumeLiquid row, N2113 gave
the tick its shouldConsume() body -- but the tick never advanced
progress or crafted: a factory sat at progress 0 forever. N2117 is
the first C06 slice, the production half of
GenericCrafterBuild.updateTile() (GenericCrafter.java:235-266): with
efficiency above zero the progress climbs by getProgressIncrease
(craftTime) -- the GenericCrafter override scales it when the block
outputs liquids -- and a completed progress crafts (consume +
offload, GenericCrafter.java:301-315). The registry captures the
block's craftTime (the initializer's own assignment, else the class
default 80, GenericCrafter.java:40), so the tick reads the real
craft time per block: silicon smelter 40, graphite press 90.

Java: BuildingComp.getProgressIncrease (BuildingComp.java:1203-1205)
is `1f / baseTime * edelta()`, with edelta() = efficiency * delta()
(BuildingComp.java:1927-1929) and delta() = Time.delta * timeScale
(BuildingComp.java:1922-1924). GenericCrafterBuild overrides it
(GenericCrafter.java:266-285): ignoreLiquidFullness returns the base
increase, otherwise each output liquid scales by (liquidCapacity -
held) / (amount * edelta()), taking the minimum as scaling and the
maximum as max, and the base is multiplied by min(max, 1f) when
dumpExtraLiquid, else by scaling. GenericCrafterBuild.craft()
(GenericCrafter.java:301-315) calls consume() -- BuildingComp.consume
(BuildingComp.java:1911-1915) triggers every consumer, and only the
item rows remove anything, through ConsumeItems.trigger
(ConsumeItems.java:45-48, Math.round removal clamped at what the
module holds, ItemModule.java:258-259) -- then offloads each output
item once per amount (BuildingComp.offload, BuildingComp.java:1000-
1016: produced(item, 1), then the proximity buildings in cdump order,
keeping the item when no neighbor takes it) and wraps progress with
`progress %= 1f`. The continuous liquid output half of updateTile
(GenericCrafter.java:241-246, handleLiquid per tick), warmup /
totalProgress and dumpOutputs() are later slices.
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
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
ITEM_MODULE = 'core/src/mindustry/world/modules/ItemModule.java'
TICK_OWNER = 'SourceFactoryBuildState.source_factory_tick_buildings_state'
PROOF = '/root/C06FactoryCraftProof'
TESTS = ['test_factory_craft_registration', 'test_all_factory_craft_input_evidence_is_exact', 'test_tick_crafts_when_progress_completes', 'test_reference_graph_and_actual_c06_factory_craft_gate']
DEFERRED = [
    'The continuous liquid output half of GenericCrafterBuild.updateTile() (GenericCrafter.java:241-246, handleLiquid per tick) is a later slice; a liquid-output crafter crafts its item rows here while its liquid output is still unwired.',
    'warmup / totalProgress tracking (GenericCrafter.java:238, 259-260) is a later slice.',
    'dumpOutputs() (GenericCrafter.java:317+) is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class GenericCrafter extends Block{',
    'public class GenericCrafterBuild extends Building{',
    'public float craftTime = 80;',
    'progress += getProgressIncrease(craftTime);',
    'public float getProgressIncrease(float baseTime){',
    'if(ignoreLiquidFullness){',
    'float scaling = 1f, max = 1f;',
    'float value = (liquidCapacity - liquids.get(s.liquid)) / (s.amount * edelta());',
    'return super.getProgressIncrease(baseTime) * (dumpExtraLiquid ? Math.min(max, 1f) : scaling);',
    'if(progress >= 1f){',
    'craft();',
    'public void craft(){',
    'consume();',
    'for(int i = 0; i < output.amount; i++){',
    'offload(output.item);',
    'progress %= 1f;',
    'public void consume(){',
    'for(Consume cons : block.consumers){',
    'cons.trigger(self());',
    'public void offload(Item item){',
    'produced(item, 1);',
    'int dump = this.cdump;',
    'if(other.acceptItem(self(), item) && canDump(other, item)){',
    'other.handleItem(self(), item);',
    'handleItem(self(), item);',
    'return 1f / baseTime * edelta();',
    'public float delta(){',
    'return Time.delta * timeScale;',
    'public float edelta(){',
    'return efficiency * delta();',
    'public void trigger(Building build){',
    'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));',
    'public Floatf<Building> multiplier = b -> 1f;',
    'craftTime = 40f;',
    'craftTime = 90f;',
    'public void remove(Item item, int amount){',
    'amount = Math.min(amount, items[item.id]);',
    'public final Building newBuilding(){',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GENERIC_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2117_progress_inputs = {
        'craft_time': f('float', 'public float craftTime = 80;', 'The block craft time (GenericCrafter.craftTime, default 80): the divisor of the progress increase.'),
        'efficiency': f('float', 'return efficiency * delta();', 'The live efficiency; edelta is efficiency times delta.', source=BUILDING_COMP),
        'seconds': f('float', 'return Time.delta * timeScale;', 'The frame delta in seconds; the port edelta convention is seconds * TICK_RATE * timeScale * efficiency.', source=BUILDING_COMP),
        'time_scale': f('float', 'return Time.delta * timeScale;', 'The building time scale (BuildingComp.delta() = Time.delta * timeScale).', source=BUILDING_COMP),
    }
    n2117_progress_outputs = {
        'progress_increase': f('float', 'return 1f / baseTime * edelta();', 'The progress gained this tick: 1 / craftTime * edelta().', source=BUILDING_COMP),
        'edelta': f('float', 'return efficiency * delta();', 'The efficiency-scaled delta this tick (efficiency * Time.delta * timeScale).', source=BUILDING_COMP),
    }

    n2117_crafter_inputs = {
        'block': f('Object', 'public class GenericCrafter extends Block{', 'The typed block definition; its craftTime, outputLiquids, liquidCapacity and dump flags scale the increase.'),
        'liquids': f('Dictionary', 'float value = (liquidCapacity - liquids.get(s.liquid)) / (s.amount * edelta());', "The building's liquid module the output-liquid scaling reads."),
        'liquid_ids': f('Dictionary', 'for(var s : outputLiquids){', 'The catalog name-to-id map for the output liquids: the liquid module is id-indexed, so output liquid names resolve to ids through it.'),
        'efficiency': f('float', 'return super.getProgressIncrease(baseTime) * (dumpExtraLiquid ? Math.min(max, 1f) : scaling);', 'The live efficiency; the override scales the base increase, never the efficiency itself.'),
        'seconds': f('float', 'progress += getProgressIncrease(craftTime);', 'The frame delta in seconds; the progress increase is computed from it every tick.'),
        'time_scale': f('float', 'totalProgress += warmup * Time.delta;', 'The building time scale carried by the tick frame.'),
    }
    n2117_crafter_outputs = {
        'progress_increase': f('float', 'return super.getProgressIncrease(baseTime) * (dumpExtraLiquid ? Math.min(max, 1f) : scaling);', 'The scaled progress gained this tick: the base increase times min(max, 1f) when dumping excess, else scaling.'),
        'scaling': f('float', 'float scaling = 1f, max = 1f;', 'The liquid-output scaling factor applied to the base increase.'),
        'edelta': f('float', 'float value = (liquidCapacity - liquids.get(s.liquid)) / (s.amount * edelta());', 'The efficiency-scaled delta this tick.'),
    }

    n2117_consume_inputs = {
        'frame': f('Dictionary', 'public void consume(){', 'The factory frame (the port Building state) whose item module the triggers remove from.', source=BUILDING_COMP),
        'consumers': f('Array', 'for(Consume cons : block.consumers){', 'The bound RuntimeConsumer actors, one per consume row.', source=BUILDING_COMP),
        'rows': f('Array', 'cons.trigger(self());', 'The consume rows the actors were bound from; liquid rows are skipped, only item rows trigger.', source=BUILDING_COMP),
    }
    n2117_consume_outputs = {
        'triggered': f('int', 'cons.trigger(self());', 'How many item consumers triggered this craft.', source=BUILDING_COMP),
        'removed': f('Dictionary', 'build.items.remove(stack.item, Math.round(stack.amount * multiplier.get(build)));', 'What each item row removed: Math.round(amount * multiplier), clamped at what the module holds.', source=CONSUME_ITEMS),
    }

    n2117_offload_inputs = {
        'game': f('Object', 'public void offload(Item item){', 'The live game: the proximity ring and the conveyor queues are read from it.', source=BUILDING_COMP),
        'frame': f('Dictionary', 'produced(item, 1);', 'The factory frame; its cdump cursor advances and its items keep the produced item when no neighbor takes it.', source=BUILDING_COMP),
        'cell': f('Vector2i', 'if(other.acceptItem(self(), item) && canDump(other, item)){', "The building's cell; the proximity ring is computed from it.", source=BUILDING_COMP),
        'block': f('Object', 'public class GenericCrafter extends Block{', 'The typed block definition; its size shapes the proximity ring.'),
        'item': f('String', 'public void offload(Item item){', 'The produced item to offer to the proximity neighbors.', source=BUILDING_COMP),
    }
    n2117_offload_outputs = {
        'placed': f('bool', 'other.handleItem(self(), item);', 'Whether a neighbor took the produced item.', source=BUILDING_COMP),
        'destination': f('String', 'if(other.acceptItem(self(), item) && canDump(other, item)){', 'Where the item went: the accepting neighbor, or none when the frame keeps it.', source=BUILDING_COMP),
        'receiver_cell': f('Variant', 'other.handleItem(self(), item);', 'The cell of the neighbor that took the item, or null.', source=BUILDING_COMP),
        'cdump_after': f('int', 'int dump = this.cdump;', 'The frame cdump cursor after this offload.', source=BUILDING_COMP),
        'items_after': f('Dictionary', 'handleItem(self(), item);', "The frame items after the offload: the produced item added when no neighbor took it.", source=BUILDING_COMP),
    }

    n2117_craft_inputs = {
        'game': f('Object', 'public void craft(){', 'The live game the craft offloads into.'),
        'frame': f('Dictionary', 'consume();', 'The factory frame; its items are consumed and its progress wraps at 1.'),
        'cell': f('Vector2i', 'if(progress >= 1f){', "The building's cell; the craft offloads from it.", ),
        'block': f('Object', 'public class GenericCrafterBuild extends Building{', 'The typed block definition; its outputItems are what the craft offloads.'),
    }
    n2117_craft_outputs = {
        'crafted': f('bool', 'public void craft(){', 'Whether the craft ran: false only for a null block.'),
        'consumed': f('Dictionary', 'consume();', 'What the consume step removed per item row.'),
        'offloaded': f('Array', 'offload(output.item);', 'One offload result per output item per amount.'),
        'progress_after': f('float', 'progress %= 1f;', 'The frame progress after the craft wraps.'),
    }

    entries = [
        ('N2117', 'SourceFactoryBuildState.source_factory_progress_increase_state', 'source_factory_progress_increase_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.getProgressIncrease(float)', n2117_progress_inputs, n2117_progress_outputs, True, 'Dictionary'),
        ('N2117', 'SourceFactoryBuildState.source_factory_crafter_progress_increase_state', 'source_factory_crafter_progress_increase_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.getProgressIncrease(float)', n2117_crafter_inputs, n2117_crafter_outputs, True, 'Dictionary'),
        ('N2117', 'SourceFactoryBuildState.source_factory_consume_state', 'source_factory_consume_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.consume()', n2117_consume_inputs, n2117_consume_outputs, True, 'Dictionary'),
        ('N2117', 'SourceFactoryBuildState.source_factory_offload_state', 'source_factory_offload_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp', 'BuildingComp.offload(Item)', n2117_offload_inputs, n2117_offload_outputs, True, 'Dictionary'),
        ('N2117', 'SourceFactoryBuildState.source_factory_craft_state', 'source_factory_craft_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.craft()', n2117_craft_inputs, n2117_craft_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GenericCrafter progress + craft() live-loop slice.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GenericCrafter progress + craft() live-loop slice.'))
        all_names.extend(names)

    # The live-loop tick driver (N2110) gains the production half
    # (N2113 pattern: deepcopy the existing contract and extend its
    # rule and tests, keeping the N2110 source_slice the driver
    # itself was registered under; the game+seconds params are
    # unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows, with shouldConsume() read live from the output space every tick so a factory with a full output ticks at efficiency 0, and with efficiency above zero the progress climbs by getProgressIncrease(craftTime) and a completed progress crafts (consume + offload).'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2117'] = sorted(all_names)
    # One slice row: the tick driver is the primary owner (the
    # production half is wired into it); the five new functions are
    # registered under it.
    source_symbols.upsert_source_slice(GODOT, 'N2117', dict(status='done', java_source=GENERIC_CRAFTER, java_class='mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', java_method='GenericCrafterBuild.craft(); GenericCrafterBuild.getProgressIncrease(float); BuildingComp.consume(); BuildingComp.offload(Item)', godot_owner=TICK_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    # The emitter change captures craftTime, so the canonical
    # content_registry.json was regenerated first; its blocks shard
    # mirror must be rebuilt with it (the N2114 lesson).
    source_ssot.write_registered_json(GODOT, 'content_registry_blocks', source_ssot.build_extension_shard(GODOT, 'content_registry_blocks'))


if __name__ == '__main__':
    main()
