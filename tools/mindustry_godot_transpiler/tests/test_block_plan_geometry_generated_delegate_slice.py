import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockPlanGeometryGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_access_and_geometry_methods_delegate_to_canonical_modules(self):
        generated = (
            PROJECT
            / "src"
            / "generated"
            / "classes"
            / "mindustry"
            / "world"
            / "Block.gd"
        ).read_text(encoding="utf-8")

        expected_delegates = (
            "return source_block_plan_config_state.is_accessible_state(has_items, item_capacity)",
            "return source_block_plan_geometry_state.nearby_side_state(x_value, y_value, rotation, index_value, size_value, out_value)",
            "return source_block_plan_geometry_state.get_edges_state(size_value)",
            "return source_block_plan_geometry_state.get_inside_edges_state(size_value)",
            "return source_block_plan_geometry_state.iterate_taken_state(x_value, y_value, size_value, placer)",
        )
        for delegate in expected_delegates:
            with self.subTest(delegate=delegate):
                self.assertIn(delegate, generated)

        for owner in (
            "source_block_is_accessible_state",
            "source_block_nearby_side_state",
            "source_block_get_edges_state",
            "source_block_get_inside_edges_state",
            "source_block_iterate_taken_state",
        ):
            with self.subTest(owner=owner):
                self.assertNotIn(f'return {{"source_owner": "port_game.{owner}"', generated)


if __name__ == "__main__":
    unittest.main()
