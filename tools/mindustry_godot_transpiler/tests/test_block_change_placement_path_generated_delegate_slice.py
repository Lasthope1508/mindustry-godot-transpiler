from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockChangePlacementPathGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_change_placement_path_overloads_delegate_to_canonical_plan_state(self):
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
            "return source_block_plan_placement_state.change_placement_path_diagonal_state(points, rotation, diagonal_on)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_placement_state.change_placement_path_state(points, rotation)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_change_placement_path_diagonal_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_change_placement_path_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
