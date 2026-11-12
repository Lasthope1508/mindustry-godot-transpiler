import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PLACED_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_RUNTIME = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
POWER_STATUS_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C07PowerStatusLiveProof.gd'


class C07PowerStatusLiveTests(unittest.TestCase):
    def test_c07_power_status_live_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2142']['godot_owner'], 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state')
        # N2141 stamped live per-type unit counts into the frame,
        # but the frame's power_status is still never written: the
        # live loop runs the graph update every tick before the
        # factory tick (SourceFactoryRuntimeState.gd:163 vs :192)
        # yet only writes battery statuses back to sprite meta,
        # dropping every consumer's computed power.status. The
        # unit-factory driver therefore reads
        # frame.get("power_status", null) and the null folds to
        # 1.0 (UnitAssembler.java:469, `float powerStatus =
        # !enabled ? 0f : power == null ? 1f : power.status;`),
        # so an assembler with no power still runs at full
        # powerStatus. N2142 is the power.status live read: a
        # read/write pair on the placed building's frame (the
        # battery pattern, N2082/N2083) plus the live-loop
        # write-back of every updated consumer's status, so the
        # driver reads a live value. The distributePower pure
        # function already exists
        # (SourcePowerGraphBatteryDistributionState.
        # distribute_power_state) -- composition, not
        # re-implementation. Five new result symbols: three for
        # the read, two for the write.
        self.assertEqual(
            ledger['N2142']['source_symbols'],
            [
                'source_consumer_power_status_for_cell_state_result.status',
                'source_consumer_power_status_for_cell_state_result.found',
                'source_consumer_power_status_for_cell_state_result.reason',
                'source_consumer_set_power_status_for_cell_state_result.stored',
                'source_consumer_set_power_status_for_cell_state_result.reason',
            ],
        )
        for name in ledger['N2142']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_source'], {
                    'core/src/mindustry/world/blocks/power/PowerGraph.java',
                    'core/src/mindustry/world/consumers/ConsumePower.java',
                })
                self.assertEqual(symbol['godot_owner'], {
                    'source_consumer_power_status_for_cell_state_result.status': 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state',
                    'source_consumer_power_status_for_cell_state_result.found': 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state',
                    'source_consumer_power_status_for_cell_state_result.reason': 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state',
                    'source_consumer_set_power_status_for_cell_state_result.stored': 'SourcePlacedPowerGraphState.source_consumer_set_power_status_for_cell_state',
                    'source_consumer_set_power_status_for_cell_state_result.reason': 'SourcePlacedPowerGraphState.source_consumer_set_power_status_for_cell_state',
                }[name])
        self.assertEqual(ledger['N2142']['runtime_proof'], '/root/C07PowerStatusLiveProof')
        self.assertEqual(
            ledger['N2142']['tests'],
            [
                'test_c07_power_status_live_registration',
                'test_all_c07_power_status_live_input_evidence_is_exact',
                'test_consumer_power_status_state',
                'test_reference_graph_and_actual_c07_power_status_live',
            ],
        )
        self.assertTrue(ledger['N2142']['deferred_exprs'])

    def test_all_c07_power_status_live_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2142']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], {
                    'source_consumer_power_status_for_cell_state_result.status': 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state',
                    'source_consumer_power_status_for_cell_state_result.found': 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state',
                    'source_consumer_power_status_for_cell_state_result.reason': 'SourcePlacedPowerGraphState.source_consumer_power_status_for_cell_state',
                    'source_consumer_set_power_status_for_cell_state_result.stored': 'SourcePlacedPowerGraphState.source_consumer_set_power_status_for_cell_state',
                    'source_consumer_set_power_status_for_cell_state_result.reason': 'SourcePlacedPowerGraphState.source_consumer_set_power_status_for_cell_state',
                }[name])
        slice_sources = {
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/world/modules/PowerModule.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2142']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_consumer_power_status_state(self):
        placed = PLACED_STATE.read_text(encoding='utf-8')
        runtime = FACTORY_RUNTIME.read_text(encoding='utf-8')
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        # The read/write pair lives on the placed graph state,
        # following the battery pattern (N2082/N2083): the read
        # returns the frame's stored power.status (PowerModule
        # default 0.0, PowerModule.java:13), the write stores the
        # distributePower result (PowerGraph.java:203,
        # `consumer.power.status = coverage;`).
        self.assertIn('static func source_consumer_power_status_for_cell_state', placed)
        self.assertIn('static func source_consumer_set_power_status_for_cell_state', placed)
        self.assertIn('return build.power.status;', placed)
        self.assertIn('consumer.power.status = coverage;', placed)
        self.assertIn('public float status = 0.0f;', placed)
        # The live loop writes each updated consumer's computed
        # status back to its building frame (battery pattern),
        # before the factory tick runs, so the driver reads live
        # power_status instead of the null fold; the stale "no
        # power_status yet" comment is gone.
        self.assertIn('source_consumer_set_power_status_for_cell_state(', runtime)
        self.assertNotIn('the frame records no power_status yet', factory)
        # The proof's keys drive the set/read round-trip (missing
        # sprite, missing frame) plus the distributePower coverage
        # math (half / full / buffered accumulate) directly.
        proof = POWER_STATUS_PROOF.read_text(encoding='utf-8')
        for key in [
            'consumer_set_read_roundtrip',
            'consumer_read_missing_sprite',
            'consumer_read_no_frame',
            'consumer_set_no_frame',
            'distribute_coverage_half',
            'distribute_coverage_full',
            'distribute_buffered_accumulates',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c07_power_status_live(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C07PowerStatusLiveProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_07_POWER_STATUS_LIVE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'consumer_set_read_roundtrip',
            'consumer_read_missing_sprite',
            'consumer_read_no_frame',
            'consumer_set_no_frame',
            'distribute_coverage_half',
            'distribute_coverage_full',
            'distribute_buffered_accumulates',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
