import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WALL_CRAFTER_STATE = ROOT / 'godot-mindustry/src/game/SourceWallCrafterBuildState.gd'
WALL_CRAFTER_BAR_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterBarRowsProof.gd'
WALL_CRAFTER_BAR_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07WallCrafterBarRowsProof.tscn'


class C07WallCrafterBarRowsTests(unittest.TestCase):
    def test_c07_wall_crafter_bar_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2465']['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_bar_state')
        # The WallCrafter tick is live (N2223 advance +
        # N2264 second consumers + N2273 timerUse +
        # N2283 timerDump + N2301 getEfficiency fill +
        # N2398 offload routing + N2426 draw rows +
        # N2459 live edge-tile scan) but NOTHING modeled
        # setBars(): the drillspeed bar (WallCrafter.
        # java:68-73) shows Strings.fixed(lastEfficiency
        # * 60 / drillTime, 2) under the bar.drillspeed
        # key in Pal.ammo with the raw warmup fraction.
        # N2465 ports it as ONE pure-only pure (the
        # N2422 bar / N2450 ImpactReactor precedent):
        # the bar pure takes the caller-supplied
        # lastEfficiency + drillTime + warmup (the frame
        # keys the N2223 advance tracks) and returns
        # the label Dict + color + raw fraction. Three
        # new result symbols: the bar label + color +
        # fraction.
        self.assertEqual(
            ledger['N2465']['source_symbols'],
            [
                'source_wall_crafter_bar_state_result.label',
                'source_wall_crafter_bar_state_result.color',
                'source_wall_crafter_bar_state_result.fraction',
            ],
        )
        for name in ledger['N2465']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/production/WallCrafter.java')
                self.assertEqual(symbol['godot_owner'], 'SourceWallCrafterBuildState.source_wall_crafter_bar_state')
        self.assertEqual(ledger['N2465']['runtime_proof'], '/root/C07WallCrafterBarRowsProof')
        self.assertEqual(
            ledger['N2465']['tests'],
            [
                'test_c07_wall_crafter_bar_rows_registration',
                'test_all_c07_wall_crafter_bar_rows_input_evidence_is_exact',
                'test_wall_crafter_bar_rows_state',
                'test_reference_graph_and_actual_c07_wall_crafter_bar_rows',
            ],
        )
        self.assertTrue(ledger['N2465']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #30 (1-based in
        # the merged advances-30 DEFERRED base): the
        # WallCrafter setBars row entry is REMOVED --
        # the drillspeed bar is live now. Net 246 - 1
        # = 245.
        self.assertFalse(any(entry.startswith('WallCrafter setBars row (') for entry in ledger['N2465']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter large variant (') for entry in ledger['N2465']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter updateTile live fill (') for entry in ledger['N2465']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter booster timer first-fire deviation (') for entry in ledger['N2465']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('WallCrafter frame items intake (') for entry in ledger['N2465']['deferred_exprs']))
        self.assertEqual(len(ledger['N2465']['deferred_exprs']), 245)

    def test_all_c07_wall_crafter_bar_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2465']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourceWallCrafterBuildState.source_wall_crafter_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/ui/Bar.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # Strings.fixed and the Mathf clamp live in
        # arc, not mindustry (the N2191 precedent):
        # fixedBuilder truncates (Strings.java:737),
        # clamp(float) clamps to [0, 1] (Mathf.
        # java:402-404).
        upstream['arc-core/src/arc/util/Strings.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/util/Strings.java').read_text(encoding='utf-8')
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2465']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_wall_crafter_bar_rows_state(self):
        wall_crafter = WALL_CRAFTER_STATE.read_text(encoding='utf-8')
        # The setBars drillspeed bar row (WallCrafter.
        # setBars(), WallCrafter.java:68-73): super.
        # setBars() then addBar("drillspeed", ...) with
        # the label lambda (Core.bundle.format("bar.
        # drillspeed", Strings.fixed(e.lastEfficiency *
        # 60 / drillTime, 2))), the color lambda (() ->
        # Pal.ammo) and the fraction lambda (() -> e.
        # warmup). lastEfficiency / warmup are the build
        # fields (WallCrafter.java:184) the N2223
        # advance tracks (lastEfficiency = eff *
        # timeScale * efficiency, WallCrafter.java:211;
        # frame keys "last_efficiency" / "warmup").
        # drillTime is the class field (150f, WallCrafter.
        # java:33) overridden by both defs (110f cliff-
        # crusher, Blocks.java:3006; 48f large-cliff-
        # crusher, Blocks.java:3020). Strings.fixed
        # TRUNCATES (arc Strings.java:737), it does NOT
        # round (the N2426 lesson). The label is the
        # bundle key + the formatted amount -- Core.
        # bundle.format composes the rendered "Drill
        # Speed: 1.09/s" at render (bar.drillspeed =
        # Drill Speed: {0}/s, bundle.properties:1279;
        # the N2450 precedent). The color token is Pal.
        # ammo (ammo = Color.valueOf("ff8947"), Pal.
        # java:64). The fraction is RAW: the Bar itself
        # clamps at render (Bar.java:33/:80; clamp to
        # [0, 1] is return Math.max(Math.min(value, 1f),
        # 0f);, Mathf.java:402-404) -- the N2422 lesson.
        # The amount formula is the SAME formula as the
        # N2426 drawPlace drillspeed text (60f /
        # drillTime * eff, WallCrafter.java:131-135),
        # modulo the Java operand order: the bar
        # multiplies lastEfficiency * 60 first, drawPlace
        # divides 60 / drillTime first -- the two agree
        # in GDScript double and the proof values sit
        # safely off any hundredth boundary. Pure-only:
        # the tick never calls setBars.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_wall_crafter_bar_state', wall_crafter)
        self.assertIn('public void setBars(){', wall_crafter)
        self.assertIn('super.setBars();', wall_crafter)
        self.assertIn('addBar("drillspeed", (WallCrafterBuild e) ->', wall_crafter)
        self.assertIn('new Bar(() -> Core.bundle.format("bar.drillspeed", Strings.fixed(e.lastEfficiency * 60 / drillTime, 2)), () -> Pal.ammo, () -> e.warmup));', wall_crafter)
        self.assertIn('public float drillTime = 150f;', wall_crafter)
        self.assertIn('public float time, warmup, totalTime, lastEfficiency;', wall_crafter)
        self.assertIn('lastEfficiency = eff * timeScale * efficiency;', wall_crafter)
        self.assertIn('cliffCrusher = new WallCrafter("cliff-crusher"){{', wall_crafter)
        self.assertIn('drillTime = 110f;', wall_crafter)
        self.assertIn('largeCliffCrusher = new WallCrafter("large-cliff-crusher"){{', wall_crafter)
        self.assertIn('drillTime = 48f;', wall_crafter)
        self.assertIn('ammo = Color.valueOf("ff8947"),', wall_crafter)
        self.assertIn('lastValue = value = Mathf.clamp(fraction.get());', wall_crafter)
        self.assertIn('float computed = Mathf.clamp(fraction.get());', wall_crafter)
        self.assertIn('dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));', wall_crafter)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', wall_crafter)
        self.assertIn('bar.drillspeed = Drill Speed: {0}/s', wall_crafter)
        self.assertIn('drawPlaceText(Core.bundle.formatFloat("bar.drillspeed", 60f / drillTime * eff, 2), x, y, valid);', wall_crafter)
        # The documented limits record the setBars row
        # as live (the old "still deferred" text is
        # gone).
        self.assertIn('SetBars rows live (N2465)', wall_crafter)
        self.assertNotIn('The setBars drillspeed bar row is still deferred', wall_crafter)
        # The proof's keys drive the bar pure (the label
        # at lastEfficiency 2.0 / drillTime 110, the
        # truncation probe 1.099 -> "1.09" + 3.125 ->
        # "3.12", the Pal.ammo color, the raw warmup
        # fraction, the def values at both defs + the
        # class default, and the zero-efficiency case).
        proof = WALL_CRAFTER_BAR_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'bar_label',
            'bar_truncation',
            'bar_color',
            'bar_fraction_warmup',
            'bar_def_values',
            'bar_zero_efficiency',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourceWallCrafterBuildState.gd")', proof)
        self.assertTrue(WALL_CRAFTER_STATE.exists())
        self.assertTrue(WALL_CRAFTER_BAR_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07WallCrafterBarRowsProof.gd', WALL_CRAFTER_BAR_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_wall_crafter_bar_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07WallCrafterBarRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_WALL_CRAFTER_BAR_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bar_label',
            'bar_truncation',
            'bar_color',
            'bar_fraction_warmup',
            'bar_def_values',
            'bar_zero_efficiency',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
