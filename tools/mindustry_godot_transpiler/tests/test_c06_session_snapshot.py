import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SNAPSHOT_STATE = ROOT / 'godot-mindustry/src/game/SourceSessionSnapshotState.gd'


class C06SessionSnapshotTests(unittest.TestCase):
    def test_c06_session_snapshot_registration(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        schemas = json.loads((generated / 'source_state_schema.json').read_text(encoding='utf-8'))['schemas']
        contracts = json.loads((generated / 'source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        self.assertEqual(ledger['N2121']['godot_owner'], 'SourceSessionSnapshotState.source_session_snapshot_state')
        for owner, schema, return_type, return_keys, source_slice in [
            ('SourceSessionSnapshotState.source_session_snapshot_state', 'source_session_snapshot_state_input', 'Dictionary', ['core_copper', 'core_health', 'battery_stored', 'battery_capacity', 'power_needed', 'power_produced', 'power_coverage', 'drill_time_drilled', 'drill_warmup', 'drill_last_speed', 'drill_water', 'drill_produced_total', 'pump_warmup', 'pump_total_progress', 'pump_water', 'conduit_water'], 'N2121'),
            ('SourceFactoryRuntimeState.source_factory_conveyor_tick_delta_state', 'source_factory_conveyor_tick_delta_state_input', 'Dictionary', ['ticks'], 'N2121'),
        ]:
            with self.subTest(owner=owner):
                self.assertEqual(contracts[owner]['source_slice'], source_slice)
                self.assertEqual(schemas[schema]['owner'], owner)
                self.assertEqual(contracts[owner].get('return_type'), return_type)
                self.assertEqual(contracts[owner]['return_keys'], return_keys)
                self.assertEqual([param['name'] for param in contracts[owner]['params']], list(schemas[schema]['keys']))
        self.assertEqual(
            [param['name'] for param in contracts['SourceSessionSnapshotState.source_session_snapshot_state']['params']],
            ['game'],
        )
        self.assertEqual(
            [param['name'] for param in contracts['SourceFactoryRuntimeState.source_factory_conveyor_tick_delta_state']['params']],
            ['seconds'],
        )
        self.assertEqual(len(ledger['N2121']['source_symbols']), 19)
        self.assertTrue(ledger['N2121']['deferred_exprs'])

    def test_all_c06_session_snapshot_input_evidence_is_exact(self):
        generated = ROOT / 'godot-mindustry/src/generated'
        ledger = json.loads((generated / 'source_slice_ledger.json').read_text(encoding='utf-8'))['slices']
        symbols = json.loads((generated / 'source_symbol_registry.json').read_text(encoding='utf-8'))['symbols']
        for name in ledger['N2121']['source_symbols']:
            with self.subTest(symbol=name):
                symbol = symbols[name]
                upstream_root = ROOT / 'arc-upstream' if symbol['java_source'].startswith('arc-core/') else ROOT / 'mindustry-upstream'
                self.assertIn(symbol['java_expr'], (upstream_root / symbol['java_source']).read_text(encoding='utf-8'))
                self.assertEqual(symbol['godot_owner'], ledger['N2121']['godot_owner'] if name.startswith('source_session_snapshot_state_') else 'SourceFactoryRuntimeState.source_factory_conveyor_tick_delta_state')
        slice_sources = {
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/power/PowerGraph.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/modules/ItemModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/modules/LiquidModule.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/HealthComp.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Drill.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/production/Pump.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/storage/CoreBlock.java'),
            ('mindustry-upstream', 'core/src/mindustry/world/blocks/distribution/Conveyor.java'),
            ('mindustry-upstream', 'core/src/mindustry/entities/comp/BuildingComp.java'),
            ('arc-upstream', 'arc-core/src/arc/util/Time.java'),
        }
        upstream = {source: (ROOT / root / source).read_text(encoding='utf-8') for root, source in slice_sources}
        for expr in ledger['N2121']['exact_exprs']:
            with self.subTest(expr=expr):
                self.assertTrue(any(expr in text for text in upstream.values()), expr)

    def test_snapshot_reads_live_session_state(self):
        snapshot = SNAPSHOT_STATE.read_text(encoding='utf-8')
        self.assertIn('static func source_session_snapshot_state(game: Object) -> Dictionary:', snapshot)
        self.assertIn('PORT_GAME_SOURCE_SESSION_SNAPSHOT_STATE', snapshot)
        self.assertIn('game_runtime_state', snapshot)
        self.assertIn('source_battery_power_status_for_cell_state', snapshot)
        self.assertIn('source_placed_power_graph_state', snapshot)
        self.assertIn('game_health_at_cell', snapshot)
        self.assertIn('core_item_count', snapshot)
        self.assertIn('drill_time_drilled_at_cell', snapshot)
        self.assertIn('source_get_state', snapshot)
        self.assertIn('conduit_cells()', snapshot)
        self.assertIn('distribute_power_state', snapshot)
        registry = (ROOT / 'godot-mindustry/src/game/SourceRuntimeOwnerGameplayRegistry.gd').read_text(encoding='utf-8')
        self.assertIn('PORT_GAME_SOURCE_SESSION_SNAPSHOT_STATE', registry)
        self.assertIn('PORT_GAME_SOURCE_FACTORY_CONVEYOR_TICK_DELTA_STATE', registry)
        factory = (ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd').read_text(encoding='utf-8')
        self.assertIn('static func source_factory_conveyor_tick_delta_state(seconds: float) -> Dictionary:', factory)
        self.assertIn('source_factory_conveyor_tick_delta_state(delta)', factory)
        self.assertIn('source_time_defaults.TICK_RATE', factory)

    def test_reference_graph_and_actual_c06_session_snapshot(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/C06SessionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('C_06_SESSION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])


if __name__ == '__main__':
    unittest.main()
