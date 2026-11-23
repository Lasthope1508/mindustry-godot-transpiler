"""Register WaveSpawner.countGroundSpawns() + countFlyerSpawns() (N2453).

WaveSpawner.countGroundSpawns() (WaveSpawner.java:201-205) +
WaveSpawner.countFlyerSpawns() (WaveSpawner.java:207-211) is one
combined slice (batch 43 slot 2): exactly the 4 distinct body exprs
-- `tmpCount = 0;` (:202/:208, shared),
`eachGroundSpawn((x, y) -> tmpCount ++);` (:203),
`eachFlyerSpawn(-1, (x, y) -> tmpCount ++);` (:209) and
`return tmpCount;` (:204/:210, shared) -- all 0-hit in both ledgers
(re-probed at base 2fb5e9c7 + origin 63e1399c -- local 1926 slices,
remote 1923 slices, no new divergence). Each Java method resets
tmpCount, counts one callback invocation per enumerated spawn point,
and returns the total -- so the count IS the size of the enumerated
list. GD takes the two already-enumerated lists as Array inputs
(option (A) data-driven, decided at spawn; precedent N2451 playerNear
input instead of cross-func call) and does not enumerate them itself:
eachGroundSpawn (:125-175) and eachFlyerSpawn (:176-199) are NOT
ported and belong to later slices -- this slice does NOT claim the
iterators are ported. The field `private int tmpCount;`
(WaveSpawner.java:25) is NOT registered here (field decl, no GD state
needed -- count is list size). The Logic call-sites
(checkGameState / runWave) are NOT registered here; they belong to
Logic, a later slice. One GD function on the existing file
SourceWaveSpawnerState.gd (opened by N2442, extended by
N2444/N2446/N2451). One slice source: WaveSpawner.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WAVE_SPAWNER = 'core/src/mindustry/ai/WaveSpawner.java'
PROOF = '/root/C07WaveSpawnerSpawnCountsProof'
SPAWN_COUNTS_OWNER = 'SourceWaveSpawnerState.source_wave_spawner_spawn_counts_state'
TESTS = ['test_c07_wave_spawner_spawn_counts_registration', 'test_all_c07_wave_spawner_spawn_counts_input_evidence_is_exact', 'test_wave_spawner_spawn_counts_state', 'test_reference_graph_and_actual_c07_wave_spawner_spawn_counts']
# The 1 slice source the N2453 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/ai/WaveSpawner.java',
]
EXACT_EXPRS = [
    'tmpCount = 0;',
    'eachGroundSpawn((x, y) -> tmpCount ++);',
    'eachFlyerSpawn(-1, (x, y) -> tmpCount ++);',
    'return tmpCount;',
]
JAVA_METHOD = 'WaveSpawner.countGroundSpawns() + WaveSpawner.countFlyerSpawns()'

DEFERRED = [
    'WaveSpawner.eachGroundSpawn(int, SpawnConsumer) (WaveSpawner.java:125-175) + eachFlyerSpawn(int, Floatc2) (WaveSpawner.java:176-199) -- the iterators that enumerate the spawn points are NOT ported here; this slice only counts already-enumerated lists (option (A) data-driven), and the enumeration belongs to later eachGroundSpawn/eachFlyerSpawn slices.',
    'The field `private int tmpCount;` (WaveSpawner.java:25) -- NOT registered here (field decl, no GD state needed -- count is list size).',
    'The Logic call-sites of countGroundSpawns()/countFlyerSpawns() (checkGameState / runWave) -- not in this slice; they belong to Logic, a later slice.',
    'WaveSpawner.countGroundSpawns()/countFlyerSpawns() Windows Godot proof -- debt in GOAL.md section 5: the N2453 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=WAVE_SPAWNER, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return tmpCount;'
    spawn_counts_inputs = {
        'ground_spawn_points': a('Array', 'eachGroundSpawn((x, y) -> tmpCount ++);', 'The already-enumerated ground spawn points (WaveSpawner.java:203, `eachGroundSpawn((x, y) -> tmpCount ++);`): the (x, y) pairs the iterator would pass to the counting callback; GD takes them as an Array input and counts them by size, never calling eachGroundSpawn itself (option (A) data-driven).'),
        'flyer_spawn_points': a('Array', 'eachFlyerSpawn(-1, (x, y) -> tmpCount ++);', 'The already-enumerated flyer spawn points (WaveSpawner.java:209, `eachFlyerSpawn(-1, (x, y) -> tmpCount ++);`): the (x, y) pairs the iterator would pass to the counting callback; GD takes them as an Array input and counts them by size, never calling eachFlyerSpawn itself (option (A) data-driven).'),
    }
    spawn_counts_outputs = {
        'ground_spawn_count': a('int', expr, 'The ground spawn count (WaveSpawner.java:204, `return tmpCount;`): the number of ground spawn points, i.e. the size of the enumerated ground list.'),
        'flyer_spawn_count': a('int', expr, 'The flyer spawn count (WaveSpawner.java:210, `return tmpCount;`): the number of flyer spawn points, i.e. the size of the enumerated flyer list.'),
    }
    return spawn_counts_inputs, spawn_counts_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for keys in inputs_outputs:
        total += len(keys)
        for field, meta in keys.items():
            source = meta['java_source']
            text = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
            if meta['java_expr'] not in text:
                missing.append('%s: %s' % (field, meta['java_expr']))
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    symbols = {}
    spawn_counts_inputs, spawn_counts_outputs = definitions()

    entries = [
        ('N2453', SPAWN_COUNTS_OWNER, 'source_wave_spawner_spawn_counts_state', WAVE_SPAWNER, 'mindustry.ai.WaveSpawner', JAVA_METHOD, spawn_counts_inputs, spawn_counts_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed WaveSpawner.countGroundSpawns()/countFlyerSpawns() state from WaveSpawner.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed WaveSpawner.countGroundSpawns()/countFlyerSpawns() state from WaveSpawner.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: flyer_spawn_count before
    # ground_spawn_count (alphabetical) -- the two result keys of
    # the GD func.
    by_slice['N2453'] = [
        'source_wave_spawner_spawn_counts_state_result.flyer_spawn_count',
        'source_wave_spawner_spawn_counts_state_result.ground_spawn_count',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2453', dict(status='done', java_source=WAVE_SPAWNER, java_class='mindustry.ai.WaveSpawner', java_method=JAVA_METHOD, godot_owner=SPAWN_COUNTS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2453'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
