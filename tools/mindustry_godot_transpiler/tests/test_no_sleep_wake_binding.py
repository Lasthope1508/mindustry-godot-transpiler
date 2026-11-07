import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class NoSleepWakeBindingTests(unittest.TestCase):
    def test_no_sleep_wake_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for sid, owner, schema, return_type, return_keys in [
            ('N2044', 'SourceBuildingItemState.source_handle_stack_wake_state', 'source_handle_stack_wake_state_input', None, ['count_before', 'count_after', 'sleep_time_before', 'sleep_time_after', 'sleeping_before', 'sleeping_after', 'sleeping_entities_before', 'sleeping_entities_after', 'woke', 'add_called']),
            ('N2045', 'SourceBuildingItemState.source_remove_stack_wake_state', 'source_remove_stack_wake_state_input', None, ['removed', 'remaining', 'return_value', 'sleep_time_before', 'sleep_time_after', 'sleeping_before', 'sleeping_after', 'sleeping_entities_before', 'sleeping_entities_after', 'woke', 'add_called']),
            ('N2046', 'SourceBuildingAccessState.source_on_proximity_update_wake_state', 'source_on_proximity_update_wake_state_input', None, ['sleep_time_before', 'sleep_time_after', 'sleeping_before', 'sleeping_after', 'sleeping_entities_before', 'sleeping_entities_after', 'woke', 'add_called']),
        ]:
            with self.subTest(slice=sid):
                self.assertEqual(ledger[sid]['godot_owner'], owner)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
                self.assertTrue(ledger[sid]['deferred_exprs'])

    def test_all_no_sleep_wake_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for sid in ['N2044', 'N2045', 'N2046']:
            for name in ledger[sid]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                    self.assertEqual(symbol['godot_owner'], ledger[sid]['godot_owner'])

    def test_reference_graph_and_actual_no_sleep_wake(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/NoSleepWakeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('NO_SLEEP_WAKE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
