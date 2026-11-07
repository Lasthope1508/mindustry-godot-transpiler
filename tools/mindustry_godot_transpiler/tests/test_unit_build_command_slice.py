import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class UnitBuildCommandSliceTests(unittest.TestCase):
    def test_shared_command_state_owns_all_three_source_classes(self):
        source_text = (PROJECT / "src" / "game" / "SourceUnitBuildingCommandSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src" / "game" / "SourceUnitBuildingCommandState.gd").read_text(encoding="utf-8")
        registry = (PROJECT / "src" / "game" / "SourceRuntimeOwnerUnitBuildingRegistry.gd").read_text(encoding="utf-8")
        for class_name in ["UnitFactory", "UnitAssembler", "Reconstructor"]:
            self.assertIn(f'"{class_name}"', source_text)
        self.assertIn("source_text.SOURCE_UNIT_BUILDING_INNER_CLASS_DECLARATIONS", state)
        self.assertIn("commandPos", source_text)
        self.assertIn("PORT_GAME_SOURCE_UNIT_BUILDING_GET_COMMAND_POSITION_STATE", registry)
        self.assertIn("PORT_GAME_SOURCE_UNIT_BUILDING_ON_COMMAND_STATE", registry)

    def test_source_text_variants_match_all_upstream_declarations(self):
        source_text = (PROJECT / "src" / "game" / "SourceUnitBuildingCommandSourceTextState.gd").read_text(encoding="utf-8")
        upstream_files = {
            "UnitFactory": ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "units" / "UnitFactory.java",
            "UnitAssembler": ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "units" / "UnitAssembler.java",
            "Reconstructor": ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "world" / "blocks" / "units" / "Reconstructor.java",
        }
        for class_name, path in upstream_files.items():
            with self.subTest(class_name=class_name):
                upstream = path.read_text(encoding="utf-8")
                self.assertIn("public Vec2 getCommandPosition(){", upstream)
                self.assertIn("public void onCommand(Vec2 target){", upstream)
                self.assertIn("return commandPos;", upstream)
                self.assertIn("commandPos = target;", upstream)
                self.assertIn(class_name, source_text)

    def test_canonical_ssot_covers_both_owners_without_duplicate_owner_names(self):
        import json

        generated = PROJECT / "src" / "generated"
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((generated / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]
        symbols = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        owners = [
            "PortGame.source_unit_building_get_command_position_state",
            "PortGame.source_unit_building_on_command_state",
        ]
        owner_entries = [entry for entry in ledger.values() if entry.get("godot_owner") in owners]
        self.assertEqual({entry["godot_owner"] for entry in owner_entries}, set(owners))
        self.assertEqual(set(owners), set(contracts) & set(owners))
        self.assertEqual(len([name for name, entry in symbols.items() if entry.get("godot_owner") in owners]), len(set(name for name, entry in symbols.items() if entry.get("godot_owner") in owners)))
        for owner in owners:
            schema_prefix = owner.removeprefix("PortGame.")
            self.assertIn(schema_prefix + "_input", schemas)
            self.assertIn(schema_prefix + "_result", schemas)

    def test_facade_delegates_command_state_without_duplicating_behavior(self):
        facade = (PROJECT / "src" / "game" / "SourceUnitBuildingCommandPortBridge.gd").read_text(encoding="utf-8") if (PROJECT / "src" / "game" / "SourceUnitBuildingCommandPortBridge.gd").exists() else (PROJECT / "src" / "game" / "SourcePortGameFacadePortBridge.gd").read_text(encoding="utf-8")
        self.assertIn("source_unit_building_command_state", facade)
        self.assertIn("generated_unit_building_get_command_position_bridge_state", facade)
        self.assertIn("generated_unit_building_on_command_bridge_state", facade)


if __name__ == "__main__":
    unittest.main()
