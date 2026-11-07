import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]

class BuildingGetDisplayIconGeneratedSliceTests(unittest.TestCase):
    def test_generated_method_delegates_to_canonical_display_owner(self):
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        body = generated.split("func java_method_getDisplayIcon_158", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_display_state.generated_building_comp_get_display_icon_bridge_state", body)
        self.assertNotIn("return null", body)

    def test_source_boundary_and_ssot_slice_are_registered(self):
        source = (ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java").read_text(encoding="utf-8")
        self.assertIn("public TextureRegion getDisplayIcon(){", source)
        self.assertIn("return block.uiIcon;", source)
        generated = ROOT / "godot-mindustry/src/generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        self.assertEqual(ledger["N1954"]["godot_owner"], "PortGame.source_building_display_icon_state")
        self.assertEqual(ledger["N1954"]["generated_owner"], "BuildingComp.java_method_getDisplayIcon_158")

    def test_display_module_exposes_generated_bridge(self):
        module = (ROOT / "godot-mindustry/src/game/SourceBuildingDisplayState.gd").read_text(encoding="utf-8")
        bridge = (ROOT / "godot-mindustry/src/game/SourceBuildingDisplayPortBridge.gd").read_text(encoding="utf-8")
        self.assertIn("static func generated_building_comp_get_display_icon_bridge_state", module)
        self.assertIn("func generated_building_comp_get_display_icon_bridge_state", bridge)

if __name__ == "__main__":
    unittest.main()
