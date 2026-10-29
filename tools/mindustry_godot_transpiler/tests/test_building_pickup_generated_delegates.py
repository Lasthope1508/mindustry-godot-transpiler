import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingPickupGeneratedDelegateTests(unittest.TestCase):
    def test_can_pickup_uses_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_canPickup_182", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_lifecycle_state.can_pickup_state(block_can_pickup)", body)
        self.assertNotIn('return {"source_owner":', body)

    def test_picked_up_uses_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_pickedUp_183", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_lifecycle_state.picked_up_state(previous_state)", body)
        self.assertNotIn('return {"source_owner":', body)


if __name__ == "__main__":
    unittest.main()
