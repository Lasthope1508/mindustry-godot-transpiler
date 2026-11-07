import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"

BLOCK_INIT_PROOFS = [
    "BlockInitBufferedPowerModuleProof.gd",
    "BlockInitBuildingDefaultModuleProof.gd",
    "BlockInitBuildTimeModuleProof.gd",
    "BlockInitClipModuleProof.gd",
    "BlockInitConsumerModuleProof.gd",
    "BlockInitFlagsModuleProof.gd",
    "BlockInitHealthModuleProof.gd",
    "BlockInitItemLiquidFiltersModuleProof.gd",
    "BlockInitLogicConfigurableModuleProof.gd",
    "BlockInitPlacementModuleProof.gd",
    "BlockInitSandboxVisibilityModuleProof.gd",
    "BlockInitSetBarsCallModuleProof.gd",
    "BlockInitSoundModuleProof.gd",
    "BlockInitStatsCategoriesModuleProof.gd",
]


class BlockInitModuleSliceTests(unittest.TestCase):
    def test_consumer_slice_literals_live_in_source_text_ssot(self):
        source_text = (PROJECT / "src" / "game" / "SourceBlockInitConsumerSourceTextState.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockInitConsumerState.gd").read_text(
            encoding="utf-8"
        )
        expected = {
            "SOURCE_BLOCK_INIT_CONSUMER_SOURCE": "core/src/mindustry/world/Block.java",
            "SOURCE_BLOCK_INIT_CONSUMER_CONSUME_SOURCE": "core/src/mindustry/world/consumers/Consume.java",
            "SOURCE_BLOCK_INIT_CONSUMER_METHOD": "public void init(){",
            "SOURCE_BLOCK_INIT_CONSUMER_SUPER_INIT_EXPR": "super.init();",
            "SOURCE_BLOCK_INIT_CONSUMER_CONSUMERS_EXPR": "consumers = consumeBuilder.toArray(Consume.class);",
            "SOURCE_BLOCK_INIT_CONSUMER_OPTIONAL_CONSUMERS_EXPR": "optionalConsumers = consumeBuilder.select(consume -> consume.optional && !consume.ignore()).toArray(Consume.class);",
            "SOURCE_BLOCK_INIT_CONSUMER_NON_OPTIONAL_CONSUMERS_EXPR": "nonOptionalConsumers = consumeBuilder.select(consume -> !consume.optional && !consume.ignore()).toArray(Consume.class);",
            "SOURCE_BLOCK_INIT_CONSUMER_UPDATE_CONSUMERS_EXPR": "updateConsumers = consumeBuilder.select(consume -> consume.update && !consume.ignore()).toArray(Consume.class);",
            "SOURCE_BLOCK_INIT_CONSUMER_HAS_CONSUMERS_EXPR": "hasConsumers = consumers.length > 0;",
            "SOURCE_BLOCK_INIT_CONSUMER_LOOP_EXPR": "for(Consume cons : consumers){",
            "SOURCE_BLOCK_INIT_CONSUMER_APPLY_EXPR": "cons.apply(this);",
            "SOURCE_BLOCK_INIT_CONSUMER_INPUT_IGNORED_KEY": "ignored",
            "SOURCE_BLOCK_INIT_CONSUMER_INPUT_OPTIONAL_KEY": "optional",
            "SOURCE_BLOCK_INIT_CONSUMER_INPUT_UPDATE_KEY": "update",
        }
        self.assertIn("class_name SourceBlockInitConsumerSourceTextState", source_text)
        for name, literal in expected.items():
            self.assertIn(f'const {name} := "{literal}"', source_text)
            self.assertIn(f"const {name} := source_block_init_consumer_source_text_state.{name}", module)
            self.assertNotIn(f'const {name} := "{literal}"', module)
        self.assertIn("static func generated_consumer_arrays_result_state(consume_builder: Array) -> Dictionary:", module)
        self.assertIn("static func generated_consumer_apply_loop_result_state(consumers: Array) -> Dictionary:", module)

    def test_generated_block_init_item_liquid_filters_delegates_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )
        module = (PROJECT / "src" / "game" / "SourceBlockInitItemLiquidFiltersState.gd").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            'const source_block_init_item_liquid_filters_state := preload("res://src/game/SourceBlockInitItemLiquidFiltersState.gd")',
            generated,
        )
        self.assertIn(
            "return source_block_init_item_liquid_filters_state.generated_item_liquid_filters_result_state(content_items_size, content_liquids_size)",
            generated,
        )
        self.assertNotIn("\t\tvar item_filter: Array = []", generated)
        self.assertNotIn("\t\tvar liquid_filter: Array = []", generated)
        self.assertIn(
            "static func generated_item_liquid_filters_result_state(content_items_size: int, content_liquids_size: int) -> Dictionary:",
            module,
        )

    def test_generated_block_init_consumer_branches_delegate_to_canonical_module(self):
        generated = (PROJECT / "src" / "generated" / "classes" / "mindustry" / "world" / "Block.gd").read_text(
            encoding="utf-8"
        )

        self.assertIn('const source_block_init_consumer_state := preload("res://src/game/SourceBlockInitConsumerState.gd")', generated)
        self.assertIn("return source_block_init_consumer_state.generated_consumer_arrays_result_state(consumer_builder_entries)", generated)
        self.assertIn("return source_block_init_consumer_state.generated_consumer_apply_loop_result_state(consumer_entries)", generated)

    def test_consumer_array_classification_uses_shared_consume_registry(self):
        module = (PROJECT / "src" / "game" / "SourceBlockInitConsumerState.gd").read_text(
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
        module = (PROJECT / "src" / "game" / "SourceBlockInitConsumerState.gd").read_text(encoding="utf-8")
        self.assertIn(
            "source_consume_module_registry.source_consume_state.consumer_apply_calls(",
            module,
        )
        self.assertNotIn("var apply_calls: Array = []", module)

    def test_runtime_proofs_use_canonical_finalizer_without_long_timer(self):
        proof_dir = PROJECT / "tools" / "runtime_proofs"

        for proof_name in BLOCK_INIT_PROOFS:
            with self.subTest(proof=proof_name):
                proof_source = (proof_dir / proof_name).read_text(encoding="utf-8")
                module_name = proof_name.removesuffix(".gd")

                self.assertIn('const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")', proof_source)
                self.assertIn('runtime_proof_state.write_proof("%s", proof)' % module_name, proof_source)
                self.assertIn("await get_tree().process_frame", proof_source)
                self.assertIn("get_tree().quit(runtime_proof_state.exit_code(proof))", proof_source)
                self.assertNotIn("await get_tree().create_timer(60.0).timeout", proof_source)
                self.assertNotIn("get_tree().quit(0)", proof_source)

    def test_port_game_no_longer_depends_on_removed_block_init_runtime_owner(self):
        port_source = (PROJECT / "src" / "game" / "PortGame.gd").read_text(
            encoding="utf-8"
        )
        block_init_bridge_source = (PROJECT / "src" / "game" / "SourceBlockInitPortBridge.gd").read_text(
            encoding="utf-8"
        )
        block_runtime_bridge_source = (PROJECT / "src" / "game" / "SourceBlockRuntimePortBridge.gd").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("SourceBlockInitRuntimeState", port_source)
        self.assertIn(
            'const source_block_init_building_default_state_script := preload("res://src/game/SourceBlockInitBuildingDefaultState.gd")',
            block_init_bridge_source,
        )
        self.assertIn(
            'const source_block_check_content_array_capacity_state_script := preload("res://src/game/SourceBlockCheckContentArrayCapacityState.gd")',
            block_runtime_bridge_source,
        )


if __name__ == "__main__":
    unittest.main()
