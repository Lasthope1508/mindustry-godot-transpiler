from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockRuntimeGeometryGeneratedDelegateSliceTests(unittest.TestCase):
    def test_generated_block_runtime_geometry_methods_delegate_to_canonical_state(self):
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
            "return source_block_runtime_geometry_state.update_clip_radius_state(clip_size_before, size_value, tilesize_value, radius_in_world_units)",
            generated,
        )
        self.assertIn(
            "return source_block_runtime_geometry_state.bounds_state(x_value, y_value, size_value, tilesize_value, offset_value, rect_value)",
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_update_clip_radius_state"',
            generated,
        )
        self.assertNotIn(
            'return {"source_owner": "port_game.source_block_bounds_state"',
            generated,
        )


if __name__ == "__main__":
    unittest.main()
