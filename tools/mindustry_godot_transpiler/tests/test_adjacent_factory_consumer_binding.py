import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ADJACENT_STATE = ROOT / 'godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd'
ITEMS_STATE = ROOT / 'godot-mindustry/src/game/SourceConsumeItemsState.gd'


class AdjacentFactoryConsumerBindingTests(unittest.TestCase):
    def test_adjacent_factory_consumer_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2115']['godot_owner'], 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceAdjacentFactoryBuildState.source_bind_consumer_state', 'source_adjacent_factory_bind_consumer_state_input', 'Dictionary', ['bound', 'consumers', 'rows'], 'N2115'),
            ('SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state', 'source_adjacent_factory_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell'], 'N2114'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state']['params']],
            ['game', 'seconds'],
        )
        self.assertEqual(len(ledger['N2115']['source_symbols']), 7)
        self.assertTrue(ledger['N2115']['deferred_exprs'])

    def test_all_adjacent_factory_consumer_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2115']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceAdjacentFactoryBuildState.source_bind_consumer_state', 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/world/blocks/production/Incinerator.java',
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/world/blocks/production/SingleBlockProducer.java',
            'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2115']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_binds_runtime_consumers_for_adjacent_factory(self):
        adjacent = ADJACENT_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:', adjacent)
        self.assertIn('static func source_adjacent_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', adjacent)
        tick = adjacent.split('static func source_adjacent_factory_tick_buildings_state')[1]
        self.assertIn('source_bind_consumer_state(frame, block, catalog, liquids)', tick)
        self.assertIn('update_consumption_state(', tick)
        self.assertIn('apply_update_consumption_state(', tick)
        self.assertIn('PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_BIND_CONSUMER_STATE', adjacent)
        items = ITEMS_STATE.read_text(encoding='utf-8')
        self.assertIn('class RuntimeConsumer extends RefCounted:', items)
        self.assertIn('static func source_runtime_consumer_state(definition: Dictionary, items: Dictionary, cost_multiplier: Callable) -> Dictionary:', items)
        self.assertIn('static func source_bind_item_consumers_state(block: Object, content_catalog: Object) -> Dictionary:', items)

    def test_reference_graph_and_actual_adjacent_factory_consumer_binding(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/AdjacentFactoryConsumerBindingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('ADJACENT_FACTORY_CONSUMER_BINDING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
