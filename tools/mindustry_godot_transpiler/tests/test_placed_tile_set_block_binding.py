import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class PlacedTileSetBlockBindingTests(unittest.TestCase):
    def test_placed_tile_set_block_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for sid, owner, schema, return_type, return_keys in [
            ('N2032', 'SourceBlockGeometry.source_assign_build_team_state', 'source_assign_build_team_state_input', None, ['team_id', 'build']),
            ('N2033', 'SourceWorldTerrainRuntimeState.source_apply_placed_tile_set_block_state', 'source_apply_placed_tile_set_block_state_input', None, ['tile', 'build', 'removed_old_build', 'proximity_updated', 'changed_event_fired', 'recache_called']),
        ]:
            with self.subTest(slice=sid):
                self.assertEqual(ledger[sid]['godot_owner'], owner)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
                self.assertTrue(ledger[sid]['deferred_exprs'])
        # N2034 has no contract: the wiring lives in PortBridge
        # record_placed_block, whose name the implementation-discovery
        # rule cannot see (PortBridge files only discover source_ /
        # generated_ functions). Ledger + symbols + schema only.
        with self.subTest(slice='N2034'):
            self.assertEqual(ledger['N2034']['godot_owner'], 'SourcePlacedBlockPortBridge.record_placed_block')
            self.assertEqual(schemas['record_placed_block_input']['owner'], 'SourcePlacedBlockPortBridge.record_placed_block')
            self.assertNotIn('SourcePlacedBlockPortBridge.record_placed_block', contracts)
            self.assertTrue(ledger['N2034']['deferred_exprs'])

    def test_all_placed_tile_set_block_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for sid in ['N2032', 'N2033', 'N2034']:
            for name in ledger[sid]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                    self.assertEqual(symbol['godot_owner'], ledger[sid]['godot_owner'])

    def test_reference_graph_and_actual_placed_tile_set_block(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/PlacedTileSetBlockProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('PLACED_TILE_SET_BLOCK_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
