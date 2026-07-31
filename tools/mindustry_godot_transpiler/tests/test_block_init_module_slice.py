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
    def test_runtime_proofs_flush_json_before_long_timer(self):
        proof_dir = PROJECT / "tools" / "runtime_proofs"

        for proof_name in BLOCK_INIT_PROOFS:
            with self.subTest(proof=proof_name):
                proof_source = (proof_dir / proof_name).read_text(encoding="utf-8")

                self.assertIn("proof_file.store_string(proof_json)", proof_source)
                self.assertIn("proof_file.flush()", proof_source)

    def test_port_game_no_longer_depends_on_removed_block_init_runtime_owner(self):
        port_source = (PROJECT / "src" / "game" / "PortGame.gd").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("SourceBlockInitRuntimeState", port_source)
        self.assertIn(
            'const source_block_init_building_default_state_script := preload("res://src/game/SourceBlockInitBuildingDefaultState.gd")',
            port_source,
        )
        self.assertIn(
            'const source_block_check_content_array_capacity_state_script := preload("res://src/game/SourceBlockCheckContentArrayCapacityState.gd")',
            port_source,
        )


if __name__ == "__main__":
    unittest.main()
