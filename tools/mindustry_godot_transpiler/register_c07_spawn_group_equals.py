"""Register SpawnGroup.equals(Object) (N2457).

SpawnGroup.equals(Object) (SpawnGroup.java:181-190) is one slice
(batch 44 slot 3): exactly the 5 distinct body exprs -- the
signature `public boolean equals(Object o){` (:182) and the 4 lines
of the return statement (:186-189) -- all 0-hit in ledger, registry
and contracts at base fbb81cad (1931 slices). The comparison covers
end, begin, spacing, max, unitScaling, shields, shieldScaling,
unitAmount, type, effect and items ONLY: spawn (:44), payloads
(:46) and team (:52) are deliberately NOT compared, so two groups
differing only in those fields are still equal. The three floats use
Java Float.compare semantics (NaN == NaN, -0.0f < 0.0f); GD's `==`
gets both wrong (NaN != NaN, 0.0 == -0.0), so GD compares floats
through a small _float_compare helper. Structs.eq(items, group.items)
(arc Structs.java:12-14) is `(a == b) || (a != null &&
a.equals(b))`, and ItemStack.equals (ItemStack.java:77-79) is same
object, or same item identity + same amount -- GD models ItemStack
as a Dictionary {"item": <name>, "amount": <int>} or null and
compares those two keys. type/effect are compared by content name
(the data-driven equivalent of Java reference identity for named
content). hashCode() (:192-195, Arrays.hashCode semantics) is NOT
part of this slice. One GD function on the existing file
SourceWaveSpawnRuntimeState.gd (home of the 3 earlier SpawnGroup
slices). One slice source: SpawnGroup.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
SPAWN_GROUP = 'core/src/mindustry/game/SpawnGroup.java'
PROOF = '/root/C07SpawnGroupEqualsProof'
EQUALS_OWNER = 'SourceWaveSpawnRuntimeState.source_spawn_group_equals_state'
TESTS = ['test_c07_spawn_group_equals_registration', 'test_all_c07_spawn_group_equals_input_evidence_is_exact', 'test_spawn_group_equals_state', 'test_reference_graph_and_actual_c07_spawn_group_equals']
# The 1 slice source the N2457 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/SpawnGroup.java',
]
EXACT_EXPRS = [
    'public boolean equals(Object o){',
    'return end == group.end && begin == group.begin && spacing == group.spacing && max == group.max',
    'Float.compare(group.unitScaling, unitScaling) == 0 && Float.compare(group.shields, shields) == 0',
    'Float.compare(group.shieldScaling, shieldScaling) == 0 && unitAmount == group.unitAmount &&',
    'type == group.type && effect == group.effect && Structs.eq(items, group.items);',
]
JAVA_METHOD = 'SpawnGroup.equals(Object)'

DEFERRED = [
    'SpawnGroup.hashCode() (SpawnGroup.java:192-195, `Arrays.hashCode(new Object[]{type, end, begin, spacing, max, unitScaling, shields, shieldScaling, unitAmount, effect, items})`) -- NOT ported here; Arrays.hashCode semantics belong to a later slice.',
    'The `this == o` identity shortcut (SpawnGroup.java:183) -- NOT modelled: GDScript has no reference-identity operator for Dictionary, and Dictionary `==` is deep value equality, which is wrong here twice over (verified on Godot 4.6.2): `==` between a Dictionary and a String/int is an invalid operation, and `{"x": 0.0} == {"x": -0.0}` is true, so a `==` shortcut would short-circuit the -0.0 trap before _float_compare ever runs. The shortcut is unobservable: the field comparison returns true for a group compared with itself (Float.compare makes NaN == NaN, Structs.eq makes items equal to itself).',
    'type/effect reference identity (`type == group.type && effect == group.effect`, SpawnGroup.java:189) -- GD compares the content names as strings (data-driven model); the actual UnitType/StatusEffect object identity is not ported.',
    'Structs.eq(items, group.items) (SpawnGroup.java:189) -- GD models ItemStack as a Dictionary {"item": <name>, "amount": <int>} or null and compares those two keys, per ItemStack.equals (ItemStack.java:77-79); a richer ItemStack model belongs to a later slice if needed.',
    'SpawnGroup.equals(Object) Windows Godot proof -- debt in GOAL.md section 5: the N2457 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=SPAWN_GROUP, **extra):
        return backed(typ, source, expr, rule, **extra)

    equals_inputs = {
        'group': a('Dictionary', 'SpawnGroup group = (SpawnGroup)o;', 'The SpawnGroup being compared (SpawnGroup.java:185, `SpawnGroup group = (SpawnGroup)o;`): a Dictionary with the compared fields end, begin, spacing, max, unitScaling, shields, shieldScaling, unitAmount, type, effect, items -- plus the uncompared spawn, payloads, team fields, which never affect the result.'),
        'other': a('Variant', 'public boolean equals(Object o){', 'The object to compare against (SpawnGroup.java:182, `public boolean equals(Object o){`): a Dictionary for another group, null, or any other type -- null and non-Dictionary values are never equal.'),
    }
    equals_outputs = {
        'equals': a('bool', 'return end == group.end && begin == group.begin && spacing == group.spacing && max == group.max', 'Whether the two groups are equal (SpawnGroup.java:186-189): all compared fields equal, with Float.compare semantics for the three floats (NaN == NaN, -0.0f < 0.0f) and Structs.eq semantics for items; spawn, payloads and team are deliberately not compared.'),
    }
    return equals_inputs, equals_outputs


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
    equals_inputs, equals_outputs = definitions()

    entries = [
        ('N2457', EQUALS_OWNER, 'source_spawn_group_equals_state', SPAWN_GROUP, 'mindustry.game.SpawnGroup', JAVA_METHOD, equals_inputs, equals_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed SpawnGroup.equals(Object) state from SpawnGroup.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed SpawnGroup.equals(Object) state from SpawnGroup.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2457'] = [
        'source_spawn_group_equals_state_result.equals',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2457', dict(status='done', java_source=SPAWN_GROUP, java_class='mindustry.game.SpawnGroup', java_method=JAVA_METHOD, godot_owner=EQUALS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2457'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
