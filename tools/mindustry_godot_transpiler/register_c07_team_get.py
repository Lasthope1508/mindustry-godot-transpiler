"""Register Team.get(int) (N2456).

Team.get(int) (Team.java:58-60) is one slice (batch 44 slot 2):
exactly the 2 distinct body exprs -- `public static Team get(int id){`
(:58) and `return all[((byte)id) & 0xff];` (:59) -- both 0-hit in
ledger, registry and contracts at base fb02806f (1930 slices). The
(byte) cast keeps only the low 8 bits, then & 0xff makes the index
unsigned, so the id wraps modulo 256: 256 -> 0, -1 -> 255, -256 -> 0,
257 -> 1. GD takes the already-built 256-entry Team.all array
(Team.java:27-28) as an Array input (option (A) data-driven,
precedent N2453/N2455) and does not build the 256 teams itself: the
static init at Team.java:43-56 (with its Mathf.rand seed) is NOT
ported and belongs to a later slice -- this slice does NOT claim the
256 teams are constructed. Call-sites of get() (BuildingComp.setProp,
SpawnGroup.read) are NOT registered here; they belong to their own
owners, later slices. One GD function on the existing file
SourceTeamsRuntimeState.gd (opened long before N2450, extended by the
N2450 Team group). One slice source: Team.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM = 'core/src/mindustry/game/Team.java'
PROOF = '/root/C07TeamGetProof'
TEAM_GET_OWNER = 'SourceTeamsRuntimeState.source_team_get_state'
TESTS = ['test_c07_team_get_registration', 'test_all_c07_team_get_input_evidence_is_exact', 'test_team_get_state', 'test_reference_graph_and_actual_c07_team_get']
# The 1 slice source the N2456 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Team.java',
]
EXACT_EXPRS = [
    'public static Team get(int id){',
    'return all[((byte)id) & 0xff];',
]
JAVA_METHOD = 'Team.get(int)'

DEFERRED = [
    'The static init creating the 256 teams (Team.java:43-56, `Mathf.rand.setSeed(8)` + the loop filling `all[7..255]` with placeholder teams) -- NOT ported here; GD takes the already-built 256-entry Team.all array as data input (option (A) data-driven), and the construction belongs to a later slice.',
    'The call-sites of Team.get(int) -- `BuildingComp.setProp` (java_expr `Team team = Team.get((int)value);`, already in the registry as a call-site, not a body expr) and `SpawnGroup.read` (Team.java call at SpawnGroup.java:147) -- not in this slice; they belong to their own owners, later slices.',
    'Team.get(int) Windows Godot proof -- debt in GOAL.md section 5: the N2456 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM, **extra):
        return backed(typ, source, expr, rule, **extra)

    expr = 'return all[((byte)id) & 0xff];'
    team_get_inputs = {
        'all_teams': a('Array', 'public static final Team[] all = new Team[256];', 'The 256 registered teams (Team.java:27-28, `/** All 256 registered teams. */ public static final Team[] all = new Team[256];`): GD takes the already-built array as an Array input and indexes it, never constructing the teams itself (option (A) data-driven).'),
    }
    team_get_outputs = {
        'team': a('Variant', expr, 'The team at the wrapped index (Team.java:59, `return all[((byte)id) & 0xff];`): all_teams[((id % 256) + 256) % 256] in GD, the same modulo-256 wrap as the Java (byte) cast + & 0xff for every int, including negatives.'),
        'wrapped_id': a('int', '((byte)id) & 0xff', 'The wrapped index (Team.java:59, `((byte)id) & 0xff`): the low 8 bits of id as an unsigned 0..255 value; 256 -> 0, -1 -> 255, -256 -> 0, 257 -> 1.'),
    }
    return team_get_inputs, team_get_outputs


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
    team_get_inputs, team_get_outputs = definitions()

    entries = [
        ('N2456', TEAM_GET_OWNER, 'source_team_get_state', TEAM, 'mindustry.game.Team', JAVA_METHOD, team_get_inputs, team_get_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Team.get(int) state from Team.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Team.get(int) state from Team.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2456'] = [
        'source_team_get_state_result.team',
        'source_team_get_state_result.wrapped_id',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2456', dict(status='done', java_source=TEAM, java_class='mindustry.game.Team', java_method=JAVA_METHOD, godot_owner=TEAM_GET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2456'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
