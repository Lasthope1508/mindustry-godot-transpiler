import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingAfterPickedUpGeneratedDelegateTests(unittest.TestCase):
    def test_after_picked_up_uses_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_afterPickedUp_184", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_lifecycle_state.after_picked_up_state(power_present, has_cons_power, cons_power_buffered, current_status)", body)
        self.assertNotIn('return {"source_owner":', body)
        self.assertNotIn("var status := 0.0 if power_present and has_cons_power and not cons_power_buffered else current_status", body)


if __name__ == "__main__":
    unittest.main()
