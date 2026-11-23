import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
SHOOT_BULLET_LEGS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretShootBulletLegsProof.gd'


class C07TurretShootBulletLegsTests(unittest.TestCase):
    def test_c07_turret_shoot_bullet_legs_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2428']['godot_owner'], 'SourceTurretBuildState.source_turret_shoot_bullet_legs_state')
        # TurretBuild.shoot() (Turret.java:741-774) +
        # TurretBuild.bullet() (Turret.java:776-810): the 6
        # leftover legs remote N2269/N2252 did not register --
        # the barrel capture in the ShootPattern lambda, the
        # delayed barrel save/restore around the queued bullet
        # call, the ammo-eject effect call (the 4-line call
        # :796-799 counts as ONE expr, the N816 precedent),
        # and the shake guard opener. `barrelCounter =
        # barrel;` / `barrelCounter = prev;` are NOT the
        # N854 exprs `mount.barrelCounter = barrel;` /
        # `mount.barrelCounter = prev;` (Weapon.shoot(), a
        # different class/method/receiver) -- substring
        # false positives, re-probed before registering.
        self.assertEqual(
            ledger['N2428']['java_method'],
            'TurretBuild.shoot()/TurretBuild.bullet()',
        )
        self.assertEqual(
            ledger['N2428']['exact_exprs'],
            [
                'int barrel = barrelCounter;',
                'int prev = barrelCounter;',
                'barrelCounter = barrel;',
                'barrelCounter = prev;',
                'ammoUseEffect.at(',
                'if(shake > 0){',
            ],
        )
        self.assertEqual(
            ledger['N2428']['source_symbols'],
            [
                'source_turret_shoot_bullet_legs_state_result.barrel',
                'source_turret_shoot_bullet_legs_state_result.delayed',
                'source_turret_shoot_bullet_legs_state_result.ammo_use_effect_x',
                'source_turret_shoot_bullet_legs_state_result.ammo_use_effect_y',
                'source_turret_shoot_bullet_legs_state_result.ammo_use_effect_rotation',
                'source_turret_shoot_bullet_legs_state_result.shake_applies',
            ],
        )
        for name in ledger['N2428']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_shoot_bullet_legs_state'))
        self.assertEqual(ledger['N2428']['runtime_proof'], '/root/C07TurretShootBulletLegsProof')
        self.assertEqual(
            ledger['N2428']['tests'],
            [
                'test_c07_turret_shoot_bullet_legs_registration',
                'test_all_c07_turret_shoot_bullet_legs_input_evidence_is_exact',
                'test_turret_shoot_bullet_legs_state',
                'test_reference_graph_and_actual_c07_turret_shoot_bullet_legs',
            ],
        )
        self.assertTrue(ledger['N2428']['deferred_exprs'])

    def test_all_c07_turret_shoot_bullet_legs_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2428']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_shoot_bullet_legs_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2428']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_shoot_bullet_legs_state(self):
        state = TURRET_STATE.read_text(encoding='utf-8')
        # The 6 legs, each quoted verbatim on its own comment
        # line (the N2378 precedent: never split an exact
        # expr across lines): the barrel capture, the delayed
        # save/restore, the ammo-eject effect call, and the
        # shake guard opener. The ammo-eject arg lines
        # (:797-799) are implemented as the effect
        # position/rotation computation, not separate exprs.
        # The bullet() call is a call-site of the bullet
        # Callable (remote N2269); the Effect.shake body is
        # deferred (same text owned at N774/N2294 in other
        # methods).
        self.assertIn('static func source_turret_shoot_bullet_legs_state(frame: Dictionary, delay: float, bullet: Callable, time_run: Callable, bullet_type: Variant, x_offset: float, y_offset: float, angle_offset: float, mover: Variant, x: float, y: float, rotation: float, ammo_eject_back: float, shake: float, ammo_use_effect: Callable) -> Dictionary:', state)
        for expr in [
            'int barrel = barrelCounter;',
            'int prev = barrelCounter;',
            'barrelCounter = barrel;',
            'barrelCounter = prev;',
            'ammoUseEffect.at(',
            'if(shake > 0){',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, state)
        # The proof's keys drive one leg each: the barrel
        # capture, the delayed queue (bullet not fired yet),
        # the delayed restore (bullet fires with the captured
        # barrel, counter handed back), the immediate fire,
        # the ammo-eject position, the ammo-eject rotation
        # sign, and the shake guard both ways.
        proof = SHOOT_BULLET_LEGS_PROOF.read_text(encoding='utf-8')
        for key in [
            'barrel_captured',
            'delayed_bullet_not_called_yet',
            'delayed_action_restores_barrel',
            'immediate_bullet_called',
            'ammo_use_effect_position',
            'ammo_use_effect_rotation_sign',
            'shake_guard_true',
            'shake_guard_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_shoot_bullet_legs(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretShootBulletLegsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SHOOT_BULLET_LEGS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'barrel_captured',
            'delayed_bullet_not_called_yet',
            'delayed_action_restores_barrel',
            'immediate_bullet_called',
            'ammo_use_effect_position',
            'ammo_use_effect_rotation_sign',
            'shake_guard_true',
            'shake_guard_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
