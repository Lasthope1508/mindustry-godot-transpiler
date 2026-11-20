"""Register the Turret sense() LAccess dispatch (N2283).

sense() is `public double sense(LAccess sensor){ return
switch(sensor){ case ammo -> totalAmmo; case ammoCapacity
-> maxAmmo; case rotation -> rotation; case shootX ->
World.conv(targetPos.x); case shootY -> World.conv(
targetPos.y); case shooting -> isShooting ? 1 : 0; case
progress -> progress(); default -> super.sense(sensor); };
}` (Turret.java:405-419). Every Turret case has a live or
catalog input: ammo reads totalAmmo (`public int
totalAmmo;`, Turret.java:283, live in the driver as
duo_total from the game dict -- passed as an explicit int
param because the frame carries no total_ammo key);
ammoCapacity reads maxAmmo (`public int maxAmmo = 30;`,
Turret.java:47, duo never overrides it -- explicit int
param); rotation reads the live frame key stamped every
tick by the aim call (absent folds to 90.0, `public float
rotation = 90;`, BaseTurret.java:114); shootX/shootY read
World.conv(targetPos) (`public Vec2 targetPos = new
Vec2();`, Turret.java:290, default (0,0); `public static
float conv(float coord){` / `return coord / tilesize;`,
World.java:165-166; `public static final int tilesize =
8;`, Vars.java:135) over the live frame target_pos dict
(null counts as (0,0)); shooting reads the live frame
is_shooting (N2277 tick, `public boolean wasShooting,
isShooting;`, Turret.java:292); progress reads the live
frame progress (N2282 tick, `public float progress(){` /
`return Mathf.clamp(reloadCounter / reload);`,
Turret.java:425-427). The default falls through to
super.sense (BuildingComp.java:2093-2126, ~25 cases) --
its own later slice -- so the pure function reports
handled false + NaN and the caller knows to fall through.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceTurretBuildState.gd,
source_turret_sense_state(frame, sensor, total_ammo,
max_ammo, tilesize), returning the N2206/N2208/N2223 sense
wire shape (`handled` + `sense_value` +
`sense_value_is_nan`), so a caller can tell "handled" from
"not handled -- fall through to super.sense". It sits
immediately BEFORE source_turret_progress_state (Java
order: sense :405-419 before progress :425-427). (2) There
is NO driver tick line: sense is a logic read, not a tick
write (the N2206/N2208/N2223 precedent); the proof calls
the pure function directly with synthetic frames, and the
logic-processor dispatch hook is its own later slice. (3)
No legacy `source_turret_sense_result` schema exists, so
the contract validator falls through to the new
source_turret_sense_state_result schema and no alias is
needed. SSOT expected after GREEN: symbols +3, Done +1,
contracts +1, schema +2, 11659/1732/1666/3123 ->
11662/1733/1667/3125; defense shard slices 209 -> 210,
contracts 208 -> 209.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_progress import DEFERRED as N2282_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
WORLD = 'core/src/mindustry/core/World.java'
VARS = 'core/src/mindustry/Vars.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/C07TurretSenseProof'
SENSE_OWNER = 'SourceTurretBuildState.source_turret_sense_state'
TESTS = ['test_c07_turret_sense_registration', 'test_all_c07_turret_sense_input_evidence_is_exact', 'test_turret_sense_state', 'test_reference_graph_and_actual_c07_turret_sense']
# The slice sources the N2283 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
    'core/src/mindustry/core/World.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/logic/LAccess.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
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
    'public int maxAmmo = 30;',
    'public int totalAmmo;',
    'public Vec2 targetPos = new Vec2();',
    'public boolean wasShooting, isShooting;',
    'public float rotation = 90;',
    'public static float conv(float coord){',
    'return coord / tilesize;',
    'public static final int tilesize = 8;',
    'public float progress(){',
    'return Mathf.clamp(reloadCounter / reload);',
    'ammo,',
    'ammoCapacity,',
    'rotation,',
    'shootX,',
    'shootY,',
    'shooting,',
    'progress,',
    'default -> Float.NaN; //gets converted to null in logic',
]

# DEFERRED is carried from the N2282 register script via import --
# never retyped. sense() is done by this slice; super.sense
# delegation, the logic-processor dispatch hook, senseObject,
# findTarget / shootp / calculateHeat / the other ItemTurret
# defs / controlled() still wait.
DEFERRED = list(N2282_DEFERRED) + [
    'Turret sense() LAccess dispatch (`public double sense(LAccess sensor){`, Turret.java:405-419) -- DONE by this slice (N2283); the pure function ports all seven Turret cases over live frame keys + live total_ammo / catalog max_ammo params, and reports handled=false + NaN for anything else so the caller falls through to super.sense.',
    'Turret super.sense() delegation (BuildingComp.sense, BuildingComp.java:2093-2126, ~25 cases) -- NOT this slice; the N2283 pure function reports handled=false for any sensor outside the seven Turret cases, and the delegation to BuildingComp.sense is its own later slice.',
    'Turret sense() logic-processor dispatch hook (LExecutor sense -> turret sense) -- NOT this slice; sense is a logic read and the port has no logic-executor dispatch hook yet; the N2283 pure function is callable directly with synthetic frames.',
    'Turret senseObject() (BuildingComp.java:2128-2136) -- NOT this slice; senseObject is its own later slice (the N2223 sense / N2230 setStats precedent).',
    'Turret sense() for defs other than duo -- the pure function takes total_ammo / max_ammo as params; only duo values (live total, 30) are proven here.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_inputs = {
        'frame': a('Dictionary', 'case rotation -> rotation;', 'The turret frame carrying the live `rotation` (stamped every tick by the aim call, absent folds to 90.0, the Java field init `public float rotation = 90;`, BaseTurret.java:114), `target_pos` (stamped by the aim call as a {"x","y"} dict or null, which counts as the (0,0) default of `public Vec2 targetPos = new Vec2();`, Turret.java:290), `is_shooting` (stamped by the N2277 tick) and `progress` (stamped by the N2282 tick).'),
        'sensor': a('String', 'public double sense(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (`ammo,` LAccess.java:18, `ammoCapacity,` :19, `progress,` :28, `rotation,` :30, `shootX,` :35, `shootY,` :36, `shooting,` :49): the seven Turret cases are handled here, anything else falls through to super.sense (`default -> super.sense(sensor);`, Turret.java:415).'),
        'total_ammo': a('int', 'public int totalAmmo;', 'The live total ammo (`public int totalAmmo;`, Turret.java:283, field default 0; live in the driver as duo_total from the game dict `turret_total_ammo`, written back on shot); passed explicitly because the frame carries no total_ammo key (the N2212/N2220 per-def-param precedent).'),
        'max_ammo': a('int', 'public int maxAmmo = 30;', 'The ammo capacity (`public int maxAmmo = 30;`, Turret.java:47, the class default; duo never overrides it, Blocks.java:3257-3331); passed explicitly because it is per-def static state, not a live frame key (the N2212/N2220 per-def-param precedent).'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly (the N2220 draw-place precedent) so the shootX/shootY legs divide by the caller-supplied world constant (`public static float conv(float coord){` / `return coord / tilesize;`, World.java:165-166).', source=VARS),
    }
    sense_outputs = {
        'handled': a('bool', 'default -> super.sense(sensor);', 'Whether this slice handled the sensor (one of the seven Turret cases); false means "not handled -- fall through to super.sense" (the N2208 mass-driver / N2223 repair-turret sense precedent).'),
        'sense_value': a('float', 'case ammo -> totalAmmo;', 'The sensed value: totalAmmo for "ammo" (`case ammo -> totalAmmo;`, Turret.java:408), maxAmmo for "ammoCapacity" (:409), the live rotation in degrees for "rotation" (:410), World.conv(targetPos.x/y) in tiles for "shootX"/"shootY" (:411-412), 1 or 0 for "shooting" (:413), the live progress() fraction for "progress" (:414); null when the sensor is not handled.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the sensed value is NaN: true only when the sensor is not handled (the super switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`, converts to null in logic); false for all seven handled cases.', source=BUILDING_COMP),
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
        ('N2283', SENSE_OWNER, 'source_turret_sense_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.sense(LAccess)', sense_inputs, sense_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret sense() LAccess dispatch from Turret.java:405-419 + BaseTurret.java + World.java + Vars.java + LAccess.java + BuildingComp.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret sense() LAccess dispatch from Turret.java:405-419 + BaseTurret.java + World.java + Vars.java + LAccess.java + BuildingComp.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value,
    # sense_value_is_nan.
    by_slice['N2283'] = [
        'source_turret_sense_state_result.handled',
        'source_turret_sense_state_result.sense_value',
        'source_turret_sense_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2283', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.sense(LAccess)', godot_owner=SENSE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2283'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
