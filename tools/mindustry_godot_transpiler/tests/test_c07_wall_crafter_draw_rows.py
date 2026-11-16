import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
WALL_CRAFTER_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterDrawRowsProof.gd'
WALL_CRAFTER_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterDrawRowsProof.tscn'


class C07WallCrafterDrawRowsTests(unittest.TestCase):
    def test_c07_wall_crafter_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2426']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_draw_state')
        # The WallCrafter tick is live (N2223 advance +
        # N2264 second consumers + N2273 timerUse +
        # N2283 timerDump + N2301 getEfficiency fill +
        # N2398 offload routing) but NOTHING modeled
        # draw(): the base/top rects + the rotator loop
        # (WallCrafter.java:231-244), icons (:120-122),
        # drawPlanRegion (:125-129), drawPlace (:131-
        # 135). N2426 ports all four areas as ONE
        # pure-only draw pure, the N2396/N2421
        # precedent: draw is never called by the tick,
        # so the pure takes caller-supplied inputs (the
        # frame rotation / totalTime, the facing edge
        # tiles as {cx, cy} positions, the drawPlace
        # efficiency, the plan dict) and returns the
        # draw calls as data. The icons rows ride the
        # draw pure (icons() takes no args and the SSOT
        # schema validator requires non-empty input
        # keys) -- one pure, six new result symbols:
        # the base / top calls, the rotator calls, the
        # plan + place calls, and the icons region
        # list. The getEfficiency scan itself is NOT
        # implemented here (the edge tiles arrive
        # caller-supplied; the live scan is DEFERRED
        # #242, a separate slice).
        self.assertEqual(
            ledger['N2426']['source_symbols'],
            [
                'source_wall_crafter_draw_state_result.base_call',
                'source_wall_crafter_draw_state_result.top_call',
                'source_wall_crafter_draw_state_result.rotator_calls',
                'source_wall_crafter_draw_state_result.plan_call',
                'source_wall_crafter_draw_state_result.place_call',
                'source_wall_crafter_draw_state_result.icon_regions',
            ],
        )
        for name in ledger['N2426']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/WallCrafter.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceWallCrafterBuildState.source_wall_crafter_'))
        self.assertEqual(ledger['N2426']['runtime_proof'], '/root/C07WallCrafterDrawRowsProof')
        self.assertEqual(
            ledger['N2426']['tests'],
            [
                'test_c07_wall_crafter_draw_rows_registration',
                'test_all_c07_wall_crafter_draw_rows_input_evidence_is_exact',
                'test_wall_crafter_draw_rows_state',
                'test_reference_graph_and_actual_c07_wall_crafter_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2426']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #37 (1-based in
        # the merged advances-25 DEFERRED base): the
        # WallCrafter draw / icons / drawPlanRegion /
        # drawPlace entry is REMOVED -- draw, icons,
        # drawPlanRegion and drawPlace are all live
        # now, so nothing of the entry remains. Net
        # 280 - 1 = 279.
        self.assertFalse(any(entry.startswith('WallCrafter draw / icons / drawPlanRegion / drawPlace rows (') for entry in ledger['N2426']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter setBars row (') for entry in ledger['N2426']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter large variant (') for entry in ledger['N2426']['deferred_exprs']))
        self.assertEqual(len(ledger['N2426']['deferred_exprs']), 279)

    def test_all_c07_wall_crafter_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2426']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWallCrafterBuildState.source_wall_crafter_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/graphics/Layer.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2426']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_draw_rows_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The draw rows (WallCrafterBuild.draw(),
        # WallCrafter.java:231-244): `Draw.rect(block.region,
        # x, y);` + `Draw.rect(topRegion, x, y, rotdeg());`
        # (rotdeg() is rotation * 90, BuildingComp.java:
        # 582-584) + the rotator loop over the facing edge
        # tiles: ds 0.6f, dx/dy = d4(rotation) * ds (d4x
        # {1, 0, -1, 0}, d4y {0, 1, 0, -1}, arc Geometry.
        # java:23-24), bs = (rotation 0/3) ? 1 : -1, sign
        # = idx++ >= size/2 && size % 2 == 0 ? -1 : 1
        # (INT size/2 -- a size-2 crafter flips the second
        # rotator, a size-3 never flips), vx/vy = (c - d)
        # * tilesize (tilesize 8, Vars.java:135), z Layer.
        # blockOver (35, Layer.java:42), the rotatorBottom
        # rect at totalTime * rotateSpeed * sign * bs +
        # the unrotated rotator rect at the same vx/vy
        # (the second rect is easy to miss -- the brief
        # flagged it). The cpos callback fires for EVERY
        # edge tile (WallCrafter.java:167-169, before the
        # solid check), so the loop draws size rotators
        # whether or not the tiles are solid. The icons
        # rows (:120-122): `return new TextureRegion[]{region, topRegion};`
        # (`public @Load("@-top") TextureRegion topRegion;`,
        # :28). The drawPlanRegion rows (:125-129): the
        # region rect + the top rect at plan.rotation *
        # 90. The drawPlace rows (:131-135): eff from
        # getEfficiency + drawPlaceText with formatFloat
        # ("bar.drillspeed", 60f / drillTime * eff, 2) --
        # formatFloat renders Strings.fixed (TRUNCATION,
        # arc Strings.java:725+, NOT rounding) into the
        # bundle text "Drill Speed: {0}/s". Neither def
        # overrides draw (Blocks.java:3002-3035 set fields
        # only -- the N2419 drawer check), and WallCrafter
        # has no drawer field at all (it extends Block
        # directly, WallCrafter.java:25). Pure-only: the
        # tick never calls draw (draw is called by the
        # renderer, drawPlanRegion/drawPlace by the UI,
        # icons by the atlas).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_wall_crafter_draw_state', wall_crafter)
        self.assertIn('public float drillTime = 150f;', wall_crafter)
        self.assertIn('public float rotateSpeed = 2f;', wall_crafter)
        self.assertIn('public @Load("@-top") TextureRegion topRegion;', wall_crafter)
        self.assertIn('public @Load("@-rotator-bottom") TextureRegion rotatorBottomRegion;', wall_crafter)
        self.assertIn('public @Load("@-rotator") TextureRegion rotatorRegion;', wall_crafter)
        self.assertIn('public float time, warmup, totalTime, lastEfficiency;', wall_crafter)
        self.assertIn('public TextureRegion[] icons(){', wall_crafter)
        self.assertIn('return new TextureRegion[]{region, topRegion};', wall_crafter)
        self.assertIn('public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){', wall_crafter)
        self.assertIn('Draw.rect(region, plan.drawx(), plan.drawy());', wall_crafter)
        self.assertIn('Draw.rect(topRegion, plan.drawx(), plan.drawy(), plan.rotation * 90);', wall_crafter)
        self.assertIn('public void drawPlace(int x, int y, int rotation, boolean valid){', wall_crafter)
        self.assertIn('float eff = getEfficiency(x, y, rotation, null, null);', wall_crafter)
        self.assertIn('drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / drillTime * eff, 2), x, y, valid);', wall_crafter)
        self.assertIn('public void draw(){', wall_crafter)
        self.assertIn('Draw.rect(block.region, x, y);', wall_crafter)
        self.assertIn('Draw.rect(topRegion, x, y, rotdeg());', wall_crafter)
        self.assertIn('float ds = 0.6f, dx = Geometry.d4x(rotation) * ds, dy = Geometry.d4y(rotation) * ds;', wall_crafter)
        self.assertIn('int bs = (rotation == 0 || rotation == 3) ? 1 : -1;', wall_crafter)
        self.assertIn('idx = 0;', wall_crafter)
        self.assertIn('getEfficiency(tile.x, tile.y, rotation, null, (cx, cy) -> {', wall_crafter)
        self.assertIn('int sign = idx++ >= size/2 && size % 2 == 0 ? -1 : 1;', wall_crafter)
        self.assertIn('float vx = (cx - dx) * tilesize, vy = (cy - dy) * tilesize;', wall_crafter)
        self.assertIn('Draw.z(Layer.blockOver);', wall_crafter)
        self.assertIn('Draw.rect(rotatorBottomRegion, vx, vy, totalTime * rotateSpeed * sign * bs);', wall_crafter)
        self.assertIn('Draw.rect(rotatorRegion, vx, vy);', wall_crafter)
        self.assertIn('public float rotdeg(){', wall_crafter)
        self.assertIn('return rotation * 90;', wall_crafter)
        self.assertIn('public final static int[] d4x = {1, 0, -1, 0};', wall_crafter)
        self.assertIn('public final static int[] d4y = {0, 1, 0, -1};', wall_crafter)
        self.assertIn('public static final int tilesize = 8;', wall_crafter)
        self.assertIn('blockOver = 35,', wall_crafter)
        self.assertIn('bar.drillspeed = Drill Speed: {0}/s', wall_crafter)
        self.assertIn('dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));', wall_crafter)
        self.assertIn('size = 2;', wall_crafter)
        self.assertIn('drillTime = 110f;', wall_crafter)
        # The documented limits record the draw rows as
        # live (the old "No setBars / draw / icons /
        # drawPlanRegion / drawPlace rows" deferral text
        # is gone; setBars stays deferred on its own).
        self.assertIn('Draw rows live (N2426)', wall_crafter)
        self.assertNotIn('No setBars / draw / icons / drawPlanRegion / drawPlace rows', wall_crafter)
        # The proof's keys drive the draw pure (the base
        # / top rects incl. rotdeg, the rotator loop with
        # its sign/bs branches, the drawPlace drillspeed
        # text with the Strings.fixed truncation, the
        # drawPlanRegion rects, the icons region list,
        # and the rotation 0/3 vs 1/2 branch).
        proof = WALL_CRAFTER_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_top',
            'draw_rotator_loop',
            'draw_place_drillspeed',
            'draw_plan_region',
            'draw_icons',
            'draw_rotation_branch',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceWallCrafterBuildState.gd")', proof)
        self.assertTrue(WALL_CRAFTER_STATE.exists())
        self.assertTrue(WALL_CRAFTER_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07WallCrafterDrawRowsProof.gd', WALL_CRAFTER_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_wall_crafter_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_top',
            'draw_rotator_loop',
            'draw_place_drillspeed',
            'draw_plan_region',
            'draw_icons',
            'draw_rotation_branch',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
