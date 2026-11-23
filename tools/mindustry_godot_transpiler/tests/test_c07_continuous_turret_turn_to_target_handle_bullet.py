import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_TURN_TO_TARGET_HANDLE_BULLET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretTurnToTargetHandleBulletProof.gd'


class C07ContinuousTurretTurnToTargetHandleBulletTests(unittest.TestCase):
    def test_c07_continuous_turret_turn_to_target_handle_bullet_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2370']['godot_owner'], 'PortGame.source_continuous_turret_build_turn_to_target_handle_bullet_state')
        # ContinuousTurretBuild.turnToTarget()
        # (ContinuousTurret.java:149-151):
        # `protected void turnToTarget(float targetRot){`
        # `rotation = Angles.moveToward(rotation, targetRot, efficiency * rotateSpeed * delta());`
        # `}`
        # ContinuousTurretBuild.handleBullet()
        # (ContinuousTurret.java:154-164):
        # `protected void handleBullet(@Nullable Bullet bullet, float offsetX, float offsetY, float angleOffset){`
        # `if(bullet != null){`
        # `bullets.add(new BulletEntry(bullet, offsetX, offsetY, angleOffset, 0f));`
        # `//make sure the length updates to the last set value`
        # `Tmp.v1.trns(rotation, shootY + lastLength).add(x, y);`
        # `bullet.aimX = Tmp.v1.x;`
        # `bullet.aimY = Tmp.v1.y;`
        # `}`
        # `}`
        # on `public class ContinuousTurretBuild extends TurretBuild{`
        # (ContinuousTurret.java:38) inside
        # `public class ContinuousTurret extends Turret{`. The
        # rotation turn and the bullet entry are one driver
        # step (the tick turns then hands the bullet over),
        # hence one record, one symbol/owner, with BOTH
        # java_method names in the ledger record. Unlike
        # LaserTurret.turnToTarget+handleBullet (N2369) the
        # step here has NO firingMoveFract factor and the
        # entry life is 0f (not shootDuration), and the aim
        # is initialised from Tmp.v1 (shootY + lastLength)
        # -- no dedup between them. `bullet.aimX = Tmp.v1.x;`
        # / `bullet.aimY = Tmp.v1.y;` share text with N851
        # (Weapon.handleBullet, different class) -- registered
        # under this java_method (the N632-N639 vs N1078-N1085
        # precedent). Four new result symbols: rotation,
        # bullet_entry, bullet_aim_x, bullet_aim_y. delta()
        # (BuildingComp.java:1922-1924, Time.delta * timeScale)
        # / shootY (Turret.java:66, resolved at :206) /
        # lastLength (ContinuousTurret.java:40) arrive as
        # explicit params, not re-ported. The bullets seq is
        # NOT ported -- the driver adds the returned entry.
        self.assertEqual(
            ledger['N2370']['source_symbols'],
            [
                'source_continuous_turret_build_turn_to_target_handle_bullet_state_result.rotation',
                'source_continuous_turret_build_turn_to_target_handle_bullet_state_result.bullet_entry',
                'source_continuous_turret_build_turn_to_target_handle_bullet_state_result.bullet_aim_x',
                'source_continuous_turret_build_turn_to_target_handle_bullet_state_result.bullet_aim_y',
            ],
        )
        for name in ledger['N2370']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2370']['runtime_proof'], '/root/C07ContinuousTurretTurnToTargetHandleBulletProof')
        self.assertEqual(
            ledger['N2370']['tests'],
            [
                'test_c07_continuous_turret_turn_to_target_handle_bullet_registration',
                'test_all_c07_continuous_turret_turn_to_target_handle_bullet_input_evidence_is_exact',
                'test_continuous_turret_turn_to_target_handle_bullet_state',
                'test_reference_graph_and_actual_c07_continuous_turret_turn_to_target_handle_bullet',
            ],
        )
        self.assertTrue(ledger['N2370']['deferred_exprs'])

    def test_all_c07_continuous_turret_turn_to_target_handle_bullet_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2370']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2370']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_turn_to_target_handle_bullet_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.turnToTarget() moves rotation
        # toward targetRot with the wraparound
        # Angles.moveToward (already ported as
        # SourceMathState.source_angles_move_toward), the step
        # scaled by efficiency * rotateSpeed * delta() with NO
        # firingMoveFract factor; handleBullet() builds a
        # BulletEntry (bullet/x/y/rotation/life 0f) only for a
        # non-null bullet and initialises its aim from
        # Tmp.v1.trns(rotation, shootY + lastLength).add(x, y)
        # using the NEW rotation. The bullets seq is NOT
        # ported -- the driver adds the returned entry. NO
        # driver line.
        self.assertIn('static func source_continuous_turret_build_turn_to_target_handle_bullet_state(rotation: float, target_rot: float, efficiency: float, rotate_speed: float, delta: float, x: float, y: float, shoot_y: float, last_length: float, bullet: Variant, offset_x: float, offset_y: float, angle_offset: float) -> Dictionary:', bridge)
        self.assertIn('return {"rotation": new_rotation, "bullet_entry": bullet_entry, "bullet_aim_x": bullet_aim_x, "bullet_aim_y": bullet_aim_y}', bridge)
        for expr in [
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
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): rotation
        # moves toward the target at full speed / close
        # targets snap / wraparound crosses 360 / zero
        # efficiency does not move / a non-null bullet yields
        # a BulletEntry dict with life 0f / the aim comes from
        # shootY + lastLength at the NEW rotation / a null
        # bullet yields no entry / each result carries only
        # its four keys.
        proof = CONTINUOUS_TURRET_TURN_TO_TARGET_HANDLE_BULLET_PROOF.read_text(encoding='utf-8')
        for key in [
            'turn_to_target_moves_toward_target',
            'turn_to_target_snaps_when_close',
            'turn_to_target_wraps_around',
            'turn_to_target_efficiency_zero_no_move',
            'handle_bullet_adds_entry_when_bullet',
            'handle_bullet_entry_life_zero',
            'handle_bullet_aim_from_last_length',
            'handle_bullet_aim_uses_new_rotation',
            'handle_bullet_null_bullet_no_entry',
            'returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_turn_to_target_handle_bullet(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretTurnToTargetHandleBulletProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_TURN_TO_TARGET_HANDLE_BULLET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'turn_to_target_moves_toward_target',
            'turn_to_target_snaps_when_close',
            'turn_to_target_wraps_around',
            'turn_to_target_efficiency_zero_no_move',
            'handle_bullet_adds_entry_when_bullet',
            'handle_bullet_entry_life_zero',
            'handle_bullet_aim_from_last_length',
            'handle_bullet_aim_uses_new_rotation',
            'handle_bullet_null_bullet_no_entry',
            'returns_only_four_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
