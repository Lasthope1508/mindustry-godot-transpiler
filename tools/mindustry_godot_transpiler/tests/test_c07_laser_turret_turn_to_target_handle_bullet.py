import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_TURN_TO_TARGET_HANDLE_BULLET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretTurnToTargetHandleBulletProof.gd'


class C07LaserTurretTurnToTargetHandleBulletTests(unittest.TestCase):
    def test_c07_laser_turret_turn_to_target_handle_bullet_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2369']['godot_owner'], 'PortGame.source_laser_turret_build_turn_to_target_handle_bullet_state')
        # MERGED slice (N2346/N2336 precedent): ONE record, ONE
        # owner, covering BOTH java methods:
        # LaserTurretBuild.turnToTarget()
        # (LaserTurret.java:135-137):
        # `protected void turnToTarget(float targetRot){`
        # `rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta() * (bullets.any() ? firingMoveFract : 1f));`
        # `}`
        # LaserTurretBuild.handleBullet()
        # (LaserTurret.java:140-144):
        # `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){`
        # `if(bullet != null){`
        # `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));`
        # `}`
        # `}`
        # on `public class LaserTurretBuild extends PowerTurretBuild{`
        # (LaserTurret.java:44) inside
        # `public class LaserTurret extends PowerTurret{`.
        # The rotation moves toward the target with the
        # wraparound Angles.moveToward (already ported as
        # SourceMathState.source_angles_move_toward, NOT
        # re-ported here); the step is scaled by
        # firingMoveFract (LaserTurret.java:16,
        # `public float firingMoveFract = 0.25f;`) only while
        # a bullet is around, full speed otherwise. The
        # bullets seq is NOT ported: its emptiness arrives
        # as the explicit has_bullets param (the N2330 param
        # precedent). handleBullet appends a BulletEntry
        # (Turret.java:864-876, fields bullet/x/y/rotation/
        # life) only for a non-null bullet; the seq append
        # itself is the driver-side effect, so the pure
        # function returns the entry dict (or null) and the
        # driver adds it. Distinguishing Laser from
        # ContinuousTurretBuild.turnToTarget/handleBullet
        # (NOT owned, later batch): Laser uses
        # firingMoveFract while bullets are around and
        # shootDuration as the entry life; Continuous uses
        # duration 0f and initialises aim from Tmp.v1 --
        # no dedup between them. NO driver line: two pure
        # functions the tick reads, not per-tick writes.
        # Two new result symbols: rotation, bullet_entry.
        self.assertEqual(
            ledger['N2369']['java_method'],
            'LaserTurretBuild.turnToTarget(float); LaserTurretBuild.handleBullet(Bullet, float, float, float)',
        )
        self.assertEqual(
            ledger['N2369']['source_symbols'],
            [
                'source_laser_turret_build_turn_to_target_handle_bullet_state_result.rotation',
                'source_laser_turret_build_turn_to_target_handle_bullet_state_result.bullet_entry',
            ],
        )
        for name in ledger['N2369']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2369']['runtime_proof'], '/root/C07LaserTurretTurnToTargetHandleBulletProof')
        self.assertEqual(
            ledger['N2369']['tests'],
            [
                'test_c07_laser_turret_turn_to_target_handle_bullet_registration',
                'test_all_c07_laser_turret_turn_to_target_handle_bullet_input_evidence_is_exact',
                'test_laser_turret_turn_to_target_handle_bullet_state',
                'test_reference_graph_and_actual_c07_laser_turret_turn_to_target_handle_bullet',
            ],
        )
        self.assertTrue(ledger['N2369']['deferred_exprs'])

    def test_all_c07_laser_turret_turn_to_target_handle_bullet_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2369']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2369']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_turn_to_target_handle_bullet_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurretBuild.turnToTarget() moves rotation
        # toward targetRot with the wraparound
        # Angles.moveToward, scaled by firingMoveFract
        # while a bullet is around; handleBullet() builds
        # a BulletEntry (bullet/x/y/rotation/life) only
        # for a non-null bullet. The bullets seq is NOT
        # ported -- its emptiness arrives as has_bullets;
        # the driver adds the returned entry. NO driver line.
        self.assertIn('static func source_laser_turret_build_turn_to_target_handle_bullet_state(rotation: float, target_rot: float, efficiency: float, rotate_speed: float, delta: float, has_bullets: bool, firing_move_fract: float, bullet: Variant, offset_x: float, offset_y: float, angle_offset: float, shoot_duration: float) -> Dictionary:', bridge)
        self.assertIn('return {"rotation": new_rotation, "bullet_entry": bullet_entry}', bridge)
        for expr in [
            'public class LaserTurret extends PowerTurret{',
            'public class LaserTurretBuild extends PowerTurretBuild{',
            '@Override',
            'protected void turnToTarget(float targetRot){',
            'rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta() * (bullets.any() ? firingMoveFract : 1f));',
            'protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){',
            'if(bullet != null){',
            'bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, shootDuration));',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): rotation
        # moves toward the target at full speed with no
        # bullets / at firingMoveFract speed with bullets /
        # zero efficiency does not move / close targets
        # snap / wraparound crosses 360 / a non-null bullet
        # yields a BulletEntry dict / a null bullet yields
        # no entry / each result carries only its two keys.
        proof = LASER_TURRET_TURN_TO_TARGET_HANDLE_BULLET_PROOF.read_text(encoding='utf-8')
        for key in [
            'turn_to_target_moves_toward_target',
            'turn_to_target_firing_move_fract_when_bullets',
            'turn_to_target_efficiency_zero_no_move',
            'turn_to_target_snaps_when_close',
            'turn_to_target_wraps_around',
            'handle_bullet_adds_entry_when_bullet',
            'handle_bullet_null_bullet_no_entry',
            'returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_turn_to_target_handle_bullet(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretTurnToTargetHandleBulletProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_TURN_TO_TARGET_HANDLE_BULLET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'turn_to_target_moves_toward_target',
            'turn_to_target_firing_move_fract_when_bullets',
            'turn_to_target_efficiency_zero_no_move',
            'turn_to_target_snaps_when_close',
            'turn_to_target_wraps_around',
            'handle_bullet_adds_entry_when_bullet',
            'handle_bullet_null_bullet_no_entry',
            'returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
