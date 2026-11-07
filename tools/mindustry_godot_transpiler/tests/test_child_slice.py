from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]


class ChildSliceTests(unittest.TestCase):
    def test_source_child_state_uses_source_text_generated_bridge_constants(self):
        module = ROOT / "godot-mindustry" / "src" / "game" / "SourceChildState.gd"
        owner = ROOT / "godot-mindustry" / "src" / "game" / "SourceEntityCompSourceTextState.gd"
        module_source = module.read_text(encoding="utf-8")
        owner_source = owner.read_text(encoding="utf-8")

        expected_generated = {
            "SOURCE_CHILD_ADD": ("java_method_add_0", "child_comp.java_method_add_0"),
            "SOURCE_CHILD_UPDATE": ("java_method_update_1", "child_comp.java_method_update_1"),
        }
        for prefix, (method_literal, owner_literal) in expected_generated.items():
            method_const = f"{prefix}_JAVA_METHOD"
            owner_const = f"{prefix}_GENERATED_OWNER"
            self.assertIn(f'const {method_const} := "{method_literal}"', owner_source)
            self.assertIn(f'const {owner_const} := "{owner_literal}"', owner_source)
            self.assertIn(f"const {method_const} := source_entity_comp_source_text_state.{method_const}", module_source)
            self.assertIn(f"const {owner_const} := source_entity_comp_source_text_state.{owner_const}", module_source)
            self.assertIn(f'"generated_owner": {owner_const}', module_source)
            self.assertNotIn(f'_child_comp_call("{method_literal}"', module_source)
            self.assertNotIn(f'"generated_owner": "{owner_literal}"', module_source)

    def test_source_child_state_uses_source_text_method_and_callback_literals(self):
        module = ROOT / "godot-mindustry" / "src" / "game" / "SourceChildState.gd"
        owner = ROOT / "godot-mindustry" / "src" / "game" / "SourceEntityCompSourceTextState.gd"
        module_source = module.read_text(encoding="utf-8")
        owner_source = owner.read_text(encoding="utf-8")

        expected_literals = {
            "SOURCE_CHILD_TRNS_VEC_KEY": "trns_vec",
            "SOURCE_CHILD_TRNS_VEC_FALLBACK": "source_arc_angles_trns_vec",
            "SOURCE_CHILD_ADD_METHOD": "public void add(){",
            "SOURCE_CHILD_UPDATE_METHOD": "public void update(){",
        }
        for const_name, literal in expected_literals.items():
            self.assertIn(f'const {const_name} := "{literal}"', owner_source)
            self.assertIn(f"const {const_name} := source_entity_comp_source_text_state.{const_name}", module_source)
            self.assertNotIn(f'const {const_name} := "{literal}"', module_source)

