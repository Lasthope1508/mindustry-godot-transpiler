import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LAUNCH_PAD_STATE = ROOT / 'godot-mindustry/src/game/SourceLaunchPadBuildState.gd'
LAUNCH_PAD_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadDrawRowsProof.gd'
LAUNCH_PAD_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07LaunchPadDrawRowsProof.tscn'


class C07LaunchPadDrawRowsTests(unittest.TestCase):
    def test_c07_launch_pad_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2420']['godot_owner'], 'SourceLaunchPadBuildState.source_launch_pad_draw_state')
        # The LaunchPad tick is live (N2238 advance +
        # N2253 liquid row + N2333 acceptItem + N2389
        # sense + N2397 pod result) but NOTHING modeled
        # draw(): the bottom/liquid branch + super.draw()
        # + the light-region progress loop + the shadow/
        # pod pair (LaunchPad.java:104-136) and icons()
        # (:79-80). N2420 ports draw() + icons() as ONE
        # pure-only draw pure, the N2396 MassDriver
        # pattern: draw is never called by the tick, so
        # the pure takes caller-supplied inputs (world
        # pos / size / the liquid branch inputs / the
        # light progress inputs / the def constants) and
        # returns the draw calls as data. icons() folds
        # into the draw pure as the icon_regions result
        # key (icons() takes no args and the SSOT schema
        # validator requires non-empty input keys, the
        # N2396 precedent). Six new result symbols, in
        # Java draw order: the liquid call, the super
        # base call, the light calls, the shadow call,
        # the pod call, the icon regions.
        self.assertEqual(
            ledger['N2420']['source_symbols'],
            [
                'source_launch_pad_draw_state_result.liquid_call',
                'source_launch_pad_draw_state_result.super_draw_call',
                'source_launch_pad_draw_state_result.light_calls',
                'source_launch_pad_draw_state_result.shadow_call',
                'source_launch_pad_draw_state_result.pod_call',
                'source_launch_pad_draw_state_result.icon_regions',
            ],
        )
        for name in ledger['N2420']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/LaunchPad.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceLaunchPadBuildState.source_launch_pad_'))
        self.assertEqual(ledger['N2420']['runtime_proof'], '/root/C07LaunchPadDrawRowsProof')
        self.assertEqual(
            ledger['N2420']['tests'],
            [
                'test_c07_launch_pad_draw_rows_registration',
                'test_all_c07_launch_pad_draw_rows_input_evidence_is_exact',
                'test_launch_pad_draw_rows_state',
                'test_reference_graph_and_actual_c07_launch_pad_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2420']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #45 (1-based in
        # DEFERRED-after-advances-24.py): the LaunchPad
        # draw / drawLiquid / icons rows entry is
        # REMOVED -- draw() + icons() are live now, so
        # nothing of the entry remains. Net 286 - 1 =
        # 285.
        self.assertFalse(any(entry.startswith('LaunchPad draw / drawLiquid / icons rows (draw bottom/liquid/light/pod, LaunchPad.java:104-140; icons, LaunchPad.java:78-81)') for entry in ledger['N2420']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad updateTile launch sound / effects (launchSound.at(x, y, 1f + Mathf.range(launchSoundPitchRand))') for entry in ledger['N2420']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('LaunchPad config / display / shouldShowConfigure rows (buildConfiguration sector select, LaunchPad.java:185-...;') for entry in ledger['N2420']['deferred_exprs']))
        self.assertEqual(len(ledger['N2420']['deferred_exprs']), 285)

    def test_all_c07_launch_pad_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2420']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceLaunchPadBuildState.source_launch_pad_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/LaunchPad.java',
            'core/src/mindustry/world/blocks/liquid/LiquidBlock.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2420']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_launch_pad_draw_rows_state(self):
        launch_pad = LAUNCH_PAD_STATE.read_text(encoding='utf-8')
        # The draw rows (LaunchPadBuild.draw(),
        # LaunchPad.java:104-136): if hasLiquids &&
        # drawLiquid != null, color(bottomColor), the
        # bottom Fill.square(x, y, size * tilesize/2f -
        # liquidPad), color(), then LiquidBlock.
        # drawTiledFrames(block.size, x, y, liquidPad x4,
        # drawLiquid, liquids.get(drawLiquid) /
        # liquidCapacity); super.draw(); if lightRegion.
        # found(), progress = min(items.total() /
        # itemCapacity, launchCounter / launchTime) and
        # the 4 x lightSteps loop (alpha = Mathf.curve(
        # progress, j / lightSteps, (j+1) / lightSteps),
        # offset = -(j - 1) * lightStep, rect(lightRegion,
        # x + d8edge(i).x * offset, y + d8edge(i).y *
        # offset, i * 90) in the metalGrayDark -> lightColor
        # mix); Drawf.shadow(x, y, size * tilesize);
        # Draw.rect(podRegion, x, y); reset. icons()
        # (LaunchPad.java:79-80) returns {previewRegion}.
        # The def constants (LaunchPad.java:39-47, no def
        # override except drawLiquid / liquidCapacity):
        # lightColor eab678 / lightStep 1f / lightSteps 3
        # / liquidPad 2f / bottomColor Pal.darkerMetal
        # ("565666") / drawLiquid null by default, oil on
        # the advanced def (Blocks.java:6807, liquidCapacity
        # 40f, Blocks.java:6805). Mathf.curve(f, from, to)
        # is the arc 3-arg form (Mathf.java:608-616: 0
        # below from, 1 above to, (f - from) / (to -
        # from) between); Geometry.d8edge(i) is the arc
        # diagonal array [(1, 1), (-1, 1), (-1, -1),
        # (1, -1)] (Geometry.java:35-40, 59-61). tilesize
        # is the Java constant 8.0 (`public static
        # final int tilesize = 8;`, Vars.java:135 --
        # NEVER the game tile_size 32, the N2375
        # lesson). Pure-only: the tick never calls draw
        # (draw is called by the renderer, icons by the
        # atlas).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_launch_pad_draw_state', launch_pad)
        self.assertIn('static func _launch_pad_mathf_curve', launch_pad)
        self.assertIn('if(hasLiquids && drawLiquid != null){', launch_pad)
        self.assertIn('Draw.color(bottomColor);', launch_pad)
        self.assertIn('Fill.square(x, y, size * tilesize/2f - liquidPad);', launch_pad)
        self.assertIn('Draw.color();', launch_pad)
        self.assertIn('LiquidBlock.drawTiledFrames(block.size, x, y, liquidPad, liquidPad, liquidPad, liquidPad, drawLiquid, liquids.get(drawLiquid) / liquidCapacity);', launch_pad)
        self.assertIn('super.draw();', launch_pad)
        self.assertIn('if(lightRegion.found()){', launch_pad)
        self.assertIn('Draw.color(lightColor);', launch_pad)
        self.assertIn('float progress = Math.min((float)items.total() / itemCapacity, launchCounter / launchTime);', launch_pad)
        self.assertIn('for(int i = 0; i < 4; i++){', launch_pad)
        self.assertIn('for(int j = 0; j < lightSteps; j++){', launch_pad)
        self.assertIn('float alpha = Mathf.curve(progress, (float)j / lightSteps, (j+1f) / lightSteps);', launch_pad)
        self.assertIn('float offset = -(j - 1f) * lightStep;', launch_pad)
        self.assertIn('Draw.color(Pal.metalGrayDark, lightColor, alpha);', launch_pad)
        self.assertIn('Draw.rect(lightRegion, x + Geometry.d8edge(i).x * offset, y + Geometry.d8edge(i).y * offset, i * 90);', launch_pad)
        self.assertIn('Draw.reset();', launch_pad)
        self.assertIn('Drawf.shadow(x, y, size * tilesize);', launch_pad)
        self.assertIn('Draw.rect(podRegion, x, y);', launch_pad)
        self.assertIn('public Color lightColor = Color.valueOf("eab678");', launch_pad)
        self.assertIn('public float lightStep = 1f;', launch_pad)
        self.assertIn('public int lightSteps = 3;', launch_pad)
        self.assertIn('public float liquidPad = 2f;', launch_pad)
        self.assertIn('public @Nullable Liquid drawLiquid;', launch_pad)
        self.assertIn('public Color bottomColor = Pal.darkerMetal;', launch_pad)
        self.assertIn('public TextureRegion[] icons(){', launch_pad)
        self.assertIn('return new TextureRegion[]{previewRegion};', launch_pad)
        self.assertIn('public static void drawTiledFrames(int size, float x, float y, float padLeft, float padRight, float padTop, float padBottom, Liquid liquid, float alpha){', launch_pad)
        self.assertIn('public static void shadow(float x, float y, float rad){', launch_pad)
        self.assertIn('darkerMetal = Color.valueOf("565666"),', launch_pad)
        self.assertIn('metalGrayDark = Color.valueOf("6e7080"),', launch_pad)
        self.assertIn('public static final int tilesize = 8;', launch_pad)
        self.assertIn('public static float curve(float f, float from, float to){', launch_pad)
        self.assertIn('return (f - from) / (to - from);', launch_pad)
        self.assertIn('public static Point2 d8edge(int i){', launch_pad)
        self.assertIn('return d8edge[Mathf.mod(i, 4)];', launch_pad)
        self.assertIn('drawLiquid = Liquids.oil;', launch_pad)
        self.assertIn('liquidCapacity = 40f;', launch_pad)
        # The documented limits record the draw rows as
        # live.
        self.assertIn('Draw rows live (N2420)', launch_pad)
        # The proof's keys drive the draw pure (the
        # liquid branch on/off, the light progress math,
        # the light loop alpha/offset sample, the shadow
        # + pod pair, the merged icons, the super.draw
        # base call).
        proof = LAUNCH_PAD_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_liquid_branch',
            'draw_light_progress',
            'draw_light_loop',
            'draw_shadow_pod',
            'draw_icons',
            'draw_super_base',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceLaunchPadBuildState.gd")', proof)
        self.assertTrue(LAUNCH_PAD_STATE.exists())
        self.assertTrue(LAUNCH_PAD_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07LaunchPadDrawRowsProof.gd', LAUNCH_PAD_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_launch_pad_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07LaunchPadDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_LAUNCH_PAD_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_liquid_branch',
            'draw_light_progress',
            'draw_light_loop',
            'draw_shadow_pod',
            'draw_icons',
            'draw_super_base',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
