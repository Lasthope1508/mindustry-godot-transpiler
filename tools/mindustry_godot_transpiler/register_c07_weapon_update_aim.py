"""Register the Weapon update() leg 2 aim geometry + rotate (N2541).

Weapon.update() leg 2 (Weapon.java:313-315, :350-371,
:373, bulletRotation :455-457):
`float` /
`mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),` /
`mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);` /
`if(rotate && (mount.rotate || mount.shoot) && can){` /
`float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),` /
`axisY = unit.y + Angles.trnsy(unit.rotation - 90,  x, y);` /
`mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;` /
`mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);` /
`if(rotationLimit < 360){` /
`float dst = Angles.angleDist(mount.rotation, baseRotation);` /
`if(dst > rotationLimit/2f){` /
`mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);` /
`}` /
`}` /
`}` /
`mount.rotation = baseRotation;` /
`mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);` /
`}` /
`float` /
`weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),` /
`bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),` /
`bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),` /
`shootAngle = bulletRotation(unit, mount, bulletX, bulletY);` /
`if(alwaysShooting) mount.shoot = true;` /
bulletRotation (Weapon.java:455-457):
`return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;`.
update() is a large tick method, so it is ported leg by
leg in source order; leg 2 is the pure aim geometry +
rotate leg. `mount.shoot` / `mount.rotate` /
`mount.aimX` / `mount.aimY` come from the autoTarget
block (Weapon.java:315-347) as FRAME INPUTS (the N2540
`can` precedent: that block is BLOCKED on the live
entity scan, so its outputs are inputs here, not
re-ported). `can` is the `unit.canShoot()` frame bool,
taken as an input (canShoot() itself is NOT re-ported
here). NO driver tick call site: update() has no driver
in the port yet, and no caller reads the new function
today.

GREEN decisions (pinned by this slice): (1) One pure
function on SourceWeaponsCoreState.gd,
source_weapon_update_aim_state(20 params), placed
immediately AFTER source_weapon_update_decay_state (the
N2540 function) and BEFORE set_rotation_state, plus a
one-line delegate of the same name on
SourceWeaponsState.gd (the setup_mounts_state facade
precedent). It returns the nine keys `mount_x` /
`mount_y` / `mount_rotation` / `mount_target_rotation` /
`weapon_rotation` / `bullet_x` / `bullet_y` /
`shoot_angle` / `mount_shoot` on every call (the N2526
precedent -- every return key is a symbol). (2) NO tick
call site -- the function is DORMANT live today: no
caller reads it, so live behavior does not change. (3)
Order traps kept: axisX/axisY are the IDENTICAL
formula to mountX/mountY (same value, recomputed); the
rotate block reads `mount.rotate` / `mount.shoot`
BEFORE alwaysShooting sets `mount.shoot = true`;
`mount.rotation` used in weaponRotation and
bulletRotation is the UPDATED rotation; the `!rotate`
branch sets `mount.targetRotation =
unit.angleTo(aimX, aimY)` with NO subtraction of
`unit.rotation`; rotationLimit default 361f skips the
clamp unless under 360, and `dst` is computed on the
moveToward-updated rotation; bulletRotation's
non-rotate branch is all three terms.
SSOT expected after GREEN: symbols +9, Done +1,
contracts +1, schemas +2 (input + result),
11757/1769/1702/3195 -> 11766/1770/1703/3197; type
shard slices +1, contracts +1; comp stays 572/475.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_weapon_update_decay import DEFERRED as N2540_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
WEAPON = 'core/src/mindustry/type/Weapon.java'
WEAPON_MOUNT = 'core/src/mindustry/entities/units/WeaponMount.java'
PROOF = '/root/C07WeaponUpdateAimProof'
UPDATE_AIM_OWNER = 'SourceWeaponsCoreState.source_weapon_update_aim_state'
TESTS = ['test_c07_weapon_update_aim_registration', 'test_all_c07_weapon_update_aim_input_evidence_is_exact', 'test_weapon_update_aim_state', 'test_reference_graph_and_actual_c07_weapon_update_aim']
# The slice sources the N2541 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/type/Weapon.java',
    'core/src/mindustry/entities/units/WeaponMount.java',
]
EXACT_EXPRS = [
    'mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),',
    'mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);',
    'if(rotate && (mount.rotate || mount.shoot) && can){',
    'float axisX = unit.x + Angles.trnsx(unit.rotation - 90,  x, y),',
    'mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;',
    'mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);',
    'if(rotationLimit < 360){',
    'float dst = Angles.angleDist(mount.rotation, baseRotation);',
    'if(dst > rotationLimit/2f){',
    'mount.rotation = Angles.moveToward(mount.rotation, baseRotation, dst - rotationLimit/2f);',
    'mount.rotation = baseRotation;',
    'mount.targetRotation = unit.angleTo(mount.aimX, mount.aimY);',
    'weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),',
    'bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),',
    'bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),',
    'shootAngle = bulletRotation(unit, mount, bulletX, bulletY);',
    'if(alwaysShooting) mount.shoot = true;',
    'return rotate ? unit.rotation + mount.rotation : Angles.angle(bulletX, bulletY, mount.aimX, mount.aimY) + (unit.rotation - unit.angleTo(mount.aimX, mount.aimY)) + baseRotation;',
]

# DEFERRED is carried from the N2540 register script via import --
# never retyped. No entry is dropped: the Weapon.update()
# leg 2 entry the N2540 pool recorded deferred stays
# deferred below (it is superseded by this slice's DONE
# entry, not deleted), and the DrawPart subsystem +
# Windows proof debt stay deferred below.
# New entries below record the update() leg 2 aim geometry
# + rotate as DONE by this slice, the Windows proof debt,
# and the remaining update() legs that still need later slices.
DEFERRED = N2540_DEFERRED + [
    'Weapon.update() leg 2 aim geometry + rotate (`mount_x` / `mount_y` / `mount_rotation` / `mount_target_rotation` / `weapon_rotation` / `bullet_x` / `bullet_y` / `shoot_angle` / `mount_shoot` frame keys) -- DONE by this slice (N2541): `source_weapon_update_aim_state` ports Weapon.java:313-315, :350-371, :373, bulletRotation :455-457 for the Weapon family. `mount.shoot` / `mount.rotate` / `mount.aimX` / `mount.aimY` are frame inputs from the autoTarget block (Weapon.java:315-347, BLOCKED on the live entity scan). Order traps kept: axisX/axisY identical to mountX/mountY; rotate block reads `mount.rotate` / `mount.shoot` BEFORE alwaysShooting sets `mount.shoot = true`; weaponRotation / bulletRotation use the UPDATED mount.rotation; `!rotate` branch targetRotation = angleTo with NO unit.rotation subtraction; rotationLimit 361f default skips the clamp unless under 360. NO driver tick call site: update() has no driver in the port yet, and no caller reads the function today. Dormant live today: no caller reads the function, so live behavior does not change.',
    'Weapon.update() leg 2 Windows Godot proof -- debt in GOAL.md section 5, same as N2283-N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2513/N2514/N2515/N2516/N2517/N2518/N2519/N2520/N2521/N2522/N2523/N2524/N2525/N2526/N2527/N2528/N2529/N2530/N2531/N2532/N2533/N2534/N2535/N2536/N2537/N2538/N2539/N2540: the N2541 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Weapon.update() remaining legs still DEFERRED (later slices): auto-target block (Weapon.java:315-347, BLOCKED -- findTarget :447 live Units.closestTarget scan, checkTarget :451 live Units.invalidateTarget, Predict.intercept not ported); continuous-laser leg (Weapon.java:376-411, bullet entity live -- BLOCKED as a driver leg; shootLength :391 uses range() N2539 + approachDelta, pure); heat decay (Weapon.java:407-415 else-branch, pure -- candidate N2542, cooldownTime = 20f Weapon.java:89); side-flip leg (Weapon.java:418-423, pure with `lastReload` :294 as a separate frame input -- leg 1 only returns the post-decay reload); activeSound (Weapon.java:425-427, audio -- skip); shoot gate + shoot() (Weapon.java:429-444, BLOCKED/live -- shoot() spawns a real bullet, :459+; velLen needs unit.isRemote/deltaLen live). flip() :544 needs ShootPattern.copy()/flip() (port status unchecked) -- defer. init() :562 trivial (alwaysContinuous -> continuous) -- micro-slice later. addStats() :175-187 UI stats, C11-ish -- defer.',
]


def definitions():
    def a(typ, expr, rule, source=WEAPON, **extra):
        return backed(typ, source, expr, rule, **extra)

    update_aim_inputs = {
        'unit_x': a('float', 'unit.x + Angles.trnsx(unit.rotation - 90, x, y)', 'The unit x position (`unit.x`, Weapon.java:314 -- the mount position base, `mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y)`).'),
        'unit_y': a('float', 'unit.y + Angles.trnsy(unit.rotation - 90, x, y)', 'The unit y position (`unit.y`, Weapon.java:315 -- the mount position base, `mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y)`).'),
        'unit_rotation': a('float', 'unit.rotation - 90', 'The unit rotation in degrees (`unit.rotation`, Weapon.java:314 -- the mount offset angle is `unit.rotation - 90`, and the weapon rotation base is `unit.rotation - 90`, Weapon.java:368).'),
        'weapon_x': a('float', 'public float x = 5f, y = 0f;', 'The weapon x offset (`public float x = 5f, y = 0f;`, Weapon.java:93 -- the mount offset pair passed to Angles.trnsx/trnsy).'),
        'weapon_y': a('float', 'public float x = 5f, y = 0f;', 'The weapon y offset (`public float x = 5f, y = 0f;`, Weapon.java:93 -- the mount offset pair passed to Angles.trnsx/trnsy).'),
        'weapon_shoot_x': a('float', 'public float shootX = 0f, shootY = 3f;', 'The weapon shoot x offset (`public float shootX = 0f, shootY = 3f;`, Weapon.java:91 -- the bullet offset pair passed to Angles.trnsx/trnsy at weaponRotation, Weapon.java:369).'),
        'weapon_shoot_y': a('float', 'public float shootX = 0f, shootY = 3f;', 'The weapon shoot y offset (`public float shootX = 0f, shootY = 3f;`, Weapon.java:91 -- the bullet offset pair passed to Angles.trnsx/trnsy at weaponRotation, Weapon.java:370).'),
        'mount_rotation': a('float', 'public float rotation;', 'The mount rotation (`public float rotation;`, WeaponMount.java:14 -- rotation relative to the unit; moved toward targetRotation by the rotate block, Weapon.java:355, and returned updated).', source=WEAPON_MOUNT),
        'mount_target_rotation': a('float', 'public float targetRotation;', 'The mount target rotation (`public float targetRotation;`, WeaponMount.java:20 -- destination rotation; set to the aim angle minus unit.rotation by the rotate block, Weapon.java:354, or to angleTo by the !rotate branch, Weapon.java:364).', source=WEAPON_MOUNT),
        'mount_aim_x': a('float', 'public float aimX, aimY;', 'The mount aim x (`public float aimX, aimY;`, WeaponMount.java:32 -- aiming position in world coordinates; a frame input from the autoTarget block, Weapon.java:315-347, BLOCKED on the live entity scan).', source=WEAPON_MOUNT),
        'mount_aim_y': a('float', 'public float aimX, aimY;', 'The mount aim y (`public float aimX, aimY;`, WeaponMount.java:32 -- aiming position in world coordinates; a frame input from the autoTarget block, Weapon.java:315-347, BLOCKED on the live entity scan).', source=WEAPON_MOUNT),
        'mount_shoot': a('bool', 'public boolean shoot = false;', 'Whether the mount shoots right now (`public boolean shoot = false;`, WeaponMount.java:34 -- read by the rotate guard BEFORE alwaysShooting sets it, Weapon.java:350 vs :373; a frame input from the autoTarget block).', source=WEAPON_MOUNT),
        'mount_rotate': a('bool', 'public boolean rotate = false;', 'Whether to rotate to face the target right now (`public boolean rotate = false;`, WeaponMount.java:38 -- the second leg of the rotate guard, Weapon.java:350; a frame input from the autoTarget block).', source=WEAPON_MOUNT),
        'can': a('bool', 'boolean can = unit.canShoot();', 'The unit canShoot() frame bool (`boolean can = unit.canShoot();`, Weapon.java:293 -- taken as a bool input; canShoot() itself is NOT re-ported here; the third leg of the rotate guard, Weapon.java:350).'),
        'rotate': a('bool', 'public boolean rotate = false;', 'Whether the weapon rotates (`public boolean rotate = false;`, Weapon.java:45 -- selects the rotate block vs the !rotate branch, Weapon.java:350/362, and the weaponRotation / bulletRotation legs, Weapon.java:368/456).'),
        'rotate_speed': a('float', 'public float rotateSpeed = 20f;', 'The weapon rotation speed (`public float rotateSpeed = 20f;`, Weapon.java:73 -- the moveToward speed is `rotateSpeed * Time.delta`, Weapon.java:355).'),
        'rotation_limit': a('float', 'public float rotationLimit = 361f;', 'The weapon rotation limit (`public float rotationLimit = 361f;`, Weapon.java:107 -- the clamp block runs only when `rotationLimit < 360`, Weapon.java:356; the 361f default skips it).'),
        'base_rotation': a('float', 'public float baseRotation = 0f;', 'The weapon base rotation (`public float baseRotation = 0f;`, Weapon.java:49 -- the !rotate branch rotation, Weapon.java:363, the clamp target, Weapon.java:359, and the non-rotate bulletRotation term, Weapon.java:456).'),
        'always_shooting': a('bool', 'public boolean alwaysShooting = false;', 'Whether the weapon always shoots (`public boolean alwaysShooting = false;`, Weapon.java:63 -- `if(alwaysShooting) mount.shoot = true;`, Weapon.java:373, AFTER the rotate block reads mount.shoot).'),
        'source_delta': a('float', 'rotateSpeed * Time.delta', 'The frame delta (`Time.delta`, Weapon.java:355 -- the rotate moveToward speed is `rotateSpeed * Time.delta`).'),
    }
    update_aim_outputs = {
        'mount_x': a('float', 'mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),', 'The mount x (`mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),`, Weapon.java:314 -- the weapon mount world x).'),
        'mount_y': a('float', 'mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);', 'The mount y (`mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y);`, Weapon.java:315 -- the weapon mount world y).'),
        'mount_rotation': a('float', 'mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);', 'The updated mount rotation (`mount.rotation = Angles.moveToward(mount.rotation, mount.targetRotation, rotateSpeed * Time.delta);`, Weapon.java:355 -- moved toward targetRotation, then clamped toward baseRotation when the limit applies, Weapon.java:359; the !rotate branch sets it to baseRotation, Weapon.java:363).'),
        'mount_target_rotation': a('float', 'mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;', 'The updated mount target rotation (`mount.targetRotation = Angles.angle(axisX, axisY, mount.aimX, mount.aimY) - unit.rotation;`, Weapon.java:354 -- the rotate branch; the !rotate branch sets it to `unit.angleTo(mount.aimX, mount.aimY)` with NO unit.rotation subtraction, Weapon.java:364).'),
        'weapon_rotation': a('float', 'weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),', 'The weapon rotation (`weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),`, Weapon.java:368 -- uses the UPDATED mount.rotation when rotate is true).'),
        'bullet_x': a('float', 'bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),', 'The bullet spawn x (`bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX, this.shootY),`, Weapon.java:369 -- mount x plus the shoot offset rotated by weaponRotation).'),
        'bullet_y': a('float', 'bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),', 'The bullet spawn y (`bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX, this.shootY),`, Weapon.java:370 -- mount y plus the shoot offset rotated by weaponRotation).'),
        'shoot_angle': a('float', 'shootAngle = bulletRotation(unit, mount, bulletX, bulletY);', 'The shoot angle (`shootAngle = bulletRotation(unit, mount, bulletX, bulletY);`, Weapon.java:371 -- `unit.rotation + mount.rotation` when rotate, else the three-term aim angle, Weapon.java:456).'),
        'mount_shoot': a('bool', 'if(alwaysShooting) mount.shoot = true;', 'The post-alwaysShooting mount shoot (`if(alwaysShooting) mount.shoot = true;`, Weapon.java:373 -- true when alwaysShooting is true, else the input mount.shoot; the rotate block read the input value BEFORE this line).'),
    }
    return update_aim_inputs, update_aim_outputs


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
    update_aim_inputs, update_aim_outputs = definitions()

    entries = [
        ('N2541', UPDATE_AIM_OWNER, 'source_weapon_update_aim_state', WEAPON, 'mindustry.type.Weapon', 'Weapon.update()', update_aim_inputs, update_aim_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 2 aim geometry + rotate from Weapon.java:313-315, :350-371, :373, bulletRotation :455-457.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Weapon update() leg 2 aim geometry + rotate from Weapon.java:313-315, :350-371, :373, bulletRotation :455-457.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: mount_x, mount_y,
    # mount_rotation, mount_target_rotation,
    # weapon_rotation, bullet_x, bullet_y, shoot_angle,
    # mount_shoot (source order of the update() leg 2
    # assignments).
    by_slice['N2541'] = [
        'source_weapon_update_aim_state_result.mount_x',
        'source_weapon_update_aim_state_result.mount_y',
        'source_weapon_update_aim_state_result.mount_rotation',
        'source_weapon_update_aim_state_result.mount_target_rotation',
        'source_weapon_update_aim_state_result.weapon_rotation',
        'source_weapon_update_aim_state_result.bullet_x',
        'source_weapon_update_aim_state_result.bullet_y',
        'source_weapon_update_aim_state_result.shoot_angle',
        'source_weapon_update_aim_state_result.mount_shoot',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2541', dict(status='done', java_source=WEAPON, java_class='mindustry.type.Weapon', java_method='Weapon.update()', godot_owner=UPDATE_AIM_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2541'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
