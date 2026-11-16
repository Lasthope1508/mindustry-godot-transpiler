import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PLACED_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
ACCELERATOR_STATE = ROOT / 'godot-mindustry/src/game/SourceAcceleratorBuildState.gd'
BATTERY_STAMP_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorBatteryStampProof.gd'
BATTERY_STAMP_PROOF_SCENE = ROOT / 'godot-mindustry/tools/runtime_proofs/C07AcceleratorBatteryStampProof.tscn'


class C07AcceleratorBatteryStampTests(unittest.TestCase):
    def test_c07_accelerator_battery_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2342']['godot_owner'], 'SourcePlacedPowerGraphState.source_accelerator_set_battery_stored_for_cell_state')
        # The N2271 canLaunch gate reads frame["battery_stored"]
        # (getBatteryStored, PowerGraph.java:118-127, the
        # enabled-battery total) and the graph summary computes
        # battery_stored (SourcePlacedPowerGraphState.gd:303) but
        # never stamped it on the building frame, so a live
        # accelerator read the frame input as-is (default 0.0)
        # and the gate stayed closed. N2342 is the graph stamp:
        # a pure parallel to
        # source_consumer_set_power_status_for_cell_state
        # (N2142) that stamps frame["battery_stored"] for
        # accelerator frames ONLY (the source_accelerator_building
        # meta key), wired into the distribute step in
        # SourceFactoryRuntimeState.gd, where the battery total
        # is recomputed from the UPDATED batteries (the same
        # post-use/charge list the battery write-back reads).
        # Two new result symbols: stored + reason.
        self.assertEqual(
            ledger['N2342']['source_symbols'],
            [
                'source_accelerator_set_battery_stored_for_cell_state_result.stored',
                'source_accelerator_set_battery_stored_for_cell_state_result.reason',
            ],
        )
        for name in ledger['N2342']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/power/PowerGraph.java')
                self.assertEqual(symbol['godot_owner'], 'SourcePlacedPowerGraphState.source_accelerator_set_battery_stored_for_cell_state')
        self.assertEqual(ledger['N2342']['runtime_proof'], '/root/C07AcceleratorBatteryStampProof')
        self.assertEqual(
            ledger['N2342']['tests'],
            [
                'test_c07_accelerator_battery_stamp_registration',
                'test_all_c07_accelerator_battery_stamp_input_evidence_is_exact',
                'test_accelerator_battery_stamp_state',
                'test_reference_graph_and_actual_c07_accelerator_battery_stamp',
            ],
        )
        self.assertTrue(ledger['N2342']['deferred_exprs'])
        # DEFERRED #236 is REWRITTEN in place, not resolved
        # outright: the battery_stored live fill is live since
        # this slice, but the per-battery proportional status
        # scaling (PowerGraph.java:160-165) still waits for a
        # battery-list graph slice -- the port graph summary
        # carries only the total, no battery list.
        self.assertFalse(any(entry.startswith('Accelerator battery_stored live fill + per-battery useBatteries scaling (') for entry in ledger['N2342']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator per-battery useBatteries scaling (') for entry in ledger['N2342']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator powerBufferRequirement bar rows (') for entry in ledger['N2342']['deferred_exprs']))
        self.assertTrue(any(entry.startswith('Accelerator launch rows (') for entry in ledger['N2342']['deferred_exprs']))

    def test_all_c07_accelerator_battery_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2342']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourcePlacedPowerGraphState.source_accelerator_set_battery_stored_for_cell_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/world/blocks/campaign/Accelerator.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2342']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_accelerator_battery_stamp_state(self):
        placed = PLACED_STATE.read_text(encoding='utf-8')
        runtime = FACTORY_RUNTIME.read_text(encoding='utf-8')
        accelerator = ACCELERATOR_STATE.read_text(encoding='utf-8')
        # The stamp pure lives on the placed graph state,
        # parallel to the N2142 power_status write: it stamps
        # frame["battery_stored"] with the getBatteryStored
        # total (PowerGraph.java:118-127, `totalAccumulator +=
        # battery.power.status * battery.block.consPower.
        # capacity;` over enabled batteries) and ONLY touches
        # accelerator frames (the source_accelerator_building
        # meta key, SourceAcceleratorBuildState.gd:14) -- the
        # stored total is meaningless for non-accelerators.
        self.assertIn('static func source_accelerator_set_battery_stored_for_cell_state', placed)
        self.assertIn('totalAccumulator += battery.power.status * battery.block.consPower.capacity;', placed)
        self.assertIn('SOURCE_ACCELERATOR_BUILDING_META_KEY', placed)
        self.assertIn('frame["battery_stored"] = battery_stored', placed)
        # The driver is NOT touched by this slice: it already
        # reads frame["battery_stored"] since N2271 (the
        # canLaunch gate + the launch drain).
        self.assertIn('float(frame.get("battery_stored", 0.0))', accelerator)
        # The distribute step wires the stamp: the battery total
        # is recomputed from the UPDATED batteries (the same
        # post-use/charge list the battery write-back reads; on
        # the cheat branch the distribute state is empty and the
        # top-level batteries -- unchanged, since the
        # distribution never ran -- are the source instead), and
        # every updated consumer's origin cell gets the stamp
        # call -- the pure itself only stamps accelerator
        # frames. The power_status write-back above is untouched.
        self.assertIn('source_accelerator_set_battery_stored_for_cell_state(game, consumer.get("origin_cell"), battery_stored)', runtime)
        self.assertIn('battery_state(stored_batteries)', runtime)
        self.assertIn('source_consumer_set_power_status_for_cell_state(game, consumer.get("origin_cell"), float(consumer.get("power_status", 0.0)))', runtime)
        # The proof's keys drive the stamp on an accelerator
        # frame (set + overwrite of a stale 0.0), the two
        # no-stamp branches (missing sprite, non-accelerator
        # sprite -- bare or other-family frame) and the
        # getBatteryStored total math the wiring feeds the stamp.
        proof = BATTERY_STAMP_PROOF.read_text(encoding='utf-8')
        for key in [
            'accelerator_set_stamps_frame',
            'accelerator_set_missing_sprite',
            'accelerator_set_not_accelerator',
            'accelerator_set_no_frame',
            'accelerator_set_overwrites_stale',
            'battery_stored_total_from_batteries',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        self.assertTrue(BATTERY_STAMP_PROOF_SCENE.exists())

    def test_reference_graph_and_actual_c07_accelerator_battery_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07AcceleratorBatteryStampProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_ACCELERATOR_BATTERY_STAMP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'accelerator_set_stamps_frame',
            'accelerator_set_missing_sprite',
            'accelerator_set_not_accelerator',
            'accelerator_set_no_frame',
            'accelerator_set_overwrites_stale',
            'battery_stored_total_from_batteries',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
