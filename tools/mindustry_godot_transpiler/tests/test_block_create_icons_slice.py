import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockCreateIconsSliceTests(unittest.TestCase):
    def test_generated_method_delegates_to_canonical_orchestration(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/Block.gd").read_text(encoding="utf-8")
        match = re.search(r"func java_method_createIcons_128\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)", source, re.S)
        self.assertIsNotNone(match)
        body = match.group("body")
        self.assertIn("var super_state: Dictionary", body)
        self.assertIn("var custom_regions_to_outline: Array", body)
        self.assertIn(
            "return source_block_icon_state.generated_create_icons_result_state("
            "super_state, synthetic, full_icon_width, full_icon_height, full_icon_center_color, "
            "map_color_before, name_value, team_region_found, teams, team_region, team_regions_before, "
            "atlas_team_overrides, outline_icon, outlined_icon, outline_radius, generated_icons, custom_regions_to_outline)",
            body,
        )
        self.assertNotIn("return null", body)

        state = (PROJECT / "src/game/SourceBlockIconState.gd").read_text(encoding="utf-8")
        for expression in (
            "if not synthetic and full_icon_width > 0 and full_icon_height > 0:",
            "if team_region_found:",
            "var overridden: bool = atlas_team_overrides.has(name_value + \"-team-\" + team_name)",
            "if outline_icon and generated_icons.size() > 0:",
            "if generated_icons.size() > 1:",
            'SOURCE_BLOCK_ICON_DISPOSED_KEY: true',
        ):
            self.assertIn(expression, state)
        self.assertIn('SOURCE_BLOCK_ICON_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CREATE_ICONS_STATE', state)

    def test_canonical_icon_module_is_exposed(self):
        source_text = (PROJECT / "src/game/SourceBlockIconSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceBlockIconState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('const SOURCE_BLOCK_CREATE_ICONS_METHOD := "public void createIcons(MultiPacker packer){"', source_text)
        self.assertIn("static func create_icons_state(", state)
        self.assertIn("static func generated_block_create_icons_bridge_state(", state)
        self.assertIn("func source_block_create_icons_state(", bridge)
        self.assertIn("func generated_block_create_icons_bridge_state(", bridge)
        for const_name, literal_value in {
            "SOURCE_BLOCK_ICON_SOURCE_OWNER_KEY": "source_owner",
            "SOURCE_BLOCK_ICON_GENERATED_OWNER_KEY": "generated_owner",
            "SOURCE_BLOCK_ICON_MODE_KEY": "mode",
            "SOURCE_BLOCK_ICON_OUTPUT_NAME_KEY": "output_name",
            "SOURCE_BLOCK_ICON_FULL_OUTPUT_FORMAT": "block-%s-full",
            "SOURCE_BLOCK_ICON_INPUT_TEAM_ID_KEY": "id",
            "SOURCE_BLOCK_ICON_INPUT_TEAM_NAME_KEY": "name",
            "SOURCE_BLOCK_ICON_INPUT_TEAM_PALETTE_KEY": "has_palette",
        }.items():
            self.assertIn(f'const {const_name} := "{literal_value}"', source_text)
            self.assertIn(f'const {const_name} := source_block_icon_source_text_state.{const_name}', state)
        self.assertIn('SOURCE_BLOCK_ICON_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CREATE_ICONS_STATE', state)
        self.assertIn('SOURCE_BLOCK_ICON_GENERATED_OWNER_KEY: SOURCE_BLOCK_CREATE_ICONS_GENERATED_OWNER', state)
        self.assertNotIn('team.get("id", 0)', state)
        self.assertNotIn('team.get("name", "")', state)
        self.assertNotIn('team.get("has_palette", false)', state)


if __name__ == "__main__":
    unittest.main()
