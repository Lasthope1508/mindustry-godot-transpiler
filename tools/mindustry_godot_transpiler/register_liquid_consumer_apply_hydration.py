"""Register partial-input liquid apply and shared Block capability/filter effects."""
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import alias

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BASE = 'core/src/mindustry/world/consumers/ConsumeLiquidBase.java'
LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/Main.LiquidConsumerApplyHydrationProof'
TESTS = ['test_partial_apply_contracts_are_registered_without_invented_before_flag', 'test_placement_applies_consumers_before_effective_capability_allocation', 'test_live_partial_apply_filter_cache_and_real_placement']


def main():
    entries = [
        ('N2004', 'SourceConsumeLiquidBaseState.source_apply_capability_state', 'source_liquid_apply_capability', BASE, 'mindustry.world.consumers.ConsumeLiquidBase', 'apply(Block block)', {}, {
            'block_has_liquids_after': alias('bool', 'source_consume_liquid_base_apply_result.block_has_liquids_after'),
        }, ['block.hasLiquids = true;']),
        ('N2005', 'SourceConsumeLiquidState.source_apply_filter_state', 'source_liquid_apply_filter', LIQUID, 'mindustry.world.consumers.ConsumeLiquid', 'apply(Block block)', {
            'liquid_filter_before': alias('Array', 'source_consume_liquid_apply_input.liquid_filter_before'),
            'liquid_id': alias('int', 'source_consume_liquid_apply_input.liquid_id'),
        }, {'liquid_filter_after': alias('Array', 'source_consume_liquid_apply_result.liquid_filter_after')}, ['block.liquidFilter[liquid.id] = true;']),
        ('N2006', 'SourceConsumeLiquidState.source_apply_liquid_consumers_state', 'source_liquid_consumer_apply', BLOCK, 'mindustry.world.Block', 'init(); reinitializeConsumers()', {
            'block': alias('Object', 'source_bind_liquid_consumers_input.block'),
            'content_catalog': alias('Object', 'source_liquid_catalog_input.content_catalog'),
        }, {
            'has_liquids': alias('bool', 'source_liquid_apply_capability_result.block_has_liquids_after'),
            'liquid_filter': alias('Array', 'source_liquid_apply_filter_result.liquid_filter_after'),
        }, ['liquidFilter = new boolean[content.liquids().size];', 'cons.apply(this);']),
    ]
    symbols = {}
    for slice_id, owner, prefix, source, java_class, method, inputs, outputs, expressions in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            schema_name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                name = prefix.removeprefix('source_') + '.' + field
                names.append(name)
                symbols[name] = dict(status='source-backed', godot_owner=owner, godot_symbol=schema_name + '.' + field, java_source=source, java_method=method, java_expr=expressions[-1], rule='Reuse canonical apply fields. Missing constructor capability remains unknown until the unconditional source assignment is applied. Filter is the supported direct single-liquid subset, not a complete mixed-consumer acceptance policy.', tests=TESTS, runtime_proof=PROOF)
            if keys:
                source_symbols.upsert_source_state_schema(GODOT, schema_name, dict(status='active', owner=owner, keys=keys, runtime_proof=PROOF))
        if slice_id == 'N2006':
            name = 'block_liquid_apply.metadata_key'
            names.append(name)
            symbols[name] = dict(status='source-backed', godot_owner=owner, godot_symbol='SourceConsumeLiquidState.SOURCE_BLOCK_LIQUID_APPLY_META_KEY', java_source=BLOCK, java_method=method, java_expr='cons.apply(this);', rule='Block-owned applied capability and supported single-liquid filter subset, shared by buildings. Immutable source properties and per-building liquid amount frames retain their original owners. Cache assumes immutable catalog; full reinit/reload invalidation remains deferred.', tests=TESTS, runtime_proof=PROOF)
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=source, source_method=method, params=[dict(name=key, type=meta['type'], schema=prefix + '_input.' + key) for key, meta in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Partial-input projection of unconditional source assignments; no invented before bool. Block apply requires nonempty resolved direct ConsumeLiquid descriptors and caches supported filter effects only. Not full Block.init or a runtime reinitialization API.'))
        generated = {'generated_owner': java_class.rsplit('.', 1)[-1] + '.java_method_apply_0'} if slice_id in ('N2004', 'N2005') else {}
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=source, java_class=java_class, java_method=method, godot_owner=owner, exact_exprs=expressions, source_symbols=names, tests=TESTS, runtime_proof=PROOF, **generated, deferred_exprs=['Full mixed/inherited consumers, runtime mutations/reinitializeConsumers cache invalidation and content reload remain unresolved.', 'Concrete consumer callbacks, multipliers, liquid capacity and automatic Drill ticks remain deferred.']))
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ['consumer_slices', 'consumer_api_contracts', 'block_slices', 'block_api_contracts']:
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
