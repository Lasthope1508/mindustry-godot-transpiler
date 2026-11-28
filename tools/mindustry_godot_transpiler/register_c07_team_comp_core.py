"""Register TeamComp.core() (N2491).

TeamComp.core() (TeamComp.java:27-29) is one slice
(batch C8 slot 1):
    @Nullable
    public CoreBuild core(){
        return team.core();
    }
A pure delegate: the callee Team.core()
(Team.java:88-90, `return data().core();`) is
already ported (N2450, SourceTeamsRuntimeState
.source_team_state, whose `core` result is the
first core of the team's data or null), so its
result arrives as the precomputed core input (the
precomputed-input precedent: N2477 buildRotation
takes the precomputed unit.rotation(), N2488
coloredName takes the precomputed localized(),
N2489 closestCore and N2490 closestEnemyCore take
the precomputed callee result). The delegate never
re-runs the data().core() lookup and never touches
the team's cores -- the liveness first-core-or-null
lives in N2450 (via N2374 TeamData.core). The
@Nullable return passes through whole: null when
the team has no core, exactly as the callee
returns it -- no default core, no empty-dict
fallback, no guard. The `x` / `y` / `team` of the
call are the entity's own fields (`@Import float
x, y;` TeamComp.java:13, `Team team =
Team.derelict;` :15), so they arrive as evidence
inputs (team by id, the N2099 cheating
precedent). One GD function on the existing file
SourceRulesRuntimeState.gd (home of N2099
TeamComp.cheating, N2489 TeamComp.closestCore and
N2490 TeamComp.closestEnemyCore), placed right
BEFORE source_team_comp_closest_core_state
because core() (:27-29) comes before
closestCore() (:31-34) in TeamComp.java. NOT a
twin-register: the body literal is a 0-hit in
ledger exact_exprs (main-thread verified). The
signature `public CoreBuild core(){` also appears
in N2374 (TeamData.core, `return cores.isEmpty()
? null : cores.first();`) and N2450 (Team.core,
`return data().core();`) -- a generic name
collision only, the bodies are different methods
of different classes, so no twin approval is
needed. One slice source: TeamComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
PROOF = '/root/C07TeamCompCoreProof'
CORE_OWNER = 'SourceRulesRuntimeState.source_team_comp_core_state'
TESTS = ['test_c07_team_comp_core_registration', 'test_all_c07_team_comp_core_input_evidence_is_exact', 'test_team_comp_core_state', 'test_reference_graph_and_actual_c07_team_comp_core']
# The 1 slice source the N2491 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/TeamComp.java',
]
FORMULA = '        return team.core();'
EXACT_EXPRS = [
    'abstract class TeamComp implements Posc{',
    '    @Import float x, y;',
    '    Team team = Team.derelict;',
    '    @Nullable',
    '    public CoreBuild core(){',
    FORMULA,
]
JAVA_METHOD = 'TeamComp.core()'

# DEFERRED is defined locally (the N2487 lesson: never
# import a DEFERRED list from another register script --
# the N2416 list had ballooned with other families'
# entries). Exactly 5 entries.
DEFERRED = [
    'TeamComp.closestCore() (TeamComp.java:31-34) is NOT in this slice: already ported as N2489 (source_team_comp_closest_core_state, the sibling delegate right below this function) -- the two delegates share the same file and the same x/y/team evidence, but each owns its own callee result.',
    'TeamComp.closestEnemyCore() (TeamComp.java:36-39) is NOT in this slice: already ported as N2490 (source_team_comp_closest_enemy_core_state, the sibling delegate below closestCore) -- the enemy-core scan lives in the N2354 callee and is never re-implemented here.',
    'TeamComp.inFogTo(Team viewer) (TeamComp.java:21-23) is NOT in this slice: `return this.team != viewer && !fogControl.isVisible(viewer, x, y);` needs the fogControl.isVisible live check -- it waits for its own slice (backup A of the C8 batch 2).',
    'TeamComp.core() Windows Godot proof -- debt in GOAL.md section 5: the N2491 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Team.core() (Team.java:88-90) is the callee, already ported N2450: the core input is the precomputed result of source_team_state -- the data().core() lookup and the first-core-or-null liveness live in N2450 (via N2374 TeamData.core) and are never re-implemented here; this slice passes the value through only.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    core_inputs = {
        'x': a('float', '    @Import float x, y;', 'The query x (TeamComp.java:13, `    @Import float x, y;`): the entity position x -- evidence of the calling entity, the N2099 cheating precedent; team.core() itself takes no position, the fields pin which entity\'s team is queried.'),
        'y': a('float', '    @Import float x, y;', 'The query y (TeamComp.java:13, `    @Import float x, y;`): the entity position y -- evidence of the calling entity, the N2099 cheating precedent; team.core() itself takes no position, the fields pin which entity\'s team is queried.'),
        'team_id': a('int', '    Team team = Team.derelict;', 'The team id (TeamComp.java:15, `    Team team = Team.derelict;`, default derelict): the entity team whose core() is called -- by id, the N2099 cheating precedent; evidence of the call.'),
        'core': a('Variant', FORMULA, 'The precomputed callee result (TeamComp.java:28, `        return team.core();`): whatever Team.core() returns -- the team\'s CoreBuild ref, or null (the @Nullable return, TeamComp.java:26) when the team has no core. The value arrives already computed (N2450 owns the data().core() lookup); this slice never re-derives it.'),
    }
    core_outputs = {
        'core': a('Variant', FORMULA, 'The team core (TeamComp.java:28): the precomputed callee result passed through whole -- a CoreBuild ref, or null (the @Nullable return) when the team has no core; no default, no fallback, no guard.'),
    }
    return core_inputs, core_outputs


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
    core_inputs, core_outputs = definitions()

    entries = [
        ('N2491', CORE_OWNER, 'source_team_comp_core_state', TEAM_COMP, 'mindustry.entities.comp.TeamComp', JAVA_METHOD, core_inputs, core_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TeamComp.core() state from TeamComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TeamComp.core() state from TeamComp.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2491'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2491', dict(status='done', java_source=TEAM_COMP, java_class='mindustry.entities.comp.TeamComp', java_method=JAVA_METHOD, godot_owner=CORE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2491'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
