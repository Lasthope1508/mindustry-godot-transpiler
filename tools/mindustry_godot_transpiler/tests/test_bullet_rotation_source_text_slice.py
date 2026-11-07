import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BulletRotationSourceTextSliceTests(unittest.TestCase):
    def test_rotation_literals_have_one_canonical_source_text_owner(self):
        source_text = (PROJECT / "src" / "game" / "SourceBulletSourceTextState.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src" / "game" / "SourceBulletTypeUpdateState.gd").read_text(encoding="utf-8")
        expected = {
            "SOURCE_BULLET_ROTATION_COMMENT": "/** @return the bullet's rotation. */",
            "SOURCE_BULLET_ROTATION_METHOD": "public float rotation(){",
            "SOURCE_BULLET_ROTATION_RETURN": "return vel.isZero(0.001f) ? rotation : vel.angle();",
        }
        self.assertIn("class_name SourceBulletSourceTextState", source_text)
        self.assertIn('const source_bullet_source_text_state := preload("res://src/game/SourceBulletSourceTextState.gd")', module)
        for name, literal in expected.items():
            self.assertIn(f'const {name} := "{literal}"', source_text)
            self.assertIn(f"const {name} := source_bullet_source_text_state.{name}", module)
            self.assertNotIn(f'const {name} := "{literal}"', module)


if __name__ == "__main__":
    unittest.main()
