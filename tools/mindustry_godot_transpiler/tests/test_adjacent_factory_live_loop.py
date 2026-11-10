import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
ADJACENT_STATE = ROOT / 'godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd'
RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
TERRAIN_STATE = ROOT / 'godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd'


class AdjacentFactoryLiveLoopTests(unittest.TestCase):
    def test_adjacent_factory_live_loop_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2114']['godot_owner'], 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys in [
            ('SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_frame_state', 'source_adjacent_factory_tick_frame_state_input', 'Dictionary', ['frame']),
            ('SourceAdjacentFactoryBuildState.source_adjacent_factory_bind_frame_state', 'source_adjacent_factory_bind_frame_state_input', 'Dictionary', ['applied', 'frame']),
            ('SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state', 'source_adjacent_factory_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell']),
            ('SourceAdjacentFactoryBuildState.source_adjacent_factory_update_consumption_state', 'source_adjacent_factory_update_consumption_state_input', 'Dictionary', ['cheating', 'skipped_consumption', 'potential_efficiency', 'efficiency', 'optional_efficiency', 'should_consume_power']),
            ('SourceAdjacentFactoryBuildState.source_adjacent_factory_should_consume_state', 'source_adjacent_factory_should_consume_state_input', 'Dictionary', ['should_consume', 'output_blocked', 'buffer_full']),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], 'N2114')
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(len(ledger['N2114']['source_symbols']), 30)
        self.assertTrue(ledger['N2114']['deferred_exprs'])

    def test_all_adjacent_factory_live_loop_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2114']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_frame_state', 'SourceAdjacentFactoryBuildState.source_adjacent_factory_bind_frame_state', 'SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state', 'SourceAdjacentFactoryBuildState.source_adjacent_factory_update_consumption_state', 'SourceAdjacentFactoryBuildState.source_adjacent_factory_should_consume_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/Separator.java',
            'core/src/mindustry/world/blocks/production/Incinerator.java',
            'core/src/mindustry/world/blocks/production/WallCrafter.java',
            'core/src/mindustry/world/blocks/production/SingleBlockProducer.java',
            'core/src/mindustry/world/blocks/payloads/BlockProducer.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/entities/comp/TeamComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2114']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_wires_frame_and_driver_runs_from_live_loop(self):
        adjacent = ADJACENT_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_adjacent_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:', adjacent)
        tick_frame = adjacent.split('static func source_adjacent_factory_tick_frame_state')[1].split('static func source_adjacent_factory_bind_frame_state')[0]
        self.assertIn('frame["block_implementation"] = block_implementation', tick_frame)
        self.assertIn('frame["team_id"] = team_id', tick_frame)
        self.assertIn('frame["rules_state"] = rules_state', tick_frame)
        self.assertIn('source_team_cheating_state(', tick_frame)
        self.assertIn('frame["cheating"] = ', tick_frame)
        self.assertIn('static func source_adjacent_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:', adjacent)
        bind = adjacent.split('static func source_adjacent_factory_bind_frame_state')[1].split('static func source_adjacent_factory_tick_buildings_state')[0]
        self.assertIn('_is_adjacent_factory_build_implementation(str(block.implementation))', bind)
        self.assertIn('SOURCE_ADJACENT_FACTORY_BUILD_IMPLEMENTATIONS := ["Separator", "Incinerator", "WallCrafter", "SingleBlockProducer"]', adjacent)
        self.assertIn('SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY', bind)
        self.assertIn('static func source_adjacent_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', adjacent)
        driver = adjacent.split('static func source_adjacent_factory_tick_buildings_state')[1]
        self.assertIn('source_adjacent_factory_bind_frame_state(', driver)
        self.assertIn('source_adjacent_factory_tick_frame_state(', driver)
        self.assertIn('static func source_adjacent_factory_update_consumption_state(frame: Dictionary, has_consumers: bool, enabled: bool, production_valid: bool, should_consume: bool, efficiency_scale: float) -> Dictionary:', adjacent)
        consumption = adjacent.split('static func source_adjacent_factory_update_consumption_state')[1]
        self.assertIn('update_consumption_state(', consumption)
        self.assertIn('frame.get("cheating", false)', consumption)
        self.assertIn('"skipped_consumption"', consumption)
        self.assertIn('not has_consumers or cheating', consumption)
        self.assertIn('PORT_GAME_SOURCE_ADJACENT_FACTORY_BUILD_UPDATE_CONSUMPTION_STATE', consumption)
        runtime = RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_adjacent_factory_build_state.source_adjacent_factory_tick_buildings_state(game, delta)', runtime)
        terrain = TERRAIN_STATE.read_text(encoding='utf-8')
        self.assertIn('source_adjacent_factory_build_state.source_adjacent_factory_bind_frame_state(build, build_block)', terrain)

    def test_reference_graph_and_actual_adjacent_factory_live_loop(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/AdjacentFactoryLiveLoopProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('ADJACENT_FACTORY_LIVE_LOOP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
