import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class BuildingIsHealSuppressedGeneratedSliceTests(unittest.TestCase):
    def test_generated_method_delegates_to_existing_lifecycle_owner(self):
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        lifecycle = (ROOT / "godot-mindustry/src/game/SourceBuildingLifecycleState.gd").read_text(encoding="utf-8")
        bridge = (ROOT / "godot-mindustry/src/game/SourceBuildingLifecyclePortBridge.gd").read_text(encoding="utf-8")
        body = generated.split("func java_method_isHealSuppressed_28", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_lifecycle_state.is_heal_suppressed_result_state", body)
        self.assertNotIn("return null", body)
        self.assertIn("static func generated_is_heal_suppressed_bridge_state(", lifecycle)
        self.assertIn("func generated_building_comp_is_heal_suppressed_bridge_state(", bridge)


if __name__ == "__main__":
    unittest.main()
