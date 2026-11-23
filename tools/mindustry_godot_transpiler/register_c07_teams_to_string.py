"""Register Teams BlockPlan.toString() + TeamData.toString() (N2412).

Teams.BlockPlan.toString() (Teams.java:507-513) and
TeamData.toString() (Teams.java:474-479) are one merged
slice: two debug-only toString methods, 9 exprs
(main-thread decision 2026-11-22, batch 29 slot 2 -- the
N1192 toString precedent).

Only 9 exprs are registered as distinguishing:
BlockPlan (6):
- `return "BlockPlan{" +`
- `"x=" + x +`
- `", y=" + y +`
- `", rotation=" + rotation +`
- `", block=" + block +`
- `", config=" + config +`
TeamData (3):
- `return "TeamData{" +`
- `"cores=" + cores +`
- `", team=" + team +`

NOT registered: the method signatures and the `'}';`
closing line (brief decision).

Pattern (main-thread decision 2026-11-22, batch 29):
two pure functions, one per method, each returning a
one-key Dictionary envelope {"to_string": ...}. The SSOT
contract return_type only accepts Dictionary or void, so
a bare String return is impossible (the N2365 envelope
precedent); the envelope carries the exact Java string.
Java prints null as "null" (GDScript str(null) would
print "Null"), so null inputs are mapped to "null"
explicitly. x/y are the stored short fields (already
narrowed by the ctor, N2409), so no narrowing happens
in toString. Block/config/cores/team are not ported and
arrive as Variants.

java_class note: BlockPlan uses `mindustry.game.Teams$BlockPlan`
(the N2409 precedent, `$` for nested class); TeamData uses
`mindustry.game.Teams.TeamData` (the N2374 precedent for the
same class, dot form).

Two result symbols (one per envelope key). One slice source:
Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_block_plan import DEFERRED as N2409_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsToStringProof'
OWNER_BLOCK_PLAN = 'SourceTeamsRuntimeState.source_teams_block_plan_to_string_state'
OWNER_TEAM_DATA = 'SourceTeamsRuntimeState.source_teams_team_data_to_string_state'
# Ledger godot_owner is the first (BlockPlan) owner; the
# TeamData owner is carried by its own symbols/contracts
# (multi-owner slice precedent: N1381/N1384/N1420).
OWNER = OWNER_BLOCK_PLAN
TESTS = ['test_c07_teams_to_string_registration', 'test_all_c07_teams_to_string_input_evidence_is_exact', 'test_teams_to_string_state', 'test_reference_graph_and_actual_c07_teams_to_string']
# The 1 slice source the N2412 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'return "BlockPlan{" +',
    '"x=" + x +',
    '", y=" + y +',
    '", rotation=" + rotation +',
    '", block=" + block +',
    '", config=" + config +',
    'return "TeamData{" +',
    '"cores=" + cores +',
    '", team=" + team +',
]

# DEFERRED is carried from the N2409 register script via import --
# never retyped. All N2409 entries are carried verbatim (the
# Game chain, the B/C notes, and the N2402/N2409 Windows proof
# debts -- none of them is resolved by this slice). One entry is
# added: N2412's Windows proof debt.
DEFERRED = list(N2409_DEFERRED) + [
    'Teams.BlockPlan.toString()/TeamData.toString() Windows Godot proof -- debt in GOAL.md section 5, same as N2402: the N2412 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    block_plan_inputs = {
        'x': a('int', '"x=" + x +', 'The plan tile x (Teams.java:509, `"x=" + x +`): the stored short field, printed decimal.'),
        'y': a('int', '", y=" + y +', 'The plan tile y (Teams.java:510, `", y=" + y +`): the stored short field, printed decimal.'),
        'rotation': a('int', '", rotation=" + rotation +', 'The plan rotation (Teams.java:511, `", rotation=" + rotation +`): the stored short field, printed decimal.'),
        'block': a('Variant', '", block=" + block +', 'The planned block (Teams.java:512, `", block=" + block +`): Block is not ported, arrives as a Variant, prints via its toString; null prints as "null".'),
        'config': a('Variant', '", config=" + config +', 'The plan config (Teams.java:513, `", config=" + config +`): Object config arrives as a Variant, prints via its toString; null prints as "null".'),
    }
    block_plan_outputs = {
        'to_string': a('String', 'return "BlockPlan{" +', 'The exact Java string (Teams.java:508, `return "BlockPlan{" +`): "BlockPlan{x=.., y=.., rotation=.., block=.., config=..}" in a one-key Dictionary envelope (N2365 precedent -- contract return_type only accepts Dictionary or void).'),
    }
    team_data_inputs = {
        'cores': a('Variant', '"cores=" + cores +', 'The team cores (Teams.java:476, `"cores=" + cores +`): ObjectSet<Core> is not ported, arrives as a Variant, prints via its toString; null prints as "null".'),
        'team': a('Variant', '", team=" + team +', 'The team (Teams.java:477, `", team=" + team +`): Team is not ported, arrives as a Variant, prints via its toString; null prints as "null".'),
    }
    team_data_outputs = {
        'to_string': a('String', 'return "TeamData{" +', 'The exact Java string (Teams.java:475, `return "TeamData{" +`): "TeamData{cores=.., team=..}" in a one-key Dictionary envelope (N2365 precedent).'),
    }
    return (block_plan_inputs, block_plan_outputs, team_data_inputs, team_data_outputs)


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
    for pair in [(inputs_outputs[0], inputs_outputs[1]), (inputs_outputs[2], inputs_outputs[3])]:
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
        ('N2412', OWNER_BLOCK_PLAN, 'source_teams_block_plan_to_string_state', TEAMS, 'mindustry.game.Teams$BlockPlan', 'Teams.BlockPlan.toString()', pairs[0], pairs[1], True, 'Dictionary'),
        ('N2412', OWNER_TEAM_DATA, 'source_teams_team_data_to_string_state', TEAMS, 'mindustry.game.Teams.TeamData', 'TeamData.toString()', pairs[2], pairs[3], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams toString state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams toString state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2412'] = [
        'source_teams_block_plan_to_string_state_result.to_string',
        'source_teams_team_data_to_string_state_result.to_string',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2412', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams$BlockPlan', java_method='Teams.BlockPlan.toString()/TeamData.toString()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2412'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
