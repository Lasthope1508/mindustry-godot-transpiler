import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingEfficiencyMultiplierGeneratedDelegateTests(unittest.TestCase):
    def _body(self, method_name: str) -> str:
        source = GENERATED.read_text(encoding="utf-8")
        return source.split(f"func {method_name}", 1)[1].split("\nfunc ", 1)[0]

    def test_update_efficiency_multiplier_uses_canonical_state(self):
        body = self._body("java_method_updateEfficiencyMultiplier_192")
        self.assertIn(
            "return source_building_efficiency_state.update_efficiency_multiplier_state(efficiency, optional_efficiency, efficiency_scale)",
            body,
        )
        self.assertNotIn("var scale := efficiency_scale", body)

    def test_efficiency_scale_uses_canonical_state(self):
        body = self._body("java_method_efficiencyScale_193")
        self.assertIn("return source_building_efficiency_state.efficiency_scale_state()", body)
        self.assertNotIn('return {"source_owner":', body)


if __name__ == "__main__":
    unittest.main()
