import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UNIT_FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceUnitFactoryBuildState.gd'
ITEMS_STATE = ROOT / 'godot-mindustry/src/game/SourceConsumeItemsState.gd'


class UnitFactoryConsumerBindingTests(unittest.TestCase):
    def test_unit_factory_consumer_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2120']['godot_owner'], 'SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceUnitFactoryBuildState.source_bind_consumer_state', 'source_unit_factory_bind_consumer_state_input', 'Dictionary', ['bound', 'consumers', 'rows'], 'N2120'),
            ('SourceUnitFactoryBuildState.source_unit_factory_plan_requirements_state', 'source_unit_factory_plan_requirements_state_input', 'Dictionary', ['unit', 'time', 'items'], 'N2120'),
            ('SourceUnitFactoryBuildState.source_unit_factory_reinitialize_consumers_state', 'source_unit_factory_reinitialize_consumers_state_input', 'Dictionary', ['reinitialized', 'bound', 'consumers', 'rows'], 'N2120'),
            ('SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state', 'source_unit_factory_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell'], 'N2109'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state']['params']],
            ['game', 'seconds'],
        )
        self.assertEqual(len(ledger['N2120']['source_symbols']), 20)
        self.assertTrue(ledger['N2120']['deferred_exprs'])

    def test_all_unit_factory_consumer_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2120']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceUnitFactoryBuildState.source_bind_consumer_state', 'SourceUnitFactoryBuildState.source_unit_factory_plan_requirements_state', 'SourceUnitFactoryBuildState.source_unit_factory_reinitialize_consumers_state', 'SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/units/UnitFactory.java',
            'core/src/mindustry/world/blocks/units/Reconstructor.java',
            'core/src/mindustry/world/blocks/units/UnitAssembler.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/ConsumeItemDynamic.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2120']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_binds_runtime_consumers_for_unit_factory(self):
        factory = UNIT_FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_plan_requirements_state(block: Object, plan_index: int) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_reinitialize_consumers_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:', factory)
        self.assertIn('static func source_unit_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', factory)
        tick = factory.split('static func source_unit_factory_tick_buildings_state')[1]
        self.assertIn('source_unit_factory_reinitialize_consumers_state(frame, block, catalog, liquids)', tick)
        self.assertIn('update_consumption_state(', tick)
        self.assertIn('apply_update_consumption_state(', tick)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_BIND_CONSUMER_STATE', factory)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_REINITIALIZE_CONSUMERS_STATE', factory)
        self.assertIn('PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PLAN_REQUIREMENTS_STATE', factory)
        items = ITEMS_STATE.read_text(encoding='utf-8')
        self.assertIn('class RuntimeConsumer extends RefCounted:', items)
        self.assertIn('static func source_runtime_consumer_state(definition: Dictionary, items: Dictionary, cost_multiplier: Callable) -> Dictionary:', items)
        self.assertIn('static func source_bind_item_consumers_state(block: Object, content_catalog: Object) -> Dictionary:', items)

    def test_reference_graph_and_actual_unit_factory_consumer_binding(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/UnitFactoryConsumerBindingProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('UNIT_FACTORY_CONSUMER_BINDING_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
