"""Register source single-liquid descriptors and typed, shared Block hydration."""
from pathlib import Path

from mindustry_port import source_ssot, source_symbols

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
BLOCK = 'core/src/mindustry/world/Block.java'
LIQUID = 'core/src/mindustry/world/consumers/ConsumeLiquid.java'
CONSUME = 'core/src/mindustry/world/consumers/Consume.java'
PROOF = '/root/Main.LiquidConsumerHydrationProof'
DEFINITIONS = 'SourceConsumeLiquidState.source_liquid_consumer_definitions_state'
BIND = 'SourceConsumeLiquidState.source_bind_liquid_consumers_state'
TESTS = ['test_source_calls_preserve_order_flags_zero_and_comments', 'test_real_source_registry_exports_definitions_without_block_allowlist', 'test_same_slice_contracts_and_placement_binding_are_registered', 'test_live_block_shared_consumers_and_optional_efficiency_runtime']


def backed(typ, source, expr, rule, **extra):
    return dict(type=typ, status='source-backed', java_source=source, java_expr=expr, rule=rule, **extra)


def alias(typ, target, **extra):
    return dict(type=typ, status='alias', alias_of=target, **extra)


def main():
    flag_keys = {
        'optional': alias('bool', 'source_consume_optional_result.optional_after', required=False),
        'booster': alias('bool', 'source_consume_optional_result.booster_after', required=False),
        'update': alias('bool', 'source_consume_update_flag_result.update_after', required=False),
    }
    schemas = {
        'source_liquid_consumer_definition': (DEFINITIONS, {
            'liquid': backed('String', BLOCKS, 'consumeLiquid(Liquids.water, 0.05f).boost();', 'Original Liquids static field identifier, not a guessed content slug. Runtime resolves field -> typed content -> canonical ordinal.'),
            'amount': alias('float', 'source_consume_liquid_constructor_input.amount'),
            **flag_keys,
        }),
        'source_liquid_consumer_state': (BIND, {
            'liquid': alias('Variant', 'source_consume_liquid_constructor_result.liquid_after'),
            'amount': alias('float', 'source_consume_liquid_constructor_result.amount_after'),
            **flag_keys,
            'ignored': alias('bool', 'source_consume_ignore_result.ignored'),
        }),
        'source_liquid_consumer_definitions_input': (DEFINITIONS, {'block': backed('Object', BLOCK, 'public ConsumeLiquid consumeLiquid(Liquid liquid, float amount){', 'Required block with fully resolved direct consumeLiquid initializer metadata. Missing property is unresolved, not an empty consumer policy.')}),
        'source_liquid_consumer_definitions_result': (DEFINITIONS, {'consume_builder': backed('Array', BLOCK, 'return consume(new ConsumeLiquid(liquid, amount));', 'Ordered direct single-liquid constructor definitions only. Other consumer types, inherited constructors and unsupported calls remain outside this view.', schema='source_liquid_consumer_definition', used_by=[DEFINITIONS])}),
        'source_bind_liquid_consumers_input': (BIND, {
            'block': alias('Object', 'source_liquid_consumer_definitions_input.block'),
            'content_catalog': alias('Object', 'source_liquid_catalog_input.content_catalog'),
        }),
        'source_bind_liquid_consumers_result': (BIND, {'consumers': backed('Array', BLOCK, 'consumers = consumeBuilder.toArray(Consume.class);', 'One cached typed single-liquid descriptor view per Block, shared across its buildings. No full Block.init/apply, full mixed consumer list, automatic tick or multiplier policy is claimed.', schema='source_liquid_consumer_state', used_by=[BIND])}),
    }
    for name, (owner, keys) in schemas.items():
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, keys=keys, runtime_proof=PROOF))
    entries = [
        ('N2002', DEFINITIONS, 'source_liquid_consumer_definitions', BLOCKS, 'mindustry.content.Blocks', 'load()', ['block'], ['consumeLiquid(Liquids.water, 0.05f).boost();', 'consumeLiquid(Liquids.water, 3.5f / 60f).boost();']),
        ('N2003', BIND, 'source_bind_liquid_consumers', BLOCK, 'mindustry.world.Block', 'consumeLiquid(Liquid liquid, float amount); init()', ['block', 'content_catalog'], ['public ConsumeLiquid consumeLiquid(Liquid liquid, float amount){', 'return consume(new ConsumeLiquid(liquid, amount));', 'consumers = consumeBuilder.toArray(Consume.class);']),
    ]
    symbols = {}
    for slice_id, owner, prefix, source, java_class, method, params, expressions in entries:
        input_keys = schemas[prefix + '_input'][1]
        result_keys = schemas[prefix + '_result'][1]
        names = []
        for schema_name in [prefix + '_input', prefix + '_result']:
            for field, meta in schemas[schema_name][1].items():
                name = prefix.removeprefix('source_') + '.' + field
                names.append(name)
                symbols[name] = dict(status='source-backed', godot_owner=owner, godot_symbol=schema_name + '.' + field, java_source=meta.get('java_source', source), java_method=method, java_expr=meta.get('java_expr', expressions[-1]), rule=meta.get('rule', 'Reuse canonical source input and descriptor representation.'), tests=TESTS, runtime_proof=PROOF)
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=source, source_method=method, params=[dict(name=p, type=input_keys[p]['type'], schema=prefix + '_input.' + p) for p in params], return_keys=list(result_keys), tests=TESTS, runtime_proof=PROOF, rule='Required source-resolved single-liquid definitions and shared typed Block descriptor view; no guessed flag, liquid identity, resource formula or post-init capability fallback.'))
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=source, java_class=java_class, java_method=method, godot_owner=owner, exact_exprs=expressions, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=['Only standalone direct ConsumeLiquid calls with literal/division amounts and supported literal flag selectors are exported; the whole block remains unresolved if any call is unsupported.', 'Consumer.apply/post-Block.init capability and liquid filters, inherited constructor consumers, mixed consumer arrays, runtime multiplier callbacks and automatic Drill ticks remain deferred.', 'Metadata assumes one immutable catalog load. Dynamic content reload/reorder and consumer mutation need source-backed invalidation before reuse.']))
    for schema_name in ['source_liquid_consumer_definition', 'source_liquid_consumer_state']:
        owner, keys = schemas[schema_name]
        for field, meta in keys.items():
            name = schema_name.removeprefix('source_') + '.' + field
            symbols[name] = dict(status='source-backed', godot_owner=owner, godot_symbol=schema_name + '.' + field, java_source=meta.get('java_source', LIQUID if field in ('liquid', 'amount') else CONSUME), java_method='ConsumeLiquid(Liquid liquid, float amount)' if field in ('liquid', 'amount') else 'optional(boolean optional, boolean boost); update(boolean update); ignore()', java_expr=meta.get('java_expr', {'liquid': 'this.liquid = liquid;', 'amount': 'super(amount);', 'optional': 'this.optional = optional;', 'booster': 'this.booster = boost;', 'update': 'this.update = update;', 'ignored': 'return false;'}[field]), rule=meta.get('rule', 'Reuse canonical consumer field; absent flags stay absent for the existing classifier to interpret.'), tests=TESTS, runtime_proof=PROOF)
    symbols['block_liquid_consumers.metadata_key'] = dict(status='source-backed', godot_owner=BIND, godot_symbol='SourceConsumeLiquidState.SOURCE_BLOCK_LIQUID_CONSUMERS_META_KEY', java_source=BLOCK, java_method='init()', java_expr='public Consume[] consumers = {}, optionalConsumers = {}, nonOptionalConsumers = {}, updateConsumers = {};', rule='Single-liquid descriptor view belongs to Block and is shared by building instances; this is not a second building liquid storage owner.', tests=TESTS, runtime_proof=PROOF)
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ['consumer_slices', 'consumer_api_contracts', 'block_slices', 'block_api_contracts', 'content_registry_blocks']:
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    main()
