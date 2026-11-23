"""Register the LaserTurret turnToTarget() + handleBullet() (N2369).

MERGED slice (N2346/N2336 precedent): ONE record, ONE
owner, covering BOTH java methods:
LaserTurretBuild.turnToTarget()
(LaserTurret.java:135-137, `protected void turnToTarget(float targetRot){` /
`rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta() * (bullets.any() ? firingMoveFract : 1f));`) and
LaserTurretBuild.handleBullet()
(LaserTurret.java:140-144, `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){` /
`if(bullet != null){` /
`bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));`)
are one pure function on the
SourceLaserTurretBuildPortBridge.gd (opened by N2360),
following the PortBridge precedent (N2355/N2360/N2364).
The rotation turn and the bullet entry are one driver
step (the tick turns then hands the bullet over), and
both read the same bullets-any() state -- hence one
record, one symbol/owner, with BOTH java_method names
in the ledger record (`LaserTurretBuild.turnToTarget(float);
LaserTurretBuild.handleBullet(Bullet, float, float, float)`).
Main thread confirms at merge.

RED decisions (resolved at RED): (1) The function lives
in the existing PortBridge file: there is no
SourceLaserTurretBuildState.gd to delegate to.
The SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2360 PortGame.source_laser_turret_build_should_consume_state,
N2364 PortGame.source_laser_turret_build_update_shooting_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed here, owner PortGame.
(2) Angles.moveToward is NOT re-ported: it already exists
as SourceMathState.source_angles_move_toward (wraparound,
snaps when closer than the step). (3) The bullets seq is
NOT ported: its emptiness arrives as the explicit
has_bullets param (the N2330 param precedent).
firingMoveFract (LaserTurret.java:16) and shootDuration
(LaserTurret.java:17) arrive as explicit params.
(4) handleBullet appends a BulletEntry (Turret.java:864-876,
fields bullet/x/y/rotation/life, positional from the
constructor call: offsetX -> x, offsetY -> y,
angleOffset -> rotation, shootDuration -> life) only for
a non-null bullet; the seq append itself is the
driver-side effect, so the pure function returns the
entry dict (or null) and the driver adds it.
(5) Distinguishing Laser from
ContinuousTurretBuild.turnToTarget/handleBullet (NOT
owned, later batch): Laser uses firingMoveFract while
bullets are around and shootDuration as the entry life;
Continuous uses duration 0f and initialises aim from
Tmp.v1 -- no dedup between them. (6) NO driver line:
pure functions the tick reads, not per-tick writes.
Two new result symbols: rotation, bullet_entry.
Slice source: LaserTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_laser_turret_update_shooting import DEFERRED as N2364_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
LASER_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java'
PROOF = '/root/C07LaserTurretTurnToTargetHandleBulletProof'
TURN_TO_TARGET_HANDLE_BULLET_OWNER = 'PortGame.source_laser_turret_build_turn_to_target_handle_bullet_state'
TESTS = ['test_c07_laser_turret_turn_to_target_handle_bullet_registration', 'test_all_c07_laser_turret_turn_to_target_handle_bullet_input_evidence_is_exact', 'test_laser_turret_turn_to_target_handle_bullet_state', 'test_reference_graph_and_actual_c07_laser_turret_turn_to_target_handle_bullet']
# The 1 slice source the N2369 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
]
EXACT_EXPRS = [
    'public class LaserTurret extends PowerTurret{',
    'public class LaserTurretBuild extends PowerTurretBuild{',
    '@Override',
    'protected void turnToTarget(float targetRot){',
    'rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta() * (bullets.any() ? firingMoveFract : 1f));',
    'protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){',
    'if(bullet != null){',
    'bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));',
]

# DEFERRED is carried from the N2364 register script via import --
# never retyped. All N2364 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2360/N2364's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2369's Windows proof debt.
DEFERRED = list(N2364_DEFERRED) + [
    'LaserTurret turnToTarget + handleBullet Windows Godot proof -- debt in GOAL.md section 5, same as N2360/N2364: the N2369 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=LASER_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    move_toward = 'rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta() * (bullets.any() ? firingMoveFract : 1f));'
    add_entry = 'bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));'
    turn_to_target_handle_bullet_inputs = {
        'rotation': a('float', move_toward, 'The current rotation, rotation (LaserTurret.java:136): the angle moveToward starts from.'),
        'target_rot': a('float', move_toward, 'The target rotation, targetRot (LaserTurret.java:135): the angle moveToward moves toward.'),
        'efficiency': a('float', move_toward, 'The build efficiency, efficiency (LaserTurret.java:136): scales the turn step; zero efficiency does not turn.'),
        'rotate_speed': a('float', move_toward, 'The rotate speed, rotateSpeed (LaserTurret.java:136): scales the turn step.'),
        'delta': a('float', move_toward, 'The frame delta, delta() (LaserTurret.java:136): scales the turn step.'),
        'has_bullets': a('bool', move_toward, 'Whether the bullets seq is non-empty, bullets.any() (LaserTurret.java:136): the seq itself is NOT ported -- its emptiness arrives as an explicit param (the N2330 param precedent); while a bullet is around the step is scaled by firingMoveFract.'),
        'firing_move_fract': a('float', move_toward, 'The firing move fraction, firingMoveFract (LaserTurret.java:16, `public float firingMoveFract = 0.25f;`): the turn-step scale while a bullet is around.'),
        'bullet': a('Variant', 'if(bullet != null){', 'The bullet to hand over, bullet (LaserTurret.java:140-141): only a non-null bullet yields an entry.'),
        'offset_x': a('float', add_entry, 'The bullet entry x offset, offsetX (LaserTurret.java:142): the BulletEntry x field (Turret.java:864-876).'),
        'offset_y': a('float', add_entry, 'The bullet entry y offset, offsetY (LaserTurret.java:142): the BulletEntry y field (Turret.java:864-876).'),
        'angle_offset': a('float', add_entry, 'The bullet entry angle offset, angleOffset (LaserTurret.java:142): the BulletEntry rotation field (Turret.java:864-876).'),
        'shoot_duration': a('float', add_entry, 'The bullet entry life, shootDuration (LaserTurret.java:17, `public float shootDuration = 100f;`): the BulletEntry life field (Turret.java:864-876).'),
    }
    turn_to_target_handle_bullet_outputs = {
        'rotation': a('float', move_toward, 'The new rotation (LaserTurret.java:136, `rotation = Angles.moveToward(...);`): the wraparound moveToward result, snapped to targetRot when closer than the step.'),
        'bullet_entry': a('Variant', add_entry, 'The BulletEntry dict (LaserTurret.java:142, `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));`): {"bullet", "x", "y", "rotation", "life"} for a non-null bullet, null otherwise -- the driver adds it to the bullets seq.'),
    }
    return (turn_to_target_handle_bullet_inputs, turn_to_target_handle_bullet_outputs)


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
    (turn_to_target_handle_bullet_inputs, turn_to_target_handle_bullet_outputs) = definitions()

    entries = [
        ('N2369', TURN_TO_TARGET_HANDLE_BULLET_OWNER, 'source_laser_turret_build_turn_to_target_handle_bullet_state', LASER_TURRET, 'mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', 'LaserTurretBuild.turnToTarget(float); LaserTurretBuild.handleBullet(Bullet, float, float, float)', turn_to_target_handle_bullet_inputs, turn_to_target_handle_bullet_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.turnToTarget()/handleBullet() state from LaserTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed LaserTurretBuild.turnToTarget()/handleBullet() state from LaserTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation, bullet_entry.
    by_slice['N2369'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2369', dict(status='done', java_source=LASER_TURRET, java_class='mindustry.world.blocks.defense.turrets.LaserTurret.LaserTurretBuild', java_method='LaserTurretBuild.turnToTarget(float); LaserTurretBuild.handleBullet(Bullet, float, float, float)', godot_owner=TURN_TO_TARGET_HANDLE_BULLET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2369'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
