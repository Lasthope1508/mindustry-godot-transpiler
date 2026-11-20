import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_IS_SHOOTING_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretIsShootingProof.gd'


class C07TurretIsShootingTests(unittest.TestCase):
    def test_c07_turret_is_shooting_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2343']['godot_owner'], 'SourceTurretBuildState.source_turret_is_shooting_state')
        # TurretBuild.isShooting() (Turret.java:429-432):
        # `public boolean isShooting(){`
        # `return isShooting;`
        # `}`
        # on `public class TurretBuild extends ReloadTurretBuild implements ControlBlock{`
        # (Turret.java:277). The field is the TurretBuild field
        # (`public boolean wasShooting, isShooting;`,
        # Turret.java:292) and arrives as the explicit bool
        # is_shooting (the shouldConsume :364 / sense :413 /
        # warmup :502 precedent -- the field name collides
        # with the method name, so the GD param is
        # is_shooting, never isShooting). The field is
        # written by updateTile :492 (not ported here -- this
        # slice only reads it). NO driver line: isShooting()
        # is a read accessor its callers read, not a per-tick
        # write (the N2249 precedent); no `.isShooting()` call
        # site exists in core/src -- the field is read
        # directly at shouldConsume :365, sense :413 and the
        # warmup leg :502. One new result symbol: is_shooting.
        self.assertEqual(
            ledger['N2343']['source_symbols'],
            [
                'source_turret_is_shooting_state_result.is_shooting',
            ],
        )
        for name in ledger['N2343']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2343']['runtime_proof'], '/root/C07TurretIsShootingProof')
        self.assertEqual(
            ledger['N2343']['tests'],
            [
                'test_c07_turret_is_shooting_registration',
                'test_all_c07_turret_is_shooting_input_evidence_is_exact',
                'test_turret_is_shooting_state',
                'test_reference_graph_and_actual_c07_turret_is_shooting',
            ],
        )
        self.assertTrue(ledger['N2343']['deferred_exprs'])

    def test_all_c07_turret_is_shooting_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2343']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2343']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_is_shooting_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # TurretBuild.isShooting() (Turret.java:429-432):
        # `public boolean isShooting(){`
        # `return isShooting;`
        # `}`
        # The field arrives as the explicit bool is_shooting
        # (the shouldConsume / sense / warmup precedent). The
        # result echoes the param unchanged: true stays true,
        # false stays false. NO driver line: isShooting() is a
        # pure accessor, not a per-tick write.
        self.assertIn('static func source_turret_is_shooting_state(frame: Dictionary, is_shooting: bool) -> Dictionary:', turret)
        self.assertIn('return {"is_shooting": is_shooting}', turret)
        for expr in [
            'public boolean isShooting(){',
            'return isShooting;',
            'public boolean wasShooting, isShooting;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure function with
        # synthetic frames (no live tick: isShooting is a pure
        # accessor over one input): true echoes true / false
        # echoes false / the explicit param wins over a
        # same-named frame key / the result carries only the
        # one is_shooting key.
        proof = TURRET_IS_SHOOTING_PROOF.read_text(encoding='utf-8')
        for key in [
            'is_shooting_true',
            'is_shooting_false',
            'is_shooting_param_wins_over_frame',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_is_shooting(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretIsShootingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_IS_SHOOTING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'is_shooting_true',
            'is_shooting_false',
            'is_shooting_param_wins_over_frame',
            'returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
