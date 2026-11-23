"""Register Teams.updateTeamStats() (N2383).

Teams.updateTeamStats() (Teams.java:181-251,
`present.clear();` /
`bosses.clear();` /
`data.presentFlag = data.buildings.size > 0;` /
`data.units.clear();` /
`data.players.clear();` /
`if(data.cores.size > 0){` /
`data.lastCore = data.cores.first();` /
`if(data.unitTree != null){` /
`data.unitTree.clear();` /
`if(data.unitsByType != null){` /
`for(int i = 0; i < data.unitsByType.length; i++){` /
`if(data.unitsByType[i] != null){` /
`data.unitsByType[i].clear();` /
`if(unit.type == null) continue;` /
`TeamData data = unit.team.data();` /
`data.presentFlag = true;` /
`if(unit.team == state.rules.waveTeam && unit.isBoss()){` /
`bosses.add(unit);` /
`if(data.unitsByType == null || data.unitsByType.length <= unit.type.id){` /
`data.unitsByType = new Seq[content.units().size];` /
`if(data.unitsByType[unit.type.id] == null){` /
`data.unitsByType[unit.type.id] = new Seq<>();` /
`data.unitsByType[unit.type.id].add(unit);` /
`count(unit);` /
`for(var player : Groups.player){` /
`player.team().data().players.add(player);` /
`if(data.presentFlag || data.active()){` /
`present.add(data);`) is the full multi-team rebuild: reset
every tracked team's data, recount every live unit,
group players by team, rebuild present from
presentFlag || active(). One GD function on
SourceTeamsRuntimeState.gd, one ledger entry, one owner
(the N2378 lesson: a contract owner must be an actual GD
function).

Callees / evidence -- NOT re-registered as distinguishing exprs:
- `public void updateTeamStats(){` + `data.unitCount = 0;` +
  `if(data.typeCounts != null){` +
  `Arrays.fill(data.typeCounts, 0);` +
  `for(Unit unit : Groups.unit){` +
  `data.units.add(unit);` + helper `count(Unit unit){` --
  already the exact_exprs of N2141 (PortGame-era); the
  reset + recount behavior they describe IS implemented
  here, through the N2141 callee `_team_data_count_unit`
  for `count(unit);`.
- `for(Team team : Team.all){` -- already the exact_expr
  of N1356 (Block.load); Team.all is the
  teams_state["teams"] keys here.
- `data.tree().insert(unit);` -- tree() is NOT called as
  an accessor: the team's unitTree arrives inside the
  per-team dict as its inserted-unit list
  {"inserted": [...]}, created lazily exactly as tree()
  does (Teams.java:437-439); the QuadTree spatial
  structure itself is not ported.
- `TeamData.active()` in the presence loop -- already the
  exact_expr of N2074/N2075 (PortGame-era); the file's
  `_teams_active` helper is that callee, called as evidence.
- `TeamData data = team.data();` -- the generic per-team
  lookup (not distinguishing); the function reads the
  per-team dicts from teams_state["teams"] and creates a
  missing entry via `_teams_data`, exactly as Java
  `team.data()` does.

`present`/`bosses` are the frame's in/out Seqs: cleared
first, then rebuilt in place (the caller's Arrays are the
ones mutated). `units`/`players` arrive as explicit record
Arrays (Groups.unit / Groups.player are live entity
groups, not ported); `state.rules.waveTeam` and
`content.units().size` arrive as explicit params. Four
new result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_lookup import DEFERRED as N2380_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsUpdateTeamStatsProof'
OWNER = 'SourceTeamsRuntimeState.source_teams_update_team_stats_state'
TESTS = ['test_c07_teams_update_team_stats_registration', 'test_all_c07_teams_update_team_stats_input_evidence_is_exact', 'test_teams_update_team_stats_state', 'test_reference_graph_and_actual_c07_teams_update_team_stats']
# The 1 slice source the N2383 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'present.clear();',
    'bosses.clear();',
    'data.presentFlag = data.buildings.size > 0;',
    'data.units.clear();',
    'data.players.clear();',
    'if(data.cores.size > 0){',
    'data.lastCore = data.cores.first();',
    'if(data.unitTree != null){',
    'data.unitTree.clear();',
    'if(data.unitsByType != null){',
    'for(int i = 0; i < data.unitsByType.length; i++){',
    'if(data.unitsByType[i] != null){',
    'data.unitsByType[i].clear();',
    'if(unit.type == null) continue;',
    'TeamData data = unit.team.data();',
    'data.presentFlag = true;',
    'if(unit.team == state.rules.waveTeam && unit.isBoss()){',
    'bosses.add(unit);',
    'if(data.unitsByType == null || data.unitsByType.length <= unit.type.id){',
    'data.unitsByType = new Seq[content.units().size];',
    'if(data.unitsByType[unit.type.id] == null){',
    'data.unitsByType[unit.type.id] = new Seq<>();',
    'data.unitsByType[unit.type.id].add(unit);',
    'count(unit);',
    'for(var player : Groups.player){',
    'player.team().data().players.add(player);',
    'if(data.presentFlag || data.active()){',
    'present.add(data);',
]

# DEFERRED is carried from the N2380 register script via import --
# never retyped. All N2380 entries are carried verbatim (the
# Game chain, the B/C notes, and N2380's own Windows proof
# debt -- none of them is resolved by this slice). Three entries
# are added: N2383's Windows proof debt, the unitTree QuadTree
# model, and the Team.all / Groups frame notes.
DEFERRED = list(N2380_DEFERRED) + [
    'Teams.updateTeamStats() Windows Godot proof -- debt in GOAL.md section 5, same as N2380: the N2383 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TeamData.unitTree QuadTree spatial structure (Teams.java:296, 437-439) -- tree() lazily creates the QuadTree from world bounds; the port models the tree as its inserted-unit list {"inserted": [...]} in the per-team dict, insertion order preserved, spatial queries wait for a QuadTree slice.',
    'Team.all iteration (Teams.java:185, 244) + Groups.unit / Groups.player (Teams.java:214, 240) -- Team.all is the teams_state["teams"] keys (the frame\'s tracked teams); units/players arrive as explicit record Arrays, so the driver tick that feeds live Groups waits for a groups slice.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'teams_state': a('Dictionary', 'TeamData data = team.data();', 'The teams state (Teams.updateTeamStats, Teams.java:186, `TeamData data = team.data();`): the family-convention first arg; it carries the "teams" map team_id -> TeamData dict, the "active" list, and the "rules" ({wave_team, waves}) the active() callee reads. Every per-team field updateTeamStats touches lives here (present_flag, unit_count, units, players, last_core, unit_tree, type_counts, units_by_type) -- teams_state is an in/out param, mutated in place.'),
        'units': a('Array', 'for(Unit unit : Groups.unit){', 'The live units (Teams.java:214, `for(Unit unit : Groups.unit){`): Groups.unit is a live entity group (not ported), so units arrive as explicit records {"team_id": int, "type_id": int (-1 maps to unit.type == null), "type_name": String, "is_boss": bool, "payload_units": [...]} (the N2141 record shape plus is_boss for unit.isBoss()). A record with type_id < 0 is skipped (`if(unit.type == null) continue;`, Teams.java:215).'),
        'players': a('Array', 'for(var player : Groups.player){', 'The players (Teams.java:240, `for(var player : Groups.player){`): Groups.player is a live entity group (not ported), so players arrive as explicit records {"team_id": int, "ref": Variant} -- player.team() is the team_id, the player itself is the opaque ref stored in that team\'s players list.'),
        'wave_team_id': a('int', 'if(unit.team == state.rules.waveTeam && unit.isBoss()){', 'state.rules.waveTeam as an explicit param (Teams.java:221, `if(unit.team == state.rules.waveTeam && unit.isBoss()){`): Rules is not ported, so the wave team arrives as its team id (the N2330 param precedent) -- only a boss unit of this team lands in bosses.'),
        'content_unit_size': a('int', 'data.unitsByType = new Seq[content.units().size];', 'content.units().size as an explicit param (Teams.java:226, `data.unitsByType = new Seq[content.units().size];`): the content registry is not ported, so the unit-type count arrives explicitly -- it sizes the fresh unitsByType array on regrowth and the type_counts growth inside the count() callee.'),
        'present': a('Array', 'present.clear();', 'The frame\'s present Seq (Teams.java:182, `present.clear();`): cleared first, then rebuilt in place with the team ids whose presentFlag is true or whose TeamData.active() is true -- the caller\'s Array is the one mutated, so present is an in/out param.'),
        'bosses': a('Array', 'bosses.clear();', 'The frame\'s bosses Seq (Teams.java:183, `bosses.clear();`): cleared first, then rebuilt in place with the wave-team boss unit records -- the caller\'s Array is the one mutated, so bosses is an in/out param.'),
    }
    outputs = {
        'teams_state': a('Dictionary', 'if(data.presentFlag || data.active()){', 'The updated teams state (Teams.java:246, `if(data.presentFlag || data.active()){`): every tracked team\'s data after the reset + recount -- present_flag, unit_count, units, players, last_core, unit_tree, type_counts, units_by_type all rewritten; teams created by a unit/player get the reset treatment too.'),
        'present': a('Array', 'present.add(data);', 'The present team ids (Teams.java:247, `present.add(data);`): every team whose presentFlag is true or whose TeamData.active() is true, in teams_state key order -- the same Array passed in, rebuilt in place.'),
        'bosses': a('Array', 'bosses.add(unit);', 'The current boss units (Teams.java:222, `bosses.add(unit);`): the wave-team boss unit records seen in this rebuild, in Groups.unit order -- the same Array passed in, rebuilt in place.'),
        'unit_counts_by_team': a('Dictionary', 'count(unit);', 'The name-keyed unit counts per team (Teams.java:235, `count(unit);`): {team_id: {type_name: count}} -- the N2141 count() callee\'s team_unit_counts view, one entry per team that was reset (payload units included, exactly as count(unit) recurses).'),
    }
    return (inputs, outputs)


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
    inputs_outputs = (definitions(),)
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
        ('N2383', OWNER, 'source_teams_update_team_stats_state', TEAMS, 'mindustry.game.Teams', 'Teams.updateTeamStats()', pairs[0], pairs[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.updateTeamStats() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.updateTeamStats() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: teams_state, present, bosses,
    # unit_counts_by_team.
    by_slice['N2383'] = [
        'source_teams_update_team_stats_state_result.teams_state',
        'source_teams_update_team_stats_state_result.present',
        'source_teams_update_team_stats_state_result.bosses',
        'source_teams_update_team_stats_state_result.unit_counts_by_team',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2383', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='Teams.updateTeamStats()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2383'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
