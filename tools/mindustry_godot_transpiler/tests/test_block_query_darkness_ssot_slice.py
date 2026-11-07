import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockQueryDarknessSsotSliceTests(unittest.TestCase):
    def test_generated_darkness_queries_delegate_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockQueryDarknessState.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_block_query_darkness_state := preload("res://src/game/SourceBlockQueryDarknessState.gd")',
            generated,
        )
        expected_delegates = (
            "generated_synthetic_result_state(update_value, destructible_value)",
            "generated_check_force_dark_result_state(force_dark_value, tile)",
            "generated_is_darkened_result_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)",
        )
        for delegate in expected_delegates:
            with self.subTest(delegate=delegate):
                self.assertIn("return source_block_query_darkness_state." + delegate, generated)

        self.assertNotIn("var synthetic_value: bool = update_value or destructible_value", generated)
        self.assertNotIn("var synthetic_state := {", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_is_darkened_state"', generated)
        for entrypoint in (
            "generated_synthetic_result_state",
            "generated_check_force_dark_result_state",
            "generated_is_darkened_result_state",
        ):
            self.assertIn("static func " + entrypoint, module)


if __name__ == "__main__":
    unittest.main()
