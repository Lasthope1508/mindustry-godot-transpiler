import tempfile
import unittest
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class BuildingItemDumpRuntimeSliceTests(unittest.TestCase):
    def test_emitter_delegates_building_dump_overloads_to_canonical_module(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void offload(Item item){}
    public boolean put(Item item){ return false; }
    public void produced(Item item){ produced(item, 1); }
    public void produced(Item item, int amount){}
    public boolean dumpAccumulate(){ return dumpAccumulate(null); }
    public boolean dumpAccumulate(Item item){ return false; }
    public boolean dump(){ return dump(null); }
    public boolean dump(Item todump){ return false; }
    public void incrementDump(int prox){ cdump = ((cdump + 1) % prox); }
    public boolean canDump(Building to, Item item){ return true; }
}
""",
                encoding="utf-8",
            )
            output = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(root / "core" / "src", output)
            emitted = (output / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")

        self.assertIn('const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")', emitted)
        self.assertIn("source_building_item_dump_state.dump_item_state", emitted)
        self.assertIn("source_building_item_dump_state.dump_accumulate_generated_state", emitted)
        self.assertIn("source_building_item_dump_state.produced_item_default_state", emitted)
        self.assertIn("source_building_item_dump_state.produced_item_amount_state", emitted)
        self.assertIn("source_building_item_dump_state.generated_put_item_state", emitted)
        self.assertIn("source_drill_inventory_runtime_state.offload_to_inventory_state", emitted)
        self.assertIn('const source_drill_inventory_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")', emitted)
        self.assertIn("source_building_item_dump_state.increment_dump_cursor_state", emitted)
        self.assertIn("source_building_item_dump_state.can_dump_item_default_state", emitted)
        self.assertIn("source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ITEM_DUMP_STATE", emitted)

    def test_source_module_contains_complete_building_dump_contract(self):
        module = ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingItemDumpState.gd"
        source = module.read_text(encoding="utf-8")
        for expression in (
            'const source_building_item_dump_source_text_state := preload("res://src/game/SourceBuildingItemDumpSourceTextState.gd")',
            "const SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD",
            "const SOURCE_BUILDING_ITEM_DUMP_HANDLE_ITEM_CALL := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_HANDLE_ITEM_CALL",
            "const SOURCE_BUILDING_ITEM_DUMP_REMOVE_ITEM_CALL := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_REMOVE_ITEM_CALL",
            "static func dump_item_state(",
            "static func dump_accumulate_generated_state(",
            "static func produced_item_default_state(",
            "static func produced_item_amount_state(",
            "static func generated_put_item_state(",
            '"dumped": dumped',
            "var guard_failed :=",
            "next_cursor = increment_dump_cursor_state(next_cursor, proximity_size)",
            '"item_amounts_by_index": next_item_amounts',
            '"handle_item_called": true',
            '"remove_item_called": true',
        ):
            self.assertIn(expression, source)

        source_text = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingItemDumpSourceTextState.gd").read_text(encoding="utf-8")
        for expression in (
            'const SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD := "if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;"',
            'const SOURCE_BUILDING_ITEM_DUMP_HANDLE_ITEM_CALL := "other.handleItem(self(), item);"',
            'const SOURCE_BUILDING_ITEM_DUMP_REMOVE_ITEM_CALL := "items.remove(item, 1);"',
        ):
            self.assertIn(expression, source_text)

    def test_runtime_proof_scene_is_registered_for_generated_dump_bridge(self):
        proof = ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "BuildingItemDumpStateModuleProof.gd"
        source = proof.read_text(encoding="utf-8")
        self.assertIn('preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")', source)
        self.assertIn("generated_comp.java_method_dump_109", source)
        self.assertIn('"generated_owner_matches"', source)


if __name__ == "__main__":
    unittest.main()
