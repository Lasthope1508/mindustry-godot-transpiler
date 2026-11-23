"""Register the ContinuousTurret updateShooting() (N2367).

ContinuousTurretBuild.updateShooting()
(ContinuousTurret.java:138-146, `protected void
updateShooting(){` / `if(bullets.any()){` / `return;` /
`if(canConsume() && !charging() && shootWarmup >= minWarmup){` /
`shoot(peekAmmo());`) is one pure function on the existing
SourceContinuousTurretBuildPortBridge.gd (created by N2355,
updateTile by N2362, updateBullet by N2366), following the
ItemTurret PortBridge precedent (SourceItemTurretBuildPortBridge.gd:23,
source_item_turret_build_get_ammo_fraction_state) and the
ContinuousTurret PortBridge precedent (N2355, N2362, N2366).
It decides whether a new shot is fired this tick: only when
no bullet is flying and the consume / charging / warmup
guard holds.

RED decisions (resolved at RED): (1) The function lives
directly in the existing PortBridge file: there is no
SourceContinuousTurretBuildState.gd to delegate to. The
SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed at N2355, owner PortGame here.
(2) canConsume() is the TurretBuild callee (Turret.java:624-629,
heatRequirement gate then super.canConsume()) -- its value
arrives as the explicit can_consume param, not re-ported.
(3) charging() is the TurretBuild callee (Turret.java:714-716,
`return queuedBullets > 0 && shoot.firstShotDelay > 0;`) --
its value arrives as the explicit charging param, not
re-ported.
(4) peekAmmo() here is ContinuousTurretBuild.peekAmmo
(ContinuousTurret.java:70-72, `return shootType;`), whose
body is already owned by N1172 (PowerTurretBuild.peekAmmo)
-- its value arrives as the explicit ammo_type param, not
re-ported. shoot() is the TurretBuild callee
(Turret.java:742) -- the shot decision is the observable
effect, returned as shot.
(5) minWarmup is the Turret field (Turret.java:76, default
0f) -- the shoot threshold, explicit param. shootWarmup is
the TurretBuild field (Turret.java:286).
(6) The bullets Seq is NOT ported: its emptiness arrives as
the explicit has_bullets param (the N2330 param precedent).
(7) `shoot(peekAmmo());` is a 0-hit in both ledgers.
`if(bullets.any()){` shares text with N2362 (updateTile,
same class) and N2364 (LaserTurret.updateShooting,
different class) -- registered under this java_method (the
N632-N639 vs N1078-N1085 precedent); the main thread
decides whether to keep it as an exact_expr or move it to
bridge evidence at merge.
(8) Unlike LaserTurret.updateShooting (N2364) the guard
here is canConsume() (no reloadCounter / efficiency leg)
and shoot(peekAmmo()) is a single line -- a different
method on a different class, no dedup.
(9) NO driver line yet: the pure function returns the
decision frame the driver writes; the driver tick that
calls it per tick is a later slice.
Two new result symbols: shot, ammo_type.
Slice source: ContinuousTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_update_bullet import DEFERRED as N2366_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretUpdateShootingProof'
UPDATE_SHOOTING_OWNER = 'PortGame.source_continuous_turret_build_update_shooting_state'
TESTS = ['test_c07_continuous_turret_update_shooting_registration', 'test_all_c07_continuous_turret_update_shooting_input_evidence_is_exact', 'test_continuous_turret_update_shooting_state', 'test_reference_graph_and_actual_c07_continuous_turret_update_shooting']
# The 1 slice source the N2367 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    'public class ContinuousTurret extends Turret{',
    'public class ContinuousTurretBuild extends TurretBuild{',
    '@Override',
    'protected void updateShooting(){',
    'if(bullets.any()){',
    'if(canConsume() && !charging() && shootWarmup >= minWarmup){',
    'shoot(peekAmmo());',
]

# DEFERRED is carried from the N2366 register script via import --
# never retyped. All N2366 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2366's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2367's Windows proof debt.
DEFERRED = list(N2366_DEFERRED) + [
    'ContinuousTurret updateShooting Windows Godot proof -- debt in GOAL.md section 5, same as N2366: the N2367 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    guard = 'if(canConsume() && !charging() && shootWarmup >= minWarmup){'
    update_shooting_inputs = {
        'has_bullets': a('bool', 'if(bullets.any()){', 'Whether the bullets seq is non-empty, bullets.any() (ContinuousTurret.java:139): the seq itself is NOT ported -- its emptiness arrives as an explicit param (the N2330 param precedent).'),
        'can_consume': a('bool', guard, 'Whether the turret can consume, canConsume() (ContinuousTurret.java:143, Turret.java:624-629): a callee, its value arrives as an explicit param, not re-ported here.'),
        'charging': a('bool', guard, 'Whether the turret is charging, charging() (ContinuousTurret.java:143, Turret.java:714-716): a callee, its value arrives as an explicit param, not re-ported here.'),
        'shoot_warmup': a('float', guard, 'The shoot warmup, shootWarmup (ContinuousTurret.java:143, Turret.java:286): shooting requires it at or above minWarmup.'),
        'min_warmup': a('float', guard, 'The minimum warmup, minWarmup (ContinuousTurret.java:143, Turret.java:76 `public float minWarmup = 0f;`): the shoot threshold.'),
        'ammo_type': a('Variant', 'shoot(peekAmmo());', 'The peekAmmo() result (ContinuousTurret.java:144): peekAmmo() here is ContinuousTurretBuild.peekAmmo (:70-72, `return shootType;`), whose body is already owned by N1172 (PowerTurretBuild.peekAmmo) -- its value arrives as an explicit param, not re-ported here.'),
    }
    update_shooting_outputs = {
        'shot': a('bool', 'shoot(peekAmmo());', 'Whether to shoot (ContinuousTurret.java:144, `shoot(peekAmmo());`): true only when no bullet is flying and the guard holds -- the shoot call is the observable effect of the decision.'),
        'ammo_type': a('Variant', 'shoot(peekAmmo());', 'The type to shoot (ContinuousTurret.java:144, `shoot(peekAmmo());`): the peekAmmo() result when shooting, null otherwise.'),
    }
    return (update_shooting_inputs, update_shooting_outputs)


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
    inputs_outputs = [definitions()]
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
    symbols = {}
    (update_shooting_inputs, update_shooting_outputs) = definitions()

    entries = [
        ('N2367', UPDATE_SHOOTING_OWNER, 'source_continuous_turret_build_update_shooting_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.updateShooting()', update_shooting_inputs, update_shooting_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.updateShooting() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.updateShooting() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: shot, ammo_type.
    by_slice['N2367'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2367', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.updateShooting()', godot_owner=UPDATE_SHOOTING_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2367'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
