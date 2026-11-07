from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockNewBuildingGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_new_building_delegates_to_canonical_runtime_geometry_state(self):
        generated = (
            PROJECT
            / "src"
            / "generated"
            / "classes"
            / "mindustry"
            / "world"
            / "Block.gd"
        ).read_text(encoding="utf-8")

        self.assertIn(
            "return source_block_runtime_geometry_state.new_building_state(build_type_value)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_new_building_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
