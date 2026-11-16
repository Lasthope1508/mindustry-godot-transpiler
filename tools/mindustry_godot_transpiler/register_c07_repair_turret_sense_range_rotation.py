"""Register the RepairTurret sense(range)/sense(rotation) rows (N2223).

N2222 captured the ambient-sound live-loop gate, but a logic
processor reading `range` or `rotation` on a repair turret still
gets the BuildingComp default: the sense switch has no
RepairTurret override (RepairTurret.java carries NO sense
override), so the two RepairTurret-specific legs come from the
super switch itself (BuildingComp.java:2093, `public double
sense(LAccess sensor){`): `case range -> this instanceof Ranged
r ? r.range() / tilesize : 0;` (BuildingComp.java:2105) and `case
rotation -> rotation;` (BuildingComp.java:2106). RepairPointBuild
implements Ranged (RepairTurret.java:153, `public class
RepairPointBuild extends Building implements Ranged, RotBlock{`)
with range() returning repairRadius (RepairTurret.java:231-232,
`public float range(){` / `return repairRadius;`), and its
rotation field defaults to 90 (RepairTurret.java:156, `public
float strength, rotation = 90;`, read by buildRotation(),
RepairTurret.java:158-161, `return rotation;`). The sensor
spellings are the LAccess enum names `range,` (LAccess.java:48)
and `rotation,` (LAccess.java:30); tilesize is 8 (Vars.java:135,
`public static final int tilesize = 8;`). Any other sensor falls
through to the switch default (BuildingComp.java:2123, `default
-> Float.NaN; //gets converted to null in logic`).

RED decisions (resolved at RED): (1) One pure function on the
same family file N2174 / N2188 / N2209 / N2212-N2215 / N2217 /
N2219-N2222 built, following the N2206 launch-pad / N2208
mass-driver sense precedent exactly: (frame, sensor, ...) and
the generic laccess wire shape (`handled` + `sense_value` +
`sense_value_is_nan`, SourceBlockSenseState.laccess_state), so a
caller can tell "handled" from "not handled -- fall through to
super.sense". (2) repair_radius and tilesize are explicit float
params (the N2212 acquire / N2220 draw-place per-def-param
precedent -- repairRadius is per-def static state, not a live
frame key: repair-point 60f, repair-turret 145f, class default
50f, RepairTurret.java:32 / Blocks.java:6389, :6401); rotation
is the live frame key (stamped by the N2214 slerp + N2217
read/write, absent folds to 90.0, the Java field init). (3) An
absent `rotation` key reads 90.0, NOT NaN: `public float
strength, rotation = 90;` is the Java init value, so a freshly
built turret senses 90.0 -- the only observable Java behavior at
init. (4) There is NO driver tick line: sense is a logic read,
not a tick write (the N2206/N2208 precedent); the proof calls
source_repair_turret_sense_state(frame, sensor, repair_radius,
tilesize) directly with synthetic frames, and the
logic-processor dispatch hook is its own later slice. Three new
result symbols: handled, sense_value, sense_value_is_nan. Slice
sources: RepairTurret.java + BuildingComp.java + Vars.java +
LAccess.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_repair_turret_ambient_sound_loop import DEFERRED as N2222_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
REPAIR_TURRET = 'core/src/mindustry/world/blocks/units/RepairTurret.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
VARS = 'core/src/mindustry/Vars.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07RepairTurretSenseRangeRotationProof'
SENSE_OWNER = 'SourceRepairTurretBuildState.source_repair_turret_sense_state'
TESTS = ['test_c07_repair_turret_sense_range_rotation_registration', 'test_all_c07_repair_turret_sense_range_rotation_input_evidence_is_exact', 'test_repair_turret_sense_range_rotation_state', 'test_reference_graph_and_actual_c07_repair_turret_sense_range_rotation']
# The 4 slice sources the N2223 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/units/RepairTurret.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/Vars.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = ['case range -> this instanceof Ranged r ? r.range() / tilesize : 0;', 'case rotation -> rotation;', 'public double sense(LAccess sensor){', 'default -> Float.NaN; //gets converted to null in logic', 'public float range(){', 'return repairRadius;', 'public float strength, rotation = 90;', 'return rotation;', 'public float repairRadius = 50f;', 'public static final int tilesize = 8;', 'public class RepairPointBuild extends Building implements Ranged, RotBlock{', 'range,', 'rotation,']

# DEFERRED is carried from the N2222 register script via import --
# never retyped. The N2222 script's DEFERRED is a computed
# expression (list(...) + [...] over the N2221 import), NOT a plain
# list literal, so the N2218-style ast.literal_eval carry cannot
# recover it (ValueError: malformed node); the import recovers the
# runtime value verbatim. NOTE for the next slice: N2223's
# DEFERRED is likewise a computed list(...) + [...] expression, so
# carry it forward by import too, not by ast.literal_eval.
DEFERRED = list(N2222_DEFERRED) + [
    'RepairTurret sense(range)/sense(rotation) Windows Godot proof -- debt in GOAL.md section 5, same as N2212-N2222: the N2223 proof runs headless on Linux here and waits for a Windows Godot run.',
    'RepairTurret display() / senseObject(config) rows -- BuildingComp.display (BuildingComp.java:1556) builds the UI Table (bars + consumption + flow) and senseObject (BuildingComp.java:2139-2146) senses `config` only when block.configSenseable() (Block.java:809-813); RepairTurret registers no configurations in its constructor, so config senses null, and display() is UI Table work, not a pure state read -- both wait for their own slices.',
]


def definitions():
    def a(typ, expr, rule, source=REPAIR_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_inputs = {
        'frame': a('Dictionary', 'case rotation -> rotation;', 'The repair-turret frame carrying the live `rotation` (stamped every tick by the N2214 slerp and persisted by the N2217 read/write; absent folds to 90.0, the Java field init `public float strength, rotation = 90;`, RepairTurret.java:156).', source=BUILDING_COMP),
        'sensor': a('String', 'public double sense(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (LAccess.java:30 `rotation,` and LAccess.java:48 `range,`): "range" or "rotation" are handled here, anything else falls through to super.sense (BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`).', source=BUILDING_COMP),
        'repair_radius': a('float', 'public float repairRadius = 50f;', 'The per-def repair radius in world pixels (RepairTurret.java:32, `public float repairRadius = 50f;`, the class default; repair-point 60f and repair-turret 145f, Blocks.java:6389, :6401); passed explicitly because it is per-def static state, not a live frame key (the N2212 acquire / N2220 draw-place per-def-param precedent).'),
        'tilesize': a('float', 'public static final int tilesize = 8;', 'The world tilesize in pixels (Vars.java:135, `public static final int tilesize = 8;`); passed explicitly (the N2220 draw-place precedent) so the range leg divides by the caller-supplied world constant.', source=VARS),
    }
    sense_outputs = {
        'handled': a('bool', 'case range -> this instanceof Ranged r ? r.range() / tilesize : 0;', 'Whether this slice handled the sensor ("range" or "rotation"); false means "not handled -- fall through to super.sense" (the N2208 mass-driver sense precedent).', source=BUILDING_COMP),
        'sense_value': a('float', 'case range -> this instanceof Ranged r ? r.range() / tilesize : 0;', 'The sensed value: repairRadius / tilesize in blocks for "range" (BuildingComp.java:2105, `case range -> this instanceof Ranged r ? r.range() / tilesize : 0;`, with range() returning repairRadius, RepairTurret.java:231-232) or the live rotation in degrees for "rotation" (BuildingComp.java:2106, `case rotation -> rotation;`); null when the sensor is not handled.', source=BUILDING_COMP),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the sensed value is NaN: true only when the sensor is not handled (the switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`, converts to null in logic); false for both handled rows.', source=BUILDING_COMP),
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
        ('N2223', SENSE_OWNER, 'source_repair_turret_sense_state', REPAIR_TURRET, 'mindustry.world.blocks.units.RepairTurret.RepairPointBuild', 'BuildingComp.sense(LAccess)', sense_inputs, sense_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed RepairTurret sense(range)/sense(rotation) state from RepairTurret.java + BuildingComp.java + Vars.java + LAccess.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed RepairTurret sense(range)/sense(rotation) state from RepairTurret.java + BuildingComp.java + Vars.java + LAccess.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value,
    # sense_value_is_nan.
    by_slice['N2223'] = [
        'source_repair_turret_sense_state_result.handled',
        'source_repair_turret_sense_state_result.sense_value',
        'source_repair_turret_sense_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2223', dict(status='done', java_source=REPAIR_TURRET, java_class='mindustry.world.blocks.units.RepairTurret.RepairPointBuild', java_method='BuildingComp.sense(LAccess)', godot_owner=SENSE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2223'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
