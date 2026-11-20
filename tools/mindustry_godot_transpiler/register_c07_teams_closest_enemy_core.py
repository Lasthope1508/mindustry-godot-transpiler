"""Register Teams closestEnemyCore() (N2354).

Teams.closestEnemyCore() (Teams.java:39-55,
`@Nullable` / `public CoreBuild closestEnemyCore(float
x, float y, Team team){` / `CoreBuild closest =
null;` / `float closestDst = Float.MAX_VALUE;` /
`for(Team enemy : team.data().coreEnemies){` /
`for(CoreBuild core : enemy.cores()){` / `float dst
= Mathf.dst2(x, y, core.getX(), core.getY());` /
`if(closestDst > dst){` / `closest = core;` /
`closestDst = dst;` / `return closest;`) is one
pure function on SourceTeamsRuntimeState.gd next to
the N2074/N2075 registerCore/unregisterCore
functions. The scan walks the calling team's
coreEnemies (kept in teams_state by updateEnemies,
Teams.java:252-268 -- NOT ported here, only read)
and each enemy team's cores, keeping the core with
the smallest squared distance. Mathf.dst2 is the
SQUARED distance (arc Mathf.java:656-659:
`public static float dst2(float x1, float y1, float
x2, float y2){` / `final float xd = x2 - x1;` /
`final float yd = y2 - y1;` / `return xd * xd + yd
* yd;`). A strict `>` keeps the FIRST core on a
tie. No enemy core means null (the @Nullable
return) with closest_dst2 left at Float.MAX_VALUE.
The cores stored in teams_state are opaque refs
with no position, so the enemy cores arrive as
explicit records {"team_id": int, "ref": Variant,
"x": float, "y": float} (the N2330 param
precedent); only records whose team_id is in the
calling team's core_enemies are considered. The
read does not mutate teams_state (it never calls
_teams_data, which would create a missing team
entry).

RED decisions (resolved at RED): (1) One slice
entry for the one method, following the
N2343/N2348/N2350/N2353 precedent (one ledger
entry per method group, one function per method).
(2) The frame is the family-convention first arg
and carries the teams_state dict (the N2074
precedent); the query point arrives as explicit
x/y floats, the calling team as team_id, and the
enemy cores as the explicit enemy_cores array of
records (the caller flattens core_enemies -> cores
and attaches positions -- the N2330 param
precedent). (3) The function returns two keys:
closest_core (the winning core ref, or null) plus
closest_dst2 (the squared distance, or
Float.MAX_VALUE when nothing is found). (4) NO
driver tick line: AI/targeting calls
closestEnemyCore(); no call site is ported here
(the shouldTurn/isShooting precedent). (5)
updateEnemies() stays deferred (it maintains
coreEnemies; this slice only reads it) and the
1-line closestCore() delegate
(Teams.java:56-58) is NOT gobbled into this slice
(batch-9 scope sections 2.3/2.6/5c). Two new
result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_sound_control_stop import DEFERRED as N2352_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsClosestEnemyCoreProof'
CLOSEST_ENEMY_CORE_OWNER = 'SourceTeamsRuntimeState.source_teams_closest_enemy_core_state'
TESTS = ['test_c07_teams_closest_enemy_core_registration', 'test_all_c07_teams_closest_enemy_core_input_evidence_is_exact', 'test_teams_closest_enemy_core_state', 'test_reference_graph_and_actual_c07_teams_closest_enemy_core']
# The 1 slice source the N2354 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public class Teams{',
    '@Nullable',
    'public CoreBuild closestEnemyCore(float x, float y, Team team){',
    'CoreBuild closest = null;',
    'float closestDst = Float.MAX_VALUE;',
    'for(Team enemy : team.data().coreEnemies){',
    'for(CoreBuild core : enemy.cores()){',
    'float dst = Mathf.dst2(x, y, core.getX(), core.getY());',
    'if(closestDst > dst){',
    'closest = core;',
    'closestDst = dst;',
    'return closest;',
]

# DEFERRED is carried from the N2352 register script via import --
# never retyped. All N2352 entries are carried verbatim (the
# Game chain, the B/C notes, and N2352's own Windows proof
# debt -- none of them is resolved by this slice). Three
# entries are added: closestCore/updateEnemies NOT-this-slice
# notes and N2354's Windows proof debt.
DEFERRED = list(N2352_DEFERRED) + [
    'Teams.closestCore() (Teams.java:56-58, 1-line Geometry.findClosest delegate) -- NOT this slice: too thin for its own slice (batch-9 scope section 5c); closestEnemyCore() does not gobble it.',
    'Teams.updateEnemies() (Teams.java:252-268, maintains each active team\'s coreEnemies) -- NOT this slice: closestEnemyCore() only READS core_enemies from teams_state (batch-9 scope section 2.3).',
    'Teams.closestEnemyCore Windows Godot proof -- debt in GOAL.md section 5, same as N2352: the N2354 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    closest_enemy_core_inputs = {
        'teams_state': a('Dictionary', 'public CoreBuild closestEnemyCore(float x, float y, Team team){', 'The teams state (Teams.closestEnemyCore, Teams.java:39): the family-convention first arg; it carries the calling team\'s core_enemies list (kept there by updateEnemies, Teams.java:252-268 -- NOT ported here, only read) and the teams dict (the N2074 precedent).'),
        'x': a('float', 'public CoreBuild closestEnemyCore(float x, float y, Team team){', 'The query point x (Teams.java:39, `public CoreBuild closestEnemyCore(float x, float y, Team team){`): the point the nearest enemy core is measured from.'),
        'y': a('float', 'public CoreBuild closestEnemyCore(float x, float y, Team team){', 'The query point y (Teams.java:39, `public CoreBuild closestEnemyCore(float x, float y, Team team){`): the point the nearest enemy core is measured from.'),
        'team_id': a('int', 'for(Team enemy : team.data().coreEnemies){', 'The calling team id (Teams.java:43, `for(Team enemy : team.data().coreEnemies){`): the team whose coreEnemies list is scanned -- its cores are never candidates, only its enemies\' are.'),
        'enemy_cores': a('Array', 'for(CoreBuild core : enemy.cores()){', 'The enemy cores as explicit records {"team_id": int, "ref": Variant, "x": float, "y": float} (Teams.java:44, `for(CoreBuild core : enemy.cores()){`): the cores stored in teams_state are opaque refs with no position, so the caller flattens core_enemies -> cores and attaches positions (the N2330 param precedent); only records whose team_id is in the calling team\'s core_enemies are considered.'),
    }
    closest_enemy_core_outputs = {
        'closest_core': a('Variant', 'closest = core;', 'The nearest enemy core ref (Teams.java:47, `closest = core;`): null when no enemy core exists (the @Nullable return, Teams.java:38) -- the caller must null-check before using it.'),
        'closest_dst2': a('float', 'closestDst = dst;', 'The squared distance to the nearest enemy core (Teams.java:48, `closestDst = dst;`): Mathf.dst2 is the SQUARED distance (arc Mathf.java:656-659); left at Float.MAX_VALUE (`float closestDst = Float.MAX_VALUE;`, Teams.java:41) when no enemy core exists.'),
    }
    return (closest_enemy_core_inputs, closest_enemy_core_outputs)


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
    (closest_enemy_core_inputs, closest_enemy_core_outputs) = definitions()

    entries = [
        ('N2354', CLOSEST_ENEMY_CORE_OWNER, 'source_teams_closest_enemy_core_state', TEAMS, 'mindustry.game.Teams', 'closestEnemyCore', closest_enemy_core_inputs, closest_enemy_core_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.closestEnemyCore() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.closestEnemyCore() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: closest_core, closest_dst2.
    by_slice['N2354'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2354', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='closestEnemyCore', godot_owner=CLOSEST_ENEMY_CORE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2354'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
