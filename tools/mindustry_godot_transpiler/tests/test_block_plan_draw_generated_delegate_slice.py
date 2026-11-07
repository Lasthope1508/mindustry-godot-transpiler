from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockPlanDrawGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_plan_draw_methods_delegate_to_canonical_state(self):
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
            "const source_block_plan_draw_state := preload(\"res://src/game/SourceBlockPlanDrawState.gd\")",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_plan_default_alpha_state(plan, list, valid)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_plan_state(plan, list, valid, alpha, time_absin)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_other_player_plan_state(plan, list, alpha)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_plan_region_state(plan, list)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_default_plan_region_state(plan, list, rotate_value, rotate_draw, plan_rotation)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.find_plan_default_size_state(list, x_value, y_value, predicate)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.find_plan_state(list, x_value, y_value, size_value, predicate, list_is_query_eachable, query_find_result)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.get_plan_region_state(plan, list, full_icon)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_plan_config_state(plan, list)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_plan_config_center_state(plan, content, region, cross, content_color)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_plan_config_center_default_cross_state(plan, content, region)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.draw_plan_config_top_state(plan, list)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_draw_state.plan_config_clip_size_state(clip_size)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_plan_default_alpha_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_plan_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_other_player_plan_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_plan_region_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_default_plan_region_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_find_plan_default_size_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_find_plan_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_get_plan_region_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_plan_config_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_plan_config_center_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_plan_config_center_default_cross_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_draw_plan_config_top_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_plan_config_clip_size_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
