import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
TURRET_STATE = ROOT / 'godot-mindustry/src/game/SourceTurretBuildState.gd'
BASE_TURRET_DRAW_SELECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseTurretBuildDrawSelectProof.gd'


class C07BaseTurretBuildDrawSelectTests(unittest.TestCase):
    def test_c07_base_turret_build_draw_select_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2393']['godot_owner'], 'SourceTurretBuildState.source_base_turret_build_draw_select_state')
        # BaseTurretBuild.drawSelect() (BaseTurret.java:133-135)
        # is the whole method in one line:
        # `Drawf.dashCircle(x, y, range(), team.color);`
        # (BaseTurret.java:134). The center is the building
        # world position, the radius is the LIVE range()
        # value, the color is the building team's color. One
        # pure function on the family file (the N2334
        # TurretBuild.drawSelect() / N2377 TurretBuild.draw()
        # precedent): the caller passes the live range()
        # result and the team color as explicit params, and
        # Drawf.dashCircle arrives as an explicit Callable
        # param (the N2377 drawer precedent: guarded with
        # is_valid(), invoked with .call()) -- Drawf itself
        # is NOT ported here. No driver tick line lands here:
        # drawSelect is selection UI, not per-tick state (the
        # accessor precedent N2311/N2340). Four new result
        # symbols: dash_circle_called, center, radius, color.
        self.assertEqual(
            ledger['N2393']['source_symbols'],
            [
                'source_base_turret_build_draw_select_state_result.dash_circle_called',
                'source_base_turret_build_draw_select_state_result.center',
                'source_base_turret_build_draw_select_state_result.radius',
                'source_base_turret_build_draw_select_state_result.color',
            ],
        )
        for name in ledger['N2393']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2393']['runtime_proof'], '/root/C07BaseTurretBuildDrawSelectProof')
        self.assertEqual(
            ledger['N2393']['tests'],
            [
                'test_c07_base_turret_build_draw_select_registration',
                'test_all_c07_base_turret_build_draw_select_input_evidence_is_exact',
                'test_base_turret_build_draw_select_state',
                'test_reference_graph_and_actual_c07_base_turret_build_draw_select',
            ],
        )
        self.assertTrue(ledger['N2393']['deferred_exprs'])

    def test_all_c07_base_turret_build_draw_select_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2393']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceTurretBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/BaseTurret.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2393']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_turret_build_draw_select_state(self):
        turret = TURRET_STATE.read_text(encoding='utf-8')
        # The pure drawSelect() row lives on the turret build
        # state next to the N2334 drawSelect row:
        # BaseTurretBuild.drawSelect()
        # (BaseTurret.java:133-135) draws one dash circle
        # around the building (`Drawf.dashCircle(x, y,
        # range(), team.color);`, BaseTurret.java:134). The
        # center is the building world position, the radius
        # is the LIVE range() value (BaseTurret.java:124,
        # `public float range(){` with `return range;`,
        # BaseTurret.java:125 -- the def field `range`
        # (BaseTurret.java:22, `public float range = 80f;`)
        # is evidence only, the caller passes the live
        # range() result as the explicit range_value param,
        # the N2311/N2261 precedent). The color is the team
        # color, passed as a String (the
        # SourceBuildingDrawState draw_team precedent).
        # Drawf.dashCircle arrives as an explicit Callable
        # param (the N2377 drawer precedent: guarded with
        # is_valid(), invoked with .call()); Drawf itself is
        # NOT ported here. This is a different method from
        # N2334 TurretBuild.drawSelect() (selection UI,
        # Turret.java:481-488, the min-range circle) and
        # from drawPlace() (BaseTurret.java:84-92, which
        # draws the range circle at place time) -- no
        # overlap. One def (BaseTurret,
        # BaseTurret.java:21, `public class BaseTurret
        # extends Block{`; BaseTurretBuild,
        # BaseTurret.java:110, `public class
        # BaseTurretBuild extends Building implements Ranged,
        # RotBlock{`).
        self.assertIn('static func source_base_turret_build_draw_select_state(x: float, y: float, range_value: float, team_color: String, dash_circle: Callable) -> Dictionary:', turret)
        # The dash circle is invoked with the center, the
        # live range and the team color when valid.
        self.assertIn('dash_circle.call(x, y, range_value, team_color)', turret)
        self.assertIn('"dash_circle_called": dash_circle_called, "center": Vector2(x, y), "radius": range_value, "color": team_color}', turret)
        for expr in [
            'public void drawSelect(){',
            'Drawf.dashCircle(x, y, range(), team.color);',
            'public float range(){',
            'return range;',
            'public float range = 80f;',
            'public class BaseTurret extends Block{',
            'public class BaseTurretBuild extends Building implements Ranged, RotBlock{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, turret)
        # The proof's keys drive the pure drawSelect
        # function (circle called / not called, live radius,
        # zero range, center and team color). There are no
        # driver-tick keys: drawSelect() is selection UI.
        proof = BASE_TURRET_DRAW_SELECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_select_circle_called',
            'draw_select_circle_not_called',
            'draw_select_radius_live',
            'draw_select_radius_zero_range',
            'draw_select_center',
            'draw_select_color_team',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_base_turret_build_draw_select(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseTurretBuildDrawSelectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_TURRET_BUILD_DRAW_SELECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_select_circle_called',
            'draw_select_circle_not_called',
            'draw_select_radius_live',
            'draw_select_radius_zero_range',
            'draw_select_center',
            'draw_select_color_team',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
