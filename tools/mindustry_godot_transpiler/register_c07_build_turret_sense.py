"""Register BuildTurretBuild.sense() (N2484).

BuildTurretBuild overrides sense (BuildTurret.java:281-287,
`public double sense(LAccess sensor){` / `return
switch(sensor){` / `case buildX, buildY ->
unit.sense(sensor);` / `default -> super.sense(sensor);`
/ `};`) over the base default BuildingComp.sense
(BuildingComp.java:2093, `public double sense(LAccess
sensor){`), whose default is `default -> Float.NaN;
//gets converted to null in logic` (BuildingComp.java:2123)
-- BaseTurretBuild does NOT override sense, so
super.sense(sensor) in BuildTurretBuild resolves to
BuildingComp.sense (BaseTurret.java:113, `public class
BaseTurretBuild extends Building implements Ranged,
RotBlock{`). The `unit` here is the FIELD `public
BlockUnitc unit = (BlockUnitc)unitType.create(team);`
(BuildTurret.java:93) -- NOT the `unit()` accessor
(:113-119, excluded for its side-effect: `unit.tile(this);
unit.team(team);`). The unit leg reads Unit.sense
(UnitComp.java:264, `public double sense(LAccess
sensor){`): buildX -> `isBuilding() ? buildPlan().x : -1;`
(:290) and buildY -> `isBuilding() ? buildPlan().y : -1;`
(:291). The sensor spellings are the LAccess enum names
`buildX,` (:54) and `buildY,` (:55).

TWIN-REGISTER -- approved explicitly by the main thread
for N2484 (2026-11-27). The case line `case buildX,
buildY -> unit.sense(sensor);` has exactly ONE hit in
the ledger's exact_exprs -- N2184
(BuildTurretBuild.updateTile), which cites it only as
dependency evidence and ports NO sense function; N2184's
own deferred_exprs say "BuildTurret sense rows (sense
buildX/buildY + senseObject building/breaking delegate to
unit, BuildTurret.java:281-295) -- logic sensing waits
for its own slice", i.e. N2184 itself declares sense
waits for its own slice. The decl `public double
sense(LAccess sensor){` and `default ->
super.sense(sensor);` are also exact_exprs of N2184
(and generic across classes -- 40 hits for the decl),
but N2184 cites them only as evidence for its
updateTile/power-status rows. java_method
`BuildTurretBuild.sense(LAccess)` is 0-hit, registry
`build_turret_sense` is 0-hit, and no GD function
computes it yet, so this slice adds a real new GD
function -- NOT a duplicate like TeamData.active(),
which was permanently excluded because its behaviour
was already ported by N2074/N2075. Precedent for twin
registration with explicit main-thread approval: N2474
(isCampaign, literal owned by N2124), N2477/N2480/N2482
(buildRotation/canControl/warmup, literals owned by
N2184 -- the same owner and the same BuildTurret.java
cluster), N2421 (`return isShooting;`), N2389, N2418.

RED decisions (resolved at RED): (1) One pure function on
SourceBuildTurretBuildState.gd after
source_build_turret_read_plans_state (Java read :266-278;
sense :281-287 stands after it, before senseObject
:289-295), following the N2298 DrillBuild sense
precedent exactly: (frame, sensor, ...) and the generic
laccess wire shape (`handled` + `sense_value` +
`sense_value_is_nan`), so a caller can tell "handled"
from "not handled -- fall through to super.sense".
(2) The unit leg takes the caller-pre-resolved
Unit.sense value (the N2478 pre-resolved-input
precedent): the caller applies Unit.sense(sensor) at
the call boundary -- this slice only routes. The super
leg is the live BuildingComp sense (N1078-N1085) and
arrives as explicit params (super_sense_value,
super_sense_value_is_nan) following the N2317/N2323
super-as-param precedent; the fallthrough leg returns
the caller-passed super result instead of null.
(3) All live values arrive as explicit params (the
N2188 precedent) -- the tick frame tracks only
cheating / enabled / power_status / efficiency today.
(4) NO driver line: sense is a logic read, not a tick
write (the N2206 / N2208 / N2223 precedent); the
logic-processor dispatch hook is its own later slice.
Three new result symbols: handled, sense_value,
sense_value_is_nan. Slice sources: BuildTurret.java +
UnitComp.java + BuildingComp.java + LAccess.java.
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
PROOF = '/root/C07BuildTurretSenseProof'
SENSE_OWNER = 'SourceBuildTurretBuildState.source_build_turret_sense_state'
TESTS = ['test_c07_build_turret_sense_registration', 'test_all_c07_build_turret_sense_input_evidence_is_exact', 'test_build_turret_sense_state', 'test_reference_graph_and_actual_c07_build_turret_sense']
# The 4 slice sources the N2484 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
    'core/src/mindustry/entities/comp/UnitComp.java',
    'core/src/mindustry/entities/comp/BuildingComp.java',
    'core/src/mindustry/logic/LAccess.java',
]
EXACT_EXPRS = [
    'public double sense(LAccess sensor){',
    'case buildX, buildY -> unit.sense(sensor);',
    'default -> super.sense(sensor);',
    'public class BuildTurretBuild extends BaseTurretBuild implements ControlBlock, RotBlock{',
    'public BlockUnitc unit = (BlockUnitc)unitType.create(team);',
    'case buildX -> isBuilding() ? buildPlan().x : -1;',
    'case buildY -> isBuilding() ? buildPlan().y : -1;',
    'default -> Float.NaN; //gets converted to null in logic',
    'buildX,',
    'buildY,',
]

DEFERRED = [
    'BuildTurretBuild.sense() Windows Godot proof -- debt in GOAL.md section 5: the N2484 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BuildTurretBuild.sense() is a TWIN-REGISTER with explicit main-thread approval (2026-11-27): the literals `public double sense(LAccess sensor){`, `case buildX, buildY -> unit.sense(sensor);` and `default -> super.sense(sensor);` are also exact_exprs of N2184 (BuildTurretBuild.updateTile), which cites the BuildTurret.java:281-287 rows only as dependency evidence and ports no sense function; N2184 is the original owner of the literals, and its own deferred_exprs say "BuildTurret sense rows (sense buildX/buildY + senseObject building/breaking delegate to unit, BuildTurret.java:281-295) -- logic sensing waits for its own slice". The other decl hits are other classes\' sense methods (N2293 TurretBuild.sense, N2298 DrillBuild.sense, N1169 PowerTurretBuild.sense -- different switches). Precedent: N2474, N2477, N2480, N2482, N2421, N2389, N2418.',
    'BuildTurretBuild.senseObject(LAccess) (BuildTurret.java:289-295, `case building, breaking -> unit.senseObject(sensor);` / `default -> super.senseObject(sensor);`) is NOT in this slice: it is the sibling senseObject override, covered by the same N2184 deferred sentence ("BuildTurret sense rows (sense buildX/buildY + senseObject building/breaking delegate to unit, BuildTurret.java:281-295)"); it waits for its own slice (batch 54 slot 1 candidate).',
    'BuildTurretBuild.sense() super.sense dispatch -- the default leg falls through to BuildingComp.sense (BuildingComp.java:2093); the logic-processor dispatch hook that calls BuildTurret sense then falls back to the BuildingComp sense bridge (SourceBuildingSenseState.gd) is its own later slice.',
    'TurretBuild.sense() (Turret.java:406-418, N2293, `case ammo -> totalAmmo;` / `case ammoCapacity -> maxAmmo;` / ... / `default -> super.sense(sensor);`) is NOT in this slice: it is the parent-class method with a 7-case switch of its own; the proof pins the cross-trap (ammo is handled by the parent but falls through to super here).',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    sense_inputs = {
        'frame': a('Dictionary', 'public double sense(LAccess sensor){', 'The build-turret frame (accepted for the family call shape; this leg reads no live frame key -- all live values arrive as explicit params, the N2188 per-def-param precedent, because the tick frame tracks only cheating/enabled/power_status/efficiency).'),
        'sensor': a('String', 'public double sense(LAccess sensor){', 'The logic sensor to read, spelled by its LAccess enum name (LAccess.java:54 `buildX,`, :55 `buildY,`): only buildX/buildY are handled here, anything else falls through to super.sense (BuildTurret.java:285, `default -> super.sense(sensor);`).'),
        'unit_sense_value': a('float', 'case buildX -> isBuilding() ? buildPlan().x : -1;', 'The pre-resolved Unit.sense(sensor) value for the buildX/buildY leg: Unit.sense (UnitComp.java:264) returns `isBuilding() ? buildPlan().x : -1;` for buildX (:290) and `isBuilding() ? buildPlan().y : -1;` for buildY (:291) -- the plan coordinate when the builder unit is building, -1 when it is not; the caller applies Unit.sense at the call boundary (the N2478 pre-resolved-input precedent) and this slice only routes. The expr is the buildX leg; the buildY leg is the same shape.', source=UNIT_COMP),
        'super_sense_value': a('Variant', 'default -> super.sense(sensor);', 'The already-computed super result: BuildingComp.sense (BuildingComp.java:2093), live at N1078-N1085 (PortGame.source_building_sense_*_state); the caller passes it (the N2317/N2323 super-as-param precedent) and the fallthrough leg returns it; null when the super was NaN (the super switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`). The expr is the BuildTurret fallthrough call site (BuildTurret.java:285).'),
        'super_sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the caller-passed super result is NaN: true when the super sensor fell through to the BuildingComp default (BuildingComp.java:2123), which converts to null in logic; false for every handled super row.', source=BUILDING_COMP),
    }
    sense_outputs = {
        'handled': a('bool', 'default -> super.sense(sensor);', 'Whether this slice handled the sensor (buildX/buildY only); false means "not handled -- the returned value is the super result" (the N2223 sense precedent).'),
        'sense_value': a('float', 'case buildX, buildY -> unit.sense(sensor);', 'The sensed value: the pre-resolved Unit.sense value for "buildX"/"buildY" (BuildTurret.java:284), or the caller-passed super result for any other sensor (BuildTurret.java:285); null when the sensor is not handled and the super was NaN.'),
        'sense_value_is_nan': a('bool', 'default -> Float.NaN; //gets converted to null in logic', 'Whether the sensed value is NaN: true only when the sensor falls through to a NaN super result (the super switch default, BuildingComp.java:2123, `default -> Float.NaN; //gets converted to null in logic`, converts to null in logic); false for the handled buildX/buildY rows (Unit.sense returns a plan coordinate or -1, never NaN).', source=BUILDING_COMP),
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
        ('N2484', SENSE_OWNER, 'source_build_turret_sense_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', 'BuildTurretBuild.sense(LAccess)', sense_inputs, sense_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.sense() state from BuildTurret.java + UnitComp.java + BuildingComp.java + LAccess.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.sense() state from BuildTurret.java + UnitComp.java + BuildingComp.java + LAccess.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: handled, sense_value,
    # sense_value_is_nan.
    by_slice['N2484'] = [
        'source_build_turret_sense_state_result.handled',
        'source_build_turret_sense_state_result.sense_value',
        'source_build_turret_sense_state_result.sense_value_is_nan',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2484', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', java_method='BuildTurretBuild.sense(LAccess)', godot_owner=SENSE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2484'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
