import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'
CONTENT_REGISTRY = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'


class FactoryDumpOutputsTests(unittest.TestCase):
    def test_factory_dump_outputs_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2119']['godot_owner'], 'SourceFactoryBuildState.source_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceFactoryBuildState.source_factory_dump_interval_state', 'source_factory_dump_interval_state_input', 'Dictionary', ['dump_interval'], 'N2119'),
            ('SourceFactoryBuildState.source_factory_dump_timer_state', 'source_factory_dump_timer_state_input', 'Dictionary', ['dump_timer', 'should_dump', 'dump_interval'], 'N2119'),
            ('SourceFactoryBuildState.source_factory_dump_liquid_state', 'source_factory_dump_liquid_state_input', 'Dictionary', ['liquid', 'amount_dumped', 'liquid_amount', 'dump_cursor'], 'N2119'),
            ('SourceFactoryBuildState.source_factory_dump_outputs_state', 'source_factory_dump_outputs_state_input', 'Dictionary', ['item_dump_fired', 'dumped_items', 'dumped_liquids', 'dump_timer', 'cdump_after', 'items_after', 'liquids_after'], 'N2119'),
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
        self.assertEqual(len(ledger['N2119']['source_symbols']), 36)
        self.assertTrue(ledger['N2119']['deferred_exprs'])

    def test_all_factory_dump_outputs_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2119']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], (
                    'SourceFactoryBuildState.source_factory_dump_interval_state',
                    'SourceFactoryBuildState.source_factory_dump_timer_state',
                    'SourceFactoryBuildState.source_factory_dump_liquid_state',
                    'SourceFactoryBuildState.source_factory_dump_outputs_state',
                    'SourceFactoryBuildState.source_factory_tick_buildings_state',
                ))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/entities/comp/TimerComp.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2119']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_dumps_outputs(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_factory_dump_interval_state(dump_time: float, time_scale: float) -> Dictionary:', factory)
        self.assertIn('static func source_factory_dump_timer_state(dump_timer: float, seconds: float, dump_time: float, time_scale: float) -> Dictionary:', factory)
        self.assertIn('static func source_factory_dump_liquid_state(game: Object, cell: Vector2i, block: Object, liquids: Dictionary, liquid_ids: Dictionary, liquid_name: String, output_dir: int) -> Dictionary:', factory)
        self.assertIn('static func source_factory_dump_outputs_state(game: Object, frame: Dictionary, cell: Vector2i, block: Object, liquids: Dictionary, liquid_ids: Dictionary, seconds: float, time_scale: float) -> Dictionary:', factory)
        self.assertIn('source_factory_dump_outputs_state(', factory.split('static func source_factory_tick_buildings_state')[1])
        for constant in [
            'PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_INTERVAL_STATE',
            'PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_TIMER_STATE',
            'PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_LIQUID_STATE',
            'PORT_GAME_SOURCE_FACTORY_BUILD_DUMP_OUTPUTS_STATE',
        ]:
            self.assertIn(constant, factory)
        tick = factory.split('static func source_factory_tick_buildings_state')[1]
        self.assertLess(tick.index('source_factory_craft_state('), tick.index('source_factory_dump_outputs_state('))
        self.assertIn('block.properties.get("dumpTime", 5)', factory)
        shard = json.loads((ROOT / 'godot-mindustry/src/generated/source_modules/content_registry_blocks.json').read_text(encoding='utf-8'))['blocks']
        self.assertEqual(shard['cryofluid-mixer']['properties']['liquidOutputDirections'], [-1])
        self.assertEqual(shard['electrolyzer']['properties']['liquidOutputDirections'], [1, 3])
        self.assertEqual(shard['silicon-smelter']['properties']['liquidOutputDirections'], [-1])

    def test_reference_graph_and_actual_c06_factory_dump_outputs_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06FactoryDumpOutputsProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_FACTORY_DUMP_OUTPUTS_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
