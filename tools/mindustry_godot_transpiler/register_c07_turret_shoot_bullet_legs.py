"""Register the TurretBuild shoot()/bullet() leftover legs (N2428).

TurretBuild.shoot() (Turret.java:741-774, `protected void
shoot(BulletType type){`) + TurretBuild.bullet()
(Turret.java:776-810, `protected void bullet(BulletType
type, float xOffset, float yOffset, float angleOffset,
Mover mover){`) -- this slice is ONLY the 6 legs remote
N2269/N2252 did not register:

- `int barrel = barrelCounter;` (:756, in the
  ShootPattern lambda)
- `int prev = barrelCounter;` (:761, in the Time.run
  lambda)
- `barrelCounter = barrel;` (:762)
- `barrelCounter = prev;` (:764)
- `ammoUseEffect.at(` (:796, the 4-line call :796-799
  counts as ONE expr, the N816 multi-line-call
  precedent: N816 registered `type.fallEngineEffect.at(`
  for the same shape)
- `if(shake > 0){` (:802, opener only)

NOT this slice: the ammo-eject arg lines (:797-799) are
implemented as the effect position/rotation computation,
not separate exprs -- they are the arguments of the one
registered `ammoUseEffect.at(` call. `bullet(type,
xOffset, yOffset, angle, mover);` (:763/:767) is a
call-site of the bullet Callable, owned by remote N2269
-- it arrives as the bullet Callable param and is never
re-ported. `Effect.shake(shake, shake, this);` (:803),
the body of the shake guard, is NOT registered: the same
text is already owned at N774 (UnitComp.destroy) and
N2294 (BurstDrillBuild.updateTile) in other methods, so
the TurretBuild.bullet() occurrence stays for a later
slice (deferred). The rest of shoot()/bullet()
(geometry :743-745, charge :748-749, queuedBullets
:755/:777, handleBullet/create :790, shoot/smoke/sound
effects :792-794, recoil/heat :806-810) stays with
remote N2269/N2252 / future slices.

The 6 exprs are 0-hit in BOTH ledgers at RED as
distinct Java lines: `barrelCounter = barrel;` /
`barrelCounter = prev;` appear as SUBSTRINGS of N854's
`mount.barrelCounter = barrel;` /
`mount.barrelCounter = prev;` (Weapon.shoot(), a
different class/method/receiver) -- false positives, not
the TurretBuild lines. One pure function on
SourceTurretBuildState.gd (the Turret file, static func
-- the N2184/N2397 convention). One owner + one GD func
+ one contract. The barrel counter is live build state,
so it arrives in the frame Dictionary (the N2397 frame
precedent) and the delayed action reads/writes it there
when it runs; bullet() and Time.run arrive as Callables
(the N2395 precedent). Slice source: Turret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_find_enemy import DEFERRED as N2425_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PROOF = '/root/C07TurretShootBulletLegsProof'
LEGS_OWNER = 'SourceTurretBuildState.source_turret_shoot_bullet_legs_state'
TESTS = ['test_c07_turret_shoot_bullet_legs_registration', 'test_all_c07_turret_shoot_bullet_legs_input_evidence_is_exact', 'test_turret_shoot_bullet_legs_state', 'test_reference_graph_and_actual_c07_turret_shoot_bullet_legs']
# The 1 slice source the N2428 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
]
EXACT_EXPRS = [
    'int barrel = barrelCounter;',
    'int prev = barrelCounter;',
    'barrelCounter = barrel;',
    'barrelCounter = prev;',
    'ammoUseEffect.at(',
    'if(shake > 0){',
]

# DEFERRED is carried from the N2425 register script via import --
# never retyped. This slice resolves NONE of the carried entries
# (the shoot/bullet legs are not the findEnemy legs), so all are
# carried verbatim. Three entries are added: the N2428 Windows
# proof debt, the shake body, and the rest of shoot()/bullet().
DEFERRED = N2425_DEFERRED + [
    'TurretBuild shoot()/bullet() leftover legs Windows Godot proof -- debt in GOAL.md section 5, same as N2425: the N2428 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Effect.shake(shake, shake, this); (Turret.java:803, the body of the `if(shake > 0){` guard in TurretBuild.bullet()) -- same text already owned at N774 (UnitComp.destroy) and N2294 (BurstDrillBuild.updateTile) in other methods, so the TurretBuild.bullet() occurrence needs its own twin-registration slice (the N2421 precedent).',
    'Port the rest of TurretBuild.shoot()/bullet() (Turret.java:743-745 geometry, :748-749 charge, :755/:777 queuedBullets, :790 handleBullet/create, :792-794 shoot/smoke/sound effects, :806-810 recoil/heat) as their own slices; N2428 covers only the 6 leftover legs :756/:761-762/:764/:796/:802, and the remote N2269/N2252-owned lines inside the two methods are NOT re-ported.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    legs_inputs = {
        'frame': a('Dictionary', 'protected void shoot(BulletType type){', 'The turret frame (accepted for the family call shape; it carries the live barrel_counter key -- the barrel counter is live build state (Turret.java:301, `public int totalShots, barrelCounter;`), so the delayed action reads/writes it there when it runs, the N2397 frame precedent).'),
        'delay': a('float', 'if(delay > 0f){', 'The pattern delay for this shot (Turret.java:758, `if(delay > 0f){`): the ShootPattern lambda param -- above zero the bullet is queued through Time.run, at zero it fires at once.'),
        'bullet': a('Callable', 'bullet(type, xOffset, yOffset, angle, mover);', 'The bullet() call (Turret.java:763, `bullet(type, xOffset, yOffset, angle, mover);`): bullet() (body N2269-remote) is a call-site, so it arrives as a Callable param (type, x_offset, y_offset, angle, mover) and the call is recorded, never re-ported.'),
        'time_run': a('Callable', 'Time.run(delay, () -> {', 'The delayed-run hook (Turret.java:759, `Time.run(delay, () -> {`): Time.run is not ported -- it arrives as a Callable param (delay, action) recording the delay + the barrel save/restore action; the bullet only fires when the recorded action executes.'),
        'bullet_type': a('Variant', 'protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', 'The bullet type (Turret.java:776, `protected void bullet(BulletType type, ...){`): the BulletType the queued shot fires, passed through to the bullet Callable.'),
        'x_offset': a('float', 'protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', 'The shot x offset (Turret.java:776, `protected void bullet(BulletType type, float xOffset, ...){`): the ShootPattern lambda param -- also the sign source for the ammo-eject effect rotation (`rotation * Mathf.sign(xOffset)`, :799).'),
        'y_offset': a('float', 'protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', 'The shot y offset (Turret.java:776, `protected void bullet(BulletType type, float xOffset, float yOffset, ...){`): the ShootPattern lambda param, passed through to the bullet Callable.'),
        'angle_offset': a('float', 'protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', 'The shot angle offset (Turret.java:776, `protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, ...){`): the ShootPattern lambda param, passed through to the bullet Callable.'),
        'mover': a('Variant', 'protected void bullet(BulletType type, float xOffset, float yOffset, float angleOffset, Mover mover){', 'The bullet mover (Turret.java:776, `protected void bullet(BulletType type, ..., Mover mover){`): the ShootPattern lambda param, passed through to the bullet Callable.'),
        'x': a('float', 'x - Angles.trnsx(rotation, ammoEjectBack),', 'The build x position (Turret.java:797, `x - Angles.trnsx(rotation, ammoEjectBack),`): BuildingComp x, the ammo-eject effect origin before the pull-back along the aim angle.'),
        'y': a('float', 'y - Angles.trnsy(rotation, ammoEjectBack),', 'The build y position (Turret.java:798, `y - Angles.trnsy(rotation, ammoEjectBack),`): BuildingComp y, the ammo-eject effect origin before the pull-back along the aim angle.'),
        'rotation': a('float', 'rotation * Mathf.sign(xOffset)', 'The aim rotation (Turret.java:799, `rotation * Mathf.sign(xOffset)`): BaseTurretBuild rotation, the ammo-eject effect angle before the shot-side sign.'),
        'ammo_eject_back': a('float', 'public float ammoEjectBack = 1f;', 'The ammo eject pull-back (Turret.java, `public float ammoEjectBack = 1f;`): how far behind the turret the ammo-eject effect spawns, along the aim angle.'),
        'shake': a('float', 'public float shake = 0f;', 'The shake amount (Turret.java, `public float shake = 0f;`): the Turret field -- the guard opens only above zero.'),
        'ammo_use_effect': a('Callable', 'ammoUseEffect.at(', 'The ammo-eject effect call (Turret.java:796, `ammoUseEffect.at(`): Effect.at is an engine call, so it arrives as a Callable param (x, y, rotation) and the call is recorded, never re-ported.'),
    }
    legs_outputs = {
        'barrel': a('int', 'int barrel = barrelCounter;', 'The captured barrel (Turret.java:756, `int barrel = barrelCounter;`): the barrelCounter value at shoot() time -- the Time.run lambda closes over this local, so a later shot cannot change which barrel this bullet uses.'),
        'delayed': a('bool', 'if(delay > 0f){', 'Whether the shot was delayed (Turret.java:758, `if(delay > 0f){`): true exactly when the bullet went through Time.run instead of firing at once.'),
        'ammo_use_effect_x': a('float', 'x - Angles.trnsx(rotation, ammoEjectBack),', 'The ammo-eject effect x (Turret.java:797, `x - Angles.trnsx(rotation, ammoEjectBack),`): x minus the pull-back along the aim angle (2-arg trnsx = len * cos, Angles.java:66-70).'),
        'ammo_use_effect_y': a('float', 'y - Angles.trnsy(rotation, ammoEjectBack),', 'The ammo-eject effect y (Turret.java:798, `y - Angles.trnsy(rotation, ammoEjectBack),`): y minus the pull-back along the aim angle (2-arg trnsy = len * sin, Angles.java:66-70).'),
        'ammo_use_effect_rotation': a('float', 'rotation * Mathf.sign(xOffset)', 'The ammo-eject effect rotation (Turret.java:799, `rotation * Mathf.sign(xOffset)`): the aim rotation times the sign of the shot x offset -- left shots eject mirrored.'),
        'shake_applies': a('bool', 'if(shake > 0){', 'Whether the shake guard opens (Turret.java:802, `if(shake > 0){`): true exactly when shake is above zero -- opener only, the Effect.shake body is deferred.'),
    }
    return legs_inputs, legs_outputs


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
    (legs_inputs, legs_outputs) = definitions()

    entries = [
        ('N2428', LEGS_OWNER, 'source_turret_shoot_bullet_legs_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.shoot()/TurretBuild.bullet()', legs_inputs, legs_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TurretBuild.shoot()/bullet() leftover legs from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TurretBuild.shoot()/bullet() leftover legs from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: barrel, delayed,
    # ammo_use_effect_x, ammo_use_effect_y,
    # ammo_use_effect_rotation, shake_applies.
    by_slice['N2428'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2428', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.shoot()/TurretBuild.bullet()', godot_owner=LEGS_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2428'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
