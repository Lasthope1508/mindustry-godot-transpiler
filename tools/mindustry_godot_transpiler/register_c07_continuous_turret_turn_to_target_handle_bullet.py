"""Register the ContinuousTurret turnToTarget() + handleBullet() (N2370).

MERGED slice (N2346/N2336 precedent): ONE record, ONE
owner, covering BOTH java methods:
ContinuousTurretBuild.turnToTarget()
(ContinuousTurret.java:149-151, `protected void turnToTarget(float targetRot){` /
`rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta());`) and
ContinuousTurretBuild.handleBullet()
(ContinuousTurret.java:154-164, `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){` /
`if(bullet != null){` /
`bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, 0f));` /
`Tmp.v1.trns(rotation, shootY + lastLength).add(x, y);` /
`bullet.aimX = Tmp.v1.x;` / `bullet.aimY = Tmp.v1.y;`)
are one pure function on the existing
SourceContinuousTurretBuildPortBridge.gd (created by N2355,
updateTile by N2362, updateBullet by N2366, updateShooting
by N2367), following the PortBridge precedent (N2355/N2362/
N2366/N2367) and the merged turnToTarget+handleBullet
precedent (N2369 LaserTurret). The rotation turn and the
bullet entry are one driver step (the tick turns then hands
the bullet over), and both read the same rotation state --
hence one record, one symbol/owner, with BOTH java_method
names in the ledger record
(`ContinuousTurretBuild.turnToTarget(float);
ContinuousTurretBuild.handleBullet(Bullet, float, float, float)`).
Main thread confirms at merge.

RED decisions (resolved at RED): (1) The function lives
in the existing PortBridge file: there is no
SourceContinuousTurretBuildState.gd to delegate to. The
SSOT owner is PortGame (not the bridge filename):
PortBridge files are discovered by the catalog validator
as port_game.* (source_symbols._discover_godot_owner_functions
forces class_name "port_game" for *PortBridge.gd), the same
as every other PortBridge contract (e.g. N1181
PortGame.source_item_turret_build_get_ammo_fraction_state,
N2355 PortGame.source_continuous_turret_build_get_ammo_fraction_state,
N2367 PortGame.source_continuous_turret_build_update_shooting_state).
Registering the bridge filename as owner breaks
implementation_linkage validation (gate batch 9: 9 failures)
-- fixed at N2355, owner PortGame here.
(2) Angles.moveToward is NOT re-ported: it already exists
as SourceMathState.source_angles_move_toward (wraparound,
snaps when closer than the step), called here exactly as
N2369 calls it.
(3) delta() is the BuildingComp callee
(BuildingComp.java:1922-1924, `return Time.delta *
timeScale;`) -- its value arrives as the explicit delta
param, not re-ported here.
(4) shootY is the TurretBuild field (Turret.java:66,
default NEGATIVE_INFINITY, resolved to size * tilesize /
2f at :206) -- the resolved value arrives as the explicit
shoot_y param. lastLength is the ContinuousTurretBuild
field (ContinuousTurret.java:40, default size * 4f, written
by updateBullet N2366) -- its value arrives as the
explicit last_length param; read() is NOT ported here (a
later slice).
(5) The bullets seq is NOT ported: the seq append itself
is the driver-side effect, so the pure function returns
the entry dict (or null) and the driver adds it.
BulletEntry fields (Turret.java:864-876): bullet/x/y/
rotation/life, positional from the constructor call:
offsetX -> x, offsetY -> y, angleOffset -> rotation,
0f -> life.
(6) Distinguishing Continuous from LaserTurret
turnToTarget+handleBullet (N2369): Continuous has NO
firingMoveFract factor and the entry life is 0f (not
shootDuration), and the aim is initialised from Tmp.v1
(shootY + lastLength) -- no dedup between them.
(7) `bullet.aimX = Tmp.v1.x;` / `bullet.aimY = Tmp.v1.y;`
share text with N851 (Weapon.handleBullet, different
class) -- registered under this java_method (the
N632-N639 vs N1078-N1085 precedent); flagged for the
main thread, see register.
(8) The aim uses the NEW rotation: in the tick
turnToTarget runs before handleBullet, so Tmp.v1.trns
reads the already-turned rotation.
(9) For a null bullet Java does nothing at all: no entry
and no aim update. The pure function returns
bullet_aim_x/y as 0.0 then, and they are only meaningful
when bullet_entry is non-null -- the driver must not
apply them otherwise.
(10) NO driver line: pure functions the tick reads, not
per-tick writes.
Four new result symbols: rotation, bullet_entry,
bullet_aim_x, bullet_aim_y.
Slice source: ContinuousTurret.java only.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_continuous_turret_update_shooting import DEFERRED as N2367_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
CONTINUOUS_TURRET = 'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java'
PROOF = '/root/C07ContinuousTurretTurnToTargetHandleBulletProof'
TURN_TO_TARGET_HANDLE_BULLET_OWNER = 'PortGame.source_continuous_turret_build_turn_to_target_handle_bullet_state'
TESTS = ['test_c07_continuous_turret_turn_to_target_handle_bullet_registration', 'test_all_c07_continuous_turret_turn_to_target_handle_bullet_input_evidence_is_exact', 'test_continuous_turret_turn_to_target_handle_bullet_state', 'test_reference_graph_and_actual_c07_continuous_turret_turn_to_target_handle_bullet']
# The 1 slice source the N2370 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in this file.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
]
EXACT_EXPRS = [
    'public class ContinuousTurret extends Turret{',
    'public class ContinuousTurretBuild extends TurretBuild{',
    '@Override',
    'protected void turnToTarget(float targetRot){',
    'rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta());',
    'protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){',
    'if(bullet != null){',
    'bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, 0f));',
    'Tmp.v1.trns(rotation, shootY + lastLength).add(x, y);',
    'bullet.aimX = Tmp.v1.x;',
    'bullet.aimY = Tmp.v1.y;',
]

# DEFERRED is carried from the N2367 register script via import --
# never retyped. All N2367 entries are carried verbatim (the
# Turret chain, the B/C notes, and N2367's own Windows proof
# debt -- none of them is resolved by this slice). One entry
# is added: N2370's Windows proof debt.
DEFERRED = list(N2367_DEFERRED) + [
    'ContinuousTurret turnToTarget + handleBullet Windows Godot proof -- debt in GOAL.md section 5, same as N2367: the N2370 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def definitions():
    def a(typ, expr, rule, source=CONTINUOUS_TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    move_toward = 'rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta());'
    add_entry = 'bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, 0f));'
    trns_aim = 'Tmp.v1.trns(rotation, shootY + lastLength).add(x, y);'
    turn_to_target_handle_bullet_inputs = {
        'rotation': a('float', move_toward, 'The current rotation, rotation (ContinuousTurret.java:150): the angle moveToward starts from.'),
        'target_rot': a('float', move_toward, 'The target rotation, targetRot (ContinuousTurret.java:149): the angle moveToward moves toward.'),
        'efficiency': a('float', move_toward, 'The build efficiency, efficiency (ContinuousTurret.java:150): scales the turn step; zero efficiency does not turn.'),
        'rotate_speed': a('float', move_toward, 'The rotate speed, rotateSpeed (ContinuousTurret.java:150): scales the turn step.'),
        'delta': a('float', move_toward, 'The frame delta, delta() (ContinuousTurret.java:150, BuildingComp.java:1922-1924 `return Time.delta * timeScale;`): scales the turn step; its value arrives as an explicit param, not re-ported here.'),
        'x': a('float', trns_aim, 'The building x, x (ContinuousTurret.java:161): the aim point is offset from here.'),
        'y': a('float', trns_aim, 'The building y, y (ContinuousTurret.java:161): the aim point is offset from here.'),
        'shoot_y': a('float', trns_aim, 'The shoot Y offset, shootY (ContinuousTurret.java:161, Turret.java:66 default NEGATIVE_INFINITY, resolved at :206): the aim length base together with lastLength.'),
        'last_length': a('float', trns_aim, 'The last set aim length, lastLength (ContinuousTurret.java:161, :40 default size * 4f, written by updateBullet N2366): the aim length together with shootY; read() is NOT ported here.'),
        'bullet': a('Variant', 'if(bullet != null){', 'The bullet to hand over, bullet (ContinuousTurret.java:155-156): only a non-null bullet yields an entry.'),
        'offset_x': a('float', add_entry, 'The bullet entry x offset, offsetX (ContinuousTurret.java:157): the BulletEntry x field (Turret.java:864-876).'),
        'offset_y': a('float', add_entry, 'The bullet entry y offset, offsetY (ContinuousTurret.java:157): the BulletEntry y field (Turret.java:864-876).'),
        'angle_offset': a('float', add_entry, 'The bullet entry angle offset, angleOffset (ContinuousTurret.java:157): the BulletEntry rotation field (Turret.java:864-876).'),
    }
    turn_to_target_handle_bullet_outputs = {
        'rotation': a('float', move_toward, 'The new rotation (ContinuousTurret.java:150, `rotation = Angles.moveToward(...);`): the wraparound moveToward result, snapped to targetRot when closer than the step.'),
        'bullet_entry': a('Variant', add_entry, 'The BulletEntry dict (ContinuousTurret.java:157, `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, 0f));`): {"bullet", "x", "y", "rotation", "life"} with life 0f for a non-null bullet, null otherwise -- the driver adds it to the bullets seq.'),
        'bullet_aim_x': a('float', 'bullet.aimX = Tmp.v1.x;', 'The bullet aim x (ContinuousTurret.java:162, `bullet.aimX = Tmp.v1.x;`): Tmp.v1.trns(new rotation, shootY + lastLength).add(x, y) -- shares text with N851 (Weapon.handleBullet, different class), registered under this java_method per the N632-N639 precedent.'),
        'bullet_aim_y': a('float', 'bullet.aimY = Tmp.v1.y;', 'The bullet aim y (ContinuousTurret.java:163, `bullet.aimY = Tmp.v1.y;`): Tmp.v1.trns(new rotation, shootY + lastLength).add(x, y) -- shares text with N851 (Weapon.handleBullet, different class), registered under this java_method per the N632-N639 precedent.'),
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
        ('N2370', TURN_TO_TARGET_HANDLE_BULLET_OWNER, 'source_continuous_turret_build_turn_to_target_handle_bullet_state', CONTINUOUS_TURRET, 'mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', 'ContinuousTurretBuild.turnToTarget(float); ContinuousTurretBuild.handleBullet(Bullet, float, float, float)', turn_to_target_handle_bullet_inputs, turn_to_target_handle_bullet_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.turnToTarget()/handleBullet() state from ContinuousTurret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ContinuousTurretBuild.turnToTarget()/handleBullet() state from ContinuousTurret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: rotation, bullet_entry, bullet_aim_x, bullet_aim_y.
    by_slice['N2370'] = all_names
    source_symbols.upsert_source_slice(GODOT, 'N2370', dict(status='done', java_source=CONTINUOUS_TURRET, java_class='mindustry.world.blocks.defense.turrets.ContinuousTurret.ContinuousTurretBuild', java_method='ContinuousTurretBuild.turnToTarget(float); ContinuousTurretBuild.handleBullet(Bullet, float, float, float)', godot_owner=TURN_TO_TARGET_HANDLE_BULLET_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2370'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
