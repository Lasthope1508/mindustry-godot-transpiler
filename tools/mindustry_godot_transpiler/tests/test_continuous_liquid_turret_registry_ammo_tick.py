import json
import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD_STATE = ROOT / 'godot-mindustry/src/game/SourceContinuousLiquidTurretBuildState.gd'


class ContinuousLiquidTurretRegistryAmmoTickTests(unittest.TestCase):
    def test_tick_reads_ammo_types_from_registry_properties(self):
        source = BUILD_STATE.read_text(encoding='utf-8')
        self.assertNotIn('SOURCE_CONTINUOUS_LIQUID_TURRET_AMMO_TYPES_BY_BLOCK', source)
        tick = source.split('static func source_tick_buildings_state')[1].split('static func sense_object_state')[0]
        self.assertIn('block.properties.get("ammoTypes", {})', tick)

    def test_reference_graph_and_actual_continuous_liquid_turret_registry_ammo_tick(self):
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
