from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockOnNewPlanGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_on_new_plan_delegates_to_canonical_plan_placement_state(self):
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
            "return source_block_plan_placement_state.on_new_plan_state(plan)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_on_new_plan_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
