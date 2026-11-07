import json
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class BuildingConfigureEntrySliceTests(unittest.TestCase):
    def test_emitter_routes_configure_entry_methods_to_canonical_module(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            source = root / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void configure(Object value){}
    public void configureAny(Object value){}
    public void deselect(){}
    public boolean configTapped(){ return true; }
}
""",
                encoding="utf-8",
            )
            output = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(root / "core" / "src", output)
            generated = (output / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
            self.assertIn('const source_building_configure_state := preload("res://src/game/SourceBuildingConfigureState.gd")', generated)
            self.assertIn("source_building_configure_state.configure_state(block_state, player_state, self_state, value, tile_config_callback)", generated)
            self.assertIn("source_building_configure_state.configure_any_state(self_state, value, tile_config_callback)", generated)
            self.assertIn("source_building_configure_state.deselect_state(headless, selected_building, self_state, hide_config_callback)", generated)
            self.assertIn("return source_building_configure_state.config_tapped_state()", generated)

    def test_generated_configure_entry_methods_delegate_to_canonical_configure_module(self):
        generated = (ROOT / "godot-mindustry" / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        expected = {
            "java_method_configure_18": "source_building_configure_state.configure_state",
            "java_method_configureAny_19": "source_building_configure_state.configure_any_state",
            "java_method_deselect_20": "source_building_configure_state.deselect_state",
            "java_method_configTapped_21": "source_building_configure_state.config_tapped_state",
        }
        for method, delegate in expected.items():
            with self.subTest(method=method):
                body = generated.split(f"func {method}", 1)[1].split("\nfunc ", 1)[0]
                self.assertIn(delegate, body)
                self.assertNotIn("return null", body)

    def test_configure_module_keeps_source_mutation_callback_and_deselect_gate_separate(self):
        module = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingConfigureState.gd").read_text(encoding="utf-8")
        bridge = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingConfigurePortBridge.gd").read_text(encoding="utf-8")
        for function in ("configure_state", "configure_any_state", "deselect_state", "config_tapped_state"):
            self.assertIn(f"static func {function}", module)
            expected = "source_building_configure_local_state" if function == "configure_state" else f"source_building_{function}"
            self.assertIn(f"func {expected}", bridge)
        self.assertIn('updated_block_state["lastConfig"] = value', module)
        self.assertIn("tile_config_callback.call(player_state, self_state, value)", module)
        self.assertIn("tile_config_callback.call(null, self_state, value)", module)
        self.assertIn("not headless and selected_building == self_state", module)
        self.assertIn("hide_config_callback.call()", module)
        self.assertIn("return true", module)

    def test_configure_entry_source_text_and_parity_are_source_backed(self):
        from mindustry_port import source_parity

        source_text = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingSourceTextState.gd").read_text(encoding="utf-8")
        expected = (
            "SOURCE_BUILDING_CONFIGURE_LOCAL_JAVA_METHOD",
            "SOURCE_BUILDING_CONFIGURE_ANY_JAVA_METHOD",
            "SOURCE_BUILDING_DESELECT_JAVA_METHOD",
            "SOURCE_BUILDING_CONFIG_TAPPED_JAVA_METHOD",
        )
        for token in expected:
            self.assertIn(token, source_text)
        self.assertTrue(hasattr(source_parity, "verify_building_configure_entry_source"))
        self.assertEqual(source_parity.verify_building_configure_entry_source(ROOT / "mindustry-upstream")["missing"], [])

    def test_configure_entry_slices_share_configure_module_and_have_registered_contracts(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        entries = (
            ("N1917", "building_configure_local", "PortGame.source_building_configure_local_state"),
            ("N1918", "building_configure_any", "PortGame.source_building_configure_any_state"),
            ("N1919", "building_deselect", "PortGame.source_building_deselect_state"),
            ("N1920", "building_config_tapped", "PortGame.source_building_config_tapped_state"),
        )
        for slice_id, prefix, owner in entries:
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["status"], "done")
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(registry[prefix + ".method"]["godot_owner"], owner)
                self.assertEqual(contracts[owner]["source_slice"], slice_id)


if __name__ == "__main__":
    unittest.main()
