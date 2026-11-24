"""Register Team.compareTo(Team) (N2463).

Team.compareTo(Team) (Team.java:159-162) is one slice (batch 46
slot 3):
    @Override
    public int compareTo(Team team){
        return Integer.compare(id, team.id);
    }
The field `id` is `public final int` (Team.java:18) and Team
implements Comparable<Team> (Team.java:16) -- the @Override
(:159) marks this as the Comparable implementation. The trap
is that Integer.compare returns exactly -1, 0 or 1 -- never
the difference of the ids: 0 vs 255 is -1, not -255. A port
that returns `id - other_id` is wrong (and risks int overflow
in Java). GDScript ints are 64-bit signed, so a ternary
comparison reproduces Integer.compare for every int,
including negatives. The function takes the two team ids
directly -- unlike N2456 Team.get, it needs no all_teams
array. One GD function on the existing file
SourceTeamsRuntimeState.gd (home of N2456 Team.get), placed
right after source_team_get_state because Team.get() (:58-60)
comes before compareTo() (:159-162) in Team.java. One slice
source: Team.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM = 'core/src/mindustry/game/Team.java'
PROOF = '/root/C07TeamCompareToProof'
COMPARE_TO_OWNER = 'SourceTeamsRuntimeState.source_team_compare_to_state'
TESTS = ['test_c07_team_compare_to_registration', 'test_all_c07_team_compare_to_input_evidence_is_exact', 'test_team_compare_to_state', 'test_reference_graph_and_actual_c07_team_compare_to']
# The 1 slice source the N2463 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Team.java',
]
FORMULA = '        return Integer.compare(id, team.id);'
EXACT_EXPRS = [
    '    public int compareTo(Team team){',
    FORMULA,
    '    public final int id;',
    'public class Team implements Comparable<Team>, Senseable{',
]
JAVA_METHOD = 'Team.compareTo(Team)'

DEFERRED = [
    'Team.sense() / senseObject() -- a switch on LAccess, needs the sensor enum; left for a later slice.',
    'Team.compareTo() Windows Godot proof -- debt in GOAL.md section 5: the N2463 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM, **extra):
        return backed(typ, source, expr, rule, **extra)

    compare_inputs = {
        'team_id': a('int', FORMULA, 'The id of the team being compared (Team.java:160, `compareTo(Team team)`; `id` is `public final int` :18).'),
        'other_team_id': a('int', FORMULA, 'The id of the team to compare against (Team.java:161, `team.id` in `Integer.compare(id, team.id)`).'),
    }
    compare_outputs = {
        'comparison': a('int', FORMULA, 'The comparison result (Team.java:159-162): exactly -1, 0 or 1 -- never the difference of the ids, so 0 vs 255 is -1, not -255.'),
    }
    return compare_inputs, compare_outputs


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
    compare_inputs, compare_outputs = definitions()

    entries = [
        ('N2463', COMPARE_TO_OWNER, 'source_team_compare_to_state', TEAM, 'mindustry.game.Team', JAVA_METHOD, compare_inputs, compare_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Team.compareTo() state from Team.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Team.compareTo() state from Team.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2463'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2463', dict(status='done', java_source=TEAM, java_class='mindustry.game.Team', java_method=JAVA_METHOD, godot_owner=COMPARE_TO_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2463'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
