"""Register SpawnGroup.canSpawn(int) (N2447).

SpawnGroup.canSpawn(int) (SpawnGroup.java:62-64, `public boolean
canSpawn(int position){`) is a pure predicate: its only body expr is
`return spawn == -1 || spawn == position;` (:63). The 1 expr is 0-hit
in both ledgers (re-probed at HEAD 70405e1e + origin 6d09d677; the
only `canSpawn` hits in either ledger are N463/N464, a local boolean
inside BulletType.updateTrailEffects -- different class/method).
`spawn` is the SpawnGroup field `public int spawn = -1;`
(SpawnGroup.java:44, "If not -1, the unit will only spawn in
spawnpoints with these packed coordinates."): -1 means every
position. GD takes spawn + position as int inputs and never
packs/unpacks coords here. No call-site of canSpawn exists outside
SpawnGroup.java (grep: 0 hits) -- this slice ports only the
predicate. One GD function on the existing PortGame-era file
SourceWaveSpawnRuntimeState.gd. One slice source: SpawnGroup.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SPAWN_GROUP = 'core/src/mindustry/game/SpawnGroup.java'
PROOF = '/root/C07SpawnGroupCanSpawnProof'
CAN_SPAWN_OWNER = 'SourceWaveSpawnRuntimeState.source_wave_spawn_can_spawn_state'
TESTS = ['test_c07_spawn_group_can_spawn_registration', 'test_all_c07_spawn_group_can_spawn_input_evidence_is_exact', 'test_spawn_group_can_spawn_state', 'test_reference_graph_and_actual_c07_spawn_group_can_spawn']
# The 1 slice source the N2447 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/SpawnGroup.java',
]
EXACT_EXPRS = [
    'return spawn == -1 || spawn == position;',
]

DEFERRED = [
    'SpawnGroup.canSpawn(int) has no call-site outside SpawnGroup.java (grep: 0 hits) -- no consumer slice follows from this one; consumers that later call canSpawn belong to their own method slices.',
    'The `spawn` field writes -- SpawnGroup.read()/write() serialization and editor/mod assignment of `spawn` -- are later slices; canSpawn only reads the frame input.',
    'SpawnGroup.canSpawn(int) Windows Godot proof -- debt in GOAL.md section 5: the N2447 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SPAWN_GROUP, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return spawn == -1 || spawn == position;'
    can_spawn_inputs = {
        'spawn': a('int', 'public int spawn = -1;', 'The packed-coords spawnpoint this group is restricted to (SpawnGroup.java:44, `public int spawn = -1;` -- "If not -1, the unit will only spawn in spawnpoints with these packed coordinates."): -1 means every position, the first disjunct of canSpawn().'),
        'position': a('int', 'public boolean canSpawn(int position){', 'The packed-coords position to test (SpawnGroup.java:62, `public boolean canSpawn(int position){`): the second disjunct compares it against spawn.'),
    }
    can_spawn_outputs = {
        'can_spawn': a('bool', expr, 'Whether this group spawns at the given position (SpawnGroup.java:63, the full return line): spawn == -1 || spawn == position.'),
    }
    return can_spawn_inputs, can_spawn_outputs


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
    can_spawn_inputs, can_spawn_outputs = definitions()

    entries = [
        ('N2447', CAN_SPAWN_OWNER, 'source_wave_spawn_can_spawn_state', SPAWN_GROUP, 'mindustry.game.SpawnGroup', 'SpawnGroup.canSpawn(int)', can_spawn_inputs, can_spawn_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SpawnGroup.canSpawn(int) state from SpawnGroup.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SpawnGroup.canSpawn(int) state from SpawnGroup.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: can_spawn -- the single
    # result key of the GD func.
    by_slice['N2447'] = [
        'source_wave_spawn_can_spawn_state_result.can_spawn',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2447', dict(status='done', java_source=SPAWN_GROUP, java_class='mindustry.game.SpawnGroup', java_method='SpawnGroup.canSpawn(int)', godot_owner=CAN_SPAWN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2447'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
