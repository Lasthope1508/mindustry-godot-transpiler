import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'
RUNTIME_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
TERRAIN_STATE = ROOT / 'godot-mindustry/src/game/SourceWorldTerrainRuntimeState.gd'


class FactoryLiveLoopTests(unittest.TestCase):
    def test_factory_live_loop_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2110']['godot_owner'], 'SourceFactoryBuildState.source_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys in [
            ('SourceFactoryBuildState.source_factory_tick_frame_state', 'source_factory_tick_frame_state_input', 'Dictionary', ['frame']),
            ('SourceFactoryBuildState.source_factory_bind_frame_state', 'source_factory_bind_frame_state_input', 'Dictionary', ['applied', 'frame']),
            ('SourceFactoryBuildState.source_factory_tick_buildings_state', 'source_factory_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell']),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], 'N2110')
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(len(ledger['N2110']['source_symbols']), 13)
        self.assertTrue(ledger['N2110']['deferred_exprs'])

    def test_all_factory_live_loop_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2110']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceFactoryBuildState.source_factory_tick_frame_state', 'SourceFactoryBuildState.source_factory_bind_frame_state', 'SourceFactoryBuildState.source_factory_tick_buildings_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/world/blocks/production/AttributeCrafter.java',
            'core/src/mindustry/world/blocks/production/HeatCrafter.java',
            'core/src/mindustry/world/blocks/heat/HeatProducer.java',
            'core/src/mindustry/world/Block.java',
            'core/src/mindustry/world/Tile.java',
            'core/src/mindustry/entities/comp/TeamComp.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2110']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_wires_frame_and_driver_runs_from_live_loop(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_factory_tick_frame_state(frame: Dictionary, block_implementation: String, team_id: int, rules_state: Variant) -> Dictionary:', factory)
        tick_frame = factory.split('static func source_factory_tick_frame_state')[1].split('static func source_factory_bind_frame_state')[0]
        self.assertIn('frame["block_implementation"] = block_implementation', tick_frame)
        self.assertIn('frame["team_id"] = team_id', tick_frame)
        self.assertIn('frame["rules_state"] = rules_state', tick_frame)
        self.assertIn('source_team_cheating_state(', tick_frame)
        self.assertIn('frame["cheating"] = ', tick_frame)
        self.assertIn('static func source_factory_bind_frame_state(sprite: Sprite2D, block: Object) -> Dictionary:', factory)
        bind = factory.split('static func source_factory_bind_frame_state')[1].split('static func source_factory_tick_buildings_state')[0]
        self.assertIn('_is_factory_build_implementation(str(block.implementation))', bind)
        self.assertIn('SOURCE_FACTORY_BUILD_IMPLEMENTATIONS := ["GenericCrafter", "AttributeCrafter", "HeatCrafter", "HeatProducer"]', factory)
        self.assertIn('SOURCE_FACTORY_BUILDING_META_KEY', bind)
        self.assertIn('static func source_factory_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', factory)
        driver = factory.split('static func source_factory_tick_buildings_state')[1]
        self.assertIn('source_factory_bind_frame_state(', driver)
        self.assertIn('source_factory_tick_frame_state(', driver)
        runtime = RUNTIME_STATE.read_text(encoding='utf-8')
        self.assertIn('source_factory_build_state.source_factory_tick_buildings_state(game, delta)', runtime)
        terrain = TERRAIN_STATE.read_text(encoding='utf-8')
        self.assertIn('source_factory_build_state.source_factory_bind_frame_state(build, build_block)', terrain)

    def test_reference_graph_and_actual_factory_live_loop(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/FactoryLiveLoopProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('FACTORY_LIVE_LOOP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
