import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'
CONSUME_ITEMS_STATE = ROOT / 'godot-mindustry/src/game/SourceConsumeItemsState.gd'
CONTENT_REGISTRY = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'


class FactoryCraftTests(unittest.TestCase):
    def test_factory_craft_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2117']['godot_owner'], 'SourceFactoryBuildState.source_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceFactoryBuildState.source_factory_progress_increase_state', 'source_factory_progress_increase_state_input', 'Dictionary', ['progress_increase', 'edelta'], 'N2117'),
            ('SourceFactoryBuildState.source_factory_crafter_progress_increase_state', 'source_factory_crafter_progress_increase_state_input', 'Dictionary', ['progress_increase', 'scaling', 'edelta'], 'N2117'),
            ('SourceFactoryBuildState.source_factory_consume_state', 'source_factory_consume_state_input', 'Dictionary', ['triggered', 'removed'], 'N2117'),
            ('SourceFactoryBuildState.source_factory_offload_state', 'source_factory_offload_state_input', 'Dictionary', ['placed', 'destination', 'receiver_cell', 'cdump_after', 'items_after'], 'N2117'),
            ('SourceFactoryBuildState.source_factory_craft_state', 'source_factory_craft_state_input', 'Dictionary', ['crafted', 'consumed', 'offloaded', 'progress_after'], 'N2117'),
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
        self.assertEqual(len(ledger['N2117']['source_symbols']), 38)
        self.assertTrue(ledger['N2117']['deferred_exprs'])

    def test_all_factory_craft_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2117']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], (
                    'SourceFactoryBuildState.source_factory_progress_increase_state',
                    'SourceFactoryBuildState.source_factory_crafter_progress_increase_state',
                    'SourceFactoryBuildState.source_factory_consume_state',
                    'SourceFactoryBuildState.source_factory_offload_state',
                    'SourceFactoryBuildState.source_factory_craft_state',
                    'SourceFactoryBuildState.source_factory_tick_buildings_state',
                ))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/Consume.java',
            'core/src/mindustry/content/Blocks.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/modules/ItemModule.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2117']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_crafts_when_progress_completes(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_factory_progress_increase_state(craft_time: float, efficiency: float, seconds: float, time_scale: float) -> Dictionary:', factory)
        self.assertIn('static func source_factory_crafter_progress_increase_state(block: Object, liquids: Dictionary, liquid_ids: Dictionary, efficiency: float, seconds: float, time_scale: float) -> Dictionary:', factory)
        self.assertIn('static func source_factory_consume_state(frame: Dictionary, consumers: Array, rows: Array) -> Dictionary:', factory)
        self.assertIn('static func source_factory_offload_state(game: Object, frame: Dictionary, cell: Vector2i, block: Object, item: String) -> Dictionary:', factory)
        self.assertIn('static func source_factory_craft_state(game: Object, frame: Dictionary, cell: Vector2i, block: Object) -> Dictionary:', factory)
        tick = factory.split('static func source_factory_tick_buildings_state')[1]
        self.assertIn('source_factory_crafter_progress_increase_state(', tick)
        self.assertIn('source_factory_craft_state(', tick)
        self.assertIn('frame["progress"]', factory)
        self.assertIn('PORT_GAME_SOURCE_FACTORY_BUILD_PROGRESS_INCREASE_STATE', factory)
        self.assertIn('PORT_GAME_SOURCE_FACTORY_BUILD_CRAFT_STATE', factory)
        consume_items = CONSUME_ITEMS_STATE.read_text(encoding='utf-8')
        self.assertIn('func trigger(build: Dictionary) -> void:', consume_items)
        self.assertIn('Math.round(stack.amount * multiplier.get(build))', consume_items)
        emitter = CONTENT_REGISTRY.read_text(encoding='utf-8')
        self.assertIn('"craftTime"', emitter)
        shard = json.loads((ROOT / 'godot-mindustry/src/generated/source_modules/content_registry_blocks.json').read_text(encoding='utf-8'))['blocks']
        self.assertEqual(float(shard['silicon-smelter']['properties']['craftTime']), 40.0)
        self.assertEqual(float(shard['graphite-press']['properties']['craftTime']), 90.0)

    def test_reference_graph_and_actual_c06_factory_craft_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06FactoryCraftProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_FACTORY_CRAFT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
