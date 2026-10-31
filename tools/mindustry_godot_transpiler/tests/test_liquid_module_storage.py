import json
import shutil
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / 'godot-mindustry'


class LiquidModuleStorageTests(unittest.TestCase):
    def test_storage_generated_methods_delegate_to_one_domain_owner(self):
        generated = (GODOT / 'src/generated/classes/mindustry/world/modules/LiquidModule.gd').read_text(encoding='utf-8')
        for method, index in [('get', 8), ('add', 10), ('remove', 12)]:
            with self.subTest(method=method):
                body = generated.split(f'func java_method_{method}_{index}', 1)[1].split('\nfunc ', 1)[0]
                self.assertIn(f'source_liquid_module_state.source_{method}_state(', body)
                self.assertNotIn('return null', body)
                self.assertNotIn('max(', body)
                self.assertNotIn('+=', body)

    def test_storage_contracts_and_source_evidence_are_registered(self):
        ledger = json.loads((GODOT / 'src/generated/source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        contracts = json.loads((GODOT / 'src/generated/source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        schemas = json.loads((GODOT / 'src/generated/source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        upstream = (ROOT / 'mindustry-upstream/core/src/mindustry/world/modules/LiquidModule.java').read_text(encoding='utf-8')
        for slice_id, method in [('N1993', 'get'), ('N1994', 'add'), ('N1995', 'remove')]:
            owner = f'SourceLiquidModuleState.source_{method}_state'
            with self.subTest(method=method):
                self.assertEqual(ledger[slice_id]['godot_owner'], owner)
                self.assertEqual(contracts[owner]['source_slice'], slice_id)
                for expr in ledger[slice_id]['exact_exprs']:
                    self.assertIn(expr, upstream)
                self.assertEqual(set(contracts[owner]['return_keys']), set(schemas[f'source_liquid_module_{method}_result']['keys']))
                self.assertTrue(ledger[slice_id]['deferred_exprs'])

    def test_storage_golden_runtime_and_consumption_mutation(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        if not godot:
            self.skipTest('Godot unavailable; native MCP remains required')
        result = subprocess.run([godot, '--headless', '--path', str(GODOT), '--scene', 'tools/runtime_proofs/LiquidModuleStorageProof.tscn', '--quit-after', '5'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=60)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('SCRIPT ERROR', output)
        self.assertNotIn('ERROR:', output)
        records = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('LIQUID_MODULE_STORAGE_PROOF ')]
        self.assertEqual(len(records), 1, output)
        self.assertTrue(records[0]['matches'], records[0])
        self.assertEqual(records[0]['case_count'], 15)
        self.assertTrue(records[0]['consumption_mutation_matches'])
