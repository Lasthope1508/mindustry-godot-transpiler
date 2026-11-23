"""Register the Turret readSync() (N2353).

TurretBuild.readSync() (Turret.java:853-861,
`@Override` / `public void readSync(Reads read, byte
revision){` / `//maintain rotation and reload when
syncing so clients don't see turrets snapping around` /
`float oldRot = rotation, oldReload = reloadCounter;` /
`readAll(read, revision);` / `rotation = oldRot;` /
`reloadCounter = oldReload;` / `}`) is one pure
function on SourceTurretBuildState.gd next to the N2322
write/read/version persistence functions. The sync
snapshots the aim rotation and the reload counter,
applies the sync payload via readAll, then restores
both values, so clients do not see turrets snapping
around. readAll(read, revision) is the Building base
call (BuildingComp.java:283-286, `public void
readAll(Reads read, byte revision){` / `readBase(read);`
/ `read(read, revision);`): the payload it applies
arrives as the already-parsed dict read_data --
Building.readAll itself is NOT ported here (the N2330
param precedent). The rotation preserved here is the
RotComp float aim angle (`@SyncField(false) @SyncLocal
float rotation;`, RotComp.java:8), NOT the Building int
rotation 0-3 (`transient int rotation;`,
BuildingComp.java:69) that sense() takes as an
explicit int param; the two are shadowed
(Turret.java:543-544, `//sync underlying rotation; 0-3
rotation is a shadowed field`, the N2322 precedent).
The reload counter is the ReloadTurretBuild field
(`public float reloadCounter;`, ReloadTurret.java:26),
default 0.0, advanced by updateReload
(Turret.java:720-723).

RED decisions (resolved at RED): (1) One slice entry
for the one method, following the N2343/N2348/N2350
precedent (one ledger entry per method group, one
function per method). (2) The frame is the
family-convention first arg and carries the current
rotation/reload_counter; the sync payload arrives as
the explicit dict read_data (already parsed -- the
port has no net stream to parse here); revision is
accepted and passed through to readAll, never
branched on (the N2322 read() guard `if(revision >=
1){` belongs to read(), not to readSync()). (3) The
function returns three keys: rotation and
reload_counter (the preserved values) plus
read_applied, true exactly when the parsed sync
payload is non-empty -- the Turret override applies
whatever readAll read and then restores the two
preserved values. (4) The `readAll(read, revision);`
call line is shared text with N1776
(BuildingComp.readSync, a different class and method)
-- callee evidence, not ownership of
TurretBuild.readSync(); this slice registers the
correct java_method = TurretBuild.readSync() (the
batch-9 scope section 1.2 flag, resolved here, not
stalled on). (5) NO driver tick line: the engine net
sync calls readSync(); no call site is ported here
(the shouldTurn/isShooting precedent). (6) This slice
CLOSES the N2322 deferred readSync entry -- readSync
is now its own slice, as N2322 planned. Three new
result symbols. Four slice sources: Turret.java +
ReloadTurret.java + RotComp.java + BuildingComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_remove_on_destroyed import DEFERRED as N2350_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
ROT_COMP = 'core/src/mindustry/entities/comp/RotComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretReadSyncProof'
READ_SYNC_OWNER = 'SourceTurretBuildState.source_turret_read_sync_state'
TESTS = ['test_c07_turret_read_sync_registration', 'test_all_c07_turret_read_sync_input_evidence_is_exact', 'test_turret_read_sync_state', 'test_reference_graph_and_actual_c07_turret_read_sync']
# The 4 slice sources the N2353 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/comp/RotComp.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
]
EXACT_EXPRS = [
    'public class Turret extends ReloadTurret{',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'public float reloadCounter;',
    '@SyncField(false) @SyncLocal float rotation;',
    'transient int rotation;',
    '@Override',
    'public void readSync(Reads read, byte revision){',
    "//maintain rotation and reload when syncing so clients don't see turrets snapping around",
    'float oldRot = rotation, oldReload = reloadCounter;',
    'readAll(read, revision);',
    'rotation = oldRot;',
    'reloadCounter = oldReload;',
    'public void readAll(Reads read, byte revision){',
]

# DEFERRED is carried from the N2350 register script via import --
# never retyped. The N2322 readSync entry is CLOSED by this slice
# (readSync is now its own slice, as N2322 planned) and replaced
# by a CLOSED entry below; every other entry is carried verbatim.
READSYNC_DEFERRED = 'Port TurretBuild.readSync() (Turret.java:853-862, rotation/reload restore after readAll so clients do not see turrets snapping around) as its own slice; N2322 ports write/read/version only and takes no sync state.'
DEFERRED = [entry for entry in N2350_DEFERRED if entry != READSYNC_DEFERRED] + [
    'TurretBuild.readSync() (Turret.java:853-861, `float oldRot = rotation, oldReload = reloadCounter;` then `readAll(read, revision);` then restore) -- CLOSED by N2353: the N2322 deferred entry ("Port TurretBuild.readSync() ... as its own slice") is now this slice; the `readAll(read, revision);` call line stays shared text with N1776 (BuildingComp.readSync, different class/method) as callee evidence only.',
    'Turret readSync Windows Godot proof -- debt in GOAL.md section 5, same as N2350: the N2353 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    read_sync_inputs = {
        'frame': a('Dictionary', 'public void readSync(Reads read, byte revision){', 'The turret frame (TurretBuild.readSync, Turret.java:853): the family-convention first arg every Turret pure function takes; it carries the current rotation and reload_counter that the sync must preserve (the N2322 read() fallback precedent).'),
        'read_data': a('Dictionary', 'readAll(read, revision);', 'The already-parsed sync payload that readAll applies (`readAll(read, revision);`, Turret.java:857): the Building base call (BuildingComp.java:283-286, `public void readAll(Reads read, byte revision){` / `readBase(read);` / `read(read, revision);`) -- Building.readAll itself is NOT ported here; the payload arrives parsed (the N2330 param precedent).'),
        'revision': a('int', 'public void readSync(Reads read, byte revision){', 'The sync revision (Turret.java:853, `public void readSync(Reads read, byte revision){`): passed through to readAll; the Turret override never branches on it (the N2322 read() guard `if(revision >= 1){` belongs to read(), not to readSync()).'),
    }
    read_sync_outputs = {
        'rotation': a('float', 'rotation = oldRot;', 'The aim rotation after sync (Turret.java:859, `rotation = oldRot;`): the RotComp float aim angle (`@SyncField(false) @SyncLocal float rotation;`, RotComp.java:8), default 0.0 -- NOT the Building int rotation 0-3 (BuildingComp.java:69); restored to the pre-sync value, never the payload value.'),
        'reload_counter': a('float', 'reloadCounter = oldReload;', 'The reload counter after sync (Turret.java:860, `reloadCounter = oldReload;`): the ReloadTurretBuild field (`public float reloadCounter;`, ReloadTurret.java:26), default 0.0; restored to the pre-sync value, never the payload value.'),
        'read_applied': a('bool', 'readAll(read, revision);', 'Whether the sync payload was applied (`readAll(read, revision);`, Turret.java:857): true exactly when the parsed sync payload is non-empty -- the Turret override applies whatever readAll read and then restores the two preserved values.'),
    }
    return (read_sync_inputs, read_sync_outputs)


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
    (read_sync_inputs, read_sync_outputs) = definitions()

    entries = [
        ('N2353', READ_SYNC_OWNER, 'source_turret_read_sync_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.readSync()', read_sync_inputs, read_sync_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.readSync() state from Turret.java + ReloadTurret.java + RotComp.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.readSync() state from Turret.java + ReloadTurret.java + RotComp.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation, reload_counter, read_applied.
    by_slice['N2353'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2353', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.readSync()', godot_owner=READ_SYNC_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2353'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
