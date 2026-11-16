import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MEND_PROJECTOR_STATE = ROOT / 'godot-mindustry/src/game/SourceMendProjectorBuildState.gd'
MEND_PROJECTOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorDrawRowsProof.gd'
MEND_PROJECTOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07MendProjectorDrawRowsProof.tscn'


class C07MendProjectorDrawRowsTests(unittest.TestCase):
    def test_c07_mend_projector_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2372']['godot_owner'], 'SourceMendProjectorBuildState.source_mend_projector_draw_rows_state')
        # The MendProjector tick is live (N2193 advance +
        # N2242 heal scan + N2263 booster items + N2269
        # timer use + N2329 range query + N2335 narrow
        # filter + N2350 hitbox broad phase) but NOTHING
        # modeled draw(): the topRegion glow (baseColor ->
        # phaseColor by phaseHeat, alpha = heat * absin *
        # 0.5 * Lod.alpha2) and the expanding square
        # (stroke (2f * f + 0.2f) * heat, radius min(1f +
        # (1f - f) * size * tilesize / 2f, size * tilesize /
        # 2f)) were pure presentation the port never
        # described, and drawSelect / drawPlace (the
        # baseColor dash circle at realRange + the selected
        # highlights) and drawLight (radius lightRadius *
        # smoothEfficiency, alpha 0.7f * smoothEfficiency)
        # had no row either. N2372 ports draw() +
        # drawSelect() + drawPlace + drawLight() as three
        # pure draw-call dicts (the SourceBlockDrawState /
        # SourceBaseTurretDrawState pattern, the N2356
        # ShockwaveTower precedent: pures return draw-call
        # dicts, they never draw for real): the draw pure
        # returns the top call + the square call, the
        # draw-select pure returns the dash circle call +
        # the selected calls (shared by drawSelect, which
        # passes realRange, and drawPlace, which passes the
        # plain range with phaseHeat 0 -- both use
        # baseColor), and the draw-light pure returns the
        # light call. Draw never runs in the tick, so there
        # is no tick wiring (pure-only, like the BaseTurret
        # drawPlace). Five new result symbols: the top
        # call, the square call, the dash circle call, the
        # selected calls, and the light call. The draw
        # pure is named draw_rows_state (not draw_state):
        # the older display path already owns the
        # source_mend_projector_draw_state schemas
        # (PortGame.source_mend_projector_draw_state),
        # and reusing the name would overwrite them.
        self.assertEqual(
            ledger['N2372']['source_symbols'],
            [
                'source_mend_projector_draw_rows_state_result.top_call',
                'source_mend_projector_draw_rows_state_result.square_call',
                'source_mend_projector_draw_select_state_result.dash_circle_call',
                'source_mend_projector_draw_select_state_result.selected_calls',
                'source_mend_projector_draw_light_state_result.light_call',
            ],
        )
        for name in ledger['N2372']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/MendProjector.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_draw_rows_state_result.top_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_rows_state',
                    'source_mend_projector_draw_rows_state_result.square_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_rows_state',
                    'source_mend_projector_draw_select_state_result.dash_circle_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_select_state',
                    'source_mend_projector_draw_select_state_result.selected_calls': 'SourceMendProjectorBuildState.source_mend_projector_draw_select_state',
                    'source_mend_projector_draw_light_state_result.light_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_light_state',
                }[name])
        self.assertEqual(ledger['N2372']['runtime_proof'], '/root/C07MendProjectorDrawRowsProof')
        self.assertEqual(
            ledger['N2372']['tests'],
            [
                'test_c07_mend_projector_draw_rows_registration',
                'test_all_c07_mend_projector_draw_rows_input_evidence_is_exact',
                'test_mend_projector_draw_rows_state',
                'test_reference_graph_and_actual_c07_mend_projector_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2372']['deferred_exprs'])
        # This slice RESOLVES the draw / drawLight rows
        # (#1 in the merged advances-18 DEFERRED base):
        # the entry is rewritten in place to the sense-only
        # remainder (sense(LAccess.progress) still waits
        # for its own slice). The range / phase-range entry
        # (#23) is REMOVED: its only open item was the
        # drawSelect range display, which is live now (the
        # realRange fold was already live since N2242 /
        # N2329). No new entry is added: the draw pures are
        # pure-only (no tick wiring to defer), the
        # eachBlock live visit rides the existing heal-scan
        # live building-index entry (same index, the
        # drawSelect predicate is `other -> true`). Net
        # 316 - 1 = 315.
        self.assertFalse(any(entry.startswith('MendProjector draw / drawLight / sense (') for entry in ledger['N2372']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector sense rows (') for entry in ledger['N2372']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('MendProjector range / phase-range rows (') for entry in ledger['N2372']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector suppression gate (') for entry in ledger['N2372']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('MendProjector heal scan live building-index fill (') for entry in ledger['N2372']['deferred_exprs']))
        self.assertEqual(len(ledger['N2372']['deferred_exprs']), 315)

    def test_all_c07_mend_projector_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2372']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_mend_projector_draw_rows_state_result.top_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_rows_state',
                    'source_mend_projector_draw_rows_state_result.square_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_rows_state',
                    'source_mend_projector_draw_select_state_result.dash_circle_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_select_state',
                    'source_mend_projector_draw_select_state_result.selected_calls': 'SourceMendProjectorBuildState.source_mend_projector_draw_select_state',
                    'source_mend_projector_draw_light_state_result.light_call': 'SourceMendProjectorBuildState.source_mend_projector_draw_light_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/MendProjector.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2372']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_mend_projector_draw_rows_state(self):
        mend_projector = MEND_PROJECTOR_STATE.read_text(encoding='utf-8')
        # The draw rows (MendBuild.draw(),
        # MendProjector.java:146-159; drawSelect(),
        # MendProjector.java:132-139; drawPlace(),
        # MendProjector.java:76-82; drawLight(),
        # MendProjector.java:162-164). draw() is the cycle
        # factor (`float f = 1f - (Time.time / 100f) % 1f;`,
        # :147) + the Lod guard (`if(!Lod.l2) return;`,
        # :149) + the color blend (`Draw.color(baseColor,
        # phaseColor, phaseHeat);`, :151 -- baseColor is
        # Color.valueOf("84f491"), phaseColor is baseColor,
        # :23-24) + the top glow (`Draw.alpha(heat *
        # Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) *
        # 0.5f * Lod.alpha2);`, :152) + the top rect
        # (`Draw.rect(topRegion, x, y);`, :153 -- topRegion
        # is the `@-top` region, :25) + the square alpha
        # (`Draw.alpha(Lod.alpha2);`, :154) + the stroke
        # (`Lines.stroke((2f * f + 0.2f) * heat);`, :155) +
        # the expanding square (`Lines.square(x, y,
        # Math.min(1f + (1f - f) * size * tilesize / 2f,
        # size * tilesize/2f));`, :156), then the reset
        # (`Draw.reset();`, :158). drawSelect() is the
        # realRange fold (`float realRange = range +
        # phaseHeat * phaseRangeBoost;`, :133) + the
        # eachBlock selected highlights (`indexer.eachBlock(
        # this, realRange, other -> true, other ->
        # Drawf.selected(other, Tmp.c1.set(baseColor).a(
        # Mathf.absin(4f, 1f))));`, :135) + the dash circle
        # (`Drawf.dashCircle(x, y, realRange, baseColor);`,
        # :137). drawPlace() is the SAME baseColor dash
        # circle at the tile position (`Drawf.dashCircle(x
        # * tilesize + offset, y * tilesize + offset, range,
        # baseColor);`, :79) after `super.drawPlace(x, y,
        # rotation, valid);` (:77) + the same selected
        # highlights over the player team (`indexer.eachBlock(
        # player.team(), x * tilesize + offset, y * tilesize
        # + offset, range, other -> true, other ->
        # Drawf.selected(other, Tmp.c1.set(baseColor).a(
        # Mathf.absin(4f, 1f))));`, :81), so one pure serves
        # both (drawPlace passes the plain range with
        # phaseHeat 0). drawLight() is `Drawf.light(x, y,
        # lightRadius * smoothEfficiency, baseColor, 0.7f *
        # smoothEfficiency);` (:163 -- lightRadius 50f, :46;
        # neither def overrides it). The absin calls are
        # Java-exact through the shared helper: the helper
        # folds the 2f from absin (`(sin(in, scl * 2f, mag)
        # + mag) / 2f`, Mathf.java:78-80) differently, so
        # the pures pass the DOUBLED scale (100f / PI2 for
        # the draw glow, 8f for the select alpha) -- the
        # display state passes the undoubled scale, which
        # oscillates twice as fast as Java (a display-path
        # deviation, not this slice's file). sense() (:126)
        # is NOT modeled here (logic sensing, its own
        # slice); drawCached() (:141-144) only calls
        # super.draw() and gets no pure of its own.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_mend_projector_draw_rows_state', mend_projector)
        self.assertIn('static func source_mend_projector_draw_select_state', mend_projector)
        self.assertIn('static func source_mend_projector_draw_light_state', mend_projector)
        self.assertIn('public Color baseColor = Color.valueOf("84f491");', mend_projector)
        self.assertIn('public Color phaseColor = baseColor;', mend_projector)
        self.assertIn('public @Load("@-top") TextureRegion topRegion;', mend_projector)
        self.assertIn('lightRadius = 50f;', mend_projector)
        self.assertIn('float f = 1f - (Time.time / 100f) % 1f;', mend_projector)
        self.assertIn('if(!Lod.l2) return;', mend_projector)
        self.assertIn('Draw.color(baseColor, phaseColor, phaseHeat);', mend_projector)
        self.assertIn('Draw.alpha(heat * Mathf.absin(Time.time, 50f / Mathf.PI2, 1f) * 0.5f * Lod.alpha2);', mend_projector)
        self.assertIn('Draw.rect(topRegion, x, y);', mend_projector)
        self.assertIn('Draw.alpha(Lod.alpha2);', mend_projector)
        self.assertIn('Lines.stroke((2f * f + 0.2f) * heat);', mend_projector)
        self.assertIn('Lines.square(x, y, Math.min(1f + (1f - f) * size * tilesize / 2f, size * tilesize/2f));', mend_projector)
        self.assertIn('Draw.reset();', mend_projector)
        self.assertIn('float realRange = range + phaseHeat * phaseRangeBoost;', mend_projector)
        self.assertIn('indexer.eachBlock(this, realRange, other -> true, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));', mend_projector)
        self.assertIn('Drawf.dashCircle(x, y, realRange, baseColor);', mend_projector)
        self.assertIn('Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, range, baseColor);', mend_projector)
        self.assertIn('super.drawPlace(x, y, rotation, valid);', mend_projector)
        self.assertIn('indexer.eachBlock(player.team(), x * tilesize + offset, y * tilesize + offset, range, other -> true, other -> Drawf.selected(other, Tmp.c1.set(baseColor).a(Mathf.absin(4f, 1f))));', mend_projector)
        self.assertIn('Drawf.light(x, y, lightRadius * smoothEfficiency, baseColor, 0.7f * smoothEfficiency);', mend_projector)
        # The light radius is a driver constant (no def
        # override); the draw-light pure reads it, not a
        # literal.
        self.assertIn('SOURCE_MEND_PROJECTOR_LIGHT_RADIUS := 50.0', mend_projector)
        # The documented limits record the draw rows as live
        # (the old combined "draw / drawLight / sense"
        # deferral text is gone; sense alone still defers).
        self.assertIn('Draw rows live (N2372)', mend_projector)
        self.assertNotIn('draw / drawLight / sense', mend_projector)
        # The proof's keys drive the draw pures (the
        # topRegion glow alpha, the square geometry, the Lod
        # guard, the drawSelect dash circle at realRange,
        # the drawPlace dash circle at the plain range, the
        # drawLight radius/alpha) plus the live frame values
        # (a placed mender's frame heat + phaseHeat +
        # smoothEfficiency feed the draw pures). There are
        # no sense keys: sense still defers.
        proof = MEND_PROJECTOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_top_region_alpha',
            'draw_square_geometry',
            'draw_lod_guard',
            'draw_select_dash_circle',
            'draw_place_dash_circle',
            'draw_light_radius_alpha',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceMendProjectorBuildState.gd")', proof)
        self.assertTrue(MEND_PROJECTOR_STATE.exists())
        self.assertTrue(MEND_PROJECTOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07MendProjectorDrawRowsProof.gd', MEND_PROJECTOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_mend_projector_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07MendProjectorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_MEND_PROJECTOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_top_region_alpha',
            'draw_square_geometry',
            'draw_lod_guard',
            'draw_select_dash_circle',
            'draw_place_dash_circle',
            'draw_light_radius_alpha',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
