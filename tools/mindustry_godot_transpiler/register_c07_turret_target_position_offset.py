"""Register the TurretBuild.targetPosition() offset decl (N2432).

TurretBuild.targetPosition(Posc) (Turret.java:453-470): the 1
line N2122 did not register --
`var offset = Tmp.v1.setZero();` (:457, the charge offset
starts at zero before the accurateDelay branch).
Everything else in the method is already owned at N2122
(48 exprs, incl. the signature, the hasAmmo guard, the
peekAmmo call, the accurateDelay guard, the offset.set
call, the predictTarget guard, the Predict.intercept call,
the fallback set(pos) and the isZero guard) and is NOT
re-registered here. Remote N2266 owns the same method
(overlap 16/21 with local N2122) and also does not own
this line.

This slice extends the existing GD function
source_turret_target_position_state (N2122): it adds no new
owner, no new contract and no new schema (the N2427/N2430
registration-only precedent). The zero init is already
live as `velocity := Vector2.ZERO` in the GD func, only
recomputed when the target sits off the core; the exact
expr is quoted verbatim on its own comment line above the
func (the N2378 precedent: never split an exact expr
across lines).

NOT re-registered here: `if(!hasAmmo() || pos == null)
return;` (:454), `BulletType bullet = peekAmmo();`
(:455), the accurateDelay guard (:460), `offset.set(...)`
(:461), the predictTarget guard (:464),
`targetPos.set(Predict.intercept(...))` (:465),
`targetPos.set(pos);` (:467) and the isZero guard (:470)
stay owned at N2122.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c06_defense_leg import DEFERRED as N2122_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretTargetPositionOffsetProof'
UPDATE_OWNER = 'SourceTurretCombatState.source_turret_target_position_state'
TESTS = ['test_c07_turret_target_position_offset_registration', 'test_all_c07_turret_target_position_offset_input_evidence_is_exact', 'test_turret_target_position_offset_state', 'test_reference_graph_and_actual_c07_turret_target_position_offset']
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'var offset = Tmp.v1.setZero();',
]
SOURCE_SYMBOLS = [
    'source_turret_target_position_state_result.target_position',
    'source_turret_target_position_state_result.used_intercept',
    'source_turret_target_position_state_result.bullet_speed',
]

# DEFERRED is carried from the N2122 register script via import --
# never retyped. One entry is added: the N2432 Windows Godot
# proof debt (GOAL.md section 5).
DEFERRED = N2122_DEFERRED + [
    'TurretBuild.targetPosition() offset decl Windows Godot proof -- debt in GOAL.md section 5, same as N2122: the N2432 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def verify():
    """Check every EXACT_EXPRS line appears verbatim in its
    upstream source, without touching any SSOT JSON. Exit 0
    when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    total = len(EXACT_EXPRS)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    source_symbols.upsert_source_slice(GODOT, 'N2432', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.targetPosition(Posc)', godot_owner=UPDATE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=SOURCE_SYMBOLS, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {UPDATE_OWNER}
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
