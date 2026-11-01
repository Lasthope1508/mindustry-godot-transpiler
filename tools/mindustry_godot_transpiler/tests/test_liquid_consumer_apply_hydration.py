import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class LiquidConsumerApplyHydrationTests(unittest.TestCase):
    def test_partial_apply_contracts_are_registered_without_invented_before_flag(self):
        contracts = json.loads((ROOT / 'godot-mindustry/src/generated/source_api_contracts.json').read_text(encoding='utf-8'))['contracts']
        for owner, slice_id in [
            ('SourceConsumeLiquidBaseState.source_apply_capability_state', 'N2004'),
            ('SourceConsumeLiquidState.source_apply_filter_state', 'N2005'),
            ('SourceConsumeLiquidState.source_apply_liquid_consumers_state', 'N2006'),
        ]:
            with self.subTest(owner=owner):
                self.assertTrue(owner in contracts, owner)
                self.assertEqual(contracts[owner]['source_slice'], slice_id)
                self.assertNotIn('block_has_liquids_before', [p['name'] for p in contracts[owner]['params']])

    def test_placement_applies_consumers_before_effective_capability_allocation(self):
        text = (ROOT / 'godot-mindustry/src/game/PortGame.gd').read_text(encoding='utf-8')
        body = text.split('func record_placed_block(', 1)[1].split('\nfunc ', 1)[0]
        self.assertIn('SourceConsumeLiquidState.source_apply_liquid_consumers_state(block, content_catalog)', body)
        self.assertLess(body.index('source_apply_liquid_consumers_state'), body.index('source_initialize_building_liquids_state'))
        self.assertNotIn('"electrolyzer"', body)

    def test_live_partial_apply_filter_cache_and_real_placement(self):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        run = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/LiquidConsumerApplyHydrationProof.tscn', '--quit-after', '240'], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=90)
        output = run.stdout + run.stderr
        self.assertEqual(run.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        rows = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('LIQUID_CONSUMER_APPLY_HYDRATION_PROOF ')]
        self.assertEqual(len(rows), 1, output)
        self.assertTrue(rows[0]['matches'], rows[0])
