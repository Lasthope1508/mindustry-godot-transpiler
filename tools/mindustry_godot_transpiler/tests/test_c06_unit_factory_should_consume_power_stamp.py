import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PLACED_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
POWER_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C06PowerShouldConsumeProof.gd'


class C06UnitFactoryShouldConsumePowerStampTests(unittest.TestCase):
    def test_c06_unit_factory_should_consume_power_stamp_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2136']['godot_owner'], 'SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state')
        # The wiring adds no new symbol: it makes the already-registered
        # shouldConsume result live, reading it from the N2124
        # per-class bodies instead of the frame's enabled flag.
        self.assertEqual(
            ledger['N2136']['source_symbols'],
            ['source_unit_factory_should_consume_state_result.should_consume'],
        )
        symbol = symbols['source_unit_factory_should_consume_state_result.should_consume']
        self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_should_consume_state')
        self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/units/UnitFactory.java')
        self.assertEqual(ledger['N2136']['runtime_proof'], '/root/C06PowerShouldConsumeProof')
        self.assertEqual(
            ledger['N2136']['tests'],
            [
                'test_c06_unit_factory_should_consume_power_stamp_registration',
                'test_all_c06_unit_factory_should_consume_power_stamp_input_evidence_is_exact',
                'test_unit_factory_should_consume_wires_into_power_stamp',
                'test_reference_graph_and_actual_c06_unit_factory_should_consume_power_stamp',
            ],
        )
        self.assertTrue(ledger['N2136']['deferred_exprs'])

    def test_all_c06_unit_factory_should_consume_power_stamp_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2136']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitFactory.java',
            'core/src/mindustry/world/blocks/units/Reconstructor.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2136']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_unit_factory_should_consume_wires_into_power_stamp(self):
        placed = PLACED_STATE.read_text(encoding='utf-8')
        helper = placed.split('static func source_consumer_should_consume_for_cell_state')[1].split('static func source_group_buildings_by_origin_state')[0]
        # The stamp calls the unit-factory family's per-class
        # shouldConsume (N2124) for the unit-factory frame, the same
        # pattern as the factory and adjacent-factory branches above
        # it, instead of the enabled-only fallthrough.
        self.assertIn('source_unit_factory_build_state', placed)
        self.assertIn('source_unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY', helper)
        self.assertIn('source_unit_factory_should_consume_state(frame, block, game)', helper)
        self.assertNotIn('are not wired to the stamp yet', placed)
        # The power proof's new stamp keys read the gate through the
        # helper on live placed factories.
        proof = POWER_PROOF.read_text(encoding='utf-8')
        for key in [
            'stamp_unit_factory_no_plan_false',
            'stamp_unit_factory_plan_true',
            'stamp_unit_factory_disabled_false',
            'stamp_unit_reconstructor_no_payload_false',
            'stamp_unit_assembler_default_false',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c06_unit_factory_should_consume_power_stamp(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06PowerShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_POWER_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'stamp_unit_factory_no_plan_false',
            'stamp_unit_factory_plan_true',
            'stamp_unit_factory_disabled_false',
            'stamp_unit_reconstructor_no_payload_false',
            'stamp_unit_assembler_default_false',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
