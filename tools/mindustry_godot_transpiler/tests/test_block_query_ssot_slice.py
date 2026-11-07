import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockQuerySsotSliceTests(unittest.TestCase):
    def test_generated_outputs_items_delegates_to_canonical_query_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockQueryState.gd").read_text(encoding="utf-8")

        self.assertIn(
            'const source_block_query_state := preload("res://src/game/SourceBlockQueryState.gd")',
            generated,
        )
        self.assertIn(
            "return source_block_query_state.generated_outputs_items_result_state(has_items)",
            generated,
        )
        self.assertNotIn('return {"source_owner": "port_game.source_block_outputs_items_state"', generated)
        self.assertIn("static func generated_outputs_items_result_state(has_items: bool)", module)


if __name__ == "__main__":
    unittest.main()
