from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockGetReplacementGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_get_replacement_delegates_to_canonical_plan_state(self):
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
            "return source_block_plan_placement_state.get_replacement_state(req, plans, self_block)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_get_replacement_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
