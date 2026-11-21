"""Register Teams.updateActive()+Teams() (N2399).

Teams.updateActive()+Teams()
(Teams.java:135-141 + :34-36,
`TeamData data = get(team);` /
`active.add(get(Team.crux));`) is one grouped slice: two methods
of one active-list lifecycle -- the ctor seeds active with
crux, updateActive registers a team in active when needed --
main-thread decision 2026-11-22, batch 24 slot 3 (KEEP
updateActive+ctor, do NOT switch to destroyPayload --
destroyPayload is a @Remote static, its C07 scope is
undecided, decided separately in a later batch; the N2380
seven-method / N2374 five-accessor group precedent). Two GD
functions on SourceTeamsRuntimeState.gd, one ledger entry,
one owner per function (the N2380 multi-function precedent;
the N2378 lesson: a contract owner must be an actual GD
function, so the group label
`source_teams_update_active_group_state` is NOT registered
as an owner -- the ledger godot_owner is the first function
owner, `source_teams_update_active_state`).

Callees -- NOT re-registered as distinguishing exprs:
- `if(data.active() && !active.contains(data)){` /
  `active.add(data);` / `updateEnemies();` -- already the
  exact_exprs of N2074/N2075; the guard / add / enemies
  update ARE implemented here (the file's _teams_active /
  _teams_update_enemies helpers are those callees) but the
  exprs are cited as evidence only, never re-registered.
  No field evidence below cites them either.
- `get(team)` / `get(Team.crux)` -- internal
  self-references (the get() inside the group), not outside
  exprs; the get() call may create the team's entry, so
  teams_state is in/out.
- `Team.crux` -- a Team const (not ported), arrives as the
  explicit crux_team_id param (crux id 2, Team.java:41).
- `destroyPayload()` -- NOT in this slice at all (batch 24
  slot 3 decision above).

Seven new result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_derelict import DEFERRED as N2395_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsUpdateActiveProof'
UPDATE_ACTIVE_OWNER = 'SourceTeamsRuntimeState.source_teams_update_active_state'
CTOR_OWNER = 'SourceTeamsRuntimeState.source_teams_default_constructor_state'
TESTS = ['test_c07_teams_update_active_registration', 'test_all_c07_teams_update_active_input_evidence_is_exact', 'test_teams_update_active_state', 'test_reference_graph_and_actual_c07_teams_update_active']
# The 1 slice source the N2399 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'TeamData data = get(team);',
    'active.add(get(Team.crux));',
]

# DEFERRED is carried from the N2395 register script via import --
# never retyped. All N2395 entries are carried verbatim (the
# Game chain, the B/C notes, and N2395's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2399's Windows proof debt.
DEFERRED = list(N2395_DEFERRED) + [
    'Teams.updateActive()+Teams() Windows Godot proof -- debt in GOAL.md section 5, same as N2395: the N2399 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_active_inputs = {
        'teams_state': a('Dictionary', 'TeamData data = get(team);', 'The teams state (Teams.updateActive, Teams.java:136, `TeamData data = get(team);`): the family-convention first arg; it carries the "teams" map team_id -> TeamData dict (Java `map`, Teams.java:28, `private TeamData[] map = new TeamData[256];`) and the "active" list -- get() WRITES teams_state["teams"][team_id] when the team is missing, and the guard branch WRITES teams_state["active"], so teams_state is an in/out param here.'),
        'team_id': a('int', 'public void updateActive(Team team){', 'The team asking (Teams.java:135, `public void updateActive(Team team){`): team.id indexes the map; teams are compared by team_id, not the Team enum.'),
    }
    update_active_outputs = {
        'active_changed': a('bool', '//register in active list if needed', 'Whether the team was newly registered (Teams.java:137, `//register in active list if needed`): true only when the team is active and was not in the active list yet -- the guard branch ran and updateEnemies() refreshed the enemies map; false when the team was already active or is inactive.'),
        'active': a('Array', 'TeamData data = get(team);', 'The active list after (Teams.java:136, `TeamData data = get(team);`): the team ids in the active list, in registration order -- the team id appended when the guard branch ran, unchanged otherwise.'),
        'enemies_by_team': a('Dictionary', 'public void updateActive(Team team){', 'The enemies map after (Teams.java:135, `public void updateActive(Team team){`): team_id -> the other active team ids -- refreshed by updateEnemies() (Teams.java:140, already the exact_expr of N2074/N2075, called here as evidence only) when the guard branch ran, else the current map.'),
        'teams_state': a('Dictionary', 'TeamData data = get(team);', 'The updated teams_state (Teams.java:136, `TeamData data = get(team);`): the same in/out Dictionary -- the team entry created by get() when missing, the active list rewritten when the guard branch ran, and each active team\'s core_enemies rewritten by updateEnemies().'),
    }
    ctor_inputs = {
        'teams_state': a('Dictionary', 'active.add(get(Team.crux));', 'The teams state (Teams(), Teams.java:35, `active.add(get(Team.crux));`): the family-convention first arg; it carries the "teams" map and the "active" list -- get(Team.crux) WRITES teams_state["teams"][crux_team_id] when the crux entry is missing, and the ctor WRITES teams_state["active"], so teams_state is an in/out param here.'),
        'crux_team_id': a('int', 'active.add(get(Team.crux));', 'The crux team id (Teams.java:35, `active.add(get(Team.crux));`): Team.crux is a Team const (not ported), so it arrives as an explicit param (crux id 2, Team.java:41, per the file header comment) -- the team seeded into the active list by the default constructor.'),
    }
    ctor_outputs = {
        'team_data': a('Dictionary', 'active.add(get(Team.crux));', 'The crux TeamData (Teams.java:35, `active.add(get(Team.crux));`): the TeamData dict get(Team.crux) returned -- the existing entry when present, otherwise the fresh empty TeamData shape ({"cores": [], "buildings": [], "units": [], "core_enemies": []}).'),
        'active': a('Array', 'active.add(get(Team.crux));', 'The active list after (Teams.java:35, `active.add(get(Team.crux));`): the team ids in the active list -- Java Seq.add appends unconditionally, so the crux id is appended even if already present, exactly as the Java ctor does on a fresh Teams (empty active).'),
        'teams_state': a('Dictionary', 'active.add(get(Team.crux));', 'The updated teams_state (Teams.java:35, `active.add(get(Team.crux));`): the same in/out Dictionary -- the crux entry created by get() when missing and the active list with the crux id appended.'),
    }
    return ((update_active_inputs, update_active_outputs), (ctor_inputs, ctor_outputs))


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
    pairs = definitions()

    entries = [
        ('N2399', UPDATE_ACTIVE_OWNER, 'source_teams_update_active_state', TEAMS, 'mindustry.game.Teams', 'Teams.updateActive()', pairs[0][0], pairs[0][1], True, 'Dictionary'),
        ('N2399', CTOR_OWNER, 'source_teams_default_constructor_state', TEAMS, 'mindustry.game.Teams', 'Teams()', pairs[1][0], pairs[1][1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams updateActive()/default-constructor state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams updateActive()/default-constructor state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: updateActive outputs; ctor
    # outputs.
    by_slice['N2399'] = [
        'source_teams_update_active_state_result.active_changed',
        'source_teams_update_active_state_result.active',
        'source_teams_update_active_state_result.enemies_by_team',
        'source_teams_update_active_state_result.teams_state',
        'source_teams_default_constructor_state_result.team_data',
        'source_teams_default_constructor_state_result.active',
        'source_teams_default_constructor_state_result.teams_state',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2399', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='Teams.updateActive()/Teams()', godot_owner=UPDATE_ACTIVE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2399'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
