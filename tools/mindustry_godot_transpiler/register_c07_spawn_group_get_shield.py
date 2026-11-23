"""Register SpawnGroup.getShield(int) (N2452).

SpawnGroup.getShield(int wave) (SpawnGroup.java:76-78, `public float
getShield(int wave){`) returns how much shield each unit has on a
specific wave. Exactly 1 body expr is registered -- 0-hit in both
ledgers (re-probed at HEAD 2fb5e9c7 + origin 63e1399c, no
divergence): `:77` `return Math.max(shields +
shieldScaling*(wave - begin), 0);`.

Unlike getSpawned (N2449, registration-only), the formula was NOT
live in GD (grep `-i shield` in SourceWaveSpawnRuntimeState.gd:
0-hit; grep `get_shield|getShield` in all of src/game/: 0-hit), so
this slice writes a NEW GD func, source_spawn_group_get_shield_state,
as its godot_owner (`SourceWaveSpawnRuntimeState.
source_spawn_group_get_shield_state`): the validator only discovers
functions named source_*/generated_/tile_ (the N2449 linkage lesson:
never register a bare name). Java `Math.max(float, int 0)` becomes
GD `maxf(shields + shield_scaling * float(wave - begin), 0.0)`
(maxf, not maxi, because the left side is a float; wave - begin
may be negative -- the clamp to 0 is correct in that case too).
The 1 source_symbol is the computed result key: shield (the :77
formula). One GD function on the existing PortGame-era file
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
PROOF = '/root/C07SpawnGroupGetShieldProof'
GET_SHIELD_OWNER = 'SourceWaveSpawnRuntimeState.source_spawn_group_get_shield_state'
TESTS = ['test_c07_spawn_group_get_shield_registration', 'test_all_c07_spawn_group_get_shield_input_evidence_is_exact', 'test_spawn_group_get_shield_state', 'test_reference_graph_and_actual_c07_spawn_group_get_shield']
# The 1 slice source the N2452 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/SpawnGroup.java',
]
EXACT_EXPRS = [
    'return Math.max(shields + shieldScaling*(wave - begin), 0);',
]

DEFERRED = [
    'The createUnit() call-site `unit.shield = getShield(wave);` (SpawnGroup.java:92) belongs to the createUnit slice, not this one; this slice ports only the getShield formula.',
    'Java `Math.max(float, int 0)` becomes GD `maxf(..., 0.0)` -- the 0 literal is 0.0 in GD because maxf takes floats; the clamp value is identical.',
    'SpawnGroup.getShield(int) Windows Godot proof -- debt in GOAL.md section 5: the N2452 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SPAWN_GROUP, **extra):
        return backed(typ, source, expr, rule, **extra)

    get_shield_inputs = {
        'shields': a('float', 'public float shields = 0f;', 'The base shield points each unit has (SpawnGroup.java:38, `public float shields = 0f;`): GD takes it as a float input, never reads the field.'),
        'shield_scaling': a('float', 'public float shieldScaling = 0f;', 'How much shields get increased by per wave (SpawnGroup.java:40, `public float shieldScaling = 0f;`): GD takes it as a float input.'),
        'wave': a('int', 'public float getShield(int wave){', 'The wave argument (SpawnGroup.java:76, `public float getShield(int wave){`): GD names it wave, the wave whose shield is computed.'),
        'begin': a('int', 'public int begin;', 'When this spawn should start (SpawnGroup.java:30, `public int begin;`): the wave the scaling counts from -- GD takes it as an int input.'),
    }
    get_shield_outputs = {
        'shield': a('float', 'return Math.max(shields + shieldScaling*(wave - begin), 0);', 'How much shield each unit has on this wave (SpawnGroup.java:77, the full return line): shields + shieldScaling * (wave - begin), clamped at 0; wave - begin may be negative, so the clamp also covers waves before begin.'),
    }
    return get_shield_inputs, get_shield_outputs


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
    get_shield_inputs, get_shield_outputs = definitions()

    entries = [
        ('N2452', GET_SHIELD_OWNER, 'source_spawn_group_get_shield_state', SPAWN_GROUP, 'mindustry.game.SpawnGroup', 'SpawnGroup.getShield(int)', get_shield_inputs, get_shield_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SpawnGroup.getShield(int) state from SpawnGroup.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SpawnGroup.getShield(int) state from SpawnGroup.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: shield -- the single computed
    # result key of the GD func, the :77 formula.
    by_slice['N2452'] = [
        'source_spawn_group_get_shield_state_result.shield',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2452', dict(status='done', java_source=SPAWN_GROUP, java_class='mindustry.game.SpawnGroup', java_method='SpawnGroup.getShield(int)', godot_owner=GET_SHIELD_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2452'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
