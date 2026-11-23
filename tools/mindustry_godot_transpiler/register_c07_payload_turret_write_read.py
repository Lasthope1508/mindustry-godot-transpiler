"""Register the PayloadTurret write()+read() group (N2376).

PayloadTurretBuild.write()+read()
(PayloadAmmoTurret.java:179-190, `public void
write(Writes write){` / `super.write(write);` /
`payloads.write(write);` / `public void read(Reads
read, byte revision){` / `super.read(read, revision);`
/ `payloads.read(read);` /
`payloads.removeAll(u -> !ammoTypes.containsKey(u));`)
is one grouped pure function on the existing
SourcePayloadAmmoTurretBuildPortBridge.gd (created by N2358
for currentAmmo), following the ContinuousTurret PortBridge
precedent (SourceContinuousTurretBuildPortBridge.gd, N2355)
and the grouped version/write/read precedent
(N2375, `ContinuousTurretBuild.version();
ContinuousTurretBuild.write(Writes);
ContinuousTurretBuild.read(Reads, byte)` -- one record,
one owner, several java_method entries joined by "; ").

RED decisions (resolved at RED): (1) The function lives
in the existing PortBridge file: there is no
SourcePayloadAmmoTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2358 PortGame.source_payload_ammo_turret_build_current_ammo_state,
N2363 PortGame.source_payload_ammo_turret_build_use_ammo_state,
N2368 PortGame.source_payload_ammo_turret_build_get_ammo_content_state,
N2371 PortGame.source_payload_turret_build_peek_ammo_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame.
(2) write and read are grouped in ONE pure function
(the N2375 precedent): the write side takes the held
payload contents and returns the persisted contents in
order; the read side takes the stored contents read back
from the stream plus ammoTypes and returns the stored
contents filtered to ammoTypes members. `revision` is
NOT a param: the read body never reads it (unlike N2375,
where `if(revision >= 3){` gates the read).
(3) `payloads` (PayloadSeq, PayloadAmmoTurret.java:95)
arrives as the explicit payload_contents param (write
input) and the stored seq as the explicit
stored_payload_contents param (read input); `ammoTypes`
(ObjectMap<UnlockableContent, BulletType>,
PayloadAmmoTurret.java:22) arrives as the explicit
ammo_types Dictionary param (content name -> bullet type
name); ObjectMap is NOT ported (the N2330 param precedent).
The payloads.write/read stream calls themselves are NOT
ported: the write result is a copy of the held contents
(the persisted form, in order) and the read result is the
stored contents filtered by `ammoTypes.containsKey`
(`payloads.removeAll(u -> !ammoTypes.containsKey(u));`
keeps exactly the contents whose type is in ammoTypes).
(4) `super.write(write);` / `super.read(read, revision);`
are callee/context (TurretBuild.write/read already owned
by N2322) -- NOT distinguishing exprs. The distinguishing
lines are `payloads.write(write);`, `payloads.read(read);`
and `payloads.removeAll(u -> !ammoTypes.containsKey(u));`
(all three 0-hit in both ledgers at HEAD 76d71f1e).
(5) Content refs are plain strings (content names);
the result carries exactly two keys. NO driver line: pure
persistence functions, not a per-tick write; the caller
wiring waits for its own slice.
(6) Evidence, not ownership: `@Override` also appears
at PayloadAmmoTurret.java:180/:186 and on every other
override in the file; `super.write(write);` /
`super.read(read, revision);` are the TurretBuild
callee lines. Two new result symbols:
write_payload_contents, payload_contents. Slice source:
PayloadAmmoTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_payload_turret_peek_ammo import DEFERRED as N2371_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
PAYLOAD_AMMO_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java'
PROOF = '/root/C07PayloadTurretWriteReadProof'
WRITE_READ_OWNER = 'PortGame.source_payload_ammo_turret_build_write_read_state'
TESTS = ['test_c07_payload_turret_write_read_registration', 'test_all_c07_payload_turret_write_read_input_evidence_is_exact', 'test_payload_turret_write_read_state', 'test_reference_graph_and_actual_c07_payload_turret_write_read']
# The 1 slice source the N2376 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/PayloadAmmoTurret.java',
]
EXACT_EXPRS = [
    'public class PayloadAmmoTurret extends Turret{',
    'public class PayloadTurretBuild extends TurretBuild{',
    'public PayloadSeq payloads = new PayloadSeq();',
    '@Override',
    'public void write(Writes write){',
    'super.write(write);',
    'payloads.write(write);',
    'public void read(Reads read, byte revision){',
    'super.read(read, revision);',
    'payloads.read(read);',
    'payloads.removeAll(u -> !ammoTypes.containsKey(u));',
]

# DEFERRED is carried from the N2371 register script via import --
# never retyped. This slice closes none of the carried entries;
# it only adds its own Windows-proof debt entry.
DEFERRED = list(N2371_DEFERRED) + [
    'PayloadTurret write/read Windows Godot proof -- debt in GOAL.md section 5, same as N2353: the N2376 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=PAYLOAD_AMMO_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    write_read_inputs = {
        'payload_contents': a('Array', 'public PayloadSeq payloads = new PayloadSeq();', 'The contents currently held in the payloads seq (PayloadAmmoTurret.java:95, `public PayloadSeq payloads = new PayloadSeq();`): the write input -- what `payloads.write(write);` (PayloadAmmoTurret.java:181) persists, in order; the payloads.write stream call itself is NOT ported, its contents arrive as an explicit param (the N2330 param precedent).'),
        'stored_payload_contents': a('Array', 'payloads.read(read);', 'The contents read back from the stream (PayloadAmmoTurret.java:188, `payloads.read(read);`): the read input -- what `payloads.read(read);` restores before the removeAll filter; the payloads.read stream call itself is NOT ported, its contents arrive as an explicit param (the N2330 param precedent).'),
        'ammo_types': a('Dictionary', 'public ObjectMap<UnlockableContent, BulletType> ammoTypes = new ObjectMap<>();', 'The ammo-type map (PayloadAmmoTurret.java:22, `public ObjectMap<UnlockableContent, BulletType> ammoTypes = new ObjectMap<>();`): content name to bullet type name; ObjectMap is NOT ported, it arrives as an explicit Dictionary param (the N2330 param precedent). Only its keys are used, in `payloads.removeAll(u -> !ammoTypes.containsKey(u));` (PayloadAmmoTurret.java:189).'),
    }
    write_read_outputs = {
        'write_payload_contents': a('Array', 'payloads.write(write);', 'The persisted payload contents (PayloadAmmoTurret.java:181, `payloads.write(write);`): the held contents in order, as written to the stream -- a copy of the payload_contents input; the result is a fresh array, the input is never mutated.'),
        'payload_contents': a('Array', 'payloads.removeAll(u -> !ammoTypes.containsKey(u));', 'The restored payload contents (PayloadAmmoTurret.java:189, `payloads.removeAll(u -> !ammoTypes.containsKey(u));`): the stored contents filtered to the ones whose type is in ammoTypes, in stored order -- contents whose type has no ammoTypes entry are dropped, exactly as PayloadSeq.removeAll does after `payloads.read(read);` (PayloadAmmoTurret.java:188).'),
    }
    return (write_read_inputs, write_read_outputs)


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
    (write_read_inputs, write_read_outputs) = definitions()

    entries = [
        ('N2376', WRITE_READ_OWNER, 'source_payload_ammo_turret_build_write_read_state', PAYLOAD_AMMO_TURRET, 'mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', 'PayloadTurretBuild.write(Writes); PayloadTurretBuild.read(Reads, byte)', write_read_inputs, write_read_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.write()+read() state from PayloadAmmoTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed PayloadTurretBuild.write()+read() state from PayloadAmmoTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: write_payload_contents, payload_contents.
    by_slice['N2376'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2376', dict(status='done', java_source=PAYLOAD_AMMO_TURRET, java_class='mindustry.world.blocks.defense.turrets.PayloadAmmoTurret.PayloadTurretBuild', java_method='PayloadTurretBuild.write(Writes); PayloadTurretBuild.read(Reads, byte)', godot_owner=WRITE_READ_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2376'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
