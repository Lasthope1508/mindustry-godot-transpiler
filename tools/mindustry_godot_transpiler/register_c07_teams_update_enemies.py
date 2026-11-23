"""Register Teams updateEnemies() (N2357).

Teams.updateEnemies() (Teams.java:252-268,
`private void updateEnemies(){` /
`if(state.rules.waves &&
!active.contains(get(state.rules.waveTeam))){` /
`active.add(get(state.rules.waveTeam));` /
`for(TeamData data : active){` /
`Seq<Team> enemies = new Seq<>();` /
`for(TeamData other : active){` /
`if(data.team != other.team){` /
`enemies.add(other.team);` / `data.coreEnemies =
enemies.toArray(Team.class);`) is one pure
function on SourceTeamsRuntimeState.gd next to
the N2074/N2075 registerCore/unregisterCore
functions. The wave team is added to active
when waves are enabled and it is not active
yet; then every active team's coreEnemies is
rewritten to the other active teams (the team
itself excluded). state.rules.waves /
state.rules.waveTeam are Rules state (not
ported), so both arrive as explicit params
(waves_enabled, wave_team_id; the N2330 param
precedent). Team comparison is by team_id, not
the Team enum. core_enemies already lives in
the teams_state dict (kept by N2074/N2075);
this slice REWRITES that field. The call-site
`updateEnemies();` already owned by N2074/N2075
(registerCore/unregisterCore call it,
Teams.java:140, :154, :164) is callee evidence
only, not this method's body. The function is
pure: it deep-copies the teams_state, sets the
copy's rules from the params, applies the
shared _teams_update_enemies helper to the
copy, and returns the updated copy plus
wave_team_added -- the caller's dict is never
mutated.

RED decisions (resolved at RED): (1) One slice
entry for the one method, following the
N2343/N2348/N2350/N2353/N2354 precedent (one
ledger entry per method group, one function per
method). (2) The frame is the family-convention
first arg and carries the teams_state dict (the
N2074 precedent); waves_enabled and
wave_team_id arrive as explicit params because
Rules/state is not ported. (3) The function
returns two keys: teams_state (the updated
deep copy) plus wave_team_added (whether the
wave team was newly added to active). (4) NO
driver tick line: registerCore/unregisterCore
already call updateEnemies() through the shared
helper (N2074/N2075); no call site is ported
here. (5) updateTeamStats() stays deferred (it
maintains unit counts/plans/AI, ~40 exprs) and
the 1-line closestCore() delegate
(Teams.java:56-58) is NOT gobbled into this
slice (batch-10 scope sections 2.6/5f). Two new
result symbols. One slice source: Teams.java
only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_closest_enemy_core import DEFERRED as N2354_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsUpdateEnemiesProof'
UPDATE_ENEMIES_OWNER = 'SourceTeamsRuntimeState.source_teams_update_enemies_state'
TESTS = ['test_c07_teams_update_enemies_registration', 'test_all_c07_teams_update_enemies_input_evidence_is_exact', 'test_teams_update_enemies_state', 'test_reference_graph_and_actual_c07_teams_update_enemies']
# The 1 slice source the N2357 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public class Teams{',
    'private void updateEnemies(){',
    'if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){',
    'active.add(get(state.rules.waveTeam));',
    'for(TeamData data : active){',
    'Seq<Team> enemies = new Seq<>();',
    'for(TeamData other : active){',
    'if(data.team != other.team){',
    'enemies.add(other.team);',
    'data.coreEnemies = enemies.toArray(Team.class);',
]

# DEFERRED is carried from the N2354 register script via import --
# never retyped. All N2354 entries are carried verbatim (the
# Game chain, the B/C notes, and N2354's own Windows proof
# debt -- none of them is resolved by this slice). Two
# entries are added: updateTeamStats NOT-this-slice note
# and N2357's Windows proof debt.
DEFERRED = list(N2354_DEFERRED) + [
    'Teams.updateTeamStats() (Teams.java:181-250, ~40 exprs, maintains unit counts/plans/AI) -- NOT this slice: too large + depends on unported state (batch-10 scope section 2.6).',
    'Teams.updateEnemies Windows Godot proof -- debt in GOAL.md section 5, same as N2354: the N2357 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_enemies_inputs = {
        'teams_state': a('Dictionary', 'private void updateEnemies(){', 'The teams state (Teams.updateEnemies, Teams.java:252): the family-convention first arg; it carries the active list and the teams dict with each team\'s core_enemies (the N2074 precedent) -- this slice REWRITES core_enemies in the returned copy.'),
        'waves_enabled': a('bool', 'if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){', 'Whether waves are enabled (Teams.java:253, `if(state.rules.waves && !active.contains(get(state.rules.waveTeam))){`): state.rules.waves is Rules state (not ported), so it arrives as an explicit param (the N2330 param precedent).'),
        'wave_team_id': a('int', 'active.add(get(state.rules.waveTeam));', 'The wave team id (Teams.java:254, `active.add(get(state.rules.waveTeam));`): state.rules.waveTeam is Rules state (not ported), so it arrives as an explicit param; -1 means no wave team.'),
    }
    update_enemies_outputs = {
        'teams_state': a('Dictionary', 'data.coreEnemies = enemies.toArray(Team.class);', 'The updated teams_state (Teams.java:261, `data.coreEnemies = enemies.toArray(Team.class);`): a deep copy of the input with the wave team added to active when applicable and every active team\'s core_enemies rewritten to the other active teams; the caller\'s dict is never mutated.'),
        'wave_team_added': a('bool', 'active.add(get(state.rules.waveTeam));', 'Whether the wave team was newly added to active (Teams.java:254, `active.add(get(state.rules.waveTeam));`): true only when waves are enabled, the wave team id is valid, and it was not active yet.'),
    }
    return (update_enemies_inputs, update_enemies_outputs)


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
    (update_enemies_inputs, update_enemies_outputs) = definitions()

    entries = [
        ('N2357', UPDATE_ENEMIES_OWNER, 'source_teams_update_enemies_state', TEAMS, 'mindustry.game.Teams', 'updateEnemies', update_enemies_inputs, update_enemies_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.updateEnemies() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.updateEnemies() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: teams_state, wave_team_added.
    by_slice['N2357'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2357', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='updateEnemies', godot_owner=UPDATE_ENEMIES_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2357'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
