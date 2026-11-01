import json
import shutil
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / 'godot-mindustry'
METHODS = [('initial', 'java_initialize_state', 'N1996'), ('current', 'java_method_current_4', 'N1996'), ('current_amount', 'java_method_currentAmount_7', 'N1996'), ('clear', 'java_method_clear_9', 'N1997'), ('reset', 'java_method_reset_5', 'N1997'), ('set', 'java_method_set_6', 'N1998')]


class LiquidModuleLifecycleTests(unittest.TestCase):
    def test_lifecycle_adapters_delegate_to_existing_storage_owner(self):
        text = (GODOT / 'src/generated/classes/mindustry/world/modules/LiquidModule.gd').read_text(encoding='utf-8')
        for method, adapter, _ in METHODS:
            with self.subTest(method=method):
                body = text.split(f'func {adapter}', 1)[1].split('\nfunc ', 1)[0]
                self.assertIn(f'source_liquid_module_state.source_{method}_state(', body)
                for fragment in ['return null', '.fill(', '.resize(', '>=', '["liquids"]']:
                    self.assertNotIn(fragment, body)

    def test_lifecycle_source_contracts_and_shared_frame_are_registered(self):
        base = GODOT / 'src/generated'
        ledger = json.loads((base / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        contracts = json.loads((base / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        schemas = json.loads((base / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        upstream = (ROOT / 'mindustry-upstream/core/src/mindustry/world/modules/LiquidModule.java').read_text(encoding='utf-8')
        for method, _, slice_id in METHODS:
            with self.subTest(method=method):
                owner = f'SourceLiquidModuleState.source_{method}_state'
                self.assertIn(owner, ledger[slice_id]['godot_owner'])
                self.assertEqual(contracts[owner]['source_slice'], slice_id)
                self.assertEqual(set(contracts[owner]['return_keys']), set(schemas[f'source_liquid_module_{method}_result']['keys']))
                for expr in ledger[slice_id]['exact_exprs']:
                    self.assertIn(expr, upstream)
                self.assertTrue(ledger[slice_id]['deferred_exprs'])

    def test_lifecycle_golden_runtime_and_initialized_consumption(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        if not godot:
            self.skipTest('Godot unavailable; native MCP remains required')
        run = subprocess.run([godot, '--headless', '--path', str(GODOT), '--scene', 'tools/runtime_proofs/LiquidModuleLifecycleProof.tscn', '--quit-after', '5'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=60)
        output = run.stdout + run.stderr
        self.assertEqual(run.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        self.assertNotIn('SCRIPT ERROR', output)
        records = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('LIQUID_MODULE_LIFECYCLE_PROOF ')]
        self.assertEqual(len(records), 1, output)
        self.assertTrue(records[0]['matches'], records[0])
        self.assertEqual(records[0]['case_count'], 19)
        self.assertTrue(records[0]['initialized_consumption_matches'])
