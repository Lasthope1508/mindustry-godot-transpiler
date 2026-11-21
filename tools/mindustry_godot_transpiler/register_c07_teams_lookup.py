"""Register Teams lookup group (N2380).

Teams.get()+getOrNull()+playerCores()+cores()+isActive()+canInteract()+getActive()
(Teams.java:97-133,
`public TeamData get(Team team){` /
`var data = map[team.id];` /
`if(data != null){` /
`return data;` /
`return map[team.id] = new TeamData(team);` /
`public @Nullable TeamData getOrNull(Team team){` /
`return map[team.id];` /
`public Seq<CoreBuild> playerCores(){` /
`return get(state.rules.defaultTeam).cores;` /
`public Seq<CoreBuild> cores(Team team){` /
`return get(team).cores;` /
`public boolean isActive(Team team){` /
`return get(team).active();` /
`public boolean canInteract(Team team, Team other){` /
`return team == other || other == Team.derelict;` /
`public Seq<TeamData> getActive(){` /
`active.removeAll(t -> !t.active());` /
`return active;`) is one grouped slice: seven one-to-three-line
lookup methods sharing the one lookup core (`map[team.id]` +
`get(team)`) -- main-thread decision 2026-11-21 (the N2374
five-accessor / N2330 three-method group precedent). Seven
GD functions on SourceTeamsRuntimeState.gd, one ledger
entry, one owner per function (the N2330 multi-function
precedent; the N2378 lesson: a contract owner must be an
actual GD function, so the group label
`source_teams_lookup_state` is NOT registered as an owner
-- the ledger godot_owner is the first function owner,
`source_teams_get_state`).

Callees -- NOT re-registered as distinguishing exprs:
- `TeamData.active()` in isActive()/getActive() -- already
  the exact_expr of N2074/N2075 (PortGame-era); the file's
  `_teams_active` helper is that callee, called as evidence.
- `new TeamData(team)` -- no TeamData constructor ported;
  get() creates the empty TeamData dict shape the file's
  `_teams_data` helper already builds ({"cores": [],
  "buildings": [], "units": [], "core_enemies": []}).
- `get()` called by playerCores/cores/isActive INSIDE the
  group -- internal self-reference, not an outside expr.
- `state.rules.defaultTeam` / `Team.derelict` -- Rules /
  Team const state (not ported), explicit params.

`map` is the teams_state["teams"] dict (team_id ->
TeamData dict); get() WRITES it when the team is missing
(Java `map[team.id] = new TeamData(team)`), so teams_state
is an in/out param there; getOrNull() only READS it (never
creates); getActive() WRITES teams_state["active"] (Java
`active.removeAll(...)` mutates the Seq in place). Thirteen
new result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_team_data_liveness import DEFERRED as N2374_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsLookupProof'
GET_OWNER = 'SourceTeamsRuntimeState.source_teams_get_state'
GET_OR_NULL_OWNER = 'SourceTeamsRuntimeState.source_teams_get_or_null_state'
PLAYER_CORES_OWNER = 'SourceTeamsRuntimeState.source_teams_player_cores_state'
CORES_OWNER = 'SourceTeamsRuntimeState.source_teams_cores_state'
IS_ACTIVE_OWNER = 'SourceTeamsRuntimeState.source_teams_is_active_state'
CAN_INTERACT_OWNER = 'SourceTeamsRuntimeState.source_teams_can_interact_state'
GET_ACTIVE_OWNER = 'SourceTeamsRuntimeState.source_teams_get_active_state'
TESTS = ['test_c07_teams_lookup_registration', 'test_all_c07_teams_lookup_input_evidence_is_exact', 'test_teams_lookup_state', 'test_reference_graph_and_actual_c07_teams_lookup']
# The 1 slice source the N2380 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public class Teams{',
    'public TeamData get(Team team){',
    'var data = map[team.id];',
    'if(data != null){',
    'return data;',
    'return map[team.id] = new TeamData(team);',
    'public @Nullable TeamData getOrNull(Team team){',
    'return map[team.id];',
    'public Seq<CoreBuild> playerCores(){',
    'return get(state.rules.defaultTeam).cores;',
    'public Seq<CoreBuild> cores(Team team){',
    'return get(team).cores;',
    'public boolean isActive(Team team){',
    'return get(team).active();',
    'public boolean canInteract(Team team, Team other){',
    'return team == other || other == Team.derelict;',
    'public Seq<TeamData> getActive(){',
    'active.removeAll(t -> !t.active());',
    'return active;',
]

# DEFERRED is carried from the N2374 register script via import --
# never retyped. All N2374 entries are carried verbatim (the
# Game chain, the B/C notes, and N2374's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2380's Windows proof debt.
DEFERRED = list(N2374_DEFERRED) + [
    'Teams.get()+getOrNull()+playerCores()+cores()+isActive()+canInteract()+getActive() Windows Godot proof -- debt in GOAL.md section 5, same as N2374: the N2380 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    get_inputs = {
        'teams_state': a('Dictionary', 'var data = map[team.id];', 'The teams state (Teams.get, Teams.java:98, `var data = map[team.id];`): the family-convention first arg; it carries the "teams" map team_id -> TeamData dict (Java `map`, Teams.java:28, `private TeamData[] map = new TeamData[256];`) -- get() WRITES teams_state["teams"][team_id] when the team is missing (Java `map[team.id] = new TeamData(team)`), so teams_state is an in/out param here.'),
        'team_id': a('int', 'public TeamData get(Team team){', 'The team asking (Teams.java:97, `public TeamData get(Team team){`): team.id indexes the map; teams are compared by team_id, not the Team enum.'),
    }
    get_outputs = {
        'team_data': a('Dictionary', 'return map[team.id] = new TeamData(team);', 'The TeamData dict for the team (Teams.java:101-102, `return map[team.id] = new TeamData(team);`): the existing entry when present, or a freshly created empty TeamData dict {"cores": [], "buildings": [], "units": [], "core_enemies": []} (the _teams_data empty shape) when the team had none -- new TeamData(team) in Java starts with empty cores/buildings/units.'),
        'created': a('bool', 'if(data != null){', 'Whether get() had to create the TeamData (Teams.java:99, `if(data != null){`): false when map[team.id] was non-null (the `return data;` branch, Teams.java:100), true when it took the else branch and stored a new TeamData.'),
        'teams_state': a('Dictionary', 'return map[team.id] = new TeamData(team);', 'The updated teams state (Teams.java:102, `return map[team.id] = new TeamData(team);`): identical when the team existed, carrying the new empty TeamData entry when created -- Java writes map[team.id].'),
    }
    get_or_null_inputs = {
        'teams_state': a('Dictionary', 'return map[team.id];', 'The teams state (Teams.getOrNull, Teams.java:107, `return map[team.id];`): read-only here -- getOrNull() never creates an entry, unlike get().'),
        'team_id': a('int', 'public @Nullable TeamData getOrNull(Team team){', 'The team asking (Teams.java:106, `public @Nullable TeamData getOrNull(Team team){`): team.id indexes the map.'),
    }
    get_or_null_outputs = {
        'team_data': a('Variant', 'return map[team.id];', 'The TeamData dict, or null (Teams.java:107, `return map[team.id];`): null when the team has no entry (the @Nullable return, Teams.java:106) -- the caller must null-check before using it, and the missing entry is NOT created.'),
    }
    player_cores_inputs = {
        'teams_state': a('Dictionary', 'return get(state.rules.defaultTeam).cores;', 'The teams state (Teams.playerCores, Teams.java:111, `return get(state.rules.defaultTeam).cores;`): the get() inside may create the default team entry, so teams_state is in/out.'),
        'default_team_id': a('int', 'return get(state.rules.defaultTeam).cores;', 'state.rules.defaultTeam as an explicit param (Teams.java:111, `return get(state.rules.defaultTeam).cores;`): Rules is not ported, so the default team arrives as its team id (the N2330 param precedent).'),
    }
    player_cores_outputs = {
        'cores': a('Array', 'return get(state.rules.defaultTeam).cores;', 'The default team cores (Teams.java:111, `return get(state.rules.defaultTeam).cores;`): the .cores Array of the default team TeamData -- empty when the default team has no cores (get() creates the entry first, so this never nulls).'),
        'teams_state': a('Dictionary', 'return get(state.rules.defaultTeam).cores;', 'The updated teams state (Teams.java:111, `return get(state.rules.defaultTeam).cores;`): the get() inside may have created the default team entry.'),
    }
    cores_inputs = {
        'teams_state': a('Dictionary', 'return get(team).cores;', 'The teams state (Teams.cores, Teams.java:116, `return get(team).cores;`): the get() inside may create the team entry, so teams_state is in/out.'),
        'team_id': a('int', 'public Seq<CoreBuild> cores(Team team){', 'The team asking (Teams.java:115, `public Seq<CoreBuild> cores(Team team){`): team.id indexes the map.'),
    }
    cores_outputs = {
        'cores': a('Array', 'return get(team).cores;', 'The team cores (Teams.java:116, `return get(team).cores;`): the .cores Array of the team TeamData -- empty when the team has no cores (get() creates the entry first, so this never nulls). Do not modify: the /** Do not modify! */ note on cores() (Teams.java:114).'),
        'teams_state': a('Dictionary', 'return get(team).cores;', 'The updated teams state (Teams.java:116, `return get(team).cores;`): the get() inside may have created the team entry.'),
    }
    is_active_inputs = {
        'teams_state': a('Dictionary', 'return get(team).active();', 'The teams state (Teams.isActive, Teams.java:122, `return get(team).active();`): carries the "rules" ({wave_team, waves}) the active() callee reads, and the get() inside may create the team entry, so teams_state is in/out.'),
        'team_id': a('int', 'public boolean isActive(Team team){', 'The team asking (Teams.java:120, `public boolean isActive(Team team){`): team.id indexes the map.'),
    }
    is_active_outputs = {
        'is_active': a('bool', 'return get(team).active();', 'Whether the team is active (Teams.java:122, `return get(team).active();`): get(team).active() -- active() is TeamData.active() (Teams.java:446-448), already the exact_expr of N2074/N2075 and the file _teams_active helper, called here as callee evidence only; the enemy wave team is always active via the wave condition in active() (the comment at Teams.java:121).'),
        'teams_state': a('Dictionary', 'return get(team).active();', 'The updated teams state (Teams.java:122, `return get(team).active();`): the get() inside may have created the team entry.'),
    }
    can_interact_inputs = {
        'team_id': a('int', 'public boolean canInteract(Team team, Team other){', 'The team asking (Teams.java:125, `public boolean canInteract(Team team, Team other){`).'),
        'other_team_id': a('int', 'return team == other || other == Team.derelict;', 'The other team (Teams.java:126, `return team == other || other == Team.derelict;`): compared by team_id.'),
        'derelict_team_id': a('int', 'return team == other || other == Team.derelict;', 'Team.derelict as an explicit param (Teams.java:126, `return team == other || other == Team.derelict;`): the Team const is not ported, so the derelict id arrives explicitly (derelict id 0, Team.java:41, per the file header comment).'),
    }
    can_interact_outputs = {
        'can_interact': a('bool', 'return team == other || other == Team.derelict;', 'Whether the teams can interact (Teams.java:126, `return team == other || other == Team.derelict;`): true when the teams are the same, or when the other team is derelict -- a pure id predicate, no teams_state needed.'),
    }
    get_active_inputs = {
        'teams_state': a('Dictionary', 'active.removeAll(t -> !t.active());', 'The teams state (Teams.getActive, Teams.java:131, `active.removeAll(t -> !t.active());`): carries the "active" list; getActive() REMOVES inactive entries in place (Java removeAll mutates the Seq), so teams_state is an in/out param here.'),
    }
    get_active_outputs = {
        'active': a('Array', 'return active;', 'The active team ids after pruning (Teams.java:132, `return active;`): every entry whose TeamData.active() is false is removed, in original order. Do not modify: the /** Do not modify. */ note on getActive() (Teams.java:129).'),
        'teams_state': a('Dictionary', 'active.removeAll(t -> !t.active());', 'The updated teams state (Teams.java:131, `active.removeAll(t -> !t.active());`): teams_state["active"] is the pruned list -- Java mutates the Seq in place.'),
    }
    return (get_inputs, get_outputs), (get_or_null_inputs, get_or_null_outputs), (player_cores_inputs, player_cores_outputs), (cores_inputs, cores_outputs), (is_active_inputs, is_active_outputs), (can_interact_inputs, can_interact_outputs), (get_active_inputs, get_active_outputs)


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
        ('N2380', GET_OWNER, 'source_teams_get_state', TEAMS, 'mindustry.game.Teams', 'Teams.get(Team)', pairs[0][0], pairs[0][1], True, 'Dictionary'),
        ('N2380', GET_OR_NULL_OWNER, 'source_teams_get_or_null_state', TEAMS, 'mindustry.game.Teams', 'Teams.getOrNull(Team)', pairs[1][0], pairs[1][1], True, 'Dictionary'),
        ('N2380', PLAYER_CORES_OWNER, 'source_teams_player_cores_state', TEAMS, 'mindustry.game.Teams', 'Teams.playerCores()', pairs[2][0], pairs[2][1], True, 'Dictionary'),
        ('N2380', CORES_OWNER, 'source_teams_cores_state', TEAMS, 'mindustry.game.Teams', 'Teams.cores(Team)', pairs[3][0], pairs[3][1], True, 'Dictionary'),
        ('N2380', IS_ACTIVE_OWNER, 'source_teams_is_active_state', TEAMS, 'mindustry.game.Teams', 'Teams.isActive(Team)', pairs[4][0], pairs[4][1], True, 'Dictionary'),
        ('N2380', CAN_INTERACT_OWNER, 'source_teams_can_interact_state', TEAMS, 'mindustry.game.Teams', 'Teams.canInteract(Team, Team)', pairs[5][0], pairs[5][1], True, 'Dictionary'),
        ('N2380', GET_ACTIVE_OWNER, 'source_teams_get_active_state', TEAMS, 'mindustry.game.Teams', 'Teams.getActive()', pairs[6][0], pairs[6][1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.get()/getOrNull()/playerCores()/cores()/isActive()/canInteract()/getActive() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.get()/getOrNull()/playerCores()/cores()/isActive()/canInteract()/getActive() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: get team_data, created,
    # teams_state; getOrNull team_data; playerCores cores,
    # teams_state; cores cores, teams_state; isActive
    # is_active, teams_state; canInteract can_interact;
    # getActive active, teams_state.
    by_slice['N2380'] = [
        'source_teams_get_state_result.team_data',
        'source_teams_get_state_result.created',
        'source_teams_get_state_result.teams_state',
        'source_teams_get_or_null_state_result.team_data',
        'source_teams_player_cores_state_result.cores',
        'source_teams_player_cores_state_result.teams_state',
        'source_teams_cores_state_result.cores',
        'source_teams_cores_state_result.teams_state',
        'source_teams_is_active_state_result.is_active',
        'source_teams_is_active_state_result.teams_state',
        'source_teams_can_interact_state_result.can_interact',
        'source_teams_get_active_state_result.active',
        'source_teams_get_active_state_result.teams_state',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2380', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='Teams.get(Team)/Teams.getOrNull(Team)/Teams.playerCores()/Teams.cores(Team)/Teams.isActive(Team)/Teams.canInteract(Team, Team)/Teams.getActive()', godot_owner=GET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2380'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
