import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockSumAttributeSliceTests(unittest.TestCase):
    def test_generated_method_preserves_attribute_guards_and_sum(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/Block.gd").read_text(encoding="utf-8")
        match = re.search(r"func java_method_sumAttribute_12\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)", source, re.S)
        self.assertIsNotNone(match)
        body = match.group("body")
        self.assertIn("return source_block_attribute_state.generated_block_sum_attribute_result_state(", body)
        self.assertNotIn("if attr_present and tile_present:", body)
        self.assertNotIn('"null_attr_guard_expr":', body)
        self.assertNotIn('"null_tile_guard_expr":', body)
        self.assertNotIn('"source_owner": "port_game.source_block_sum_attribute_state"', body)
        self.assertNotIn("return null", body)

    def test_canonical_attribute_module_is_exposed_by_facade(self):
        state = (PROJECT / "src/game/SourceBlockAttributeState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        source = (PROJECT / "src/game/SourceBlockAttributeSourceTextState.gd").read_text(encoding="utf-8")
        self.assertIn("static func sum_attribute_state(", state)
        self.assertIn("static func generated_block_sum_attribute_result_state(", state)
        self.assertIn("static func generated_block_sum_attribute_bridge_state(", state)
        self.assertIn("func source_block_sum_attribute_state(", bridge)
        self.assertIn("func generated_block_sum_attribute_bridge_state(", bridge)
        self.assertIn('const SOURCE_BLOCK_SUM_ATTRIBUTE_METHOD := "public float sumAttribute(@Nullable Attribute attr, int x, int y){"', source)


if __name__ == "__main__":
    unittest.main()
