import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_UPDATE_SHOOTING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretUpdateShootingProof.gd'


class C07LaserTurretUpdateShootingTests(unittest.TestCase):
    def test_c07_laser_turret_update_shooting_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2364']['godot_owner'], 'PortGame.source_laser_turret_build_update_shooting_state')
        # LaserTurretBuild.updateShooting()
        # (LaserTurret.java:120-132):
        # `protected void updateShooting(){`
        # `if(bullets.any()){`
        # `return;`
        # `}`
        # `if(reloadCounter <= 0 && efficiency > 0 && !charging() && shootWarmup >= minWarmup){`
        # `BulletType type = peekAmmo();`
        # `shoot(type);`
        # `reloadCounter = reload;`
        # `}`
        # `}`
        # on `public class LaserTurretBuild extends PowerTurretBuild{`
        # (LaserTurret.java:44) inside
        # `public class LaserTurret extends PowerTurret{`.
        # The bullets seq is NOT ported: its emptiness arrives
        # as the explicit has_bullets param (the N2330 param
        # precedent). peekAmmo() (N1172, PowerTurretBuild --
        # body `return shootType;`) and shoot() and charging()
        # (Turret.java:715-717) are callees -- their values
        # arrive as explicit params, not re-ported here. The
        # pure function decides whether to shoot and returns
        # the new reloadCounter; the driver performs shoot(type).
        # NO driver line: a pure decision function, not a
        # per-tick write. Three new result symbols:
        # should_shoot, shoot_type, reload_counter.
        self.assertEqual(
            ledger['N2364']['source_symbols'],
            [
                'source_laser_turret_build_update_shooting_state_result.should_shoot',
                'source_laser_turret_build_update_shooting_state_result.shoot_type',
                'source_laser_turret_build_update_shooting_state_result.reload_counter',
            ],
        )
        for name in ledger['N2364']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2364']['runtime_proof'], '/root/C07LaserTurretUpdateShootingProof')
        self.assertEqual(
            ledger['N2364']['tests'],
            [
                'test_c07_laser_turret_update_shooting_registration',
                'test_all_c07_laser_turret_update_shooting_input_evidence_is_exact',
                'test_laser_turret_update_shooting_state',
                'test_reference_graph_and_actual_c07_laser_turret_update_shooting',
            ],
        )
        self.assertTrue(ledger['N2364']['deferred_exprs'])

    def test_all_c07_laser_turret_update_shooting_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2364']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2364']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_update_shooting_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurretBuild.updateShooting()
        # (LaserTurret.java:120-132) returns early while a
        # bullet is around, otherwise shoots the peekAmmo()
        # type and resets reloadCounter to reload when the
        # guard (reloadCounter <= 0, efficiency > 0, not
        # charging, shootWarmup >= minWarmup) holds. Callees
        # arrive as explicit params; the pure function only
        # decides. NO driver line.
        self.assertIn('static func source_laser_turret_build_update_shooting_state(has_bullets: bool, reload_counter: float, efficiency: float, charging: bool, shoot_warmup: float, min_warmup: float, reload: float, ammo_type: Variant) -> Dictionary:', bridge)
        self.assertIn('return {"should_shoot": should_shoot, "shoot_type": shoot_type, "reload_counter": new_reload_counter}', bridge)
        for expr in [
            'public class LaserTurret extends PowerTurret{',
            'public class LaserTurretBuild extends PowerTurretBuild{',
            '@Override',
            'protected void updateShooting(){',
            'if(bullets.any()){',
            'if(reloadCounter <= 0 && efficiency > 0 && !charging() && shootWarmup >= minWarmup){',
            'BulletType type = peekAmmo();',
            'shoot(type);',
            'reloadCounter = reload;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with
        # synthetic scalar inputs (no live tick): bullets
        # around blocks shooting / ready shoots with the
        # peekAmmo type and reset counter / each guard leg
        # blocks shooting on its own / idle returns a null
        # shoot type / each result carries only its three keys.
        proof = LASER_TURRET_UPDATE_SHOOTING_PROOF.read_text(encoding='utf-8')
        for key in [
            'update_shooting_bullets_present_no_shoot',
            'update_shooting_ready_shoots',
            'update_shooting_reload_counter_positive_no_shoot',
            'update_shooting_efficiency_zero_no_shoot',
            'update_shooting_charging_no_shoot',
            'update_shooting_warmup_low_no_shoot',
            'update_shooting_shoot_type_null_when_idle',
            'update_shooting_returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_update_shooting(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretUpdateShootingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_UPDATE_SHOOTING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'update_shooting_bullets_present_no_shoot',
            'update_shooting_ready_shoots',
            'update_shooting_reload_counter_positive_no_shoot',
            'update_shooting_efficiency_zero_no_shoot',
            'update_shooting_charging_no_shoot',
            'update_shooting_warmup_low_no_shoot',
            'update_shooting_shoot_type_null_when_idle',
            'update_shooting_returns_only_three_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
