import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_symbols


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / "godot-mindustry"


class PowerNodePlacementSliceTests(unittest.TestCase):
    def test_power_node_placement_matches_upstream_source(self):
        source = (ROOT / "mindustry-upstream" / "core/src/mindustry/world/blocks/power/PowerNode.java").read_text(encoding="utf-8")
        for expression in (
            "public void drawPlace(int x, int y, int rotation, boolean valid){",
            "Tile tile = world.tile(x, y);",
            "if(tile == null || !autolink) return;",
            "getPotentialLinks(tile, player.team(), other -> {",
            "drawLaser(x * tilesize + offset, y * tilesize + offset, other.x, other.y, size, other.block.size);",
            "public void changePlacementPath(Seq<Point2> points, int rotation){",
            "Placement.calculateNodes(points, this, rotation, (point, other) -> overlaps(world.tile(point.x, point.y), world.tile(other.x, other.y)));",
            "protected void getPotentialLinks(Tile tile, Team team, Cons<Building> others){",
            "public static void getNodeLinks(Tile tile, Block block, Team team, Cons<Building> others){",
            "public void drawPlanConfigTop(BuildPlan plan, Eachable<BuildPlan> list){",
            "var otherReq = findPlan(list, currentFindX, currentFindY, planFinder);",
            "drawLaser(plan.drawx(), plan.drawy(), otherReq.drawx(), otherReq.drawy(), size, otherReq.block.size, false);",
            "public static Func<Building, Bar> makePowerBalance(){",
            "public static Func<Building, Bar> makeBatteryBalance(){",
            "public void setBars(){",
            'addBar("connections", entity -> new Bar(() ->',
        ):
            self.assertIn(expression, source)
        generated = (GODOT / "src/generated/classes/mindustry/world/blocks/power/PowerNode.gd").read_text(encoding="utf-8")
        self.assertIn("source_power_node_state.draw_place_state(x, y, rotation, valid, draw_input)", generated)
        self.assertIn("source_power_node_state.change_placement_path_state(points, rotation, placement_result)", generated)
        self.assertIn("source_power_node_state.get_potential_links_state(link_input)", generated)
        self.assertIn("source_power_node_state.get_node_links_state(link_input)", generated)
        self.assertIn("source_power_node_state.draw_plan_config_top_state(plan_input)", generated)
        self.assertIn("source_power_node_state.make_power_balance_state(graph_input)", generated)
        self.assertIn("source_power_node_state.make_battery_balance_state(graph_input)", generated)
        self.assertIn("source_power_node_state.set_bars_state(bars_input)", generated)
        contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
        schemas = source_symbols.load_source_state_schema(GODOT)["schemas"]
        for owner, schema_name in (
            ("PortGame.source_power_node_draw_place_state", "source_power_node_draw_place_result"),
            ("PortGame.source_power_node_change_placement_path_state", "source_power_node_change_placement_path_result"),
            ("PortGame.source_power_node_get_potential_links_state", "source_power_node_get_potential_links_result"),
            ("PortGame.source_power_node_get_node_links_state", "source_power_node_get_node_links_result"),
            ("PortGame.source_power_node_draw_plan_config_top_state", "source_power_node_draw_plan_config_top_result"),
            ("PortGame.source_power_node_make_power_balance_state", "source_power_node_make_power_balance_result"),
            ("PortGame.source_power_node_make_battery_balance_state", "source_power_node_make_battery_balance_result"),
            ("PortGame.source_power_node_set_bars_state", "source_power_node_set_bars_result"),
        ):
            self.assertFalse(set(contracts[owner]["return_keys"]) - set(schemas[schema_name]["keys"]))
        self.assertEqual(source_symbols.validate_source_catalog(GODOT)["errors"], [])


if __name__ == "__main__":
    unittest.main()
