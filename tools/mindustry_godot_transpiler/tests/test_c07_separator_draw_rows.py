import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SEPARATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceSeparatorBuildState.gd'
SEPARATOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorDrawRowsProof.gd'
SEPARATOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07SeparatorDrawRowsProof.tscn'


class C07SeparatorDrawRowsTests(unittest.TestCase):
    def test_c07_separator_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2419']['godot_owner'], 'SourceSeparatorBuildState.source_separator_draw_state')
        # The Separator tick is live (N2222 advance +
        # N2402 dump neighbour live fill + N2413 offload
        # hoist) but NOTHING modeled draw(): the drawer
        # rows (Separator.java:104-112 drawer.draw /
        # drawer.drawLight, :71-73 icons, :66-69
        # drawPlanRegion). Verify-first (N2419): the
        # class default drawer is DrawDefault
        # (Separator.java:25), but BOTH defs override it
        # with the SAME DrawMulti (Blocks.java:1246/1266)
        # -- DrawRegion("-bottom"), DrawLiquidTile(),
        # DrawRegion("-spinner", 3, true), DrawDefault()
        # -- so the live draw is the DrawMulti
        # composition, in drawer order. N2419 ports it
        # as TWO pure-only pures (the N2396 MassDriver
        # precedent): the draw pure (the 4 sub-draws +
        # the super.drawLight() liquid light + the icons
        # folded in as icon_regions) and the plan pure
        # (the drawPlanRegion rows). Ten new result
        # symbols: the bottom / liquid / spinner / base
        # calls + the light call + the icon regions, and
        # the plan bottom / spinner / main / team calls.
        self.assertEqual(
            ledger['N2419']['source_symbols'],
            [
                'source_separator_draw_state_result.bottom_call',
                'source_separator_draw_state_result.liquid_call',
                'source_separator_draw_state_result.spinner_call',
                'source_separator_draw_state_result.base_call',
                'source_separator_draw_state_result.draw_light_call',
                'source_separator_draw_state_result.icon_regions',
                'source_separator_draw_plan_state_result.plan_bottom_call',
                'source_separator_draw_plan_state_result.plan_spinner_call',
                'source_separator_draw_plan_state_result.plan_call',
                'source_separator_draw_plan_state_result.plan_team_call',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/world/draw/DrawDefault.java',
            'core/src/mindustry/world/draw/DrawMulti.java',
            'core/src/mindustry/world/draw/DrawRegion.java',
            'core/src/mindustry/world/draw/DrawLiquidTile.java',
            'core/src/mindustry/world/draw/DrawBlock.java',
            'core/src/mindustry/world/blocks/liquid/LiquidBlock.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Liquids.java',
            'core/src/mindustry/Vars.java',
        }
        for name in ledger['N2419']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertTrue(symbol['godot_owner'].startswith('SourceSeparatorBuildState.source_separator_'))
        self.assertEqual(ledger['N2419']['runtime_proof'], '/root/C07SeparatorDrawRowsProof')
        self.assertEqual(
            ledger['N2419']['tests'],
            [
                'test_c07_separator_draw_rows_registration',
                'test_all_c07_separator_draw_rows_input_evidence_is_exact',
                'test_separator_draw_rows_state',
                'test_reference_graph_and_actual_c07_separator_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2419']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #36 (1-based in
        # DEFERRED-after-advances-24.py): the Separator
        # draw / drawLight / icons / drawPlanRegion rows
        # entry is REMOVED -- draw() / drawLight() /
        # icons() / drawPlanRegion() are live now, so
        # nothing of the entry remains. Net 286 - 1 = 285.
        self.assertFalse(any(entry.startswith('Separator draw / drawLight / icons / drawPlanRegion rows') for entry in ledger['N2419']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator read/write rows (progress / warmup / seed, Separator.java:180-194)') for entry in ledger['N2419']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Separator disassembler variant (disassembler, consumePower 4f, Blocks.java:1262') for entry in ledger['N2419']['deferred_exprs']))
        self.assertEqual(len(ledger['N2419']['deferred_exprs']), 285)

    def test_all_c07_separator_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2419']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceSeparatorBuildState.source_separator_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/world/draw/DrawDefault.java',
            'core/src/mindustry/world/draw/DrawMulti.java',
            'core/src/mindustry/world/draw/DrawRegion.java',
            'core/src/mindustry/world/draw/DrawLiquidTile.java',
            'core/src/mindustry/world/draw/DrawBlock.java',
            'core/src/mindustry/world/blocks/liquid/LiquidBlock.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Liquids.java',
            'core/src/mindustry/Vars.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The lerpDelta / mod formulas live in Arc, not
        # Mindustry: Mathf.java under arc-upstream (the
        # N2191 / N2373 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2419']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_separator_draw_rows_state(self):
        separator = SEPARATOR_STATE.read_text(encoding='utf-8')
        # The draw rows (SeparatorBuild.draw(),
        # Separator.java:104-106, `drawer.draw(this);`;
        # drawLight(), :109-112, `super.drawLight();` +
        # `drawer.drawLight(this);`; icons(), :71-73,
        # `return drawer.finalIcons(this);`;
        # drawPlanRegion(), :66-69,
        # `drawer.drawPlan(this, plan, list);`) run the
        # DrawMulti def drawer (Blocks.java:1246/1266),
        # in order: DrawRegion("-bottom") rects its
        # region at (x, y) with rotation 0 (rotateSpeed
        # 0); DrawLiquidTile() tiles the current liquid
        # over size*size tiles at amount / capacity;
        # DrawRegion("-spinner", 3, true) spinSprites at
        # totalProgress * 3 mod 90; DrawDefault rects
        # block.region at drawrot() = 0 (Separator sets
        # no rotate). The drawer adds no light (no
        # member overrides drawLight); the super light
        # is the BuildingComp liquid light (radius
        # size * 30, opacity lightColor.a * visualLiquid,
        # visualLiquid lerping toward 1 / 0 at 0.06).
        # The icons are the DrawMulti concat in drawer
        # order: "-bottom", "-spinner", block.region
        # (DrawLiquidTile contributes nothing). The plan
        # draws the bottom rect + the spinner spin at 0
        # + the fullIcon rect + the team overlay when
        # the world-context gate passes.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_separator_draw_state', separator)
        self.assertIn('static func source_separator_draw_plan_state', separator)
        self.assertIn('public DrawBlock drawer = new DrawDefault();', separator)
        self.assertIn('drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawLiquidTile(), new DrawRegion("-spinner", 3, true), new DrawDefault());', separator)
        self.assertIn('drawer.draw(this);', separator)
        self.assertIn('drawer.drawLight(this);', separator)
        self.assertIn('return drawer.finalIcons(this);', separator)
        self.assertIn('drawer.drawPlan(this, plan, list);', separator)
        self.assertIn('for(var draw : drawers){', separator)
        self.assertIn('result.addAll(draw.icons(block));', separator)
        self.assertIn('Draw.rect(build.block.region, build.x, build.y, build.drawrot());', separator)
        self.assertIn('block.drawDefaultPlanRegion(plan, list);', separator)
        self.assertIn('return new TextureRegion[]{block.region};', separator)
        self.assertIn('Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));', separator)
        self.assertIn('Drawf.spinSprite(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));', separator)
        self.assertIn('Draw.rect(region, plan.drawx()+ x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));', separator)
        self.assertIn('Drawf.spinSprite(region, plan.drawx() + x, plan.drawy() + y, (buildingRotate ? plan.rotation * 90f : 0 + rotation));', separator)
        self.assertIn('return new TextureRegion[]{region};', separator)
        self.assertIn('region = Core.atlas.find(name != null ? name : block.name + suffix);', separator)
        self.assertIn('Liquid drawn = drawLiquid != null ? drawLiquid : build.liquids.current();', separator)
        self.assertIn('LiquidBlock.drawTiledFrames(build.block.size, build.x, build.y, padLeft, padRight, padTop, padBottom, drawn, build.liquids.get(drawn) / build.block.liquidCapacity * alpha);', separator)
        self.assertIn('if(iconOverride != null){', separator)
        self.assertIn('return new TextureRegion[]{};', separator)
        self.assertIn('return block.rotate && block.rotateDraw ? rotation * 90 : 0f;', separator)
        self.assertIn('Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;', separator)
        self.assertIn('if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){', separator)
        self.assertIn('visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);', separator)
        self.assertIn('if(amount > 0.01f){', separator)
        self.assertIn('Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);', separator)
        self.assertIn('public boolean rotate;', separator)
        self.assertIn('public boolean drawLiquidLight = true;', separator)
        self.assertIn('TextureRegion reg = getPlanRegion(plan, list);', separator)
        self.assertIn('Draw.rect(reg, plan.drawx(), plan.drawy(), !rotate || !rotateDraw ? 0 : plan.rotation * 90);', separator)
        self.assertIn('if(plan.worldContext && player != null && teamRegion != null && teamRegion.found()){', separator)
        self.assertIn('if(teamRegions[player.team().id] == teamRegion) Draw.color(player.team().color, a);', separator)
        self.assertIn('Draw.rect(teamRegions[player.team().id], plan.drawx(), plan.drawy());', separator)
        self.assertIn('return fullIcon;', separator)
        self.assertIn('TextureRegion region = renderer.fluidFrames[liquid.gas ? 1 : 0][liquid.getAnimationFrame()];', separator)
        self.assertIn('float leftBounds = size/2f * tilesize - padRight;', separator)
        self.assertIn('Drawf.liquid(toDraw, x + rightBorder + ox, y + topBorder + oy, alpha, color);', separator)
        self.assertIn('Color color = Tmp.c1.set(liquid.color).a(1f);', separator)
        self.assertIn('r = Mathf.mod(r, 90f);', separator)
        self.assertIn('Draw.rect(region, x, y, r);', separator)
        self.assertIn('Draw.alpha(r / 90f*a);', separator)
        self.assertIn('Draw.rect(region, x, y, r - 90f);', separator)
        self.assertIn('if(alpha < 1f/255f) return;', separator)
        self.assertIn('public static final int tilesize = 8;', separator)
        self.assertIn('lightColor = Color.valueOf("f0511d").a(0.4f);', separator)
        self.assertIn('return lerp(fromValue, toValue, clamp(progress * Time.delta));', separator)
        self.assertIn('return ((f % n) + n) % n;', separator)
        # The documented limits record the draw rows as
        # live (the old "No draw / drawLight / icons /
        # drawPlanRegion / read-write / shouldAmbientSound
        # rows" text is gone -- read/write + shouldAmbientSound
        # still defer, draw does not).
        self.assertIn('Draw rows live (N2419)', separator)
        self.assertNotIn('No draw / drawLight / icons / drawPlanRegion / read-write / shouldAmbientSound rows', separator)
        # The proof's keys drive the draw pures (the
        # bottom rect, the liquid tiles + alpha gate,
        # the spinner mod-90 rotation + second rect,
        # the base rect at drawrot 0, the light call +
        # the visual lerp, the icon regions, the plan
        # rects + the team overlay gate).
        proof = SEPARATOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_bottom',
            'draw_liquid',
            'draw_spinner',
            'draw_base',
            'draw_light',
            'draw_light_visual',
            'draw_icons',
            'draw_plan_region',
            'draw_plan_team',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceSeparatorBuildState.gd")', proof)
        self.assertTrue(SEPARATOR_STATE.exists())
        self.assertTrue(SEPARATOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07SeparatorDrawRowsProof.gd', SEPARATOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_separator_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07SeparatorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SEPARATOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_bottom',
            'draw_liquid',
            'draw_spinner',
            'draw_base',
            'draw_light',
            'draw_light_visual',
            'draw_icons',
            'draw_plan_region',
            'draw_plan_team',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
