import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingProximityGeneratedDelegateTests(unittest.TestCase):
    def _body(self, method_name: str) -> str:
        source = GENERATED.read_text(encoding="utf-8")
        return source.split(f"func {method_name}", 1)[1].split("\nfunc ", 1)[0]

    def test_remove_from_proximity_uses_canonical_state(self):
        body = self._body("java_method_removeFromProximity_185")
        self.assertIn(
            "return source_building_lifecycle_state.remove_from_proximity_state(nearby_count, removable_count)",
            body,
        )
        self.assertNotIn('return {"source_owner":', body)
        self.assertNotIn("var queued_removals := clampi(removable_count, 0, nearby_count)", body)

    def test_update_proximity_uses_canonical_state(self):
        body = self._body("java_method_updateProximity_186")
        self.assertIn(
            "return source_building_lifecycle_state.update_proximity_state(nearby_count, same_team_count, headless, draw_cached)",
            body,
        )
        self.assertNotIn('return {"source_owner":', body)
        self.assertNotIn("var same_team_clamped := clampi(same_team_count, 0, nearby_count)", body)

    def test_on_nearby_build_added_uses_canonical_state(self):
        body = self._body("java_method_onNearbyBuildAdded_187")
        self.assertIn(
            "return source_building_lifecycle_state.on_nearby_build_added_state(other_state)",
            body,
        )
        self.assertNotIn('return {"source_owner":', body)


if __name__ == "__main__":
    unittest.main()
