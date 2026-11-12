import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONVEYOR_RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceConveyorRuntimeState.gd'
DISABLED_BELT_PROOF = ROOT / 'godot-mindustry/tools/runtime_proofs/C06DisabledBeltEfficiencyProof.gd'


class C06DisabledBeltEfficiencyTests(unittest.TestCase):
    def test_c06_disabled_belt_efficiency_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        self.assertEqual(ledger['N2135']['godot_owner'], 'SourceConveyorRuntimeState.source_conveyor_advance_state')
        # A conveyor carries no consumers, so updateConsumption
        # (BuildingComp.java:1943-1948) sets efficiency to 1 when
        # enabled and to 0 when disabled. The port's
        # source_conveyor_advance_state hardcodes efficiency 1 in
        # `moved := speed * delta * time_scale`, so a disabled belt
        # still advances; this slice gives the advance step its own
        # per-belt efficiency input.
        self.assertEqual(
            ledger['N2135']['source_symbols'],
            ['source_conveyor_advance_state_input.efficiency'],
        )
        symbol = symbols['source_conveyor_advance_state_input.efficiency']
        self.assertEqual(symbol['godot_owner'], 'SourceConveyorRuntimeState.source_conveyor_advance_state')
        self.assertEqual(symbol['java_source'], 'core/src/mindustry/world/blocks/distribution/Conveyor.java')
        self.assertEqual(symbol['java_method'], 'ConveyorBuild.updateTile()')
        # The new input joins the existing advance contract params
        # (trailing, so every existing caller keeps working) and the
        # existing advance input schema keys.
        self.assertEqual(contracts['SourceConveyorRuntimeState.source_conveyor_advance_state']['params'][-1]['name'], 'efficiency')
        self.assertIn('efficiency', schemas['source_conveyor_advance_state_input']['keys'])
        self.assertEqual(ledger['N2135']['runtime_proof'], '/root/C06DisabledBeltEfficiencyProof')
        self.assertEqual(
            ledger['N2135']['tests'],
            [
                'test_c06_disabled_belt_efficiency_registration',
                'test_all_c06_disabled_belt_efficiency_input_evidence_is_exact',
                'test_disabled_belt_efficiency_reads_efficiency',
                'test_reference_graph_and_actual_c06_disabled_belt_efficiency',
            ],
        )
        self.assertTrue(ledger['N2135']['deferred_exprs'])

    def test_all_c06_disabled_belt_efficiency_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2135']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], ledger['N2135']['godot_owner'])
        slice_sources = {
            'core/src/mindustry/world/blocks/distribution/Conveyor.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2135']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_disabled_belt_efficiency_reads_efficiency(self):
        advance = CONVEYOR_RUNTIME_STATE.read_text(encoding='utf-8')
        # The advance step takes a trailing per-belt efficiency
        # (default 1.0, so the enabled belt and every existing caller
        # are unaffected) and moves items by speed * edelta():
        # speed * delta * time_scale * efficiency. A disabled belt
        # reads efficiency 0 in Java, so moved is 0 and the belt is
        # frozen: no y progress, no x drift toward 0, no exit pass.
        self.assertIn('efficiency := 1.0', advance)
        self.assertIn('var moved := speed * delta * time_scale * efficiency', advance)
        # The new proof scene covers the advance step: a disabled
        # belt (efficiency 0) is frozen in y and x and reports no
        # exit pass, an enabled belt advances, and half efficiency
        # moves items half as far.
        proof = DISABLED_BELT_PROOF.read_text(encoding='utf-8')
        for key in [
            'disabled_belt_ys_frozen',
            'disabled_belt_xs_frozen',
            'disabled_belt_no_pass_ready',
            'enabled_belt_advances',
            'half_efficiency_half_moved',
        ]:
            with self.subTest(key=key):
                self.assertIn(key, proof)

    def test_reference_graph_and_actual_c06_disabled_belt_efficiency(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06DisabledBeltEfficiencyProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_DISABLED_BELT_EFFICIENCY_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
        for key in [
            'disabled_belt_ys_frozen',
            'disabled_belt_xs_frozen',
            'disabled_belt_no_pass_ready',
            'enabled_belt_advances',
            'half_efficiency_half_moved',
        ]:
            with self.subTest(key=key):
                self.assertTrue(proofs[0][key], proofs[0])


if __name__ == '__main__':
    unittest.main()
