import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class TileChangeBuildSetBlockTests(unittest.TestCase):
    def test_executable_tile_change_build_set_block_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for sid, owner, schema in [
            ('N2029', 'SourceBlockGeometry.source_apply_tile_change_build', 'source_apply_tile_change_build_input'),
            ('N2030', 'SourceBlockGeometry.source_apply_tile_changed', 'source_apply_tile_changed_input'),
            ('N2031', 'SourceBlockGeometry.source_apply_tile_set_block', 'source_apply_tile_set_block_input'),
        ]:
            with self.subTest(slice=sid):
                self.assertEqual(ledger[sid]['godot_owner'], owner)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner]['return_type'], 'void')
                self.assertEqual(contracts[owner]['return_keys'], [])
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
                self.assertTrue(ledger[sid]['deferred_exprs'])

    def test_all_tile_change_build_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for sid in ['N2029', 'N2030', 'N2031']:
            for name in ledger[sid]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                    self.assertEqual(symbol['godot_owner'], ledger[sid]['godot_owner'])

    def test_reference_graph_and_actual_tile_set_block(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/TileChangeBuildSetBlockProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('TILE_CHANGE_BUILD_SET_BLOCK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
