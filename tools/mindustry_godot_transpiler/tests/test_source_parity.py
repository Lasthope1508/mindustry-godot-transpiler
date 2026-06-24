import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.source_parity import verify_duo_source_parity
from mindustry_port import source_parity


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
        self.assertEqual(report["checked"]["properties"].get("inaccuracy"), 2.0)
        self.assertEqual(report["checked"]["properties"].get("rotateSpeed"), 10.0)
        self.assertEqual(report["checked"]["properties"].get("shootCone"), 15.0)
        self.assertEqual(report["checked"]["properties"].get("recoil"), 0.5)
        self.assertEqual(report["checked"]["properties"].get("recoils"), 2)
        self.assertEqual(report["checked"]["properties"].get("limitRangeMargin"), 5.0)
        self.assertEqual(report["checked"]["properties"].get("shootPattern"), {"type": "ShootAlternate", "spread": 3.5})
        self.assertAlmostEqual(report["checked"]["ammo"]["copper"]["lifetime"], 70.0)
        self.assertAlmostEqual(report["checked"]["ammo"]["graphite"]["lifetime"], 54.57142857142857)
        self.assertAlmostEqual(report["checked"]["ammo"]["silicon"]["lifetime"], 58.333333333333336)
        self.assertEqual(report["checked"]["ammo"]["copper"]["ammoMultiplier"], 2)
        self.assertEqual(report["checked"]["ammo"]["graphite"]["rangeChange"], 16.0)
        self.assertEqual(report["checked"]["ammo"]["graphite"]["reloadMultiplier"], 0.8)
        self.assertEqual(report["checked"]["ammo"]["silicon"]["reloadMultiplier"], 1.5)


    def test_generated_mend_projector_scaled_health_matches_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_mend_projector_scaled_health_parity"))
        report = source_parity.verify_mend_projector_scaled_health_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "mend-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"], {"size": 2, "scaledHealth": 80, "health": 320})

    def test_generated_mend_projector_repair_params_match_upstream_source(self):
        self.assertTrue(hasattr(source_parity, "verify_mend_projector_repair_parity"))
        report = source_parity.verify_mend_projector_repair_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "mend-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"], {"healPercent": 11.0, "phaseBoost": 15.0, "phaseRangeBoost": 50.0, "boosterItem": "phase-fabric", "boosterUseTime": 400.0})

    def test_generated_mend_projector_repair_amount_matches_source_formula(self):
        self.assertTrue(hasattr(source_parity, "verify_mend_projector_repair_amount_parity"))
        report = source_parity.verify_mend_projector_repair_amount_parity(ROOT / "mindustry-upstream", ROOT / "godot-mindustry")

        self.assertEqual(report["source"], "core/src/mindustry/content/Blocks.java")
        self.assertEqual(report["block"], "mend-projector")
        self.assertEqual(report["mismatches"], [])
        self.assertEqual(report["checked"]["health"], 320)
        self.assertEqual(report["checked"]["healPercent"], 11.0)
        self.assertEqual(report["checked"]["phaseHeat"], 0.0)
        self.assertEqual(report["checked"]["efficiency"], 1.0)
        self.assertAlmostEqual(report["checked"]["repairAmount"], 35.2)

if __name__ == "__main__":
    unittest.main()
