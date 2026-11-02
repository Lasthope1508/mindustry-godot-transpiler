import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class TerrainMutationLifecycleTests(unittest.TestCase):
    def test_terrain_lifecycle_contracts(self):
        contracts = json.loads((ROOT / 'godot-mindustry/src/generated/source_api_contracts.json').read_text())['contracts']
        for method, slice_id in [('SourceBlockGeometry.tile_floor_assignment_state', 'N2023'), ('source_set_world_floor_state', 'N2023'), ('source_clear_world_overlay_state', 'N2024'), ('source_set_world_floor_overlay_state', 'N2025'), ('source_set_world_floor_default_state', 'N2025')]:
            owner = method if '.' in method else 'SourceWorldTerrainRuntimeState.' + method
            with self.subTest(owner=owner):
                self.assertIn(owner, contracts)
                self.assertEqual(contracts[owner]['source_slice'], slice_id)

    def test_new_terrain_evidence_and_nested_schemas(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text())['symbols']
        schemas = json.loads((generated / 'source_state_schema.json').read_text())['schemas']
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text())['slices']
        for slice_id in ['N2023', 'N2024', 'N2025']:
            for name in ledger[slice_id]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
        for name, schema in schemas.items():
            if schema.get('source_slice') in ['N2023', 'N2024', 'N2025']:
                for key, field in schema['keys'].items():
                    if 'schema' in field:
                        with self.subTest(schema=name, key=key):
                            self.assertIn(field['schema'], schemas)

    def test_live_terrain_notifications_and_ordered_mutations(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/TerrainMutationLifecycleProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('TERRAIN_MUTATION_LIFECYCLE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
