import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingDrawConfigureGeneratedDelegateTests(unittest.TestCase):
    def test_generated_draw_configure_delegates_to_existing_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_drawConfigure_171", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_draw_state.draw_configure_state(source_x, source_y, block_size_value, source_tilesize)", body)
        self.assertNotIn("var half_extent :=", body)
        self.assertNotIn('"square": SOURCE_BUILDING_DRAW_CONFIGURE_SQUARE_EXPR', body)

    def test_generated_draw_configure_keeps_existing_canonical_owner(self):
        generated = ROOT / "godot-mindustry/src/generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        self.assertEqual(ledger["N1959"]["godot_owner"], "PortGame.source_building_draw_configure_state")
        self.assertEqual(ledger["N1959"]["generated_owner"], "BuildingComp.java_method_drawConfigure_171")


if __name__ == "__main__":
    unittest.main()
