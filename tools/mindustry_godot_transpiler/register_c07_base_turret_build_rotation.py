"""Register BaseTurretBuild.buildRotation() (N2479).

BaseTurretBuild.buildRotation() (BaseTurret.java:129-131) is one slice
(batch 52 slot 1):
    @Override
    public float buildRotation(){
        return rotation;
    }
The trap is FIELD vs UNIT: this reads the INHERITED `rotation` field
(`public float rotation = 90;`, BaseTurret.java:114, default 90) --
the OPPOSITE of N2477 BuildTurretBuild.buildRotation()
(BuildTurret.java:107-110, `return unit.rotation();`). The proof pins
the cross-trap: field 33 with a unit at 77 returns 33 here, while
N2477 returns 77 for the same pair. No clamp, no angle
normalisation: a negative rotation or one > 360 passes through whole.
This is NOT BaseTurretBuild.range() (N739, bare `range()`,
BaseTurret.java:124-126) -- a different method of the same class.

GENERIC-LITERAL NOTE -- the body literal `return rotation;` is
already an exact_expr of N2233 (RepairPointBuild.buildRotation(),
line Windows), N1839 (UnitComp.prefRotation()) and N2223
(BuildingComp.sense(LAccess)) -- a shared RotBlock literal, NOT a
port of THIS method: no slice cites it for BaseTurretBuild, and
the declaration `public float buildRotation(){` is cited only for
other classes (N2184 BuildTurretBuild, N2233 RepairPointBuild).
This slice adds the first GD function OWNED as
BaseTurretBuild.buildRotation(). No twin-register approval is
required for a generic literal (main thread confirmed 2026-11-27);
the note is recorded here and in the ledger deferred_exprs so a
later reader does not mistake the shared literal for a twin.
One slice source: BaseTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
PROOF = '/root/C07BaseTurretBuildRotationProof'
ROTATION_OWNER = 'SourceTurretBuildState.source_base_turret_build_rotation_state'
TESTS = ['test_c07_base_turret_build_rotation_registration', 'test_all_c07_base_turret_build_rotation_input_evidence_is_exact', 'test_base_turret_build_rotation_state', 'test_reference_graph_and_actual_c07_base_turret_build_rotation']
# The 1 slice source the N2479 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
]
FORMULA = '            return rotation;'
EXACT_EXPRS = [
    '        public float buildRotation(){',
    FORMULA,
    '        public float rotation = 90;',
    '    public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
]
JAVA_METHOD = 'BaseTurretBuild.buildRotation()'

DEFERRED = [
    'BaseTurretBuild.buildRotation() Windows Godot proof -- debt in GOAL.md section 5: the N2479 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BaseTurretBuild.buildRotation() generic-literal note (NOT a twin-register, no approval required -- main thread confirmed 2026-11-27): the body literal `return rotation;` is already an exact_expr of N2233 (RepairPointBuild.buildRotation(), line Windows), N1839 (UnitComp.prefRotation()) and N2223 (BuildingComp.sense(LAccess)); the declaration `public float buildRotation(){` is cited only for other classes (N2184 BuildTurretBuild, N2233 RepairPointBuild). No slice cites either literal for BaseTurretBuild, so this slice adds the first GD function owned as BaseTurretBuild.buildRotation().',
    'BuildTurretBuild.buildRotation() (BuildTurret.java:107-110, N2477) is NOT in this slice: it reads `unit.rotation()`, a different method of the child class -- the proof pins the cross-trap (field 33 + unit 77 returns 33 here, 77 in N2477).',
    'BaseTurretBuild.estimateDps() (BaseTurret.java:137-139) is NOT in this slice: it sits between drawSelect() (:133-135) and status() (:143-145) in Java and is spared -- a later slice inserts its GD function between source_base_turret_build_draw_select_state and source_base_turret_build_status_state.',
]


def definitions():
    def a(typ, expr, rule, source=BASE_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    rotation_inputs = {
        'rotation': a('float', FORMULA, 'The inherited `rotation` field (BaseTurret.java:114, `public float rotation = 90;`, default 90): the field itself, NOT the unit rotation -- the opposite of N2477 (BuildTurretBuild.buildRotation() reads `unit.rotation()`). No clamp, no angle normalisation.'),
    }
    rotation_outputs = {
        'build_rotation': a('float', FORMULA, 'The build rotation (BaseTurret.java:130, `return rotation;`): the field value passed through whole, unclamped and unnormalised.'),
    }
    return rotation_inputs, rotation_outputs


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
    rotation_inputs, rotation_outputs = definitions()

    entries = [
        ('N2479', ROTATION_OWNER, 'source_base_turret_build_rotation_state', BASE_TURRET, 'mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', JAVA_METHOD, rotation_inputs, rotation_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BaseTurretBuild.buildRotation() state from BaseTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BaseTurretBuild.buildRotation() state from BaseTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2479'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2479', dict(status='done', java_source=BASE_TURRET, java_class='mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', java_method=JAVA_METHOD, godot_owner=ROTATION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2479'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
