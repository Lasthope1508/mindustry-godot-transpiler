import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockQueryFilterGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_filter_queries_delegate_to_canonical_module(self):
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
            'const source_block_query_filter_state := preload("res://src/game/SourceBlockQueryFilterState.gd")',
            generated,
        )
        self.assertIn(
            "return source_block_query_filter_state.consumes_item_state(item_filter, item_id, item)",
            generated,
        )
        self.assertIn(
            "return source_block_query_filter_state.consumes_liquid_state(liquid_filter, liquid_id, liq)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_consumes_item_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_consumes_liquid_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
