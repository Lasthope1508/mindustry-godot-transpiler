import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class SchematicPlaceBindingTests(unittest.TestCase):
    def test_schematic_place_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for sid, owner, schema, return_type, return_keys in [
            ('N2035', 'SourceSchematicPlacementState.source_apply_schematic_tile_state', 'source_apply_schematic_tile_state_input', None, ['cell', 'tile', 'build', 'placed', 'skipped', 'valid_place_checked', 'configured']),
            ('N2036', 'SourceSchematicPlacementState.source_apply_schematic_place_state', 'source_apply_schematic_place_state_input', None, ['origin', 'placed', 'skipped', 'configured', 'results']),
            ('N2037', 'PortGame.source_place_schematic_state', 'source_place_schematic_state_input', None, ['origin', 'placed', 'skipped', 'configured', 'results']),
        ]:
            with self.subTest(slice=sid):
                self.assertEqual(ledger[sid]['godot_owner'], owner)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
                self.assertTrue(ledger[sid]['deferred_exprs'])
        # N2035 threads team_id through the placement funnel: the funnel
        # keeps its defaulted sharded team for existing callers. The
        # symbol belongs to the funnel slice N2034 (owner matches), the
        # schema key is added by this batch's register script.
        with self.subTest(slice='N2035-funnel-team'):
            self.assertIn('team_id', schemas['record_placed_block_input']['keys'])
            self.assertIn('record_placed_block_input.team_id', ledger['N2034']['source_symbols'])
            funnel_symbol = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']['record_placed_block_input.team_id']
            self.assertEqual(funnel_symbol['godot_owner'], 'SourcePlacedBlockPortBridge.record_placed_block')
            self.assertIn(funnel_symbol['java_expr'], (ROOT / 'mindustry-upstream' / funnel_symbol['java_source']).read_text(encoding='utf-8'))

    def test_all_schematic_place_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for sid in ['N2035', 'N2036', 'N2037']:
            for name in ledger[sid]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                    self.assertEqual(symbol['godot_owner'], ledger[sid]['godot_owner'])

    def test_reference_graph_and_actual_schematic_place(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/SchematicPlaceProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('SCHEMATIC_PLACE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
