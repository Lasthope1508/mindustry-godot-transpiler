import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockDrawPotentialLinksSliceTests(unittest.TestCase):
    def test_generated_method_delegates_power_and_beam_link_paths(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/Block.gd").read_text(encoding="utf-8")
        match = re.search(
            r"func java_method_drawPotentialLinks_7\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)",
            source,
            re.S,
        )
        self.assertIsNotNone(match)
        body = match.group("body")
        self.assertIn("return source_block_draw_state.generated_draw_potential_links_result_state(", body)
        self.assertNotIn("and has_power and connected_power and tile_present", body)
        self.assertNotIn("for link in power_links:", body)
        self.assertNotIn("for link in beam_links:", body)
        self.assertNotIn('"power_laser_expr"', body)
        self.assertNotIn('"beam_laser_expr"', body)
        self.assertNotIn("return {", body)

    def test_canonical_module_owns_link_semantics(self):
        source = (PROJECT / "src/game/SourceBlockDrawSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceBlockDrawState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('const SOURCE_BLOCK_DRAW_POTENTIAL_LINKS_METHOD := "public void drawPotentialLinks(int x, int y){"', source)
        self.assertIn("static func draw_potential_links_state(", state)
        self.assertIn("static func generated_block_draw_potential_links_bridge_state(", state)
        self.assertIn("func source_block_draw_potential_links_state(", bridge)


if __name__ == "__main__":
    unittest.main()
