import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RADAR_STATE = ROOT / 'godot-mindustry/src/game/SourceRadarBuildState.gd'
RADAR_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07RadarDrawProof.gd'


class C07RadarDrawTests(unittest.TestCase):
    def test_c07_radar_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2278']['godot_owner'], 'SourceRadarBuildState.source_radar_draw_rotation_state')
        # RadarBuild.draw() (Radar.java:84-90): the dish region
        # and the glow share one rotation, rotateSpeed *
        # totalProgress (Radar.java:87, :89), and the glow
        # alpha is glowColor.a * (1f - glowMag +
        # Mathf.absin(glowScl, glowMag)) (Radar.java:89).
        # Two pure functions on the same family file, one
        # ledger entry (the N2316 multi-function precedent):
        # rotation first, glow second. No driver tick line
        # lands here: draw() is a render call, not tick state
        # (the accessor precedent N2311/N2275). Two new result
        # symbols: rotation, glow_alpha.
        self.assertEqual(
            ledger['N2278']['source_symbols'],
            [
                'source_radar_draw_rotation_state_result.rotation',
                'source_radar_draw_glow_state_result.glow_alpha',
            ],
        )
        for name in ledger['N2278']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/defense/Radar.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2278']['runtime_proof'], '/root/C07RadarDrawProof')
        self.assertEqual(
            ledger['N2278']['tests'],
            [
                'test_c07_radar_draw_registration',
                'test_all_c07_radar_draw_input_evidence_is_exact',
                'test_radar_draw_state',
                'test_reference_graph_and_actual_c07_radar_draw',
            ],
        )
        self.assertTrue(ledger['N2278']['deferred_exprs'])

    def test_all_c07_radar_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2278']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceRadarBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/Radar.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2278']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_radar_draw_state(self):
        radar = RADAR_STATE.read_text(encoding='utf-8')
        # The pure draw() rows live on the radar build state
        # next to the N2320 updateTile advance: RadarBuild.draw()
        # (Radar.java:84-90) draws the base region unrotated
        # (`Draw.rect(baseRegion, x, y);`, Radar.java:86), the
        # region rotated by rotateSpeed * totalProgress
        # (Radar.java:87), and the glow additive with alpha
        # glowColor.a * (1f - glowMag + Mathf.absin(glowScl,
        # glowMag)) at the same rotation (Radar.java:89).
        # rotateSpeed is 2f (Radar.java:19), glowScl 5f /
        # glowMag 0.6f (Radar.java:25), glowColor Pal.turretHeat
        # (Radar.java:24, Pal.java:52, 6-digit hex -- alpha 1.0).
        # The base rect has no computed value: it is a static
        # draw call, render-only, so no pure function pins it.
        # One def (radar, Radar.java:17, `public class Radar
        # extends Block{`; RadarBuild, Radar.java:48, `public
        # class RadarBuild extends Building{`).
        self.assertIn('static func source_radar_draw_rotation_state(frame: Dictionary, rotate_speed: float) -> Dictionary:', radar)
        self.assertIn('static func source_radar_draw_glow_state(frame: Dictionary, glow_color_alpha: float, glow_mag: float, absin_value: float) -> Dictionary:', radar)
        # The rotation is the one computed angle both draws
        # share: rotateSpeed * totalProgress, total_progress
        # read from the frame (advanced by updateTile :71).
        self.assertIn('rotate_speed * total_progress', radar)
        # The glow alpha is the one computed alpha: the caller
        # supplies the time-dependent absin evaluation, the pure
        # function does the algebra.
        self.assertIn('glow_color_alpha * (1.0 - glow_mag + absin_value)', radar)
        for expr in [
            'public void draw(){',
            'Draw.rect(baseRegion, x, y);',
            'Draw.rect(region, x, y, rotateSpeed * totalProgress);',
            'Drawf.additive(glowRegion, glowColor, glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag)), x, y, rotateSpeed * totalProgress, Layer.blockAdditive);',
            'rotateSpeed * totalProgress',
            'Mathf.absin(glowScl, glowMag)',
            '1f - glowMag + Mathf.absin(glowScl, glowMag)',
            'glowColor.a * (1f - glowMag + Mathf.absin(glowScl, glowMag))',
            'public class Radar extends Block{',
            'public class RadarBuild extends Building{',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, radar)
        # The proof's keys drive both pure draw functions
        # (rotation at zero / half / full progress, glow alpha
        # at zero / partial / peak absin). There are no
        # driver-tick keys: draw() is render-only.
        proof = RADAR_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_rotation_zero_total_progress',
            'draw_rotation_half_progress',
            'draw_rotation_full_progress',
            'draw_rotation_absent_frame_zero',
            'draw_glow_alpha_full_pulse',
            'draw_glow_alpha_zero_absin',
            'draw_glow_alpha_half_color_alpha',
            'draw_glow_alpha_absin_max',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_radar_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07RadarDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_RADAR_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_rotation_zero_total_progress',
            'draw_rotation_half_progress',
            'draw_rotation_full_progress',
            'draw_rotation_absent_frame_zero',
            'draw_glow_alpha_full_pulse',
            'draw_glow_alpha_zero_absin',
            'draw_glow_alpha_half_color_alpha',
            'draw_glow_alpha_absin_max',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
