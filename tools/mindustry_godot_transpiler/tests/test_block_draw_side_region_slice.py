import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockDrawSideRegionSliceTests(unittest.TestCase):
    def test_generated_method_delegates_geometry_to_canonical_state(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/Block.gd").read_text(encoding="utf-8")
        match = re.search(
            r"func java_method_drawSideRegion_6\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)",
            source,
            re.S,
        )
        self.assertIsNotNone(match)
        body = match.group("body")
        self.assertIn("return source_block_draw_state.generated_draw_side_region_result_state(", body)
        self.assertNotIn("posmod(rotation, 4)", body)
        self.assertNotIn("block_size * source_tilesize / 2.0", body)
        self.assertNotIn("region_width / 2.0 * region_scale", body)
        self.assertNotIn("return {", body)

    def test_canonical_module_owns_the_same_geometry(self):
        source = (PROJECT / "src/game/SourceBlockDrawSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceBlockDrawState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn('const SOURCE_BLOCK_DRAW_SIDE_REGION_METHOD := "public void drawSideRegion(TextureRegion region, float x, float y, int rotation){"', source)
        self.assertIn("static func draw_side_region_state(", state)
        self.assertIn("static func generated_block_draw_side_region_bridge_state(", state)
        self.assertIn("func source_block_draw_side_region_state(", bridge)


if __name__ == "__main__":
    unittest.main()
