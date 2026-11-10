import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'


class FactoryShouldConsumeTests(unittest.TestCase):
    def test_factory_should_consume_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2113']['godot_owner'], 'SourceFactoryBuildState.source_factory_should_consume_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceFactoryBuildState.source_factory_should_consume_state', 'source_factory_should_consume_state_input', 'Dictionary', ['should_consume', 'item_blocked', 'liquid_blocked', 'all_liquids_full'], 'N2113'),
            ('SourceFactoryBuildState.source_factory_tick_buildings_state', 'source_factory_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell'], 'N2110'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(len(ledger['N2113']['source_symbols']), 8)
        self.assertTrue(ledger['N2113']['deferred_exprs'])

    def test_all_factory_should_consume_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2113']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceFactoryBuildState.source_factory_should_consume_state',))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2113']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_should_consume_reads_output_space(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_factory_should_consume_state(frame: Dictionary, block: Object, liquids: Dictionary, liquid_ids: Dictionary) -> Dictionary:', factory)
        should_consume = factory.split('static func source_factory_should_consume_state')[1].split('static func source_factory_update_consumption_state')[0]
        self.assertIn('outputItems', should_consume)
        self.assertIn('outputLiquids', should_consume)
        self.assertIn('itemCapacity', should_consume)
        self.assertIn('liquidCapacity', should_consume)
        self.assertIn('liquid_capacity - 0.001', should_consume)
        self.assertIn('ignoreLiquidFullness', should_consume)
        self.assertIn('dumpExtraLiquid', should_consume)
        self.assertIn('all_liquids_full', should_consume)
        self.assertIn('"should_consume"', should_consume)
        self.assertIn('PORT_GAME_SOURCE_FACTORY_BUILD_SHOULD_CONSUME_STATE', should_consume)
        tick = factory.split('static func source_factory_tick_buildings_state')[1]
        self.assertIn('source_factory_should_consume_state(frame, block, liquids, liquid_id_by_name)', tick)

    def test_reference_graph_and_actual_factory_should_consume(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/FactoryShouldConsumeProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('FACTORY_SHOULD_CONSUME_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
