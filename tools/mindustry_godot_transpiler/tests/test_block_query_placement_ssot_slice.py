import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockQueryPlacementSsotSliceTests(unittest.TestCase):
    def test_generated_block_placement_queries_delegate_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockQueryPlacementState.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_block_query_placement_state := preload("res://src/game/SourceBlockQueryPlacementState.gd")',
            generated,
        )
        expected_delegates = (
            "generated_can_place_on_result_state(tile, team, rotation)",
            "generated_can_break_result_state(tile)",
            "generated_rotated_output_result_state(rotate_value, x_value, y_value)",
            "generated_rotated_output_tile_result_state(rotate_value, from_x, from_y, destination)",
        )
        for delegate in expected_delegates:
            with self.subTest(delegate=delegate):
                self.assertIn("return source_block_query_placement_state." + delegate, generated)

        self.assertNotIn("var base_state := {\"source_owner\": \"port_game.source_block_rotated_output_state\"", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_can_place_on_state"', generated)
        for entrypoint in (
            "generated_can_place_on_result_state",
            "generated_can_break_result_state",
            "generated_rotated_output_result_state",
            "generated_rotated_output_tile_result_state",
        ):
            self.assertIn("static func " + entrypoint, module)


if __name__ == "__main__":
    unittest.main()
