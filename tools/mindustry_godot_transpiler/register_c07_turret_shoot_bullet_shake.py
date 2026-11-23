"""Register the TurretBuild.bullet() shake body (N2435).

TurretBuild.bullet() (Turret.java:776-810, `protected void
bullet(BulletType type, float xOffset, float yOffset, float
angleOffset, Mover mover){`) -- this slice is ONLY the 1
expr N2428 deferred:

- `Effect.shake(shake, shake, this);` (:803, the body of
  the `if(shake > 0){` guard :802)

The same text is already owned at N774 (UnitComp.destroy)
and N2194-N2200 (ShockwaveTowerBuild.updateTile) and N2294
(BurstDrillBuild.updateTile) in other methods -- this is
the twin-registration of the TurretBuild.bullet()
occurrence under N2428's owner (the N2421 precedent; the
GD comment deferred it to this slice).

This slice extends the existing GD function
source_turret_shoot_bullet_legs_state (N2428): it adds no
new owner and no new contract entry (the N2430 same-owner
precedent). It adds ONE new result key, `shake_effect` --
`Effect.shake(intensity, duration, Position)` fires a
camera shake of the given intensity for the given duration
at the build (Effect.java:210), so the body is recorded
as data `{"intensity": shake, "duration": shake, "x": x,
"y": y}` when the guard opens and `{}` when it does not
(the N2437 runWave precedent: engine calls not yet wired
are recorded in the returned Dictionary). The shared
result schema and the shared contract gain that one key
(their `source_slice` stays N2428); the func signature
is unchanged (no new param), so N2428's test and proof
are untouched. The stale "the Effect.shake body is
deferred" phrase in the shared `shake_applies` rule is
fixed in the same upsert (the body is registered here).

NOT re-registered here: the guard opener :802 (N2428),
`ammoUseEffect.at(` :796 (N2428), the barrel legs
:756/:761-762/:764 (N2428), `curRecoil = 1f;` /
`curRecoils[...] = 1f;` / `heat = 1f;` / `totalShots++;` /
`useAmmo();` / `if(!consumeAmmoOnce){` (already owned).
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_shoot_bullet_legs import (
    DEFERRED as N2428_DEFERRED,
)
from register_c07_turret_shoot_bullet_legs import (
    LEGS_OWNER,
    PROOF as N2428_PROOF,
)
from register_c07_turret_shoot_bullet_legs import (
    definitions as n2428_definitions,
)
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretShootBulletShakeProof'
TESTS = ['test_c07_turret_shoot_bullet_shake_registration', 'test_all_c07_turret_shoot_bullet_shake_input_evidence_is_exact', 'test_turret_shoot_bullet_shake_state', 'test_reference_graph_and_actual_c07_turret_shoot_bullet_shake']
# The 1 slice source the N2435 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'Effect.shake(shake, shake, this);',
]
SOURCE_SYMBOLS = [
    'source_turret_shoot_bullet_legs_state_result.shake_effect',
]

# DEFERRED is carried from the N2428 register script via import --
# never retyped. The shake-body entry is DROPPED: this slice IS
# the twin-registration it asked for (asserted below: exactly
# one entry dropped). One entry is added: the N2435 Windows
# Godot proof debt (GOAL.md section 5).
_DEFERRED_DROPPED = [e for e in N2428_DEFERRED if 'Turret.java:803' in e]
assert len(_DEFERRED_DROPPED) == 1, _DEFERRED_DROPPED
DEFERRED = [e for e in N2428_DEFERRED if 'Turret.java:803' not in e] + [
    'TurretBuild shoot()/bullet() shake body Windows Godot proof -- debt in GOAL.md section 5, same as N2428: the N2435 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def extended_definitions():
    """N2428's inputs/outputs plus the one new result key,
    with the stale 'body is deferred' phrase in the
    `shake_applies` rule fixed (the body is registered
    at N2435)."""
    legs_inputs, legs_outputs = n2428_definitions()
    legs_outputs['shake_applies']['rule'] = 'Whether the shake guard opens (Turret.java:802, `if(shake > 0){`): true exactly when shake is above zero -- opener only; the Effect.shake body is registered at N2435.'
    legs_outputs['shake_effect'] = backed('Dictionary', TURRET, 'Effect.shake(shake, shake, this);', 'The shake effect (Turret.java:803, `Effect.shake(shake, shake, this);`): Effect.shake(intensity, duration, Position) fires a camera shake of the given intensity for the given duration at the build (Effect.java:210) -- both args are the same `shake` value, so the recorded call is {"intensity": shake, "duration": shake, "x": x, "y": y} when the guard opens and {} when it does not.')
    return legs_inputs, legs_outputs


def verify():
    """Check the expr and every input/output java_expr
    appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    inputs_outputs = [extended_definitions()]
    total = len(EXACT_EXPRS)
    for pair in inputs_outputs:
        for keys in pair:
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
    (legs_inputs, legs_outputs) = extended_definitions()
    prefix = 'source_turret_shoot_bullet_legs_state'
    method = 'TurretBuild.shoot()/TurretBuild.bullet()'

    # The ONE new symbol. The shared `shake_applies`
    # symbol is re-upserted with only its rule fixed
    # (copied verbatim from the registry first -- never
    # retyped); every other field stays exactly as N2428
    # registered it.
    registry = source_symbols.load_source_symbol_registry(GODOT)
    shake_applies = dict(registry['symbols']['source_turret_shoot_bullet_legs_state_result.shake_applies'])
    shake_applies['rule'] = legs_outputs['shake_applies']['rule']
    symbols = {}
    shake_effect_meta = legs_outputs['shake_effect']
    shake_effect_meta['used_by'] = [LEGS_OWNER]
    symbols['source_turret_shoot_bullet_legs_state_result.shake_effect'] = dict(status='source-backed', godot_owner=LEGS_OWNER, godot_symbol='source_turret_shoot_bullet_legs_state_result.shake_effect', java_source=shake_effect_meta['java_source'], java_method=method, java_expr=shake_effect_meta['java_expr'], rule=shake_effect_meta['rule'], tests=TESTS, runtime_proof=PROOF)
    symbols['source_turret_shoot_bullet_legs_state_result.shake_applies'] = shake_applies

    # The shared result schema and the shared contract
    # gain the one new key; source_slice stays N2428
    # and every other field stays exactly as N2428
    # registered it (params, tests and rule copied from
    # the live catalog -- never retyped).
    for keys in (legs_inputs, legs_outputs):
        for meta in keys.values():
            meta['used_by'] = [LEGS_OWNER]
    contracts = source_symbols.load_source_api_contracts(GODOT)
    old_contract = dict(contracts['contracts'][LEGS_OWNER])
    old_contract['return_keys'] = list(legs_outputs)
    source_symbols.upsert_source_state_schema(GODOT, prefix + '_result', dict(status='active', owner=LEGS_OWNER, source_slice='N2428', keys=legs_outputs, runtime_proof=N2428_PROOF, rule='Source-backed TurretBuild.shoot()/bullet() leftover legs from Turret.java.'))
    source_symbols.upsert_source_api_contract(GODOT, LEGS_OWNER, old_contract)

    source_symbols.upsert_source_slice(GODOT, 'N2435', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method=method, godot_owner=LEGS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=SOURCE_SYMBOLS, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {LEGS_OWNER}
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
