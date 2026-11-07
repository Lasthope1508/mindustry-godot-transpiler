import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_symbols


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / "godot-mindustry"


class PowerNodePresentationSliceTests(unittest.TestCase):
    def test_power_node_presentation_matches_upstream_source(self):
        source = (ROOT / "mindustry-upstream" / "core/src/mindustry/world/blocks/power/PowerNode.java").read_text(encoding="utf-8")
        for expression in (
            "protected void setupColor(float satisfaction){",
            "Draw.color(Tmp.c1.set(laserColor1).lerp(laserColor2, (1f - satisfaction) * 0.86f + Mathf.absin(3f, 0.1f)).a(Renderer.laserOpacity * Lod.alpha2));",
            "public void drawLaser(float x1, float y1, float x2, float y2, int size1, int size2){",
            "drawLaser(x1, y1, x2, y2, size1, size2, true);",
            "public void drawLaser(float x1, float y1, float x2, float y2, int size1, int size2, boolean light){",
            "float angle1 = Angles.angle(x1, y1, x2, y2),",
            "vx = Mathf.cosDeg(angle1), vy = Mathf.sinDeg(angle1),",
            "len1 = size1 * tilesize / 2f - 1.5f, len2 = size2 * tilesize / 2f - 1.5f;",
            "Drawf.laser(laser, laserEnd, laserEnd, x1 + vx*len1, y1 + vy*len1, x2 - vx*len2, y2 - vy*len2, laserScale, light);",
        ):
            self.assertIn(expression, source)
        generated = (GODOT / "src/generated/classes/mindustry/world/blocks/power/PowerNode.gd").read_text(encoding="utf-8")
        self.assertIn("setup_color_state", generated)
        self.assertIn("draw_laser_state", generated)
        contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
        schemas = source_symbols.load_source_state_schema(GODOT)["schemas"]
        for owner, schema_name in (
            ("PortGame.source_power_node_setup_color_state", "source_power_node_setup_color_result"),
            ("PortGame.source_power_node_draw_laser_state", "source_power_node_draw_laser_result"),
        ):
            self.assertFalse(set(contracts[owner]["return_keys"]) - set(schemas[schema_name]["keys"]))
        self.assertEqual(source_symbols.validate_source_catalog(GODOT)["errors"], [])


if __name__ == "__main__":
    unittest.main()
