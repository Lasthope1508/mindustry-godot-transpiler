import tempfile
import unittest
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class BuildingProximityPowerSliceTests(unittest.TestCase):
    def test_power_graph_removed_has_canonical_contract_and_state_schema(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((generated / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]
        contract = contracts["PortGame.source_building_power_graph_removed_state"]
        self.assertEqual(contract["source_slice"], "N977")
        self.assertEqual(contract["source_method"], "powerGraphRemoved()")
        self.assertEqual(
            [param["name"] for param in contract["params"]],
            ["power_present", "linked_build_present_by_index", "linked_build_power_present_by_index"],
        )
        self.assertEqual(contract["runtime_proof"], "/root/Main.source_building_power_graph_removed_state")
        self.assertIn("source_building_power_graph_removed_input", schemas)
        self.assertIn("source_building_power_graph_removed_result", schemas)
        self.assertEqual(schemas["source_building_power_graph_removed_input"]["owner"], "port_game.source_building_power_graph_removed_state")
        self.assertIn("linked_remove_indices", schemas["source_building_power_graph_removed_result"]["keys"])

    def test_emitter_delegates_building_proximity_power_methods_to_canonical_state(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public void onProximityRemoved(){ if(power != null){ powerGraphRemoved(); } }
    public void onProximityAdded(){ if(power != null){ updatePowerGraph(); } }
    public void onProximityUpdate(){ noSleep(); }
    public void updatePowerGraph(){ for(Building other : getPowerConnections(tempBuilds)){ if(other.power != null){ other.power.graph.addGraph(power.graph); } } }
    public void powerGraphRemoved(){ if(power == null) return; power.graph.remove(self()); power.links.clear(); }
    public boolean conductsTo(Building other){ return !block.insulated; }
    public Seq<Building> getPowerConnections(Seq<Building> out){ out.clear(); if(power == null) return out; return out; }
}
""",
                encoding="utf-8",
            )
            output = root / "godot" / "src" / "generated" / "classes"
            emit_gdscript_classes(root / "core" / "src", output)
            emitted = (output / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")

        self.assertIn('const source_building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")', emitted)
        self.assertIn("func java_method_onProximityRemoved_0(_args: Array = []) -> Variant:", emitted)
        self.assertIn("func java_method_onProximityAdded_1(_args: Array = []) -> Variant:", emitted)
        self.assertIn("func java_method_onProximityUpdate_2(_args: Array = []) -> Variant:", emitted)
        self.assertIn("func java_method_updatePowerGraph_3(_args: Array = []) -> Variant:", emitted)
        self.assertIn("func java_method_powerGraphRemoved_4(_args: Array = []) -> Variant:", emitted)
        self.assertIn("source_building_power_state.on_proximity_removed_state", emitted)
        self.assertIn("source_building_power_state.on_proximity_added_state", emitted)
        self.assertIn("source_building_power_state.on_proximity_update_state", emitted)
        self.assertIn("source_building_power_state.update_power_graph_state", emitted)
        self.assertIn("source_building_power_state.power_graph_removed_state", emitted)
        self.assertIn("PORT_GAME_SOURCE_BUILDING_ON_PROXIMITY_REMOVED_STATE", emitted)
        self.assertIn("PORT_GAME_SOURCE_BUILDING_POWER_GRAPH_REMOVED_STATE", emitted)
        self.assertIn("source_building_power_state.conducts_to_state", emitted)
        self.assertIn("source_building_power_state.get_power_connections_state", emitted)
        self.assertIn("PORT_GAME_SOURCE_BUILDING_GET_POWER_CONNECTIONS_STATE", emitted)
        self.assertIn("func java_method_conductsTo_5(_args: Array = []) -> Variant:", emitted)
        self.assertIn("func java_method_getPowerConnections_6(_args: Array = []) -> Variant:", emitted)
        self.assertNotIn("func java_method_onProximityRemoved_0(_args: Array = []) -> Variant:\n\treturn null", emitted)
        self.assertNotIn("func java_method_powerGraphRemoved_4(_args: Array = []) -> Variant:\n\treturn null", emitted)

    def test_building_registry_owns_proximity_power_adapters(self):
        registry = ROOT / "godot-mindustry" / "src" / "game" / "SourceRuntimeOwnerBuildingRegistry.gd"
        source = registry.read_text(encoding="utf-8")
        for name in (
            "ON_PROXIMITY_REMOVED",
            "ON_PROXIMITY_ADDED",
            "ON_PROXIMITY_UPDATE",
            "UPDATE_POWER_GRAPH",
            "POWER_GRAPH_REMOVED",
        ):
            self.assertIn(f"PORT_GAME_SOURCE_BUILDING_{name}_STATE", source)

    def test_get_power_connections_has_canonical_aggregate_owner(self):
        registry = ROOT / "godot-mindustry" / "src" / "game" / "SourceRuntimeOwnerBuildingRegistry.gd"
        power_state = ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingPowerState.gd"
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry_source = registry.read_text(encoding="utf-8")
        power_source = power_state.read_text(encoding="utf-8")
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        schemas = json.loads((generated / "source_state_schema.json").read_text(encoding="utf-8"))["schemas"]
        self.assertIn("PORT_GAME_SOURCE_BUILDING_GET_POWER_CONNECTIONS_STATE", registry_source)
        self.assertIn("static func get_power_connections_state(", power_source)
        self.assertIn("get_power_connections_proximity_guard_state", power_source)
        self.assertIn("get_power_connections_power_compatibility_guard_state", power_source)
        self.assertIn("get_power_connections_conducts_link_guard_state", power_source)
        self.assertIn("get_power_connections_automatic_add_state", power_source)
        self.assertIn("get_power_connections_manual_links_loop_state", power_source)
        contract = contracts["PortGame.source_building_get_power_connections_state"]
        self.assertEqual(contract["source_slice"], "N978")
        self.assertEqual(contract["source_method"], "getPowerConnections(Seq<Building> out)")
        self.assertIn("source_building_get_power_connections_input", schemas)
        self.assertIn("source_building_get_power_connections_result", schemas)
        self.assertIn("phases", schemas["source_building_get_power_connections_result"]["keys"])


if __name__ == "__main__":
    unittest.main()
