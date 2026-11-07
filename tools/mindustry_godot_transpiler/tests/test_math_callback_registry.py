import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GAME = ROOT / "godot-mindustry" / "src" / "game"


class MathCallbackRegistryTests(unittest.TestCase):
    def test_shared_math_callback_literals_have_one_canonical_owner(self):
        registry = GAME / "SourceMathCallbackRegistry.gd"
        source = registry.read_text(encoding="utf-8")
        literals = [
            'const APPROACH_DELTA_KEY := "approach_delta"',
            'const MATHF_APPROACH_DELTA_FALLBACK := "source_mathf_approach_delta"',
            'const LERP_DELTA_KEY := "lerp_delta"',
            'const MATHF_LERP_DELTA_FALLBACK := "source_mathf_lerp_delta"',
            'const ARC_LERP_DELTA_FALLBACK := "source_arc_lerp_delta"',
            'const MATHF_DST_KEY := "mathf_dst"',
            'const MATHF_DST_FALLBACK := "source_mathf_dst"',
            'const VEC2_LIMIT_KEY := "vec2_limit"',
            'const ARC_VEC2_LIMIT_FALLBACK := "source_arc_vec2_limit"',
            'const VECTOR_STATE_LIMIT_FALLBACK := "source_vec2_limit"',
        ]
        self.assertIn("class_name SourceMathCallbackRegistry", source)
        for literal in literals:
            self.assertEqual(source.count(literal), 1)

        consumers = [
            "SourceWeaponsCallbackRegistry.gd",
            "SourceTractorBeamCallbackRegistry.gd",
            "SourceBuildingDrawState.gd",
            "SourceConstructBuildState.gd",
            "SourceUnitUpdateCallbackRegistry.gd",
            "SourceBulletTypeUpdateMotionState.gd",
        ]
        for name in consumers:
            consumer = (GAME / name).read_text(encoding="utf-8")
            self.assertIn(
                'const source_math_callback_registry := preload("res://src/game/SourceMathCallbackRegistry.gd")',
                consumer,
            )
            for literal in literals:
                self.assertNotIn(literal, consumer)


if __name__ == "__main__":
    unittest.main()
