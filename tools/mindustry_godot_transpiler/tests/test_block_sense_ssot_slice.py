import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockSenseSsotSliceTests(unittest.TestCase):
    def test_source_text_is_the_single_owner_of_sense_literals(self):
        source_text = (PROJECT / "src" / "game" / "SourceBlockSenseSourceTextState.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockSenseState.gd").read_text(
            encoding="utf-8"
        )

        expected = {
            "SOURCE_BLOCK_SENSE_SOURCE": "core/src/mindustry/world/Block.java",
            "SOURCE_BLOCK_SENSE_LACCESS_METHOD": "public double sense(LAccess sensor){",
            "SOURCE_BLOCK_SENSE_CONTENT_METHOD": "public double sense(Content content){",
            "SOURCE_BLOCK_SENSE_OBJECT_METHOD": "public Object senseObject(LAccess sensor){",
            "SOURCE_BLOCK_SENSE_LACCESS_DEFAULT_EXPR": "default -> Double.NaN;",
            "SOURCE_BLOCK_SENSE_CONTENT_AMOUNT_RETURN_EXPR": "return Math.round(r.amount * state.rules.buildCostMultiplier);",
            "SOURCE_BLOCK_SENSE_OBJECT_DEFAULT_RETURN_EXPR": "return noSensed;",
        }
        self.assertIn("class_name SourceBlockSenseSourceTextState", source_text)
        for name, literal in expected.items():
            self.assertIn(f'const {name} := "{literal}"', source_text)
            self.assertIn(f"const {name} := source_block_sense_source_text_state.{name}", module)
            self.assertNotIn(f'const {name} := "{literal}"', module)

    def test_generated_block_sense_methods_delegate_to_canonical_state(self):
        generated = (
            PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd"
        ).read_text(encoding="utf-8")
        module = (PROJECT / "src" / "game" / "SourceBlockSenseState.gd").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            'const source_block_sense_state := preload("res://src/game/SourceBlockSenseState.gd")',
            generated,
        )
        self.assertIn("return source_block_sense_state.generated_laccess_result_state(", generated)
        self.assertIn("return source_block_sense_state.generated_content_result_state(", generated)
        self.assertIn("return source_block_sense_state.generated_object_result_state(", generated)
        self.assertNotIn("\tmatch sensor:", generated)
        self.assertNotIn('\tif content_type == "Item":', generated)
        self.assertNotIn("\tvar sense_object_value: Variant = no_sensed", generated)
        self.assertIn("static func generated_laccess_result_state(", module)
        self.assertIn("static func generated_content_result_state(", module)
        self.assertIn("static func generated_object_result_state(", module)


if __name__ == "__main__":
    unittest.main()
