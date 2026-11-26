"""Register BuildTurretBuild.buildRotation() (N2477).

BuildTurretBuild.buildRotation() (BuildTurret.java:107-110) is one
slice (batch 51 slot 2):
    @Override
    public float buildRotation(){
        return unit.rotation();
    }
It reads the rotation of the builder UNIT (BlockUnitc), not the
inherited `rotation` field of BaseTurretBuild. `unit` is the
BuildTurretBuild field (BuildTurret.java:93,
`public BlockUnitc unit = (BlockUnitc)unitType.create(team);`),
initialised to rotation 90f in the instance block
(:98-100, `unit.rotation(90f);`). updateTile (:121) assigns
the inherited field from the unit every tick
(`rotation = unit.rotation();`), so between ticks the two can
differ -- and a port that reads the field is wrong. There is
no clamp and no angle normalisation: a negative angle or an
angle > 360 passes through whole (Java has no Math.min/max
or angle wrap here). Do NOT confuse with
BaseTurretBuild.buildRotation() (BaseTurret.java:129-131,
`return rotation;` -- reads the FIELD, a different method
in the parent class, backup B, NOT registered by this
slice) or with RepairPointBuild.buildRotation() (N2233,
Windows line -- same RotBlock interface, a different class
that also reads its field). One GD function on the
existing file SourceBuildTurretBuildState.gd (home of N2184
source_build_turret_power_status_row_state), placed before
source_build_turret_power_status_row_state (Java updateTile
:121-139) and before source_build_turret_should_consume_state
(Java shouldConsume :229-230) because buildRotation()
(:107-110) comes before both in Java order; the spare
canControl (:103-105) would slot before buildRotation if
ported later. The input `unit_rotation` is the precomputed
unit rotation (float) -- the GD function returns it whole.

TWIN-REGISTER -- approved explicitly by the main thread
for N2477 (2026-11-26). The body literal
`return unit.rotation();` (and the declaration line
`public float buildRotation(){`) is ALREADY an exact_expr
of N2184 (BuildTurretBuild.updateTile, owner GD
SourceBuildTurretBuildState.source_build_turret_power_status_row_state),
which cites the BuildTurret.java:103-110 rows (canControl +
buildRotation) only as dependency evidence -- N2184 ports
NO buildRotation function (its godot_owner is the
power-status row state), and its own deferred_exprs say
"BuildTurret unit rows (... canControl / buildRotation,
BuildTurret.java:103-110; ...) -- unit creation + control
waits for its own slice", i.e. N2184 itself declares
buildRotation waits for its own slice. The second literal
hit, N2233 (RepairPointBuild.buildRotation, Windows line),
is the same RotBlock signature in a different class, not
this method. java_method `BuildTurretBuild.buildRotation()`
is 0-hit and no GD function computes it yet, so this
slice adds a real new GD function -- NOT a duplicate like
TeamData.active(), which was permanently excluded because
its behaviour was already ported by N2074/N2075. Precedent
for twin registration with explicit main-thread approval:
N2474 (isCampaign, literal owned by N2124), N2421
(`return isShooting;`), N2389, N2418. One slice source:
BuildTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BUILD_TURRET = 'core/src/mindustry/world/blocks/defense/BuildTurret.java'
PROOF = '/root/C07BuildTurretBuildRotationProof'
BUILD_ROTATION_OWNER = 'SourceBuildTurretBuildState.source_build_turret_build_rotation_state'
TESTS = ['test_c07_build_turret_build_rotation_registration', 'test_all_c07_build_turret_build_rotation_input_evidence_is_exact', 'test_build_turret_build_rotation_state', 'test_reference_graph_and_actual_c07_build_turret_build_rotation']
# The 1 slice source the N2477 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/BuildTurret.java',
]
FORMULA = '            return unit.rotation();'
EXACT_EXPRS = [
    '        public float buildRotation(){',
    FORMULA,
    '        public BlockUnitc unit = (BlockUnitc)unitType.create(team);',
]
JAVA_METHOD = 'BuildTurretBuild.buildRotation()'

DEFERRED = [
    'BuildTurretBuild.buildRotation() Windows Godot proof -- debt in GOAL.md section 5: the N2477 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BuildTurretBuild.buildRotation() is a TWIN-REGISTER with explicit main-thread approval (2026-11-26): the literals `public float buildRotation(){` and `return unit.rotation();` are also exact_exprs of N2184 (BuildTurretBuild.updateTile), which cites the BuildTurret.java:103-110 rows only as dependency evidence and ports no buildRotation function; N2184 is the original owner of the literals, and its own deferred_exprs say buildRotation "waits for its own slice". Precedent: N2474, N2421, N2389, N2418.',
    'BaseTurretBuild.buildRotation() (BaseTurret.java:129-131, `return rotation;` -- reads the inherited field) is NOT in this slice: it is a different method in the parent class with a different body, and needs its own slice (backup B).',
]


def definitions():
    def a(typ, expr, rule, source=BUILD_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    build_rotation_inputs = {
        'unit_rotation': a('float', FORMULA, 'The builder unit rotation (BuildTurret.java:107-110): the precomputed `unit.rotation()` of the BuildTurretBuild field `unit` (BuildTurret.java:93), initialised to 90f (:98-100, `unit.rotation(90f);`) -- NOT the inherited `rotation` field of BaseTurretBuild, which updateTile (:121) assigns from the unit every tick and which can differ between ticks.'),
    }
    build_rotation_outputs = {
        'build_rotation': a('float', FORMULA, 'The build rotation (BuildTurret.java:107-110): `unit.rotation()` returned whole -- no clamp, no angle normalisation (a negative angle or an angle > 360 passes through; Java has no Math.min/max or angle wrap here).'),
    }
    return build_rotation_inputs, build_rotation_outputs


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
    build_rotation_inputs, build_rotation_outputs = definitions()

    entries = [
        ('N2477', BUILD_ROTATION_OWNER, 'source_build_turret_build_rotation_state', BUILD_TURRET, 'mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', JAVA_METHOD, build_rotation_inputs, build_rotation_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2096 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.buildRotation() state from BuildTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BuildTurretBuild.buildRotation() state from BuildTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2477'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2477', dict(status='done', java_source=BUILD_TURRET, java_class='mindustry.world.blocks.defense.BuildTurret.BuildTurretBuild', java_method=JAVA_METHOD, godot_owner=BUILD_ROTATION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2477'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
