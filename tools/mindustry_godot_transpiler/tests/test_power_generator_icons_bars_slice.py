import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_parity, source_symbols


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / "godot-mindustry"


class PowerGeneratorIconsBarsSliceTests(unittest.TestCase):
    def test_power_generator_icons_and_set_bars_match_upstream_source(self):
        upstream = (ROOT / "mindustry-upstream/core/src/mindustry/world/blocks/power/PowerGenerator.java").read_text(encoding="utf-8")
        generated = (GODOT / "src/generated/classes/mindustry/world/blocks/power/PowerGenerator.gd").read_text(encoding="utf-8")
        state = (GODOT / "src/game/SourcePowerGeneratorState.gd").read_text(encoding="utf-8")
        for expr in (
            "public TextureRegion[] icons(){",
            "return drawer.finalIcons(this);",
            "public void setBars(){",
            "super.setBars();",
            "if(hasPower && outputsPower){",
            'addBar("power", (GeneratorBuild entity) -> new Bar(() ->',
            'Core.bundle.format("bar.poweroutput",',
            "Strings.fixed(entity.getPowerProduction() * 60 * entity.timeScale(), 1)",
            "() -> Pal.powerBar,",
            "() -> entity.productionEfficiency));",
        ):
            self.assertIn(expr, upstream)
        self.assertIn("return source_power_generator_state.icons_state(drawer_icons)", generated)
        self.assertIn("return source_power_generator_state.set_bars_state(has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency)", generated)
        self.assertIn("static func icons_state(drawer_icons: Array) -> Dictionary:", state)
        self.assertIn("static func set_bars_state(has_power: bool", state)
        self.assertEqual(source_parity.verify_power_generator_icons_source(ROOT / "mindustry-upstream")["missing"], [])
        self.assertEqual(source_parity.verify_power_generator_set_bars_source(ROOT / "mindustry-upstream")["missing"], [])
        contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
        schemas = source_symbols.load_source_state_schema(GODOT)["schemas"]
        expected_schemas = {
            "PortGame.source_power_generator_icons_state": "source_power_generator_icons_result",
            "PortGame.source_power_generator_set_bars_state": "source_power_generator_set_bars_result",
        }
        for owner, schema_name in expected_schemas.items():
            self.assertEqual(set(contracts[owner]["return_keys"]) - set(schemas[schema_name]["keys"]), set())
        self.assertEqual(source_symbols.validate_source_catalog(GODOT)["errors"], [])


if __name__ == "__main__":
    unittest.main()
