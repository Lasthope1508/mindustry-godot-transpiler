import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_DRAW_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorDrawRowsProof.gd'
ACCELERATOR_DRAW_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorDrawRowsProof.tscn'


class C07AcceleratorDrawRowsTests(unittest.TestCase):
    def test_c07_accelerator_draw_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2373']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_draw_state')
        # The Accelerator tick is live (N2191 advance +
        # N2271 launch + N2342 battery stamp + N2354 launch
        # drain) but NOTHING modeled draw(): the statusLerp
        # arrows (4 layers x 4 arrows, absin pulse), the
        # launchBlock shadow + blockbuild shader draw, the
        # heat-gated charge rings (3 Lines.square rings +
        # team-color arrows) and drawLight / drawSelect (the
        # battery warning) were pure presentation the port
        # never described. N2373 ports draw() + drawLight()
        # + drawSelect() as three pure draw-call dicts (the
        # N2356 ShockwaveTower pattern: pures return
        # draw-call dicts, they never draw for real): the
        # draw pure returns the arrows call + the build call
        # (shadow + blockbuild) + the rings call, the
        # draw-light pure returns the light call, and the
        # draw-select pure returns the battery warning call.
        # Draw never runs in the tick, so there is no tick
        # wiring (pure-only, like the N2356 draw rows). Five
        # new result symbols: the arrows call, the build
        # call, the rings call, the light call, and the
        # battery warning call.
        self.assertEqual(
            ledger['N2373']['source_symbols'],
            [
                'source_accelerator_draw_state_result.arrows_call',
                'source_accelerator_draw_state_result.build_call',
                'source_accelerator_draw_state_result.rings_call',
                'source_accelerator_draw_light_state_result.light_call',
                'source_accelerator_draw_select_state_result.battery_warning_call',
            ],
        )
        for name in ledger['N2373']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/Accelerator.java')
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_draw_state_result.arrows_call': 'SourceAcceleratorBuildState.source_accelerator_draw_state',
                    'source_accelerator_draw_state_result.build_call': 'SourceAcceleratorBuildState.source_accelerator_draw_state',
                    'source_accelerator_draw_state_result.rings_call': 'SourceAcceleratorBuildState.source_accelerator_draw_state',
                    'source_accelerator_draw_light_state_result.light_call': 'SourceAcceleratorBuildState.source_accelerator_draw_light_state',
                    'source_accelerator_draw_select_state_result.battery_warning_call': 'SourceAcceleratorBuildState.source_accelerator_draw_select_state',
                }[name])
        self.assertEqual(ledger['N2373']['runtime_proof'], '/root/C07AcceleratorDrawRowsProof')
        self.assertEqual(
            ledger['N2373']['tests'],
            [
                'test_c07_accelerator_draw_rows_registration',
                'test_all_c07_accelerator_draw_rows_input_evidence_is_exact',
                'test_accelerator_draw_rows_state',
                'test_reference_graph_and_actual_c07_accelerator_draw_rows',
            ],
        )
        self.assertTrue(ledger['N2373']['deferred_exprs'])
        # This slice RESOLVES the draw rows (#106 in the
        # merged advances-18 DEFERRED base) and the
        # drawSelect / drawLight half of #107 -- but both
        # entries are REWRITTEN IN PLACE, not removed: the
        # launching branch of draw() (Accelerator.java:
        # 180-194, Fill.light / fullIcon / mixcol by
        # launchTime / chargeDuration) still defers because
        # launchTime is not tracked yet (see the
        # launchTime / cloudSeed entry), and getCursor
        # (Accelerator.java:242-244) still defers because
        # canLaunch needs the environment half (isValid /
        # !net.client() / state.isCampaign()) the port does
        # not model. drawLaunch / drawLaunchGlobalZ /
        # drawLanding stay under the launch rows (#103) +
        # launch animator (#109) entries. No new entry is
        # added: the draw pures are pure-only (no tick
        # wiring to defer). Net 0+0 = 316.
        self.assertFalse(any(entry.startswith('Accelerator draw rows (draw arrows / launchBlock icons / charge rings / landing, Accelerator.java:157-...)') for entry in ledger['N2373']['deferred_exprs']))
        self.assertFalse(any(entry.startswith('Accelerator drawSelect / drawLight / getCursor rows (') for entry in ledger['N2373']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator draw launching-branch rows (') for entry in ledger['N2373']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator getCursor rows (') for entry in ledger['N2373']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch rows (') for entry in ledger['N2373']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator powerBufferRequirement bar rows (') for entry in ledger['N2373']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch animator rows (') for entry in ledger['N2373']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launchTime / cloudSeed rows (') for entry in ledger['N2373']['deferred_exprs']))
        self.assertEqual(len(ledger['N2373']['deferred_exprs']), 316)

    def test_all_c07_accelerator_draw_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2373']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_accelerator_draw_state_result.arrows_call': 'SourceAcceleratorBuildState.source_accelerator_draw_state',
                    'source_accelerator_draw_state_result.build_call': 'SourceAcceleratorBuildState.source_accelerator_draw_state',
                    'source_accelerator_draw_state_result.rings_call': 'SourceAcceleratorBuildState.source_accelerator_draw_state',
                    'source_accelerator_draw_light_state_result.light_call': 'SourceAcceleratorBuildState.source_accelerator_draw_light_state',
                    'source_accelerator_draw_select_state_result.battery_warning_call': 'SourceAcceleratorBuildState.source_accelerator_draw_select_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/Vars.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The absin / trnsx formulas live in Arc, not
        # Mindustry: Mathf.java / Angles.java under
        # arc-upstream (the N2191 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Angles.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Angles.java').read_text(encoding='utf-8')
        for expr in ledger['N2373']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_draw_rows_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The draw rows (AcceleratorBuild.draw(),
        # Accelerator.java:157-233; drawLight(),
        # Accelerator.java:235-237; drawSelect(),
        # Accelerator.java:249-256). draw() is super.draw()
        # (:158) + the arrows loop (:160-169: 4 layers, length
        # 7f + l * 5f, color lerp darkMetal -> team.color by
        # statusLerp then -> darkMetal by absin(Time.time +
        # l*50f, 10f, 1f), 4 arrows per layer at rot i*90f +
        # 45f via Angles.trnsx/trnsy, rotation rot + 180f) +
        # the launching branch (:180-194, Fill.light /
        # fullIcon / mixcol by launchTime / chargeDuration --
        # DEFERRED, launchTime is not tracked) or the
        # non-launching branch (:195-212: Drawf.shadow(x, y,
        # launchBlock.size * tilesize * 2f, progress) +
        # Draw.draw(Layer.blockBuilding, ...) with
        # Draw.color(Pal.accent, heat) and the blockbuild
        # shader (region / time / progress per generated
        # icon)) + the heat gate (:215, if(heat < 0.0001f)
        # return) + the rings (:217-232: rad = size *
        # tilesize / 2f * 0.74f * lerp(1f, 1.3f, launchHeat),
        # z Layer.bullet - 0.0001f, stroke 1.75f * heat
        # square rad * 1.22f rot lerp(45f, 0f, launchHeat),
        # stroke 3f * heat squares rad * lerp(1f, 1.3f,
        # launchHeat) rot 45f + time / scl and rad * lerp(1f,
        # 1.8f, launchHeat) rot lerp(45f, 0f, launchHeat) -
        # time / scl, scl 2f, then team.color arrows alpha
        # clamp(heat * 3f), rot i*90f + 45f + (-time/3f)%360f,
        # length 26f * heat * lerp(1f, 1.5f, launchHeat)).
        # drawLight() is Drawf.light(x, y, lightRadius,
        # lightColor, launchHeat) (:236 -- lightRadius 70f,
        # lightColor Pal.accent, :79-80). drawSelect() is
        # super.drawSelect() + the battery warning (:252-254:
        # battery < requirement && !launching ->
        # drawPlaceText("bar.nobatterypower", tile.x, tile.y,
        # false), valid false -> Pal.remove, Block.java:531).
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_accelerator_draw_state', accelerator)
        self.assertIn('static func source_accelerator_draw_light_state', accelerator)
        self.assertIn('static func source_accelerator_draw_select_state', accelerator)
        self.assertIn('public @Load(value = "@-launch-arrow", fallback = "launch-arrow") TextureRegion arrowRegion;', accelerator)
        self.assertIn('float length = 7f + l * 5f;', accelerator)
        self.assertIn('Draw.color(Tmp.c1.set(Pal.darkMetal).lerp(team.color, statusLerp), Pal.darkMetal, Mathf.absin(Time.time + l*50f, 10f, 1f));', accelerator)
        self.assertIn('Draw.rect(arrowRegion, x + Angles.trnsx(rot, length), y + Angles.trnsy(rot, length), rot + 180f);', accelerator)
        self.assertIn('Drawf.shadow(x, y, launchBlock.size * tilesize * 2f, progress);', accelerator)
        self.assertIn('Draw.draw(Layer.blockBuilding, () -> {', accelerator)
        self.assertIn('Draw.color(Pal.accent, heat);', accelerator)
        self.assertIn('Shaders.blockbuild.progress = progress;', accelerator)
        self.assertIn('if(heat < 0.0001f) return;', accelerator)
        self.assertIn('float rad = size * tilesize / 2f * 0.74f * Mathf.lerp(1f, 1.3f, launchHeat);', accelerator)
        self.assertIn('Lines.stroke(1.75f * heat, Pal.accent);', accelerator)
        self.assertIn('Lines.square(x, y, rad * 1.22f, Mathf.lerp(45f, 0f, launchHeat));', accelerator)
        self.assertIn('Lines.square(x, y, rad * Mathf.lerp(1f, 1.3f, launchHeat), 45f + time / scl);', accelerator)
        self.assertIn('Lines.square(x, y, rad * Mathf.lerp(1f, 1.8f, launchHeat), Mathf.lerp(45f, 0f, launchHeat) - time / scl);', accelerator)
        self.assertIn('Draw.alpha(Mathf.clamp(heat * 3f));', accelerator)
        self.assertIn('float length = 26f * heat * Mathf.lerp(1f, 1.5f, launchHeat);', accelerator)
        self.assertIn('Drawf.light(x, y, lightRadius, lightColor, launchHeat);', accelerator)
        self.assertIn('if(power.graph.getBatteryStored() < powerBufferRequirement && !launching){', accelerator)
        self.assertIn('drawPlaceText(Core.bundle.get("bar.nobatterypower"), tile.x, tile.y, false);', accelerator)
        # The launching branch is documented as deferred in
        # the driver (launchTime is not tracked yet).
        self.assertIn('launching_visual_deferred', accelerator)
        self.assertIn('Fill.light(x, y, 15, launchBlock.size * tilesize * 1f, Tmp.c2.set(Pal.accent).a(launchTime / chargeDuration), Tmp.c1.set(Pal.accent).a(0f));', accelerator)
        # The draw constants are driver constants (no def
        # override for the size / tilesize / launch-block
        # size / light radius); the draw pures read them,
        # not literals.
        self.assertIn('SOURCE_ACCELERATOR_SIZE := 7', accelerator)
        self.assertIn('SOURCE_ACCELERATOR_LAUNCH_BLOCK_SIZE := 5', accelerator)
        self.assertIn('SOURCE_ACCELERATOR_TILESIZE := 8.0', accelerator)
        self.assertIn('SOURCE_ACCELERATOR_LIGHT_RADIUS := 70.0', accelerator)
        # The documented limits record the draw rows as live
        # (the old "No draw/config modeling" text is gone;
        # config still waits for its own slice).
        self.assertIn('Draw rows live (N2373)', accelerator)
        self.assertNotIn('No draw/config modeling', accelerator)
        # The proof's keys drive the draw pures (the arrows
        # statusLerp lerp + absin pulse, the shadow +
        # blockbuild shader draw, the heat-gated charge
        # rings, the drawLight launchHeat opacity, the
        # drawSelect battery warning) plus the live frame
        # values (a placed accelerator's frame heat /
        # statusLerp / launchHeat / time / progress /
        # launching / battery_stored feed the draw pures).
        # There is no launching-branch key: that branch
        # still defers (launchTime untracked).
        proof = ACCELERATOR_DRAW_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_arrows_status_lerp_pulse',
            'draw_shadow_blockbuild',
            'draw_charge_rings_heat_gate',
            'draw_light_launch_heat',
            'draw_select_battery_warning',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceAcceleratorBuildState.gd")', proof)
        self.assertTrue(ACCELERATOR_STATE.exists())
        self.assertTrue(ACCELERATOR_DRAW_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07AcceleratorDrawRowsProof.gd', ACCELERATOR_DRAW_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_accelerator_draw_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorDrawRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_DRAW_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_arrows_status_lerp_pulse',
            'draw_shadow_blockbuild',
            'draw_charge_rings_heat_gate',
            'draw_light_launch_heat',
            'draw_select_battery_warning',
            'draw_live_frame_values',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
