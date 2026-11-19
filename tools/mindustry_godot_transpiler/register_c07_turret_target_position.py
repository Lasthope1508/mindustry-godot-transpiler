"""Register the Turret targetPosition(pos) call (N2266).

TurretBuild.targetPosition(Posc pos) (Turret.java:453-471) is the
method the control() shootp overload calls (Turret.java:398,
`targetPosition(pos);`, N2264 deferred it: the shootp arm only
reported target_position_deferred because the call needs
hasAmmo / peekAmmo plus Predict.intercept):
`public void targetPosition(Posc pos){`
`if(!hasAmmo() || pos == null) return;`
`BulletType bullet = peekAmmo();`
`var offset = Tmp.v1.setZero();`
`if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){`
`offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);`
`}`
`if(predictTarget && bullet.speed >= 0.01f){`
`targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));`
`}else{`
`targetPos.set(pos);`
`}`
`if(targetPos.isZero()){`
`targetPos.set(pos);`
`}`
`}` (:453-471). The intercept is the Position overload
(Predict.java: `public static Vec2 intercept(Position src,
Position dst, float offsetx, float offsety, float v){`): the
target's per-frame displacement (Hitboxc deltaX/deltaY) is the
velocity, the turret building is not a Hitboxc so no shooter
velocity is subtracted, and the float overload divides the
displacement by Time.delta (`dstvx /= Time.delta;`) before
solving the quadratic for the smallest positive root, else
the current position. Duo pins: `accurateDelay = true`
(Turret.java:78) but `moveWhileCharging = true` (:80), so the
offset branch is OFF for duo -- the offset stays zero even
though firstShotDelay would scale it; `predictTarget = true`
(:105); duo copper is `new BasicBulletType(2.5f, 9)`
(Blocks.java:3260, speed 2.5, damage 9) so the
`bullet.speed >= 0.01f` gate is on and the intercept runs;
`shoot = new ShootAlternate(3.5f);` (Blocks.java:3299) with
`public float firstShotDelay = 0;` (ShootPattern.java:11), so
even the accurateDelay offset would be zero for duo. The
N2122 live-aim function
(SourceTurretCombatState.source_turret_target_position_state)
already implements the intercept branch for the aim path with
game/target dicts; this slice is the C07 control-path pure
function on the shared TurretBuild driver file, taking
frame-level scalars so the logic executor can call it from
the :398 shootp arm.

GREEN decisions (pinned by this slice): (1) One pure function
on SourceTurretBuildState.gd,
source_turret_target_position_control_state(has_ammo, pos,
pos_is_hitboxc, delta_x, delta_y, accurate_delay,
move_while_charging, first_shot_delay, time_delta,
predict_target, bullet_speed, turret_x, turret_y,
target_pos), returning `{"target_pos": ..}` -- no ammo or a
null pos returns the current targetPos unchanged, exactly
what Java does by returning early; otherwise the aim point
is the Predict.intercept result when predictTarget is set
and the peeked bullet is fast enough, else the pos itself;
a zero result falls back to the pos. The intercept reuses
SourcePredictState.source_predict_intercept_state (the N2122
float overload, preloaded like SourceTurretCombatState does).
(2) NO driver tick -- control() is event-driven (the N2264
precedent, N2248): the logic executor does not exist in the
driver yet, so the pure function is called directly by the
proof and waits for the executor slice to wire the :398 arm;
the frame's target_position_deferred flag (N2264) is not
resolved by any tick here because the frame carries no Posc
coords to resolve it from. (3) The live-entity scan behind
findTarget still waits (BLOCKED); this slice takes the scan
result (the pos + its per-frame displacement) as inputs.
SSOT expected after GREEN: symbols +1, Done +1, contracts
+1, schema +2, 11627/1715/1649/3089 -> 11628/1716/1650/3091;
defense shard slices 194 -> 195, contracts 193 -> 194.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_turret_efficiency_multiplier import DEFERRED as N2265_DEFERRED
from register_liquid_consumer_hydration import backed

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TURRET = 'core/src/mindustry/world/blocks/defense/turrets/Turret.java'
PREDICT = 'core/src/mindustry/entities/Predict.java'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
SHOOT_PATTERN = 'core/src/mindustry/entities/pattern/ShootPattern.java'
PROOF = '/root/C07TurretTargetPositionControlProof'
TARGET_POSITION_OWNER = 'SourceTurretBuildState.source_turret_target_position_control_state'
TESTS = ['test_c07_turret_target_position_registration', 'test_all_c07_turret_target_position_input_evidence_is_exact', 'test_turret_target_position_control_state', 'test_reference_graph_and_actual_c07_turret_target_position']
# The slice sources the N2266 test checks exact_exprs
# against -- every expr in EXACT_EXPRS below must appear verbatim
# in one of these files.
SLICE_SOURCES = [
    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
    'core/src/mindustry/entities/Predict.java',
    'core/src/mindustry/content/Blocks.java',
    'core/src/mindustry/entities/pattern/ShootPattern.java',
]
EXACT_EXPRS = ['public void targetPosition(Posc pos){', 'if(!hasAmmo() || pos == null) return;', 'if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){', 'offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);', 'if(predictTarget && bullet.speed >= 0.01f){', 'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', 'if(targetPos.isZero()){', 'targetPosition(pos);', 'public boolean accurateDelay = true;', 'public boolean moveWhileCharging = true;', 'public boolean predictTarget = true;', 'public float firstShotDelay = 0;', 'public static Vec2 intercept(float srcx, float srcy, float dstx, float dsty, float dstvx, float dstvy, float v){', 'dstvx /= Time.delta;', 'public static Vec2 intercept(Position src, Position dst, float offsetx, float offsety, float v){', 'return intercept(src.getX(), src.getY(), dst.getX() + offsetx, dst.getY() + offsety, ddx, ddy, v);', 'public boolean hasAmmo(){', 'public @Nullable BulletType peekAmmo(){', 'public Vec2 targetPos = new Vec2();', 'new BasicBulletType(2.5f, 9)', 'shoot = new ShootAlternate(3.5f);']

# DEFERRED is carried from the N2265 register script via import --
# never retyped. The targetPosition(pos) call is done by this
# slice (it was the next item named in the N2265 handoff); the
# calculateHeat live proximity scan, the maxHealth/health
# re-sync, the set(tile) world position, the cross-tick
# queuedBullets counter, effects/sound, findTarget / the other
# ItemTurret defs still wait.
DEFERRED = list(N2265_DEFERRED) + [
    'Turret targetPosition(pos) Windows Godot proof -- debt in GOAL.md section 5, same as N2240-N2265: the N2266 proof runs headless on Linux here and waits for a Windows Godot run.',
    'Turret control() targetPosition(pos) call (Turret.java:398, :453-471) -- DONE by this slice (N2266); it was the next item named in the N2265 handoff.',
    'Turret control() targetPosition(pos) for defs other than duo -- the pure function takes accurate_delay / move_while_charging / first_shot_delay / predict_target / bullet_speed as params; only duo is pinned live (copper speed 2.5, accurateDelay true, moveWhileCharging true, firstShotDelay 0).',
    'Turret control() shootp live wiring -- the logic executor still does not exist in the driver, so no driver tick resolves the N2264 target_position_deferred flag; the pure function waits for the executor slice to call it from the :398 arm.',
]


def definitions():
    def a(typ, expr, rule, source=TURRET, **extra):
        return backed(typ, source, expr, rule, **extra)

    target_position_inputs = {
        'has_ammo': a('bool', 'public boolean hasAmmo(){', 'Whether the turret has ammo to shoot with (Turret.java:698 -- ammo.size > 0 and the peeked entry holds at least ammoPerShot, or cheating(); the driver peek convention is the last duo_entries stack, N2253).'),
        'pos': a('Dictionary', 'public void targetPosition(Posc pos){', 'The Posc to aim at as {"x", "y"} world coords (Turret.java:453, the method arg; an empty dict means a null pos, which returns early at :454).'),
        'pos_is_hitboxc': a('bool', 'if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){', 'Whether the pos is a Hitboxc (Turret.java:460 -- only then does Java read deltaX/deltaY for the accurateDelay offset; a building pos has no per-frame displacement).'),
        'delta_x': a('float', 'ddx += h.deltaX();', 'The pos per-frame X displacement (Predict.java -- the Hitboxc deltaX() that the Position intercept overload adds to ddx; the float overload divides it by Time.delta).', source=PREDICT),
        'delta_y': a('float', 'ddy += h.deltaY();', 'The pos per-frame Y displacement (Predict.java -- the Hitboxc deltaY() that the Position intercept overload adds to ddy).', source=PREDICT),
        'accurate_delay': a('bool', 'public boolean accurateDelay = true;', 'Whether the turret targets accurately with respect to shoot.firstShotDelay (Turret.java:78, the class default true; duo never overrides it).'),
        'move_while_charging': a('bool', 'public boolean moveWhileCharging = true;', 'Whether the turret can move while charging (Turret.java:80, the class default true; duo never overrides it, so the offset branch is off for duo).'),
        'first_shot_delay': a('float', 'public float firstShotDelay = 0;', 'The shoot pattern first-shot delay in ticks (ShootPattern.java:11, the class default 0; duo ShootAlternate(3.5f) never sets it, Blocks.java:3299).', source=SHOOT_PATTERN),
        'time_delta': a('float', 'dstvx /= Time.delta;', 'The frame delta in ticks (Predict.java -- the float intercept overload divides the per-frame displacement by it; the proof passes 1.0 per live-loop tick).', source=PREDICT),
        'predict_target': a('bool', 'public boolean predictTarget = true;', 'Whether the block predicts unit movement (Turret.java:105, the class default true; duo never overrides it).'),
        'bullet_speed': a('float', 'if(predictTarget && bullet.speed >= 0.01f){', 'The peeked bullet speed (Turret.java:464 -- the intercept runs only when it is at least 0.01; duo copper is 2.5, new BasicBulletType(2.5f, 9), Blocks.java:3260).'),
        'turret_x': a('float', 'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', 'The turret world X (Turret.java:466 -- the `this` shooter origin passed to Predict.intercept; the proof reads it live from the placed duo segment).'),
        'turret_y': a('float', 'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', 'The turret world Y (Turret.java:466 -- the `this` shooter origin passed to Predict.intercept).'),
        'target_pos': a('Dictionary', 'public Vec2 targetPos = new Vec2();', 'The target position before this call (Turret.java:289, the field default is (0, 0) in world coords; returned unchanged when the guard fires).'),
    }
    target_position_outputs = {
        'target_pos': a('Dictionary', 'targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', 'The target position after this call (Turret.java:466-472 -- the intercept point when predictTarget is set and the bullet is fast enough, else the pos itself; a zero result falls back to the pos).'),
    }
    return target_position_inputs, target_position_outputs


def verify():
    """Check every EXACT_EXPRS line and every input/output
    java_expr appears verbatim in its upstream source, without
    touching any SSOT JSON. Exit 0 when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
        upstream[source] = (upstream_root / source).read_text(encoding='utf-8')
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
            upstream_root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            text = (upstream_root / source).read_text(encoding='utf-8')
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
    target_position_inputs, target_position_outputs = definitions()

    entries = [
        ('N2266', TARGET_POSITION_OWNER, 'source_turret_target_position_control_state', TURRET, 'mindustry.world.blocks.defense.turrets.Turret.TurretBuild', 'TurretBuild.targetPosition()', target_position_inputs, target_position_outputs, True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Turret targetPosition(pos) call from Turret.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Turret targetPosition(pos) call from Turret.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: target_pos.
    by_slice['N2266'] = [
        'source_turret_target_position_control_state_result.target_pos',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2266', dict(status='done', java_source=TURRET, java_class='mindustry.world.blocks.defense.turrets.Turret.TurretBuild', java_method='TurretBuild.targetPosition()', godot_owner=TARGET_POSITION_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2266'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
