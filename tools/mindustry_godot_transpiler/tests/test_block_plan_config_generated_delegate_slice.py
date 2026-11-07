import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockPlanConfigGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_config_methods_delegate_to_canonical_config_module(self):
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
            "return source_block_plan_config_state.point_config_state(config, transformer)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_config_state.config_clear_state(cons)",
            generated,
        )
        self.assertIn(
            "return source_block_plan_config_state.config_handler_state(type_value, config_handler)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_point_config_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_config_clear_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_config_handler_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
