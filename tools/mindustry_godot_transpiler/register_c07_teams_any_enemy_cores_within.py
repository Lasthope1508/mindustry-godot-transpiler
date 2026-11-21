"""Register Teams anyEnemyCoresWithin() (N2361).

Teams.anyEnemyCoresWithin() (Teams.java:73-85,
`public boolean anyEnemyCoresWithin(Team team, float x,
float y, float radius){` / `for(TeamData data : active){` /
`if(team != data.team && data.team.rules().protectCores){` /
`for(CoreBuild tile : data.cores){` /
`if(tile.within(x, y, radius)){` /
`return true;` / `return false;`) is one pure function on
SourceTeamsRuntimeState.gd next to the N2359
anyEnemyCoresWithinBuildRadius and N2357 updateEnemies
functions. The scan walks the active teams (read from
teams_state, kept there by registerCore/unregisterCore,
N2074/N2075), skipping the calling team and teams whose
rules do not protect cores, and each enemy team's cores; a
core within `radius` of the query point returns true.
`data.team.rules().protectCores` is Rules state (not
ported), so it arrives as an explicit per-team lookup keyed
by team_id (the N2330 param precedent). Unlike N2359, the
radius comes STRAIGHT from the signature param -- no
buildRadius lookup and no tilesize here.
`tile.within(x, y, radius)` is arc Position.within
(Position.java:44-46:
`default boolean within(float x, float y, float dst){` /
`return Mathf.dst2(getX(), getY(), x, y) < dst*dst;`) -- a
STRICT < on the squared distance, so a core exactly on the
radius boundary is OUTSIDE. The cores stored in teams_state
are opaque refs with no position, so the enemy cores arrive as
explicit records {"team_id": int, "x": float, "y": float} (the
N2330/N2354 param precedent); only records whose team_id is
the active team being scanned are considered. The
`protectCores` condition line is shared text with N2359
(`if(team != data.team && data.team.rules().protectCores){`)
-- one shared condition line, NOT a shared method: this slice
registers java_method Teams.anyEnemyCoresWithin(Team, float,
float, float), and the distinguishing line
`if(tile.within(x, y, radius)){` is 0-hit in both ledgers.
No call-site of this method is owned by any slice yet. One
new result symbol.

RED decisions (resolved at RED): (1) One slice entry for the
one method, following the N2354/N2357/N2359 precedent (one
ledger entry per method, one function per method). (2) The
frame is the family-convention first arg and carries the
teams_state dict (the N2074 precedent); the query point
arrives as explicit x/y floats, the calling team as team_id,
the radius as an explicit float param, protectCores as an
explicit per-team dict lookup, and the enemy cores as the
explicit enemy_cores array of records (the caller flattens
active -> cores and attaches positions -- the N2330/N2354
param precedent). (3) The function returns one key: within
(bool). (4) NO driver tick line: no call site is ported here
(the closestEnemyCore precedent). (5) eachEnemyCore()
(Teams.java:86-96) stays deferred -- a separate method for
batch 13 (batch-11 scope section 1.6b), not gobbled into
this slice. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_any_enemy_cores_within_build_radius import DEFERRED as N2359_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsAnyEnemyCoresWithinProof'
ANY_ENEMY_CORES_WITHIN_OWNER = 'SourceTeamsRuntimeState.source_teams_any_enemy_cores_within_state'
TESTS = ['test_c07_teams_any_enemy_cores_within_registration', 'test_all_c07_teams_any_enemy_cores_within_input_evidence_is_exact', 'test_teams_any_enemy_cores_within_state', 'test_reference_graph_and_actual_c07_teams_any_enemy_cores_within']
# The 1 slice source the N2361 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public class Teams{',
    'public boolean anyEnemyCoresWithin(Team team, float x, float y, float radius){',
    'for(TeamData data : active){',
    'if(team != data.team && data.team.rules().protectCores){',
    'for(CoreBuild tile : data.cores){',
    'if(tile.within(x, y, radius)){',
    'return true;',
    'return false;',
]

# DEFERRED is carried from the N2359 register script via import --
# never retyped. All N2359 entries are carried verbatim (the
# Game chain, the B/C notes, the anyEnemyCoresWithin NOT-this-slice
# note -- which was true for N2359 and stays as that slice's
# record -- and N2359's own Windows proof debt -- none of them
# is resolved by this slice except the method itself, whose
# registration is this slice). One entry is added: N2361's
# Windows proof debt.
DEFERRED = list(N2359_DEFERRED) + [
    'Teams.anyEnemyCoresWithin Windows Godot proof -- debt in GOAL.md section 5, same as N2359: the N2361 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    any_enemy_cores_within_inputs = {
        'teams_state': a('Dictionary', 'for(TeamData data : active){', 'The teams state (Teams.anyEnemyCoresWithin, Teams.java:74): the family-convention first arg; it carries the active list (kept there by registerCore/unregisterCore, N2074/N2075 -- NOT ported here, only read).'),
        'team_id': a('int', 'if(team != data.team && data.team.rules().protectCores){', 'The calling team id (Teams.java:75, `if(team != data.team && data.team.rules().protectCores){`): the team asking -- its own cores are never candidates, only other active teams\' are.'),
        'x': a('float', 'public boolean anyEnemyCoresWithin(Team team, float x, float y, float radius){', 'The query point x (Teams.java:73, `public boolean anyEnemyCoresWithin(Team team, float x, float y, float radius){`): the point enemy cores are measured from.'),
        'y': a('float', 'public boolean anyEnemyCoresWithin(Team team, float x, float y, float radius){', 'The query point y (Teams.java:73, `public boolean anyEnemyCoresWithin(Team team, float x, float y, float radius){`): the point enemy cores are measured from.'),
        'radius': a('float', 'if(tile.within(x, y, radius)){', 'The radius in world units (Teams.java:77, `if(tile.within(x, y, radius)){`): taken straight from the signature param -- unlike N2359, no buildRadius lookup and no tilesize here.'),
        'protect_cores_by_team': a('Dictionary', 'if(team != data.team && data.team.rules().protectCores){', 'Whether each team protects its cores, keyed by team_id (Teams.java:75, `if(team != data.team && data.team.rules().protectCores){`): data.team.rules() is Rules state (not ported), so it arrives as an explicit lookup (the N2330 param precedent); teams absent from the lookup are treated as unprotected.'),
        'enemy_cores': a('Array', 'for(CoreBuild tile : data.cores){', 'The enemy cores as explicit records {"team_id": int, "x": float, "y": float} (Teams.java:76, `for(CoreBuild tile : data.cores){`): the cores stored in teams_state are opaque refs with no position, so the caller flattens active -> cores and attaches positions (the N2330/N2354 param precedent); only records whose team_id is the active team being scanned are considered.'),
    }
    any_enemy_cores_within_outputs = {
        'within': a('bool', 'return true;', 'Whether any enemy core is within radius (Teams.java:78, `return true;`): true as soon as one protected enemy team\'s core is within radius of the query point (tile.within is a STRICT < on the squared distance, arc Position.java:44-46); false when no core qualifies (`return false;`, Teams.java:83).'),
    }
    return (any_enemy_cores_within_inputs, any_enemy_cores_within_outputs)


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
    (any_enemy_cores_within_inputs, any_enemy_cores_within_outputs) = definitions()

    entries = [
        ('N2361', ANY_ENEMY_CORES_WITHIN_OWNER, 'source_teams_any_enemy_cores_within_state', TEAMS, 'mindustry.game.Teams', 'anyEnemyCoresWithin', any_enemy_cores_within_inputs, any_enemy_cores_within_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.anyEnemyCoresWithin() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.anyEnemyCoresWithin() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: within.
    by_slice['N2361'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2361', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='anyEnemyCoresWithin', godot_owner=ANY_ENEMY_CORES_WITHIN_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2361'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
