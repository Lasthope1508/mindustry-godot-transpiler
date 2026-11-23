"""Register Teams.destroyPayload() (N2402).

Teams.destroyPayload()
(Teams.java:483-488,
`if(build != null && build.getPayload() instanceof UnitPayload && build.takePayload() instanceof UnitPayload unit){` /
`unit.dump();` / `unit.unit.killed();`) is one slice: the
server-side body of the @Remote static -- @Remote is
transport metadata (Call.destroyPayload), NOT behavior, so
the annotation is recorded in this note only, never as a
distinguishing expr (main-thread decision 2026-11-22,
batch 25 slot 3, due from the batch 24 decision to keep
updateActive+ctor and decide destroyPayload separately).
The body is pure deterministic logic: when the build is
present and its payload is a UnitPayload, take the
payload, dump it and kill its unit.

Callees -- NOT re-registered as distinguishing exprs:
- `build.getPayload()` / `build.takePayload()` -- the
  payload accessors (Building is not ported): they arrive
  as the take_payload Callable (build) plus the
  has_unit_payload bool for the getPayload() instanceof
  check; takePayload() returns the same payload
  getPayload() saw, so its instanceof check is the
  payload-is-Dictionary check in the GD function.
- `Call.destroyPayload(build)` -- the network call that
  WRAPS this method (used by TeamData.scheduleDerelict,
  Teams.java:401, already the exact_expr of N2395 as a
  destroy_payload Callable param): the annotation /
  Call transport is never ported, no packet is ever sent.
- `unit.dump()` / `unit.unit.killed()` -- the payload
  dump and the unit kill: they arrive as the dump_payload
  Callable (payload) and the kill_unit Callable (unit)
  and are recorded in the frame.

Three new result symbols. One slice source: Teams.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_update_active import DEFERRED as N2399_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsDestroyPayloadProof'
OWNER = 'SourceTeamsRuntimeState.source_teams_destroy_payload_state'
TESTS = ['test_c07_teams_destroy_payload_registration', 'test_all_c07_teams_destroy_payload_input_evidence_is_exact', 'test_teams_destroy_payload_state', 'test_reference_graph_and_actual_c07_teams_destroy_payload']
# The 1 slice source the N2402 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'if(build != null && build.getPayload() instanceof UnitPayload && build.takePayload() instanceof UnitPayload unit){',
    'unit.dump();',
    'unit.unit.killed();',
]

# DEFERRED is carried from the N2399 register script via import --
# never retyped. All N2399 entries are carried verbatim (the
# Game chain, the B/C notes, and N2399's own Windows proof
# debt -- none of them is resolved by this slice). One entry is
# added: N2402's Windows proof debt.
DEFERRED = list(N2399_DEFERRED) + [
    'Teams.destroyPayload() Windows Godot proof -- debt in GOAL.md section 5, same as N2399: the N2402 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    inputs = {
        'build': a('Variant', 'public static void destroyPayload(Building build){', 'The build whose payload is destroyed (Teams.java:483, `public static void destroyPayload(Building build){`): Building is not ported, so it arrives as a Variant -- the build record, or null when absent (the `build != null` guard, Teams.java:484).'),
        'has_unit_payload': a('bool', 'if(build != null && build.getPayload() instanceof UnitPayload && build.takePayload() instanceof UnitPayload unit){', 'Whether the build carries a UnitPayload (Teams.java:484, `build.getPayload() instanceof UnitPayload`): getPayload() is a Building accessor, not ported -- its instanceof result arrives as this bool; takePayload() returns the same payload, so this bool also gates the takePayload() instanceof check.'),
        'take_payload': a('Callable', 'if(build != null && build.getPayload() instanceof UnitPayload && build.takePayload() instanceof UnitPayload unit){', 'The payload take hook (Teams.java:484, `build.takePayload() instanceof UnitPayload unit`): takePayload() removes and returns the build payload -- it arrives as a Callable (build) returning the taken payload record (a Dictionary with a "unit" key) or null; the instanceof on its result is the payload-is-Dictionary check in the GD function.'),
        'dump_payload': a('Callable', 'unit.dump();', 'The payload dump hook (Teams.java:485, `unit.dump();`): UnitPayload.dump() drops the unit into the world -- it arrives as a Callable (payload) and is recorded in the frame; nothing is dumped here.'),
        'kill_unit': a('Callable', 'unit.unit.killed();', 'The unit kill hook (Teams.java:486, `unit.unit.killed();`): the payload unit is killed -- it arrives as a Callable (unit) and is recorded in the frame; nothing is killed here.'),
    }
    outputs = {
        'destroyed_payload': a('Variant', 'if(build != null && build.getPayload() instanceof UnitPayload && build.takePayload() instanceof UnitPayload unit){', 'The destroyed payload (Teams.java:484, `build.takePayload() instanceof UnitPayload unit`): the taken UnitPayload record when the guard passed and the taken payload was a record with a "unit" key, else null.'),
        'dumped_payloads': a('Array', 'unit.dump();', 'The dumped payloads (Teams.java:485, `unit.dump();`): the payload records passed to dump_payload, in call order -- empty when the guard did not pass or the taken payload was not a record.'),
        'killed_units': a('Array', 'unit.unit.killed();', 'The killed units (Teams.java:486, `unit.unit.killed();`): the units passed to kill_unit, in call order -- empty when the guard did not pass or the taken payload was not a record.'),
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
    inputs_outputs = definitions()
    total = len(EXACT_EXPRS)
    for pair in [inputs_outputs]:
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
        ('N2402', OWNER, 'source_teams_destroy_payload_state', TEAMS, 'mindustry.game.Teams', 'Teams.destroyPayload()', pairs[0], pairs[1], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams destroyPayload() state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams destroyPayload() state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2402'] = [
        'source_teams_destroy_payload_state_result.destroyed_payload',
        'source_teams_destroy_payload_state_result.dumped_payloads',
        'source_teams_destroy_payload_state_result.killed_units',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2402', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='Teams.destroyPayload()', godot_owner=OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2402'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
