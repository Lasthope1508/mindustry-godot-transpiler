"""Register WaveSpawner.isSpawning() (N2444).

WaveSpawner.isSpawning() (WaveSpawner.java:213-215, `public boolean
isSpawning(){`) is a pure predicate: its only body expr is
`return spawning && !net.client();` (:214). The 1 expr is 0-hit
in both ledgers (re-probed at HEAD 8a0c6e4d). `spawning` is the
WaveSpawner field `private boolean spawning = false;`
(WaveSpawner.java:27), set true by spawnEnemies() (:63) and
cleared by reset() (:218) / a delayed Time.run (:108); GD takes
it as a bool input. `net.client()` is read as-is from the frame
input is_client and never resolved here (precedent N2438
checkCampaignStats, same `... && !net.client()` shape, and
N2436 isWaitingWave). The checkGameState() call-site
`spawner.isSpawning();` (WaveSpawner.java:369, inside
Logic.checkGameState) is NOT registered here -- it belongs to
checkGameState, a later slice. One GD function on the existing
file SourceWaveSpawnerState.gd (opened by N2442). One slice
source: WaveSpawner.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WAVE_SPAWNER = 'core/src/mindustry/ai/WaveSpawner.java'
PROOF = '/root/C07WaveSpawnerIsSpawningProof'
SPAWNING_OWNER = 'SourceWaveSpawnerState.source_wave_spawner_is_spawning_state'
TESTS = ['test_c07_wave_spawner_is_spawning_registration', 'test_all_c07_wave_spawner_is_spawning_input_evidence_is_exact', 'test_wave_spawner_is_spawning_state', 'test_reference_graph_and_actual_c07_wave_spawner_is_spawning']
# The 1 slice source the N2444 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/ai/WaveSpawner.java',
]
EXACT_EXPRS = [
    'return spawning && !net.client();',
]

DEFERRED = [
    'Logic.checkGameState() call-site `spawner.isSpawning();` (WaveSpawner.java:369, via Logic.java checkGameState) -- not in this slice; it belongs to checkGameState, a later slice.',
    'The live writes to the `spawning` field -- spawnEnemies() sets it true (WaveSpawner.java:63), reset() clears it (:218), a delayed Time.run clears it (:108) -- are later slices; isSpawning only reads the frame input.',
    'WaveSpawner.isSpawning() Windows Godot proof -- debt in GOAL.md section 5: the N2444 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=WAVE_SPAWNER, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return spawning && !net.client();'
    is_spawning_inputs = {
        'spawning': a('bool', 'private boolean spawning = false;', 'Whether a wave is currently spawning (WaveSpawner.java:27, `private boolean spawning = false;`): the first conjunct of isSpawning(), set true by spawnEnemies() (:63) and cleared by reset() (:218).'),
        'is_client': a('bool', expr, 'Whether the game runs as a net client (WaveSpawner.java:214, `net.client()`): negated in the second conjunct of isSpawning().'),
    }
    is_spawning_outputs = {
        'spawning': a('bool', expr, 'Whether a wave is spawning and this side is not a net client (WaveSpawner.java:214, the full return line): spawning && !net.client().'),
    }
    return is_spawning_inputs, is_spawning_outputs


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
    is_spawning_inputs, is_spawning_outputs = definitions()

    entries = [
        ('N2444', SPAWNING_OWNER, 'source_wave_spawner_is_spawning_state', WAVE_SPAWNER, 'mindustry.ai.WaveSpawner', 'WaveSpawner.isSpawning()', is_spawning_inputs, is_spawning_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed WaveSpawner.isSpawning() state from WaveSpawner.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed WaveSpawner.isSpawning() state from WaveSpawner.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: spawning -- the single
    # result key of the GD func.
    by_slice['N2444'] = [
        'source_wave_spawner_is_spawning_state_result.spawning',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2444', dict(status='done', java_source=WAVE_SPAWNER, java_class='mindustry.ai.WaveSpawner', java_method='WaveSpawner.isSpawning()', godot_owner=SPAWNING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2444'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
