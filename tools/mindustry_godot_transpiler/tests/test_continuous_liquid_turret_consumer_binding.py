import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceContinuousLiquidTurretBuildState.gd'


class ContinuousLiquidTurretConsumerBindingTests(unittest.TestCase):
    def test_continuous_liquid_turret_consumer_binding_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2106']['godot_owner'], 'SourceContinuousLiquidTurretBuildState.source_tick_buildings_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceContinuousLiquidTurretBuildState.source_bind_consumer_state', 'source_bind_consumer_state_input', 'Dictionary', ['bound', 'consumers', 'rows'], 'N2106'),
            ('SourceContinuousLiquidTurretBuildState.source_consumed_liquid_state', 'source_consumed_liquid_state_input', 'Dictionary', ['consumed_liquid', 'consumed_index'], 'N2106'),
            ('SourceContinuousLiquidTurretBuildState.source_tick_buildings_state', 'source_tick_buildings_state_input', 'Dictionary', ['ticked_count', 'results_by_cell'], 'N2103'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceContinuousLiquidTurretBuildState.source_tick_buildings_state']['params']],
            ['game', 'seconds'],
        )
        self.assertEqual(len(ledger['N2106']['source_symbols']), 13)
        self.assertTrue(ledger['N2106']['deferred_exprs'])

    def test_all_continuous_liquid_turret_consumer_binding_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2106']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertIn(symbol['godot_owner'], ('SourceContinuousLiquidTurretBuildState.source_bind_consumer_state', 'SourceContinuousLiquidTurretBuildState.source_consumed_liquid_state', 'SourceContinuousLiquidTurretBuildState.source_tick_buildings_state'))
        slice_sources = {
            'core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java',
            'core/src/mindustry/world/consumers/ConsumeLiquidFilter.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/modules/LiquidModule.java',
            'core/src/mindustry/world/Block.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2106']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_tick_binds_a_runtime_consumer_for_sublimate(self):
        source = BUILD_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_bind_consumer_state(frame: Dictionary, block: Object, catalog: Object, amounts: Dictionary) -> Dictionary:', source)
        self.assertIn('static func source_consumed_liquid_state(frame: Dictionary, liquids: Dictionary, liquid_names_by_id: Array) -> Dictionary:', source)
        self.assertIn('static func source_tick_buildings_state(game: Object, seconds: float) -> Dictionary:', source)
        tick = source.split('static func source_tick_buildings_state')[1].split('static func sense_object_state')[0]
        self.assertIn('source_bind_consumer_state(frame, block, catalog, liquids)', tick)
        self.assertIn('source_consumed_liquid_state(frame, liquids, liquid_names_by_id)', tick)
        self.assertIn('update_consumption_state(', tick)
        self.assertIn('apply_update_consumption_state(', tick)

    def test_reference_graph_and_actual_continuous_liquid_turret_consumer_binding(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/ContinuousLiquidTurretLiveLoopProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('CONTINUOUS_LIQUID_TURRET_LIVE_LOOP_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
