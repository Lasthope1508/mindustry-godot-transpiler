"""Register TeamComp.closestCore() (N2489).

TeamComp.closestCore() (TeamComp.java:31-34) is one slice
(batch C8 slot 2):
    @Nullable
    public CoreBuild closestCore(){
        return state.teams.closestCore(x, y, team);
    }
A pure delegate: the callee Teams.closestCore
(Teams.java:56-58, `return Geometry.findClosest(x, y,
get(team).cores);`) is already ported (N2392,
SourceTeamsRuntimeState.source_teams_closest_core_state),
so its result arrives as the precomputed closest_core
input (the precomputed-input precedent: N2477
buildRotation takes the precomputed unit.rotation(),
N2488 coloredName takes the precomputed localized()).
The delegate never re-runs the Geometry.findClosest
search and never touches the team's cores Array -- the
cores and the find_closest Callable live in N2392. The
@Nullable return passes through whole: null when no
core is near, exactly as the callee returns it -- no
default core, no empty-dict fallback, no guard. The
`x` / `y` / `team` of the call are the entity's own
fields (`@Import float x, y;` TeamComp.java:13, `Team
team = Team.derelict;` :15), so they arrive as
evidence inputs (team by id, the N2099 cheating
precedent). One GD function on the existing file
SourceRulesRuntimeState.gd (home of N2099
TeamComp.cheating), placed right after
source_team_cheating_state because cheating()
(:17-19) comes before closestCore() (:31-34) in
TeamComp.java (inFogTo :21-23 and core() :27-29 are
unported, so cheating is the nearest ported neighbour
above it). NO twin-register: the body literal is a
0-hit in ledger exact_exprs (main-thread verified);
the registry closest_core hits are the callee's own
symbols (N2392), not this method. One slice source:
TeamComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
PROOF = '/root/C07TeamCompClosestCoreProof'
CLOSEST_CORE_OWNER = 'SourceRulesRuntimeState.source_team_comp_closest_core_state'
TESTS = ['test_c07_team_comp_closest_core_registration', 'test_all_c07_team_comp_closest_core_input_evidence_is_exact', 'test_team_comp_closest_core_state', 'test_reference_graph_and_actual_c07_team_comp_closest_core']
# The 1 slice source the N2489 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/TeamComp.java',
]
FORMULA = '        return state.teams.closestCore(x, y, team);'
EXACT_EXPRS = [
    'abstract class TeamComp implements Posc{',
    '    @Import float x, y;',
    '    Team team = Team.derelict;',
    '    @Nullable',
    '    public CoreBuild closestCore(){',
    FORMULA,
]
JAVA_METHOD = 'TeamComp.closestCore()'

# DEFERRED is defined locally (the N2487 lesson: never
# import a DEFERRED list from another register script --
# the N2416 list had ballooned with other families'
# entries). Exactly 5 entries.
DEFERRED = [
    'TeamComp.core() (TeamComp.java:27-29) is NOT in this slice: `return team.core();` delegates to Team.core(), already ported -- the thin delegate waits for its own slice (backup B of the C8 batch).',
    'TeamComp.closestEnemyCore() (TeamComp.java:37-39) is NOT in this slice: `return state.teams.closestEnemyCore(x, y, team);` delegates to Teams.closestEnemyCore, already ported N2354 -- the sibling delegate waits for its own slice (N2490, the next slot of the C8 batch).',
    'TeamComp.inFogTo(Team viewer) (TeamComp.java:21-23) is NOT in this slice: `return this.team != viewer && !fogControl.isVisible(viewer, x, y);` needs the fogControl.isVisible live check -- it waits for its own slice.',
    'TeamComp.closestCore() Windows Godot proof -- debt in GOAL.md section 5: the N2489 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Teams.closestCore (Teams.java:56-58) is the callee, already ported N2392: the closest_core input is the precomputed result of source_teams_closest_core_state -- the cores Array and the Geometry.findClosest Callable live in N2392 and are never re-implemented here; this slice passes the value through only.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    closest_inputs = {
        'x': a('float', '    @Import float x, y;', 'The query x (TeamComp.java:13, `    @Import float x, y;`): the entity position x passed straight to state.teams.closestCore -- evidence of the call, the search itself lives in the N2392 callee.'),
        'y': a('float', '    @Import float x, y;', 'The query y (TeamComp.java:13, `    @Import float x, y;`): the entity position y passed straight to state.teams.closestCore -- evidence of the call, the search itself lives in the N2392 callee.'),
        'team_id': a('int', '    Team team = Team.derelict;', 'The team id (TeamComp.java:15, `    Team team = Team.derelict;`, default derelict): the entity team passed to state.teams.closestCore -- by id, the N2099 cheating precedent; evidence of the call.'),
        'closest_core': a('Variant', FORMULA, 'The precomputed callee result (TeamComp.java:33, `        return state.teams.closestCore(x, y, team);`): whatever Teams.closestCore returns -- the nearest CoreBuild ref, or null (the @Nullable return, TeamComp.java:31) when no core is near. The value arrives already computed (N2392 owns the search); this slice never re-derives it.'),
    }
    closest_outputs = {
        'closest_core': a('Variant', FORMULA, 'The closest core (TeamComp.java:33): the precomputed callee result passed through whole -- a CoreBuild ref, or null (the @Nullable return) when no core is near; no default, no fallback, no guard.'),
    }
    return closest_inputs, closest_outputs


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
    closest_inputs, closest_outputs = definitions()

    entries = [
        ('N2489', CLOSEST_CORE_OWNER, 'source_team_comp_closest_core_state', TEAM_COMP, 'mindustry.entities.comp.TeamComp', JAVA_METHOD, closest_inputs, closest_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TeamComp.closestCore() state from TeamComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TeamComp.closestCore() state from TeamComp.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2489'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2489', dict(status='done', java_source=TEAM_COMP, java_class='mindustry.entities.comp.TeamComp', java_method=JAVA_METHOD, godot_owner=CLOSEST_CORE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2489'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
