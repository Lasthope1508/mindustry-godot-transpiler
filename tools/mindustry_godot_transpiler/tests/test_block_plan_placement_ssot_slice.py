import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockPlanPlacementSsotSliceTests(unittest.TestCase):
    def test_generated_plan_queries_delegate_to_canonical_modules(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockPlanPlacementState.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_block_plan_placement_state := preload("res://src/game/SourceBlockPlanPlacementState.gd")',
            generated,
        )
        self.assertIn(
            "return source_block_plan_placement_state.generated_plan_rotation_result_state(rotate_value, lock_rotation, rot)",
            generated,
        )
        self.assertNotIn("var plan_rotation_value: int = 0 if ((not rotate_value) and lock_rotation) else rot", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_plan_rotation_state"', generated)
        self.assertIn("static func generated_plan_rotation_result_state", module)
        self.assertIn(
            "return source_block_plan_placement_state.generated_flip_rotation_result_state(rotation_before, x_value, invert_flip, rotate_value, lock_rotation)",
            generated,
        )
        self.assertNotIn("var rotation_even: bool = rotation_before % 2 == 0", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_flip_rotation_state"', generated)
        self.assertIn("static func generated_flip_rotation_result_state", module)
        config_module = (PROJECT / "src" / "game" / "SourceBlockPlanConfigState.gd").read_text(encoding="utf-8")
        self.assertIn(
            'const source_block_plan_config_state := preload("res://src/game/SourceBlockPlanConfigState.gd")',
            generated,
        )
        self.assertIn(
            "return source_block_plan_config_state.generated_get_plan_configs_result_state(options_before, item_configured, liquid_configured, content_items, content_liquids)",
            generated,
        )
        self.assertNotIn("var options_after: Array = options_before.duplicate()", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_get_plan_configs_state"', generated)
        self.assertIn("static func generated_get_plan_configs_result_state", config_module)


if __name__ == "__main__":
    unittest.main()
