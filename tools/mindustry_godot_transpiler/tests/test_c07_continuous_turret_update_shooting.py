import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTINUOUS_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceContinuousTurretBuildPortBridge.gd'
CONTINUOUS_TURRET_UPDATE_SHOOTING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ContinuousTurretUpdateShootingProof.gd'


class C07ContinuousTurretUpdateShootingTests(unittest.TestCase):
    def test_c07_continuous_turret_update_shooting_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2367']['godot_owner'], 'PortGame.source_continuous_turret_build_update_shooting_state')
        # ContinuousTurretBuild.updateShooting()
        # (ContinuousTurret.java:138-146):
        # `protected void updateShooting(){`
        # `if(bullets.any()){`
        # `return;`
        # `}`
        # `if(canConsume() && !charging() && shootWarmup >= minWarmup){`
        # `shoot(peekAmmo());`
        # `}`
        # `}`
        # on `public class ContinuousTurretBuild extends TurretBuild{`
        # (ContinuousTurret.java:38) inside
        # `public class ContinuousTurret extends Turret{`. This
        # is the shoot-decision half of the ContinuousTurret
        # tick: when no bullet is flying and the consume /
        # charging / warmup guard holds, fire one shot of the
        # peeked ammo. Unlike LaserTurret.updateShooting
        # (N2364) the guard here is canConsume() (no
        # reloadCounter / efficiency leg) and shoot(peekAmmo())
        # is one line -- a different method on a different
        # class, no dedup. `shoot(peekAmmo());` is a 0-hit in
        # both ledgers; `if(bullets.any()){` shares text with
        # N2362 (updateTile, same class) and N2364 (different
        # class) -- registered under this java_method (the
        # N632-N639 vs N1078-N1085 precedent). Two new result
        # symbols: shot, ammo_type. canConsume() / charging() /
        # peekAmmo() / shoot() are callees -- explicit params,
        # not re-ported. peekAmmo() here is
        # ContinuousTurretBuild.peekAmmo (:70-72, body already
        # owned by N1172 PowerTurretBuild.peekAmmo).
        self.assertEqual(
            ledger['N2367']['source_symbols'],
            [
                'source_continuous_turret_build_update_shooting_state_result.shot',
                'source_continuous_turret_build_update_shooting_state_result.ammo_type',
            ],
        )
        for name in ledger['N2367']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2367']['runtime_proof'], '/root/C07ContinuousTurretUpdateShootingProof')
        self.assertEqual(
            ledger['N2367']['tests'],
            [
                'test_c07_continuous_turret_update_shooting_registration',
                'test_all_c07_continuous_turret_update_shooting_input_evidence_is_exact',
                'test_continuous_turret_update_shooting_state',
                'test_reference_graph_and_actual_c07_continuous_turret_update_shooting',
            ],
        )
        self.assertTrue(ledger['N2367']['deferred_exprs'])

    def test_all_c07_continuous_turret_update_shooting_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2367']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2367']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_continuous_turret_update_shooting_state(self):
        bridge = CONTINUOUS_TURRET_BRIDGE.read_text(encoding='utf-8')
        # ContinuousTurretBuild.updateShooting()
        # (ContinuousTurret.java:138-146) fires one shot of the
        # peeked ammo exactly when no bullet is flying and
        # canConsume() holds, the turret is not charging, and
        # shootWarmup has reached minWarmup. The guard has no
        # reloadCounter / efficiency leg (unlike N2364).
        self.assertIn('static func source_continuous_turret_build_update_shooting_state(has_bullets: bool, can_consume: bool, charging: bool, shoot_warmup: float, min_warmup: float, ammo_type: Variant) -> Dictionary:', bridge)
        self.assertIn('return {"shot": shot, "ammo_type": shot_ammo_type}', bridge)
        for expr in [
            'public class ContinuousTurret extends Turret{',
            'public class ContinuousTurretBuild extends TurretBuild{',
            'protected void updateShooting(){',
            'if(bullets.any()){',
            'if(canConsume() && !charging() && shootWarmup >= minWarmup){',
            'shoot(peekAmmo());',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof drives the pure function with synthetic
        # guard values (no live tick): shot when ready / no
        # shot while bullets fly / without consume / while
        # charging / below min warmup / at the exact warmup
        # boundary.
        proof = CONTINUOUS_TURRET_UPDATE_SHOOTING_PROOF.read_text(encoding='utf-8')
        for key in [
            'shot_when_ready',
            'no_shot_when_bullets',
            'no_shot_without_consume',
            'no_shot_when_charging',
            'no_shot_below_min_warmup',
            'shot_at_exact_min_warmup',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_continuous_turret_update_shooting(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ContinuousTurretUpdateShootingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONTINUOUS_TURRET_UPDATE_SHOOTING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shot_when_ready',
            'no_shot_when_bullets',
            'no_shot_without_consume',
            'no_shot_when_charging',
            'no_shot_below_min_warmup',
            'shot_at_exact_min_warmup',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
