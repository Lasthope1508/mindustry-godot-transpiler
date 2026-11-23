import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretDrawProof.gd'


class C07TurretDrawTests(unittest.TestCase):
    def test_c07_turret_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2377']['godot_owner'], 'SourceTurretBuildState.source_turret_draw_state')
        # TurretBuild.draw() (Turret.java:476-478) is the whole
        # method in one line: `drawer.draw(this);`
        # (Turret.java:477). The drawer is the block-level
        # DrawBlock field (`public DrawBlock drawer = new
        # DrawTurret();`, Turret.java:155) -- the delegate that
        # draws the whole turret. One pure function on the
        # family file (the N2334 drawSelect precedent): the
        # caller passes the drawer as an explicit Callable
        # param and the build as an explicit Dictionary, and
        # the pure function calls the drawer with the build
        # and returns the delegation state (draw_delegated /
        # drawer_called). DrawTurret itself is NOT ported
        # here. No driver tick line lands here: draw() is a
        # render delegate, not per-tick state (the accessor
        # precedent N2311/N2340). Two new result symbols:
        # draw_delegated, drawer_called.
        self.assertEqual(
            ledger['N2377']['source_symbols'],
            [
                'source_turret_draw_state_result.draw_delegated',
                'source_turret_draw_state_result.drawer_called',
            ],
        )
        for name in ledger['N2377']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2377']['runtime_proof'], '/root/C07TurretDrawProof')
        self.assertEqual(
            ledger['N2377']['tests'],
            [
                'test_c07_turret_draw_registration',
                'test_all_c07_turret_draw_input_evidence_is_exact',
                'test_turret_draw_state',
                'test_reference_graph_and_actual_c07_turret_draw',
            ],
        )
        self.assertTrue(ledger['N2377']['deferred_exprs'])

    def test_all_c07_turret_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2377']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2377']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_draw_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # The pure draw() row lives on the turret build state
        # next to the N2334 drawSelect row: TurretBuild.draw()
        # (Turret.java:476-478) delegates the whole draw to
        # the block-level drawer (`drawer.draw(this);`,
        # Turret.java:477). The drawer is a DrawBlock
        # (`public DrawBlock drawer = new DrawTurret();`,
        # Turret.java:155) -- it arrives as an explicit
        # Callable param (the SourceBlockGeometry
        # world_tile_lookup precedent: guarded with
        # is_valid(), invoked with .call()), NOT re-ported
        # here; the build (`this`) arrives as an explicit
        # Dictionary param. DrawTurret itself is NOT ported.
        # This is a different method from N2334 drawSelect()
        # (selection UI, Turret.java:481-488) and from
        # drawPlace() (:252-253, already ported as N1162
        # turret_draw_place.min_range) -- no overlap. One def
        # (Turret, Turret.java:36, `public class Turret
        # extends ReloadTurret{`; TurretBuild,
        # Turret.java:277, `public class TurretBuild extends
        # ReloadTurretBuild implements ControlBlock{`).
        self.assertIn('static func source_turret_draw_state(drawer: Callable, build: Dictionary) -> Dictionary:', turret)
        # The drawer is invoked with the build when valid.
        self.assertIn('drawer.call(build)', turret)
        self.assertIn('"draw_delegated": true, "drawer_called": drawer_called}', turret)
        for expr in [
            'public void draw(){',
            'drawer.draw(this);',
            'public DrawBlock drawer = new DrawTurret();',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure draw function
        # (delegation, build passing, uninvoked drawer, only
        # two keys). There are no driver-tick keys: draw()
        # is a render delegate.
        proof = TURRET_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_delegates_to_drawer',
            'draw_passes_build_to_drawer',
            'draw_returns_delegated_flag',
            'draw_reports_uninvoked_drawer',
            'draw_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_delegates_to_drawer',
            'draw_passes_build_to_drawer',
            'draw_returns_delegated_flag',
            'draw_reports_uninvoked_drawer',
            'draw_returns_only_two_keys',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
