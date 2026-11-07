import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_symbols


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / "godot-mindustry"


class PowerNodeOverlapSliceTests(unittest.TestCase):
    def test_power_node_overlaps_matches_upstream_source(self):
        source = (ROOT / "mindustry-upstream" / "core/src/mindustry/world/blocks/power/PowerNode.java").read_text(encoding="utf-8")
        for expression in (
            "protected boolean overlaps(float srcx, float srcy, Tile other, Block otherBlock, float range){",
            "Intersector.overlaps(Tmp.cr1.set(srcx, srcy, range), Tmp.r1.setCentered(other.worldx() + otherBlock.offset, other.worldy() + otherBlock.offset,",
            "otherBlock.size * tilesize, otherBlock.size * tilesize))",
            "protected boolean overlaps(float srcx, float srcy, Tile other, float range){",
            "Intersector.overlaps(Tmp.cr1.set(srcx, srcy, range), other.getHitbox(Tmp.r1))",
            "protected boolean overlaps(Building src, Building other, float range){",
            "return overlaps(src.x, src.y, other.tile, range);",
            "protected boolean overlaps(Tile src, Tile other, float range){",
            "return overlaps(src.drawx(), src.drawy(), other, range);",
            "public boolean overlaps(@Nullable Tile src, @Nullable Tile other){",
            "if(src == null || other == null) return true;",
        ):
            self.assertIn(expression, source)
        generated = (GODOT / "src/generated/classes/mindustry/world/blocks/power/PowerNode.gd").read_text(encoding="utf-8")
        self.assertIn("overlaps_state", generated)
        self.assertIn("overlaps_nullable_state", generated)
        contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
        schemas = source_symbols.load_source_state_schema(GODOT)["schemas"]
        for owner, schema_name in (
            ("PortGame.source_power_node_overlaps_state", "source_power_node_overlaps_result"),
            ("PortGame.source_power_node_overlaps_nullable_state", "source_power_node_overlaps_nullable_result"),
        ):
            self.assertFalse(set(contracts[owner]["return_keys"]) - set(schemas[schema_name]["keys"]))
        self.assertEqual(source_symbols.validate_source_catalog(GODOT)["errors"], [])


if __name__ == "__main__":
    unittest.main()
