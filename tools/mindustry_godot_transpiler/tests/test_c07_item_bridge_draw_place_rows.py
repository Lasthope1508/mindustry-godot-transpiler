import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ITEM_BRIDGE_STATE = ROOT / 'godot-mindustry/src/game/SourceItemBridgeBuildState.gd'
ITEM_BRIDGE_DRAW_PLACE_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDrawPlaceRowsProof.gd'
ITEM_BRIDGE_DRAW_PLACE_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ItemBridgeDrawPlaceRowsProof.tscn'


class C07ItemBridgeDrawPlaceRowsTests(unittest.TestCase):
    def test_c07_item_bridge_draw_place_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2456']['godot_owner'], 'SourceItemBridgeBuildState.source_item_bridge_draw_place_state')
        # The ItemBridge draw family is live (N2429:
        # draw / drawSelect / drawInput /
        # drawConfigure) but NOTHING modeled the
        # placement preview: drawPlace
        # (ItemBridge.java:118-142) dashes the four
        # range lines and, when findLink finds a
        # would-be link more than one tile away,
        # rects the span + arrows the link tile; and
        # drawPlanConfigTop (:82-96) draws the
        # configured bridge to the planned partner
        # through drawBridge (:98-115). N2456 ports
        # both as TWO pure-only pures, the N2429
        # precedent: draw is never called by the
        # tick, so the pures take caller-supplied
        # inputs (the find_link output as a {x, y}
        # link Dict or null -- findLink itself is
        # already live since N2199, :830, and is NOT
        # ported again -- the plan config + the
        # findPlan result + Renderer.bridgeOpacity)
        # and return the draw calls as data. Two
        # pures, four new result symbols: the draw
        # place dash calls, the link rect, the link
        # arrow, and the plan bridge call.
        self.assertEqual(
            ledger['N2456']['source_symbols'],
            [
                'source_item_bridge_draw_place_state_result.dash_calls',
                'source_item_bridge_draw_place_state_result.link_rect',
                'source_item_bridge_draw_place_state_result.arrow_call',
                'source_item_bridge_draw_plan_config_top_state_result.bridge_call',
            ],
        )
        for name in ledger['N2456']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/ItemBridge.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceItemBridgeBuildState.source_item_bridge_'))
        self.assertEqual(ledger['N2456']['runtime_proof'], '/root/C07ItemBridgeDrawPlaceRowsProof')
        self.assertEqual(
            ledger['N2456']['tests'],
            [
                'test_c07_item_bridge_draw_place_rows_registration',
                'test_all_c07_item_bridge_draw_place_rows_input_evidence_is_exact',
                'test_item_bridge_draw_place_rows_state',
                'test_reference_graph_and_actual_c07_item_bridge_draw_place_rows',
            ],
        )
        self.assertTrue(ledger['N2456']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #93 (1-based
        # in the merged advances-29 DEFERRED base,
        # 253 entries): "ItemBridge drawPlace /
        # drawPlanConfigTop link preview
        # (ItemBridge.java:118-142, :82-96; findLink
        # at :121)". Net 253 - 1 = 252.
        self.assertFalse(any(entry.startswith('ItemBridge drawPlace / drawPlanConfigTop link preview (') for entry in ledger['N2456']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge handlePlacementLine (') for entry in ledger['N2456']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge per-def stat rows (') for entry in ledger['N2456']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ItemBridge config() getter / rebuild rows (') for entry in ledger['N2456']['deferred_exprs']))
        self.assertEqual(len(ledger['N2456']['deferred_exprs']), 252)

    def test_all_c07_item_bridge_draw_place_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2456']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_item_bridge_draw_place_state_result.dash_calls': 'SourceItemBridgeBuildState.source_item_bridge_draw_place_state',
                    'source_item_bridge_draw_place_state_result.link_rect': 'SourceItemBridgeBuildState.source_item_bridge_draw_place_state',
                    'source_item_bridge_draw_place_state_result.arrow_call': 'SourceItemBridgeBuildState.source_item_bridge_draw_place_state',
                    'source_item_bridge_draw_plan_config_top_state_result.bridge_call': 'SourceItemBridgeBuildState.source_item_bridge_draw_plan_config_top_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/ItemBridge.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/units/BuildPlan.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The d4 table / zero epsilon / angle
        # formula / setLength zero-vector rule live
        # in Arc, not Mindustry: Geometry.java /
        # Mathf.java / Angles.java / Vec2.java under
        # arc-upstream (the N2191 precedent).
        upstream['arc-core/src/arc/math/geom/Geometry.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Geometry.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Angles.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Angles.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/geom/Vec2.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/geom/Vec2.java').read_text(encoding='utf-8')
        for expr in ledger['N2456']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_item_bridge_draw_place_rows_state(self):
        item_bridge = ITEM_BRIDGE_STATE.read_text(encoding='utf-8')
        # The draw-place rows (ItemBridge.drawPlace(),
        # ItemBridge.java:118-142; drawPlanConfigTop(),
        # :82-96; drawBridge(), :98-115). drawPlace
        # records super.drawPlace (Block.drawPlace is
        # NOT modeled here, the N2374 precedent) +
        # `Tile link = findLink(x, y);` (findLink is
        # already live since N2199 -- the pure takes
        # its output caller-supplied, it does NOT
        # port findLink again) + the 4 dash lines
        # (`Drawf.dashLine(Pal.placing, ...)` in
        # Geometry.d4 order i = 0..3, from
        # tilesize/2f + 2 out to range * tilesize,
        # segments (int)(max span / tilesize * 2)
        # per the Drawf 4-arg overload) + `Draw.
        # reset();` + `Draw.color(Pal.placing);`
        # (Pal.placing IS the accent color,
        # `placing = accent,`, Pal.java:95) +
        # `Lines.stroke(1f);` + the link gate (`if(
        # link != null && Math.abs(link.x - x) +
        # Math.abs(link.y - y) > 1){` -- adjacent
        # links draw no rect/arrow) + `int rot =
        # link.absoluteRelativeTo(x, y);` (called ON
        # the link tile with the placement coords --
        # an EAST link has rot 2, the placement tile
        # is west of it) + the w/h span formulas +
        # `Lines.rect(...)` + the "bridge-arrow"
        # rect at the link tile offset by d4(rot),
        # rotation rot * 90. drawPlanConfigTop
        # gates on the Point2 config (`Math.abs(p.x)
        # <= range && Math.abs(p.y) <= range && (p.x
        # == 0 || p.y == 0)`) + `findPlan(list,
        # currentFindX, currentFindY, planFinder)`
        # (the caller supplies the findPlan result
        # as other_req, the N2429 caller-supplied
        # precedent) + `drawBridge(plan, otherReq.
        # drawx(), otherReq.drawy(), 0);`.
        # drawBridge guards `Mathf.zero(Renderer.
        # bridgeOpacity)` (|value| <= 1e-6,
        # FLOAT_ROUNDING_ERROR, Mathf.java:522-524,
        # arc) + `Draw.alpha(Renderer.bridgeOpacity)
        # ;` + `Lines.stroke(bridgeWidth);` + the
        # v1 offset (`Tmp.v1.set(ox, oy).sub(req.
        # drawx(), req.drawy()).setLength(tilesize/
        # 2f);` -- a zero vector STAYS zero,
        # Vec2.setLength2, arc) + the bridgeRegion
        # line from req+v1 to o-v1 + the arrowRegion
        # rect at the midpoint with `Angles.angle(
        # req.drawx(), req.drawy(), ox, oy) + flip`
        # (flip 0 here; Angles.angle is atan2(dy,
        # dx) degrees normalized to [0, 360),
        # Angles.java:56-60, arc, through the shared
        # source_angles_angle helper). The req draw
        # pos is plan * tilesize (BuildPlan.drawx()
        # adds the Block offset, which is 0 for the
        # size-1 bridge, Block.java:761). Pure-only:
        # the tick never calls drawPlace /
        # drawPlanConfigTop -- the placement UI
        # calls them, and the call sites wait for UI
        # slices. Keep each Java expr on ONE comment
        # line (the N2148 lesson: a split line
        # fails this test).
        self.assertIn('static func source_item_bridge_draw_place_state', item_bridge)
        self.assertIn('static func source_item_bridge_draw_plan_config_top_state', item_bridge)
        self.assertIn('public int range;', item_bridge)
        self.assertIn('public @Load("@-bridge") TextureRegion bridgeRegion;', item_bridge)
        self.assertIn('public @Load("@-arrow") TextureRegion arrowRegion;', item_bridge)
        self.assertIn('public float bridgeWidth = 6.5f;', item_bridge)
        self.assertIn('public void drawPlanConfigTop(BuildPlan plan, Eachable<BuildPlan> list){', item_bridge)
        self.assertIn('if(plan.config instanceof Point2 p && (Math.abs(p.x) <= range && Math.abs(p.y) <= range && (p.x == 0 || p.y == 0))){', item_bridge)
        self.assertIn('currentFindX = plan.x + p.x;', item_bridge)
        self.assertIn('currentFindY = plan.y + p.y;', item_bridge)
        self.assertIn('var otherReq = findPlan(list, currentFindX, currentFindY, planFinder);', item_bridge)
        self.assertIn('if(otherReq != null){', item_bridge)
        self.assertIn('drawBridge(plan, otherReq.drawx(), otherReq.drawy(), 0);', item_bridge)
        self.assertIn('public void drawBridge(BuildPlan req, float ox, float oy, float flip){', item_bridge)
        self.assertIn('if(Mathf.zero(Renderer.bridgeOpacity)) return;', item_bridge)
        self.assertIn('Draw.alpha(Renderer.bridgeOpacity);', item_bridge)
        self.assertIn('Lines.stroke(bridgeWidth);', item_bridge)
        self.assertIn('Tmp.v1.set(ox, oy).sub(req.drawx(), req.drawy()).setLength(tilesize/2f);', item_bridge)
        self.assertIn('Lines.line(', item_bridge)
        self.assertIn('bridgeRegion,', item_bridge)
        self.assertIn('req.drawx() + Tmp.v1.x,', item_bridge)
        self.assertIn('req.drawy() + Tmp.v1.y,', item_bridge)
        self.assertIn('ox - Tmp.v1.x,', item_bridge)
        self.assertIn('oy - Tmp.v1.y, false', item_bridge)
        self.assertIn('Draw.rect(arrowRegion, (req.drawx() + ox) / 2f, (req.drawy() + oy) / 2f,', item_bridge)
        self.assertIn('Angles.angle(req.drawx(), req.drawy(), ox, oy) + flip);', item_bridge)
        self.assertIn('Draw.reset();', item_bridge)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', item_bridge)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', item_bridge)
        self.assertIn('Tile link = findLink(x, y);', item_bridge)
        self.assertIn('for(int i = 0; i < 4; i++){', item_bridge)
        self.assertIn('Drawf.dashLine(Pal.placing,', item_bridge)
        self.assertIn('x * tilesize + Geometry.d4[i].x * (tilesize / 2f + 2),', item_bridge)
        self.assertIn('y * tilesize + Geometry.d4[i].y * (tilesize / 2f + 2),', item_bridge)
        self.assertIn('x * tilesize + Geometry.d4[i].x * (range) * tilesize,', item_bridge)
        self.assertIn('y * tilesize + Geometry.d4[i].y * (range) * tilesize);', item_bridge)
        self.assertIn('Draw.color(Pal.placing);', item_bridge)
        self.assertIn('Lines.stroke(1f);', item_bridge)
        self.assertIn('if(link != null && Math.abs(link.x - x) + Math.abs(link.y - y) > 1){', item_bridge)
        self.assertIn('int rot = link.absoluteRelativeTo(x, y);', item_bridge)
        self.assertIn('float w = (link.x == x ? tilesize : Math.abs(link.x - x) * tilesize - tilesize);', item_bridge)
        self.assertIn('float h = (link.y == y ? tilesize : Math.abs(link.y - y) * tilesize - tilesize);', item_bridge)
        self.assertIn('Lines.rect((x + link.x) / 2f * tilesize - w / 2f, (y + link.y) / 2f * tilesize - h / 2f, w, h);', item_bridge)
        self.assertIn('Draw.rect("bridge-arrow", link.x * tilesize + Geometry.d4(rot).x * tilesize, link.y * tilesize + Geometry.d4(rot).y * tilesize, link.absoluteRelativeTo(x, y) * 90);', item_bridge)
        self.assertIn('public Tile findLink(int x, int y){', item_bridge)
        self.assertIn('public byte absoluteRelativeTo(int cx, int cy){', item_bridge)
        self.assertIn('public static BuildPlan findPlan(Eachable<BuildPlan> list, int x, int y, Boolf<BuildPlan> predicate){', item_bridge)
        self.assertIn('offset = ((size + 1) % 2) * tilesize / 2f;', item_bridge)
        self.assertIn('return x*tilesize + (block == null ? 0 : block.offset);', item_bridge)
        self.assertIn('return y*tilesize + (block == null ? 0 : block.offset);', item_bridge)
        self.assertIn('public static void dashLine(Color color, float x, float y, float x2, float y2){', item_bridge)
        self.assertIn('dashLine(color, x, y, x2, y2, (int)(Math.max(Math.abs(x - x2), Math.abs(y - y2)) / tilesize * 2));', item_bridge)
        self.assertIn('placing = accent,', item_bridge)
        self.assertIn('public static final int tilesize = 8;', item_bridge)
        self.assertIn('range = 12;', item_bridge)
        self.assertIn('public final static Point2[] d4 = {', item_bridge)
        self.assertIn('public final static int[] d4x = {1, 0, -1, 0};', item_bridge)
        self.assertIn('public final static int[] d4y = {0, 1, 0, -1};', item_bridge)
        self.assertIn('return d4[Mathf.mod(i, 4)];', item_bridge)
        self.assertIn('public static final float FLOAT_ROUNDING_ERROR = 0.000001f; // 32 bits', item_bridge)
        self.assertIn('return Math.abs(value) <= FLOAT_ROUNDING_ERROR;', item_bridge)
        self.assertIn('float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;', item_bridge)
        self.assertIn('if(ang < 0) ang += 360f;', item_bridge)
        self.assertIn('return (oldLen2 == 0 || oldLen2 == len2) ? this : scl((float)Math.sqrt(len2 / oldLen2));', item_bridge)
        # The d4 VALUES (Geometry.java:10-14, arc)
        # pin the dash order: 0 east, 1 north, 2
        # west, 3 south -- the comment "starting at
        # the left" is wrong, the values win.
        self.assertIn('new Point2(1, 0),', item_bridge)
        self.assertIn('new Point2(0, 1),', item_bridge)
        self.assertIn('new Point2(-1, 0),', item_bridge)
        self.assertIn('new Point2(0, -1)', item_bridge)
        # The documented limits record the draw-place
        # rows as live.
        self.assertIn('DrawPlace rows live (N2456)', item_bridge)
        # The proof's keys drive the two pures (the
        # 4 dash lines in d4 order with their
        # segments, the link rect gate incl. the
        # adjacent-link exclusion, the rect values
        # incl. the rot convention + the diagonal
        # degenerate rect, the bridge-arrow call,
        # the valid plan bridge incl. the v1
        # geometry + the Angles.angle arrow, and the
        # invalid plan bridge incl. the three
        # skipped reasons + the zero epsilon).
        proof = ITEM_BRIDGE_DRAW_PLACE_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'dash_calls',
            'link_rect_gate',
            'link_rect_values',
            'arrow_call',
            'plan_bridge_valid',
            'plan_bridge_invalid',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceItemBridgeBuildState.gd")', proof)
        self.assertTrue(ITEM_BRIDGE_STATE.exists())
        self.assertTrue(ITEM_BRIDGE_DRAW_PLACE_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ItemBridgeDrawPlaceRowsProof.gd', ITEM_BRIDGE_DRAW_PLACE_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_item_bridge_draw_place_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ItemBridgeDrawPlaceRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ITEM_BRIDGE_DRAW_PLACE_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'dash_calls',
            'link_rect_gate',
            'link_rect_values',
            'arrow_call',
            'plan_bridge_valid',
            'plan_bridge_invalid',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
