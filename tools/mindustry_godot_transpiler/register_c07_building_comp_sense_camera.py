"""Register the BuildingComp.sense() `cameraX/cameraY/cameraWidth/cameraHeight` legs (N2518).

BuildingComp.sense() is `public double sense(LAccess sensor){`
(BuildingComp.java:2093-2126). Its camera legs are `case cameraX,
cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ?
c.unit().sense(sensor) : 0;` (:2122, the last leg of sense()), with the
sensor spellings the LAccess enum names (`cameraX,` `cameraY,`
`cameraWidth,` `cameraHeight,`, LAccess.java:37-40).
The four legs share ONE Java case line and ONE delegation expression,
so one slice ports all four as one pure function with a `sensor`
param (splitting into four slices would quadruple near-identical
functions for zero additional Java coverage). The delegation target
already exists in the port: `SourceUnitSensorState.laccess_state`
(SourceUnitSensorState.gd:41-44) ports the UnitComp.sense camera legs
(`case cameraX -> controller instanceof Player player ?
World.conv(player.con == null ? Core.camera.position.x :
player.con.viewX) : 0;`, UnitComp.java:283-286, and cameraY /
cameraWidth / cameraHeight analogously) -- 0 when the controller is
not a Player, else `World.conv` of the player view / core camera
value. This slice ports ONLY the BuildingComp gate (`instanceof
ControlBlock` + fallback 0 + pass-through of the unit sense value);
it does NOT re-port the unit-side camera math.
N2284 ported 23 handled legs of sense() and left
dead/health/totalItems/camera*/powerNet* deferred. N2511 ported
`dead`, N2512 ported `health`, N2513 ported `totalItems`, N2514 ported
`powerNetIn`, N2515 ported `powerNetOut`, N2516 ported
`powerNetStored`, N2517 ported `powerNetCapacity`. This slice ports
exactly the camera* case, the last leg of sense().

GREEN decisions (pinned by this slice): (1) One pure function on
SourceTurretBuildState.gd,
source_building_comp_sense_camera_state(sensor, is_control_block,
unit_sense_value), returning `handled` + `sense_value` +
`sense_value_is_nan` (the N2283/N2284 sense wire shape). The three
params are the live input a future frame-stamp/wiring slice will
supply (the N2212/N2220 per-def-param precedent): `sensor` is one of
the four camera labels (LAccess.java:37-40), `is_control_block` is
`this instanceof ControlBlock` (:2122, the gate of the ternary) and
`unit_sense_value` is `c.unit().sense(sensor)` -- the already-ported
unit sense result for this sensor (UnitComp.java:283-286, via
`SourceUnitSensorState.laccess_state`). `sense_value` is 0.0 when not
a control block, else `unit_sense_value` exactly (Java `sense()`
returns double; the float widens exactly), no clamping, no rounding,
no World.conv here (the conv already happened inside the unit sense
call). `handled` is true always (this function IS the camera case;
the sensor is one of the four camera labels) and
`sense_value_is_nan` is false always (the leg never yields NaN;
the key stays in the wire shape for consistency with
N2283/N2284/N2511/N2512/N2513/N2514/N2515/N2516/N2517). The function
does NOT validate the sensor: the dispatch guarantees one of the four
labels, same as the N2511-N2517 fixed-sensor functions do not
validate theirs. It sits immediately AFTER
source_building_comp_sense_power_net_capacity_state and BEFORE
source_turret_sense_object_state, mirroring the sense() /
senseObject() order in BuildingComp.java (:2093 / :2128) and,
inside sense(), dead :2098 -> health :2101 -> totalItems :2107 ->
powerNetIn :2114 -> powerNetOut :2115 -> powerNetStored :2116 ->
powerNetCapacity :2117 -> camera* :2122. It does NOT modify
`source_building_comp_sense_state`: camera* stay
handled:false in the big dispatch until a later wiring slice
connects this leg (same as N2511's dead leg, N2512's health leg,
N2513's totalItems leg, N2514's powerNetIn leg, N2515's powerNetOut
leg, N2516's powerNetStored leg and N2517's powerNetCapacity leg
living beside N2284). (2) There is NO
driver tick line: the leg is a logic read, not a tick write (the
N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517
precedent); the proof calls the pure function directly with
synthetic inputs, and wiring the leg into a live logic-executor
driver is its own later slice (the logic executor is not in the
driver yet). (3) No legacy
`source_building_comp_sense_camera_result` schema exists, so
the contract validator falls through to the new
source_building_comp_sense_camera_state_result schema and no
alias is needed. (4) Shard routing: the ported method is
BuildingComp.sense, so the java_source is BuildingComp.java
(NOT LExecutor.java -- the N2510 precedent is the reverse:
there the dispatched method WAS SenseI.run itself), and the
slice mirrors into the comp shard: comp 567/471 -> 568/472;
defense stays 210/209. SSOT expected after GREEN: symbols +3,
Done +1, contracts +1, schema +2, 11704/1746/1680/3151 ->
11707/1747/1681/3153.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_building_comp_sense_power_net_capacity import DEFERRED as N2517_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07BuildingCompSenseCameraProof'
CAMERA_OWNER = 'SourceTurretBuildState.source_building_comp_sense_camera_state'
TESTS = ['test_c07_building_comp_sense_camera_registration', 'test_all_c07_building_comp_sense_camera_input_evidence_is_exact', 'test_building_comp_sense_camera_state', 'test_reference_graph_and_actual_c07_building_comp_sense_camera']
# The slice sources the N2518 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = [
    'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;',
    'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;',
    'public double sense(LAccess sensor){',
    'default -> Float.NaN; //gets converted to null in logic',
    'cameraX,',
]

# DEFERRED is carried from the N2517 register script via import --
# never retyped. The camera* deferred entry (which names the case at
# BuildingComp.java:2121 -- that line is `case size -> block.size;`,
# the camera case is :2122, verified by grep -n this run) is dropped
# here -- the camera legs are DONE by this slice (N2518). Every other
# entry is carried verbatim (the N2211/N2228 lesson -- never retype
# the pool).
DEFERRED = [e for e in N2517_DEFERRED if 'sense() cameraX/cameraY/cameraWidth/cameraHeight legs' not in e] + [
    'BuildingComp sense() cameraX/cameraY/cameraWidth/cameraHeight legs (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2122) -- DONE by this slice (N2518); the pure function returns 0.0 when not a control block (`this instanceof ControlBlock`, :2122), else `unit_sense_value` exactly -- the already-ported unit sense result for the sensor (`case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`, UnitComp.java:283-286, via `SourceUnitSensorState.laccess_state`), no clamping, no rounding, no World.conv here (the conv already happened inside the unit sense call), with handled true and sense_value_is_nan false always. camera* stay handled:false in `source_building_comp_sense_state` until a later wiring slice connects this leg.',
    'BuildingComp sense() cameraX/cameraY/cameraWidth/cameraHeight Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517: the N2518 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=BUILDING_COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    camera_inputs = {
        'sensor': a('String', 'public double sense(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (`cameraX,` LAccess.java:37, `cameraY,` :38, `cameraWidth,` :39, `cameraHeight,` :40): one of the four camera labels of the single Java case (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2122); the sensor-specific selection already happened inside the unit sense call whose result is `unit_sense_value`.'),
        'is_control_block': a('bool', 'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;', 'Whether `this instanceof ControlBlock` (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2122, the gate of the ternary): the building has a proxy unit (`public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`, Turret.java:291); passed explicitly because the live building type is not stamped in the frame yet (the N2212/N2220 per-def-param precedent).'),
        'unit_sense_value': a('float', 'case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;', 'The proxy unit\'s sense result for this sensor (`c.unit().sense(sensor)`, BuildingComp.java:2122): the already-ported unit sense camera leg (`case cameraX -> controller instanceof Player player ? World.conv(player.con == null ? Core.camera.position.x : player.con.viewX) : 0;`, UnitComp.java:283-286, and cameraY/cameraWidth/cameraHeight analogously, via `SourceUnitSensorState.laccess_state`) -- 0 when the unit controller is not a Player, else `World.conv` of the player view / core camera value; passed explicitly because the live unit sense value is not stamped in the frame yet (the N2212/N2220 per-def-param precedent).', source=UNIT_COMP),
    }
    camera_outputs = {
        'handled': a('bool', 'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;', 'Whether the leg resolved to a logic-variable write (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2122): true always, because this function IS the camera case and the sensor is one of the four camera labels.'),
        'sense_value': a('Variant', 'case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;', 'The numeric value written to the logic variable (`case cameraX, cameraY, cameraWidth, cameraHeight -> this instanceof ControlBlock c ? c.unit().sense(sensor) : 0;`, BuildingComp.java:2122): 0.0 when not a control block, else `unit_sense_value` exactly (Java `sense()` returns double; the float widens exactly), no clamping, no rounding, no World.conv here (the conv already happened inside the unit sense call).'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether Java returns Float.NaN for this sensor (`default -> Float.NaN; //gets converted to null in logic`, BuildingComp.java:2123); false always for the camera legs, which never yield NaN -- the key stays in the wire shape for consistency with N2283/N2284/N2511/N2512/N2513/N2514/N2515/N2516/N2517.'),
    }
    return camera_inputs, camera_outputs


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
    camera_inputs, camera_outputs = definitions()

    entries = [
        ('N2518', CAMERA_OWNER, 'source_building_comp_sense_camera_state', BUILDING_COMP, 'mindustry.entities.comp.BuildingComp.BuildingComp', 'BuildingComp.sense(LAccess)', camera_inputs, camera_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildingComp.sense() cameraX/cameraY/cameraWidth/cameraHeight legs from BuildingComp.java:2122 + UnitComp.java:283-286.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildingComp.sense() cameraX/cameraY/cameraWidth/cameraHeight legs from BuildingComp.java:2122 + UnitComp.java:283-286.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value, sense_value_is_nan.
    by_slice['N2518'] = [
        'source_building_comp_sense_camera_state_result.handled',
        'source_building_comp_sense_camera_state_result.sense_value',
        'source_building_comp_sense_camera_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2518', dict(status='done', java_source=BUILDING_COMP, java_class='mindustry.entities.comp.BuildingComp.BuildingComp', java_method='BuildingComp.sense(LAccess)', godot_owner=CAMERA_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2518'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
