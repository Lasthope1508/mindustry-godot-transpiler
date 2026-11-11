import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PLACED_STATE = ROOT / 'godot-mindustry/src/game/SourcePlacedPowerGraphState.gd'
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'


class C06SourceExhaustionOutputFullTests(unittest.TestCase):
    def test_c06_source_exhaustion_output_full_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2127']['godot_owner'], 'SourceFactoryRuntimeState.source_factory_update_power_graph_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state', 'source_consumer_should_consume_for_cell_state_input', 'Dictionary', ['should_consume', 'shouldConsumePower', 'found', 'reason'], 'N2125'),
            ('SourceFactoryRuntimeState.source_factory_update_power_graph_state', 'source_factory_update_power_graph_state_input', 'Dictionary', ['power_needed', 'power_produced', 'consumer_count', 'producer_count', 'battery_count', 'update'], 'N2077'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state']['params']],
            ['game', 'cell'],
        )
        self.assertIn('factory', contracts['SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state']['rule'])
        self.assertIn('should_consume_power', contracts['SourceFactoryRuntimeState.source_factory_update_power_graph_state']['rule'])
        self.assertEqual(len(ledger['N2127']['source_symbols']), 6)
        self.assertTrue(ledger['N2127']['deferred_exprs'])

    def test_all_c06_source_exhaustion_output_full_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        owners = {
            'source_consumer_should_consume_for_cell_state_': 'SourcePlacedPowerGraphState.source_consumer_should_consume_for_cell_state',
        }
        for name in ledger['N2127']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                prefix = next(p for p in owners if name.startswith(p))
                self.assertEqual(symbol['godot_owner'], owners[prefix])
        slice_sources = {
            'core/src/mindustry/world/blocks/power/PowerGraph.java',
            'core/src/mindustry/world/consumers/ConsumePower.java',
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/production/GenericCrafter.java',
            'core/src/mindustry/world/consumers/ConsumeItems.java',
            'core/src/mindustry/world/consumers/ConsumeLiquid.java',
            'core/src/mindustry/world/blocks/production/Separator.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2127']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_stamp_reads_factory_should_consume_and_first_pass_flag(self):
        placed = PLACED_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_consumer_should_consume_for_cell_state(game: Object, cell: Vector2i) -> Dictionary:', placed)
        helper = placed.split('static func source_consumer_should_consume_for_cell_state')[1].split('static func source_group_buildings_by_origin_state')[0]
        self.assertIn('SOURCE_CONSUMER_FRAME_META_KEYS', helper)
        self.assertIn('source_factory_should_consume_state(', helper)
        self.assertIn('source_adjacent_factory_should_consume_state(', helper)
        self.assertIn('frame.get("should_consume_power"', helper)
        self.assertIn('SOURCE_BUILDING_LIQUIDS_META_KEY', helper)
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        step = factory.split('static func source_factory_update_power_graph_state')[1].split('static func source_factory_dump_all_drill_outputs_state')[0]
        self.assertIn('source_consumer_should_consume_for_cell_state(', step)
        self.assertIn('consumer["should_consume"] = ', step)
        self.assertIn('consumer["shouldConsumePower"] = ', step)

    def test_reference_graph_and_actual_c06_source_exhaustion_output_full(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06SourceExhaustionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_SOURCE_EXHAUSTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
