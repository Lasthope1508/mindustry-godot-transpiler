import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class BuildingVisibilitySliceTests(unittest.TestCase):
    def test_generated_is_discovered_delegates_to_visibility_owner(self):
        generated = (PROJECT / "src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        body = generated.split("func java_method_isDiscovered_14", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_visibility_state.is_discovered_state", body)
        self.assertNotIn("return null", body)

    def test_visibility_module_keeps_is_discovered_source_text_canonical(self):
        source_text = (PROJECT / "src/game/SourceBuildingSourceTextState.gd").read_text(encoding="utf-8")
        module = (PROJECT / "src/game/SourceBuildingVisibilityState.gd").read_text(encoding="utf-8")
        upstream = (ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java").read_text(encoding="utf-8")
        for literal in (
            "public boolean isDiscovered(Team viewer){",
            "if(state.rules.limitMapArea && world.getDarkness(tile.x, tile.y) >= 3){",
            "if(viewer == null || !state.rules.staticFog || !state.rules.fog){",
            "if(block.size <= 2){",
            "int s = block.size / 2;",
            "fogControl.isDiscovered(viewer, tile.x + s, tile.y - s);",
        ):
            self.assertIn(literal, upstream)
            self.assertIn(literal, source_text)
        self.assertIn("static func is_discovered_state", module)
        self.assertIn("static func generated_is_discovered_bridge_state", module)
        self.assertIn("source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_DISCOVERED_STATE", module)

    def test_is_discovered_slice_is_registered_to_the_visibility_owner(self):
        generated = PROJECT / "src/generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        owner = "PortGame.source_building_is_discovered_state"
        self.assertEqual(ledger["N1913"]["godot_owner"], owner)
        self.assertEqual(registry["building_is_discovered.method"]["godot_owner"], owner)
        self.assertEqual(contracts[owner]["source_slice"], "N1913")

    def test_visibility_runtime_proof_exercises_large_block_and_darkness_paths(self):
        proof = (PROJECT / "tools/runtime_proofs/BuildingVisibilityStateModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn("generated_building_comp_is_discovered_bridge_state", proof)
        self.assertIn('"is_discovered_bridge_matches"', proof)
        self.assertIn('"map_darkness_bridge_matches"', proof)


if __name__ == "__main__":
    unittest.main()
