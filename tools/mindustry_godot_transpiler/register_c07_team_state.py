"""Register Team.items()+data()+core()+active()+isAlive()+isOnlyAI()+needsFlowField()+cores() (N2450).

Team.items()+data()+core()+active()+isAlive()+isOnlyAI()
+needsFlowField()+cores() (Team.java:83-133,
`public ItemModule items(){` /
`return core() == null ? ItemModule.empty : core().items;` /
`public TeamData data(){` /
`return state.teams.get(this);` /
`@Nullable` /
`public CoreBuild core(){` /
`return data().core();` /
`public boolean active(){` /
`return state.teams.isActive(this);` /
`public boolean isAlive(){` /
`return data().isAlive();` /
`public boolean isOnlyAI(){` /
`return isAI() && data().players.size == 0;` /
`public boolean needsFlowField(){` /
`return isAI() && !rules().rtsAi;` /
`public Seq<CoreBuild> cores(){` /
`return state.teams.cores(this);`) is one grouped slice:
eight one-line forwards, one record, eight java_method
entries, one shared owner -- main-thread decision
2026-11-23 (the N2390/N2395 group precedent). data()
calls source_teams_get_state (internal self-reference,
not an outside expr); core()/isAlive() go through the
liveness func (N2374); active()/cores() go through the
Teams funcs already live (source_teams_is_active_state,
source_teams_cores_state). isAI() is N2124 (another
file), so it arrives as the explicit is_ai input;
rules().rtsAi arrives as the explicit rts_ai input.
items() computes core() once and reuses it (Java calls
core() twice in one expr).

NOT registered: isAI() (:112-114) + activateUnitFactories()
(:127-129) -- both are already the exact_exprs of N2124;
rules() (:89) -- its only line is the twin exact_expr of
N2099+N2107, and needsFlowField takes rts_ai as an
explicit input instead; localized() (:135-137) +
coloredName() (:139-141) -- they wait for the i18n
decision (batch 43+).

Nine result symbols: the eight domain keys plus the
teams_state housekeeping symbol (the N2380 precedent:
get/cores/is_active all return it). One slice source:
Team.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_count_payload_branch import DEFERRED as N2415_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAM = 'core/src/mindustry/game/Team.java'
PROOF = '/root/C07TeamStateProof'
OWNER = 'SourceTeamsRuntimeState.source_team_state'
TESTS = ['test_c07_team_state_registration', 'test_all_c07_team_state_input_evidence_is_exact', 'test_team_state', 'test_reference_graph_and_actual_c07_team_state']
# The 1 slice source the N2450 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Team.java',
]
EXACT_EXPRS = [
    'public class Team implements Comparable<Team>, Senseable{',
    'public ItemModule items(){',
    'return core() == null ? ItemModule.empty : core().items;',
    'public TeamData data(){',
    'return state.teams.get(this);',
    '@Nullable',
    'public CoreBuild core(){',
    'return data().core();',
    'public boolean active(){',
    'return state.teams.isActive(this);',
    'public boolean isAlive(){',
    'return data().isAlive();',
    'public boolean isOnlyAI(){',
    'return isAI() && data().players.size == 0;',
    'public boolean needsFlowField(){',
    'return isAI() && !rules().rtsAi;',
    'public Seq<CoreBuild> cores(){',
    'return state.teams.cores(this);',
]

# DEFERRED is carried from the N2415 register script via import --
# never retyped. The Teams DEFERRED chain split: N2415 (305
# entries, the to_string/count branch) and N2430 (298 entries,
# the update_team_stats branch) each lack entries the other
# has, so this register carries the UNION: all N2415 entries
# plus the one N2430-only entry (its Windows proof debt),
# carried verbatim from the N2430 ledger record. Two entries
# are added: the N2430 debt (chain repair) and N2450's own
# Windows proof debt.
N2430_DEBT = 'Teams.updateTeamStats() leftover legs Windows Godot proof -- debt in GOAL.md section 5, same as N2383: the N2430 proof runs headless on Linux here and waits for a Windows Godot run.'
DEFERRED = list(N2415_DEFERRED) + [
    N2430_DEBT,
    'Team.items()+data()+core()+active()+isAlive()+isOnlyAI()+needsFlowField()+cores() Windows Godot proof -- debt in GOAL.md section 5, same as N2415: the N2450 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAM, **extra):
        return backed(typ, source, expr, rule, **extra)

    team_inputs = {
        'teams_state': a('Dictionary', 'return state.teams.get(this);', 'The Teams manager state (Team.java:93, `return state.teams.get(this);`): the teams map lives in teams_state["teams"] (team_id -> TeamData dict); get() may create a missing entry, so teams_state is in/out.'),
        'team_id': a('int', 'return state.teams.get(this);', 'The Team id (Team.java:93, `return state.teams.get(this);`): this team, used as the key into the teams map.'),
        'is_ai': a('bool', 'return isAI() && data().players.size == 0;', 'Whether this team is AI-controlled (Team.java:118, `return isAI() && data().players.size == 0;`): isAI() is N2124 (another file), so its result arrives as an explicit bool input (the N2330 param precedent).'),
        'rts_ai': a('bool', 'return isAI() && !rules().rtsAi;', 'Whether this team\'s rules use the RTS AI (Team.java:123, `return isAI() && !rules().rtsAi;`): rules().rtsAi arrives as an explicit bool input; rules() itself is the twin exact_expr of N2099+N2107 and is not re-ported.'),
    }
    team_outputs = {
        'items': a('Dictionary', 'return core() == null ? ItemModule.empty : core().items;', 'The core items for this team (Team.java:84, `return core() == null ? ItemModule.empty : core().items;`): the first core\'s items dict, or {} when there is no core (ItemModule.empty) or the core ref carries no items dict. core() is computed once and reused.'),
        'data': a('Dictionary', 'return state.teams.get(this);', 'The TeamData dict for this team (Team.java:93, `return state.teams.get(this);`): the per-team dict from the teams map (created when missing).'),
        'core': a('Variant', 'return data().core();', 'The first core, or null (Team.java:98, `return data().core();`): data().core() is the liveness core (Teams.java:465, `return cores.isEmpty() ? null : cores.first();`) -- null when the team has no cores (the @Nullable return, Team.java:96).'),
        'active': a('bool', 'return state.teams.isActive(this);', 'Whether this team has any buildings on this map (Team.java:103, `return state.teams.isActive(this);`): the Teams.isActive result (in waves mode always true for the enemy team).'),
        'is_alive': a('bool', 'return data().isAlive();', 'Whether this team has any active cores (Team.java:108, `return data().isAlive();`): data().isAlive() delegates to hasCore() (Teams.java:456), so this is true exactly when the cores Array is non-empty -- not the same as active().'),
        'is_only_ai': a('bool', 'return isAI() && data().players.size == 0;', 'Whether this team is solely comprised of AI (Team.java:118, `return isAI() && data().players.size == 0;`): true only when is_ai is set and the TeamData dict has no players.'),
        'needs_flow_field': a('bool', 'return isAI() && !rules().rtsAi;', 'Whether this team needs a flow field for wave pathfinding (Team.java:123, `return isAI() && !rules().rtsAi;`): true only when is_ai is set and rts_ai is not set.'),
        'cores': a('Array', 'return state.teams.cores(this);', 'The team cores as opaque refs (Team.java:132, `return state.teams.cores(this);`): the cores seq from the TeamData dict, in order, so core() can return the first.'),
        'teams_state': a('Dictionary', 'return state.teams.get(this);', 'The updated teams state (Team.java:93, `return state.teams.get(this);`): get() may create the team\'s entry, so the caller gets the mutated state back (the N2380 precedent).'),
    }
    return (team_inputs, team_outputs)


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
    inputs_outputs = [definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
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
    (team_inputs, team_outputs) = definitions()

    entries = [
        ('N2450', OWNER, 'source_team_state', TEAM, 'mindustry.game.Team', 'Team.items()/data()/core()/active()/isAlive()/isOnlyAI()/needsFlowField()/cores()', team_inputs, team_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Team.items()+data()+core()+active()+isAlive()+isOnlyAI()+needsFlowField()+cores() state from Team.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Team.items()+data()+core()+active()+isAlive()+isOnlyAI()+needsFlowField()+cores() state from Team.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: items, data, core, active,
    # is_alive, is_only_ai, needs_flow_field, cores, teams_state.
    by_slice['N2450'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2450', dict(status='done', java_source=TEAM, java_class='mindustry.game.Team', java_method='Team.items()/data()/core()/active()/isAlive()/isOnlyAI()/needsFlowField()/cores()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2450'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
