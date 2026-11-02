import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class DrillProximityLifecycleTests(unittest.TestCase):
    def test_proximity_lifecycle_contracts(self):
        contracts = json.loads((ROOT / 'godot-mindustry/src/generated/source_api_contracts.json').read_text())['contracts']
        for owner, slice_id in [('SourceDrillRuntimeState.source_on_proximity_update_state', 'N2020'), ('SourceDrillConsumptionRuntimeState.source_on_proximity_update_state', 'N2021'), ('SourceDrillConsumptionRuntimeState.source_dominant_item_name_state', 'N2022')]:
            with self.subTest(owner=owner):
                self.assertTrue(owner in contracts, owner)
                self.assertEqual(contracts[owner]['source_slice'], slice_id)

    def test_registered_evidence_and_nested_schema_references(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text())['symbols']
        schemas = json.loads((generated / 'source_state_schema.json').read_text())['schemas']
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text())['slices']
        for slice_id in ['N2020', 'N2021', 'N2022']:
            for name in ledger[slice_id]['source_symbols']:
                with self.subTest(symbol=name):
                    symbol = symbols[name]
                    source = ROOT / 'mindustry-upstream' / symbol['java_source']
                    self.assertIn(symbol['java_expr'], source.read_text(encoding='utf-8'))
        for name, schema in schemas.items():
            if schema.get('source_slice') in ['N2020', 'N2021', 'N2022']:
                for key, field in schema['keys'].items():
                    if 'schema' in field:
                        with self.subTest(schema=name, key=key):
                            self.assertIn(field['schema'], schemas)

    def test_actual_proximity_mutation_and_dominant_production(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/DrillProximityLifecycleProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('DRILL_PROXIMITY_LIFECYCLE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
