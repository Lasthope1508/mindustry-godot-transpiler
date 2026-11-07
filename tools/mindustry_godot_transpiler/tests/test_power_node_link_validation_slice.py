import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_symbols


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / "godot-mindustry"


class PowerNodeLinkValidationSliceTests(unittest.TestCase):
    def test_power_node_link_validation_matches_upstream_source(self):
        source = (ROOT / "mindustry-upstream" / "core/src/mindustry/world/blocks/power/PowerNode.java").read_text(encoding="utf-8")
        for expression in (
            "public boolean linkValid(Building tile, Building link){",
            "public boolean linkValid(Building tile, Building link, boolean checkMaxNodes){",
            "if(tile == link || link == null || !link.block.hasPower || !link.block.connectedPower || tile.team != link.team || (sameBlockConnection && tile.block != link.block)) return false;",
            "if(overlaps(tile, link, laserRange * tilesize) || (link.block instanceof PowerNode node && overlaps(link, tile, node.laserRange * tilesize))){",
            "if(checkMaxNodes && link.block instanceof PowerNode node){",
            "return link.power.links.size < node.maxNodes || link.power.links.contains(tile.pos());",
            "public static boolean insulated(Tile tile, Tile other){",
            "public static boolean insulated(Building tile, Building other){",
            "public static boolean insulated(int x, int y, int x2, int y2){",
            "return World.raycast(x, y, x2, y2, (wx, wy) -> {",
        ):
            self.assertIn(expression, source)
        generated = (GODOT / "src/generated/classes/mindustry/world/blocks/power/PowerNode.gd").read_text(encoding="utf-8")
        self.assertIn("return source_power_node_state.link_valid_state(link_state, check_max_nodes)", generated)
        self.assertIn("return source_power_node_state.insulated_state(raycast_insulated)", generated)
        contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
        schemas = source_symbols.load_source_state_schema(GODOT)["schemas"]
        for owner, schema_name in (
            ("PortGame.source_power_node_link_valid_state", "source_power_node_link_valid_result"),
            ("PortGame.source_power_node_insulated_state", "source_power_node_insulated_result"),
        ):
            self.assertFalse(set(contracts[owner]["return_keys"]) - set(schemas[schema_name]["keys"]))
        self.assertEqual(source_symbols.validate_source_catalog(GODOT)["errors"], [])


if __name__ == "__main__":
    unittest.main()
