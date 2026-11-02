import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class DrillLiveConsumptionTests(unittest.TestCase):
    def test_same_batch_contracts_cover_adapter_unique_traversal_and_live_ticks(self):
        contracts = json.loads((ROOT / 'godot-mindustry/src/generated/source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for owner, slice_id in [
            ('SourceConsumeState.source_cost_multiplier_state', 'N2007'),
            ('SourceConsumeLiquidState.source_runtime_consumer_state', 'N2007'),
            ('SourcePlacedBlockState.source_unique_buildings_state', 'N2008'),
            ('SourceDrillConsumptionRuntimeState.source_tick_state', 'N2009'),
        ]:
            with self.subTest(owner=owner):
                self.assertTrue(owner in contracts, owner)
                self.assertEqual(contracts[owner]['source_slice'], slice_id)

    def test_factory_uses_live_tick_owner_and_timescale_uses_unique_buildings(self):
        factory = (ROOT / 'godot-mindustry/src/game/SourceFactoryRuntimeState.gd').read_text(encoding='utf-8')
        body = factory.split('static func simulate_factory(', 1)[1].split('\nstatic func ', 1)[0]
        self.assertIn('source_drill_consumption_runtime_state.source_factory_state(game, delta)', body)
        placed = (ROOT / 'godot-mindustry/src/game/SourcePlacedBlockState.gd').read_text(encoding='utf-8')
        body = placed.split('static func simulate_time_scales(', 1)[1].split('\nstatic func ', 1)[0]
        self.assertIn('source_unique_buildings_state(game)', body)
        self.assertNotIn('placed_block_origins.get(key)', body)

    def test_real_process_drives_two_multicell_drills_and_concrete_adapter(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/DrillLiveConsumptionProof.tscn', '--quit-after', '300'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=100)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('DRILL_LIVE_CONSUMPTION_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])
