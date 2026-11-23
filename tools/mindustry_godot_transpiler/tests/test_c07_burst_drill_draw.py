import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
BURST_DRILL_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BurstDrillDrawProof.gd'


class C07BurstDrillDrawTests(unittest.TestCase):
    def test_c07_burst_drill_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2314']['godot_owner'], 'SourceBurstDrillBuildState.source_burst_drill_draw_state')
        # BurstDrillBuild.draw() (BurstDrill.java:133-180,
        # `public void draw(){`) is the BurstDrillBuild
        # OVERRIDE (BurstDrill.java:70, `public class
        # BurstDrillBuild extends DrillBuild{`): base rect +
        # drawDefaultCracks() + top rect + invert overlay +
        # mine-item overlay + 4-direction arrow ring + glow
        # additive. The DrillBuild.draw() BASE (Drill.java:
        # 346-379) is a LATER slice (N2317), NOT this one:
        # drawDefaultCracks() (Drill.java:341-343) is a callee
        # whose result the caller passes as an explicit param.
        # One pure function on the family file (the N2341
        # drawSelect precedent): it returns the computed draw
        # state (rects, colors, alpha, z, blend, glow) and
        # does NOT touch real Draw/Drawf playback. Fourteen
        # new result symbols: base_rect, cracks, top_rect,
        # invert_visible, invert_alpha, invert_rect,
        # mine_item_visible, mine_item_rect, fract,
        # arrow_count, arrows, glow_visible, glow_alpha,
        # glow_color. There is NO driver tick line: draw()
        # is per-frame render state, not per-tick state (the
        # N2341 drawSelect lifecycle precedent).
        self.assertEqual(
            ledger['N2314']['source_symbols'],
            [
                'source_burst_drill_draw_state_result.base_rect',
                'source_burst_drill_draw_state_result.cracks',
                'source_burst_drill_draw_state_result.top_rect',
                'source_burst_drill_draw_state_result.invert_visible',
                'source_burst_drill_draw_state_result.invert_alpha',
                'source_burst_drill_draw_state_result.invert_rect',
                'source_burst_drill_draw_state_result.mine_item_visible',
                'source_burst_drill_draw_state_result.mine_item_rect',
                'source_burst_drill_draw_state_result.fract',
                'source_burst_drill_draw_state_result.arrow_count',
                'source_burst_drill_draw_state_result.arrows',
                'source_burst_drill_draw_state_result.glow_visible',
                'source_burst_drill_draw_state_result.glow_alpha',
                'source_burst_drill_draw_state_result.glow_color',
            ],
        )
        for name in ledger['N2314']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/BurstDrill.java',
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2314']['runtime_proof'], '/root/C07BurstDrillDrawProof')
        self.assertEqual(
            ledger['N2314']['tests'],
            [
                'test_c07_burst_drill_draw_registration',
                'test_all_c07_burst_drill_draw_input_evidence_is_exact',
                'test_burst_drill_draw_state',
                'test_reference_graph_and_actual_c07_burst_drill_draw',
            ],
        )
        self.assertTrue(ledger['N2314']['deferred_exprs'])

    def test_all_c07_burst_drill_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2314']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/BurstDrill.java',
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2314']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_burst_drill_draw_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # BurstDrillBuild.draw() (BurstDrill.java:133-180):
        # `Draw.rect(region, x, y);` (:134),
        # `drawDefaultCracks();` (:135),
        # `Draw.rect(topRegion, x, y);` (:137),
        # `if(invertTime > 0 && topInvertRegion.found()){`
        # (:139) with `Draw.alpha(Interp.pow3Out.apply(
        # invertTime));` (:140) and `Draw.rect(
        # topInvertRegion, x, y);` (:141),
        # `if(dominantItem != null && drawMineItem){`
        # (:145) with `Draw.color(dominantItem.color);`
        # (:146) and `Draw.rect(itemRegion, x, y);` (:147),
        # `float fract = smoothProgress;` (:151),
        # `Draw.color(arrowColor);` (:152), the 4-direction
        # arrow ring (:153-173): `float arrowFract =
        # (arrows - 1 - j);` (:155), `float a =
        # Mathf.clamp(fract * arrows - arrowFract);` (:156),
        # `Tmp.v1.trns(i * 90 + 45, j * arrowSpacing +
        # arrowOffset);` (:157), `Draw.z(Layer.block);`
        # (:159), `Draw.color(baseArrowColor, arrowColor, a);`
        # (:160), `Draw.rect(arrowRegion, x + Tmp.v1.x, y +
        # Tmp.v1.y, i * 90);` (:161), blur `if(
        # arrowBlurRegion.found()){` (:165) with
        # `Draw.z(Layer.blockAdditive);` (:166),
        # `Draw.blend(Blending.additive);` (:167),
        # `Draw.alpha(Mathf.pow(a, 10f));` (:168) and
        # `Draw.rect(arrowBlurRegion, x + Tmp.v1.x, y +
        # Tmp.v1.y, i * 90);` (:169), then `Draw.color();`
        # (:174) and `if(glowRegion.found()){` (:177) with
        # `Drawf.additive(glowRegion, Tmp.c2.set(glowColor)
        # .a(Mathf.pow(fract, 3f) * glowColor.a), x, y);`
        # (:178). Per-def: impact-drill uses class defaults
        # (arrows 3, arrowSpacing 4f, arrowOffset 0f,
        # glowColor.a 1.0); eruption-drill overrides
        # `arrowOffset = 2f;` (Blocks.java:3108),
        # `arrowSpacing = 5f;` (:3109), `arrows = 2;`
        # (:3110), `glowColor.a = 0.6f;` (:3111). The classes
        # are `public class BurstDrill extends Drill{`
        # (BurstDrill.java:17) and `public class
        # BurstDrillBuild extends DrillBuild{` (:70).
        # drawDefaultCracks() (Drill.java:341-343) is a callee
        # (D5, N2317) -- passed as an explicit param, NOT
        # re-ported. There is NO driver tick line: draw() is
        # per-frame render state.
        self.assertIn('static func source_burst_drill_draw_state(x: float, y: float, region: Variant, top_region: Variant, item_region: Variant, arrow_region: Variant, arrow_blur_region: Variant, glow_region: Variant, top_invert_region: Variant, invert_time: float, smooth_progress: float, has_dominant_item: bool, dominant_item_color: Variant, draw_mine_item: bool, arrows: int, arrow_spacing: float, arrow_offset: float, arrow_color: Variant, base_arrow_color: Variant, glow_color: Variant, top_invert_region_found: bool, arrow_blur_region_found: bool, glow_region_found: bool, draw_default_cracks: Dictionary) -> Dictionary:', burst_drill)
        for expr in [
            'public void draw(){',
            'Draw.rect(region, x, y);',
            'drawDefaultCracks();',
            'Draw.rect(topRegion, x, y);',
            'if(invertTime > 0 && topInvertRegion.found()){',
            'Draw.alpha(Interp.pow3Out.apply(invertTime));',
            'Draw.rect(topInvertRegion, x, y);',
            'if(dominantItem != null && drawMineItem){',
            'Draw.color(dominantItem.color);',
            'Draw.rect(itemRegion, x, y);',
            'float fract = smoothProgress;',
            'Draw.color(arrowColor);',
            'for(int i = 0; i < 4; i++){',
            'for(int j = 0; j < arrows; j++){',
            'float arrowFract = (arrows - 1 - j);',
            'float a = Mathf.clamp(fract * arrows - arrowFract);',
            'Tmp.v1.trns(i * 90 + 45, j * arrowSpacing + arrowOffset);',
            'Draw.z(Layer.block);',
            'Draw.color(baseArrowColor, arrowColor, a);',
            'Draw.rect(arrowRegion, x + Tmp.v1.x, y + Tmp.v1.y, i * 90);',
            'if(arrowBlurRegion.found()){',
            'Draw.z(Layer.blockAdditive);',
            'Draw.blend(Blending.additive);',
            'Draw.alpha(Mathf.pow(a, 10f));',
            'Draw.rect(arrowBlurRegion, x + Tmp.v1.x, y + Tmp.v1.y, i * 90);',
            'Draw.blend();',
            'if(glowRegion.found()){',
            'Drawf.additive(glowRegion, Tmp.c2.set(glowColor).a(Mathf.pow(fract, 3f) * glowColor.a), x, y);',
            'public class BurstDrill extends Drill{',
            'public class BurstDrillBuild extends DrillBuild{',
            'public float smoothProgress = 0f;',
            'public float invertTime = 0f;',
            'public float arrowSpacing = 4f, arrowOffset = 0f;',
            'public int arrows = 3;',
            'public Color arrowColor = Color.valueOf("feb380"), baseArrowColor = Color.valueOf("6e7080");',
            'public Color glowColor = arrowColor.cpy();',
            'public @Load("@-top-invert") TextureRegion topInvertRegion;',
            'public @Load("@-glow") TextureRegion glowRegion;',
            'public @Load("@-arrow") TextureRegion arrowRegion;',
            'public @Load("@-arrow-blur") TextureRegion arrowBlurRegion;',
            'public void drawDefaultCracks(){',
            'public boolean drawMineItem = true;',
            'public Item dominantItem;',
            'public @Load("@-top") TextureRegion topRegion;',
            'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;',
            'public TextureRegion region;',
            'size = 4;',
            'size = 5;',
            'arrowOffset = 2f;',
            'arrowSpacing = 5f;',
            'arrows = 2;',
            'glowColor.a = 0.6f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with per-def params: base/top rects at (100, 200);
        # cracks passed through; invert visible at 0.5 with
        # alpha 0.875, hidden at 0; mine-item visible with
        # dominant + drawMineItem, hidden without; fract =
        # smoothProgress; 12 arrows impact (4x3), 8 eruption
        # (4x2); first arrow at (100, 200) alpha 1 rotation
        # 0; alpha clamped 0/1; arrow at i=1,j=1 sits at
        # (100-2.828, 200+2.828) rotation 90; blur alpha
        # pow(a, 10); glow alpha pow(fract, 3) * glowColor.a
        # (0.125 impact, 0.075 eruption at fract 0.5),
        # hidden when glow not found.
        proof = BURST_DRILL_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_rect',
            'draw_top_rect',
            'draw_cracks_passthrough',
            'draw_invert',
            'draw_mine_item',
            'draw_fract',
            'draw_arrow_count',
            'draw_arrow_first',
            'draw_arrow_alpha_clamp',
            'draw_arrow_position',
            'draw_arrow_blur',
            'draw_glow',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_burst_drill_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BurstDrillDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BURST_DRILL_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_rect',
            'draw_top_rect',
            'draw_cracks_passthrough',
            'draw_invert',
            'draw_mine_item',
            'draw_fract',
            'draw_arrow_count',
            'draw_arrow_first',
            'draw_arrow_alpha_clamp',
            'draw_arrow_position',
            'draw_arrow_blur',
            'draw_glow',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
