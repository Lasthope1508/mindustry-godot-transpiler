import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockQueryBasicSsotSliceTests(unittest.TestCase):
    def test_generated_block_query_basic_methods_delegate_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockQueryBasicState.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_block_query_basic_state := preload("res://src/game/SourceBlockQueryBasicState.gd")',
            generated,
        )
        expected_delegates = (
            "generated_has_building_result_state(destructible_value, update_value)",
            "generated_is_multiblock_result_state(size_value)",
            "generated_is_floor_result_state(is_floor_instance)",
            "generated_is_overlay_result_state(is_overlay_floor_instance)",
            "generated_as_floor_result_state(self_block)",
            "generated_is_air_result_state(id_value)",
            "generated_can_be_built_result_state(build_visibility_value)",
            "generated_environment_buildable_result_state(is_on_planet_value)",
            "generated_is_static_result_state(cache_layer_value)",
            "generated_is_banned_result_state(rules_is_banned_value)",
            "generated_supports_env_result_state(env_enabled, env_disabled, env_required, env_value)",
        )
        for delegate in expected_delegates:
            with self.subTest(delegate=delegate):
                self.assertIn("return source_block_query_basic_state." + delegate, generated)

        self.assertNotIn("var has_building_value: bool = destructible_value or update_value", generated)
        self.assertNotIn("var supports_env_value: bool = (env_enabled & env_value)", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_is_floor_state"', generated)
        for entrypoint in (
            "generated_has_building_result_state",
            "generated_is_multiblock_result_state",
            "generated_is_floor_result_state",
            "generated_is_overlay_result_state",
            "generated_as_floor_result_state",
            "generated_is_air_result_state",
            "generated_can_be_built_result_state",
            "generated_environment_buildable_result_state",
            "generated_is_static_result_state",
            "generated_is_banned_result_state",
            "generated_supports_env_result_state",
        ):
            self.assertIn("static func " + entrypoint, module)


if __name__ == "__main__":
    unittest.main()
