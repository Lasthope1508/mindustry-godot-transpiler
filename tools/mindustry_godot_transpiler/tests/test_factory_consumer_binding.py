import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'
ITEMS_STATE = ROOT / 'godot-mindustry/src/game/SourceConsumeItemsState.gd'


class FactoryConsumerBindingTests(unittest.TestCase):
    def test_factory_consumer_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2112']['godot_owner'], 'SourceFactoryBuildState.source_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceFactoryBuildState.source_bind_consumer_state', 'source_factory_bind_consumer_state_input', 'Dictionary', ['bound', 'consumers', 'rows'], 'N2112'),
            ('SourceConsumeItemsState.source_bind_item_consumers_state', 'source_bind_item_consumers_state_input', 'Dictionary', ['consumers'], 'N2112'),
            ('SourceConsumeItemsState.source_runtime_consumer_state', 'source_item_runtime_consumer_input', 'Dictionary', ['consumer'], 'N2112'),
            ('SourceFactoryBuildState.source_factory_tick_buildings_state', 'source_factory_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell'], 'N2110'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceFactoryBuildState.source_factory_tick_buildings_state']['params']],
            ['game', 'seconds'],
        )
        self.assertEqual(len(ledger['N2112']['source_symbols']), 14)
        self.assertTrue(ledger['N2112']['deferred_exprs'])

    def test_all_factory_consumer_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2112']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceFactoryBuildState.source_bind_consumer_state', 'SourceConsumeItemsState.source_bind_item_consumers_state', 'SourceConsumeItemsState.source_runtime_consumer_state', 'SourceFactoryBuildState.source_factory_tick_buildings_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2112']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_binds_runtime_consumers_for_factory(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:', factory)
        self.assertIn('static func source_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', factory)
        tick = factory.split('static func source_factory_tick_buildings_state')[1]
        self.assertIn('source_factory_reinitialize_consumers_state(frame, block, catalog, liquids)', tick)
        self.assertIn('update_consumption_state(', tick)
        self.assertIn('apply_update_consumption_state(', tick)
        self.assertIn('PORT_GAME_SOURCE_FACTORY_BUILD_BIND_CONSUMER_STATE', factory)
        items = ITEMS_STATE.read_text(encoding='utf-8')
        self.assertIn('class RuntimeConsumer extends RefCounted:', items)
        self.assertIn('static func source_runtime_consumer_state(definition: Dictionary, items: Dictionary, cost_multiplier: Callable) -> Dictionary:', items)
        self.assertIn('static func source_bind_item_consumers_state(block: Object, content_catalog: Object) -> Dictionary:', items)

    def test_reference_graph_and_actual_factory_consumer_binding(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/FactoryConsumerBindingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('FACTORY_CONSUMER_BINDING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
