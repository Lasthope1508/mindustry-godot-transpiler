"""Register Teams.count() payload branch (N2415).

Teams.count(Unit unit) (Teams.java:168-179,
`private void count(Unit unit){` /
`unit.team.data().updateCount(unit.type, 1);` /
`if(unit instanceof Payloadc payloadc){` /
`var payloads = payloadc.payloads();` /
`for(int i = 0; i < payloads.size; i++){` /
`if(payloads.get(i) instanceof UnitPayload payload){` /
`count(payload.unit);` /
`}` /
`}` /
`}`) is a sub-slice (batch 30 slot 2, the N2408
sub-slice precedent): the method body is already owned
in large part by N2141 (the signature, the updateCount
call, the count(payload.unit) recursion), so only the
4 payload-branch exprs are registered here:
- `if(unit instanceof Payloadc payloadc){`
- `var payloads = payloadc.payloads();`
- `for(int i = 0; i < payloads.size; i++){`
- `if(payloads.get(i) instanceof UnitPayload payload){`

NOT registered: the signature `private void count(Unit
unit){`, the updateCount call
`unit.team.data().updateCount(unit.type, 1);`, and the
recursion `count(payload.unit);` -- all three are
already the exact_exprs of N2141 (both ledgers, checked
at spawn). They are reached here by call-site only:
the updateCount call through the
source_team_data_update_count_state callee (N2141) and
the recursion through the _team_data_count_unit helper
(N2383).

Pattern: one pure function, payloads as an explicit
Array param (the N2408 precedent: live Units/world
queries become params). The caller passes
payloadc.payloads() -- the unit only reaches this
function when it is a Payloadc, so the instanceof
Payloadc gate and the payloads() call live at the
call-site (the _team_data_count_unit helper reads the
unit record's "payload_units" entry). Each payload
entry is a unit record when it is a UnitPayload; other
payloads carry no unit record and are skipped. The
function returns the three count views (type_counts,
unit_count, team_unit_counts) plus the source_owner
stamp, in the N2141 result shape.

java_class note: `mindustry.game.Teams` (the N2383
precedent for the same class).

Three result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_to_string import DEFERRED as N2412_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsCountPayloadBranchProof'
OWNER = 'SourceTeamsRuntimeState.source_teams_count_payload_branch_state'
TESTS = ['test_c07_teams_count_payload_branch_registration', 'test_all_c07_teams_count_payload_branch_input_evidence_is_exact', 'test_teams_count_payload_branch_state', 'test_reference_graph_and_actual_c07_teams_count_payload_branch']
# The 1 slice source the N2415 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'if(unit instanceof Payloadc payloadc){',
    'var payloads = payloadc.payloads();',
    'for(int i = 0; i < payloads.size; i++){',
    'if(payloads.get(i) instanceof UnitPayload payload){',
]

# DEFERRED is carried from the N2412 register script via import --
# never retyped. All N2412 entries are carried verbatim (the
# Game chain, the B/C notes, and the N2412 Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2415's Windows proof debt.
DEFERRED = list(N2412_DEFERRED) + [
    'Teams.count() payload branch Windows Godot proof -- debt in GOAL.md section 5, same as N2412: the N2415 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'payloads': a('Array', 'var payloads = payloadc.payloads();', 'The payloads Seq (Teams.java:173, `var payloads = payloadc.payloads();`): payloadc.payloads() is a live entity query (not ported), so the payloads arrive as an explicit Array of payload entries -- a unit record {\"team_id\": int, \"type_id\": int, \"type_name\": String, \"payload_units\": [...]} when the entry is a UnitPayload, any other Variant (a raw value, a block payload record with no type_id) otherwise.'),
        'team_id': a('int', 'unit.team.data().updateCount(unit.type, 1);', 'The team whose data count() updates (Teams.java:170, `unit.team.data().updateCount(unit.type, 1);`): the carrier unit\'s team arrives as its team id -- the recursion counts each payload unit into its own team\'s data when the team matches, and skips it in this single-team frame view when it does not (same as the N2383 helper\'s team gate).'),
        'type_counts': a('Array', 'if(data.typeCounts != null){', 'The per-type counts (Teams.java:189, `if(data.typeCounts != null){`): TeamData.typeCounts arrives as an explicit Array of ints, grown to content_unit_size by the updateCount callee (N2141) -- type_counts is an in/out param, the caller\'s Array is the one the recursion extends.'),
        'unit_count': a('int', 'data.unitCount = 0;', 'The unit count (Teams.java:186, `data.unitCount = 0;`): TeamData.unitCount arrives explicitly -- every counted payload unit bumps it by 1 through the updateCount callee (N2141).'),
        'content_unit_size': a('int', 'data.unitsByType = new Seq[content.units().size];', 'content.units().size as an explicit param (Teams.java:226, `data.unitsByType = new Seq[content.units().size];`): the content registry is not ported, so the unit-type count arrives explicitly -- it sizes the type_counts growth inside the count() callee (the N2383 precedent).'),
        'team_unit_counts': a('Dictionary', 'count(unit);', 'The name-keyed unit counts (Teams.java:235, `count(unit);`): {type_name: count} -- the N2141 count() callee\'s per-team view, one entry per counted type, payload units included exactly as count(unit) recurses -- team_unit_counts is an in/out param.'),
    }
    outputs = {
        'type_counts': a('Array', 'count(payload.unit);', 'The per-type counts after the branch (Teams.java:177, `count(payload.unit);`): every UnitPayload unit\'s type count bumped by 1 through the count() recursion -- the same Array passed in, extended to content_unit_size.'),
        'unit_count': a('int', 'unit.team.data().updateCount(unit.type, 1);', 'The unit count after the branch (Teams.java:170, `unit.team.data().updateCount(unit.type, 1);`): bumped by 1 per counted payload unit through the updateCount callee (N2141).'),
        'team_unit_counts': a('Dictionary', 'if(payloads.get(i) instanceof UnitPayload payload){', 'The name-keyed unit counts after the branch (Teams.java:176, `if(payloads.get(i) instanceof UnitPayload payload){`): only UnitPayload entries reach the count() call that fills this view -- non-unit payloads add nothing.'),
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
        ('N2415', OWNER, 'source_teams_count_payload_branch_state', TEAMS, 'mindustry.game.Teams', 'Teams.count(Unit)', pairs[0], pairs[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams.count() payload branch state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams.count() payload branch state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: type_counts, unit_count,
    # team_unit_counts.
    by_slice['N2415'] = [
        'source_teams_count_payload_branch_state_result.type_counts',
        'source_teams_count_payload_branch_state_result.unit_count',
        'source_teams_count_payload_branch_state_result.team_unit_counts',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2415', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='Teams.count(Unit)', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2415'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
