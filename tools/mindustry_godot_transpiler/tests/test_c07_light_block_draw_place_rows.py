import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LIGHT_BLOCK_STATE = ROOT / 'godot-mindustry/src/game/SourceLightBlockBuildState.gd'
LIGHT_BLOCK_DRAW_PLACE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockDrawPlaceRowsProof.gd'
LIGHT_BLOCK_DRAW_PLACE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LightBlockDrawPlaceRowsProof.tscn'


class C07LightBlockDrawPlaceRowsTests(unittest.TestCase):
    def test_c07_light_block_draw_place_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2439']['godot_owner'], 'SourceLightBlockBuildState.source_light_block_draw_place_state')
        # draw() is live since N2374, but NOTHING modeled
        # the three placement methods: drawPlace() (:48-53,
        # the dash circle at radius * 0.75f in Pal.placing),
        # changePlacementPath() (:55-59, placeRadius2 =
        # pow(radius * 0.7f / tilesize, 2f) * 3 + the
        # Placement.calculateNodes call) and minimapColor()
        # (:61-66, 0 when the tile has no build, else
        # build.color | 0xff). N2439 ports all three as ONE
        # pure-only draw-place pure (no tick wiring -- the
        # placement UI calls drawPlace, the placer calls
        # changePlacementPath, the minimap calls
        # minimapColor; the call sites wait for UI slices).
        # Four new result symbols: the dash call, the
        # placeRadius2 float, the calculateNodes CALL record
        # (the N2396 precedent -- the pure records the call
        # + predicate threshold, it does NOT port the node
        # algorithm) and the minimap color int. The super
        # place call is recorded but NOT a symbol (the N2374
        # super_draw_called / N2396 super_expr precedent).
        self.assertEqual(
            ledger['N2439']['source_symbols'],
            [
                'source_light_block_draw_place_state_result.dash_call',
                'source_light_block_draw_place_state_result.place_radius2',
                'source_light_block_draw_place_state_result.calculate_nodes_call',
                'source_light_block_draw_place_state_result.minimap_color',
            ],
        )
        for name in ledger['N2439']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/power/LightBlock.java')
                self.assertEqual(symbol['godot_owner'], 'SourceLightBlockBuildState.source_light_block_draw_place_state')
        self.assertEqual(ledger['N2439']['runtime_proof'], '/root/C07LightBlockDrawPlaceRowsProof')
        self.assertEqual(
            ledger['N2439']['tests'],
            [
                'test_c07_light_block_draw_place_rows_registration',
                'test_all_c07_light_block_draw_place_rows_input_evidence_is_exact',
                'test_light_block_draw_place_rows_state',
                'test_reference_graph_and_actual_c07_light_block_draw_place_rows',
            ],
        )
        self.assertTrue(ledger['N2439']['deferred_exprs'])
        # This slice RESOLVES the drawPlace /
        # changePlacementPath / minimapColor rows (#96 in
        # the merged advances-26 DEFERRED base): the dash
        # circle math, the placeRadius2 math, the
        # calculateNodes call record and the minimap color
        # fold are all live in the draw-place pure. No new
        # entry is added: the pure is pure-only (no tick
        # wiring to defer), the color config / init /
        # read-write rows stay deferred under their own
        # entries. Net -1+0 = 272.
        self.assertFalse(any(entry.startswith('LightBlock drawPlace / changePlacementPath / minimapColor rows (') for entry in ledger['N2439']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock config / color rows (') for entry in ledger['N2439']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock init rows (') for entry in ledger['N2439']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LightBlock read/write rows (') for entry in ledger['N2439']['deferred_exprs']))
        self.assertEqual(len(ledger['N2439']['deferred_exprs']), 272)

    def test_all_c07_light_block_draw_place_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2439']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceLightBlockBuildState.source_light_block_draw_place_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/power/LightBlock.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/input/Placement.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2439']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_light_block_draw_place_rows_state(self):
        light_block = LIGHT_BLOCK_STATE.read_text(encoding='utf-8')
        # The draw-place rows (LightBlock.drawPlace(),
        # LightBlock.java:48-53; changePlacementPath(),
        # LightBlock.java:55-59; minimapColor(),
        # LightBlock.java:61-66). drawPlace() is
        # super.drawPlace(x, y, rotation, valid) (:50) +
        # the dash circle (`Drawf.dashCircle(x * tilesize +
        # offset, y * tilesize + offset, radius * 0.75f,
        # Pal.placing);`, :52 -- WITH the Block offset,
        # unlike the MassDriver dash circle). offset is the
        # Block offset (`offset = ((size + 1) % 2) *
        # tilesize / 2f;`, Block.java:761 -- 0 for the
        # size-1 LightBlock, `public int size = 1;`,
        # Block.java:215); tilesize is the Java constant 8
        # (`public static final int tilesize = 8;`,
        # Vars.java:135 -- NEVER the game tile_size 32, the
        # N2375 lesson); Pal.placing IS the accent color
        # (`placing = accent,`, Pal.java:95). radius is the
        # class default 200f (`public float radius =
        # 200f;`, LightBlock.java:23), overridden by the
        # illuminator def to 140f (`radius = 140f;`,
        # Blocks.java:6766). changePlacementPath() is the
        # placeRadius2 math (`var placeRadius2 =
        # Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;`,
        # :57) + the calculateNodes call
        # (`Placement.calculateNodes(points, this,
        # rotation, (point, other) -> point.dst2(other) <=
        # placeRadius2);`, :58 -- `public static void
        # calculateNodes(Seq<Point2> points, Block block,
        # int rotation, Boolf2<Point2, Point2>
        # overlapper){`, Placement.java:92). minimapColor()
        # is the null guard (`var build =
        # (LightBuild)tile.build;`, :63) + the fold
        # (`return build == null ? 0 : build.color |
        # 0xff;`, :65 -- the color is `public int color =
        # Pal.accent.rgba();`, LightBlock.java:68). The
        # pure takes explicit params (offset + radius are
        # caller-supplied so the pure stays def-agnostic;
        # build_color is a Variant null-or-int -- null
        # when the tile has no build). Pure-only: no tick
        # wiring. draw() stays untouched (live since
        # N2374). Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails this test).
        self.assertIn('static func source_light_block_draw_place_state', light_block)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', light_block)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', light_block)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, radius * 0.75f, Pal.placing);', light_block)
        self.assertIn('public void changePlacementPath(Seq<Point2> points, int rotation){', light_block)
        self.assertIn('var placeRadius2 = Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;', light_block)
        self.assertIn('Placement.calculateNodes(points, this, rotation, (point, other) -> point.dst2(other) <= placeRadius2);', light_block)
        self.assertIn('public int minimapColor(Tile tile){', light_block)
        self.assertIn('var build = (LightBuild)tile.build;', light_block)
        self.assertIn('return build == null ? 0 : build.color | 0xff;', light_block)
        self.assertIn('public float radius = 200f;', light_block)
        self.assertIn('public int color = Pal.accent.rgba();', light_block)
        self.assertIn('public int size = 1;', light_block)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', light_block)
        self.assertIn('public static final int tilesize = 8;', light_block)
        self.assertIn('placing = accent,', light_block)
        self.assertIn('public static void calculateNodes(Seq<Point2> points, Block block, int rotation, Boolf2<Point2, Point2> overlapper){', light_block)
        self.assertIn('radius = 140f;', light_block)
        # The documented limits record the draw-place rows
        # as live (the draw rows stay live since N2374).
        self.assertIn('DrawPlace rows live (N2439)', light_block)
        self.assertIn('Draw rows live (N2374)', light_block)
        # The proof's keys drive the draw-place pure (the
        # dash circle math, the super call record, the
        # placeRadius2 math, the calculateNodes call
        # record, the minimap null -> 0 fold and the
        # minimap color | 0xff fold). There are no
        # color-config keys: those rows still defer.
        proof = LIGHT_BLOCK_DRAW_PLACE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_place_dash_circle',
            'draw_place_super_recorded',
            'draw_place_radius2_math',
            'draw_place_calculate_nodes',
            'minimap_color_null',
            'minimap_color_or_ff',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceLightBlockBuildState.gd")', proof)
        self.assertTrue(LIGHT_BLOCK_STATE.exists())
        self.assertTrue(LIGHT_BLOCK_DRAW_PLACE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07LightBlockDrawPlaceRowsProof.gd', LIGHT_BLOCK_DRAW_PLACE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_light_block_draw_place_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LightBlockDrawPlaceRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LIGHT_BLOCK_DRAW_PLACE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_place_dash_circle',
            'draw_place_super_recorded',
            'draw_place_radius2_math',
            'draw_place_calculate_nodes',
            'minimap_color_null',
            'minimap_color_or_ff',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
