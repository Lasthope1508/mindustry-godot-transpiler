import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"
SOURCE = ROOT / "mindustry-upstream" / "core/src/mindustry/entities/comp/BuildingComp.java"


class BuildingUpdateAccessSliceTests(unittest.TestCase):
    def test_upstream_and_source_text_keep_exact_method_boundaries(self):
        upstream = SOURCE.read_text(encoding="utf-8")
        source_text = (PROJECT / "src/game/SourceBuildingSourceTextState.gd").read_text(encoding="utf-8")
        for expression in (
            "public boolean allowUpdate(){",
            "return team != Team.derelict && block.supportsEnv(state.rules.env) &&",
            "Rect.contains(state.rules.limitX, state.rules.limitY, state.rules.limitWidth, state.rules.limitHeight, tile.x, tile.y)",
            "public boolean inMapArea(){",
            "return !state.rules.limitMapArea || Rect.contains(state.rules.limitX * tilesize, state.rules.limitY * tilesize, state.rules.limitWidth * tilesize, state.rules.limitHeight * tilesize, x, y);",
        ):
            self.assertIn(expression, upstream)
            self.assertIn(expression, source_text)

    def test_generated_methods_delegate_to_canonical_access_module(self):
        generated = (PROJECT / "src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        self.assertIn("func java_method_allowUpdate_53(_args: Array = []) -> Variant:", generated)
        self.assertIn("return source_building_access_state.allow_update_state", generated)
        self.assertIn("func java_method_inMapArea_54(_args: Array = []) -> Variant:", generated)
        self.assertIn("return source_building_access_state.in_map_area_state", generated)

    def test_registry_and_ledger_are_canonical(self):
        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))["symbols"]
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))["slices"]
        for slice_id, prefix, method in (("N1886", "building_allow_update", "allowUpdate()"), ("N1887", "building_in_map_area", "inMapArea()")):
            self.assertEqual(ledger[slice_id]["status"], "done")
            self.assertEqual(ledger[slice_id]["java_method"], method)
            self.assertIn(prefix + ".method", registry)
            self.assertEqual(registry[prefix + ".method"]["status"], "source-backed")

    def test_module_exposes_explicit_dependencies(self):
        module = (PROJECT / "src/game/SourceBuildingAccessState.gd").read_text(encoding="utf-8")
        self.assertIn("static func allow_update_state(team_is_derelict: bool", module)
        self.assertIn("static func in_map_area_state(limit_map_area: bool", module)
        self.assertIn("source_block_geometry.tile_in_map_area_state", module)


if __name__ == "__main__":
    unittest.main()
