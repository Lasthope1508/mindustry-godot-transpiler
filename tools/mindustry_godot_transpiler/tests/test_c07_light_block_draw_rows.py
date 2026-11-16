import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIGHT_BLOCK_STATE = ROOT / 'godot-mindustry/src/game/SourceLightBlockBuildState.gd'
LIGHT_BLOCK_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockDrawRowsProof.gd'
LIGHT_BLOCK_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockDrawRowsProof.tscn'


class C07LightBlockDrawRowsTests(unittest.TestCase):
    def test_c07_light_block_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2374']['godot_owner'], 'SourceLightBlockBuildState.source_light_block_draw_state')
        # The LightBlock tick is live (N2185 power.status fold +
        # N2189/N2241 smoothTime advance) but NOTHING modeled
        # draw() or drawLight(): the topRegion rect tinted by
        # the config color at alpha 0.6f and the emitted light
        # (radius lightRadius * min(smoothTime, 2f),
        # brightness * efficiency) were pure presentation the
        # port never described. N2374 ports draw() +
        # drawLight() as two pure draw-call dicts (the N2356
        # ShockwaveTower pattern: pures return draw-call
        # dicts, they never draw for real): the draw pure
        # returns the topRegion rect call, and the draw-light
        # pure returns the light call. There is NO drawSelect
        # (verified by reading LightBlock.java in full --
        # LightBuild overrides draw / drawLight / updateTile
        # only, and drawPlace / changePlacementPath /
        # minimapColor stay deferred under their own entry).
        # Draw never runs in the tick, so there is no tick
        # wiring (pure-only, like the BaseTurret drawPlace).
        # Two new result symbols: the top rect call and the
        # light call.
        self.assertEqual(
            ledger['N2374']['source_symbols'],
            [
                'source_light_block_draw_state_result.top_call',
                'source_light_block_draw_light_state_result.light_call',
            ],
        )
        for name in ledger['N2374']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/power/LightBlock.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_light_block_draw_state_result.top_call': 'SourceLightBlockBuildState.source_light_block_draw_state',
                    'source_light_block_draw_light_state_result.light_call': 'SourceLightBlockBuildState.source_light_block_draw_light_state',
                }[name])
        self.assertEqual(ledger['N2374']['runtime_proof'], '/root/C07LightBlockDrawRowsProof')
        self.assertEqual(
            ledger['N2374']['tests'],
            [
                'test_c07_light_block_draw_rows_registration',
                'test_all_c07_light_block_draw_rows_input_evidence_is_exact',
                'test_light_block_draw_rows_state',
                'test_reference_graph_and_actual_c07_light_block_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2374']['deferred_exprs'])
        # This slice RESOLVES the draw rows (#123 in the
        # merged advances-18 DEFERRED base) and the drawLight
        # rows (#119): the topRegion rect + alpha 0.6f are
        # live in the draw pure, and the light radius clamp +
        # brightness * efficiency fold are live in the
        # draw-light pure. No new entry is added: the draw
        # pures are pure-only (no tick wiring to defer), the
        # color config / drawPlace / read-write rows stay
        # deferred under their own entries. Net -2+0 = 317.
        self.assertFalse(any(entry.startswith('LightBlock draw rows (') for entry in ledger['N2374']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('LightBlock drawLight rows (') for entry in ledger['N2374']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock config / color rows (') for entry in ledger['N2374']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock init rows (') for entry in ledger['N2374']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock drawPlace / changePlacementPath / minimapColor rows (') for entry in ledger['N2374']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock read/write rows (') for entry in ledger['N2374']['deferred_exprs']))
        self.assertEqual(len(ledger['N2374']['deferred_exprs']), 317)

    def test_all_c07_light_block_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2374']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_light_block_draw_state_result.top_call': 'SourceLightBlockBuildState.source_light_block_draw_state',
                    'source_light_block_draw_light_state_result.light_call': 'SourceLightBlockBuildState.source_light_block_draw_light_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/power/LightBlock.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2374']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_light_block_draw_rows_state(self):
        light_block = LIGHT_BLOCK_STATE.read_text(encoding='utf-8')
        # The draw rows (LightBuild.draw(),
        # LightBlock.java:96-102; drawLight(),
        # LightBlock.java:126-128). draw() is super.draw()
        # (:97) + the color set (`Draw.color(Tmp.c1.set(
        # color).a(0.6f));`, :98 -- the config color, `public
        # int color = Pal.accent.rgba();`, :68, at alpha
        # 0.6f) + the top rect (`Draw.rect(topRegion, x, y);`,
        # :99 -- topRegion is the `@-top` region, :24) + the
        # color reset (`Draw.color();`, :100). drawLight() is
        # the emitted light (`Drawf.light(x, y, lightRadius *
        # Math.min(smoothTime, 2f), Tmp.c1.set(color),
        # brightness * efficiency);`, :127 -- lightRadius is
        # radius*2.5f, :40; brightness 0.9f / radius 200f are
        # the class defaults, :22-23, overridden by the
        # illuminator def to 0.75f / 140f,
        # Blocks.java:6765-6766). There is NO drawSelect:
        # LightBuild overrides draw / drawLight / updateTile
        # only. The pures take explicit params (the color is
        # NOT frame state -- the color config waits for its
        # own slice -- and lightRadius / brightness are
        # caller-supplied so the pures stay def-agnostic);
        # smoothTime and efficiency ride the live frame. Draw
        # never runs in the tick, so there is no tick wiring.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_light_block_draw_state', light_block)
        self.assertIn('static func source_light_block_draw_light_state', light_block)
        self.assertIn('public @Load("@-top") TextureRegion topRegion;', light_block)
        self.assertIn('public int color = Pal.accent.rgba();', light_block)
        self.assertIn('public float brightness = 0.9f;', light_block)
        self.assertIn('public float radius = 200f;', light_block)
        self.assertIn('lightRadius = radius*2.5f;', light_block)
        self.assertIn('public void draw(){', light_block)
        self.assertIn('super.draw();', light_block)
        self.assertIn('Draw.color(Tmp.c1.set(color).a(0.6f));', light_block)
        self.assertIn('Draw.rect(topRegion, x, y);', light_block)
        self.assertIn('Draw.color();', light_block)
        self.assertIn('public void drawLight(){', light_block)
        self.assertIn('Drawf.light(x, y, lightRadius * Math.min(smoothTime, 2f), Tmp.c1.set(color), brightness * efficiency);', light_block)
        # The top alpha is a driver constant (0.6f, the Java
        # literal in the Draw.color call); the draw pure reads
        # it, not a literal.
        self.assertIn('SOURCE_LIGHT_BLOCK_DRAW_TOP_ALPHA := 0.6', light_block)
        # The documented limits record the draw rows as live
        # (the old "waits for their own slice" text for the
        # draw / drawLight rows is gone).
        self.assertIn('Draw rows live (N2374)', light_block)
        self.assertNotIn('No draw / read / write modeling', light_block)
        # The proof's keys drive the draw pures (the topRegion
        # rect, the 0.6f color alpha, the drawLight radius
        # clamp min(smoothTime, 2f), the brightness *
        # efficiency fold, the illuminator def values) plus
        # the live frame values (a placed illuminator's frame
        # smooth_time + efficiency feed the draw-light pure).
        # There are no color-config / drawPlace keys: those
        # rows still defer.
        proof = LIGHT_BLOCK_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_top_region_rect',
            'draw_color_alpha_06',
            'draw_light_radius_clamp',
            'draw_light_brightness_efficiency',
            'draw_light_def_values',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceLightBlockBuildState.gd")', proof)
        self.assertTrue(LIGHT_BLOCK_STATE.exists())
        self.assertTrue(LIGHT_BLOCK_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07LightBlockDrawRowsProof.gd', LIGHT_BLOCK_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_light_block_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LightBlockDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIGHT_BLOCK_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_top_region_rect',
            'draw_color_alpha_06',
            'draw_light_radius_clamp',
            'draw_light_brightness_efficiency',
            'draw_light_def_values',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
