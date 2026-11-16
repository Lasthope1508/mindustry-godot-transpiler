import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_CARGO_LOADER_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitCargoLoaderBuildState.gd'
UNIT_CARGO_LOADER_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderDrawRowsProof.gd'
UNIT_CARGO_LOADER_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07UnitCargoLoaderDrawRowsProof.tscn'


class C07UnitCargoLoaderDrawRowsTests(unittest.TestCase):
    def test_c07_unit_cargo_loader_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2415']['godot_owner'], 'SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_draw_state')
        # The UnitCargoLoader tick is live (N2234 advance +
        # N2249 liquid row + N2322 canCreate + N2330
        # canPlaceOn) but NOTHING modeled draw():
        # the base rect + the Drawf.construct call while
        # no unit is held + the poly ring once a unit
        # waits (UnitCargoLoader.java:146-162). N2415
        # ports draw() as ONE pure-only draw pure, the
        # N2396 MassDriver pattern: draw is never called
        # by the tick, so the pure takes caller-supplied
        # inputs (frame unit / buildProgress / warmup /
        # totalProgress / readyness + Time.time + size)
        # and returns the draw calls as data. The icon
        # rides the draw pure as the construct_icon
        # result key (the construct region is
        # unitType.fullIcon -- UnitCargoLoader has NO
        # icons() override, and a pure icons() 0-arg
        # FAILS the register because the validator
        # requires input keys non-empty). Six new result
        # symbols: the base call, the construct call +
        # its icon, the poly call + its rotation +
        # stroke.
        self.assertEqual(
            ledger['N2415']['source_symbols'],
            [
                'source_unit_cargo_loader_draw_state_result.base_call',
                'source_unit_cargo_loader_draw_state_result.construct_call',
                'source_unit_cargo_loader_draw_state_result.construct_icon',
                'source_unit_cargo_loader_draw_state_result.poly_call',
                'source_unit_cargo_loader_draw_state_result.poly_rotation',
                'source_unit_cargo_loader_draw_state_result.poly_stroke',
            ],
        )
        for name in ledger['N2415']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitCargoLoader.java')
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_'))
        self.assertEqual(ledger['N2415']['runtime_proof'], '/root/C07UnitCargoLoaderDrawRowsProof')
        self.assertEqual(
            ledger['N2415']['tests'],
            [
                'test_c07_unit_cargo_loader_draw_rows_registration',
                'test_all_c07_unit_cargo_loader_draw_rows_input_evidence_is_exact',
                'test_unit_cargo_loader_draw_rows_state',
                'test_reference_graph_and_actual_c07_unit_cargo_loader_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2415']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #3 (1-based in
        # DEFERRED-after-advances-23.py): the
        # UnitCargoLoader draw rows entry is REMOVED --
        # draw() is live now, so nothing of the entry
        # remains. Net 291 - 1 = 290.
        self.assertFalse(any(entry.startswith('UnitCargoLoader draw rows (Drawf.construct / poly ring, UnitCargoLoader.java:146-162)') for entry in ledger['N2415']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader bar rows (setBars units bar, UnitCargoLoader.java:48-63)') for entry in ledger['N2415']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('UnitCargoLoader read/write rows (readUnitId, write unit id, UnitCargoLoader.java:174-188)') for entry in ledger['N2415']['deferred_exprs']))
        self.assertEqual(len(ledger['N2415']['deferred_exprs']), 290)

    def test_all_c07_unit_cargo_loader_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2415']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceUnitCargoLoaderBuildState.source_unit_cargo_loader_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitCargoLoader.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2415']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_cargo_loader_draw_rows_state(self):
        unit_cargo_loader = UNIT_CARGO_LOADER_STATE.read_text(encoding='utf-8')
        # The draw rows (UnitTransportSourceBuild.draw(),
        # UnitCargoLoader.java:146-162): `Draw.rect(
        # block.region, x, y);` always, then EITHER the
        # construct call on Layer.blockOver while no
        # unit is held (`Drawf.construct(this,
        # unitType.fullIcon, 0f, buildProgress, warmup,
        # totalProgress);`) OR the poly ring once a unit
        # waits (`Draw.z(Layer.bullet - 0.01f);` +
        # `Draw.color(polyColor);` + `Lines.stroke(
        # polyStroke * readyness);` + `Lines.poly(x, y,
        # polySides, polyRadius, Time.time *
        # polyRotateSpeed);` + `Draw.reset();` +
        # `Draw.z(Layer.block);`). The def constants are
        # polyStroke 1.8f / polyRadius 8f / polySides 6
        # / polyRotateSpeed 1f / polyColor Pal.accent
        # (UnitCargoLoader.java:27-30, no def override --
        # the unit-cargo-loader def, Blocks.java:2270-
        # 2283, sets only size 3 / unitBuildTime /
        # consumers / itemCapacity). Drawf.construct
        # delegates (Drawf.java:574-579) to the sized
        # overload with color Pal.accent and size
        # t.block.size * tilesize - 4f = 3 * 8 - 4 =
        # 20f, drawing the build-shader rect (progress
        # buildProgress, alpha warmup, shader time
        # -totalProgress / 20f) plus the scan line
        # (`Lines.lineAngleCenter(t.x + Mathf.sin(time,
        # 20f, size / 2f), t.y, 90, size);`, Drawf.java:
        # 596) -- the sin is the arc 3-arg form
        # `return sin(radians / scl) * mag;`
        # (Mathf.java:90-92, arc), so the line offset is
        # sin(totalProgress / 20f) * 10f, computed with
        # GDScript sin() like the shared absin helper
        # does (SourceMathState.source_absin). tilesize
        # is the Java constant 8.0 (`public static
        # final int tilesize = 8;`, Vars.java:135 --
        # NEVER the game tile_size 32, the N2375
        # lesson). Pure-only: the tick never calls draw
        # (draw is called by the renderer).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_unit_cargo_loader_draw_state', unit_cargo_loader)
        self.assertIn('Draw.rect(block.region, x, y);', unit_cargo_loader)
        self.assertIn('Draw.draw(Layer.blockOver, () -> {', unit_cargo_loader)
        self.assertIn('Drawf.construct(this, unitType.fullIcon, 0f, buildProgress, warmup, totalProgress);', unit_cargo_loader)
        self.assertIn('if(unit == null){', unit_cargo_loader)
        self.assertIn('Draw.z(Layer.bullet - 0.01f);', unit_cargo_loader)
        self.assertIn('Draw.color(polyColor);', unit_cargo_loader)
        self.assertIn('Lines.stroke(polyStroke * readyness);', unit_cargo_loader)
        self.assertIn('Lines.poly(x, y, polySides, polyRadius, Time.time * polyRotateSpeed);', unit_cargo_loader)
        self.assertIn('Draw.reset();', unit_cargo_loader)
        self.assertIn('Draw.z(Layer.block);', unit_cargo_loader)
        self.assertIn('public float polyStroke = 1.8f, polyRadius = 8f;', unit_cargo_loader)
        self.assertIn('public int polySides = 6;', unit_cargo_loader)
        self.assertIn('public float polyRotateSpeed = 1f;', unit_cargo_loader)
        self.assertIn('public Color polyColor = Pal.accent;', unit_cargo_loader)
        self.assertIn('public UnitType unitType = UnitTypes.manifold;', unit_cargo_loader)
        self.assertIn('public float buildProgress, totalProgress;', unit_cargo_loader)
        self.assertIn('public float warmup, readyness;', unit_cargo_loader)
        self.assertIn('public @Nullable Unit unit;', unit_cargo_loader)
        self.assertIn('public static void construct(Building t, TextureRegion region, float rotation, float progress, float alpha, float time){', unit_cargo_loader)
        self.assertIn('construct(t, region, Pal.accent, rotation, progress, alpha, time);', unit_cargo_loader)
        self.assertIn('construct(t, region, color, rotation, progress, alpha, time, t.block.size * tilesize - 4f);', unit_cargo_loader)
        self.assertIn('Shaders.build.progress = progress;', unit_cargo_loader)
        self.assertIn('Shaders.build.color.a = alpha;', unit_cargo_loader)
        self.assertIn('Shaders.build.time = -time / 20f;', unit_cargo_loader)
        self.assertIn('Draw.rect(region, t.x, t.y, rotation);', unit_cargo_loader)
        self.assertIn('Draw.color(Pal.accent);', unit_cargo_loader)
        self.assertIn('Draw.alpha(alpha);', unit_cargo_loader)
        self.assertIn('Lines.lineAngleCenter(t.x + Mathf.sin(time, 20f, size / 2f), t.y, 90, size);', unit_cargo_loader)
        self.assertIn('return sin(radians / scl) * mag;', unit_cargo_loader)
        self.assertIn('public static final int tilesize = 8;', unit_cargo_loader)
        # The documented limits record the draw rows as
        # live (the old "Bar / draw / read-write rows
        # still defer" text is gone -- bar + read/write
        # still defer, draw does not).
        self.assertIn('Draw rows live (N2415)', unit_cargo_loader)
        self.assertNotIn('Bar / draw / read-write rows still defer', unit_cargo_loader)
        # The proof's keys drive the draw pure (the
        # base rect at (x, y), the construct branch
        # when no unit is held + its progress values,
        # the poly branch when a unit waits + its
        # rotation from time + its stroke from
        # readyness).
        proof = UNIT_CARGO_LOADER_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_base_rect',
            'draw_construct_branch',
            'draw_construct_progress',
            'draw_poly_branch',
            'draw_poly_rotation',
            'draw_poly_stroke',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")', proof)
        self.assertTrue(UNIT_CARGO_LOADER_STATE.exists())
        self.assertTrue(UNIT_CARGO_LOADER_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07UnitCargoLoaderDrawRowsProof.gd', UNIT_CARGO_LOADER_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_unit_cargo_loader_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07UnitCargoLoaderDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_UNIT_CARGO_LOADER_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_base_rect',
            'draw_construct_branch',
            'draw_construct_progress',
            'draw_poly_branch',
            'draw_poly_rotation',
            'draw_poly_stroke',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
