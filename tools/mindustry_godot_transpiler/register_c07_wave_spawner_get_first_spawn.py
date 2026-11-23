"""Register WaveSpawner.getFirstSpawn() (N2455).

WaveSpawner.getFirstSpawn() (WaveSpawner.java:40-47) is one slice
(batch 44 slot 1): exactly the 3 distinct body exprs --
`firstSpawn = null;` (:42),
`eachGroundSpawn((cx, cy) -> { firstSpawn = world.tile(cx, cy); });`
(:43-45, registered as its two verbatim lines) and
`return firstSpawn;` (:46) -- all 0-hit in ledger, registry and
contracts at base 899260e (1929 slices). The callback overwrites
firstSpawn UNCONDITIONALLY on every enumerated ground spawn point,
so despite the name the method returns the LAST enumerated tile
(or null when there are none). GD takes the already-enumerated
ground spawn tiles as an Array input (option (A) data-driven,
precedent N2453 spawn counts / N2451 playerNear) and does not
enumerate them itself: eachGroundSpawn (:121-174) is NOT ported
and belongs to a later slice -- this slice does NOT claim the
iterator is ported. Each input element is the tile the callback
would have produced via `world.tile(cx, cy)` (:44). The field
`private Tile firstSpawn = null;` (WaveSpawner.java:29) is NOT
registered here (field decl; in the port it is a per-call local,
reset to null at the start of every call, exactly like :42).
Call-sites of getFirstSpawn() are NOT registered here; they
belong to their own owners, later slices. One GD function on the
existing file SourceWaveSpawnerState.gd (opened by N2442,
extended by N2444/N2446/N2451/N2453). One slice source:
WaveSpawner.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WAVE_SPAWNER = 'core/src/mindustry/ai/WaveSpawner.java'
PROOF = '/root/C07WaveSpawnerGetFirstSpawnProof'
GET_FIRST_SPAWN_OWNER = 'SourceWaveSpawnerState.source_wave_spawner_get_first_spawn_state'
TESTS = ['test_c07_wave_spawner_get_first_spawn_registration', 'test_all_c07_wave_spawner_get_first_spawn_input_evidence_is_exact', 'test_wave_spawner_get_first_spawn_state', 'test_reference_graph_and_actual_c07_wave_spawner_get_first_spawn']
# The 1 slice source the N2455 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/ai/WaveSpawner.java',
]
EXACT_EXPRS = [
    'firstSpawn = null;',
    'eachGroundSpawn((cx, cy) -> {',
    'firstSpawn = world.tile(cx, cy);',
    'return firstSpawn;',
]
JAVA_METHOD = 'WaveSpawner.getFirstSpawn()'

DEFERRED = [
    'WaveSpawner.eachGroundSpawn(Intc2) (WaveSpawner.java:121-123) + eachGroundSpawn(int, SpawnConsumer) (WaveSpawner.java:125-174) -- the iterators that enumerate the ground spawn points are NOT ported here; this slice only folds an already-enumerated tile list (option (A) data-driven), and the enumeration belongs to later eachGroundSpawn slices.',
    'The field `private Tile firstSpawn = null;` (WaveSpawner.java:29) -- NOT registered here (field decl; in the port it is a per-call local reset by `firstSpawn = null;` at WaveSpawner.java:42).',
    'The call-sites of getFirstSpawn() -- not in this slice; they belong to their own owners, later slices.',
    'WaveSpawner.getFirstSpawn() Windows Godot proof -- debt in GOAL.md section 5: the N2455 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=WAVE_SPAWNER, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return firstSpawn;'
    get_first_spawn_inputs = {
        'ground_spawn_tiles': a('Array', 'eachGroundSpawn((cx, cy) -> {', 'The already-enumerated ground spawn tiles (WaveSpawner.java:43-44, `eachGroundSpawn((cx, cy) -> { firstSpawn = world.tile(cx, cy); });`): the tiles the iterator callback would produce via world.tile(cx, cy), in enumeration order; GD takes them as an Array input and folds them in order, never calling eachGroundSpawn itself (option (A) data-driven).'),
    }
    get_first_spawn_outputs = {
        'first_spawn': a('Variant', expr, 'The first-spawn tile (WaveSpawner.java:46, `return firstSpawn;`): the LAST tile of the enumerated ground spawn list, because the callback at WaveSpawner.java:44 overwrites firstSpawn unconditionally on every point; null when the list is empty (the reset at WaveSpawner.java:42 stands).'),
    }
    return get_first_spawn_inputs, get_first_spawn_outputs


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
    get_first_spawn_inputs, get_first_spawn_outputs = definitions()

    entries = [
        ('N2455', GET_FIRST_SPAWN_OWNER, 'source_wave_spawner_get_first_spawn_state', WAVE_SPAWNER, 'mindustry.ai.WaveSpawner', JAVA_METHOD, get_first_spawn_inputs, get_first_spawn_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed WaveSpawner.getFirstSpawn() state from WaveSpawner.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed WaveSpawner.getFirstSpawn() state from WaveSpawner.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2455'] = [
        'source_wave_spawner_get_first_spawn_state_result.first_spawn',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2455', dict(status='done', java_source=WAVE_SPAWNER, java_class='mindustry.ai.WaveSpawner', java_method=JAVA_METHOD, godot_owner=GET_FIRST_SPAWN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2455'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
