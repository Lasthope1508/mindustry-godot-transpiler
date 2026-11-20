import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
TURRET_DRAW_SELECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07TurretDrawSelectProof.gd'


class C07TurretDrawSelectTests(unittest.TestCase):
    def test_c07_turret_draw_select_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2334']['godot_owner'], 'SourceTurretBuildState.source_turret_draw_select_state')
        # TurretBuild.drawSelect() (Turret.java:481-488) calls
        # super.drawSelect() then, when the def field
        # drawMinRange is true, draws one dash circle around
        # the building: `Drawf.dashCircle(x, y, minRange(),
        # team.color);` (Turret.java:485). The center is the
        # building world position, the radius is the LIVE
        # minRange() value (N2340), the color is the building
        # team's color. One pure function on the family file
        # (the N2220 RepairPointBuild.drawSelect() / N2333
        # Radar drawSelect precedent): the caller passes the
        # live minRange() result and the team color as
        # explicit params. No driver tick line lands here:
        # drawSelect is selection UI, not per-tick state (the
        # accessor precedent N2311/N2340). Four new result
        # symbols: draw_min_range_circle, center, radius,
        # color.
        self.assertEqual(
            ledger['N2334']['source_symbols'],
            [
                'source_turret_draw_select_state_result.draw_min_range_circle',
                'source_turret_draw_select_state_result.center',
                'source_turret_draw_select_state_result.radius',
                'source_turret_draw_select_state_result.color',
            ],
        )
        for name in ledger['N2334']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2334']['runtime_proof'], '/root/C07TurretDrawSelectProof')
        self.assertEqual(
            ledger['N2334']['tests'],
            [
                'test_c07_turret_draw_select_registration',
                'test_all_c07_turret_draw_select_input_evidence_is_exact',
                'test_turret_draw_select_state',
                'test_reference_graph_and_actual_c07_turret_draw_select',
            ],
        )
        self.assertTrue(ledger['N2334']['deferred_exprs'])

    def test_all_c07_turret_draw_select_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2334']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/Turret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2334']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_turret_draw_select_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # The pure drawSelect() row lives on the turret build
        # state next to the N2340 minRange rows:
        # TurretBuild.drawSelect() (Turret.java:481-488) calls
        # super.drawSelect() (BuildingComp.drawSelect(),
        # live as N573 PortGame.source_building_draw_select_state
        # -- NOT re-ported here) then, when drawMinRange is
        # true, draws one dash circle
        # (`Drawf.dashCircle(x, y, minRange(), team.color);`,
        # Turret.java:485). The radius is the live minRange()
        # value (Turret.java:334, `public float minRange(){`
        # with `return minRange + peekAmmo().minRangeChange;`,
        # Turret.java:335 -- N2340, NOT re-ported here). The
        # color is the team color, passed as a String (the
        # SourceBuildingDrawState.gd draw_team precedent).
        # This is a different method from N2329 peekAmmo()
        # (which minRange() reads) and from drawPlace()
        # (:252-253, which reads the minRange FIELD directly
        # -- already ported as N1162 turret_draw_place.min_range)
        # -- no overlap. One def (Turret, Turret.java:36,
        # `public class Turret extends ReloadTurret{`;
        # TurretBuild, Turret.java:277, `public class
        # TurretBuild extends ReloadTurretBuild implements
        # ControlBlock{`).
        self.assertIn('static func source_turret_draw_select_state(x: float, y: float, draw_min_range: bool, min_range: float, team_color: String) -> Dictionary:', turret)
        # The circle is drawn only when drawMinRange is true;
        # otherwise the radius reads 0.0 (no circle).
        self.assertIn('if draw_min_range:', turret)
        self.assertIn('"radius": min_range, "color": team_color}', turret)
        self.assertIn('"radius": 0.0, "color": team_color}', turret)
        for expr in [
            'public void drawSelect(){',
            'super.drawSelect();',
            'if(drawMinRange){',
            'Drawf.dashCircle(x, y, minRange(), team.color);',
            'public boolean drawMinRange;',
            'public float minRange = 0f;',
            'public float minRange(){',
            'return minRange + peekAmmo().minRangeChange;',
            'return minRange;',
            'public class Turret extends ReloadTurret{',
            'public class TurretBuild extends ReloadTurretBuild implements ControlBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure drawSelect function
        # (circle drawn / hidden, live radius, zero minRange,
        # artillery radius, center and team color). There are
        # no driver-tick keys: drawSelect() is selection UI.
        proof = TURRET_DRAW_SELECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_select_circle_drawn',
            'draw_select_circle_hidden',
            'draw_select_radius_live',
            'draw_select_radius_zero_min_range',
            'draw_select_center',
            'draw_select_color_team',
            'draw_select_radius_artillery',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_turret_draw_select(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07TurretDrawSelectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_TURRET_DRAW_SELECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_select_circle_drawn',
            'draw_select_circle_hidden',
            'draw_select_radius_live',
            'draw_select_radius_zero_min_range',
            'draw_select_center',
            'draw_select_color_team',
            'draw_select_radius_artillery',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
