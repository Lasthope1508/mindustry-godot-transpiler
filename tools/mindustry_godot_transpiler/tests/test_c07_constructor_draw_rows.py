import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceConstructorBuildState.gd'
CONSTRUCTOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorDrawRowsProof.gd'
CONSTRUCTOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ConstructorDrawRowsProof.tscn'


class C07ConstructorDrawRowsTests(unittest.TestCase):
    def test_c07_constructor_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2440']['godot_owner'], 'SourceConstructorBuildState.source_constructor_draw_state')
        # The Constructor tick is live (N2216
        # shouldConsume + N2265 dynamic item row +
        # N2274 updateTile advance) but NOTHING modeled
        # draw(): the base rect + the out rect at
        # rotdeg() + the recipe shadow + the blockbuild
        # shader loop over the recipe generated icons +
        # the scan line + drawPayload() + the top region
        # (BlockProducer.java:134-160), or drawSelect()
        # (Constructor.java:77-87), or the payload
        # placement effect (BlockProducer.java:116-119).
        # N2440 ports draw() + drawSelect() + the
        # placeEffect as ONE pure-only draw pure, the
        # N2418 PayloadDeconstructor pattern: draw is
        # never called by the tick, so the pure takes
        # caller-supplied inputs (x / y / rotation /
        # time / heat / progress / the recipe descriptor
        # / payload presence / just_crafted / the
        # producer size / the Draw scale factors) and
        # returns the draw calls as data, with the
        # shader loop recorded as CALL + params (no
        # shader port) and drawPayload() recorded (no
        # inner payload draw). Nine new result symbols:
        # the base call, the out call, the shadow call,
        # the build call, the scan call, the payload
        # call, the top call, the select call, and the
        # place effect call.
        self.assertEqual(
            ledger['N2440']['source_symbols'],
            [
                'source_constructor_draw_state_result.base_call',
                'source_constructor_draw_state_result.out_call',
                'source_constructor_draw_state_result.shadow_call',
                'source_constructor_draw_state_result.build_call',
                'source_constructor_draw_state_result.scan_call',
                'source_constructor_draw_state_result.payload_call',
                'source_constructor_draw_state_result.top_call',
                'source_constructor_draw_state_result.select_call',
                'source_constructor_draw_state_result.place_effect_call',
            ],
        )
        for name in ledger['N2440']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                if name.endswith('.payload_call'):
                    self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java')
                elif name.endswith('.select_call'):
                    self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/Constructor.java')
                else:
                    self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/BlockProducer.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceConstructorBuildState.source_constructor_'))
        self.assertEqual(ledger['N2440']['runtime_proof'], '/root/C07ConstructorDrawRowsProof')
        self.assertEqual(
            ledger['N2440']['tests'],
            [
                'test_c07_constructor_draw_rows_registration',
                'test_all_c07_constructor_draw_rows_input_evidence_is_exact',
                'test_constructor_draw_rows_state',
                'test_reference_graph_and_actual_c07_constructor_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2440']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #9 (1-based in
        # DEFERRED-after-advances-27.py): the
        # Constructor payload / draw rows entry is
        # REMOVED -- draw() + drawSelect() + the
        # placeEffect are live now, so nothing of the
        # entry remains. Net 266 - 1 = 265.
        self.assertFalse(any(entry.startswith('Constructor payload / draw rows (payload placement effect, BlockProducer.java:116-119') for entry in ledger['N2440']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Constructor config / filter rows (filter, minBlockSize 1 / maxBlockSize 2, canProduce, Constructor.java:21-22, 54-56)') for entry in ledger['N2440']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('RegenProjector suppression gate (checkSuppression(), RegenProjector.java:135') for entry in ledger['N2440']['deferred_exprs']))
        self.assertEqual(len(ledger['N2440']['deferred_exprs']), 265)

    def test_all_c07_constructor_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2440']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceConstructorBuildState.source_constructor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
            'core/src/mindustry/world/blocks/payloads/Constructor.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/graphics/Layer.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2440']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_constructor_draw_rows_state(self):
        constructor = CONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The draw rows (BlockProducerBuild.draw(),
        # BlockProducer.java:134-160): `Draw.rect(
        # region, x, y);` always, then `Draw.rect(
        # outRegion, x, y, rotdeg());` always, then the
        # recipe branch (`if(recipe != null){` +
        # `Drawf.shadow(x, y, recipe.size * tilesize *
        # 2f, progress / recipe.buildTime);` + the
        # Layer.blockBuilding draw lambda with
        # `Draw.color(Pal.accent);` + the shader loop
        # `for(TextureRegion region : recipe.
        # getGeneratedIcons()){` with `Shaders.
        # blockbuild.region = region;` / `Shaders.
        # blockbuild.time = time;` / `Shaders.
        # blockbuild.progress = progress / recipe.
        # buildTime;` + `Draw.rect(region, x, y,
        # recipe.rotate ? rotdeg() : 0);` + `Draw.
        # flush();` + `Draw.color();` + `Draw.z(Layer.
        # blockBuilding + 1);` + `Draw.color(Pal.
        # accent, heat);` + the scan line `Lines.
        # lineAngleCenter(x + Mathf.sin(time, 10f,
        # Vars.tilesize / 2f * recipe.size + 1f), y,
        # 90, recipe.size * Vars.tilesize + 1f);` +
        # `Draw.reset();`), then `drawPayload();`,
        # then `Draw.z(Layer.blockBuilding + 1.1f);`
        # + `Draw.rect(topRegion, x, y);` always.
        # drawSelect() (Constructor.java:77-87):
        # `float dx = x - size * tilesize/2f, dy = y +
        # size * tilesize/2f;` + `TextureRegion icon =
        # recipe.uiIcon;` + `Draw.mixcol(Color.
        # darkGray, 1f);` + the shadow rect `Draw.rect(
        # icon, dx - 0.7f, dy - 1f, Draw.scl * Draw.
        # xscl * 24f, Draw.scl * Draw.yscl * 24f);` +
        # `Draw.reset();` + the icon rect `Draw.rect(
        # icon, dx, dy, Draw.scl * Draw.xscl * 24f,
        # Draw.scl * Draw.yscl * 24f);` -- dx / dy use
        # the PRODUCER block size (3 / 5), not the
        # recipe size. The placeEffect
        # (BlockProducer.java:116-119) fires when the
        # craft completes (`if(progress >= recipe.
        # buildTime){` + `payload = new BuildPayload(
        # recipe, team);` + `payload.block().
        # placeEffect.at(x, y, payload.size() /
        # tilesize);`): the scale is payload.size() /
        # tilesize, and BuildPayload.size() is
        # `return build.block.size * tilesize;`
        # (BuildPayload.java:86-88), so the scale is
        # the RECIPE block size in tiles -- NOT the
        # producer size. The sin is the arc 3-arg form
        # (`return sin(radians / scl) * mag;`,
        # Mathf.java:90-92, arc) -- NOT absin (the
        # N2415 precedent) -- so the scan offset is
        # sin(time / 10f) * (tilesize / 2f * recipe.
        # size + 1f) and the length is recipe.size *
        # tilesize + 1f: recipe size 2 gives magnitude
        # 9 and length 17, recipe size 4 gives 17 and
        # 33. rotdeg() is `return rotation * 90;`
        # (BuildingComp.java:582-584). Layer.
        # blockBuilding is 40 and Layer.blockOver is
        # 35 (Layer.java:42/45), so the scan z is 41
        # and the top z is 41.1. Drawf.shadow
        # (Drawf.java:360-364) draws the circle-shadow
        # at black alpha 0.4 * alpha. tilesize is the
        # Java constant 8.0 (`public static final int
        # tilesize = 8;`, Vars.java:135 -- NEVER the
        # game tile_size 32, the N2375 lesson). Two
        # defs share this driver: constructor size 3
        # (Blocks.java:6658-6667, buildSpeed 0.6f) and
        # large-constructor size 5 (Blocks.java:
        # 6670-6680, buildSpeed 0.75f); neither def
        # overrides the drawer -- draw() is the
        # BlockProducerBuild override, no drawer field
        # on Constructor / BlockProducer. Pure-only:
        # the tick never calls draw (draw is called by
        # the renderer) and never calls drawSelect.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_constructor_draw_state', constructor)
        self.assertIn('Draw.rect(region, x, y);', constructor)
        self.assertIn('Draw.rect(outRegion, x, y, rotdeg());', constructor)
        self.assertIn('Drawf.shadow(x, y, recipe.size * tilesize * 2f, progress / recipe.buildTime);', constructor)
        self.assertIn('Draw.draw(Layer.blockBuilding, () -> {', constructor)
        self.assertIn('Draw.color(Pal.accent);', constructor)
        self.assertIn('for(TextureRegion region : recipe.getGeneratedIcons()){', constructor)
        self.assertIn('Shaders.blockbuild.region = region;', constructor)
        self.assertIn('Shaders.blockbuild.time = time;', constructor)
        self.assertIn('Shaders.blockbuild.progress = progress / recipe.buildTime;', constructor)
        self.assertIn('Draw.rect(region, x, y, recipe.rotate ? rotdeg() : 0);', constructor)
        self.assertIn('Draw.flush();', constructor)
        self.assertIn('Draw.color();', constructor)
        self.assertIn('Draw.z(Layer.blockBuilding + 1);', constructor)
        self.assertIn('Draw.color(Pal.accent, heat);', constructor)
        self.assertIn('Lines.lineAngleCenter(x + Mathf.sin(time, 10f, Vars.tilesize / 2f * recipe.size + 1f), y, 90, recipe.size * Vars.tilesize + 1f);', constructor)
        self.assertIn('Draw.reset();', constructor)
        self.assertIn('drawPayload();', constructor)
        self.assertIn('Draw.z(Layer.blockBuilding + 1.1f);', constructor)
        self.assertIn('Draw.rect(topRegion, x, y);', constructor)
        self.assertIn('public float progress, time, heat;', constructor)
        self.assertIn('public abstract @Nullable Block recipe();', constructor)
        self.assertIn('if(progress >= recipe.buildTime){', constructor)
        self.assertIn('payload = new BuildPayload(recipe, team);', constructor)
        self.assertIn('payload.block().placeEffect.at(x, y, payload.size() / tilesize);', constructor)
        self.assertIn('public class Constructor extends BlockProducer{', constructor)
        self.assertIn('public @Nullable Block recipe;', constructor)
        self.assertIn('if(recipe != null){', constructor)
        self.assertIn('float dx = x - size * tilesize/2f, dy = y + size * tilesize/2f;', constructor)
        self.assertIn('TextureRegion icon = recipe.uiIcon;', constructor)
        self.assertIn('Draw.mixcol(Color.darkGray, 1f);', constructor)
        self.assertIn('Draw.rect(icon, dx - 0.7f, dy - 1f, Draw.scl * Draw.xscl * 24f, Draw.scl * Draw.yscl * 24f);', constructor)
        self.assertIn('Draw.rect(icon, dx, dy, Draw.scl * Draw.xscl * 24f, Draw.scl * Draw.yscl * 24f);', constructor)
        self.assertIn('public void drawPayload(){', constructor)
        self.assertIn('if(payload != null){', constructor)
        self.assertIn('updatePayload();', constructor)
        self.assertIn('payload.draw();', constructor)
        self.assertIn('public float size(){', constructor)
        self.assertIn('return build.block.size * tilesize;', constructor)
        self.assertIn('public Effect placeEffect = Fx.placeBlock;', constructor)
        self.assertIn('public TextureRegion[] getGeneratedIcons(){', constructor)
        self.assertIn('return generatedIcons == null ? (generatedIcons = icons()) : generatedIcons;', constructor)
        self.assertIn('public static void shadow(float x, float y, float rad, float alpha){', constructor)
        self.assertIn('Draw.color(0, 0, 0, 0.4f * alpha);', constructor)
        self.assertIn('Draw.rect("circle-shadow", x, y, rad * Draw.xscl, rad * Draw.yscl);', constructor)
        self.assertIn('blockBuilding = 40,', constructor)
        self.assertIn('blockOver = 35,', constructor)
        self.assertIn('public static final int tilesize = 8;', constructor)
        self.assertIn('size = 3;', constructor)
        self.assertIn('size = 5;', constructor)
        self.assertIn('buildSpeed = 0.6f;', constructor)
        self.assertIn('buildSpeed = 0.75f;', constructor)
        self.assertIn('public float rotdeg(){', constructor)
        self.assertIn('return rotation * 90;', constructor)
        self.assertIn('public static float sin(float radians, float scl, float mag){', constructor)
        self.assertIn('return sin(radians / scl) * mag;', constructor)
        # The documented limits record the draw rows as
        # live (the old "the placeEffect ... is
        # presentation and defers" text is gone -- the
        # placeEffect is recorded by the draw pure now;
        # config/filter rows still defer).
        self.assertIn('Draw rows live (N2440)', constructor)
        self.assertNotIn('the placeEffect (BlockProducer.java:118) is presentation and defers', constructor)
        # The proof's keys drive the draw pure (the
        # no-recipe branch, the recipe build call, the
        # shadow math, the scan line sin, the select
        # icon shadow offset, the place effect scale).
        proof = CONSTRUCTOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_no_recipe',
            'draw_recipe_build',
            'draw_shadow_math',
            'draw_scan_line_sin',
            'draw_select_icon',
            'draw_place_effect',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceConstructorBuildState.gd")', proof)
        self.assertTrue(CONSTRUCTOR_STATE.exists())
        self.assertTrue(CONSTRUCTOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ConstructorDrawRowsProof.gd', CONSTRUCTOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_constructor_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ConstructorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_CONSTRUCTOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_no_recipe',
            'draw_recipe_build',
            'draw_shadow_math',
            'draw_scan_line_sin',
            'draw_select_icon',
            'draw_place_effect',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
