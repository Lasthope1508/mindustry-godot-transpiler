import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'


class FactoryUpdateConsumptionTests(unittest.TestCase):
    def test_factory_update_consumption_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2111']['godot_owner'], 'SourceFactoryBuildState.source_factory_update_consumption_state')
        for owner, schema, return_type, return_keys in [
            ('SourceFactoryBuildState.source_factory_update_consumption_state', 'source_factory_update_consumption_state_input', 'Dictionary', ['cheating', 'skipped_consumption', 'potential_efficiency', 'efficiency', 'optional_efficiency', 'should_consume_power']),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], 'N2111')
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(len(ledger['N2111']['source_symbols']), 12)
        self.assertTrue(ledger['N2111']['deferred_exprs'])

    def test_all_factory_update_consumption_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2111']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceFactoryBuildState.source_factory_update_consumption_state',))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2111']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_update_consumption_reads_frame_cheating(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_factory_update_consumption_state(frame: Dictionary, has_consumers: bool, enabled: bool, production_valid: bool, should_consume: bool, efficiency_scale: float) -> Dictionary:', factory)
        consumption = factory.split('static func source_factory_update_consumption_state')[1].split('static func source_factory_tick_buildings_state')[0]
        self.assertIn('update_consumption_state(', consumption)
        self.assertIn('frame.get("cheating", false)', consumption)
        self.assertIn('"skipped_consumption"', consumption)
        self.assertIn('not has_consumers or cheating', consumption)
        self.assertIn('PORT_GAME_SOURCE_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE', consumption)

    def test_reference_graph_and_actual_factory_update_consumption(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/FactoryUpdateConsumptionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('FACTORY_UPDATE_CONSUMPTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
