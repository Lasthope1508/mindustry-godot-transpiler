import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
SHOOT_BULLET_SHAKE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretShootBulletShakeProof.gd'


class C07TurretShootBulletShakeTests(unittest.TestCase):
    def test_c07_turret_shoot_bullet_shake_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2435']['godot_owner'], 'SourceTurretBuildState.source_turret_shoot_bullet_legs_state')
        # TurretBuild.bullet() (Turret.java:776-810): the ONE
        # expr N2428 deferred -- the shake body
        # `Effect.shake(shake, shake, this);` (:803, the
        # body of the `if(shake > 0){` guard :802). The same
        # text is already owned at N774 (UnitComp.destroy)
        # and N2194-N2200 (ShockwaveTower updateTile) and
        # N2294 (BurstDrillBuild.updateTile) in other
        # methods -- this is the twin-registration of the
        # TurretBuild.bullet() occurrence under N2428's
        # owner (the N2421 precedent; the GD comment
        # deferred it to this slice). The guard opener
        # :802 stays owned at N2428 -- only the body is
        # registered here.
        self.assertEqual(
            ledger['N2435']['java_method'],
            'TurretBuild.shoot()/TurretBuild.bullet()',
        )
        self.assertEqual(
            ledger['N2435']['exact_exprs'],
            [
                'Effect.shake(shake, shake, this);',
            ],
        )
        self.assertEqual(
            ledger['N2435']['source_symbols'],
            [
                'source_turret_shoot_bullet_legs_state_result.shake_effect',
            ],
        )
        for name in ledger['N2435']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_shoot_bullet_legs_state'))
        self.assertEqual(ledger['N2435']['runtime_proof'], '/root/C07TurretShootBulletShakeProof')
        self.assertEqual(
            ledger['N2435']['tests'],
            [
                'test_c07_turret_shoot_bullet_shake_registration',
                'test_all_c07_turret_shoot_bullet_shake_input_evidence_is_exact',
                'test_turret_shoot_bullet_shake_state',
                'test_reference_graph_and_actual_c07_turret_shoot_bullet_shake',
            ],
        )
        self.assertTrue(ledger['N2435']['deferred_exprs'])

    def test_all_c07_turret_shoot_bullet_shake_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2435']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceTurretBuildState.source_turret_shoot_bullet_legs_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2435']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_shoot_bullet_shake_state(self):
        state = TURRET_STATE.read_text(encoding='utf-8')
        # The GD function already exists (N2428) with the
        # same 15-param signature -- this slice adds no
        # param, only the `shake_effect` result key (the
        # N2430 same-owner precedent). The shake body is
        # quoted verbatim on its own comment line (the
        # N2378 precedent: never split an exact expr
        # across lines). `Effect.shake(intensity, duration,
        # Position)` (Effect.java:210) fires a camera shake
        # of the given intensity for the given duration at
        # the build -- recorded as data in the returned
        # Dictionary (the N2437 runWave precedent).
        self.assertIn('static func source_turret_shoot_bullet_legs_state(frame: Dictionary, delay: float, bullet: Callable, time_run: Callable, bullet_type: Variant, x_offset: float, y_offset: float, angle_offset: float, mover: Variant, x: float, y: float, rotation: float, ammo_eject_back: float, shake: float, ammo_use_effect: Callable) -> Dictionary:', state)
        self.assertIn('Effect.shake(shake, shake, this);', state)
        self.assertIn('shake_effect', state)
        # The proof's keys drive the one leg: the shake
        # effect fires with (intensity, duration) = (shake,
        # shake) at the build position when the guard
        # opens, and is absent when it does not.
        proof = SHOOT_BULLET_SHAKE_PROOF.read_text(encoding='utf-8')
        for key in [
            'shake_effect_applied',
            'shake_effect_absent',
            'shake_effect_uses_shake_both_args',
            'shake_applies_matches_effect',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_shoot_bullet_shake(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretShootBulletShakeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_SHOOT_BULLET_SHAKE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'shake_effect_applied',
            'shake_effect_absent',
            'shake_effect_uses_shake_both_args',
            'shake_applies_matches_effect',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
