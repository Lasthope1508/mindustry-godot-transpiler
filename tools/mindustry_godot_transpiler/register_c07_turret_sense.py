"""Register the TurretBuild.sense() pure function (N2293).

TurretBuild overrides sense (Turret.java:406-419, `public
double sense(LAccess sensor){` / `return switch(sensor){`
/ `case ammo -> totalAmmo;` / `case ammoCapacity ->
maxAmmo;` / `case rotation -> rotation;` / `case shootX
-> World.conv(targetPos.x);` / `case shootY ->
World.conv(targetPos.y);` / `case shooting ->
isShooting ? 1 : 0;` / `case progress -> progress();` /
`default -> super.sense(sensor);`). The base default it
overrides is BuildingComp.sense (BuildingComp.java:2093,
`public double sense(LAccess sensor){`), whose default is
`default -> Float.NaN; //gets converted to null in logic`
(BuildingComp.java:2123). The inputs are the TurretBuild
fields totalAmmo (Turret.java:283, `public int
totalAmmo;`), maxAmmo (Turret.java:47, `public int
maxAmmo = 30;`), targetPos (Turret.java:290, `public Vec2
targetPos = new Vec2();`), isShooting (Turret.java:292,
`public boolean wasShooting, isShooting;`), and rotation,
the Building int rotation (BuildingComp.java:69,
`transient int rotation;`), plus the reload pair
reloadCounter (ReloadTurret.java:26, `public float
reloadCounter;`) / reload (ReloadTurret.java:10, `public
float reload = 10f;`) for the progress case (N2292,
`return Mathf.clamp(reloadCounter / reload);`,
Turret.java:426), and tilesize (Vars.java:135, `public
static final int tilesize = 8;`) for World.conv
(World.java:165-166, `public static float conv(float
coord){` / `return coord / tilesize;`). The sensor
spellings are the LAccess enum names `ammo,`
(LAccess.java:18), `ammoCapacity,` (:19), `progress,`
(:28), `rotation,` (:30), `shootX,` (:35), `shootY,`
(:36), `shooting,` (:49). This closes the deferred item
recorded in N2291/N2292 ('TurretBuild.sense()
(Turret.java:406-419) -- N2293, assigned centrally; its
progress case depends on N2292.').

RED decisions (resolved at RED): (1) One pure function on
SourceTurretBuildState.gd next to the N2291 shouldConsume
/ N2292 progress rows, following the N2223 sense precedent
exactly: (frame, sensor, ...) and the generic laccess wire
shape (`handled` + `sense_value` + `sense_value_is_nan`,
SourceBlockSenseState.laccess_state), so a caller can tell
"handled" from "not handled -- fall through to
super.sense". (2) All live values arrive as explicit
params (the N2188 precedent) -- the tick frame
tracks only cheating / enabled / power_status / efficiency
today. (3) The progress case calls the N2292 pure function
with explicit params. (4) NO driver line: sense is a logic
read, not a tick write (the N2206 / N2208 / N2223
precedent); the logic-processor dispatch hook is its own
later slice. Three new result symbols: handled,
sense_value, sense_value_is_nan. Slice sources:
Turret.java + ReloadTurret.java + BuildingComp.java +
Vars.java + LAccess.java + World.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_progress import DEFERRED as N2292_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
RELOAD_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
VARS = 'core/src/mindustry/Vars.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
WORLD = 'core/src/mindustry/core/World.java'
PROOF = '/root/C07TurretSenseProof'
SENSE_OWNER = 'SourceTurretBuildState.source_turret_sense_state'
TESTS = ['test_c07_turret_sense_registration', 'test_all_c07_turret_sense_input_evidence_is_exact', 'test_turret_sense_state', 'test_reference_graph_and_actual_c07_turret_sense']
# The 6 slice sources the N2293 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/ReloadTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/core/World.java',
]
EXACT_EXPRS = [
    'public double sense(LAccess sensor){',
    'case ammo -> totalAmmo;',
    'case ammoCapacity -> maxAmmo;',
    'case rotation -> rotation;',
    'case shootX -> World.conv(targetPos.x);',
    'case shootY -> World.conv(targetPos.y);',
    'case shooting -> isShooting ? 1 : 0;',
    'case progress -> progress();',
    'default -> super.sense(sensor);',
    'public int totalAmmo;',
    'public int maxAmmo = 30;',
    'public Vec2 targetPos = new Vec2();',
    'public boolean wasShooting, isShooting;',
    'transient int rotation;',
    'public static float conv(float coord){',
    'return coord / tilesize;',
    'public static final int tilesize = 8;',
    'return Mathf.clamp(reloadCounter / reload);',
    'public float reload = 10f;',
    'public float reloadCounter;',
    'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
    'default -> Float.NaN; //gets converted to null in logic',
    'ammo,',
    'ammoCapacity,',
    'progress,',
    'rotation,',
    'shootX,',
    'shootY,',
    'shooting,',
]

# DEFERRED is carried from the N2292 register script via import --
# never retyped. The N2292 entry deferring TurretBuild.sense()
# to N2293 is DROPPED here: N2293 IS that slice. Everything
# else is carried verbatim.
DEFERRED = [e for e in N2292_DEFERRED if 'TurretBuild.sense() (Turret.java:406-419)' not in e] + [
    'Turret sense Windows Godot proof -- debt in GOAL.md section 5, same as N2148/N2227: the N2293 proof runs headless on Linux here and waits for a Windows Godot run.',
    'TurretBuild.sense() super.sense dispatch -- the default leg falls through to BuildingComp.sense (BuildingComp.java:2093); the logic-processor dispatch hook that calls Turret sense then falls back to the BuildingComp sense bridge (SourceBuildingSenseState.gd) is its own later slice.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_inputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'sensor': a('String', 'public double sense(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (LAccess.java:18 `ammo,`, :19 `ammoCapacity,`, :28 `progress,`, :30 `rotation,`, :35 `shootX,`, :36 `shootY,`, :49 `shooting,`): the seven Turret cases are handled here, anything else falls through to super.sense (Turret.java:415, `default -> super.sense(sensor);`).'),
        'total_ammo': a('int', 'public int totalAmmo;', 'The total ammo units stored: the TurretBuild.totalAmmo field (Turret.java:283), read by the ammo case (Turret.java:408, `case ammo -> totalAmmo;`); passed explicitly because no frame key stamps it yet.'),
        'max_ammo': a('int', 'public int maxAmmo = 30;', 'The maximum ammo units stored: Turret.maxAmmo (Turret.java:47), read by the ammoCapacity case (Turret.java:409, `case ammoCapacity -> maxAmmo;`); passed explicitly because it is per-def static state, not a live frame key.'),
        'rotation': a('int', 'transient int rotation;', 'The Building rotation (0-3): BuildingComp.rotation (BuildingComp.java:69), read by the rotation case (Turret.java:410, `case rotation -> rotation;`); passed explicitly because no frame key stamps it yet.', source=BUILDING_COMP),
        'target_pos': a('Vector2', 'public Vec2 targetPos = new Vec2();', 'The target position in world pixels: the TurretBuild.targetPos field (Turret.java:290), read by the shootX/shootY cases (Turret.java:411-412, `case shootX -> World.conv(targetPos.x);` / `case shootY -> World.conv(targetPos.y);`) through World.conv; passed explicitly because no frame key stamps it yet.'),
        'is_shooting': a('bool', 'public boolean wasShooting, isShooting;', 'Whether the turret is shooting: the TurretBuild.isShooting field (Turret.java:292), set in updateTile (Turret.java:492), read by the shooting case (Turret.java:413, `case shooting -> isShooting ? 1 : 0;`); passed explicitly because no frame key stamps it yet.'),
        'reload_counter': a('float', 'public float reloadCounter;', 'The reload progress: the ReloadTurretBuild.reloadCounter field (ReloadTurret.java:26), advanced in updateReload (Turret.java:720-723) and capped at reload (:723); read by the progress case through the N2292 pure function (Turret.java:414, `case progress -> progress();`); passed explicitly because no frame key stamps it yet.', source=RELOAD_TURRET),
        'reload': a('float', 'public float reload = 10f;', 'The per-def reload time: ReloadTurret.reload (ReloadTurret.java:10); read by the progress case through the N2292 pure function; passed explicitly because the frame carries no reload def value yet.', source=RELOAD_TURRET),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly (the N2223 sense precedent) so the shootX/shootY legs divide by the caller-supplied world constant (World.java:166, `return coord / tilesize;`).', source=VARS),
    }
    sense_outputs = {
        'handled': a('bool', 'default -> super.sense(sensor);', 'Whether this slice handled the sensor (one of the seven Turret cases); false means "not handled -- fall through to super.sense" (the N2223 sense precedent).'),
        'sense_value': a('float', 'case ammo -> totalAmmo;', 'The sensed value: totalAmmo for "ammo" (Turret.java:408), maxAmmo for "ammoCapacity" (:409), the Building rotation for "rotation" (:410), targetPos.x / tilesize for "shootX" (:411), targetPos.y / tilesize for "shootY" (:412), 1 or 0 for "shooting" (:413), or the N2292 progress clamp for "progress" (:414); null when the sensor is not handled.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the sensed value is NaN: true only when the sensor is not handled (the super switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`, converts to null in logic); false for all seven handled rows.', source=BUILDING_COMP),
    }
    return sense_inputs, sense_outputs


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
    sense_inputs, sense_outputs = definitions()

    entries = [
        ('N2293', SENSE_OWNER, 'source_turret_sense_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.sense(LAccess)', sense_inputs, sense_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.sense() state from Turret.java + ReloadTurret.java + BuildingComp.java + Vars.java + LAccess.java + World.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.sense() state from Turret.java + ReloadTurret.java + BuildingComp.java + Vars.java + LAccess.java + World.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value,
    # sense_value_is_nan.
    by_slice['N2293'] = [
        'source_turret_sense_state_result.handled',
        'source_turret_sense_state_result.sense_value',
        'source_turret_sense_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2293', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.sense(LAccess)', godot_owner=SENSE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2293'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
