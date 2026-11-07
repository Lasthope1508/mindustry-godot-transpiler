import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]


class BuildingGetCursorGeneratedSliceTests(unittest.TestCase):
    def test_generated_method_delegates_to_existing_meta_owner(self):
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        body = generated.split("func java_method_getCursor_165", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("source_building_meta_state.cursor_state", body)
        self.assertNotIn('var cursor := "hand" if block_configurable and interactable_player_team else "arrow"', body)

    def test_generated_slice_reuses_canonical_cursor_owner(self):
        ledger = json.loads((ROOT / "godot-mindustry/src/generated/source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        self.assertEqual(ledger["N1957"]["godot_owner"], "PortGame.source_building_cursor_state")
        self.assertEqual(ledger["N1957"]["generated_owner"], "BuildingComp.java_method_getCursor_165")


if __name__ == "__main__":
    unittest.main()
