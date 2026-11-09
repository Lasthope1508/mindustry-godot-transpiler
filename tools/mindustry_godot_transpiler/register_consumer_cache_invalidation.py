"""Register the consumer cache invalidation on Block reinit/reload (N2100).

N2100 is the cache-invalidation half of Block.reinitializeConsumers()
(Block.java:1481-1497): it rebuilds consumers, consPower, the optional /
non-optional / update consumer arrays and itemFilter / liquidFilter from
consumeBuilder, then re-applies each consumer. DataPatcher calls it when
a block's "consumes" JSON is re-read on reload (DataPatcher.java:604, 615),
and updateConsumption() reads the block's consumer arrays fresh every tick
(BuildingComp.java:1969, 1980, 2000) -- Java keeps no cached actors. The
port does cache: the bound liquid-consumer rows on the block meta
(source_block_liquid_consumers), the apply result derived from those rows
(source_block_liquid_apply; ConsumeLiquid.apply sets
block.liquidFilter[liquid.id] = true, ConsumeLiquid.java:26-28, after
reinit rebuilds the filter at Block.java:1491), and the RuntimeConsumer
actors in the building frame ("consumers", built once by the drill tick).
All three go stale on reinit, so source_invalidate_consumer_cache_state
drops them; the next tick rebinds from the block's current consumeBuilder
and rebuilds the actors through the tick's existing is_empty() path.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/ConsumerCacheInvalidationProof'
TESTS = ['test_consumer_cache_invalidation_binding_registration', 'test_all_consumer_cache_invalidation_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_consumer_cache_invalidation']
DEFERRED = [
    'Wiring other buildings (turrets, factories) to the live cheating value is a later slice; this slice wires the drill tick cache only.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

REINIT_METHOD = '    public void reinitializeConsumers(){'
CONSUMERS_REBUILD = '        consumers = consumeBuilder.toArray(Consume.class);'
CONS_POWER = '        consPower = (ConsumePower)Structs.find(consumers, c -> c instanceof ConsumePower);'
ITEM_FILTER_RESET = '        itemFilter = new boolean[content.items().size];'
LIQUID_FILTER_RESET = '        liquidFilter = new boolean[content.liquids().size];'
APPLY_LOOP = '        for(Consume cons : consumers){'
APPLY_CALL = '            cons.apply(this);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=BLOCK, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2100_inputs = {
        'block': f('Variant', CONSUMERS_REBUILD, 'The registry block whose consumer arrays reinitializeConsumers() rebuilds from consumeBuilder; its bound-rows and apply caches are dropped.'),
        'frame': f('Variant', CONSUMERS_REBUILD, 'The building frame holding the cached RuntimeConsumer actors; its consumers list is cleared so the next tick rebuilds from the rebound rows.'),
    }
    n2100_outputs = {
        'bound_rows_invalidated': f('bool', CONSUMERS_REBUILD, 'Whether the block held a bound-rows cache (source_block_liquid_consumers) that was dropped.'),
        'apply_invalidated': f('bool', LIQUID_FILTER_RESET, 'Whether the block held an apply cache (source_block_liquid_apply) that was dropped; reinit rebuilds liquidFilter fresh before ConsumeLiquid.apply sets it.'),
        'frame_consumers_before': f('int', CONSUMERS_REBUILD, 'How many cached RuntimeConsumer actors the frame held before invalidation.'),
        'frame_consumers_invalidated': f('bool', CONSUMERS_REBUILD, 'Whether the frame held cached actors that were cleared.'),
    }

    entries = [
        ('N2100', 'SourceConsumeLiquidState.source_invalidate_consumer_cache_state', 'source_invalidate_consumer_cache_state', BLOCK, 'mindustry.world.Block', 'reinitializeConsumers()', n2100_inputs, n2100_outputs, [REINIT_METHOD, CONSUMERS_REBUILD, CONS_POWER, ITEM_FILTER_RESET, LIQUID_FILTER_RESET, APPLY_LOOP, APPLY_CALL], True, 'Dictionary'),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed consumer cache invalidation on Block reinit/reload.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed consumer cache invalidation on Block reinit/reload; the next tick rebinds from the current consumeBuilder.'))
        by_slice[sid] = names
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
