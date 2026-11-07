import unittest
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class BuildingOnConfigureBuildTappedGeneratedSliceTests(unittest.TestCase):
    def test_generated_method_delegates_to_existing_canonical_configure_owner(self):
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        body = generated.split("func java_method_onConfigureBuildTapped_166", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_configure_state.on_configure_build_tapped_state", body)
        self.assertNotIn("return null", body)

    def test_source_boundary_and_existing_ssot_are_preserved(self):
        source = (ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java").read_text(encoding="utf-8")
        self.assertIn("public boolean onConfigureBuildTapped(Building other){", source)
        for expression in ("if(block.clearOnDoubleTap){", "if(self() == other){", "deselect();", "configure(null);", "return false;", "return true;", "return self() != other;"):
            self.assertIn(expression, source)
        state = (ROOT / "godot-mindustry/src/game/SourceBuildingConfigureState.gd").read_text(encoding="utf-8")
        self.assertIn("static func on_configure_build_tapped_state", state)

    def test_generated_bridge_slice_reuses_existing_owner(self):
        generated = ROOT / "godot-mindustry/src/generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        self.assertEqual(ledger["N1953"]["godot_owner"], "PortGame.source_building_on_configure_build_tapped_state")
        self.assertEqual(ledger["N1953"]["generated_owner"], "BuildingComp.java_method_onConfigureBuildTapped_166")
        self.assertEqual(registry["building_on_configure_build_tapped.method"]["godot_owner"], "PortGame.source_building_on_configure_build_tapped_state")
        self.assertNotIn("building_on_configure_build_tapped.generated_delegate", registry)


if __name__ == "__main__":
    unittest.main()
