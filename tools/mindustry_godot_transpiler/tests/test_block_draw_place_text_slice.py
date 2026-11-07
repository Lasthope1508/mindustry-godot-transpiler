import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockDrawPlaceTextSliceTests(unittest.TestCase):
    def test_generated_overloads_delegate_to_canonical_state(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/Block.gd").read_text(encoding="utf-8")
        expected_owners = {
            8: "port_game.source_block_draw_place_text_simple_state",
            9: "port_game.source_block_draw_place_text_state",
        }
        for index in (8, 9):
            match = re.search(
                rf"func java_method_drawPlaceText_{index}\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)",
                source,
                re.S,
            )
            self.assertIsNotNone(match)
            body = match.group("body")
            delegate = "generated_draw_place_text_simple_result_state" if index == 8 else "generated_draw_place_text_result_state"
            self.assertIn(f"return source_block_draw_state.{delegate}(", body)
            self.assertNotIn("if(renderer.pixelate) return 0;", body)
            self.assertNotIn("layout_width / 2.0 - 2.0", body)
            self.assertNotIn("layout_width / 2.0 + 1.5", body)
            self.assertNotIn(f'"source_owner": "{expected_owners[index]}"', body)
            self.assertNotIn("return {", body)

    def test_simple_overload_preserves_java_delegation_in_canonical_state(self):
        source = (PROJECT / "src/game/SourceBlockDrawSourceTextState.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src/game/SourceBlockDrawState.gd").read_text(encoding="utf-8")
        self.assertIn("SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_DELEGATION_EXPR", source)
        self.assertIn("return drawPlaceText(text, x, y, valid ? Pal.accent : Pal.remove, true);", source)
        self.assertIn("SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_DELEGATION_EXPR", module)

    def test_canonical_module_and_facade_own_both_overloads(self):
        source = (PROJECT / "src/game/SourceBlockDrawSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceBlockDrawState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('const SOURCE_BLOCK_DRAW_PLACE_TEXT_SIMPLE_METHOD := "public float drawPlaceText(String text, int x, int y, boolean valid){"', source)
        self.assertIn('const SOURCE_BLOCK_DRAW_PLACE_TEXT_METHOD := "public float drawPlaceText(String text, int x, int y, Color color, boolean drawLine){"', source)
        self.assertIn("static func draw_place_text_state(", state)
        self.assertIn("static func draw_place_text_simple_state(", state)
        self.assertIn("func source_block_draw_place_text_state(", bridge)
        self.assertIn("func source_block_draw_place_text_simple_state(", bridge)


if __name__ == "__main__":
    unittest.main()
