import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE_SHIELD_STATE = ROOT / 'godot-mindustry/src/game/SourceBaseShieldBuildState.gd'
BASE_SHIELD_DRAW_SHIELD_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseShieldDrawShieldRowsProof.gd'
BASE_SHIELD_DRAW_SHIELD_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07BaseShieldDrawShieldRowsProof.tscn'


class C07BaseShieldDrawShieldRowsTests(unittest.TestCase):
    def test_c07_base_shield_draw_shield_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2441']['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_draw_shield_state')
        # drawShield() (BaseShield.java:125-147) + drawSelect()
        # (BaseShield.java:106-110) ported as ONE pure-only draw
        # pure (no tick wiring -- the draw loop calls
        # drawShield, the selection UI calls drawSelect; the
        # call sites wait for UI slices). Four new result
        # symbols: the shield z + color call (null when
        # broken), the fill call (Fill.poly -- the animated
        # branch draws the fill only, the static branch fills
        # at alpha 0.09 + clamp(0.08 * hit)), the line call
        # (Lines.poly + stroke 1.5f -- null in the animated
        # branch and when broken) and the dash call (the
        # drawSelect dashCircle with the FIELD radius -- NOT
        # radius() = smoothRadius). The super.drawSelect()
        # call is recorded on the dash call, not ported (the
        # N2439 super-recorded precedent).
        self.assertEqual(
            ledger['N2441']['source_symbols'],
            [
                'source_base_shield_draw_shield_state_result.shield_call',
                'source_base_shield_draw_shield_state_result.fill_call',
                'source_base_shield_draw_shield_state_result.line_call',
                'source_base_shield_draw_shield_state_result.dash_call',
            ],
        )
        for name in ledger['N2441']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/defense/BaseShield.java')
                self.assertEqual(symbol['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_draw_shield_state')
        self.assertEqual(ledger['N2441']['runtime_proof'], '/root/C07BaseShieldDrawShieldRowsProof')
        self.assertEqual(
            ledger['N2441']['tests'],
            [
                'test_c07_base_shield_draw_shield_rows_registration',
                'test_all_c07_base_shield_draw_shield_rows_input_evidence_is_exact',
                'test_base_shield_draw_shield_rows_state',
                'test_reference_graph_and_actual_c07_base_shield_draw_shield_rows',
            ],
        )
        self.assertTrue(ledger['N2441']['deferred_exprs'])
        # This slice RESOLVES the BaseShield drawShield rows
        # (#12 in the merged advances-27 DEFERRED base): the
        # shield color mix, the animated/static branches, the
        # hit alpha math and the drawSelect dashCircle are all
        # live in the draw-shield pure. No new entry is added:
        # the pure is pure-only (no tick wiring to defer), the
        # radius/sides + broken/hit rows stay deferred under
        # their own entries. Net -1+0 = 265.
        self.assertFalse(any(entry.startswith('BaseShield drawShield rows (') for entry in ledger['N2441']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BaseShield radius / sides rows (') for entry in ledger['N2441']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('BaseShield broken / hit rows (') for entry in ledger['N2441']['deferred_exprs']))
        self.assertEqual(len(ledger['N2441']['deferred_exprs']), 265)

    def test_all_c07_base_shield_draw_shield_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2441']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceBaseShieldBuildState.source_base_shield_draw_shield_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/BaseShield.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Layer.java',
            'core/src/mindustry/graphics/Drawf.java',
            'core/src/mindustry/core/Renderer.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The clamp / color-lerp formulas live in Arc, not
        # Mindustry: Mathf.java and Draw.java under
        # arc-upstream (the N2328 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/graphics/g2d/Draw.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/graphics/g2d/Draw.java').read_text(encoding='utf-8')
        for expr in ledger['N2441']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_base_shield_draw_shield_rows_state(self):
        base_shield = BASE_SHIELD_STATE.read_text(encoding='utf-8')
        # The drawShield rows (BaseShieldBuild.drawShield(),
        # BaseShield.java:125-147): if(!broken) the shield
        # poly uses radius() = smoothRadius (`public float
        # radius(){` / `return smoothRadius;`, :101-103) at z
        # Layer.shields (`shields = 125,`, Layer.java:87),
        # colored shieldColor == null ? team.color :
        # shieldColor lerped toward Color.white by
        # Mathf.clamp(hit) (Draw.color(a, b, s) lerps a
        # toward b by s, arc Draw.java:234-236; clamp is
        # [0,1], arc Mathf.java:402-404). The animated
        # branch (`if(renderer.animateShields){` -- the
        # renderer flag, Renderer.java:42, loaded from
        # settings at :168) draws ONLY the fill; the static
        # branch strokes 1.5f, fills at alpha 0.09 +
        # clamp(0.08 * hit) (the sum is NOT clamped --
        # 0.09..1.09 in Java), resets alpha to 1f, then
        # draws the outline. Draw.reset() closes both
        # branches and the method. drawSelect()
        # (BaseShield.java:106-110) is super.drawSelect()
        # (recorded, NOT ported) + Drawf.dashCircle(x, y,
        # radius, team.color) with the FIELD radius
        # (`public float radius = 200f;`, :20) -- NOT
        # radius() = smoothRadius; the dash runs regardless
        # of broken. sides is 24 (`public int sides = 24;`,
        # :21) and shieldColor is nullable (`public
        # @Nullable Color shieldColor;`, :23) -- neither def
        # overrides either (the large def sets only `radius
        # = 400f;`, Blocks.java:2060). Keep each Java expr
        # on ONE comment line (the N2148 lesson: a split
        # line fails this test).
        self.assertIn('static func source_base_shield_draw_shield_state', base_shield)
        self.assertIn('public void drawShield(){', base_shield)
        self.assertIn('if(!broken){', base_shield)
        self.assertIn('float radius = radius();', base_shield)
        self.assertIn('Draw.z(Layer.shields);', base_shield)
        self.assertIn('Draw.color(shieldColor == null ? team.color : shieldColor, Color.white, Mathf.clamp(hit));', base_shield)
        self.assertIn('if(renderer.animateShields){', base_shield)
        self.assertIn('Fill.poly(x, y, sides, radius);', base_shield)
        self.assertIn('Lines.stroke(1.5f);', base_shield)
        self.assertIn('Draw.alpha(0.09f + Mathf.clamp(0.08f * hit));', base_shield)
        self.assertIn('Draw.alpha(1f);', base_shield)
        self.assertIn('Lines.poly(x, y, sides, radius);', base_shield)
        self.assertIn('Draw.reset();', base_shield)
        self.assertIn('public void drawSelect(){', base_shield)
        self.assertIn('super.drawSelect();', base_shield)
        self.assertIn('Drawf.dashCircle(x, y, radius, team.color);', base_shield)
        self.assertIn('public float radius = 200f;', base_shield)
        self.assertIn('public int sides = 24;', base_shield)
        self.assertIn('public @Nullable Color shieldColor;', base_shield)
        self.assertIn('public float radius(){', base_shield)
        self.assertIn('return smoothRadius;', base_shield)
        self.assertIn('radius = 400f;', base_shield)
        self.assertIn('shields = 125,', base_shield)
        self.assertIn('public static void dashCircle(float x, float y, float rad, Color color){', base_shield)
        self.assertIn('public boolean animateShields, animateWater, drawWeather = true, drawStatus, enableEffects, drawDisplays = true, drawLight = true, pixelate = false, showPings = true, showOtherBuildPlans = true;', base_shield)
        self.assertIn('public static float clamp(float value){', base_shield)
        self.assertIn('public static void color(Color a, Color b, float s){', base_shield)
        self.assertIn('Core.batch.setPackedColor(Tmp.c1.set(a).lerp(b, s).toFloatBits());', base_shield)
        # The sides + layer consts (no def overrides either).
        self.assertIn('const SOURCE_BASE_SHIELD_SIDES := 24', base_shield)
        self.assertIn('const SOURCE_BASE_SHIELD_LAYER_SHIELDS := 125', base_shield)
        # The broken gate nulls the shield/fill/line calls
        # but NOT the dash call (drawSelect has no broken
        # gate); the hit clamp is [0,1]; the static fill
        # alpha is 0.09 + clamp(0.08 * hit), unclamped sum;
        # the line call exists only in the static branch.
        self.assertIn('"shield_call": null, "fill_call": null, "line_call": null, "dash_call": dash_call', base_shield)
        self.assertIn('clampf(hit, 0.0, 1.0)', base_shield)
        self.assertIn('0.09 + clampf(0.08 * hit, 0.0, 1.0)', base_shield)
        self.assertIn('"branch": "animated" if animate_shields else "static"', base_shield)
        self.assertIn('var line_call: Variant = null', base_shield)
        self.assertIn('if not animate_shields:', base_shield)
        # The documented limits record the draw rows as live
        # (N2441); the scan + advance rows stay live.
        self.assertIn('Draw rows live (N2441)', base_shield)
        self.assertIn('bullet + enemy-unit scans live (N2328)', base_shield)
        self.assertIn('updateTile advance live (N2236)', base_shield)
        # The proof's keys drive the draw-shield pure (the
        # broken gate, the animated branch, the static
        # branch alpha math, shieldColor null vs set, the
        # hit clamp, and the dashCircle FIELD radius --
        # never the smooth radius).
        proof = BASE_SHIELD_DRAW_SHIELD_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'draw_shield_broken_gate',
            'draw_shield_animated_branch',
            'draw_shield_static_alpha',
            'draw_shield_color_null_vs_set',
            'draw_shield_hit_clamp',
            'draw_select_dash_field_radius',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # Static proof-file checks (the N2185 lesson: the scene is
        # written but never run on this VM, so the test pins its
        # preloads to files that exist).
        self.assertIn('preload("res://src/game/SourceBaseShieldBuildState.gd")', proof)
        self.assertIn('base_shield_build_state.source_base_shield_draw_shield_state(', proof)
        self.assertTrue(BASE_SHIELD_STATE.is_file())
        self.assertIn('preload("res://scenes/Main.tscn")', proof)
        self.assertTrue((ROOT / 'godot-mindustry/scenes/Main.tscn').is_file())
        scene = BASE_SHIELD_DRAW_SHIELD_ROWS_PROOF_SCENE.read_text(encoding='utf-8')
        self.assertIn('C07BaseShieldDrawShieldRowsProof.gd', scene)
        self.assertIn('C07BaseShieldDrawShieldRowsProof', scene)

    def test_reference_graph_and_actual_c07_base_shield_draw_shield_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07BaseShieldDrawShieldRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_BASE_SHIELD_DRAW_SHIELD_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'draw_shield_broken_gate',
            'draw_shield_animated_branch',
            'draw_shield_static_alpha',
            'draw_shield_color_null_vs_set',
            'draw_shield_hit_clamp',
            'draw_select_dash_field_radius',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
