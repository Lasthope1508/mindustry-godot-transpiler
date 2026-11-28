"""Register Team.localized() (N2494).

Team.localized() (Team.java:135-137) is one slice
(batch C8, twin-register slot):
    public String localized(){
        return Core.bundle.get("team." + name + ".name", name);
    }
Core.bundle.get(key, def) is I18NBundle.get (arc-core
I18NBundle.java:412-414): `has(key) ? get(key) : def` --
for the key "team." + name + ".name". The field `name`
is `public String` (Team.java:25). Core.bundle itself
is NOT ported here, so the raw lookup result arrives
as a precomputed input (the getOrNull-equivalent:
null when the key is absent; the N1271
ability_localized.bundle_get precedent) and the GD
function falls back to the name only on a missing
key. TRAP: an empty bundle value is a real value,
not a miss -- it passes through, never replaced by
the name. TWIN-REGISTER (main-thread approval
2026-11-28 ~11:40, N2474 precedent): the body
literal is already an exact_expr of N2488
(Team.coloredName quotes localized() as dependency
evidence and defers it for its own slice) -- N2488
is the original owner of the shared literal, this
slice ports localized() as its own GD function.
One GD function on the existing file
SourceTeamsRuntimeState.gd (home of N2456 Team.get,
N2488 Team.coloredName and N2463 Team.compareTo),
placed between source_team_get_state and
source_team_colored_name_state because Team.get()
(:58-60) comes before localized() (:135-137), which
comes before coloredName() (:139-141) in Team.java.
One slice source: Team.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM = 'core/src/mindustry/game/Team.java'
PROOF = '/root/C07TeamLocalizedProof'
LOCALIZED_OWNER = 'SourceTeamsRuntimeState.source_team_localized_state'
TESTS = ['test_c07_team_localized_registration', 'test_all_c07_team_localized_input_evidence_is_exact', 'test_team_localized_state', 'test_reference_graph_and_actual_c07_team_localized']
# The 1 slice source the N2494 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Team.java',
]
FORMULA = '        return Core.bundle.get("team." + name + ".name", name);'
EXACT_EXPRS = [
    'public class Team implements Comparable<Team>, Senseable{',
    '    public String name;',
    '    public String localized(){',
    FORMULA,
]
JAVA_METHOD = 'Team.localized()'

DEFERRED = [
    'TWIN-REGISTER (main-thread approval 2026-11-28 ~11:40, N2474 precedent): the body literal `return Core.bundle.get("team." + name + ".name", name);` is already an exact_expr of N2488 (Team.coloredName quotes localized() as dependency evidence and defers it for its own slice) -- N2488 is the original owner of the shared literal; this slice ports localized() as its own GD function (SourceTeamsRuntimeState.source_team_localized_state).',
    'The real Core.bundle lookup (I18NBundle, arc-core I18NBundle.java:412-414) is NOT ported here: the bundle_value input is the precomputed raw lookup result (the getOrNull-equivalent, null when the key is absent; the N1271 ability_localized.bundle_get precedent) -- a real bundle implementation waits for a later slice.',
    'Team.localized() Windows Godot proof -- debt in GOAL.md section 5: the N2494 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Team.activateUnitFactories() (Team.java:127) and Team.isAI() (Team.java:112) need a twin-register approval of their own (their body literals are exact_exprs of N2124) -- they are NOT in this slice and must not be taken as slots without that approval (the N2474 precedent).',
    'Team.rules() (Team.java:88) needs a twin-register approval of its own (its body literal is an exact_expr of N2099/N2107) -- it is NOT in this slice.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM, **extra):
        return backed(typ, source, expr, rule, **extra)

    localized_inputs = {
        'name': a('String', '    public String name;', 'The team name field (Team.java:25, `public String name;`): the key stem ("team." + name + ".name") and the fallback value when the bundle has no entry for the key.'),
        'bundle_value': a('Variant', '        return Core.bundle.get("team." + name + ".name", name);', 'The precomputed raw bundle lookup result for the key "team." + name + ".name" (Team.java:136, `return Core.bundle.get("team." + name + ".name", name);`): the bundle value when the key exists, or null (the getOrNull-equivalent) when it does not -- Core.bundle is NOT ported here (the N1271 ability_localized.bundle_get precedent), so the lookup arrives already computed and this slice never re-derives it.'),
    }
    localized_outputs = {
        'localized': a('String', FORMULA, 'The localized name (Team.java:136): the bundle value when the key exists, else the team name -- I18NBundle.get(key, def) is `has(key) ? get(key) : def` (arc-core I18NBundle.java:412-414); only a missing key falls back to the name, an empty bundle value passes through.'),
    }
    return localized_inputs, localized_outputs


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
    localized_inputs, localized_outputs = definitions()

    entries = [
        ('N2494', LOCALIZED_OWNER, 'source_team_localized_state', TEAM, 'mindustry.game.Team', JAVA_METHOD, localized_inputs, localized_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2096 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Team.localized() state from Team.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Team.localized() state from Team.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2494'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2494', dict(status='done', java_source=TEAM, java_class='mindustry.game.Team', java_method=JAVA_METHOD, godot_owner=LOCALIZED_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2494'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
