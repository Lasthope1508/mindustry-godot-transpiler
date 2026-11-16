import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PAYLOAD_DECONSTRUCTOR_STATE = ROOT / 'godot-mindustry/src/game/SourcePayloadDeconstructorBuildState.gd'
PAYLOAD_DECONSTRUCTOR_BAR_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorBarRowsProof.gd'
PAYLOAD_DECONSTRUCTOR_BAR_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PayloadDeconstructorBarRowsProof.tscn'


class C07PayloadDeconstructorBarRowsTests(unittest.TestCase):
    def test_c07_payload_deconstructor_bar_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2464']['godot_owner'], 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_bar_state')
        # The PayloadDeconstructor tick is live (N2210
        # shouldConsume gate + N2233 updateTile advance
        # + N2276 dump + N2291 handlePayload live fill
        # + N2297 acceptPayload / acceptUnitPayload
        # gates + N2308 intake-gate wiring + N2387
        # sense rows + N2418 draw rows) but NOTHING
        # modeled setBars(): the progress bar
        # (PayloadDeconstructor.java:45-49) shows
        # the build progress under the bar.progress
        # key in Pal.ammo with the progress RAW --
        # the Bar clamps at render (Bar.java:80),
        # the pure does NOT clamp (the N2422
        # lesson). N2464 ports it as ONE pure-only
        # pure: the bar pure takes the frame
        # progress (the N2276 advance already
        # tracks it) and returns the label + color
        # + raw fraction. Three new result symbols:
        # the bar label + color + fraction.
        self.assertEqual(
            ledger['N2464']['source_symbols'],
            [
                'source_payload_deconstructor_bar_state_result.label',
                'source_payload_deconstructor_bar_state_result.color',
                'source_payload_deconstructor_bar_state_result.fraction',
            ],
        )
        expected_owners = {
            'source_payload_deconstructor_bar_state_result.label': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_bar_state',
            'source_payload_deconstructor_bar_state_result.color': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_bar_state',
            'source_payload_deconstructor_bar_state_result.fraction': 'SourcePayloadDeconstructorBuildState.source_payload_deconstructor_bar_state',
        }
        for name in ledger['N2464']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java')
                self.assertEqual(symbol['godot_owner'], expected_owners[name])
        self.assertEqual(ledger['N2464']['runtime_proof'], '/root/C07PayloadDeconstructorBarRowsProof')
        self.assertEqual(
            ledger['N2464']['tests'],
            [
                'test_c07_payload_deconstructor_bar_rows_registration',
                'test_all_c07_payload_deconstructor_bar_rows_input_evidence_is_exact',
                'test_payload_deconstructor_bar_rows_state',
                'test_reference_graph_and_actual_c07_payload_deconstructor_bar_rows',
            ],
        )
        self.assertTrue(ledger['N2464']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #3 (1-based in
        # the merged advances-30 DEFERRED base): the
        # PayloadDeconstructor setBars row entry is
        # REMOVED -- the progress bar is live now.
        # Net 246 - 1 = 245. The read/write rows,
        # small variant, Fx.breakBlock finish effect,
        # moveInPayload live payload positioning and
        # puddles liquid dump entries STAY.
        self.assertFalse(any(entry.startswith('PayloadDeconstructor setBars row (') for entry in ledger['N2464']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor read/write rows (') for entry in ledger['N2464']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor small variant (') for entry in ledger['N2464']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor Fx.breakBlock finish effect (') for entry in ledger['N2464']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor moveInPayload live payload positioning (') for entry in ledger['N2464']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('PayloadDeconstructor puddles liquid dump (') for entry in ledger['N2464']['deferred_exprs']))
        self.assertEqual(len(ledger['N2464']['deferred_exprs']), 245)

    def test_all_c07_payload_deconstructor_bar_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2464']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertTrue(symbol['godot_owner'].startswith('SourcePayloadDeconstructorBuildState.source_payload_deconstructor_'))
        slice_sources = {
            'core/src/mindustry/world/blocks/payloads/PayloadDeconstructor.java',
            'core/src/mindustry/ui/Bar.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/assets/bundles/bundle.properties',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The Mathf clamp lives in arc, not
        # mindustry (the N2191 precedent):
        # clamp(float) clamps to [0, 1]
        # (Mathf.java:402-404).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2464']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_payload_deconstructor_bar_rows_state(self):
        payload_deconstructor = PAYLOAD_DECONSTRUCTOR_STATE.read_text(encoding='utf-8')
        # The progress bar (PayloadDeconstructor.
        # setBars(), PayloadDeconstructor.java:45-49):
        # super.setBars() then addBar("progress",
        # (PayloadDeconstructorBuild e) -> new Bar(
        # "bar.progress", Pal.ammo, () -> e.
        # progress)). The bar NAME is "progress" and
        # the label is the bundle KEY "bar.progress"
        # itself -- the 3-arg Bar constructor takes
        # the key directly (public Bar(String name,
        # Color color, Floatp fraction), Bar.java:
        # 23-29) and resolves it at render via
        # Core.bundle.get(name, name) (Bar.java:25),
        # so there is NO Core.bundle.format Dict
        # form here (the N2450 Dict form applies
        # only when Java calls Core.bundle.format
        # with args, which this bar does not).
        # The bundle value is "Build Progress"
        # (bar.progress = Build Progress, bundle.
        # properties:1299) -- the pure carries the
        # KEY, not the rendered value. The color
        # token is Pal.ammo (ammo = Color.valueOf(
        # "ff8947"), Pal.java:64), carried as a
        # symbolic token, never resolved to RGB
        # (the N2373 color-token precedent). The
        # fraction is the build progress RAW: the
        # frame value the N2233 advance tracks
        # (public float progress;, PayloadDeconstructor.
        # java:54: progress += shift with shift =
        # edelta() * deconstructSpeed /
        # deconstructing.buildTime(), :142) and
        # Java returns it AS-IS -- the 3-arg Bar
        # constructor stores it raw (lastValue =
        # value = fraction.get();, Bar.java:27) and
        # the clamp happens only at render (float
        # computed = Mathf.clamp(fraction.get());,
        # Bar.java:80; clamp to [0, 1] is return
        # Math.max(Math.min(value, 1f), 0f);, arc
        # Mathf.java:402-404) -- the N2422 lesson.
        # VERIFY-FIRST CORRECTION: the brief cited
        # Bar.java:33 for the clamp, but :33 is the
        # clamp in the OTHER (Prov-form) constructor
        # (Bar.java:31-40), which this bar does NOT
        # use -- the 3-arg form used here clamps
        # only at draw (:80). The conclusion is
        # unchanged: the pure does NOT clamp.
        # Pure-only: the tick never calls setBars.
        # Keep each Java expr on ONE comment line
        # (the N2148 lesson: a split line fails
        # this test).
        self.assertIn('static func source_payload_deconstructor_bar_state', payload_deconstructor)
        self.assertIn('public void setBars(){', payload_deconstructor)
        self.assertIn('super.setBars();', payload_deconstructor)
        self.assertIn('addBar("progress", (PayloadDeconstructorBuild e) -> new Bar("bar.progress", Pal.ammo, () -> e.progress));', payload_deconstructor)
        self.assertIn('public float progress;', payload_deconstructor)
        self.assertIn('public Bar(String name, Color color, Floatp fraction){', payload_deconstructor)
        self.assertIn('this.name = Core.bundle.get(name, name);', payload_deconstructor)
        self.assertIn('lastValue = value = fraction.get();', payload_deconstructor)
        self.assertIn('float computed = Mathf.clamp(fraction.get());', payload_deconstructor)
        self.assertIn('return Math.max(Math.min(value, 1f), 0f);', payload_deconstructor)
        self.assertIn('ammo = Color.valueOf("ff8947"),', payload_deconstructor)
        self.assertIn('bar.progress = Build Progress', payload_deconstructor)
        # The documented limits record the bar row
        # as live.
        self.assertIn('Bar row live (N2464)', payload_deconstructor)
        # The proof's keys drive the pure (the bar
        # label at several progress values, the bar
        # color, the fraction at 0.0 / 0.5 / 1.0
        # and the raw overfull 1.5).
        proof = PAYLOAD_DECONSTRUCTOR_BAR_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'bar_label',
            'bar_color',
            'bar_fraction_zero',
            'bar_fraction_half',
            'bar_fraction_full',
            'bar_fraction_raw_overfull',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the
        # N2185 lesson: check the preload target exists,
        # and the scene file exists and points at the
        # proof script).
        self.assertIn('preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")', proof)
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_STATE.exists())
        self.assertTrue(PAYLOAD_DECONSTRUCTOR_BAR_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07PayloadDeconstructorBarRowsProof.gd', PAYLOAD_DECONSTRUCTOR_BAR_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_payload_deconstructor_bar_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PayloadDeconstructorBarRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_PAYLOAD_DECONSTRUCTOR_BAR_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bar_label',
            'bar_color',
            'bar_fraction_zero',
            'bar_fraction_half',
            'bar_fraction_full',
            'bar_fraction_raw_overfull',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
