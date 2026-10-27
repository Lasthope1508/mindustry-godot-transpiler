import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingCoreGeneratedDelegateTests(unittest.TestCase):
    def test_absorb_lasers_delegates_to_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_absorbLasers_174", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_core_state.absorb_lasers_state(block_absorb_lasers)", body)
        self.assertNotIn('return {"source_owner":', body)

    def test_is_insulated_delegates_to_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_isInsulated_175", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_core_state.is_insulated_state(block_insulated)", body)
        self.assertNotIn('return {"source_owner":', body)

    def test_collide_delegates_to_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_collide_176", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_core_state.collide_state(other)", body)
        self.assertNotIn('return {"source_owner":', body)


if __name__ == "__main__":
    unittest.main()
