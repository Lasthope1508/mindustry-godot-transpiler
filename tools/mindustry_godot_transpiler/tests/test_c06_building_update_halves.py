import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONVEYOR_STATE = ROOT / 'godot-mindustry/src/game/SourceConveyorRuntimeState.gd'
FACTORY_STATE = ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd'
CONDUIT_STATE = ROOT / 'godot-mindustry/src/game/SourceConduitRuntimeState.gd'


class C06BuildingUpdateHalvesTests(unittest.TestCase):
    def test_c06_building_update_halves_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2126']['godot_owner'], 'SourceConduitRuntimeState.source_conduit_update_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceConduitRuntimeState.source_conduit_update_state', 'source_conduit_update_state_input', 'Dictionary', ['liquid', 'flowed', 'smooth_liquid', 'flow_timer', 'update_tile_called', 'enabled'], 'N2092'),
            ('SourceConveyorRuntimeState.source_conveyor_advance_state', 'source_conveyor_advance_state_input', 'Dictionary', ['ids_after', 'xs_after', 'ys_after', 'len_after', 'mid', 'minitem', 'pass_ready', 'pass_item_id', 'clog_heat', 'no_sleep_called', 'reason'], 'N2069'),
            ('SourceFactoryRuntimeState.source_factory_advance_conveyors_state', 'source_factory_advance_conveyors_state_input', 'Dictionary', ['results_by_cell', 'passed_count', 'reason'], 'N2070'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceConduitRuntimeState.source_conduit_update_state']['params']],
            ['game', 'cell', 'delta'],
        )
        self.assertIn('update_tile_called', schemas['source_conduit_update_state_result']['keys'])
        self.assertIn('enabled', schemas['source_conduit_update_state_result']['keys'])
        self.assertIn('edelta', contracts['SourceConveyorRuntimeState.source_conveyor_advance_state']['rule'])
        self.assertIn('time_scale', contracts['SourceFactoryRuntimeState.source_factory_advance_conveyors_state']['rule'])
        self.assertIn('noUpdateDisabled', contracts['SourceConduitRuntimeState.source_conduit_update_state']['rule'])
        self.assertEqual(len(ledger['N2126']['source_symbols']), 2)
        self.assertTrue(ledger['N2126']['deferred_exprs'])

    def test_all_c06_building_update_halves_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2126']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                self.assertIn(symbol['java_expr'], (ROOT / 'mindustry-upstream' / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], 'SourceConduitRuntimeState.source_conduit_update_state')
        slice_sources = {
            'core/src/mindustry/entities/comp/BuildingComp.java',
            'core/src/mindustry/world/blocks/distribution/Conveyor.java',
            'core/src/mindustry/world/blocks/liquid/Conduit.java',
        }
        upstream = {source: (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8') for source in slice_sources}
        for expr in ledger['N2126']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_live_loop_wires_building_update_halves(self):
        conveyor = CONVEYOR_STATE.read_text(encoding='utf-8')
        advance = conveyor.split('static func source_conveyor_advance_state')[1].split('static func source_conveyor_item_draw_positions_state')[0]
        self.assertIn('var moved := speed * delta * time_scale', advance)
        factory = FACTORY_STATE.read_text(encoding='utf-8')
        wrapper = factory.split('static func source_factory_advance_conveyors_state')[1].split('static func source_factory_update_power_graph_state')[0]
        self.assertIn('time_scales[cell] = source_placed_block_state.time_scale(sprite, source_placed_block_state.game_default_time_scale(game))', wrapper)
        self.assertIn('var cell_time_scale: float = float(time_scales.get(cell, 1.0))', wrapper)
        self.assertIn('delta, cell_time_scale, aligned, next_minitem, 0, 0.0)', wrapper)
        self.assertNotIn('delta, 1.0, aligned, next_minitem, 0, 0.0)', wrapper)
        conduit = CONDUIT_STATE.read_text(encoding='utf-8')
        self.assertIn('CONDUIT_NO_UPDATE_DISABLED := true', conduit)
        update = conduit.split('static func source_conduit_update_state')[1]
        self.assertIn('var enabled: bool = bool(frame.get("enabled", true))', update)
        self.assertIn('frame["enabled"] = enabled', update)
        self.assertIn('source_building_lifecycle_state.update_tile_gate_state(enabled, CONDUIT_NO_UPDATE_DISABLED)', update)
        self.assertIn('"update_tile_called": false', update)
        self.assertIn('"update_tile_called": true', update)

    def test_reference_graph_and_actual_c06_building_update_halves(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06BuildingUpdateProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_BUILDING_UPDATE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
