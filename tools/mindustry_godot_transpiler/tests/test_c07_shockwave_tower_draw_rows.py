import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SHOCKWAVE_TOWER_STATE = ROOT / 'godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd'
SHOCKWAVE_TOWER_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerDrawRowsProof.gd'
SHOCKWAVE_TOWER_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerDrawRowsProof.tscn'


class C07ShockwaveTowerDrawRowsTests(unittest.TestCase):
    def test_c07_shockwave_tower_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2356']['godot_owner'], 'SourceShockwaveTowerBuildState.source_shockwave_tower_draw_state')
        # The ShockwaveTower tick is live (N2247 advance +
        # N2318 timerCheck + N2327/N2340/N2347 bullet scan +
        # N2331 cyanogen row) but NOTHING modeled draw():
        # the additive heatRegion glow (heatColor, alpha =
        # heat) and the rotating shape poly (4 sides, radius
        # shapeRadius * potentialEfficiency, rotation
        # Time.time * shapeRotateSpeed, color lerp shapeColor
        # -> waveColor by heat^2) were pure presentation the
        # port never described, and drawSelect / drawPlace
        # (the waveColor dash circle at the def range) had no
        # row either. N2356 ports draw() + drawSelect() +
        # drawPlace as two pure draw-call dicts (the
        # SourceBlockDrawState / SourceBaseTurretDrawState
        # pattern: pures return draw-call dicts, they never
        # draw for real): the draw pure returns the heat call
        # + the shape call, and the draw-select pure returns
        # the dash circle call, shared by drawSelect (building
        # x/y) and drawPlace (x * tilesize + offset) -- both
        # use waveColor (ShockwaveTower.java:63, NOT
        # Pal.placing like the BaseTurret drawPlace). Draw
        # never runs in the tick, so there is no tick wiring
        # (pure-only, like the BaseTurret drawPlace). Three
        # new result symbols: the heat call, the shape call,
        # and the dash circle call.
        self.assertEqual(
            ledger['N2356']['source_symbols'],
            [
                'source_shockwave_tower_draw_state_result.heat_call',
                'source_shockwave_tower_draw_state_result.shape_call',
                'source_shockwave_tower_draw_select_state_result.dash_circle_call',
            ],
        )
        for name in ledger['N2356']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/ShockwaveTower.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_draw_state_result.heat_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_draw_state',
                    'source_shockwave_tower_draw_state_result.shape_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_draw_state',
                    'source_shockwave_tower_draw_select_state_result.dash_circle_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_draw_select_state',
                }[name])
        self.assertEqual(ledger['N2356']['runtime_proof'], '/root/C07ShockwaveTowerDrawRowsProof')
        self.assertEqual(
            ledger['N2356']['tests'],
            [
                'test_c07_shockwave_tower_draw_rows_registration',
                'test_all_c07_shockwave_tower_draw_rows_input_evidence_is_exact',
                'test_shockwave_tower_draw_rows_state',
                'test_reference_graph_and_actual_c07_shockwave_tower_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2356']['deferred_exprs'])
        # This slice RESOLVES the draw / drawSelect rows
        # (#69 in the merged advances-16 DEFERRED base) and
        # the shape / timer fields rows (#204): the shape
        # fields (shapeRotateSpeed 1f / shapeRadius 6f /
        # shapeSides 4) are live in the draw pure, timerCheck
        # is live since N2318, and shake 2f is already
        # covered by the wave effects / sound / shake entry
        # (#205) -- so #204 leaves nothing behind. No new
        # entry is added: the draw pures are pure-only (no
        # tick wiring to defer), sense / warmup and the live
        # bullet query stay deferred. Net -2+0 = 324.
        self.assertFalse(any(entry.startswith('ShockwaveTower draw / drawSelect rows (') for entry in ledger['N2356']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('ShockwaveTower shape / timer fields rows (') for entry in ledger['N2356']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower sense / warmup rows (') for entry in ledger['N2356']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower wave effects / sound / shake (') for entry in ledger['N2356']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('ShockwaveTower live bullet query (') for entry in ledger['N2356']['deferred_exprs']))
        self.assertEqual(len(ledger['N2356']['deferred_exprs']), 324)

    def test_all_c07_shockwave_tower_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2356']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_shockwave_tower_draw_state_result.heat_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_draw_state',
                    'source_shockwave_tower_draw_state_result.shape_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_draw_state',
                    'source_shockwave_tower_draw_select_state_result.dash_circle_call': 'SourceShockwaveTowerBuildState.source_shockwave_tower_draw_select_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/ShockwaveTower.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2356']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_shockwave_tower_draw_rows_state(self):
        shockwave_tower = SHOCKWAVE_TOWER_STATE.read_text(encoding='utf-8')
        # The draw rows (ShockwaveTowerBuild.draw(),
        # ShockwaveTower.java:126-134; drawSelect(),
        # ShockwaveTower.java:137-139; drawPlace(),
        # ShockwaveTower.java:60-64). draw() is super.draw()
        # + the additive heatRegion glow (`Drawf.additive(
        # heatRegion, heatColor, heat, x, y, 0f,
        # Layer.blockAdditive);`, :128 -- heatRegion is the
        # `@-heat` region, :42; heatColor is Pal.turretHeat,
        # :33) + the shape poly at Layer.effect (`Draw.z(
        # Layer.effect);`, :130) with the color lerp
        # (`Draw.color(shapeColor, waveColor, Mathf.pow(heat,
        # 2f));`, :131 -- shapeColor is Color.valueOf
        # ("f29c83"), waveColor is Pal.accent, :33) and the
        # poly (`Fill.poly(x, y, shapeSides, shapeRadius *
        # potentialEfficiency, Time.time * shapeRotateSpeed);`,
        # :132 -- shapeSides 4, shapeRadius 6f,
        # shapeRotateSpeed 1f, :39-40), then the color reset
        # (`Draw.color();`, :133). drawSelect() is the dash
        # circle at the building x/y (`Drawf.dashCircle(x, y,
        # range, waveColor);`, :138); drawPlace() is the SAME
        # waveColor dash circle at the tile position
        # (`Drawf.dashCircle(x * tilesize + offset, y *
        # tilesize + offset, range, waveColor);`, :63 -- NOT
        # Pal.placing, unlike the BaseTurret drawPlace), so
        # one pure serves both (the caller supplies world
        # coords). The shape has NO state advance -- the
        # rotation is a function of Time.time, which the
        # caller supplies as time_value (the tick never
        # stamps it: draw never runs in the tick). The color
        # lerp has NO precedent in the port's draw-call dicts
        # (BaseTurret uses flat color strings), so the shape
        # call carries it as an explicit from/to/t dict.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_shockwave_tower_draw_state', shockwave_tower)
        self.assertIn('static func source_shockwave_tower_draw_select_state', shockwave_tower)
        self.assertIn('public float shapeRotateSpeed = 1f, shapeRadius = 6f;', shockwave_tower)
        self.assertIn('public int shapeSides = 4;', shockwave_tower)
        self.assertIn('public Color waveColor = Pal.accent, heatColor = Pal.turretHeat, shapeColor = Color.valueOf("f29c83");', shockwave_tower)
        self.assertIn('public @Load("@-heat") TextureRegion heatRegion;', shockwave_tower)
        self.assertIn('super.draw();', shockwave_tower)
        self.assertIn('Drawf.additive(heatRegion, heatColor, heat, x, y, 0f, Layer.blockAdditive);', shockwave_tower)
        self.assertIn('Draw.z(Layer.effect);', shockwave_tower)
        self.assertIn('Draw.color(shapeColor, waveColor, Mathf.pow(heat, 2f));', shockwave_tower)
        self.assertIn('Fill.poly(x, y, shapeSides, shapeRadius * potentialEfficiency, Time.time * shapeRotateSpeed);', shockwave_tower)
        self.assertIn('Draw.color();', shockwave_tower)
        self.assertIn('Drawf.dashCircle(x, y, range, waveColor);', shockwave_tower)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, waveColor);', shockwave_tower)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', shockwave_tower)
        # The shape fields are driver constants (no def
        # override); the draw pures read them, not literals.
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_SHAPE_SIDES := 4', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_SHAPE_RADIUS := 6.0', shockwave_tower)
        self.assertIn('SOURCE_SHOCKWAVE_TOWER_SHAPE_ROTATE_SPEED := 1.0', shockwave_tower)
        # The documented limits record the draw rows as live
        # (the old "waits for their own slice" text for the
        # heatRegion / shape draw is gone).
        self.assertIn('Draw rows live (N2356)', shockwave_tower)
        self.assertNotIn('No draw modeling', shockwave_tower)
        # The proof's keys drive the draw pures (the heat
        # call alpha, the shape poly geometry, the heat^2
        # color lerp, the drawSelect dash circle, the
        # drawPlace dash circle in waveColor) plus the live
        # frame values (a placed tower's frame heat +
        # potentialEfficiency feed the draw pure). There are
        # no sense / warmup keys: those rows still defer.
        proof = SHOCKWAVE_TOWER_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_heat_call_additive',
            'draw_shape_poly_geometry',
            'draw_shape_color_lerp',
            'draw_select_dash_circle',
            'draw_place_dash_circle_wave_color',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceShockwaveTowerBuildState.gd")', proof)
        self.assertTrue(SHOCKWAVE_TOWER_STATE.exists())
        self.assertTrue(SHOCKWAVE_TOWER_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07ShockwaveTowerDrawRowsProof.gd', SHOCKWAVE_TOWER_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_shockwave_tower_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07ShockwaveTowerDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_SHOCKWAVE_TOWER_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_heat_call_additive',
            'draw_shape_poly_geometry',
            'draw_shape_color_lerp',
            'draw_select_dash_circle',
            'draw_place_dash_circle_wave_color',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
