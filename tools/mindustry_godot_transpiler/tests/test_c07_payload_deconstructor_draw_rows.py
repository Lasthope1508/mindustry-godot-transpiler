import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDrawRowsProof.gd'
PAYLOAD_DECONSTRUCTOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorDrawRowsProof.tscn'


class C07PayloadDeconstructorDrawRowsTests(unittest.TestCase):
    def test_c07_payload_deconstructor_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2418']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_draw_state')
        # The PayloadDeconstructor tick is live (N2233
        # advance + N2276 dump + N2291 handlePayload +
        # N2297 acceptance + N2308 intake gate + N2387
        # sense) but NOTHING modeled draw(): the base
        # rect + the 4 input regions + drawPayload() +
        # the deconstructing shadow + the Drawf.construct
        # effect + the scan line + the top region
        # (PayloadDeconstructor.java:58-89), or icons()
        # (PayloadDeconstructor.java:40-42). N2418
        # ports draw() + icons() as ONE pure-only draw
        # pure, the N2396 MassDriver pattern: draw is
        # never called by the tick, so the pure takes
        # caller-supplied inputs (blends + payload
        # presence + deconstructing descriptor +
        # progress + time + size + x / y) and returns
        # the draw calls as data, with the icons riding
        # the pure as the icon_regions result key (a
        # pure icons() 0-arg FAILS the register because
        # the validator requires input keys non-empty).
        # Eight new result symbols: the base call, the
        # input calls, the payload call, the shadow
        # call, the construct call, the scan line, the
        # top call, and the icon regions.
        self.assertEqual(
            ledger['N2418']['source_symbols'],
            [
                'source_payload_deconstructor_draw_state_result.base_call',
                'source_payload_deconstructor_draw_state_result.input_calls',
                'source_payload_deconstructor_draw_state_result.payload_call',
                'source_payload_deconstructor_draw_state_result.shadow_call',
                'source_payload_deconstructor_draw_state_result.construct_call',
                'source_payload_deconstructor_draw_state_result.scan_line',
                'source_payload_deconstructor_draw_state_result.top_call',
                'source_payload_deconstructor_draw_state_result.icon_regions',
            ],
        )
        for name in ledger['N2418']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                if name.endswith('.payload_call'):
                    self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadBlock.java')
                else:
                    self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourcePayloadDeconstructorBuildState.source_payload_deconstructor_'))
        self.assertEqual(ledger['N2418']['runtime_proof'], '/root/C07PayloadDeconstructorDrawRowsProof')
        self.assertEqual(
            ledger['N2418']['tests'],
            [
                'test_c07_payload_deconstructor_draw_rows_registration',
                'test_all_c07_payload_deconstructor_draw_rows_input_evidence_is_exact',
                'test_payload_deconstructor_draw_rows_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2418']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #5 (1-based in
        # DEFERRED-after-advances-24.py): the
        # PayloadDeconstructor draw / icons rows entry
        # is REMOVED -- draw() + icons() are live now,
        # so nothing of the entry remains. Net 286 - 1
        # = 285.
        self.assertFalse(any(entry.startswith('PayloadDeconstructor draw / icons rows (draw input regions / drawPayload / deconstructing shadow / construct effect, PayloadDeconstructor.java:58-89; icons, PayloadDeconstructor.java:40-42)') for entry in ledger['N2418']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor setBars row (progress bar, PayloadDeconstructor.java:45-49)') for entry in ledger['N2418']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor read/write rows (progress / accum / deconstructing, PayloadDeconstructor.java:224-252)') for entry in ledger['N2418']['deferred_exprs']))
        self.assertEqual(len(ledger['N2418']['deferred_exprs']), 285)

    def test_all_c07_payload_deconstructor_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2418']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourcePayloadDeconstructorBuildState.source_payload_deconstructor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/world/blocks/payloads/PayloadBlock.java',
            'core/src/mindustry/world/blocks/payloads/Payload.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/blocks/payloads/BuildPayload.java',
            'core/src/mindustry/world/blocks/payloads/UnitPayload.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2418']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_draw_rows_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The draw rows (PayloadDeconstructorBuild.draw(),
        # PayloadDeconstructor.java:58-89): `Draw.rect(
        # region, x, y);` always, then the 4 input
        # regions (`for(int i = 0; i < 4; i++){` +
        # `if(blends(i)){` + `Draw.rect(inRegion, x, y,
        # (i * 90) - 180);`), then `Draw.z(Layer.
        # blockOver);` + `drawPayload();`, then the
        # deconstructing branch (`if(deconstructing !=
        # null){` + `deconstructing.set(x + payVector.x,
        # y + payVector.y, payRotation);` + `Draw.z(Layer.
        # blockOver);` + `deconstructing.drawShadow(1f -
        # progress);` + the Draw.draw lambda with
        # `Drawf.construct(x, y, deconstructing.icon(),
        # Pal.remove, deconstructing instanceof
        # BuildPayload ? 0f : payRotation - 90f, 1f -
        # progress, 1f - progress, time);` + `Draw.color(
        # Pal.remove);` + `Draw.alpha(1f);` + the scan
        # line `Lines.lineAngleCenter(x + Mathf.sin(time,
        # 20f, tilesize / 2f * block.size - 3f), y, 90f,
        # block.size * tilesize - 6f);` + `Draw.reset();
        # `), then `Draw.rect(topRegion, x, y);` always.
        # icons() (`public TextureRegion[] icons(){` /
        # `return new TextureRegion[]{region, topRegion};
        # `, PayloadDeconstructor.java:40-42) rides the
        # pure as icon_regions (the N2396 precedent -- a
        # pure icons() 0-arg FAILS the register).
        # drawPayload() (PayloadBlock.java:246-253)
        # draws the HELD payload when present (`if(
        # payload != null){` + `updatePayload();` +
        # `Draw.z(Layer.blockOver);` + `payload.draw();`
        # ) -- a different field from deconstructing
        # (`public @Nullable Payload deconstructing;`,
        # PayloadDeconstructor.java:52). blends(i) is
        # the PayloadBlock neighbour check
        # (PayloadBlock.java:170-172, `return PayloadBlock.
        # blends(this, direction);`) -- the pure takes
        # the 4 verdicts as an explicit Array input
        # (the neighbour query waits for its own slice).
        # The sin is the arc 3-arg form (`return sin(
        # radians / scl) * mag;`, Mathf.java:90-92, arc)
        # -- NOT absin (the N2415 precedent) -- so the
        # scan offset is sin(time / 20f) * (tilesize /
        # 2f * size - 3f) and the length is size *
        # tilesize - 6f: size 5 gives magnitude 17 and
        # length 34, size 3 gives 9 and 18. The
        # Drawf.construct overload here is the (x, y,
        # region, color, rotation, progress, alpha,
        # time) one (Drawf.java:560-572) -- a shader
        # rect ONLY, no scan line of its own (unlike
        # the Building overload, Drawf.java:582-599).
        # tilesize is the Java constant 8.0 (`public
        # static final int tilesize = 8;`, Vars.java:135
        # -- NEVER the game tile_size 32, the N2375
        # lesson). Pure-only: the tick never calls draw
        # (draw is called by the renderer).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_payload_deconstructor_draw_state', payload_deconstructor)
        self.assertIn('Draw.rect(region, x, y);', payload_deconstructor)
        self.assertIn('for(int i = 0; i < 4; i++){', payload_deconstructor)
        self.assertIn('if(blends(i)){', payload_deconstructor)
        self.assertIn('Draw.rect(inRegion, x, y, (i * 90) - 180);', payload_deconstructor)
        self.assertIn('Draw.z(Layer.blockOver);', payload_deconstructor)
        self.assertIn('drawPayload();', payload_deconstructor)
        self.assertIn('if(deconstructing != null){', payload_deconstructor)
        self.assertIn('deconstructing.set(x + payVector.x, y + payVector.y, payRotation);', payload_deconstructor)
        self.assertIn('deconstructing.drawShadow(1f - progress);', payload_deconstructor)
        self.assertIn('Draw.draw(Layer.blockOver, () -> {', payload_deconstructor)
        self.assertIn('Drawf.construct(x, y, deconstructing.icon(), Pal.remove, deconstructing instanceof BuildPayload ? 0f : payRotation - 90f, 1f - progress, 1f - progress, time);', payload_deconstructor)
        self.assertIn('Draw.color(Pal.remove);', payload_deconstructor)
        self.assertIn('Draw.alpha(1f);', payload_deconstructor)
        self.assertIn('Lines.lineAngleCenter(x + Mathf.sin(time, 20f, tilesize / 2f * block.size - 3f), y, 90f, block.size * tilesize - 6f);', payload_deconstructor)
        self.assertIn('Draw.reset();', payload_deconstructor)
        self.assertIn('Draw.rect(topRegion, x, y);', payload_deconstructor)
        self.assertIn('public TextureRegion[] icons(){', payload_deconstructor)
        self.assertIn('return new TextureRegion[]{region, topRegion};', payload_deconstructor)
        self.assertIn('public @Nullable Payload deconstructing;', payload_deconstructor)
        self.assertIn('public float progress;', payload_deconstructor)
        self.assertIn('public float time, speedScl;', payload_deconstructor)
        self.assertIn('public void drawPayload(){', payload_deconstructor)
        self.assertIn('if(payload != null){', payload_deconstructor)
        self.assertIn('updatePayload();', payload_deconstructor)
        self.assertIn('payload.draw();', payload_deconstructor)
        self.assertIn('public boolean blends(int direction){', payload_deconstructor)
        self.assertIn('return PayloadBlock.blends(this, direction);', payload_deconstructor)
        self.assertIn('public Vec2 payVector = new Vec2();', payload_deconstructor)
        self.assertIn('public float payRotation;', payload_deconstructor)
        self.assertIn('void draw();', payload_deconstructor)
        self.assertIn('void drawShadow(float alpha);', payload_deconstructor)
        self.assertIn('TextureRegion icon();', payload_deconstructor)
        self.assertIn('public static void construct(float x, float y, TextureRegion region, Color color, float rotation, float progress, float alpha, float time){', payload_deconstructor)
        self.assertIn('Shaders.build.progress = progress;', payload_deconstructor)
        self.assertIn('Shaders.build.color.a = alpha;', payload_deconstructor)
        self.assertIn('Shaders.build.time = -time / 20f;', payload_deconstructor)
        self.assertIn('Draw.rect(region, x, y, rotation);', payload_deconstructor)
        self.assertIn('public static final int tilesize = 8;', payload_deconstructor)
        self.assertIn('size = 5;', payload_deconstructor)
        self.assertIn('Drawf.squareShadow(build.x, build.y, build.block.size * tilesize * 1.85f, alpha);', payload_deconstructor)
        self.assertIn('unit.type.drawSoftShadow(unit, alpha);', payload_deconstructor)
        self.assertIn('return sin(radians / scl) * mag;', payload_deconstructor)
        # The documented limits record the draw rows as
        # live (the old "No draw / icons / setBars /
        # read-write rows" text is gone -- setBars +
        # read/write still defer, draw / icons do not).
        self.assertIn('Draw rows live (N2418)', payload_deconstructor)
        self.assertNotIn('No draw / icons / setBars / read-write rows', payload_deconstructor)
        # The proof's keys drive the draw pure (the
        # base rect + input regions, the
        # no-deconstructing branch, the deconstructing
        # shadow + construct, the scan line math, the
        # merged icons, the BuildPayload rotation 0f vs
        # the payload rotation branch).
        proof = PAYLOAD_DECONSTRUCTOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_inputs',
            'draw_no_deconstructing',
            'draw_deconstructing_shadow_construct',
            'draw_scan_line',
            'draw_icons_merged',
            'draw_construct_rotation',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.exists())
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07PayloadDeconstructorDrawRowsProof.gd', PAYLOAD_DECONSTRUCTOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_payload_deconstructor_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_inputs',
            'draw_no_deconstructing',
            'draw_deconstructing_shadow_construct',
            'draw_scan_line',
            'draw_icons_merged',
            'draw_construct_rotation',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
