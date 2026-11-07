import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockPlanVisibilitySsotSliceTests(unittest.TestCase):
    def test_generated_visibility_queries_delegate_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockPlanVisibilityState.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_block_plan_visibility_state := preload("res://src/game/SourceBlockPlanVisibilityState.gd")',
            generated,
        )
        expected_delegates = (
            "generated_is_hidden_result_state(build_visibility_visible, revealed_blocks_contains_self)",
            "generated_is_visible_result_state(is_hidden_value, state_rules_editor, state_rules_hide_banned_blocks, is_banned_value)",
            "generated_is_placeable_result_state(placeable_is_visible_value, placeable_is_banned_value, placeable_state_rules_editor, supports_env_value)",
        )
        for delegate in expected_delegates:
            with self.subTest(delegate=delegate):
                self.assertIn("return source_block_plan_visibility_state." + delegate, generated)

        self.assertNotIn("var is_hidden_value: bool = (not build_visibility_visible)", generated)
        self.assertNotIn("var is_visible_value: bool = (not is_hidden_value)", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_is_placeable_state"', generated)
        for entrypoint in (
            "generated_is_hidden_result_state",
            "generated_is_visible_result_state",
            "generated_is_placeable_result_state",
        ):
            self.assertIn("static func " + entrypoint, module)


if __name__ == "__main__":
    unittest.main()
