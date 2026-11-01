"""Extend the existing LiquidModule owner with source-backed instance lifecycle.

java_initialize_state is an explicit field-initialization adapter, not a parsed
Java constructor or an automatic content lookup from Godot new().
"""
from pathlib import Path

from mindustry_port import source_symbols

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SOURCE = 'core/src/mindustry/world/modules/LiquidModule.java'
PROOF = '/root/Main.LiquidModuleLifecycleProof'
TESTS = ['test_lifecycle_adapters_delegate_to_existing_storage_owner', 'test_lifecycle_source_contracts_and_shared_frame_are_registered', 'test_lifecycle_golden_runtime_and_initialized_consumption']
PREFIX = 'SourceLiquidModuleState.source_{}_state'
INIT_EXPRS = ['private float[] liquids = new float[content.liquids().size];', 'private Liquid current = content.liquid(0);', 'private @Nullable WindowedMean[] flow;']
METHODS = [
    ('N1996', 'initial', 'java_initialize_state', '<instance field initialization>', ['content_liquid_ids'], INIT_EXPRS),
    ('N1996', 'current', 'java_method_current_4', 'current()', ['self_state'], ['public Liquid current(){', 'return current;']),
    ('N1996', 'current_amount', 'java_method_currentAmount_7', 'currentAmount()', ['self_state'], ['public float currentAmount(){', 'return liquids[current.id];']),
    ('N1997', 'clear', 'java_method_clear_9', 'clear()', ['self_state'], ['public void clear(){', 'Arrays.fill(liquids, 0);']),
    ('N1997', 'reset', 'java_method_reset_5', 'reset(Liquid liquid, float amount)', ['self_state', 'liquid_id', 'amount'], ['public void reset(Liquid liquid, float amount){', 'Arrays.fill(liquids, 0f);', 'liquids[liquid.id] = amount;', 'current = liquid;']),
    ('N1998', 'set', 'java_method_set_6', 'set(Liquid liquid, float amount)', ['self_state', 'liquid_id', 'amount'], ['public void set(Liquid liquid, float amount){', 'if(amount >= liquids[current.id]){', 'current = liquid;', 'liquids[liquid.id] = amount;']),
]


def main():
    schemas = source_symbols.load_source_state_schema(GODOT)['schemas']
    storage = schemas['source_liquid_module_storage_state']['keys']
    shared = schemas['source_liquid_module_storage_input']['keys']
    initial_input = dict(type='Array', status='explicit-input', java_source=SOURCE, java_method='<instance field initialization>', java_expr=INIT_EXPRS[0], rule='Resolved content.liquids() IDs in source content order. Array size supplies content.liquids().size and the first ID represents content.liquid(0). Caller supplies a nonempty canonical content list; there is no fallback capacity/ID.')
    source_symbols.upsert_source_state_schema(GODOT, 'source_liquid_module_initial_input', dict(status='active', owner=PREFIX.format('initial'), runtime_proof=PROOF, keys={'content_liquid_ids': initial_input}))
    symbols = {}
    slices = {}
    for slice_id, method, adapter, java_method, params, exprs in METHODS:
        owner = PREFIX.format(method)
        if method == 'current':
            result = {'current': dict(type=storage['current']['type'], status='alias', alias_of='source_liquid_module_storage_state.current', used_by=[owner])}
        elif method == 'current_amount':
            result = {'amount': dict(type='float', status='alias', alias_of='source_liquid_module_get_result.amount', used_by=[owner])}
        else:
            result = {name: dict(type=meta['type'], status='alias', alias_of=f'source_liquid_module_storage_state.{name}', used_by=[owner]) for name, meta in storage.items()}
        source_symbols.upsert_source_state_schema(GODOT, f'source_liquid_module_{method}_result', dict(status='active', owner=owner, runtime_proof=PROOF, keys=result))
        api_params = []
        names = []
        for name in params:
            meta = initial_input if name == 'content_liquid_ids' else shared[name]
            schema = 'source_liquid_module_initial_input' if name == 'content_liquid_ids' else 'source_liquid_module_storage_input'
            api_params.append(dict(name=name, type=meta['type'], schema=f'{schema}.{name}'))
            symbol = f'liquid_module_{method}.{name}'
            symbols[symbol] = dict(status=meta['status'], godot_owner=owner, godot_symbol=f'{schema}.{name}', java_source=SOURCE, java_method=java_method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            names.append(symbol)
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=SOURCE, source_method=java_method, params=api_params, return_keys=list(result), tests=TESTS, runtime_proof=PROOF, rule='Same canonical storage frame/ID representation as N1993–N1995. Explicit field initializer allocates a fresh zeroed array and null instance flow; lifecycle methods preserve source assignment order and existing flow identity.'))
        entry = slices.setdefault(slice_id, dict(status='done', java_source=SOURCE, java_class='mindustry.world.modules.LiquidModule', java_method='', godot_owner='', generated_owner='', exact_exprs=[], source_symbols=[], tests=TESTS, runtime_proof=PROOF, rule='Cohesive instance lifecycle in the existing SourceLiquidModuleState owner; generated methods only normalize arguments and delegate.', deferred_exprs=['Runtime content provider and automatic binding from Godot new() remain deferred; java_initialize_state requires resolved canonical content IDs and is not a parsed Java constructor.', 'Array capacity changes, flow sampling/reset/display lifecycle, serialization and live world/Drill ownership remain separate integration work.']))
        for key, value in [('java_method', java_method), ('godot_owner', owner), ('generated_owner', f'LiquidModule.{adapter}')]:
            entry[key] = '; '.join(filter(None, [entry[key], value]))
        entry['exact_exprs'] = list(dict.fromkeys(entry['exact_exprs'] + exprs))
        entry['source_symbols'].extend(names)
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for slice_id, entry in slices.items():
        source_symbols.upsert_source_slice(GODOT, slice_id, entry)


if __name__ == '__main__':
    main()
