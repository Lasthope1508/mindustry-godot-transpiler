"""Register BuildTurretBuild.senseObject() (N2485).

BuildTurretBuild overrides senseObject (BuildTurret.java:289-295,
`public Object senseObject(LAccess sensor){` / `return
switch(sensor){` / `case building, breaking ->
unit.senseObject(sensor);` / `default ->
super.senseObject(sensor);` / `};`) over the base default
BuildingComp.senseObject (BuildingComp.java:2128, `public
Object senseObject(LAccess sensor){`), whose rows are
`case type -> block;` / `case firstItem -> items == null ?
null : items.first();` / `case config ->
block.configSenseable() ? config() : null;` / `case
payloadType -> getPayload() instanceof UnitPayload p1 ?
p1.unit.type : getPayload() instanceof BuildPayload p2 ?
p2.block() : null;` / `default -> noSensed;`
(:2129-2135) -- BaseTurretBuild does NOT override
senseObject, so super.senseObject(sensor) in
BuildTurretBuild resolves to BuildingComp.senseObject
(BaseTurret.java:113, `public class BaseTurretBuild
extends Building implements Ranged, RotBlock{`). The
`unit` here is the FIELD `public BlockUnitc unit =
(BlockUnitc)unitType.create(team);` (BuildTurret.java:93)
-- NOT the `unit()` accessor (:113-119, excluded for its
side-effect: `unit.tile(this); unit.team(team);`). The
unit leg reads Unit.senseObject (UnitComp.java:313,
`public Object senseObject(LAccess sensor){`): building
-> `isBuilding() && !buildPlan().breaking ?
buildPlan().tile().build : null;` (:324) and breaking ->
`isBuilding() && buildPlan().breaking ?
buildPlan().tile().build : null;` (:325) -- the build
object when the builder unit has a plan of that kind,
null otherwise. The sensor spellings are the LAccess
enum names `building,` (:59) and `breaking,` (:60).

TWIN-REGISTER -- approved explicitly by the main thread
for N2485 (2026-11-27). The case line `case building,
breaking -> unit.senseObject(sensor);` has exactly ONE
hit in the ledger's exact_exprs -- N2184
(BuildTurretBuild.updateTile), which cites it only as
dependency evidence and ports NO senseObject function;
N2184's own deferred_exprs say "BuildTurret sense rows
(sense buildX/buildY + senseObject building/breaking
delegate to unit, BuildTurret.java:281-295) -- logic
sensing waits for its own slice", i.e. N2184 itself
declares senseObject waits for its own slice. The decl
`public Object senseObject(LAccess sensor){` and
`default -> super.senseObject(sensor);` are also
exact_exprs of N2184 (and generic across classes),
but N2184 cites them only as evidence for its
updateTile/power-status rows. java_method
`BuildTurretBuild.senseObject(LAccess)` is 0-hit,
registry `build_turret_sense_object` is 0-hit, and no GD
function computes it yet, so this slice adds a real new
GD function -- NOT a duplicate like TeamData.active(),
which was permanently excluded because its behaviour
was already ported by N2074/N2075. Precedent for twin
registration with explicit main-thread approval: N2484
(sense, same N2184 owner and the same deferred
sentence, batch 53 slot 3), N2474 (isCampaign, literal
owned by N2124), N2477/N2480/N2482 (buildRotation/
canControl/warmup, literals owned by N2184 -- the same
owner and the same BuildTurret.java cluster), N2421
(`return isShooting;`), N2389, N2418.

RED decisions (resolved at RED): (1) One pure function on
SourceBuildTurretBuildState.gd after
source_build_turret_sense_state (Java sense :281-287;
senseObject :289-295 stands after it), following the
N2484 sense precedent + the N2298 DrillBuild senseObject
precedent exactly: (frame, sensor, ...) and the generic
laccess wire shape (`handled` + `sense_object_value` +
`sense_object_value_is_null`), so a caller can tell
"handled" from "not handled -- fall through to
super.senseObject". (2) The unit leg takes the
caller-pre-resolved Unit.senseObject value (the N2478
pre-resolved-input precedent): the caller applies
Unit.senseObject(sensor) at the call boundary -- this
slice only routes; a null unit value means the builder
unit has no plan of that kind, and the handled leg
reports it via sense_object_value_is_null (computed from
the value itself, since Unit.senseObject returns null
exactly when not building). The super leg is the live
BuildingComp senseObject (N2506 bridge) and arrives as
explicit params (super_sense_object_value,
super_sense_object_value_is_null) following the
N2317/N2323 super-as-param precedent; the fallthrough
leg returns the caller-passed super result instead of
null. (3) All live values arrive as explicit params
(the N2188 precedent) -- the tick frame tracks only
cheating / enabled / power_status / efficiency today.
(4) NO driver line: senseObject is a logic read, not a
tick write (the N2206 / N2208 / N2223 precedent); the
logic-processor dispatch hook is its own later slice.
Three new result symbols: handled, sense_object_value,
sense_object_value_is_null. Slice sources:
BuildTurret.java + UnitComp.java + BuildingComp.java +
LAccess.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
UNIT_COMP = 'core/src/mindustry/entities/comp/UnitComp.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
LACCESS = 'core/src/mindustry/logic/LAccess.java'
PROOF = '/root/C07BuildTurretSenseObjectProof'
SENSE_OBJECT_OWNER = 'SourceBuildTurretBuildState.source_build_turret_sense_object_state'
TESTS = ['test_c07_build_turret_sense_object_registration', 'test_all_c07_build_turret_sense_object_input_evidence_is_exact', 'test_build_turret_sense_object_state', 'test_reference_graph_and_actual_c07_build_turret_sense_object']
# The 4 slice sources the N2485 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = [
    'public Object senseObject(LAccess sensor){',
    'case building, breaking -> unit.senseObject(sensor);',
    'default -> super.senseObject(sensor);',
    'public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{',
    'public BlockUnitc unit = (BlockUnitc)unitType.create(team);',
    'case building -> isBuilding() && !buildPlan().breaking ? buildPlan().tile().build : null;',
    'case breaking -> isBuilding() && buildPlan().breaking ? buildPlan().tile().build : null;',
    'default -> noSensed;',
    'building,',
    'breaking,',
]

DEFERRED = [
    'BuildTurretBuild.senseObject() Windows Godot proof -- debt in GOAL.md section 5: the N2485 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BuildTurretBuild.senseObject() is a TWIN-REGISTER with explicit main-thread approval (2026-11-27): the literals `public Object senseObject(LAccess sensor){`, `case building, breaking -> unit.senseObject(sensor);` and `default -> super.senseObject(sensor);` are also exact_exprs of N2184 (BuildTurretBuild.updateTile), which cites the BuildTurret.java:289-295 rows only as dependency evidence and ports no senseObject function; N2184 is the original owner of the literals, and its own deferred_exprs say "BuildTurret sense rows (sense buildX/buildY + senseObject building/breaking delegate to unit, BuildTurret.java:281-295) -- logic sensing waits for its own slice". The sibling sense() (N2484, BuildTurret.java:281-287) is the twin sibling under the same N2184 deferred sentence and is already done. Precedent: N2484, N2474, N2477, N2480, N2482, N2421, N2389, N2418.',
    'BuildTurretBuild.sense() (BuildTurret.java:281-287, `case buildX, buildY -> unit.sense(sensor);` / `default -> super.sense(sensor);`) is NOT in this slice: it is the sibling sense override, already done as N2484.',
    'BuildTurretBuild.senseObject() super.senseObject dispatch -- the default leg falls through to BuildingComp.senseObject (BuildingComp.java:2128); the logic-processor dispatch hook that calls BuildTurret senseObject then falls back to the BuildingComp senseObject bridge (SourceTurretBuildState.source_turret_sense_object_state, N2506) is its own later slice.',
    'The turret senseObject bridge (N2506, SourceTurretBuildState.source_turret_sense_object_state, which models the BuildingComp.senseObject rows type/firstItem/config/payloadType itself) is NOT in this slice: it is the parent-bridge method with its own switch; the proof pins the cross-trap (building is handled here but not there; type is handled there but falls through here). DrillBuild.senseObject (N2298, firstItem -> dominantItem) is likewise a different class and NOT in this slice.',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_object_inputs = {
        'frame': a('Dictionary', 'public Object senseObject(LAccess sensor){', 'The build-turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'sensor': a('String', 'public Object senseObject(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (LAccess.java:59 `building,`, :60 `breaking,`): only building/breaking are handled here, anything else falls through to super.senseObject (BuildTurret.java:292, `default -> super.senseObject(sensor);`).'),
        'unit_sense_object_value': a('Variant', 'case building -> isBuilding() && !buildPlan().breaking ? buildPlan().tile().build : null;', 'The pre-resolved Unit.senseObject(sensor) value for the building/breaking leg: Unit.senseObject (UnitComp.java:313) returns `isBuilding() && !buildPlan().breaking ? buildPlan().tile().build : null;` for building (:324) and `isBuilding() && buildPlan().breaking ? buildPlan().tile().build : null;` for breaking (:325) -- the build object when the builder unit has a plan of that kind, null otherwise; the caller applies Unit.senseObject at the call boundary (the N2478 pre-resolved-input precedent) and this slice only routes. The expr is the building leg; the breaking leg is the same shape.', source=UNIT_COMP),
        'super_sense_object_value': a('Variant', 'default -> super.senseObject(sensor);', 'The already-computed super result: BuildingComp.senseObject (BuildingComp.java:2128), live at the N2506 bridge (SourceTurretBuildState.source_turret_sense_object_state); the caller passes it (the N2317/N2323 super-as-param precedent) and the fallthrough leg returns it; null when the super was noSensed (the super switch default, BuildingComp.java:2135, `default -> noSensed;`). The expr is the BuildTurret fallthrough call site (BuildTurret.java:292).'),
        'super_sense_object_value_is_null': a('bool', 'default -> noSensed;', 'Whether the caller-passed super result is null: true when the super sensor fell through to the BuildingComp default (BuildingComp.java:2135), which returns the noSensed sentinel; false for every handled super row.', source=BUILDING_COMP),
    }
    sense_object_outputs = {
        'handled': a('bool', 'default -> super.senseObject(sensor);', 'Whether this slice handled the sensor (building/breaking only); false means "not handled -- the returned value is the super result" (the N2223 sense precedent).'),
        'sense_object_value': a('Variant', 'case building, breaking -> unit.senseObject(sensor);', 'The sensed object: the pre-resolved Unit.senseObject value for "building"/"breaking" (BuildTurret.java:291), or the caller-passed super result for any other sensor (BuildTurret.java:292); null when the sensor is handled but the unit has no plan of that kind, or when it is not handled and the super was noSensed.'),
        'sense_object_value_is_null': a('bool', 'default -> noSensed;', 'Whether the sensed object is null: true when the handled building/breaking leg got a null unit value (no plan of that kind) or when the sensor falls through to a null super result (the super switch default, BuildingComp.java:2135, `default -> noSensed;`); false otherwise.', source=BUILDING_COMP),
    }
    return sense_object_inputs, sense_object_outputs


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
    sense_object_inputs, sense_object_outputs = definitions()

    entries = [
        ('N2485', SENSE_OBJECT_OWNER, 'source_build_turret_sense_object_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', 'BuildTurretBuild.senseObject(LAccess)', sense_object_inputs, sense_object_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.senseObject() state from BuildTurret.java + UnitComp.java + BuildingComp.java + LAccess.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.senseObject() state from BuildTurret.java + UnitComp.java + BuildingComp.java + LAccess.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_object_value,
    # sense_object_value_is_null.
    by_slice['N2485'] = [
        'source_build_turret_sense_object_state_result.handled',
        'source_build_turret_sense_object_state_result.sense_object_value',
        'source_build_turret_sense_object_state_result.sense_object_value_is_null',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2485', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', java_method='BuildTurretBuild.senseObject(LAccess)', godot_owner=SENSE_OBJECT_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2485'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
