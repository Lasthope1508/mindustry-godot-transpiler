import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockCanReplaceGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_can_replace_delegates_to_pure_canonical_state(self):
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
            'const source_building_core_state := preload("res://src/game/SourceBuildingCoreState.gd")',
            generated,
        )
        self.assertIn(
            "return source_building_core_state.block_can_replace_result_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)",
            generated,
        )
        self.assertNotIn("var replacement_gate: bool =", generated)
        self.assertNotIn('return {"source_owner": "port_game.source_block_can_replace_state"', generated)


if __name__ == "__main__":
    unittest.main()
