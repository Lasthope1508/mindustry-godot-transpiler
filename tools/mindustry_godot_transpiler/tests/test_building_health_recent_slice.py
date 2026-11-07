import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class BuildingHealthRecentSliceTests(unittest.TestCase):
    def test_generated_health_recent_methods_delegate_to_lifecycle_state(self):
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        for method, helper in (("recentlyHealed_29", "recently_healed_state"), ("wasRecentlyHealed_30", "was_recently_healed_state"), ("wasRecentlyDamaged_31", "was_recently_damaged_state")):
            body = generated.split(f"func java_method_{method}", 1)[1].split("\nfunc ", 1)[0]
            self.assertIn(f"source_building_lifecycle_state.{helper}", body)
            self.assertNotIn("return null", body)

    def test_source_formulas_are_preserved(self):
        source = (ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java").read_text(encoding="utf-8")
        for expression in ("lastHealTime = Time.time;", "return lastHealTime + duration >= Time.time;", "return lastDamageTime + recentDamageTime >= Time.time;"):
            self.assertIn(expression, source)


if __name__ == "__main__":
    unittest.main()
