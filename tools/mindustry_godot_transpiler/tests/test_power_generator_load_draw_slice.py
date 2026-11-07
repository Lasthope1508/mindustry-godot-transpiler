import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))
from mindustry_port import source_parity, source_symbols


class PowerGeneratorLoadDrawSliceTests(unittest.TestCase):
    def test_power_generator_load_and_draw_plan_region_match_upstream_source(self):
        upstream = (ROOT / "mindustry-upstream/core/src/mindustry/world/blocks/power/PowerGenerator.java").read_text(encoding="utf-8")
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/world/blocks/power/PowerGenerator.gd").read_text(encoding="utf-8")
        state = (ROOT / "godot-mindustry/src/game/SourcePowerGeneratorState.gd").read_text(encoding="utf-8")
        for expr in ("public void load(){", "super.load();", "drawer.load(this);", "public void drawPlanRegion(BuildPlan plan, Eachable<BuildPlan> list){", "drawer.drawPlan(this, plan, list);"):
            self.assertIn(expr, upstream)
        self.assertIn("return source_power_generator_state.load_state(super_load_state, drawer_load_state)", generated)
        self.assertIn("return source_power_generator_state.draw_plan_region_state(plan, list, drawer_draw_plan_state)", generated)
        self.assertIn("static func load_state(super_load_state: Dictionary, drawer_load_state: Dictionary)", state)
        self.assertIn("static func draw_plan_region_state(plan: Variant, list: Variant, drawer_draw_plan_state: Dictionary)", state)
        self.assertEqual(source_parity.verify_power_generator_load_source(ROOT / "mindustry-upstream")["missing"], [])
        self.assertEqual(source_parity.verify_power_generator_draw_plan_region_source(ROOT / "mindustry-upstream")["missing"], [])
        self.assertEqual(source_symbols.validate_source_catalog(ROOT / "godot-mindustry")["errors"], [])


if __name__ == "__main__":
    unittest.main()
