import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class WorldTileLifecycleTests(unittest.TestCase):
    def run_proof(self, *args):
        godot = shutil.which('Godot_v4.6.2-stable_win64_console.exe') or shutil.which('godot')
        self.assertIsNotNone(godot)
        result = subprocess.run([godot, '--headless', '--path', str(ROOT / 'godot-mindustry'), '--scene', 'tools/runtime_proofs/WorldTileLifecycleProof.tscn', '--quit-after', '300' if not args else '3', '--', *args], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=120)
        return result, result.stdout + result.stderr

    def test_world_tile_lifecycle_contracts(self):
        contracts = json.loads((ROOT / 'godot-mindustry/src/generated/source_api_contracts.json').read_text())['contracts']
        for owner, slice_id in [('source_block_geometry_state', 'N2017'), ('source_campaign_world_tiles_state', 'N2018'), ('source_game_world_tiles_state', 'N2019')]:
            with self.subTest(owner=owner):
                self.assertTrue('SourceWorldTerrainRuntimeState.' + owner in contracts, owner)
                self.assertEqual(contracts['SourceWorldTerrainRuntimeState.' + owner]['source_slice'], slice_id)

    def test_actual_world_bootstrap_and_placement(self):
        result, output = self.run_proof()
        self.assertEqual(result.returncode, 0, output)
        self.assertNotIn('ERROR:', output)
        proofs = [json.loads(line.split(' ', 1)[1]) for line in output.splitlines() if line.startswith('WORLD_TILE_LIFECYCLE_PROOF ')]
        self.assertEqual(len(proofs), 1, output)
        self.assertTrue(proofs[0]['matches'], proofs[0])

    def test_unknown_map_content_rejected(self):
        _, output = self.run_proof('--unknown-block')
        self.assertIn('World Tile block definition is unresolved', output)
        self.assertNotIn('WORLD_TILE_LIFECYCLE_PROOF ', output)

    def test_incomplete_map_terrain_rejected(self):
        _, output = self.run_proof('--incomplete-map')
        self.assertIn('World Tile floor runs must cover the map', output)
        self.assertNotIn('WORLD_TILE_LIFECYCLE_PROOF ', output)


if __name__ == '__main__':
    unittest.main()
