import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockReinitializeConsumersSsotSliceTests(unittest.TestCase):
    def test_source_text_module_owns_contract_and_input_literals(self):
        source_text = (PROJECT / "src" / "game" / "SourceBlockReinitializeConsumersSourceTextState.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockReinitializeConsumersState.gd").read_text(
            encoding="utf-8"
        )
        constants = {
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_RESULT_KEY": "result",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CANONICAL_KEY": "canonical",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_MATCHES_KEY": "matches",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_INPUT_IS_POWER_KEY": "is_consume_power",
        }
        shared_aliases = {
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_SOURCE": "SOURCE_BLOCK_INIT_CONSUMER_SOURCE",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CONSUME_SOURCE": "SOURCE_BLOCK_INIT_CONSUMER_CONSUME_SOURCE",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CONSUMERS_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_CONSUMERS_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_OPTIONAL_CONSUMERS_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_OPTIONAL_CONSUMERS_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_NON_OPTIONAL_CONSUMERS_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_NON_OPTIONAL_CONSUMERS_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_UPDATE_CONSUMERS_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_UPDATE_CONSUMERS_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_HAS_CONSUMERS_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_HAS_CONSUMERS_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CONSUME_OPTIONAL_FIELD_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_OPTIONAL_FIELD_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CONSUME_UPDATE_FIELD_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_UPDATE_FIELD_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CONSUME_IGNORE_METHOD_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_IGNORE_METHOD_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_LOOP_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_LOOP_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_APPLY_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_APPLY_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_APPLY_METHOD_EXPR": "SOURCE_BLOCK_INIT_CONSUMER_APPLY_METHOD_EXPR",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_THIS_ARG": "SOURCE_BLOCK_INIT_CONSUMER_THIS_ARG",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_SOURCE_OWNER_KEY": "SOURCE_BLOCK_INIT_CONSUMER_SOURCE_OWNER_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_SOURCE_KEY": "SOURCE_BLOCK_INIT_CONSUMER_SOURCE_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CONSUME_SOURCE_KEY": "SOURCE_BLOCK_INIT_CONSUMER_CONSUME_SOURCE_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_INPUT_IGNORED_KEY": "SOURCE_BLOCK_INIT_CONSUMER_INPUT_IGNORED_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_INPUT_OPTIONAL_KEY": "SOURCE_BLOCK_INIT_CONSUMER_INPUT_OPTIONAL_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_INPUT_UPDATE_KEY": "SOURCE_BLOCK_INIT_CONSUMER_INPUT_UPDATE_KEY",
        }
        self.assertIn("class_name SourceBlockReinitializeConsumersSourceTextState", source_text)
        self.assertIn(
            'const source_block_init_consumer_source_text_state := preload("res://src/game/SourceBlockInitConsumerSourceTextState.gd")',
            source_text,
        )
        self.assertIn(
            'const source_block_reinitialize_consumers_source_text_state := preload("res://src/game/SourceBlockReinitializeConsumersSourceTextState.gd")',
            module,
        )
        for name, literal in constants.items():
            self.assertIn(f'const {name} := "{literal}"', source_text)
            self.assertIn(
                f"const {name} := source_block_reinitialize_consumers_source_text_state.{name}",
                module,
            )
            self.assertNotIn(f'const {name} := "{literal}"', module)
        for name, shared_name in shared_aliases.items():
            self.assertIn(
                f"const {name} := source_block_init_consumer_source_text_state.{shared_name}",
                source_text,
            )

    def test_module_uses_canonical_keys_for_runtime_contracts(self):
        module = (PROJECT / "src" / "game" / "SourceBlockReinitializeConsumersState.gd").read_text(
            encoding="utf-8"
        )
        for key in (
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_SOURCE_OWNER_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CONSUMERS_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_APPLY_CALLS_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_RESULT_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_CANONICAL_KEY",
            "SOURCE_BLOCK_REINITIALIZE_CONSUMERS_MATCHES_KEY",
        ):
            self.assertIn(key + ":", module)

    def test_generated_block_branches_delegate_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )

        self.assertIn('const source_block_reinitialize_consumers_state := preload("res://src/game/SourceBlockReinitializeConsumersState.gd")', generated)
        self.assertIn("return source_block_reinitialize_consumers_state.generated_arrays_result_state(consumer_builder_entries)", generated)
        self.assertIn("return source_block_reinitialize_consumers_state.generated_item_liquid_filters_result_state(content_items_size, content_liquids_size)", generated)
        self.assertIn("return source_block_reinitialize_consumers_state.generated_outputs_power_result_state(outputs_power, has_power_before)", generated)
        self.assertIn("return source_block_reinitialize_consumers_state.generated_apply_loop_result_state(consumer_entries)", generated)

    def test_consumer_array_classification_uses_shared_consume_registry(self):
        module = (PROJECT / "src" / "game" / "SourceBlockReinitializeConsumersState.gd").read_text(
            encoding="utf-8"
        )
        self.assertIn(
            'const source_consume_module_registry := preload("res://src/game/SourceConsumeModuleRegistry.gd")',
            module,
        )
        self.assertIn(
            "source_consume_module_registry.source_consume_state.classify_consumer_arrays(",
            module,
        )
        self.assertNotIn("for consumer in consume_builder:", module)

    def test_consumer_apply_call_projection_uses_shared_consume_registry(self):
        module = (PROJECT / "src" / "game" / "SourceBlockReinitializeConsumersState.gd").read_text(encoding="utf-8")
        self.assertIn(
            "source_consume_module_registry.source_consume_state.consumer_apply_calls(",
            module,
        )
        self.assertNotIn("var apply_calls: Array = []", module)
