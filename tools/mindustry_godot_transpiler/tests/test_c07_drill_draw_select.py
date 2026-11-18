import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BURST_DRILL_STATE = ROOT / 'godot-mindustry/src/game/SourceBurstDrillBuildState.gd'
DRILL_DRAW_SELECT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07DrillDrawSelectProof.gd'


class C07DrillDrawSelectTests(unittest.TestCase):
    def test_c07_drill_draw_select_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2283']['godot_owner'], 'SourceBurstDrillBuildState.source_drill_draw_select_state')
        # DrillBuild.drawSelect() (Drill.java:262-264,
        # `public void drawSelect(){` with
        # `drawItemSelection(dominantItem);`, :263) draws the
        # dominant item's icon above the building through the
        # live BuildingComp.drawItemSelection helper
        # (BuildingComp.java:1249-1257, `public void
        # drawItemSelection(@Nullable UnlockableContent
        # selection){`): the icon sits at dx = x -
        # block.size * tilesize/2f, dy = y + block.size *
        # tilesize/2f, sized s = iconSmall / 4f *
        # selection.fullIcon.ratio(), h = iconSmall / 4f,
        # with a darkGray shadow rect at dy - 1 and the
        # foreground rect at dy. One pure function on the
        # family file (the N2220 RepairPointBuild.drawSelect()
        # / N2281 Radar drawSelect() precedent): the caller
        # passes dominantItem as explicit params
        # (has_dominant_item, dominant_item_icon_ratio) and
        # the function calls the live helper
        # source_building_draw_state.draw_item_selection_state
        # (PortGame N570) -- it does NOT re-port the helper.
        # Nine new result symbols: visible, dx, dy,
        # shadow_color, shadow_alpha, shadow_y, foreground_y,
        # selection_width, selection_height. There is NO
        # driver tick line: drawSelect is selection UI, not
        # per-tick state (the accessor precedent
        # N2268/N2275/N2281).
        self.assertEqual(
            ledger['N2283']['source_symbols'],
            [
                'source_drill_draw_select_state_result.visible',
                'source_drill_draw_select_state_result.dx',
                'source_drill_draw_select_state_result.dy',
                'source_drill_draw_select_state_result.shadow_color',
                'source_drill_draw_select_state_result.shadow_alpha',
                'source_drill_draw_select_state_result.shadow_y',
                'source_drill_draw_select_state_result.foreground_y',
                'source_drill_draw_select_state_result.selection_width',
                'source_drill_draw_select_state_result.selection_height',
            ],
        )
        for name in ledger['N2283']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/production/Drill.java',
                    'core/src/mindustry/entities/comp/BuildingComp.java',
                    'core/src/mindustry/Vars.java',
                    'core/src/mindustry/content/Blocks.java',
                })
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        self.assertEqual(ledger['N2283']['runtime_proof'], '/root/C07DrillDrawSelectProof')
        self.assertEqual(
            ledger['N2283']['tests'],
            [
                'test_c07_drill_draw_select_registration',
                'test_all_c07_drill_draw_select_input_evidence_is_exact',
                'test_drill_draw_select_state',
                'test_reference_graph_and_actual_c07_drill_draw_select',
            ],
        )
        self.assertTrue(ledger['N2283']['deferred_exprs'])

    def test_all_c07_drill_draw_select_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2283']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBurstDrillBuildState.' + name.rsplit('_result.', 1)[0])
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Drill.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2283']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_drill_draw_select_state(self):
        burst_drill = BURST_DRILL_STATE.read_text(encoding='utf-8')
        # DrillBuild.drawSelect() (Drill.java:262-264,
        # `public void drawSelect(){` with
        # `drawItemSelection(dominantItem);`, :263) draws the
        # dominant item's icon (`public Item dominantItem;`,
        # Drill.java:244, set by the N2262 ore/dominant
        # binding) through BuildingComp.drawItemSelection
        # (BuildingComp.java:1249-1257): `if(selection !=
        # null){` (:1250), then `float dx = x - block.size *
        # tilesize/2f, dy = y + block.size * tilesize/2f, s =
        # iconSmall / 4f * selection.fullIcon.ratio(), h =
        # iconSmall / 4f;` (:1251), `Draw.mixcol(
        # Color.darkGray, 1f);` (:1252),
        # `Draw.rect(selection.fullIcon, dx, dy - 1, s, h);`
        # (:1253), `Draw.reset();` (:1254),
        # `Draw.rect(selection.fullIcon, dx, dy, s, h);`
        # (:1255). The pure function calls the live helper
        # draw_item_selection_state (SourceBuildingDrawState.gd,
        # PortGame N570) with dominantItem passed as explicit
        # params -- it does NOT re-port the helper. tilesize
        # is 8 (`public static final int tilesize = 8;`,
        # Vars.java:135), iconSmall is 24 (`iconSmall =
        # 8*3f;`, Vars.java:139). Per-def sizes: impact-drill
        # `size = 4;` (Blocks.java:3073), eruption-drill
        # `size = 5;` (Blocks.java:3096). The classes are
        # `public class Drill extends Block{` (Drill.java:27)
        # and `public class DrillBuild extends Building{`
        # (Drill.java:237); BurstDrillBuild inherits
        # DrillBuild (`public class BurstDrill extends
        # Drill{`, BurstDrill.java:17). This is a different
        # method from RepairTurret drawSelect N2220
        # (different class) -- no overlap. There is NO
        # driver tick line: drawSelect is selection UI.
        self.assertIn('static func source_drill_draw_select_state(x: float, y: float, block_size: int, tilesize: float, icon_small: float, has_dominant_item: bool, dominant_item_icon_ratio: float) -> Dictionary:', burst_drill)
        self.assertIn('return source_building_draw_state.draw_item_selection_state(has_dominant_item, x, y, block_size, tilesize, icon_small, dominant_item_icon_ratio)', burst_drill)
        for expr in [
            'public void drawSelect(){',
            'drawItemSelection(dominantItem);',
            'public void drawItemSelection(@Nullable UnlockableContent selection){',
            'if(selection != null){',
            'float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;',
            'Draw.mixcol(Color.darkGray, 1f);',
            'Draw.rect(selection.fullIcon, dx, dy - 1, s, h);',
            'Draw.rect(selection.fullIcon, dx, dy, s, h);',
            'public Item dominantItem;',
            'public class Drill extends Block{',
            'public class DrillBuild extends Building{',
            'public static final int tilesize = 8;',
            'iconSmall = 8*3f;',
            'size = 4;',
            'size = 5;',
        ]:
            with self.subTest(expr=expr):
                self.assertIn(expr, burst_drill)
        # The proof's keys drive the pure function directly
        # with per-def params: hidden when there is no
        # dominant item, visible with one; dx/dy per def
        # (impact 84/216, eruption 80/220 at 100/200);
        # selection size from iconSmall 24 (6 high, 6 wide
        # at ratio 1.0, 12 wide at ratio 2.0); shadow
        # darkGray at dy - 1, foreground at dy; tilesize
        # 1.0 reads the raw offsets (98/202).
        proof = DRILL_DRAW_SELECT_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_select_hidden_no_dominant',
            'draw_select_visible_with_dominant',
            'draw_select_dx_impact',
            'draw_select_dy_impact',
            'draw_select_position_eruption',
            'draw_select_selection_size_ratio_one',
            'draw_select_selection_size_ratio_two',
            'draw_select_shadow',
            'draw_select_tilesize_one',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_drill_draw_select(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07DrillDrawSelectProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_DRILL_DRAW_SELECT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_select_hidden_no_dominant',
            'draw_select_visible_with_dominant',
            'draw_select_dx_impact',
            'draw_select_dy_impact',
            'draw_select_position_eruption',
            'draw_select_selection_size_ratio_one',
            'draw_select_selection_size_ratio_two',
            'draw_select_shadow',
            'draw_select_tilesize_one',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
