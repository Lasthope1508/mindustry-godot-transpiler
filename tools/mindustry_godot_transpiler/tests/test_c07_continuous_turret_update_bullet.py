import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_UPDATE_BULLET_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretUpdateBulletProof.gd'


class C07ContinuousTurretUpdateBulletTests(unittest.TestCase):
    def test_c07_continuous_turret_update_bullet_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2366']['godot_owner'], 'PortGame.source_continuous_turret_build_update_bullet_state')
        # ContinuousTurretBuild.updateBullet()
        # (ContinuousTurret.java:102-130):
        # `protected void updateBullet(BulletEntry entry){`
        # `bulletX = x + Angles.trnsx(rotation - 90, shootX + entry.x, shootY + entry.y),`
        # `bulletY = y + Angles.trnsy(rotation - 90, shootX + entry.x, shootY + entry.y),`
        # `angle = rotation + entry.rotation;`
        # `entry.bullet.rotation(angle);`
        # `entry.bullet.set(bulletX, bulletY);`
        # `//target length of laser`
        # `float shootLength = Math.min(dst(targetPos), range);`
        # `//current length of laser`
        # `float curLength = dst(entry.bullet.aimX, entry.bullet.aimY);`
        # `//resulting length of the bullet (smoothed)`
        # `float resultLength = Mathf.approachDelta(curLength, shootLength, aimChangeSpeed);`
        # `//actual aim end point based on length`
        # `Tmp.v1.trns(rotation, lastLength = resultLength).add(x, y);`
        # `entry.bullet.aimX = Tmp.v1.x;`
        # `entry.bullet.aimY = Tmp.v1.y;`
        # `if(scaleDamageEfficiency){`
        # `entry.bullet.damage = entry.bullet.type.damage * Math.min(efficiency, 1f) * timeScale * entry.bullet.damageMultiplier();`
        # `}`
        # `if(isShooting && hasAmmo()){`
        # `entry.bullet.time = entry.bullet.lifetime * entry.bullet.type.optimalLifeFract * Math.min(shootWarmup, efficiency);`
        # `entry.bullet.keepAlive = true;`
        # `}`
        # on `public class ContinuousTurretBuild extends TurretBuild{`
        # (ContinuousTurret.java:38) inside
        # `public class ContinuousTurret extends Turret{`. This
        # is the per-bullet half of the ContinuousTurret tick:
        # N2362 prunes the bullets seq and calls this for each
        # survivor; this slice moves one surviving bullet to its
        # rotated muzzle offset, re-aims its laser end point
        # toward the target with a smoothed length, and refreshes
        # its damage / lifetime while the turret is shooting.
        # The resultLength line shares text with N866 (Weapon.update
        # continuous laser aim, same text in a different method) --
        # registered under this java_method (the N632-N639 vs
        # N1078-N1085 precedent); the main thread decides whether
        # to keep it as an exact_expr or move it to bridge evidence
        # at merge. Twelve new result symbols: bullet_x, bullet_y,
        # bullet_angle, bullet_aim_x, bullet_aim_y, bullet_damage,
        # bullet_time, bullet_keep_alive, last_length, shoot_length,
        # cur_length, result_length. The entry / bullet dicts are
        # NOT mutated: the result is a fresh Dictionary.
        self.assertEqual(
            ledger['N2366']['source_symbols'],
            [
                'source_continuous_turret_build_update_bullet_state_result.bullet_x',
                'source_continuous_turret_build_update_bullet_state_result.bullet_y',
                'source_continuous_turret_build_update_bullet_state_result.bullet_angle',
                'source_continuous_turret_build_update_bullet_state_result.bullet_aim_x',
                'source_continuous_turret_build_update_bullet_state_result.bullet_aim_y',
                'source_continuous_turret_build_update_bullet_state_result.bullet_damage',
                'source_continuous_turret_build_update_bullet_state_result.bullet_time',
                'source_continuous_turret_build_update_bullet_state_result.bullet_keep_alive',
                'source_continuous_turret_build_update_bullet_state_result.last_length',
                'source_continuous_turret_build_update_bullet_state_result.shoot_length',
                'source_continuous_turret_build_update_bullet_state_result.cur_length',
                'source_continuous_turret_build_update_bullet_state_result.result_length',
            ],
        )
        for name in ledger['N2366']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2366']['runtime_proof'], '/root/C07ContinuousTurretUpdateBulletProof')
        self.assertEqual(
            ledger['N2366']['tests'],
            [
                'test_c07_continuous_turret_update_bullet_registration',
                'test_all_c07_continuous_turret_update_bullet_input_evidence_is_exact',
                'test_continuous_turret_update_bullet_state',
                'test_reference_graph_and_actual_c07_continuous_turret_update_bullet',
            ],
        )
        self.assertTrue(ledger['N2366']['deferred_exprs'])

    def test_all_c07_continuous_turret_update_bullet_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2366']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2366']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_update_bullet_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.updateBullet()
        # (ContinuousTurret.java:102-130) moves one surviving
        # bullet to its rotated muzzle offset (Angles.trnsx/trnsy
        # three-arg overloads rotate the offset vector by
        # rotation - 90), re-aims its laser end point toward
        # the target with a length smoothed by approachDelta,
        # and refreshes its damage / lifetime while shooting.
        # isShooting / hasAmmo() are state / callee already owned
        # (N2343 / N2313) -- explicit bool params, not re-ported.
        self.assertIn('static func source_continuous_turret_build_update_bullet_state(entry: Dictionary, x: float, y: float, rotation: float, shoot_x: float, shoot_y: float, target_pos_x: float, target_pos_y: float, range_value: float, aim_change_speed: float, scale_damage_efficiency: bool, efficiency: float, time_scale: float, shoot_warmup: float, is_shooting: bool, has_ammo: bool, source_delta: float) -> Dictionary:', bridge)
        self.assertIn('return {"bullet_x": bullet_x, "bullet_y": bullet_y, "bullet_angle": angle, "bullet_aim_x": aim_end.x, "bullet_aim_y": aim_end.y, "bullet_damage": bullet_damage, "bullet_time": bullet_time, "bullet_keep_alive": bullet_keep_alive, "last_length": result_length, "shoot_length": shoot_length, "cur_length": cur_length, "result_length": result_length}', bridge)
        for expr in [
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
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof drives the pure function with synthetic
        # bullet entries (no live tick): rotated muzzle offset /
        # smoothed laser length / aim end point / damage scaling /
        # keep-alive lifetime / range cap / input dicts unmutated.
        proof = CONTINUOUS_TURRET_UPDATE_BULLET_PROOF.read_text(encoding='utf-8')
        for key in [
            'bullet_position_rotated',
            'laser_length_smoothed',
            'aim_endpoint_set',
            'damage_scaled',
            'keep_alive_set',
            'no_keep_alive_without_ammo',
            'range_caps_length',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_update_bullet(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretUpdateBulletProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_UPDATE_BULLET_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bullet_position_rotated',
            'laser_length_smoothed',
            'aim_endpoint_set',
            'damage_scaled',
            'keep_alive_set',
            'no_keep_alive_without_ammo',
            'range_caps_length',
            'input_unmutated',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
