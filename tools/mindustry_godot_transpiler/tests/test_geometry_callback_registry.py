import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


class GeometryCallbackRegistryTests(unittest.TestCase):
    def test_shared_geometry_literals_have_one_canonical_owner(self):
        registry = GAME / "SourceGeometryCallbackRegistry.gd"
        source = registry.read_text(encoding="utf-8")
        literals = [
            'const TRNS_VEC_KEY := "trns_vec"',
            'const TRNS_VEC_FALLBACK := "source_arc_angles_trns_vec"',
            'const ANGLES_ANGLE_KEY := "angles_angle"',
            'const ANGLES_ANGLE_FALLBACK := "source_arc_angles_angle"',
            'const ANGLE_KEY := "angle"',
            'const ANGLE_FALLBACK := "source_arc_angles_angle"',
            'const MOVE_TOWARD_ANGLE_KEY := "move_toward_angle"',
            'const MOVE_TOWARD_ANGLE_FALLBACK := "source_arc_angles_move_toward"',
            'const ANGLE_DIST_KEY := "angle_dist"',
            'const ANGLE_DIST_FALLBACK := "source_angles_angle_dist"',
        ]
        self.assertIn("class_name SourceGeometryCallbackRegistry", source)
        for literal in literals:
            self.assertEqual(source.count(literal), 1)

        consumers = [
            "SourceWeaponsCallbackRegistry.gd",
            "SourceUnitUpdateCallbackRegistry.gd",
            "SourceTurretAimCallbackState.gd",
            "SourceBulletTypeCreateState.gd",
            "SourceBulletTypeCreateFragsState.gd",
            "SourceBulletTypeUpdateMotionState.gd",
            "SourceBulletTypeUpdateState.gd",
            "SourceTractorBeamCallbackRegistry.gd",
        ]
        for name in consumers:
            consumer = (GAME / name).read_text(encoding="utf-8")
            self.assertIn(
                'const source_geometry_callback_registry := preload("res://src/game/SourceGeometryCallbackRegistry.gd")',
                consumer,
            )
            for literal in literals:
                self.assertNotIn(literal, consumer)


if __name__ == "__main__":
    unittest.main()
