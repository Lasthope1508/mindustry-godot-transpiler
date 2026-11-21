"""Register the ContinuousTurret updateBullet() (N2366).

ContinuousTurretBuild.updateBullet()
(ContinuousTurret.java:102-130, `protected void
updateBullet(BulletEntry entry){` / `float` /
`bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),` /
`bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),` /
`angle = rotation + entry.rotation;` /
`entry.bullet.rotation(angle);` /
`entry.bullet.set(bulletX, bulletY);` /
`//target length of laser` /
`float shootLength = Math.min(dst(targetPos), range);` /
`//current length of laser` /
`float curLength = dst(entry.bullet.aimX, entry.bullet.aimY);` /
`//resulting length of the bullet (smoothed)` /
`float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);` /
`//actual aim end point based on length` /
`Tmp.v1.trns(rotation, lastLength = resultLength).add(x, y);` /
`entry.bullet.aimX = Tmp.v1.x;` /
`entry.bullet.aimY = Tmp.v1.y;` /
`if(scaleDamageEfficiency){` /
`entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();` /
`}` /
`if(isShooting && hasAmmo()){` /
`entry.bullet.time = entry.bullet.lifetime * entry.bullet.type.optimalLifeFract * Math.min(shootWarmup, efficiency);` /
`entry.bullet.keepAlive = true;` /
`}`) is one pure function on the existing
SourceContinuousTurretBuildPortBridge.gd (created by N2355,
updateTile by N2362), following the ItemTurret PortBridge
precedent (SourceItemTurretBuildPortBridge.gd:23,
source_item_turret_build_get_ammo_fraction_state) and the
ContinuousTurret PortBridge precedent (N2355, N2362). It
moves one surviving bullet to its rotated muzzle offset,
re-aims its laser end point toward the target with a
smoothed length, and refreshes its damage / lifetime while
the turret is shooting.

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
(2) Angles.trnsx/trnsy here are the THREE-arg overloads
(Angles.java:74-79): they rotate the (shootX + entry.x,
shootY + entry.y) offset vector by rotation - 90 degrees --
NOT the len overloads -- so the offset is
Vector2(shootX + entry.x, shootY + entry.y).rotated(
deg_to_rad(rotation - 90)) in GDScript.
(3) dst(targetPos) is the distance from the building (x, y)
to targetPos, and dst(aimX, aimY) the distance from (x, y)
to the bullet aim point -- both Vector2.distance_to here.
(4) Mathf.approachDelta(from, to, speed) is approach(from,
to, Time.delta * speed) (Mathf.java:420-422), so Time.delta
arrives as the explicit source_delta param (the N2330 param
precedent); the step is computed inline, exactly
SourceMathState.source_approach_delta. aimChangeSpeed
defaults to Float.POSITIVE_INFINITY (ContinuousTurret.java:17),
so with delta > 0 the length snaps to shootLength in one tick.
(5) The resultLength line shares text with N866
(Weapon.update continuous laser aim, same text in a
different method) -- registered under this java_method
(the N632-N639 vs N1078-N1085 precedent); the main thread
decides whether to keep it as an exact_expr or move it to
bridge evidence at merge.
(6) entry arrives as a Dictionary {x, y, rotation, bullet}
and bullet as {aim_x, aim_y, damage, time, lifetime,
type_damage, type_optimal_life_fract, damage_multiplier}:
BulletEntry (Turret.java:864-875), BulletType.damage /
lifetime / optimalLifeFract and Bullet.damageMultiplier()
(BulletComp.java:95) are NOT re-ported; their values arrive
as explicit fields (the N2330 param precedent). shootX /
shootY are Turret fields (Turret.java:66); shootWarmup is a
TurretBuild field (Turret.java:286); lastLength is the
ContinuousTurretBuild field (ContinuousTurret.java:40)
assigned here and returned as last_length.
(7) isShooting / hasAmmo() are state / callee already owned
(N2343 isShooting, N2313 hasAmmo) -- explicit bool params,
not re-ported.
(8) NO driver line yet: the pure function returns the frame
the driver writes; the driver tick that calls it per tick
is a later slice. (9) The input dicts are never mutated:
the result is a fresh Dictionary built from read values.
Twelve new result symbols: bullet_x, bullet_y, bullet_angle,
bullet_aim_x, bullet_aim_y, bullet_damage, bullet_time,
bullet_keep_alive, last_length, shoot_length, cur_length,
result_length.
Slice source: ContinuousTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_update_tile import DEFERRED as N2362_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretUpdateBulletProof'
UPDATE_BULLET_OWNER = 'PortGame.source_continuous_turret_build_update_bullet_state'
TESTS = ['test_c07_continuous_turret_update_bullet_registration', 'test_all_c07_continuous_turret_update_bullet_input_evidence_is_exact', 'test_continuous_turret_update_bullet_state', 'test_reference_graph_and_actual_c07_continuous_turret_update_bullet']
# The 1 slice source the N2366 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    'public class ContinuousTurret extends Turret{',
    'public class ContinuousTurretBuild extends TurretBuild{',
    'protected void updateBullet(BulletEntry entry){',
    'bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),',
    'bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),',
    'angle = rotation + entry.rotation;',
    'entry.bullet.rotation(angle);',
    'entry.bullet.set(bulletX, bulletY);',
    '//target length of laser',
    'float shootLength = Math.min(dst(targetPos), range);',
    '//current length of laser',
    'float curLength = dst(entry.bullet.aimX, entry.bullet.aimY);',
    '//resulting length of the bullet (smoothed)',
    'float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);',
    '//actual aim end point based on length',
    'Tmp.v1.trns(rotation, lastLength = resultLength).add(x, y);',
    'entry.bullet.aimX = Tmp.v1.x;',
    'entry.bullet.aimY = Tmp.v1.y;',
    'if(scaleDamageEfficiency){',
    'entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();',
    'if(isShooting && hasAmmo()){',
    'entry.bullet.time = entry.bullet.lifetime * entry.bullet.type.optimalLifeFract * Math.min(shootWarmup, efficiency);',
    'entry.bullet.keepAlive = true;',
]

# DEFERRED is carried from the N2362 register script via import --
# never retyped. All N2362 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2362's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2366's Windows proof debt.
DEFERRED = list(N2362_DEFERRED) + [
    'ContinuousTurret updateBullet Windows Godot proof -- debt in GOAL.md section 5, same as N2362: the N2366 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_bullet_inputs = {
        'entry': a('Dictionary', 'protected void updateBullet(BulletEntry entry){', 'The BulletEntry (Turret.java:864-875, {bullet, x, y, rotation, life}): the entry updateTile hands over -- NOT re-ported here (BulletEntry/Bullet are not ported); it arrives as an explicit param (the N2330 param precedent) as a Dictionary {x, y, rotation, bullet}, with bullet {aim_x, aim_y, damage, time, lifetime, type_damage, type_optimal_life_fract, damage_multiplier}. The input dicts are never mutated: the result is a fresh Dictionary.'),
        'x': a('float', 'bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),', 'The building x (ContinuousTurret.java:104): the origin the rotated muzzle offset and the aim end point are added to -- taken as an explicit param.'),
        'y': a('float', 'bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),', 'The building y (ContinuousTurret.java:105): the origin the rotated muzzle offset and the aim end point are added to -- taken as an explicit param.'),
        'rotation': a('float', 'bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),', 'The turret rotation in degrees (ContinuousTurret.java:104): the offset rotates by rotation - 90 and the aim end point extends along rotation -- taken as an explicit param.'),
        'shoot_x': a('float', 'bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),', 'The Turret shootX field (Turret.java:66, default 0f): the muzzle offset x before rotation -- taken as an explicit param.'),
        'shoot_y': a('float', 'bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),', 'The Turret shootY field (Turret.java:66, default size * tilesize / 2f): the muzzle offset y before rotation -- taken as an explicit param.'),
        'target_pos_x': a('float', 'float shootLength = Math.min(dst(targetPos), range);', 'The targetPos x (Turret.java:290, `public Vec2 targetPos = new Vec2();`): shootLength is the distance from the building to targetPos, capped by range -- taken as an explicit param.'),
        'target_pos_y': a('float', 'float shootLength = Math.min(dst(targetPos), range);', 'The targetPos y (Turret.java:290): shootLength is the distance from the building to targetPos, capped by range -- taken as an explicit param.'),
        'range_value': a('float', 'float shootLength = Math.min(dst(targetPos), range);', 'The block range (ContinuousTurret.java:112, `Math.min(dst(targetPos), range)`): the cap on shootLength -- taken as an explicit param.'),
        'aim_change_speed': a('float', 'float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);', 'The ContinuousTurret aimChangeSpeed field (ContinuousTurret.java:17, default Float.POSITIVE_INFINITY): how fast resultLength approaches shootLength per second -- taken as an explicit param.'),
        'scale_damage_efficiency': a('bool', 'if(scaleDamageEfficiency){', 'The ContinuousTurret scaleDamageEfficiency field (ContinuousTurret.java:18, default false): when true the bullet damage is rescaled by efficiency -- taken as an explicit param.'),
        'efficiency': a('float', 'entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();', 'The block efficiency (ContinuousTurret.java:122, `Math.min(efficiency, 1f)`): caps the rescaled damage and the keep-alive lifetime -- taken as an explicit param.'),
        'time_scale': a('float', 'entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();', 'The global Time.timeScale (ContinuousTurret.java:122): multiplies the rescaled damage -- taken as an explicit param (the N2330 param precedent).'),
        'shoot_warmup': a('float', 'entry.bullet.time = entry.bullet.lifetime * entry.bullet.type.optimalLifeFract * Math.min(shootWarmup, efficiency);', 'The TurretBuild shootWarmup field (Turret.java:286): caps the keep-alive lifetime together with efficiency -- taken as an explicit param.'),
        'is_shooting': a('bool', 'if(isShooting && hasAmmo()){', 'The isShooting state (ContinuousTurret.java:126): already owned (N2343) -- arrives as an explicit bool param, not re-ported.'),
        'has_ammo': a('bool', 'if(isShooting && hasAmmo()){', 'The hasAmmo() callee (ContinuousTurret.java:126): already owned (N2313) -- arrives as an explicit bool param, not re-ported.'),
        'source_delta': a('float', 'float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);', 'Time.delta (Mathf.java:420-422, approachDelta is approach(from, to, Time.delta * speed)): the frame delta the smoothed length advances by -- taken as an explicit param (the N2330 param precedent).'),
    }
    update_bullet_outputs = {
        'bullet_x': a('float', 'entry.bullet.set(bulletX, bulletY);', 'The bullet x after the tick (ContinuousTurret.java:109, `entry.bullet.set(bulletX, bulletY);`): the building x plus the (shootX + entry.x, shootY + entry.y) offset rotated by rotation - 90.'),
        'bullet_y': a('float', 'entry.bullet.set(bulletX, bulletY);', 'The bullet y after the tick (ContinuousTurret.java:109): the building y plus the rotated offset y.'),
        'bullet_angle': a('float', 'entry.bullet.rotation(angle);', 'The bullet rotation after the tick (ContinuousTurret.java:108, `entry.bullet.rotation(angle);`): rotation + entry.rotation.'),
        'bullet_aim_x': a('float', 'entry.bullet.aimX = Tmp.v1.x;', 'The bullet aimX after the tick (ContinuousTurret.java:119, `entry.bullet.aimX = Tmp.v1.x;`): x plus cos(rotation) * resultLength.'),
        'bullet_aim_y': a('float', 'entry.bullet.aimY = Tmp.v1.y;', 'The bullet aimY after the tick (ContinuousTurret.java:120, `entry.bullet.aimY = Tmp.v1.y;`): y plus sin(rotation) * resultLength.'),
        'bullet_damage': a('float', 'entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();', 'The bullet damage after the tick (ContinuousTurret.java:122): type.damage * min(efficiency, 1f) * timeScale * damageMultiplier() when scaleDamageEfficiency, otherwise the input damage unchanged.'),
        'bullet_time': a('float', 'entry.bullet.time = entry.bullet.lifetime * entry.bullet.type.optimalLifeFract * Math.min(shootWarmup, efficiency);', 'The bullet time after the tick (ContinuousTurret.java:127): lifetime * type.optimalLifeFract * min(shootWarmup, efficiency) when isShooting and hasAmmo, otherwise the input time unchanged.'),
        'bullet_keep_alive': a('bool', 'entry.bullet.keepAlive = true;', 'Whether the bullet is kept alive this tick (ContinuousTurret.java:128, `entry.bullet.keepAlive = true;`): true exactly when isShooting and hasAmmo.'),
        'last_length': a('float', 'Tmp.v1.trns(rotation, lastLength = resultLength).add(x, y);', 'The lastLength field after the tick (ContinuousTurret.java:40, `lastLength = resultLength` inside the trns call at :117): the smoothed laser length.'),
        'shoot_length': a('float', 'float shootLength = Math.min(dst(targetPos), range);', 'The target laser length (ContinuousTurret.java:112): min(distance from the building to targetPos, range).'),
        'cur_length': a('float', 'float curLength = dst(entry.bullet.aimX, entry.bullet.aimY);', 'The current laser length (ContinuousTurret.java:114): distance from the building to the bullet aim point before smoothing.'),
        'result_length': a('float', 'float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);', 'The resulting laser length (ContinuousTurret.java:116): curLength moved toward shootLength by source_delta * aimChangeSpeed.'),
    }
    return (update_bullet_inputs, update_bullet_outputs)


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
    (update_bullet_inputs, update_bullet_outputs) = definitions()

    entries = [
        ('N2366', UPDATE_BULLET_OWNER, 'source_continuous_turret_build_update_bullet_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.updateBullet()', update_bullet_inputs, update_bullet_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.updateBullet() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.updateBullet() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: bullet_x, bullet_y, bullet_angle,
    # bullet_aim_x, bullet_aim_y, bullet_damage, bullet_time,
    # bullet_keep_alive, last_length, shoot_length, cur_length,
    # result_length.
    by_slice['N2366'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2366', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.updateBullet()', godot_owner=UPDATE_BULLET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2366'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
