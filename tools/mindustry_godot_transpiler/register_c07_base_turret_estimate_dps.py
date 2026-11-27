"""Register BaseTurretBuild.estimateDps() (N2486).

BaseTurretBuild.estimateDps() (BaseTurret.java:138-140) is one
slice (batch 54 slot 2):
    public float estimateDps(){
        return 0f;
    }
on `public class BaseTurretBuild extends Building implements
Ranged, RotBlock{` (BaseTurret.java:113). The override returns
the CONSTANT 0f and reads NO state: a BaseTurret has no ammo
and no bullet, so there is no DPS to compute. It takes no
params, so no input schema is upserted (the N2422 zero-param
contract precedent, same as N2481: `source_reload_turret_
ammo_reload_multiplier_state_result` exists with no `_input`
schema). One new result symbol: estimate_dps.

TRAP: this is NOT TurretBuild.estimateDps() (N2301,
Turret.java:740-745, the child-class method that computes
real DPS from shots / reload / peekAmmo().estimateDps() /
potentialEfficiency / timeScale): a port computing real DPS
is WRONG -- that is the child body, and a loaded turret
gives a nonzero value there but 0.0 here. N2301's GD owner
is `SourceTurretBuildState.source_turret_estimate_dps_state`
(TurretBuild.java order), and it ports NO BaseTurretBuild
override -- this slice adds the first GD function owned as
BaseTurretBuild.estimateDps(). TRAP: this is NOT
BaseTurretBuild.status() (N2475, BaseTurret.java:143-145)
and NOT buildRotation() (N2479, :129-131) -- the three
consecutive methods :129/:138/:143 are three separate
slices. Java order: estimateDps (:138-140) stands AFTER
drawSelect (:133-135) and BEFORE status (:143-145), so the
GD function sits between
source_base_turret_build_draw_select_state and
source_base_turret_build_status_state in
SourceTurretBuildState.gd.

CLEAN -- verified by the main thread for N2486
(2026-11-27), no twin-register needed: java_method
`BaseTurretBuild.estimateDps()` is 0-hit; the declaration
literal `public float estimateDps(){` hits N1236
(TractorBeamBuild), N2301 (TurretBuild), N2389
(ContinuousTurretBuild), N2533/N2536 (UnitType) -- all
different classes' estimateDps overrides, none of them
BaseTurretBuild; the body `return 0f;` is a generic
constant line, NOT twin evidence (same classification as
N2481's `return 1f;`). The registry has 0
`base_turret_estimate_dps` symbols before this slice, and
no GD function computes the BaseTurretBuild override yet.
This is NOT a duplicate like TeamData.active(), which was
permanently excluded because its behaviour was already
ported by N2074/N2075. One slice source: BaseTurret.java.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
BASE_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java'
PROOF = '/root/C07BaseTurretEstimateDpsProof'
ESTIMATE_DPS_OWNER = 'SourceTurretBuildState.source_base_turret_estimate_dps_state'
TESTS = ['test_c07_base_turret_estimate_dps_registration', 'test_all_c07_base_turret_estimate_dps_input_evidence_is_exact', 'test_base_turret_estimate_dps_state', 'test_reference_graph_and_actual_c07_base_turret_estimate_dps']
# The 1 slice source the N2486 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
]
FORMULA = '            return 0f;'
EXACT_EXPRS = [
    '        public float estimateDps(){',
    FORMULA,
    '    public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
]
JAVA_METHOD = 'BaseTurretBuild.estimateDps()'

DEFERRED = [
    'BaseTurretBuild.estimateDps() Windows Godot proof -- debt in GOAL.md section 5: the N2486 proof runs headless on Linux here and waits for a Windows Godot run.',
    'BaseTurretBuild.estimateDps() is CLEAN, verified by the main thread (2026-11-27), no twin-register needed: java_method `BaseTurretBuild.estimateDps()` is 0-hit and the registry has 0 `base_turret_estimate_dps` symbols before this slice. The declaration literal `public float estimateDps(){` hits N1236 (TractorBeamBuild), N2301 (TurretBuild), N2389 (ContinuousTurretBuild), N2533/N2536 (UnitType) -- all different classes\' estimateDps overrides, none BaseTurretBuild; the body `return 0f;` is a generic constant line, not twin evidence (same classification as N2481\'s `return 1f;`). No GD function computes the BaseTurretBuild override yet.',
    'TurretBuild.estimateDps() (Turret.java:740-745, N2301, real DPS from shots / reload / peekAmmo().estimateDps() / potentialEfficiency / timeScale) is NOT in this slice: it is the child-class method -- a loaded turret gives a nonzero value there and 0.0 here; the proof pins the cross-trap by evaluating the parent formula from locals (N2301 exposes the pure GD function source_turret_estimate_dps_state, but the cross-trap is pinned from the documented formula, same as the N2481 pattern).',
    'BaseTurretBuild.status() (BaseTurret.java:143-145, N2475, `(activationTimer <= 0)? super.status() : BlockStatus.inactive`) is NOT in this slice: status reads the activation timer and the super status, estimateDps reads nothing and returns the constant 0f.',
    'BaseTurretBuild.buildRotation() (BaseTurret.java:129-131, N2479, `return rotation;`) is NOT in this slice: buildRotation reads the inherited rotation field (default 90), estimateDps reads nothing.',
]


def definitions():
    def a(typ, expr, rule, source=BASE_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    # Zero params: estimateDps() takes no state -- no input schema
    # is registered (the N2422 zero-param contract precedent).
    estimate_dps_inputs = {}
    estimate_dps_outputs = {
        'estimate_dps': a('float', FORMULA, 'The estimated DPS (BaseTurret.java:138-140, `return 0f;`): the BaseTurretBuild override returns the constant 0f and reads no ammo, no reload, no efficiency -- a BaseTurret has no ammo and no bullet, so there is no DPS to compute. It must NOT compute real DPS like the child TurretBuild.estimateDps() (N2301, Turret.java:740-745), which gives a nonzero value for a loaded turret.'),
    }
    return estimate_dps_inputs, estimate_dps_outputs


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
    estimate_dps_inputs, estimate_dps_outputs = definitions()

    entries = [
        ('N2486', ESTIMATE_DPS_OWNER, 'source_base_turret_estimate_dps_state', BASE_TURRET, 'mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', JAVA_METHOD, estimate_dps_inputs, estimate_dps_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            # Zero params: skip the input schema entirely (the
            # N2422 precedent) -- an empty keys object fails
            # state-schema validation.
            if not keys:
                continue
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed BaseTurretBuild.estimateDps() state from BaseTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed BaseTurretBuild.estimateDps() state from BaseTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    by_slice['N2486'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2486', dict(status='done', java_source=BASE_TURRET, java_class='mindustry.world.blocks.defense.turrets.BaseTurret.BaseTurretBuild', java_method=JAVA_METHOD, godot_owner=ESTIMATE_DPS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2486'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
