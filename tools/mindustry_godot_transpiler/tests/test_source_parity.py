import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.source_parity import verify_duo_source_parity


class SourceParityTests(unittest.TestCase):
    def test_generated_duo_values_match_upstream_blocks_source(self):
        report = verify_duo_source_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "duo")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"]["properties"]["reload"], 20.0)
        self.assertEqual(report["checked"]["properties"]["range"], 160)
        self.assertEqual(report["checked"]["properties"]["health"], 250)
        self.assertEqual(report["checked"]["properties"].get("shootY"), 3.0)
        self.assertEqual(report["checked"]["properties"].get("shootPattern"), {"type": "ShootAlternate", "spread": 3.5})
        self.assertEqual(report["checked"]["ammo"]["copper"]["ammoMultiplier"], 2)
        self.assertEqual(report["checked"]["ammo"]["graphite"]["rangeChange"], 16.0)
        self.assertEqual(report["checked"]["ammo"]["graphite"]["reloadMultiplier"], 0.8)
        self.assertEqual(report["checked"]["ammo"]["silicon"]["reloadMultiplier"], 1.5)


if __name__ == "__main__":
    unittest.main()
