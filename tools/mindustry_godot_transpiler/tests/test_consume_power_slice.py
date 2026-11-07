from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]


class ConsumePowerSliceTests(unittest.TestCase):
    def test_source_consume_power_state_uses_source_text_generated_bridge_constants(self):
        consume_power = ROOT / "godot-mindustry" / "src" / "game" / "SourceConsumePowerState.gd"
        source_text = ROOT / "godot-mindustry" / "src" / "game" / "SourceConsumeSourceTextState.gd"
        module_source = consume_power.read_text(encoding="utf-8")
        source_text_source = source_text.read_text(encoding="utf-8")

        expected = {
            "SOURCE_CONSUME_POWER_REQUESTED_POWER": ("java_method_requestedPower_4", "consume_power.requestedPower"),
            "SOURCE_CONSUME_POWER_APPLY": ("java_method_apply_0", "consume_power.apply"),
            "SOURCE_CONSUME_POWER_IGNORE": ("java_method_ignore_1", "consume_power.ignore"),
            "SOURCE_CONSUME_POWER_EFFICIENCY": ("java_method_efficiency_2", "consume_power.efficiency"),
            "SOURCE_CONSUME_POWER_DISPLAY": ("java_method_display_3", "consume_power.display"),
            "SOURCE_CONSUME_POWER_CONDITION_REQUESTED_POWER": ("java_method_requestedPower_0", "consume_power_condition.requestedPower"),
            "SOURCE_CONSUME_POWER_DYNAMIC_REQUESTED_POWER": ("java_method_requestedPower_0", "consume_power_dynamic.requestedPower"),
            "SOURCE_CONSUME_POWER_DYNAMIC_DISPLAY": ("java_method_display_1", "consume_power_dynamic.display"),
        }
        for prefix, (method_literal, owner_literal) in expected.items():
            method_const = f"{prefix}_JAVA_METHOD"
            owner_const = f"{prefix}_GENERATED_OWNER"
            self.assertIn(f'const {method_const} := "{method_literal}"', source_text_source)
            self.assertIn(f'const {owner_const} := "{owner_literal}"', source_text_source)
            self.assertIn(f"const {method_const} := source_consume_source_text_state.{method_const}", module_source)
            self.assertIn(f"const {owner_const} := source_consume_source_text_state.{owner_const}", module_source)
            self.assertIn(f'"generated_owner": {owner_const}', module_source)

