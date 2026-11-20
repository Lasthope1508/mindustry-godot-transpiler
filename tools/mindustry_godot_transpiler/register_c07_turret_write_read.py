"""Register the Turret write/read/version persistence (N2276).

TurretBuild.write()/read()/version() (Turret.java:831-850)
persist exactly TWO fields, the reload counter and the aim
rotation (`write.f(reloadCounter);` / `write.f(rotation);`,
Turret.java:833-834, inside `public void write(Writes
write){` / `super.write(write);`, Turret.java:831-832),
restore them only for saves at revision >= 1
(`if(revision >= 1){ reloadCounter = read.f(); rotation
= read.f(); }`, Turret.java:841-844, inside `public void
read(Reads read, byte revision){` / `super.read(read,
revision);`, Turret.java:838-839), and report save
version 1 (`public byte version(){ return 1; }`,
Turret.java:848-850; the BuildingComp base returns 0,
BuildingComp.java:669-671). The reload counter is the
ReloadTurretBuild field (`public float reloadCounter;`,
ReloadTurret.java:26), default 0.0, advanced by
updateReload (Turret.java:720-723) and read by
shouldConsume (Turret.java:364-366). The rotation is the
RotComp float aim angle (`@SyncField(false) @SyncLocal
float rotation;`, RotComp.java:8), default 0.0 -- NOT the
Building int rotation 0-3 (`transient int rotation;`,
BuildingComp.java:69) that sense() takes as an explicit
int param; the two are shadowed (Turret.java:543-544,
`//sync underlying rotation; 0-3 rotation is a shadowed
field`, `((Building)this).rotation =
Mathf.mod(Mathf.round(rotation / 90f), 4);`).

RED decisions (resolved at RED): (1) Three pure functions
on the same family file -- write takes the frame only and
reads both values from frame keys (the N2217 RepairTurret
precedent: reload_counter is a tracked frame key, the
tick driver reads it); read takes the two stored values +
revision and applies them only at revision >= 1, else
keeps the frame's current values; version returns the
constant 1. (2) super.write/read are empty BuildingComp
bodies ("overriden by subclasses!") -- only the marker is
recorded. (3) readSync() is its own slice, not included
here. (4) NO driver tick line: persistence is not a
per-tick call, and the port has no save/load stream to
call these functions yet -- wiring them into a save/load
path waits for a persistence-integration slice. (5) The
frame "rotation" key is the RotComp float aim angle, never
the Building int rotation. (6) Java write.f is a 32-bit
float while GDScript float is 64-bit -- the pure
functions add NO rounding epsilon; the proof round-trips
float32-safe values exactly and checks the inexact value
0.1 with is_equal_approx. Five new result symbols:
write.reload_counter, write.rotation,
read.reload_counter, read.rotation, version.version.
Four slice sources: Turret.java + ReloadTurret.java +
RotComp.java + BuildingComp.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_tracking_range import DEFERRED as N2319_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
ROT_COMP = 'core/src/mindustry/entities/comp/RotComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretWriteReadProof'
WRITE_OWNER = 'SourceTurretBuildState.source_turret_write_state'
READ_OWNER = 'SourceTurretBuildState.source_turret_read_state'
VERSION_OWNER = 'SourceTurretBuildState.source_turret_version_state'
TESTS = ['test_c07_turret_write_read_registration', 'test_all_c07_turret_write_read_input_evidence_is_exact', 'test_turret_write_read_state', 'test_reference_graph_and_actual_c07_turret_write_read']
# The 4 slice sources the N2276 test checks exact_exprs
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
    'public class ReloadTurret extends BaseTurret{',
    'public class ReloadTurretBuild extends BaseTurretBuild{',
    'public float reloadCounter;',
    'public float reload = 10f;',
    '@SyncField(false) @SyncLocal float rotation;',
    'transient int rotation;',
    'public void write(Writes write){',
    'super.write(write);',
    'write.f(reloadCounter);',
    'write.f(rotation);',
    'public void read(Reads read, byte revision){',
    'super.read(read, revision);',
    'if(revision >= 1){',
    'reloadCounter = read.f();',
    'rotation = read.f();',
    'public byte version(){',
    'return 1;',
    'return 0;',
    '//overriden by subclasses!',
    '//sync underlying rotation; 0-3 rotation is a shadowed field',
    '((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);',
    'public void readSync(Reads read, byte revision){',
    "//maintain rotation and reload when syncing so clients don't see turrets snapping around",
]

# DEFERRED is carried from the N2319 register script via import --
# never retyped. Nothing in it closes here: write/read/version
# was never a deferred entry of the Turret chain. Two entries
# are added: the readSync follow-up (its own slice) and the
# N2276 Windows Godot proof debt (GOAL.md section 5).
DEFERRED = N2319_DEFERRED + [
    'Port TurretBuild.readSync() (Turret.java:853-862, rotation/reload restore after readAll so clients do not see turrets snapping around) as its own slice; N2276 ports write/read/version only and takes no sync state.',
    'Turret write/read/version Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2276 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    write_inputs = {
        'frame': a('Dictionary', 'public void write(Writes write){', 'The turret frame (TurretBuild.write, Turret.java:831): the family-convention first arg every Turret pure function takes; both persisted values are read from frame keys (the N2217 RepairTurret precedent) -- reload_counter is a tracked frame key, the tick driver reads it.'),
    }
    write_outputs = {
        'reload_counter': a('float', 'write.f(reloadCounter);', 'The persisted reload counter (`write.f(reloadCounter);`, Turret.java:833): the ReloadTurretBuild field (`public float reloadCounter;`, ReloadTurret.java:26), default 0.0, advanced by updateReload (Turret.java:720-723); written first, in Java write order.'),
        'rotation': a('float', 'write.f(rotation);', 'The persisted aim rotation (`write.f(rotation);`, Turret.java:834): the RotComp float aim angle (`@SyncField(false) @SyncLocal float rotation;`, RotComp.java:8), default 0.0 -- NOT the Building int rotation 0-3 (BuildingComp.java:69); written second, in Java write order.'),
    }
    read_inputs = {
        'frame': a('Dictionary', 'public void read(Reads read, byte revision){', 'The turret frame (TurretBuild.read, Turret.java:838): the family-convention first arg every Turret pure function takes; a revision-0 save leaves the fields where they already are, so the frame carries the current values as the fallback.'),
        'stored_reload_counter': a('float', 'reloadCounter = read.f();', 'The reload counter read from the save stream (`reloadCounter = read.f();`, Turret.java:842) -- applied only when revision >= 1.'),
        'stored_rotation': a('float', 'rotation = read.f();', 'The aim rotation read from the save stream (`rotation = read.f();`, Turret.java:843) -- applied only when revision >= 1.'),
        'revision': a('int', 'public void read(Reads read, byte revision){', 'The save revision (Turret.java:838, `public void read(Reads read, byte revision){`): the guard (`if(revision >= 1){`, Turret.java:841) -- the save version is 1 (`public byte version(){ return 1; }`, Turret.java:848-850).'),
    }
    read_outputs = {
        'reload_counter': a('float', 'reloadCounter = read.f();', 'The reload counter after load (Turret.java:842, `reloadCounter = read.f();`): the stored value when revision >= 1, else the frame current value (default 0.0).'),
        'rotation': a('float', 'rotation = read.f();', 'The aim rotation after load (Turret.java:843, `rotation = read.f();`): the stored value when revision >= 1, else the frame current value (default 0.0).'),
    }
    version_inputs = {
        'frame': a('Dictionary', 'public byte version(){', 'The turret frame (TurretBuild.version, Turret.java:848): accepted for the family call shape and read for nothing -- the version is a class constant, not live state.'),
    }
    version_outputs = {
        'version': a('int', 'return 1;', 'The save version: 1 (Turret.java:849, `return 1;`); the BuildingComp base returns 0 (BuildingComp.java:670).'),
    }
    return write_inputs, write_outputs, read_inputs, read_outputs, version_inputs, version_outputs


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
    for keys in inputs_outputs:
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
    write_inputs, write_outputs, read_inputs, read_outputs, version_inputs, version_outputs = definitions()

    entries = [
        ('N2276', WRITE_OWNER, 'source_turret_write_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.write()', write_inputs, write_outputs, True, 'Dictionary'),
        ('N2276', READ_OWNER, 'source_turret_read_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.read()', read_inputs, read_outputs, True, 'Dictionary'),
        ('N2276', VERSION_OWNER, 'source_turret_version_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.version()', version_inputs, version_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.write()/read()/version() state from Turret.java + ReloadTurret.java + RotComp.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.write()/read()/version() state from Turret.java + ReloadTurret.java + RotComp.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: write.reload_counter,
    # write.rotation, read.reload_counter, read.rotation,
    # version.version.
    by_slice['N2276'] = [
        'source_turret_write_state_result.reload_counter',
        'source_turret_write_state_result.rotation',
        'source_turret_read_state_result.reload_counter',
        'source_turret_read_state_result.rotation',
        'source_turret_version_state_result.version',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2276', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.write(); TurretBuild.read(); TurretBuild.version()', godot_owner=WRITE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2276'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
