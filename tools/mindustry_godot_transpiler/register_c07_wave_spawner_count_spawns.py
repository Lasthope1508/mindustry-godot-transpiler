"""Register WaveSpawner.countSpawns() (N2442).

WaveSpawner.countSpawns() (WaveSpawner.java:49-51, `public int
countSpawns(){`) returns the number of spawn tiles: its only
body expr is `return spawns.size;` (:50). The 1 expr is 0-hit
in both ledgers (re-probed at HEAD d638bfc2). `spawns` is the
WaveSpawner field `private Seq<Tile> spawns = new Seq<>(false);`
(WaveSpawner.java:26); GD takes it as an Array input and does
not recompute it from the world (the world-tiles scan belongs
to reset(), WaveSpawner.java:217-227, a later slice). This is
the FIRST WaveSpawner slice on either line (java_method
containing WaveSpawner 0-hit both ledgers). It must not be
confused with countGroundSpawns()/countFlyerSpawns()
(WaveSpawner.java:201-211, batch 40 candidates), and
`spawnEnemies` is NOT registered here (unported, belongs to
runWave N2437's deferred call-site). One GD function on the
NEW file SourceWaveSpawnerState.gd. Pure accessor, precedent
N2123/N2297 (micro-accessors) + N2405/N2407/batch 37 slot 3
(new files). One slice source: WaveSpawner.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WAVE_SPAWNER = 'core/src/mindustry/ai/WaveSpawner.java'
PROOF = '/root/C07WaveSpawnerCountSpawnsProof'
COUNT_OWNER = 'SourceWaveSpawnerState.source_wave_spawner_count_spawns_state'
TESTS = ['test_c07_wave_spawner_count_spawns_registration', 'test_all_c07_wave_spawner_count_spawns_input_evidence_is_exact', 'test_wave_spawner_count_spawns_state', 'test_reference_graph_and_actual_c07_wave_spawner_count_spawns']
# The 1 slice source the N2442 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/ai/WaveSpawner.java',
]
EXACT_EXPRS = [
    'return spawns.size;',
]

DEFERRED = [
    'WaveSpawner.spawnEnemies() -- not in this slice; countSpawns is independent of spawnEnemies (WaveSpawner.java:62-110), which waits for a later WaveSpawner slice; the runWave func (N2437) records spawn_enemies: true as data until then.',
    'WaveSpawner.countGroundSpawns()/countFlyerSpawns() (WaveSpawner.java:201-211) -- batch 40 candidates, not registered here.',
    'WaveSpawner.countSpawns() Windows Godot proof -- debt in GOAL.md section 5: the N2442 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=WAVE_SPAWNER, **extra):
        return backed(typ, source, expr, rule, **extra)

    count_inputs = {
        'spawns': a('Array', 'private Seq<Tile> spawns = new Seq<>(false);', 'The spawn tiles of this WaveSpawner (WaveSpawner.java:26, `private Seq<Tile> spawns = new Seq<>(false);`): GD takes it as an Array input and does not recompute it from the world.'),
    }
    count_outputs = {
        'count': a('int', 'return spawns.size;', 'The number of spawn tiles (WaveSpawner.java:50, `return spawns.size;`): countSpawns returns the size of the spawns sequence.'),
    }
    return count_inputs, count_outputs


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
    count_inputs, count_outputs = definitions()

    entries = [
        ('N2442', COUNT_OWNER, 'source_wave_spawner_count_spawns_state', WAVE_SPAWNER, 'mindustry.ai.WaveSpawner', 'WaveSpawner.countSpawns()', count_inputs, count_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed WaveSpawner.countSpawns() state from WaveSpawner.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed WaveSpawner.countSpawns() state from WaveSpawner.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: count -- the single
    # result key of the GD func.
    by_slice['N2442'] = [
        'source_wave_spawner_count_spawns_state_result.count',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2442', dict(status='done', java_source=WAVE_SPAWNER, java_class='mindustry.ai.WaveSpawner', java_method='WaveSpawner.countSpawns()', godot_owner=COUNT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2442'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
