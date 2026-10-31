"""Register the cohesive LiquidModule get/add/remove storage boundary.

No constructor, content lookup or flow timer is synthesized. Static cacheSums is
an explicitly supplied shared array; current uses the upstream liquid.id identity.
"""
from pathlib import Path

from mindustry_port import source_symbols

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
SOURCE = 'core/src/mindustry/world/modules/LiquidModule.java'
PROOF = '/root/Main.LiquidModuleStorageProof'
TESTS = ['test_storage_generated_methods_delegate_to_one_domain_owner', 'test_storage_contracts_and_source_evidence_are_registered', 'test_storage_golden_runtime_and_consumption_mutation']
OWNER = 'SourceLiquidModuleState.source_{}_state'
FIELDS = {
    'liquids': ('Array', 'private float[] liquids = new float[content.liquids().size];', 'Indexed amounts; caller supplies actual content-sized storage, no capacity/default is guessed.'),
    'current': ('int', 'private Liquid current = content.liquid(0);', 'Explicit Liquid.id representation of current identity; constructor/content lookup stays deferred.'),
    'flow': ('Variant', 'private @Nullable WindowedMean[] flow;', 'Null/non-null flow identity only; this slice does not implement WindowedMean or timer sampling.'),
    'self_state': ('Dictionary', 'private float[] liquids = new float[content.liquids().size];', 'Mutable adapter of the existing LiquidModule instance fields, not new Java state.'),
    'liquid_id': ('int', 'liquids[liquid.id] += amount;', 'Explicit Liquid.id; caller supplies a valid in-range content ID.'),
    'amount': ('float', 'public void add(Liquid liquid, float amount){', 'Source amount parameter; no invented nonnegative guard.'),
    'cache_sums': ('Array', 'private static float[] cacheSums;', 'Explicit shared static cacheSums array; caller supplies capacity when flow is non-null.'),
}


def field(name):
    typ, expr, rule = FIELDS[name]
    return dict(type=typ, status='source-backed', java_source=SOURCE, java_method='LiquidModule', java_expr=expr, rule=rule)


def main():
    state_keys = {name: field(name) for name in ('liquids', 'current', 'flow')}
    source_symbols.upsert_source_state_schema(GODOT, 'source_liquid_module_storage_state', dict(status='active', owner=OWNER.format('add'), runtime_proof=PROOF, keys=state_keys))
    inputs = {name: field(name) for name in ('self_state', 'liquid_id', 'amount', 'cache_sums')}
    inputs['self_state']['schema'] = 'source_liquid_module_storage_state'
    source_symbols.upsert_source_state_schema(GODOT, 'source_liquid_module_storage_input', dict(status='active', owner=OWNER.format('add'), runtime_proof=PROOF, keys=inputs))
    symbols = {}
    for slice_id, method, index, exprs in [
        ('N1993', 'get', 8, ['public float get(Liquid liquid){', 'return liquids[liquid.id];']),
        ('N1994', 'add', 10, ['public void add(Liquid liquid, float amount){', 'liquids[liquid.id] += amount;', 'current = liquid;', 'if(flow != null){', 'cacheSums[liquid.id] += Math.max(amount, 0);']),
        ('N1995', 'remove', 12, ['public void remove(Liquid liquid, float amount){', '//cap to prevent negative removal', 'add(liquid, Math.max(-amount, -liquids[liquid.id]));']),
    ]:
        owner = OWNER.format(method)
        params = ['self_state', 'liquid_id'] + ([] if method == 'get' else ['amount', 'cache_sums'])
        if method == 'get':
            result = {'amount': dict(type='float', status='source-backed', java_source=SOURCE, java_method='get(Liquid liquid)', java_expr=exprs[1], rule='Read indexed amount without mutation.', used_by=[owner])}
        else:
            result = {name: dict(type=meta['type'], status='alias', alias_of=f'source_liquid_module_storage_state.{name}', used_by=[owner]) for name, meta in state_keys.items()}
        source_symbols.upsert_source_state_schema(GODOT, f'source_liquid_module_{method}_result', dict(status='active', owner=owner, runtime_proof=PROOF, keys=result))
        names = []
        for name in params:
            symbol = f'liquid_module_{method}.{name}'
            meta = inputs[name]
            symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=f'source_liquid_module_storage_input.{name}', java_source=SOURCE, java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            names.append(symbol)
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=slice_id, java_source=SOURCE, source_method=method, params=[dict(name=name, type=inputs[name]['type'], schema=f'source_liquid_module_storage_input.{name}') for name in params], return_keys=list(result), tests=TESTS, runtime_proof=PROOF, rule='Explicit instance storage adapter; get returns amount, add/remove mutate the original frame and shared cache. remove reuses canonical add, preserving source negative-request behavior.'))
        source_symbols.upsert_source_slice(GODOT, slice_id, dict(status='done', java_source=SOURCE, java_class='mindustry.world.modules.LiquidModule', java_method=method, godot_owner=owner, generated_owner=f'LiquidModule.java_method_{method}_{index}', exact_exprs=exprs + [FIELDS[name][1] for name in ('liquids', 'current', 'flow', 'cache_sums')], source_symbols=names, tests=TESTS, runtime_proof=PROOF, rule='Canonical LiquidModule storage behavior; generated method delegates through explicit storage/identity inputs.', deferred_exprs=['Content-sized constructor allocation and concrete Liquid object lookup remain caller-supplied; ID adapter represents Liquid.id/current.id.', 'WindowedMean allocation, flow timers, cache reset/poll/display and stopFlow are not implemented; caller supplies actual flow presence and the shared static cacheSums array.', 'Other LiquidModule methods, serialization and world/Drill resource ownership remain separate integration work.']))
    source_symbols.upsert_source_symbols(GODOT, symbols)


if __name__ == '__main__':
    main()
