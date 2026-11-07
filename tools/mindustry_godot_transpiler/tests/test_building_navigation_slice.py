import json
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))


class BuildingNavigationSliceTests(unittest.TestCase):
    def test_generated_building_navigation_methods_delegate_to_one_canonical_module(self):
        generated = (ROOT / "godot-mindustry" / "src" / "generated" / "classes" / "mindustry" / "entities" / "comp" / "BuildingComp.gd").read_text(encoding="utf-8")
        expected = {
            "java_method_nearby_33": "source_building_navigation_state.nearby_delta_state",
            "java_method_nearby_34": "source_building_navigation_state.nearby_rotation_state",
            "java_method_relativeTo_35": "source_building_navigation_state.relative_to_tile_state",
            "java_method_relativeTo_36": "source_building_navigation_state.relative_to_building_state",
            "java_method_relativeToEdge_37": "source_building_navigation_state.relative_to_edge_state",
            "java_method_relativeTo_38": "source_building_navigation_state.relative_to_coordinates_state",
            "java_method_front_39": "source_building_navigation_state.front_state",
            "java_method_back_40": "source_building_navigation_state.back_state",
            "java_method_left_41": "source_building_navigation_state.left_state",
            "java_method_right_42": "source_building_navigation_state.right_state",
            "java_method_findClosestEdge_17": "source_building_navigation_state.find_closest_edge_state",
            "java_method_eachEdge_32": "source_building_navigation_state.each_edge_state",
        }
        for method, delegate in expected.items():
            with self.subTest(method=method):
                body = generated.split(f"func {method}", 1)[1].split("\nfunc ", 1)[0]
                self.assertIn(delegate, body)
                self.assertNotIn("return null", body)

    def test_navigation_module_reuses_canonical_tile_geometry_without_tile_lookup_substitution(self):
        module = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingNavigationState.gd").read_text(encoding="utf-8")
        self.assertIn("source_block_geometry.tile_absolute_relative_state", module)
        self.assertIn("source_block_geometry.tile_relative_float_state", module)
        self.assertIn("world_build_lookup", module)
        self.assertIn("source_block_plan_geometry_state.edge_points_state", module)
        self.assertIn("world_tile_lookup", module)

    def test_navigation_source_text_is_backed_by_building_tile_and_edges_sources(self):
        source_text = (ROOT / "godot-mindustry" / "src" / "game" / "SourceBuildingNavigationSourceTextState.gd").read_text(encoding="utf-8")
        building = (ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "entities" / "comp" / "BuildingComp.java").read_text(encoding="utf-8")
        tile = (ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "world" / "Tile.java").read_text(encoding="utf-8")
        edges = (ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "world" / "Edges.java").read_text(encoding="utf-8")
        expressions = (
            "public Building nearby(int dx, int dy){",
            "return world.build(tile.x + dx, tile.y + dy);",
            "public Building nearby(int rotation){",
            "public byte relativeTo(Building build){",
            "public byte relativeToEdge(Tile other){",
            "return relativeTo(Edges.getFacingEdge(other, tile));",
            "public byte relativeTo(int cx, int cy){",
            "return tile.absoluteRelativeTo(cx, cy);",
            "public @Nullable Building front(){",
            "public @Nullable Building back(){",
            "public @Nullable Building left(){",
            "public @Nullable Building right(){",
            "public @Nullable Tile findClosestEdge(Position to, Boolf<Tile> solid){",
            "if(to == null) return null;",
            "for(var point : Edges.getEdges(block.size)){",
            "Tile other = Vars.world.tile(tile.x + point.x, tile.y + point.y);",
            "if(other != null && !solid.get(other) && (best == null || to.dst2(other) < mindst)){",
        )
        for expression in expressions:
            self.assertIn(expression, building)
            self.assertIn(expression, source_text)
        for expression in ("public void eachEdge(Cons<Tile> cons){", "for(var edge : block.getEdges()){"):
            self.assertIn(expression, building)
            self.assertIn(expression, source_text)
        for expression in ("public byte absoluteRelativeTo(int cx, int cy){", "public static Tile getFacingEdge(Tile tile, Tile other){", "if(!block.isMultiblock()) return world.tile(tilex, tiley);", "public static Point2[] getEdges(int size){"):
            self.assertIn(expression, tile if "absoluteRelative" in expression else edges)
            self.assertIn(expression, source_text)

    def test_navigation_slice_registry_uses_a_unique_canonical_owner(self):
        generated = ROOT / "godot-mindustry" / "src" / "generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        contracts = json.loads((generated / "source_api_contracts.json").read_text(encoding="utf-8"))["contracts"]
        owner = "PortGame.source_building_navigation_state"
        for slice_id, prefix in (("N1903", "building_nearby_delta"), ("N1904", "building_nearby_rotation"), ("N1905", "building_relative_to_tile"), ("N1906", "building_relative_to_building"), ("N1907", "building_relative_to_edge"), ("N1908", "building_relative_to_coordinates"), ("N1909", "building_navigation_front_back"), ("N1910", "building_navigation_left_right"), ("N1916", "building_find_closest_edge"), ("N1950", "building_each_edge")):
            with self.subTest(slice_id=slice_id):
                self.assertEqual(ledger[slice_id]["status"], "done")
                self.assertEqual(ledger[slice_id]["godot_owner"], owner)
                self.assertEqual(registry[prefix + ".method"]["godot_owner"], owner)
        self.assertEqual(contracts[owner]["source_slice"], "N1903")

    def test_navigation_runtime_proof_covers_rotation_offsets_facing_edge_and_generated_bridges(self):
        proof = (ROOT / "godot-mindustry" / "tools" / "runtime_proofs" / "BuildingNavigationStateModuleProof.gd").read_text(encoding="utf-8")
        for token in ("nearby_rotation", "relative_to_edge", "front_back", "left_right", "find_closest_edge", "each_edge", "generated_nearby", "generated_relative", "one_headquarter_per_ssot"):
            self.assertIn(token, proof)



if __name__ == "__main__":
    unittest.main()
