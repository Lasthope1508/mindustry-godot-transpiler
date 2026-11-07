from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]


class UnitTetherSliceTests(unittest.TestCase):
    def test_source_unit_tether_state_uses_source_text_generated_bridge_constants(self):
        module = ROOT / "godot-mindustry" / "src" / "game" / "SourceUnitTetherState.gd"
        owner = ROOT / "godot-mindustry" / "src" / "game" / "SourceEntityCompSourceTextState.gd"
        module_source = module.read_text(encoding="utf-8")
        owner_source = owner.read_text(encoding="utf-8")

        expected_generated = {
            "SOURCE_UNIT_TETHER_AFTER_READ": ("java_method_afterRead_0", "unit_tether_comp.java_method_afterRead_0"),
            "SOURCE_UNIT_TETHER_AFTER_SYNC": ("java_method_afterSync_1", "unit_tether_comp.java_method_afterSync_1"),
            "SOURCE_UNIT_TETHER_UPDATE": ("java_method_update_2", "unit_tether_comp.java_method_update_2"),
        }
        for prefix, (method_literal, owner_literal) in expected_generated.items():
            method_const = f"{prefix}_JAVA_METHOD"
            owner_const = f"{prefix}_GENERATED_OWNER"
            self.assertIn(f'const {method_const} := "{method_literal}"', owner_source)
            self.assertIn(f'const {owner_const} := "{owner_literal}"', owner_source)
            self.assertIn(f"const {method_const} := source_entity_comp_source_text_state.{method_const}", module_source)
            self.assertIn(f"const {owner_const} := source_entity_comp_source_text_state.{owner_const}", module_source)
            self.assertIn(f'"generated_owner": {owner_const}', module_source)
            self.assertNotIn(f'_unit_tether_comp_call("{method_literal}"', module_source)
            self.assertNotIn(f'"generated_owner": "{owner_literal}"', module_source)

    def test_source_unit_tether_state_uses_source_text_method_literals(self):
        module = ROOT / "godot-mindustry" / "src" / "game" / "SourceUnitTetherState.gd"
        owner = ROOT / "godot-mindustry" / "src" / "game" / "SourceEntityCompSourceTextState.gd"
        module_source = module.read_text(encoding="utf-8")
        owner_source = owner.read_text(encoding="utf-8")

        expected_literals = {
            "SOURCE_UNIT_TETHER_AFTER_READ_METHOD": "public void afterRead(){",
            "SOURCE_UNIT_TETHER_AFTER_SYNC_METHOD": "public void afterSync(){",
            "SOURCE_UNIT_TETHER_READ_SYNC_GUARD_EXPR": "if(spawnerUnitId != -1) spawner = Groups.unit.getByID(spawnerUnitId);",
            "SOURCE_UNIT_TETHER_READ_SYNC_RESET_EXPR": "spawnerUnitId = -1;",
            "SOURCE_UNIT_TETHER_GROUPS_UNIT_GET_BY_ID_CALL": "Groups.unit.getByID(spawnerUnitId)",
            "SOURCE_UNIT_TETHER_UPDATE_METHOD": "public void update(){",
            "SOURCE_UNIT_TETHER_UPDATE_GUARD_EXPR": "if(spawner == null || !spawner.isValid() || spawner.team != team){",
            "SOURCE_UNIT_TETHER_UPDATE_ELSE_EXPR": "}else{",
            "SOURCE_UNIT_TETHER_UPDATE_ELSE_KEY": "else:",
            "SOURCE_UNIT_TETHER_UPDATE_DESPAWN_CALL": "Call.unitDespawn(self())",
            "SOURCE_UNIT_TETHER_UPDATE_ASSIGN_EXPR": "spawnerUnitId = spawner.id;",
        }
        for const_name, literal in expected_literals.items():
            self.assertIn(f'const {const_name} := "{literal}"', owner_source)
            self.assertIn(f"const {const_name} := source_entity_comp_source_text_state.{const_name}", module_source)
            self.assertNotIn(f'const {const_name} := "{literal}"', module_source)
