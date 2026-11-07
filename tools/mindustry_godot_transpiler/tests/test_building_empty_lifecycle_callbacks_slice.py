import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "mindustry-upstream/core/src/mindustry/entities/comp/BuildingComp.java"
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingEmptyLifecycleCallbacksSliceTests(unittest.TestCase):
    METHODS = {
        "java_method_itemTaken_68": "public void itemTaken(Item item){",
        "java_method_dropped_70": "public void dropped(){",
        "java_method_handleString_71": "public void handleString(Object value){",
        "java_method_created_72": "public void created(){}",
        "java_method_getStackOffset_81": "public void getStackOffset(Item item, Vec2 trns){",
    }

    def test_source_has_exact_empty_callback_boundaries(self):
        source = SOURCE.read_text(encoding="utf-8")
        for expression in self.METHODS.values():
            self.assertIn(expression, source)

    def test_generated_callbacks_delegate_to_one_canonical_helper(self):
        generated = GENERATED.read_text(encoding="utf-8")
        for method_name in self.METHODS:
            body = generated.split(f"func {method_name}", 1)[1].split("\nfunc ", 1)[0]
            self.assertIn("source_building_lifecycle_state.empty_lifecycle_callback_state", body)
            self.assertNotIn("return null", body)

    def test_slice_and_owner_are_registered(self):
        generated = ROOT / "godot-mindustry/src/generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        owner = "PortGame.source_building_empty_lifecycle_callbacks_state"
        self.assertEqual(ledger["N1952"]["godot_owner"], owner)
        self.assertEqual(ledger["N1952"]["status"], "done")
        for key in ("building_empty_lifecycle_callbacks.item_taken", "building_empty_lifecycle_callbacks.dropped", "building_empty_lifecycle_callbacks.handle_string", "building_empty_lifecycle_callbacks.created", "building_empty_lifecycle_callbacks.get_stack_offset"):
            self.assertEqual(registry[key]["godot_owner"], owner)


if __name__ == "__main__":
    unittest.main()
