"""Register Teams eachEnemyCore() (N2365).

Teams.eachEnemyCore() (Teams.java:86-94,
`public void eachEnemyCore(Team team, Cons<Building> ret){` /
`for(TeamData data : active){` /
`if(team != data.team){` /
`for(Building tile : data.cores){` /
`ret.get(tile);`) is one pure function on
SourceTeamsRuntimeState.gd next to the N2359
anyEnemyCoresWithinBuildRadius and N2361 anyEnemyCoresWithin
functions. The scan walks the active teams, skipping the
calling team, and collects every enemy team's cores. Java
hands each core to the Cons<Building> callback; GDScript has
no Java Cons, so the port returns the enemy cores as data
(main-thread decision 2026-11-21, recorded in
allocations.json N2365): each core is [team_id, x, y] and the
caller iterates them instead of a callback. The payload is
the "cores" Array inside the family-convention Dictionary
envelope: the SSOT validator (source_symbols.py
upsert_source_api_contract) accepts only return_type
Dictionary or void, so a bare Array return cannot be
registered, and every other state function in this file
returns a Dictionary. Unlike N2361, there is no protectCores
condition and no radius -- every enemy team's cores are
collected, in active-team order then enemy_cores order. The
cores stored in teams_state are opaque refs with no
position, so the enemy cores arrive as explicit records
{"team_id": int, "x": float, "y": float} (the N2330/N2354
param precedent); only records whose team_id is the active
team being scanned are collected.
`ret.get(tile);` is 0-hit in both ledgers, and the method
name is 0-hit in the remote ledger (the only local hits are
deferred_exprs prose in N2359/N2361, not ownership). One new
result symbol: cores (Array).

RED decisions (resolved at RED): (1) One slice entry for the
one method, following the N2354/N2357/N2359/N2361 precedent
(one ledger entry per method, one function per method). (2)
The frame is the family-convention first arg and carries the
teams_state dict (the N2074 precedent); the calling team
arrives as team_id, and the enemy cores as the explicit
enemy_cores array of records (the caller flattens active ->
cores and attaches positions -- the N2330/N2354 param
precedent). (3) The function returns one Dictionary key: cores (Array) --
the payload is the Array of [team_id, x, y] cores; the
Dictionary envelope is the family convention and the only
return shape the SSOT validator accepts. (4) NO driver tick
line: no call site is ported here (the closestEnemyCore
precedent). (5) This
slice RESOLVES the eachEnemyCore deferred entry carried by
N2359/N2361 (batch-11 scope section 1.6b): the callback
shape decision it waited for is the Array return recorded
above, so that entry is dropped from DEFERRED instead of
carried verbatim. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_any_enemy_cores_within import DEFERRED as N2361_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsEachEnemyCoreProof'
EACH_ENEMY_CORE_OWNER = 'SourceTeamsRuntimeState.source_teams_each_enemy_core_state'
TESTS = ['test_c07_teams_each_enemy_core_registration', 'test_all_c07_teams_each_enemy_core_input_evidence_is_exact', 'test_teams_each_enemy_core_state', 'test_reference_graph_and_actual_c07_teams_each_enemy_core']
# The 1 slice source the N2365 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'public class Teams{',
    'public void eachEnemyCore(Team team, Cons<Building> ret){',
    'for(TeamData data : active){',
    'if(team != data.team){',
    'for(Building tile : data.cores){',
    'ret.get(tile);',
]

# DEFERRED is carried from the N2361 register script via import --
# never retyped. All N2361 entries are carried verbatim (the
# Game chain, the B/C notes, the anyEnemyCoresWithin NOT-this-slice
# note -- which was true for N2361 and stays as that slice's
# record -- and N2361's own Windows proof debt -- none of them
# is resolved by this slice) EXCEPT the eachEnemyCore NOT-this-slice
# entry, which THIS slice resolves: the callback shape decision it
# waited for is the Array return, so it is dropped. One entry is
# added: N2365's Windows proof debt.
DEFERRED = [entry for entry in N2361_DEFERRED if 'eachEnemyCore()' not in entry] + [
    'Teams.eachEnemyCore Windows Godot proof -- debt in GOAL.md section 5, same as N2361: the N2365 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    each_enemy_core_inputs = {
        'teams_state': a('Dictionary', 'for(TeamData data : active){', 'The teams state (Teams.eachEnemyCore, Teams.java:87): the family-convention first arg; it carries the active list (kept there by registerCore/unregisterCore, N2074/N2075 -- NOT ported here, only read).'),
        'team_id': a('int', 'if(team != data.team){', 'The calling team id (Teams.java:88, `if(team != data.team){`): the team asking -- its own cores are never candidates, only other active teams\' are.'),
        'enemy_cores': a('Array', 'for(Building tile : data.cores){', 'The enemy cores as explicit records {"team_id": int, "x": float, "y": float} (Teams.java:89, `for(Building tile : data.cores){`): the cores stored in teams_state are opaque refs with no position, so the caller flattens active -> cores and attaches positions (the N2330/N2354 param precedent); only records whose team_id is the active team being scanned are collected.'),
    }
    each_enemy_core_outputs = {
        'cores': a('Array', 'ret.get(tile);', 'The enemy cores as [team_id, x, y] entries (Teams.java:90, `ret.get(tile);`): Java hands each enemy core to the Cons<Building> callback; GDScript has no Java Cons, so the port collects them into the returned Array (main-thread decision 2026-11-21) in active-team order then enemy_cores order; empty when no enemy team has cores.'),
    }
    return (each_enemy_core_inputs, each_enemy_core_outputs)


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
    (each_enemy_core_inputs, each_enemy_core_outputs) = definitions()

    entries = [
        ('N2365', EACH_ENEMY_CORE_OWNER, 'source_teams_each_enemy_core_state', TEAMS, 'mindustry.game.Teams', 'eachEnemyCore', each_enemy_core_inputs, each_enemy_core_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.eachEnemyCore() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.eachEnemyCore() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: cores.
    by_slice['N2365'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2365', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='eachEnemyCore', godot_owner=EACH_ENEMY_CORE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2365'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
