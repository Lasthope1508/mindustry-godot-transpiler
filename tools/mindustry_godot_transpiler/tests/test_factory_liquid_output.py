import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryBuildState.gd'
CONTENT_REGISTRY = ROOT / 'tools/mindustry_godot_transpiler/mindustry_port/content_registry.py'


class FactoryLiquidOutputTests(unittest.TestCase):
    def test_factory_liquid_output_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2118']['godot_owner'], 'SourceFactoryBuildState.source_factory_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceFactoryBuildState.source_factory_warmup_target_state', 'source_factory_warmup_target_state_input', 'Dictionary', ['warmup_target'], 'N2118'),
            ('SourceFactoryBuildState.source_factory_warmup_state', 'source_factory_warmup_state_input', 'Dictionary', ['warmup', 'target'], 'N2118'),
            ('SourceFactoryBuildState.source_factory_liquid_output_state', 'source_factory_liquid_output_state_input', 'Dictionary', ['inc', 'added', 'liquids_after'], 'N2118'),
            ('SourceFactoryBuildState.source_factory_total_progress_state', 'source_factory_total_progress_state_input', 'Dictionary', ['total_progress'], 'N2118'),
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
        self.assertEqual(len(ledger['N2118']['source_symbols']), 21)
        self.assertTrue(ledger['N2118']['deferred_exprs'])

    def test_all_factory_liquid_output_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2118']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], (
                    'SourceFactoryBuildState.source_factory_warmup_target_state',
                    'SourceFactoryBuildState.source_factory_warmup_state',
                    'SourceFactoryBuildState.source_factory_liquid_output_state',
                    'SourceFactoryBuildState.source_factory_total_progress_state',
                    'SourceFactoryBuildState.source_factory_tick_buildings_state',
                ))
        slice_sources = {
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/content/Blocks.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2118']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_outputs_liquid_when_efficient(self):
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_factory_warmup_target_state(block: Object) -> Dictionary:', factory)
        self.assertIn('static func source_factory_warmup_state(warmup: float, target: float, warmup_speed: float, seconds: float) -> Dictionary:', factory)
        self.assertIn('static func source_factory_liquid_output_state(block: Object, liquids: Dictionary, liquid_ids: Dictionary, efficiency: float, seconds: float, time_scale: float) -> Dictionary:', factory)
        self.assertIn('static func source_factory_total_progress_state(total_progress: float, warmup: float, seconds: float) -> Dictionary:', factory)
        self.assertIn('var step := float(seconds) * float(warmup_speed)', factory)
        self.assertIn('clampf(float(target) - float(warmup), -step, step)', factory)
        for constant in [
            'PORT_GAME_SOURCE_FACTORY_BUILD_WARMUP_TARGET_STATE',
            'PORT_GAME_SOURCE_FACTORY_BUILD_WARMUP_STATE',
            'PORT_GAME_SOURCE_FACTORY_BUILD_LIQUID_OUTPUT_STATE',
            'PORT_GAME_SOURCE_FACTORY_BUILD_TOTAL_PROGRESS_STATE',
        ]:
            self.assertIn(constant, factory)
        tick = factory.split('static func source_factory_tick_buildings_state')[1]
        self.assertIn('source_factory_warmup_target_state(', tick)
        self.assertIn('source_factory_warmup_state(', tick)
        self.assertIn('source_factory_liquid_output_state(', tick)
        self.assertIn('source_factory_total_progress_state(', tick)
        self.assertIn('block.properties.get("warmupSpeed", 0.019)', tick)
        self.assertLess(tick.index('source_factory_total_progress_state('), tick.index('source_factory_craft_state('))
        self.assertLess(tick.index('source_factory_liquid_output_state('), tick.index('source_factory_craft_state('))
        shard = json.loads((ROOT / 'godot-mindustry/src/generated/source_modules/content_registry_blocks.json').read_text(encoding='utf-8'))['blocks']
        self.assertEqual(float(shard['cryofluid-mixer']['properties']['craftTime']), 120.0)
        self.assertEqual(float(shard['cryofluid-mixer']['properties']['liquidCapacity']), 36.0)
        mixer_outputs = shard['cryofluid-mixer']['properties']['outputLiquids']
        self.assertEqual(len(mixer_outputs), 1)
        self.assertEqual(mixer_outputs[0]['liquid'], 'cryofluid')
        self.assertAlmostEqual(float(mixer_outputs[0]['amount']), 0.2)
        electrolyzer_outputs = shard['electrolyzer']['properties']['outputLiquids']
        self.assertEqual(len(electrolyzer_outputs), 2)
        self.assertEqual({row['liquid'] for row in electrolyzer_outputs}, {'ozone', 'hydrogen'})

    def test_reference_graph_and_actual_c06_factory_liquid_output_gate(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06FactoryLiquidOutputProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_FACTORY_LIQUID_OUTPUT_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
