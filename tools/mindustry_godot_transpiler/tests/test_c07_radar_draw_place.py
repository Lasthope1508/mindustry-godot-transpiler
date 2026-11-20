import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_DRAW_PLACE_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDrawPlaceProof.gd'


class C07RadarDrawPlaceTests(unittest.TestCase):
    def test_c07_radar_draw_place_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2284']['godot_owner'], 'SourceRadarBuildState.source_radar_draw_place_state')
        # Radar.drawPlace() (Radar.java:42-47) draws one
        # dash circle at the ghost position:
        # `Drawf.dashCircle(x * tilesize + offset, y *
        # tilesize + offset, fogRadius * tilesize,
        # Pal.accent);` (Radar.java:46), after
        # `super.drawPlace(x, y, rotation, valid);`
        # (Radar.java:43). The center converts tile coords
        # to world coords with tilesize and the block offset
        # (8, Vars.java:135; offset ((size + 1) % 2) *
        # tilesize / 2f, Block.java:761 -- radar size 1, so
        # 0.0). The radius is the DEF fogRadius (Block
        # field, Block.java:348, int, default -1) -- class
        # default 10 (Radar.java:33), radar def 34
        # (Blocks.java:1991) -- times tilesize, NOT the
        # live fogRadius() (N2321): drawPlace is
        # Block-level and reads the def field, unlike
        # drawSelect (N2281) which reads the live
        # fogRadius(). The color is Pal.accent. The super
        # leg (Block.drawPlace, Block.java:491-494:
        # drawPotentialLinks + drawOverlay) is folded as
        # explicit params (the N2317/N2277 super-as-param
        # precedent): rotation/valid are echoed and
        # super_draw_place_called records the call; the
        # link/overlay drawing itself waits for its own
        # slice. No driver tick line lands here: drawPlace
        # is placement UI, not per-tick state (the
        # accessor precedent N2311/N2321). Six new result
        # symbols: center, radius, color, rotation, valid,
        # super_draw_place_called.
        self.assertEqual(
            ledger['N2284']['source_symbols'],
            [
                'source_radar_draw_place_state_result.center',
                'source_radar_draw_place_state_result.radius',
                'source_radar_draw_place_state_result.color',
                'source_radar_draw_place_state_result.rotation',
                'source_radar_draw_place_state_result.valid',
                'source_radar_draw_place_state_result.super_draw_place_called',
            ],
        )
        for name in ledger['N2284']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2284']['runtime_proof'], '/root/C07RadarDrawPlaceProof')
        self.assertEqual(
            ledger['N2284']['tests'],
            [
                'test_c07_radar_draw_place_registration',
                'test_all_c07_radar_draw_place_input_evidence_is_exact',
                'test_radar_draw_place_state',
                'test_reference_graph_and_actual_c07_radar_draw_place',
            ],
        )
        self.assertTrue(ledger['N2284']['deferred_exprs'])

    def test_all_c07_radar_draw_place_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2284']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2284']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_draw_place_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure drawPlace() row lives on the radar build
        # state next to the N2281 drawSelect row:
        # Radar.drawPlace() (Radar.java:42-47) draws one
        # dash circle at the ghost position
        # (`Drawf.dashCircle(x * tilesize + offset, y *
        # tilesize + offset, fogRadius * tilesize,
        # Pal.accent);`, Radar.java:46) after
        # `super.drawPlace(x, y, rotation, valid);`
        # (Radar.java:43). The center is the tile position
        # in world units (tilesize 8, Vars.java:135, plus
        # the block offset, Block.java:761 -- radar size 1,
        # so 0.0). The radius is the DEF fogRadius -- 34
        # (Blocks.java:1991), class default 10
        # (Radar.java:33) -- times tilesize, so 272.0 for
        # the radar def and 80.0 for the class default.
        # The color is Pal.accent (the
        # SourceBlockDrawState.gd:182 precedent). This is a
        # different method from N2281 drawSelect (Build
        # method, live fogRadius()) -- no overlap. One def
        # (radar, Radar.java:17, `public class Radar
        # extends Block{`).
        self.assertIn('static func source_radar_draw_place_state(tile_x: int, tile_y: int, rotation: int, valid: bool, fog_radius: float, tilesize: float, block_offset: float) -> Dictionary:', radar)
        # The center converts tile coords to world coords
        # with tilesize and the block offset; the radius is
        # the def fog radius times tilesize.
        self.assertIn('float(tile_x) * tilesize + block_offset', radar)
        self.assertIn('fog_radius * tilesize', radar)
        for expr in [
            'public void drawPlace(int x, int y, int rotation, boolean valid){',
            'super.drawPlace(x, y, rotation, valid);',
            'Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, fogRadius * tilesize, Pal.accent);',
            'fogRadius * tilesize',
            'fogRadius = 10;',
            'public class Radar extends Block{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive the pure drawPlace function
        # (radius at the class-default / radar-def fog
        # radius, tilesize 1 pinning the factor, center
        # with the real zero offset and with a nonzero
        # offset, color, the rotation/valid echo, the super
        # call marker). There are no driver-tick keys:
        # drawPlace() is placement UI.
        proof = RADAR_DRAW_PLACE_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_place_radius_def_default',
            'draw_place_radius_def_radar',
            'draw_place_radius_tilesize_one',
            'draw_place_radius_zero_fog',
            'draw_place_center',
            'draw_place_center_offset',
            'draw_place_color_accent',
            'draw_place_rotation_echo',
            'draw_place_valid_echo',
            'draw_place_super_called',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_draw_place(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarDrawPlaceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_DRAW_PLACE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_place_radius_def_default',
            'draw_place_radius_def_radar',
            'draw_place_radius_tilesize_one',
            'draw_place_radius_zero_fog',
            'draw_place_center',
            'draw_place_center_offset',
            'draw_place_color_accent',
            'draw_place_rotation_echo',
            'draw_place_valid_echo',
            'draw_place_super_called',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
