from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockConfigSenseableGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_config_senseable_delegates_to_canonical_plan_config_state(self):
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
            "return source_block_plan_config_state.config_senseable_state(item_configured, liquid_configured, unlockable_content_configured, block_configured, unit_type_configured)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_config_senseable_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
