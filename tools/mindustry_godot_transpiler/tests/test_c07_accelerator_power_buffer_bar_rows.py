import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
ACCELERATOR_POWER_BUFFER_BAR_ROWS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorPowerBufferBarRowsProof.gd'
ACCELERATOR_POWER_BUFFER_BAR_ROWS_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorPowerBufferBarRowsProof.tscn'


class C07AcceleratorPowerBufferBarRowsTests(unittest.TestCase):
    def test_c07_accelerator_power_buffer_bar_rows_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2422']['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_power_buffer_bar_state')
        # The Accelerator tick is live (N2191 advance +
        # N2271 launch + N2342 battery stamp + N2354 launch
        # drain + N2373 draw rows) but NOTHING modeled
        # setBars(): the powerBufferRequirement bar
        # (Accelerator.java:105-109) -- the bar exists only
        # when the requirement is positive, its label is
        # bar.powerbuffer with the stored + required
        # amounts, its color is Pal.powerBar, and its
        # fraction is the stored / requirement ratio. N2422
        # ports the bar as ONE pure-only bar pure (the
        # N2373 draw precedent: the pure returns the bar
        # call as data, it never draws for real, and it
        # never runs in the tick): the pure takes the
        # caller-supplied battery_stored (getBatteryStored,
        # stamped live by the N2342 graph stamp) + the
        # power_buffer_requirement and returns the gate +
        # the bar descriptor. Two new result symbols: the
        # bar-present gate and the bar descriptor.
        self.assertEqual(
            ledger['N2422']['source_symbols'],
            [
                'source_accelerator_power_buffer_bar_state_result.bar_present',
                'source_accelerator_power_buffer_bar_state_result.bar',
            ],
        )
        for name in ledger['N2422']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/campaign/Accelerator.java')
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_power_buffer_bar_state')
        self.assertEqual(ledger['N2422']['runtime_proof'], '/root/C07AcceleratorPowerBufferBarRowsProof')
        self.assertEqual(
            ledger['N2422']['tests'],
            [
                'test_c07_accelerator_power_buffer_bar_rows_registration',
                'test_all_c07_accelerator_power_buffer_bar_rows_input_evidence_is_exact',
                'test_accelerator_power_buffer_bar_rows_state',
                'test_reference_graph_and_actual_c07_accelerator_power_buffer_bar_rows',
            ],
        )
        self.assertTrue(ledger['N2422']['deferred_exprs'])
        # This slice RESOLVES DEFERRED #95 (1-based in
        # DEFERRED-after-advances-24.py): the Accelerator
        # powerBufferRequirement bar rows entry is REMOVED
        # -- the bar is live now, so nothing of the entry
        # remains. The UI.formatAmount rendering is a UI
        # concern, not a new deferral: the pure returns
        # the raw long amounts and the formatted
        # "Batteries: X/Y" string is built by the UI
        # layer (UI.java:781-800). Net 286 - 1 = 285.
        self.assertFalse(any(entry.startswith('Accelerator powerBufferRequirement bar rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator progress / isCoreBuilt rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator draw launching-branch rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator getCursor rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch animator rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launchTime / cloudSeed rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator per-def stat rows (') for entry in ledger['N2422']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator shouldConsume gate') for entry in ledger['N2422']['deferred_exprs']))
        self.assertEqual(len(ledger['N2422']['deferred_exprs']), 285)

    def test_all_c07_accelerator_power_buffer_bar_rows_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2422']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceAcceleratorBuildState.source_accelerator_power_buffer_bar_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/ui/Bar.java',
            'core/src/mindustry/core/UI.java',
            'core/src/mindustry/graphics/Pal.java',
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        # The clamp the Bar applies at render lives in Arc:
        # Mathf.clamp(float) clamps to [0, 1]
        # (Mathf.java:402-404, the N2191 precedent).
        upstream['arc-core/src/arc/math/Mathf.java'] = (ROOT / 'arc-upstream/arc-core/src/arc/math/Mathf.java').read_text(encoding='utf-8')
        for expr in ledger['N2422']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_power_buffer_bar_rows_state(self):
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The powerBufferRequirement bar (Accelerator.
        # setBars(), Accelerator.java:100-111): super.
        # setBars() + the gate (if(powerBufferRequirement
        # > 0f)) + addBar("powerBufferRequirement", b ->
        # new Bar(...)) with the label lambda (Core.bundle.
        # format("bar.powerbuffer", UI.formatAmount((long)
        # b.power.graph.getBatteryStored()), UI.formatAmount
        # ((long)powerBufferRequirement))), the color
        # lambda (() -> Pal.powerBar) and the fraction
        # lambda (() -> b.power.graph.getBatteryStored() /
        # powerBufferRequirement). The requirement is the
        # class field (public float powerBufferRequirement;,
        # Accelerator.java:41), set by the single def to
        # 1,000,000f (Blocks.java:6826). The Bar itself
        # clamps the fraction at render (lastValue = value
        # = Mathf.clamp(fraction.get()); in the
        # constructor, float computed = Mathf.clamp(
        # fraction.get()); in draw(), Bar.java; clamp to
        # [0, 1] is return Math.max(Math.min(value, 1f),
        # 0f);, Mathf.java:402-404) -- so the pure returns
        # the RAW fraction and a stored battery above the
        # requirement reports above 1.0. The label amounts
        # are raw longs: UI.formatAmount (public static
        # String formatAmount(long number){, UI.java:781)
        # renders the magnitude suffixes + [gray] markup,
        # which is a UI concern the pure does not build.
        # The color token is Pal.powerBar (powerBar =
        # Color.valueOf("ec7b4c"), Pal.java:93). The stored
        # battery is getBatteryStored (public float
        # getBatteryStored(){, PowerGraph.java:118), a
        # caller-supplied pure input -- the pure never
        # queries the power graph itself.
        # Keep each Java expr on ONE comment line (the N2148
        # lesson: a split line fails this test).
        self.assertIn('static func source_accelerator_power_buffer_bar_state', accelerator)
        self.assertIn('if(powerBufferRequirement > 0f){', accelerator)
        self.assertIn('addBar("powerBufferRequirement", b -> new Bar(', accelerator)
        self.assertIn('() -> Core.bundle.format("bar.powerbuffer",UI.formatAmount((long)b.power.graph.getBatteryStored()),  UI.formatAmount((long)powerBufferRequirement)),', accelerator)
        self.assertIn('() -> Pal.powerBar,', accelerator)
        self.assertIn('() -> b.power.graph.getBatteryStored() / powerBufferRequirement', accelerator)
        self.assertIn('public float powerBufferRequirement;', accelerator)
        self.assertIn('powerBufferRequirement = 1_000_000f;', accelerator)
        self.assertIn('lastValue = value = Mathf.clamp(fraction.get());', accelerator)
        self.assertIn('float computed = Mathf.clamp(fraction.get());', accelerator)
        self.assertIn('public static String formatAmount(long number){', accelerator)
        self.assertIn('powerBar = Color.valueOf("ec7b4c"),', accelerator)
        self.assertIn('public float getBatteryStored(){', accelerator)
        # The documented limits record the bar rows as live
        # (the old "still waits for its own slice" bar text
        # is gone).
        self.assertIn('Bar rows live (N2422)', accelerator)
        self.assertNotIn('the powerBufferRequirement bar (Accelerator.java:105-109) still waits for its own slice.', accelerator)
        # The proof's keys drive the bar pure (the bar
        # present at a positive requirement, the bar absent
        # at requirement 0, the label amounts, the
        # powerBar color, the fraction math, and the raw
        # overfull fraction above 1.0 -- the Bar clamps at
        # render, so the pure reports the raw ratio).
        proof = ACCELERATOR_POWER_BUFFER_BAR_ROWS_PROOF.read_text(encoding='utf-8')
        for key in [
            'bar_present_requirement_positive',
            'bar_absent_requirement_zero',
            'bar_label_amounts',
            'bar_color_power_bar',
            'bar_fraction_math',
            'bar_fraction_overfull_raw',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        # The proof preloads the family state file (the N2185
        # lesson: check the preload target exists, and the
        # scene file exists and points at the proof script).
        self.assertIn('preload("res://src/game/SourceAcceleratorBuildState.gd")', proof)
        self.assertTrue(ACCELERATOR_STATE.exists())
        self.assertTrue(ACCELERATOR_POWER_BUFFER_BAR_ROWS_PROOF_SCENE.exists())
        self.assertIn('C07AcceleratorPowerBufferBarRowsProof.gd', ACCELERATOR_POWER_BUFFER_BAR_ROWS_PROOF_SCENE.read_text(encoding='utf-8'))

    def test_reference_graph_and_actual_c07_accelerator_power_buffer_bar_rows(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorPowerBufferBarRowsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_POWER_BUFFER_BAR_ROWS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'bar_present_requirement_positive',
            'bar_absent_requirement_zero',
            'bar_label_amounts',
            'bar_color_power_bar',
            'bar_fraction_math',
            'bar_fraction_overfull_raw',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
