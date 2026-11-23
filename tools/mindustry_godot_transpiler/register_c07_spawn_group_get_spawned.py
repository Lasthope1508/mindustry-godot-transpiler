"""Register SpawnGroup.getSpawned(int) (N2449).

SpawnGroup.getSpawned(int wave) (SpawnGroup.java:67-73, `public int
getSpawned(int wave){`) returns how many units spawn on a specific
wave. Exactly 3 body exprs are registered -- all 0-hit in both
ledgers (re-probed at HEAD 63e1399c + origin 63e1399c, no divergence):
`:68` `if(spacing == 0) spacing = 1;`, `:69` `if(wave < begin ||
wave > end || (wave - begin) % spacing != 0){`, `:72` `return
Math.min(unitAmount + (int)(((wave - begin) / spacing) /
unitScaling), max);`. `:70` `return 0;` is a generic literal already
owned by 11 slices (N1184/N1414/N1635/N524/N949/N1802/N1885/N2286/
N2322/N2245/N2249) and is NOT registered here.

Registration-only (precedent N2427/N2430/N2432-N2434): the formula
is already LIVE in SourceWaveSpawnRuntimeState.
spawned_for_wave_state (:16-40) -- no GD change in this slice. The
godot_owner follows the N2447 ClassName.func_name convention
(`SourceWaveSpawnRuntimeState.spawned_for_wave_state`); the runtime
"source_owner" value inside the returned dict comes from the
registry const SOURCE_WAVE_SPAWNED_FOR_WAVE_STATE
(SourceRuntimeOwnerGameplayRegistry.gd:175, lowercase value
"source_wave_spawn_runtime_state.spawned_for_wave_state"). The 3
source_symbols are the computed result keys: spacing (the effective
spacing after :68), eligible (the exact negation of :69), spawned
(the :72 formula). One GD function on the existing PortGame-era file
SourceWaveSpawnRuntimeState.gd. One slice source: SpawnGroup.java.

Deviations recorded, not hidden:
(b) :68 -- GD uses `max(1, spacing)`, which clamps negative spacing
to 1 as well, while Java only fixes spacing == 0 (negative spacing
stays, and `%` with a negative divisor applies at :69). Negative
spacing never occurs in real data (default 1, SpawnGroup.java:33),
but the difference is recorded here.
(c) :72 -- GD divides with floats (`float(wave_zero - begin) /
float(spacing)`) while Java divides ints (`(wave - begin) /
spacing`) and only then divides by unitScaling as a float. The two
are equivalent ONLY because :69 guarantees (wave - begin) %
spacing == 0 on the eligible branch (the other branch yields
spawned = 0 in both) -- equivalence is conditional, not
unconditional.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SPAWN_GROUP = 'core/src/mindustry/game/SpawnGroup.java'
PROOF = '/root/C07SpawnGroupGetSpawnedProof'
GET_SPAWNED_OWNER = 'SourceWaveSpawnRuntimeState.spawned_for_wave_state'
TESTS = ['test_c07_spawn_group_get_spawned_registration', 'test_all_c07_spawn_group_get_spawned_input_evidence_is_exact', 'test_spawn_group_get_spawned_state', 'test_reference_graph_and_actual_c07_spawn_group_get_spawned']
# The 1 slice source the N2449 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/SpawnGroup.java',
]
EXACT_EXPRS = [
    'if(spacing == 0) spacing = 1;',
    'if(wave < begin || wave > end || (wave - begin) % spacing != 0){',
    'return Math.min(unitAmount + (int)(((wave - begin) / spacing) / unitScaling), max);',
]

DEFERRED = [
    'Deviation (b): :68 -- GD uses `max(1, spacing)`, clamping negative spacing to 1 as well, while Java only fixes spacing == 0 (negative spacing stays, and `%` with a negative divisor applies at :69). Negative spacing never occurs in real data (default 1, SpawnGroup.java:33 `public int spacing = 1;`), but the difference is recorded, not hidden.',
    'Deviation (c): :72 -- GD divides with floats (`float(wave_zero - begin) / float(spacing)`) while Java divides ints (`(wave - begin) / spacing`) and only then divides by unitScaling as a float. Equivalent ONLY because :69 guarantees (wave - begin) % spacing == 0 on the eligible branch (the other branch yields spawned = 0 in both) -- equivalence is conditional, not unconditional.',
    ':70 `return 0;` is a generic literal already owned by 11 slices (N1184/N1414/N1635/N524/N949/N1802/N1885/N2286/N2322/N2245/N2249) -- NOT registered here. GD returns spawned = 0 when not eligible, which is the same outcome.',
    'Pre-existing PortGame-era guard, no Java equivalent: GD clamps unitScaling to at least 0.0001 (`max(float(group.get("unitScaling", ...)), 0.0001)`) to avoid division by zero; Java has no such clamp (unitScaling defaults to `never` = Integer.MAX_VALUE, SpawnGroup.java:38). The max clamp in :72 bounds the result either way.',
    'The spawnEnemies() call-site `int spawned = group.getSpawned(state.wave - 1);` (WaveSpawner.java, kept verbatim in SOURCE_WAVE_SPAWNER_WAVE_ZERO_EXPR) belongs to the spawnEnemies slice, not this one; wave_spawn_state already calls spawned_for_wave_state with wave_index - 1.',
    'SpawnGroup.getSpawned(int) Windows Godot proof -- debt in GOAL.md section 5: the N2449 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SPAWN_GROUP, **extra):
        return backed(typ, source, expr, rule, **extra)

    get_spawned_inputs = {
        'group': a('Dictionary', 'public class SpawnGroup implements JsonSerializable, Cloneable{', 'The SpawnGroup instance (SpawnGroup.java:23, `public class SpawnGroup implements JsonSerializable, Cloneable{`): GD takes it as a Dictionary carrying begin/end/spacing/unitAmount/unitScaling/max and never mutates it -- Java :68 mutates the field, GD returns the normalized spacing instead.'),
        'wave_zero': a('int', 'public int getSpawned(int wave){', 'The wave argument (SpawnGroup.java:67, `public int getSpawned(int wave){`): GD names it wave_zero because the call-site passes state.wave - 1 (see SOURCE_WAVE_SPAWNER_WAVE_ZERO_EXPR, `int spawned = group.getSpawned(state.wave - 1);`).'),
    }
    get_spawned_outputs = {
        'spacing': a('int', 'if(spacing == 0) spacing = 1;', 'The effective spacing after :68 (SpawnGroup.java:68, `if(spacing == 0) spacing = 1;`): GD returns max(1, spacing) without mutating the input group -- see deviation (b) in DEFERRED.'),
        'eligible': a('bool', 'if(wave < begin || wave > end || (wave - begin) % spacing != 0){', 'Whether this wave spawns for this group (SpawnGroup.java:69, the full if-condition): the exact negation of :69 -- wave >= begin and wave <= end and (wave - begin) % spacing == 0.'),
        'spawned': a('int', 'return Math.min(unitAmount + (int)(((wave - begin) / spacing) / unitScaling), max);', 'How many units spawn on this wave (SpawnGroup.java:72, the full return line): unitAmount + (wave - begin) / spacing / unitScaling, clamped by max; 0 when not eligible (the :70 outcome) -- see deviation (c) in DEFERRED.'),
    }
    return get_spawned_inputs, get_spawned_outputs


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
    get_spawned_inputs, get_spawned_outputs = definitions()

    entries = [
        ('N2449', GET_SPAWNED_OWNER, 'source_wave_spawned_for_wave_state', SPAWN_GROUP, 'mindustry.game.SpawnGroup', 'SpawnGroup.getSpawned(int)', get_spawned_inputs, get_spawned_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SpawnGroup.getSpawned(int) state from SpawnGroup.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SpawnGroup.getSpawned(int) state from SpawnGroup.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: spacing, eligible, spawned --
    # the computed result keys of the GD func, in Java order
    # (:68 normalization, :69 eligibility, :72 formula).
    by_slice['N2449'] = [
        'source_wave_spawned_for_wave_state_result.spacing',
        'source_wave_spawned_for_wave_state_result.eligible',
        'source_wave_spawned_for_wave_state_result.spawned',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2449', dict(status='done', java_source=SPAWN_GROUP, java_class='mindustry.game.SpawnGroup', java_method='SpawnGroup.getSpawned(int)', godot_owner=GET_SPAWNED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2449'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
