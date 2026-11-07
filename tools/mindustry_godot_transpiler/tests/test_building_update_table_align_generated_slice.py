import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class BuildingUpdateTableAlignGeneratedSliceTests(unittest.TestCase):
    def test_generated_method_is_not_stub_and_delegates_to_configure_domain(self):
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        body = generated.split("func java_method_updateTableAlign_164", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_configure_state.generated_update_table_align_bridge_state", body)
        self.assertNotIn("return null", body)

    def test_source_boundary_and_ssot_slice_are_registered(self):
        source = (ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java").read_text(encoding="utf-8")
        self.assertIn("public void updateTableAlign(Table table){", source)
        self.assertIn("Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", source)
        self.assertIn("table.setPosition(pos.x, pos.y, Align.top);", source)
        ledger = json.loads((ROOT / "godot-mindustry/src/generated/source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        self.assertEqual(ledger["N1956"]["godot_owner"], "PortGame.source_building_update_table_align_state")
        self.assertEqual(ledger["N1956"]["generated_owner"], "BuildingComp.java_method_updateTableAlign_164")

    def test_configure_module_exposes_update_table_align_bridge(self):
        module = (ROOT / "godot-mindustry/src/game/SourceBuildingConfigureState.gd").read_text(encoding="utf-8")
        bridge = (ROOT / "godot-mindustry/src/game/SourceBuildingConfigurePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn("static func generated_update_table_align_bridge_state", module)
        self.assertIn("func generated_building_comp_update_table_align_bridge_state", bridge)


if __name__ == "__main__":
    unittest.main()
