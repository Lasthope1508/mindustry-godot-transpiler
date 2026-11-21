"""Register the PayloadTurretBuild hasAmmo()+acceptPayload()+handlePayload() group (N2387).

PayloadTurretBuild hasAmmo()+acceptPayload()+handlePayload()
(PayloadAmmoTurret.java:107-110/:112-115/:117-120,
`public boolean acceptPayload(Building source, Payload payload){` /
`return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());` /
`public void handlePayload(Building source, Payload payload){` /
`payloads.add(payload.content());` /
`public boolean hasAmmo(){` /
`return payloads.total() > 0;`)
is one grouped pure-function slice on the existing
SourcePayloadAmmoTurretBuildPortBridge.gd (created by N2358
for currentAmmo), following the grouped multi-function
precedent (N2330, `Drill.canPlaceOn(Tile tile, Team team,
int rotation)/Drill.setBars()/Drill.drawPlanConfig(BuildPlan
plan, Eachable<BuildPlan> list)` -- one slice record, one
owner per function, several java_method entries joined by
"/") and the grouped version/write/read precedent (N2375).

RED decisions (resolved at RED): (1) The functions live
in the existing PortBridge file: these are Build methods of
PayloadTurretBuild, but the class methods of the same file
already live in the PortBridge (N2358 currentAmmo, N2363
useAmmo, N2368 getAmmoContent, N2371 peekAmmo, N2376
write/read, N2381 displayBars/updateTile/getPayloads,
N2384 limitRange/setStats) and there is no
SourcePayloadAmmoTurretBuildState.gd to delegate to.
The SSOT owners are PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2358 PortGame.source_payload_ammo_turret_build_current_ammo_state,
N2384 PortGame.source_payload_ammo_turret_limit_range_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame. The slice record owner is
the hasAmmo owner
(PortGame.source_payload_ammo_turret_build_has_ammo_state);
acceptPayload and handlePayload each carry their own owner
and contract, exactly like N2330's three owners -- one
contract per owner, because contracts are keyed by owner
and a single contract could not carry the three functions'
return keys (the N2378 lesson: contract name == function
name).
(2) Each method alone is one distinguishing line, so the
three group into one slice of three distinguishing exprs,
same Build class, same `payloads` / `maxAmmo` / `ammoTypes`
concern -- the N2330 grouping precedent, main thread
approved as batch 20 slot 3 (the batch 11 decision left
this group undecided -- "de batch 12+ xem xet rieng" --
and batch 20 approves it now).
(3) `payloads` (PayloadSeq, PayloadAmmoTurret.java:95)
arrives as the explicit payload_contents param -- one
entry per payload unit, so total() is exactly
payload_contents.size() (the N2381 updateTile precedent).
`maxAmmo` is the constructor field (`maxAmmo = 3;`,
PayloadAmmoTurret.java:28) and arrives as an explicit int
param. `ammoTypes` (ObjectMap<UnlockableContent,
BulletType>, PayloadAmmoTurret.java:22) arrives as the
explicit ammo_types Dictionary param (content name ->
bullet type name); ObjectMap is NOT ported.
`payload.content()` is a field on the given Payload --
it arrives as the explicit payload_content param (content
name or null); `Payload`/`PayloadSeq` are NOT ported.
The `source` (Building) param of acceptPayload /
handlePayload is unused in the bodies and is NOT a param.
The handlePayload mutation is modeled as param in/out
(the N2313 param precedent): the function duplicates the
contents, appends the content, and returns the updated
list -- the input array is never mutated. A null content
is a no-op (`PayloadSeq.add` returns early on null,
PayloadSeq.java:35-37).
(4) The method headers are shared text (acceptPayload
hits N1415/N2131, handlePayload hits N586, hasAmmo hits
N1171/N1203/N1228/N2285/N2301/N2311/N2313/N2316 in the
local ledger) -- evidence only, NOT distinguishing exprs
(the N632-N639 vs N1078-N1085 precedent allows the same
text under its own java_method). The distinguishing lines
are `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`,
`payloads.add(payload.content());` and
`return payloads.total() > 0;`
(all 0-hit in both ledgers at HEAD 1047fc24, re-probed
at the new base).
(5) Content refs are plain strings (content names);
each result carries exactly one key. NO driver line:
pure intake predicates / seq update -- the caller wiring
waits for its own slice.
(6) Evidence, not ownership: `@Override` also appears
at PayloadAmmoTurret.java:50 and on every other override
in the file. Three new result symbols: has_ammo,
accepts_payload, payload_contents. Slice source:
PayloadAmmoTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_turret_limit_range import DEFERRED as N2384_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
PROOF = '/root/C07PayloadTurretPayloadIntakeProof'
HAS_AMMO_OWNER = 'PortGame.source_payload_ammo_turret_build_has_ammo_state'
ACCEPT_PAYLOAD_OWNER = 'PortGame.source_payload_ammo_turret_build_accept_payload_state'
HANDLE_PAYLOAD_OWNER = 'PortGame.source_payload_ammo_turret_build_handle_payload_state'
TESTS = ['test_c07_payload_turret_payload_intake_registration', 'test_all_c07_payload_turret_payload_intake_input_evidence_is_exact', 'test_payload_turret_payload_intake_state', 'test_reference_graph_and_actual_c07_payload_turret_payload_intake']
# The 1 slice source the N2387 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'public class PayloadAmmoTurret extends Turret{',
    'public class PayloadTurretBuild extends TurretBuild{',
    '@Override',
    'public boolean acceptPayload(Building source, Payload payload){',
    'return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());',
    'public void handlePayload(Building source, Payload payload){',
    'payloads.add(payload.content());',
    'public boolean hasAmmo(){',
    'return payloads.total() > 0;',
]

# DEFERRED is carried from the N2384 register script via import --
# never retyped. This slice closes none of the carried entries;
# it only adds its own Windows-proof debt entry.
DEFERRED = list(N2384_DEFERRED) + [
    'PayloadTurretBuild hasAmmo/acceptPayload/handlePayload Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2387 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    has_ammo_inputs = {
        'payload_contents': a('Array', 'return payloads.total() > 0;', 'The held payload contents (PayloadAmmoTurret.java:119, `return payloads.total() > 0;`): one entry per payload unit from the `public PayloadSeq payloads` field (PayloadAmmoTurret.java:95) -- total() is exactly payload_contents.size() (the N2381 updateTile precedent).'),
    }
    has_ammo_outputs = {
        'has_ammo': a('bool', 'return payloads.total() > 0;', 'Whether any payload unit is held (PayloadAmmoTurret.java:119, `return payloads.total() > 0;`): true iff the payloads seq is non-empty.'),
    }
    accept_payload_inputs = {
        'payload_contents': a('Array', 'return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());', 'The held payload contents (PayloadAmmoTurret.java:109, `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`): one entry per payload unit from the `public PayloadSeq payloads` field (PayloadAmmoTurret.java:95) -- total() is exactly payload_contents.size() (the N2381 updateTile precedent).'),
        'max_ammo': a('int', 'return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());', 'The intake capacity (PayloadAmmoTurret.java:109, `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`): the constructor field (`maxAmmo = 3;`, PayloadAmmoTurret.java:28) -- arrives as an explicit int param.'),
        'ammo_types': a('Dictionary', 'return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());', 'The ammo types (PayloadAmmoTurret.java:109, `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`): content name -> bullet type name from the `public ObjectMap<UnlockableContent, BulletType> ammoTypes` field (PayloadAmmoTurret.java:22) -- ObjectMap is NOT ported (the N2330 param precedent).'),
        'payload_content': a('Variant', 'return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());', 'The incoming payload content (PayloadAmmoTurret.java:109, `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`): the `payload.content()` field on the given Payload -- arrives as an explicit param (content name or null); `Payload`/`PayloadSeq` are NOT ported.'),
    }
    accept_payload_outputs = {
        'accepts_payload': a('bool', 'return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());', 'Whether the payload is accepted (PayloadAmmoTurret.java:109, `return payloads.total() < maxAmmo && ammoTypes.containsKey(payload.content());`): true iff the held total is below maxAmmo AND the payload content is an ammo type.'),
    }
    handle_payload_inputs = {
        'payload_contents': a('Array', 'payloads.add(payload.content());', 'The held payload contents (PayloadAmmoTurret.java:114, `payloads.add(payload.content());`): one entry per payload unit from the `public PayloadSeq payloads` field (PayloadAmmoTurret.java:95) -- arrives as an explicit param; the function duplicates it and returns the updated list (the N2313 param precedent).'),
        'payload_content': a('Variant', 'payloads.add(payload.content());', 'The incoming payload content (PayloadAmmoTurret.java:114, `payloads.add(payload.content());`): the `payload.content()` field on the given Payload -- arrives as an explicit param (content name or null); a null content is a no-op (`PayloadSeq.add` returns early on null, PayloadSeq.java:35-37).'),
    }
    handle_payload_outputs = {
        'payload_contents': a('Array', 'payloads.add(payload.content());', 'The updated payload contents (PayloadAmmoTurret.java:114, `payloads.add(payload.content());`): the input contents plus the new content appended (unchanged on null content) -- a fresh array, the input is never mutated.'),
    }
    return (has_ammo_inputs, has_ammo_outputs), (accept_payload_inputs, accept_payload_outputs), (handle_payload_inputs, handle_payload_outputs)


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
    inputs_outputs = list(definitions())
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
    (has_ammo_inputs, has_ammo_outputs), (accept_payload_inputs, accept_payload_outputs), (handle_payload_inputs, handle_payload_outputs) = definitions()

    entries = [
        ('N2387', HAS_AMMO_OWNER, 'source_payload_ammo_turret_build_has_ammo_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurretBuild.hasAmmo()', has_ammo_inputs, has_ammo_outputs, True, 'Dictionary'),
        ('N2387', ACCEPT_PAYLOAD_OWNER, 'source_payload_ammo_turret_build_accept_payload_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurretBuild.acceptPayload()', accept_payload_inputs, accept_payload_outputs, True, 'Dictionary'),
        ('N2387', HANDLE_PAYLOAD_OWNER, 'source_payload_ammo_turret_build_handle_payload_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', 'PayloadAmmoTurretBuild.handlePayload()', handle_payload_inputs, handle_payload_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurretBuild.hasAmmo()+acceptPayload()+handlePayload() state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadAmmoTurretBuild.hasAmmo()+acceptPayload()+handlePayload() state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: has_ammo has_ammo,
    # accept_payload accepts_payload, handle_payload
    # payload_contents.
    by_slice['N2387'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2387', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret', java_method='PayloadAmmoTurretBuild.hasAmmo(); PayloadAmmoTurretBuild.acceptPayload(); PayloadAmmoTurretBuild.handlePayload()', godot_owner=HAS_AMMO_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2387'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
