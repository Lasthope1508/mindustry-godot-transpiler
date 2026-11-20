import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_DRAW_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillDrawProof.gd'


class C07DrillDrawTests(unittest.TestCase):
    def test_c07_drill_draw_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2325']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_draw_state')
        # DrillBuild.draw() BASE (Drill.java:346-379,
        # `public void draw(){`): base rect + cracks at
        # Layer.blockCracks + drawDefaultCracks() +
        # rim overlay at Layer.blockAfterCracks + rotator
        # (spinSprite or plain rect) + top rect +
        # mine-item overlay. drawCracks() (Drill.java:339)
        # is an EMPTY override (`public void
        # drawCracks(){}`) -- the DrillBuild never draws
        # BuildingComp cracks directly; drawDefaultCracks()
        # (Drill.java:341-343, `super.drawCracks();`)
        # invokes the BuildingComp.drawCracks() guard +
        # region + colorl + rotated rect (BuildingComp.
        # java:1231-1239), which THIS slice ports. The
        # BurstDrillBuild.draw() OVERRIDE (BurstDrill.java:
        # 133-180) is N2314, NOT this one: N2314 takes the
        # already-computed cracks dict as an explicit param
        # and this slice now supplies that computation.
        # One pure function on the family file (the N2283
        # drawSelect / N2314 draw precedents): it returns
        # the computed draw state (rects, colors, alpha, z,
        # blend, spin) and does NOT touch real Draw/Drawf
        # playback. Eleven new result symbols: base_rect,
        # cracks_z, cracks, after_cracks_z, rim_visible,
        # rim_alpha, rim_rect, rotator, top_rect,
        # mine_item_visible, mine_item_rect. There is NO
        # driver tick line: draw() is per-frame render
        # state, not per-tick state (the N2283 drawSelect
        # lifecycle precedent).
        self.assertEqual(
            ledger['N2325']['source_symbols'],
            [
                'source_drill_draw_state_result.base_rect',
                'source_drill_draw_state_result.cracks_z',
                'source_drill_draw_state_result.cracks',
                'source_drill_draw_state_result.after_cracks_z',
                'source_drill_draw_state_result.rim_visible',
                'source_drill_draw_state_result.rim_alpha',
                'source_drill_draw_state_result.rim_rect',
                'source_drill_draw_state_result.rotator',
                'source_drill_draw_state_result.top_rect',
                'source_drill_draw_state_result.mine_item_visible',
                'source_drill_draw_state_result.mine_item_rect',
            ],
        )
        for name in ledger['N2325']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/entities/comp/HealthComp.java',
                    'core/src/mindustry/world/Block.java',
                    'core/src/mindustry/content/Blocks.java',
                    'core/src/mindustry/graphics/Layer.java',
                    'core/src/mindustry/graphics/Drawf.java',
                    'core/src/mindustry/graphics/BlockRenderer.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2325']['runtime_proof'], '/root/C07DrillDrawProof')
        self.assertEqual(
            ledger['N2325']['tests'],
            [
                'test_c07_drill_draw_registration',
                'test_all_c07_drill_draw_input_evidence_is_exact',
                'test_drill_draw_state',
                'test_reference_graph_and_actual_c07_drill_draw',
            ],
        )
        self.assertTrue(ledger['N2325']['deferred_exprs'])

    def test_all_c07_drill_draw_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2325']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/HealthComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Layer.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/graphics/BlockRenderer.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2325']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_draw_state(self):
        drill = DRILL_STATE.read_text(encoding='utf-8')
        # DrillBuild.draw() BASE (Drill.java:346-379):
        # `float s = 0.3f;` (:347), `float ts = 0.6f;`
        # (:348), `Draw.rect(region, x, y);` (:350),
        # `Draw.z(Layer.blockCracks);` (:351),
        # `drawDefaultCracks();` (:352),
        # `Draw.z(Layer.blockAfterCracks);` (:354),
        # `if(drawRim){` (:355) with `Draw.color(
        # heatColor);` (:356), `Draw.alpha(warmup * ts *
        # (1f - s + Mathf.absin(Time.time, 3f, s)));`
        # (:357), `Draw.blend(Blending.additive);` (:358)
        # and `Draw.rect(rimRegion, x, y);` (:359),
        # `if(drawSpinSprite){` (:364) with `Drawf.
        # spinSprite(rotatorRegion, x, y, timeDrilled *
        # rotateSpeed);` (:365), else `Draw.rect(
        # rotatorRegion, x, y, timeDrilled * rotateSpeed);`
        # (:367), `Draw.rect(topRegion, x, y);` (:370),
        # `if(dominantItem != null && drawMineItem){`
        # (:372) with `Draw.color(dominantItem.color);`
        # (:373) and `Draw.rect(itemRegion, x, y);`
        # (:374). drawCracks() (Drill.java:339) is an empty
        # override (`public void drawCracks(){}`); the
        # cracks come only from drawDefaultCracks()
        # (Drill.java:341-343, `super.drawCracks();`) over
        # BuildingComp.drawCracks() (BuildingComp.java:
        # 1231-1239): `if(!block.drawCracks || !damaged()
        # || block.size > BlockRenderer.maxCrackSize)
        # return;`, `int id = pos();`, the crack region
        # `renderer.blocks.cracks[block.size - 1][Mathf.
        # clamp((int)((1f - healthf()) * BlockRenderer.
        # crackRegions), 0, BlockRenderer.crackRegions-1)]`,
        # `Draw.colorl(0.2f, 0.1f + (1f - healthf())*
        # 0.6f);`, `Draw.rect(region, x, y, (id%4)*90);`.
        # Per-def: mechanical/pneumatic-drill `size = 2;`,
        # laser-drill `size = 3;`, blast-drill `size = 4;`
        # with `drawRim = true;` and `rotateSpeed = 6f;`
        # (Blocks.java). The classes are `public class
        # Drill extends Block{` (Drill.java:27) and
        # `public class DrillBuild extends Building{`
        # (:237); BurstDrillBuild inherits DrillBuild
        # (`public class BurstDrill extends Drill{`,
        # BurstDrill.java:17) and its draw() OVERRIDE is
        # N2314, NOT this slice. There is NO driver tick
        # line: draw() is per-frame render state.
        self.assertIn('static func source_drill_draw_state(x: float, y: float, region: Variant, rim_region: Variant, rotator_region: Variant, top_region: Variant, item_region: Variant, block_draw_cracks: bool, damaged: bool, block_size: int, healthf: float, pos_id: int, crack_regions: Array, draw_rim: bool, heat_color: Variant, warmup: float, time_now: float, draw_spin_sprite: bool, time_drilled: float, rotate_speed: float, draw_alpha: float, has_dominant_item: bool, dominant_item_color: Variant, draw_mine_item: bool) -> Dictionary:', drill)
        for expr in [
            'public void drawCracks(){}',
            'public void drawDefaultCracks(){',
            'super.drawCracks();',
            'public void draw(){',
            'float s = 0.3f;',
            'float ts = 0.6f;',
            'Draw.rect(region, x, y);',
            'Draw.z(Layer.blockCracks);',
            'drawDefaultCracks();',
            'Draw.z(Layer.blockAfterCracks);',
            'if(drawRim){',
            'Draw.color(heatColor);',
            'Draw.alpha(warmup * ts * (1f - s + Mathf.absin(Time.time, 3f, s)));',
            'Draw.blend(Blending.additive);',
            'Draw.rect(rimRegion, x, y);',
            'Draw.blend();',
            'Draw.color();',
            'if(drawSpinSprite){',
            'Drawf.spinSprite(rotatorRegion, x, y, timeDrilled * rotateSpeed);',
            'Draw.rect(rotatorRegion, x, y, timeDrilled * rotateSpeed);',
            'Draw.rect(topRegion, x, y);',
            'if(dominantItem != null && drawMineItem){',
            'Draw.color(dominantItem.color);',
            'Draw.rect(itemRegion, x, y);',
            'if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;',
            'int id = pos();',
            'TextureRegion region = renderer.blocks.cracks[block.size - 1][Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)];',
            'Draw.colorl(0.2f, 0.1f + (1f - healthf())* 0.6f);',
            'Draw.rect(region, x, y, (id%4)*90);',
            'public class Drill extends Block{',
            'public class DrillBuild extends Building{',
            'public float rotateSpeed = 2f;',
            'public boolean drawRim = false;',
            'public boolean drawSpinSprite = true;',
            'public Color heatColor = Color.valueOf("ff5512");',
            'public @Load("@-rim") TextureRegion rimRegion;',
            'public @Load("@-rotator") TextureRegion rotatorRegion;',
            'public @Load("@-top") TextureRegion topRegion;',
            'public @Load(value = "@-item", fallback = "drill-item-@size") TextureRegion itemRegion;',
            'public boolean drawMineItem = true;',
            'public Item dominantItem;',
            'public float warmup;',
            'public float timeDrilled;',
            'public boolean drawCracks = true;',
            'public TextureRegion region;',
            'size = 2;',
            'size = 3;',
            'size = 4;',
            'drawRim = true;',
            'rotateSpeed = 6f;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, drill)
        # The proof's keys drive the pure function directly
        # with per-def params: base/top rects at (100, 200);
        # cracks at healthf 0.5 size 2 (index 4, rotation
        # 90, alpha 0.4) and hidden by each guard leg
        # (undamaged, drawCracks off, size 8); rim alpha
        # 0.51 at warmup 1 time 0, 0.6 at time 3*PI,
        # hidden without drawRim; spin rotator two rects
        # (30 deg alpha 1, -60 deg alpha 1/3) and plain
        # rotator one rect at 90 deg; mine-item visible
        # with dominant + drawMineItem, hidden without.
        proof = DRILL_DRAW_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_rect',
            'draw_cracks',
            'draw_cracks_guard',
            'draw_rim',
            'draw_rotator_spin',
            'draw_rotator_plain',
            'draw_top_rect',
            'draw_mine_item',
            'draw_cracks_z',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_draw(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillDrawProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_DRAW_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_rect',
            'draw_cracks',
            'draw_cracks_guard',
            'draw_rim',
            'draw_rotator_spin',
            'draw_rotator_plain',
            'draw_top_rect',
            'draw_mine_item',
            'draw_cracks_z',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
