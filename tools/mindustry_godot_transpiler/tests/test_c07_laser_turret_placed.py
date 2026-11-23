import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LASER_TURRET_BRIDGE = ROOT / 'godot-mindustry/src/game/SourceLaserTurretBuildPortBridge.gd'
LASER_TURRET_PLACED_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaserTurretPlacedProof.gd'


class C07LaserTurretPlacedTests(unittest.TestCase):
    def test_c07_laser_turret_placed_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2422']['godot_owner'], 'PortGame.source_laser_turret_build_placed_state')
        # LaserTurretBuild.placed()
        # (LaserTurret.java:59-64):
        # `@Override`
        # `public void placed(){`
        # `super.placed();`
        # `reloadCounter = reload;`
        # `}`
        # on `public class LaserTurretBuild extends PowerTurretBuild{`
        # (LaserTurret.java:44) inside
        # `public class LaserTurret extends PowerTurret{`.
        # Call-site fragment: `super.placed();` is the only free
        # expr -- `reloadCounter = reload;` is already owned at
        # N2364 (LaserTurretBuild.updateShooting) and is NOT
        # re-registered. The super call runs
        # BaseTurretBuild.placed() (whose own body is not ported
        # here -- only the call site); the GD function records
        # that placed() ran, returning a frame with
        # `placed: true` (the N2318 canPickup precedent: a bare
        # call-site returns a frame). NO driver line: placed()
        # runs once at build placement, not per-tick. Zero
        # params: placed() takes no state (the N1206
        # zero-param contract precedent -- result schema only,
        # no input schema).
        self.assertEqual(
            ledger['N2422']['source_symbols'],
            [
                'source_laser_turret_build_placed_state_result.placed',
            ],
        )
        for name in ledger['N2422']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2422']['runtime_proof'], '/root/C07LaserTurretPlacedProof')
        self.assertEqual(
            ledger['N2422']['tests'],
            [
                'test_c07_laser_turret_placed_registration',
                'test_all_c07_laser_turret_placed_input_evidence_is_exact',
                'test_laser_turret_placed_state',
                'test_reference_graph_and_actual_c07_laser_turret_placed',
            ],
        )
        self.assertTrue(ledger['N2422']['deferred_exprs'])

    def test_all_c07_laser_turret_placed_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2422']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'PortGame.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/LaserTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2422']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_laser_turret_placed_state(self):
        bridge = LASER_TURRET_BRIDGE.read_text(encoding='utf-8')
        # LaserTurretBuild.placed() (LaserTurret.java:59-64)
        # runs the super call once at build placement; the GD
        # function records that placed() ran and returns a
        # frame with `placed: true`. No inputs: placed() takes
        # no state.
        self.assertIn('static func source_laser_turret_build_placed_state() -> Dictionary:', bridge)
        self.assertIn('return {"placed": true}', bridge)
        for expr in [
            'public class LaserTurret extends PowerTurret{',
            'public class LaserTurretBuild extends PowerTurretBuild{',
            '@Override',
            'public void placed(){',
            'super.placed();',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, bridge)
        # The proof's keys drive the pure function with no
        # inputs (no live tick): placed() ran / the result
        # carries only its one key.
        proof = LASER_TURRET_PLACED_PROOF.read_text(encoding='utf-8')
        for key in [
            'placed_is_true',
            'placed_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_laser_turret_placed(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaserTurretPlacedProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LASER_TURRET_PLACED_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'placed_is_true',
            'placed_returns_only_one_key',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
