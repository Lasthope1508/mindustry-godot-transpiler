import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class DrillBridgeDominantBindingTests(unittest.TestCase):
    def test_drill_bridge_dominant_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for sid, owner, schema, return_type, return_keys in [
            ('N2071', 'PortGame.source_drill_runtime_state', 'source_drill_runtime_state_input', 'Dictionary', ['drill_active', 'drill_warmup_before', 'drill_warmup', 'drill_last_speed_before', 'drill_last_speed', 'drill_time_drilled_before', 'drill_time_drilled_delta', 'drill_time_drilled', 'drill_delay', 'drill_output_delta', 'production_state', 'offload_amount', 'produced_delta', 'item_progress', 'source_owner']),
        ]:
            with self.subTest(slice=sid):
                self.assertEqual(ledger[sid]['godot_owner'], owner)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
                self.assertTrue(ledger[sid]['deferred_exprs'])

    def test_all_drill_bridge_dominant_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for sid in ['N2071']:
            for name in ledger[sid]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                    self.assertEqual(symbol['godot_owner'], ledger[sid]['godot_owner'])

    def test_reference_graph_and_actual_drill_bridge_dominant(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/DrillBridgeDominantProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('DRILL_BRIDGE_DOMINANT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
