import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BlockCheckContentArrayCapacitySliceTests(unittest.TestCase):
    def test_port_game_delegates_block_check_content_array_capacity_to_dedicated_module(self):
        bridge_source = (PROJECT / "src" / "game" / "SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        module_source = (
            PROJECT / "src" / "game" / "SourceBlockCheckContentArrayCapacityState.gd"
        ).read_text(encoding="utf-8")
        registry_source = (PROJECT / "src" / "game" / "SourceRuntimeOwnerBlockRegistry.gd").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            'const source_block_check_content_array_capacity_state_script := preload("res://src/game/SourceBlockCheckContentArrayCapacityState.gd")',
            bridge_source,
        )
        self.assertIn(
            "return source_block_check_content_array_capacity_state_script.check_content_array_capacity_state(item_filter, liquid_filter, items, liquids)",
            bridge_source,
        )
        self.assertIn(
            "return source_block_check_content_array_capacity_state_script.generated_block_check_content_array_capacity_bridge_state(item_filter, liquid_filter, items, liquids)",
            bridge_source,
        )
        self.assertIn(
            "static func check_content_array_capacity_state(item_filter: Array, liquid_filter: Array, items: int, liquids: int) -> Dictionary:",
            module_source,
        )
        self.assertIn(
            "source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_STATE",
            module_source,
        )
        self.assertIn(
            'const PORT_GAME_SOURCE_BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_STATE := "port_game.source_block_check_content_array_capacity_state"',
            registry_source,
        )

    def test_runtime_proof_uses_canonical_runtime_proof_state(self):
        proof_source = (
            PROJECT / "tools" / "runtime_proofs" / "BlockCheckContentArrayCapacityModuleProof.gd"
        ).read_text(encoding="utf-8")

        self.assertIn('const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")', proof_source)
        self.assertIn('runtime_proof_state.write_proof("BlockCheckContentArrayCapacityModuleProof", proof)', proof_source)
        self.assertIn("get_tree().quit(runtime_proof_state.exit_code(proof))", proof_source)
        self.assertNotIn("FileAccess.open", proof_source)
        self.assertNotIn("get_tree().quit(0)", proof_source)


if __name__ == "__main__":
    unittest.main()
