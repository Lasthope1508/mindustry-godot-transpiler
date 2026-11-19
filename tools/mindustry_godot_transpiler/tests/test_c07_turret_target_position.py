import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_TARGET_POSITION_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretTargetPositionControlProof.gd'


class C07TurretTargetPositionTests(unittest.TestCase):
    def test_c07_turret_target_position_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2266']['godot_owner'], 'SourceTurretBuildState.source_turret_target_position_control_state')
        # TurretBuild.targetPosition(Posc pos) (Turret.java:453-471)
        # is the method the control() shootp overload calls
        # (Turret.java:398, `targetPosition(pos);`, N2264 deferred
        # it -- the shootp arm only reported
        # target_position_deferred because the call needs hasAmmo
        # / peekAmmo plus Predict.intercept):
        # `public void targetPosition(Posc pos){`
        # `if(!hasAmmo() || pos == null) return;`
        # `BulletType bullet = peekAmmo();`
        # `var offset = Tmp.v1.setZero();`
        # `if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){`
        # `offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);`
        # `}`
        # `if(predictTarget && bullet.speed >= 0.01f){`
        # `targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));`
        # `}else{`
        # `targetPos.set(pos);`
        # `}`
        # `if(targetPos.isZero()){`
        # `targetPos.set(pos);`
        # `}`
        # The intercept is the Position overload (Predict.java:
        # `public static Vec2 intercept(Position src, Position
        # dst, float offsetx, float offsety, float v){`): the
        # target's per-frame displacement (Hitboxc deltaX/deltaY)
        # is the velocity, the turret building is not a Hitboxc
        # so no shooter velocity is subtracted, and the float
        # overload divides the displacement by Time.delta
        # (`dstvx /= Time.delta;`) before solving the quadratic
        # for the smallest positive root, else the current
        # position. Duo pins: `accurateDelay = true`
        # (Turret.java:78) but `moveWhileCharging = true`
        # (:80), so the offset branch is OFF for duo -- the
        # offset stays zero even though firstShotDelay would
        # scale it; `predictTarget = true` (:105); duo copper
        # is `new BasicBulletType(2.5f, 9)` (Blocks.java:3260,
        # speed 2.5, damage 9) so the `bullet.speed >= 0.01f`
        # gate is on and the intercept runs; `shoot = new
        # ShootAlternate(3.5f);` (Blocks.java:3299) with
        # `public float firstShotDelay = 0;`
        # (ShootPattern.java:11), so even the accurateDelay
        # offset would be zero for duo. The N2122 live-aim
        # function (SourceTurretCombatState.
        # source_turret_target_position_state) already
        # implements the intercept branch for the aim path with
        # game/target dicts; this slice is the C07 control-path
        # pure function on the shared TurretBuild driver file,
        # taking frame-level scalars so the logic executor can
        # call it from the :398 shootp arm. There is NO driver
        # tick: control() is event-driven (the N2264 precedent,
        # N2248) -- the logic executor does not exist in the
        # driver yet, so the pure function is called directly by
        # the proof and waits for the executor slice to wire
        # the :398 arm; the frame's target_position_deferred
        # flag (N2264) is not resolved by any tick here because
        # the frame carries no Posc coords to resolve it from.
        # One new result symbol: target_pos.
        self.assertEqual(
            ledger['N2266']['source_symbols'],
            [
                'source_turret_target_position_control_state_result.target_pos',
            ],
        )
        for name in ledger['N2266']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                    'core/src/mindustry/entities/Predict.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/entities/pattern/ShootPattern.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_target_position_control_state_result.target_pos': 'SourceTurretBuildState.source_turret_target_position_control_state',
                }[name])
        self.assertEqual(ledger['N2266']['runtime_proof'], '/root/C07TurretTargetPositionControlProof')
        self.assertEqual(
            ledger['N2266']['tests'],
            [
                'test_c07_turret_target_position_registration',
                'test_all_c07_turret_target_position_input_evidence_is_exact',
                'test_turret_target_position_control_state',
                'test_reference_graph_and_actual_c07_turret_target_position',
            ],
        )
        self.assertTrue(ledger['N2266']['deferred_exprs'])

    def test_all_c07_turret_target_position_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2266']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8') if not symbol['java_source'].startswith('arc-core/') else (ROOT / 'arc-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_turret_target_position_control_state_result.target_pos': 'SourceTurretBuildState.source_turret_target_position_control_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
            'core/src/mindustry/entities/Predict.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/pattern/ShootPattern.java',
        }
        upstream = {}
        for source in slice_sources:
            root = ROOT / 'arc-upstream' if source.startswith('arc-core/') else ROOT / 'mindustry-upstream'
            upstream[source] = (root / source).read_text(encoding='utf-8')
        for expr in ledger['N2266']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_target_position_control_state(self):
        turret = TURRET_BUILD_STATE.read_text(encoding='utf-8')
        # TurretBuild.targetPosition(Posc pos)
        # (Turret.java:453-471) is the method the control()
        # shootp overload calls (Turret.java:398,
        # `targetPosition(pos);`, N2264 deferred it): no ammo
        # or a null pos returns early
        # (`if(!hasAmmo() || pos == null) return;`, :454), the
        # accurateDelay offset
        # (`if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){`
        # `offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);`,
        # :460-462) shifts the aim point only when the turret
        # cannot move while charging, the intercept
        # (`if(predictTarget && bullet.speed >= 0.01f){`
        # `targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));`,
        # :464-465) runs only when prediction is on and the
        # peeked bullet is fast enough, else the pos itself is
        # the aim point, and a zero result falls back to the pos
        # (`if(targetPos.isZero()){ targetPos.set(pos); }`,
        # :470-472). Duo pins: `accurateDelay = true`
        # (Turret.java:78) but `moveWhileCharging = true`
        # (:80), so the offset branch is OFF for duo;
        # `predictTarget = true` (:105); duo copper is
        # `new BasicBulletType(2.5f, 9)` (Blocks.java:3260,
        # speed 2.5) so the speed gate is on; `shoot = new
        # ShootAlternate(3.5f);` (Blocks.java:3299) with
        # `public float firstShotDelay = 0;`
        # (ShootPattern.java:11), so the offset would be zero
        # for duo either way. The intercept is the Position
        # overload (Predict.java: `public static Vec2
        # intercept(Position src, Position dst, float offsetx,
        # float offsety, float v){`): the target's per-frame
        # displacement is the velocity and the float overload
        # divides it by Time.delta (`dstvx /= Time.delta;`)
        # before solving the quadratic. The pure function takes
        # has_ammo, the pos dict (empty = null), the Hitboxc
        # flag + per-frame displacement, accurate_delay /
        # move_while_charging / first_shot_delay / time_delta,
        # predict_target, bullet_speed, the turret world pos
        # and the current target_pos, and returns the one key
        # `{"target_pos": ..}` -- the current targetPos
        # unchanged when the guard fires. There is NO driver
        # tick: control() is event-driven (the N2264 precedent,
        # N2248), the logic executor does not exist in the
        # driver yet.
        self.assertIn('static func source_turret_target_position_control_state(has_ammo: bool, pos: Dictionary, pos_is_hitboxc: bool, delta_x: float, delta_y: float, accurate_delay: bool, move_while_charging: bool, first_shot_delay: float, time_delta: float, predict_target: bool, bullet_speed: float, turret_x: float, turret_y: float, target_pos: Dictionary) -> Dictionary:', turret)
        self.assertIn('return {"target_pos": target_pos}', turret)
        self.assertIn('public void targetPosition(Posc pos){', turret)
        self.assertIn('if(!hasAmmo() || pos == null) return;', turret)
        self.assertIn('if(accurateDelay && !moveWhileCharging && pos instanceof Hitboxc h){', turret)
        self.assertIn('offset.set(h.deltaX(), h.deltaY()).scl(shoot.firstShotDelay / Time.delta);', turret)
        self.assertIn('if(predictTarget && bullet.speed >= 0.01f){', turret)
        self.assertIn('targetPos.set(Predict.intercept(this, pos, offset.x, offset.y, bullet.speed));', turret)
        self.assertIn('if(targetPos.isZero()){', turret)
        self.assertIn('targetPosition(pos);', turret)
        self.assertIn('public boolean accurateDelay = true;', turret)
        self.assertIn('public boolean moveWhileCharging = true;', turret)
        self.assertIn('public boolean predictTarget = true;', turret)
        self.assertIn('public float firstShotDelay = 0;', turret)
        self.assertIn('public Vec2 targetPos = new Vec2();', turret)
        self.assertIn('public static Vec2 intercept(Position src, Position dst, float offsetx, float offsety, float v){', turret)
        self.assertIn('dstvx /= Time.delta;', turret)
        self.assertIn('new BasicBulletType(2.5f, 9)', turret)
        self.assertIn('shoot = new ShootAlternate(3.5f);', turret)
        # The proof's keys drive targetPosition through the
        # pure function: no ammo keeps the current targetPos /
        # a null pos keeps it / no prediction uses the pos /
        # a slow bullet uses the pos / the intercept leads a
        # target moving away (500, 0 from (100, 0) at 2/tick
        # against copper speed 2.5) / a zero intercept falls
        # back to the pos / the accurateDelay offset shifts the
        # intercept to (800, 0) when the turret cannot move
        # while charging and firstShotDelay is 30 / the duo
        # offset is zero (moveWhileCharging true) so the
        # intercept stays (500, 0) / the duo live case aims
        # from the placed duo's world position with copper
        # speed 2.5.
        proof = TURRET_TARGET_POSITION_PROOF.read_text(encoding='utf-8')
        for key in [
            'tgt_pos_no_ammo_keeps',
            'tgt_pos_null_pos_keeps',
            'tgt_pos_no_predict_uses_pos',
            'tgt_pos_slow_bullet_uses_pos',
            'tgt_pos_intercept_leads',
            'tgt_pos_zero_intercept_falls_back',
            'tgt_pos_accurate_delay_offset',
            'tgt_pos_duo_offset_zero',
            'tgt_pos_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_target_position(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretTargetPositionControlProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_TARGET_POSITION_CONTROL_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'tgt_pos_no_ammo_keeps',
            'tgt_pos_null_pos_keeps',
            'tgt_pos_no_predict_uses_pos',
            'tgt_pos_slow_bullet_uses_pos',
            'tgt_pos_intercept_leads',
            'tgt_pos_zero_intercept_falls_back',
            'tgt_pos_accurate_delay_offset',
            'tgt_pos_duo_offset_zero',
            'tgt_pos_duo_live',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
