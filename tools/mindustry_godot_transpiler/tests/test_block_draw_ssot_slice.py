import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockDrawSsotSliceTests(unittest.TestCase):
    def test_generated_draw_core_delegates_to_canonical_state(self):
        generated = (
            PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd"
        ).read_text(encoding="utf-8")
        module = (PROJECT / "src" / "game" / "SourceBlockDrawState.gd").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            'const source_block_draw_state := preload("res://src/game/SourceBlockDrawState.gd")',
            generated,
        )
        self.assertIn("return source_block_draw_state.generated_draw_base_result_state(", generated)
        self.assertIn("return source_block_draw_state.generated_draw_base_cached_result_state(", generated)
        self.assertIn("return source_block_draw_state.generated_draw_shadow_result_state(", generated)
        self.assertIn("return source_block_draw_state.generated_draw_environment_light_result_state(", generated)
        self.assertIn("return source_block_draw_state.generated_draw_place_result_state(", generated)
        self.assertIn("return source_block_draw_state.generated_draw_overlay_result_state(", generated)
        self.assertIn("return source_block_draw_state.generated_display_shadow_result_state(", generated)
        self.assertNotIn("\tvar selected_region: Variant = region_value if variants == 0 else variant_region", generated)
        self.assertNotIn("\tvar shadow_region: Variant = custom_shadow_region if variants == 0 else variant_shadow_region", generated)
        self.assertNotIn('return {\"source_owner\": \"port_game.source_block_draw_base_state\"', generated)
        self.assertNotIn('return {\"source_owner\": \"port_game.source_block_draw_base_cached_state\"', generated)
        self.assertNotIn('return {\"source_owner\": \"port_game.source_block_draw_shadow_state\"', generated)
        self.assertIn("static func generated_draw_base_result_state(", module)
        self.assertIn("static func generated_draw_base_cached_result_state(", module)
        self.assertIn("static func generated_draw_shadow_result_state(", module)
        self.assertIn("static func generated_draw_environment_light_result_state(", module)
        self.assertIn("static func generated_draw_place_result_state(", module)
        self.assertIn("static func generated_draw_overlay_result_state(", module)
        self.assertIn("static func generated_display_shadow_result_state(", module)


if __name__ == "__main__":
    unittest.main()
