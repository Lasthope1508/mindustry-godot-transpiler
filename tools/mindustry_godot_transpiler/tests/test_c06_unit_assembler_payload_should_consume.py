import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
SHOULD_CONSUME_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.gd'


class C06UnitAssemblerPayloadShouldConsumeTests(unittest.TestCase):
    def test_c06_unit_assembler_payload_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        self.assertEqual(ledger['N2132']['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_should_consume_state')
        # The wiring adds no new symbol: it makes the already-registered
        # shouldConsume payload_efficiency result live, reading it from
        # the N2129 payload module instead of the frame default (1.0).
        self.assertEqual(
            ledger['N2132']['source_symbols'],
            ['source_unit_factory_should_consume_state_result.payload_efficiency'],
        )
        symbol = symbols['source_unit_factory_should_consume_state_result.payload_efficiency']
        self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_should_consume_state')
        self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/consumers/ConsumePayloadDynamic.java')
        self.assertEqual(ledger['N2132']['runtime_proof'], '/root/C06UnitFactoryShouldConsumeProof')
        self.assertEqual(
            ledger['N2132']['tests'],
            [
                'test_c06_unit_assembler_payload_should_consume_registration',
                'test_all_c06_unit_assembler_payload_should_consume_input_evidence_is_exact',
                'test_assembler_payload_efficiency_gates_should_consume',
                'test_reference_graph_and_actual_c06_unit_assembler_payload_should_consume',
            ],
        )
        self.assertTrue(ledger['N2132']['deferred_exprs'])

    def test_all_c06_unit_assembler_payload_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2132']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_should_consume_state')
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/world/consumers/ConsumePayloadDynamic.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2132']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_assembler_payload_efficiency_gates_should_consume(self):
        factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        gate = factory.split('static func source_unit_factory_should_consume_state')[1].split('static func source_unit_factory_tick_buildings_state')[0]
        # The assembler branch reads consPayload.efficiency live from
        # the payload module (N2129) instead of the frame default.
        self.assertIn('source_unit_factory_assembler_payload_state(frame, plan)', gate)
        self.assertNotIn('frame.get("payload_efficiency", 1.0)', gate)
        self.assertNotIn('It is not wired into the shouldConsume', factory)
        # The N2124 proof's assembler keys read the live module now: a
        # blocks-less assembler reads 0.0 (Java behavior), a full one
        # reads 1.0.
        proof = SHOULD_CONSUME_PROOF.read_text(encoding='utf-8')
        for key in [
            'should_consume_assembler_default_false',
            'should_consume_assembler_full_blocks_true',
            'should_consume_assembler_short_blocks_false',
            'should_consume_live_assembler_efficiency_zero',
            'should_consume_live_assembler_unoccupied_zero',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)
        for key in [
            'should_consume_assembler_default_true',
            'should_consume_assembler_no_payload_eff_false',
            'should_consume_live_assembler_efficiency_one',
            'should_consume_live_assembler_unoccupied_one',
        ]:
            with self.subTest(key=key):
                self.assertNotIn(key, proof)

    def test_reference_graph_and_actual_c06_unit_assembler_payload_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_UNIT_FACTORY_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'should_consume_assembler_default_false',
            'should_consume_assembler_full_blocks_true',
            'should_consume_assembler_short_blocks_false',
            'should_consume_live_assembler_efficiency_zero',
            'should_consume_live_assembler_unoccupied_zero',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
