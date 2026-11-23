import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_DRAW_SELECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDrawSelectProof.gd'


class C07RadarDrawSelectTests(unittest.TestCase):
    def test_c07_radar_draw_select_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2333']['godot_owner'], 'SourceRadarBuildState.source_radar_draw_select_state')
        # RadarBuild.drawSelect() (Radar.java:80-82) draws one
        # dash circle around the building:
        # `Drawf.dashCircle(x, y, fogRadius() * tilesize,
        # Pal.accent);` (Radar.java:81). The center is the
        # building world position, the radius is the LIVE fog
        # radius (fogRadius(), Radar.java:55-57) times tilesize
        # (8, Vars.java:135), the color is Pal.accent. One pure
        # function on the family file (the N2220
        # RepairPointBuild.drawSelect() precedent): the caller
        # passes the live fogRadius() result (N2321) and the
        # tilesize as explicit params. No driver tick line
        # lands here: drawSelect is selection UI, not per-tick
        # state (the accessor precedent N2311/N2321). Three new
        # result symbols: center, radius, color.
        self.assertEqual(
            ledger['N2333']['source_symbols'],
            [
                'source_radar_draw_select_state_result.center',
                'source_radar_draw_select_state_result.radius',
                'source_radar_draw_select_state_result.color',
            ],
        )
        for name in ledger['N2333']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2333']['runtime_proof'], '/root/C07RadarDrawSelectProof')
        self.assertEqual(
            ledger['N2333']['tests'],
            [
                'test_c07_radar_draw_select_registration',
                'test_all_c07_radar_draw_select_input_evidence_is_exact',
                'test_radar_draw_select_state',
                'test_reference_graph_and_actual_c07_radar_draw_select',
            ],
        )
        self.assertTrue(ledger['N2333']['deferred_exprs'])

    def test_all_c07_radar_draw_select_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2333']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2333']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_draw_select_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure drawSelect() row lives on the radar build
        # state next to the N2327 draw rows:
        # RadarBuild.drawSelect() (Radar.java:80-82) draws one
        # dash circle (`Drawf.dashCircle(x, y, fogRadius() *
        # tilesize, Pal.accent);`, Radar.java:81). The radius
        # is the live fog radius (fogRadius(), Radar.java:55,
        # `return fogRadius * progress * smoothEfficiency;`,
        # Radar.java:56 -- def fogRadius 34, Blocks.java:1991,
        # class default 10, Radar.java:33) times tilesize 8
        # (Vars.java:135). The color is Pal.accent (the
        # SourceBlockDrawState.gd:182 precedent). This is a
        # different method from N2327 draw() (rotation + glow)
        # -- no overlap. One def (radar, Radar.java:17,
        # `public class Radar extends Block{`; RadarBuild,
        # Radar.java:48, `public class RadarBuild extends
        # Building{`).
        self.assertIn('static func source_radar_draw_select_state(x: float, y: float, fog_radius: float, tilesize: float) -> Dictionary:', radar)
        # The radius is the one computed value: the live fog
        # radius times tilesize, passed in by the caller.
        self.assertIn('fog_radius * tilesize', radar)
        for expr in [
            'public void drawSelect(){',
            'Drawf.dashCircle(x, y, fogRadius() * tilesize, Pal.accent);',
            'fogRadius() * tilesize',
            'public float fogRadius(){',
            'return fogRadius * progress * smoothEfficiency;',
            'public class Radar extends Block{',
            'public class RadarBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure drawSelect function
        # (radius at zero / half / full fog radius, tilesize 1
        # pinning the factor, center and color). There are no
        # driver-tick keys: drawSelect() is selection UI.
        proof = RADAR_DRAW_SELECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_select_radius_full_discovery',
            'draw_select_radius_half_progress',
            'draw_select_radius_zero_fog',
            'draw_select_radius_tilesize_one',
            'draw_select_radius_partial',
            'draw_select_center',
            'draw_select_color_accent',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_draw_select(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarDrawSelectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_DRAW_SELECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_select_radius_full_discovery',
            'draw_select_radius_half_progress',
            'draw_select_radius_zero_fog',
            'draw_select_radius_tilesize_one',
            'draw_select_radius_partial',
            'draw_select_center',
            'draw_select_color_accent',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
