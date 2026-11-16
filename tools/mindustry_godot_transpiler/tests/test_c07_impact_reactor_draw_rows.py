import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
IMPACT_REACTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceImpactReactorBuildState.gd'
IMPACT_REACTOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorDrawRowsProof.gd'
IMPACT_REACTOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ImpactReactorDrawRowsProof.tscn'


class C07ImpactReactorDrawRowsTests(unittest.TestCase):
    def test_c07_impact_reactor_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2430']['godot_owner'], 'SourceImpactReactorBuildState.source_impact_reactor_draw_state')
        # The ImpactReactor tick is live (N2192 advance +
        # N2254 liquid row + N2266 item row / timer +
        # N2391 sense / warmup) but NOTHING modeled
        # draw(): GeneratorBuild.draw() is
        # drawer.draw(this) (PowerGenerator.java:99-100)
        # through the DrawMulti class-default drawer
        # (ImpactReactor.java:34) -- and verify-first
        # (N2430) confirms the single impact-reactor def
        # does NOT override it (Blocks.java:2632-2645
        # carries no drawer line, unlike the Separator
        # N2419 lesson where BOTH defs overrode the
        # class default). N2430 ports the drawer as ONE
        # pure-only draw pure, the N2419/N2421
        # precedent: draw is never called by the tick,
        # so the pure takes caller-supplied inputs (the
        # building pos, warmup, totalProgress, Time.time
        # as time_value, the four plasma atlas sizes,
        # the cryofluid light inputs, the previous
        # visualLiquid, source_delta, the block size)
        # and returns the draw calls as data. Five new
        # result symbols: the bottom / plasma / base
        # calls, the light call (the DrawPlasma light
        # AND the super liquid light, both halves of
        # GeneratorBuild.drawLight, PowerGenerator.java:
        # 145-148), and the icon regions folded in
        # (icons() takes no args and the SSOT schema
        # validator requires non-empty input keys).
        self.assertEqual(
            ledger['N2430']['source_symbols'],
            [
                'source_impact_reactor_draw_state_result.bottom_call',
                'source_impact_reactor_draw_state_result.plasma_call',
                'source_impact_reactor_draw_state_result.base_call',
                'source_impact_reactor_draw_state_result.light_call',
                'source_impact_reactor_draw_state_result.icon_regions',
            ],
        )
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/world/draw/DrawMulti.java',
            'core/src/mindustry/world/draw/DrawRegion.java',
            'core/src/mindustry/world/draw/DrawPlasma.java',
            'core/src/mindustry/world/draw/DrawDefault.java',
            'core/src/mindustry/world/draw/DrawBlock.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Liquids.java',
        }
        for name in ledger['N2430']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], slice_sources)
                self.assertTrue(symbol['godot_owner'].startswith('SourceImpactReactorBuildState.source_impact_reactor_'))
        self.assertEqual(ledger['N2430']['runtime_proof'], '/root/C07ImpactReactorDrawRowsProof')
        self.assertEqual(
            ledger['N2430']['tests'],
            [
                'test_c07_impact_reactor_draw_rows_registration',
                'test_all_c07_impact_reactor_draw_rows_input_evidence_is_exact',
                'test_impact_reactor_draw_rows_state',
                'test_reference_graph_and_actual_c07_impact_reactor_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2430']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #86 (1-based in
        # the merged advances-25 DEFERRED base): the
        # ImpactReactor draw rows entry is REMOVED --
        # draw, drawLight and icons are all live now.
        # It ADDS one new deferral: the drawPlan rows
        # (DrawRegion plan rect / DrawDefault plan ->
        # block.drawDefaultPlanRegion), which wait for
        # their own slice under the N2419 separate
        # plan-pure precedent. Net 280 - 1 + 1 = 280.
        self.assertFalse(any(entry.startswith('ImpactReactor draw rows (DrawMulti / DrawPlasma drawer') for entry in ledger['N2430']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor drawPlan rows (') for entry in ledger['N2430']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor power-production rows (') for entry in ledger['N2430']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ImpactReactor per-def stat rows (') for entry in ledger['N2430']['deferred_exprs']))
        self.assertEqual(len(ledger['N2430']['deferred_exprs']), 280)

    def test_all_c07_impact_reactor_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2430']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceImpactReactorBuildState.source_impact_reactor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/power/ImpactReactor.java',
            'core/src/mindustry/world/blocks/power/PowerGenerator.java',
            'core/src/mindustry/world/draw/DrawMulti.java',
            'core/src/mindustry/world/draw/DrawRegion.java',
            'core/src/mindustry/world/draw/DrawPlasma.java',
            'core/src/mindustry/world/draw/DrawDefault.java',
            'core/src/mindustry/world/draw/DrawBlock.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/content/Liquids.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2430']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_impact_reactor_draw_rows_state(self):
        impact_reactor = IMPACT_REACTOR_STATE.read_text(encoding='utf-8')
        # The draw rows (GeneratorBuild.draw(),
        # PowerGenerator.java:99-100, `drawer.draw(this);`,
        # through the DrawMulti class-default drawer,
        # ImpactReactor.java:34 -- the single def does
        # NOT override it, Blocks.java:2632-2645): (1)
        # DrawRegion("-bottom") -- the plain region rect
        # at rotation 0 (rotateSpeed 0, rotation 0,
        # buildingRotate false, DrawRegion.java:51),
        # region impact-reactor-bottom
        # (DrawRegion.java:74, block.name + suffix);
        # (2) DrawPlasma() -- the four additive plasma
        # rects (DrawPlasma.java:36-47): r from the
        # caller-supplied atlas size (width * scl - 3
        # + absin), the plasma1 -> plasma2 color lerp
        # at i / 4, alpha (0.3 + absin) * warmup,
        # rotation totalProgress * (12 + i * 6); NO
        # RNG in the pure -- DrawPlasma.draw rolls
        # nothing (the parent DrawFlame.draw uses
        # Mathf.random, but DrawPlasma overrides draw
        # fully so the parent flame never runs); the
        # absin calls land Java-exact through the
        # shared helper at the DOUBLED scale (Java
        # absin is (sin(in, scl * 2f, mag) + mag) / 2f,
        # arc Mathf.java:78-80, while the helper is
        # (sin(value / scl) * 0.5 + 0.5) * mag, so
        # helper(v, s) == Java absin(v, s / 2f)); (3)
        # DrawDefault -- the base region rect at
        # drawrot() = 0 (ImpactReactor sets no rotate,
        # Block.java:120, default false). The light
        # (GeneratorBuild.drawLight(),
        # PowerGenerator.java:145-148) is super +
        # drawer: the DrawPlasma light (DrawPlasma.java:
        # 32, radius (110 + absin(5, 5)) * warmup,
        # color plasma2 lerp plasma1 at absin(7, 0.2),
        # alpha 0.8 * warmup) AND the super liquid
        # light (BuildingComp.java:1309-1317, cryofluid
        # lightColor alpha 0.2, radius size * 30).
        # lightRadius 115f feeds ONLY Block.
        # drawEnvironmentLight for unbuilt tiles
        # (BlockRenderer.java:842-844), never the
        # placed reactor's light. The icons ride the
        # draw pure (PowerGenerator.java:54-56,
        # drawer.finalIcons -- DrawPlasma contributes
        # nothing, the base icons() returns empty).
        # Pure-only: the tick never calls draw --
        # draw/drawLight are called by the renderer,
        # icons by the atlas. Keep each Java expr on
        # ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_impact_reactor_draw_state', impact_reactor)
        self.assertIn('drawer = new DrawMulti(new DrawRegion("-bottom"), new DrawPlasma(), new DrawDefault());', impact_reactor)
        self.assertIn('public DrawBlock drawer = new DrawDefault();', impact_reactor)
        self.assertIn('impactReactor = new ImpactReactor("impact-reactor"){{', impact_reactor)
        self.assertIn('drawer.draw(this);', impact_reactor)
        self.assertIn('super.drawLight();', impact_reactor)
        self.assertIn('drawer.drawLight(this);', impact_reactor)
        self.assertIn('for(var draw : drawers){', impact_reactor)
        self.assertIn('draw.draw(build);', impact_reactor)
        self.assertIn('draw.drawLight(build);', impact_reactor)
        self.assertIn('result.addAll(draw.icons(block));', impact_reactor)
        self.assertIn('return drawer.finalIcons(this);', impact_reactor)
        self.assertIn('return new TextureRegion[]{region};', impact_reactor)
        self.assertIn('return new TextureRegion[]{block.region};', impact_reactor)
        self.assertIn('region = Core.atlas.find(name != null ? name : block.name + suffix);', impact_reactor)
        self.assertIn('Draw.rect(region, build.x + x, build.y + y, build.totalProgress() * rotateSpeed + rotation + (buildingRotate ? build.rotdeg() : 0));', impact_reactor)
        self.assertIn('public String suffix = "-plasma-";', impact_reactor)
        self.assertIn('public int plasmas = 4;', impact_reactor)
        self.assertIn('public Color plasma1 = Color.valueOf("ffd06b"), plasma2 = Color.valueOf("ff361b");', impact_reactor)
        self.assertIn('regions[i] = Core.atlas.find(block.name + suffix + i);', impact_reactor)
        self.assertIn('Draw.blend(Blending.additive);', impact_reactor)
        self.assertIn('float r = ((float)regions[i].width * regions[i].scl() - 3f + Mathf.absin(Time.time, 2f + i * 1f, 5f - i * 0.5f));', impact_reactor)
        self.assertIn('Draw.color(plasma1, plasma2, (float)i / regions.length);', impact_reactor)
        self.assertIn('Draw.alpha((0.3f + Mathf.absin(Time.time, 2f + i * 2f, 0.3f + i * 0.05f)) * build.warmup());', impact_reactor)
        self.assertIn('Draw.rect(regions[i], build.x + x, build.y + y, r, r, build.totalProgress() * (12 + i * 6f));', impact_reactor)
        self.assertIn('Drawf.light(build.x, build.y, (110f + Mathf.absin(5, 5f)) * build.warmup(), Tmp.c1.set(plasma2).lerp(plasma1, Mathf.absin(7f, 0.2f)), 0.8f * build.warmup());', impact_reactor)
        self.assertIn('Draw.rect(build.block.region, build.x, build.y, build.drawrot());', impact_reactor)
        self.assertIn('return block.rotate && block.rotateDraw ? rotation * 90 : 0f;', impact_reactor)
        self.assertIn('public boolean rotate;', impact_reactor)
        self.assertIn('Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;', impact_reactor)
        self.assertIn('if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){', impact_reactor)
        self.assertIn('visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);', impact_reactor)
        self.assertIn('Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);', impact_reactor)
        self.assertIn('lightColor = Color.valueOf("0097f5").a(0.2f);', impact_reactor)
        self.assertIn('public boolean drawLiquidLight = true;', impact_reactor)
        self.assertIn('size = 4;', impact_reactor)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2430)', impact_reactor)
        # The proof's keys drive the draw pure (the
        # bottom rect, the plasma rects at warmup /
        # time 0 incl. the per-index r / alpha /
        # rotation / color lerp, the base rect + the
        # icons, the plasma + liquid lights, the cold
        # warmup-0 branch where the plasma alpha and
        # light die but the liquid light survives, and
        # the absin time peak at 2 * PI).
        proof = IMPACT_REACTOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_bottom',
            'draw_plasma_warmup_time',
            'draw_base',
            'draw_plasma_light',
            'draw_plasma_cold',
            'draw_plasma_time_peak',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceImpactReactorBuildState.gd")', proof)
        self.assertTrue(IMPACT_REACTOR_STATE.exists())
        self.assertTrue(IMPACT_REACTOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ImpactReactorDrawRowsProof.gd', IMPACT_REACTOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_impact_reactor_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ImpactReactorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_IMPACT_REACTOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_bottom',
            'draw_plasma_warmup_time',
            'draw_base',
            'draw_plasma_light',
            'draw_plasma_cold',
            'draw_plasma_time_peak',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
