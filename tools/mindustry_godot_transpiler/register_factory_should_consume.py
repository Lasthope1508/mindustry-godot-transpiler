"""Register the GenericCrafterBuild.shouldConsume() body (N2113).

N2110 wired the factory family's frame keys live, N2111 threaded the
cheating flag through the updateConsumption adapter, and N2112 bound
one RuntimeConsumer actor per consumeItem/consumeLiquid row -- but the
tick still passed the frame's enabled flag as should_consume, so a
factory kept crafting with a full output. N2113 implements
GenericCrafterBuild.shouldConsume() (GenericCrafter.java:203-231):
an output item blocks when the held stack plus one output would
exceed itemCapacity, an output liquid blocks when the held amount
reaches liquidCapacity - 0.001f (unless ignoreLiquidFullness skips
the check, or dumpExtraLiquid lets the extra spill), and when every
output liquid is full the block cannot reproduce; otherwise the
build consumes when enabled. The registry captures the block's
outputItems/outputLiquids (the singular outputItem/outputLiquid
written to the plural arrays by GenericCrafter.init(),
GenericCrafter.java:120-124) and its liquidCapacity (the
initializer's own assignment, else Block.init()'s round(10 *
consumeAmount) default, Block.java:1407-1418). The tick driver now
calls shouldConsume every tick, so a placed factory's efficiency
follows its output space live.

Java: GenericCrafterBuild.shouldConsume() (GenericCrafter.java:203)
reads outputItems/outputLiquids against itemCapacity (Block.java:75,
default 10) and liquidCapacity (Block.java:77, -1f until init;
Block.java:1407-1418 computes round(10f * consumeAmount), where
consumeAmount is 1f, or the largest consumeLiquid amount * 60f).
dumpExtraLiquid defaults true and ignoreLiquidFullness false
(GenericCrafter.java:37-38). The liquid module is an id-indexed
array (LiquidModule.java:23 `private float[] liquids = new
float[content.liquids().size];`), read through LiquidModule.get
(LiquidModule.java:102), so the port resolves output liquid names
to ids through the content catalog's liquid_id_by_name.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
GENERIC_CRAFTER = 'core/src/mindustry/world/blocks/production/GenericCrafter.java'
BLOCK = 'core/src/mindustry/world/Block.java'
LIQUID_MODULE = 'core/src/mindustry/world/modules/LiquidModule.java'
SHOULD_CONSUME_OWNER = 'SourceFactoryBuildState.source_factory_should_consume_state'
TICK_OWNER = 'SourceFactoryBuildState.source_factory_tick_buildings_state'
PROOF = '/root/FactoryShouldConsumeProof'
TESTS = ['test_factory_should_consume_registration', 'test_all_factory_should_consume_input_evidence_is_exact', 'test_should_consume_reads_output_space', 'test_reference_graph_and_actual_factory_should_consume']
DEFERRED = [
    'The craft/progress slice owns ConsumeItems.trigger at craft() (GenericCrafter.java:301-303); shouldConsume only gates the start of a craft.',
    'Wiring the remaining factory-adjacent families (Separator, Incinerator, WallCrafter, SingleBlockProducer -- Block/BlockProducer builds, not GenericCrafterBuild) to the live cheating value is a later slice.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public class GenericCrafter extends Block{',
    'public class GenericCrafterBuild extends Building{',
    'public boolean shouldConsume(){',
    'if(items.get(output.item) + output.amount > itemCapacity){',
    'if(outputLiquids != null && !ignoreLiquidFullness){',
    'boolean allFull = true;',
    'if(liquids.get(output.liquid) >= liquidCapacity - 0.001f){',
    'if(!dumpExtraLiquid){',
    'if(allFull){',
    'return enabled;',
    'if(outputItems == null && outputItem != null){',
    'outputItems = new ItemStack[]{outputItem};',
    'if(outputLiquids == null && outputLiquid != null){',
    'outputLiquids = new LiquidStack[]{outputLiquid};',
    'public float liquidCapacity = -1f;',
    'liquidCapacity = Mathf.round(10f * consumeAmount);',
    'public int itemCapacity = 10;',
    'public boolean dumpExtraLiquid = true;',
    'public boolean ignoreLiquidFullness = false;',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=GENERIC_CRAFTER, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2113_inputs = {
        'frame': f('Dictionary', 'public final Building newBuilding(){', 'The factory frame (the port Building state) whose held items and enabled flag shouldConsume reads; created at placement (Block.newBuilding).', source=BLOCK),
        'block': f('Object', 'public class GenericCrafter extends Block{', 'The typed block definition; its outputItems/outputLiquids and capacities are what shouldConsume checks.'),
        'liquids': f('Dictionary', 'public float get(Liquid liquid){', "The building's liquid module the output-liquid check reads (LiquidModule.get).", source=LIQUID_MODULE),
        'liquid_ids': f('Dictionary', 'private float[] liquids = new float[content.liquids().size];', 'The catalog name-to-id map for the output liquids: the liquid module is an id-indexed array, so output liquid names resolve to ids through it.', source=LIQUID_MODULE),
    }
    n2113_outputs = {
        'should_consume': f('bool', 'public boolean shouldConsume(){', 'Whether the build may consume this tick: its outputs have room and it is enabled.'),
        'item_blocked': f('bool', 'if(items.get(output.item) + output.amount > itemCapacity){', 'Whether an output item is blocked: the held stack plus one output would exceed itemCapacity.'),
        'liquid_blocked': f('bool', 'if(liquids.get(output.liquid) >= liquidCapacity - 0.001f){', 'Whether an output liquid blocks: a held output liquid reaches liquidCapacity - 0.001f without dumpExtraLiquid, or every output liquid is full.'),
        'all_liquids_full': f('bool', 'boolean allFull = true;', 'Whether every output liquid is at liquidCapacity - 0.001f: with no space left for any liquid, the block cannot reproduce.'),
    }

    entries = [
        ('N2113', SHOULD_CONSUME_OWNER, 'source_factory_should_consume_state', GENERIC_CRAFTER, 'mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', 'GenericCrafterBuild.shouldConsume()', n2113_inputs, n2113_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed GenericCrafterBuild.shouldConsume() output-space checks.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed GenericCrafterBuild.shouldConsume(): an output item blocks when the held stack plus one output would exceed itemCapacity, an output liquid blocks when held at liquidCapacity - 0.001f without dumpExtraLiquid (or when every output liquid is full), unless ignoreLiquidFullness skips the liquid check; otherwise the build consumes when enabled.'))
        all_names.extend(names)

    # The live-loop tick driver (N2110) gains the shouldConsume body
    # (N2106 pattern: deepcopy the existing contract and extend its
    # rule and tests, keeping the N2110 source_slice the driver
    # itself was registered under; the game+seconds params are
    # unchanged, so no new tick symbols).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    tick_contract = copy.deepcopy(contracts[TICK_OWNER])
    tick_contract['tests'] = sorted(set(tick_contract['tests']) | set(TESTS))
    tick_contract['rule'] = 'Source-backed factory family live-loop tick and placement frame binding; the frame is bound when the block is placed (Block.newBuilding) and its keys are refreshed from the live rules every simulate_factory tick, so a cheating team\'s factory counts everything as valid in updateConsumption, and the tick binds one RuntimeConsumer per consumeItem/consumeLiquid row and runs the bound actors through updateConsumption so the placed factory consumes its liquid rows each tick and gates efficiency on its item rows, with shouldConsume() read live from the output space every tick so a factory with a full output ticks at efficiency 0.'
    source_symbols.upsert_source_api_contract(GODOT, TICK_OWNER, tick_contract)

    by_slice['N2113'] = sorted(all_names)
    # One slice row: the shouldConsume function is the primary owner.
    source_symbols.upsert_source_slice(GODOT, 'N2113', dict(status='done', java_source=GENERIC_CRAFTER, java_class='mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild', java_method='GenericCrafterBuild.shouldConsume()', godot_owner=SHOULD_CONSUME_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
