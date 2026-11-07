import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_parity, source_symbols


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / "godot-mindustry"


class PowerGeneratorOutputsItemsSliceTests(unittest.TestCase):
    def test_power_generator_outputs_items_matches_upstream_source(self):
        upstream = (ROOT / "mindustry-upstream" / "core/src/mindustry/world/blocks/power/PowerGenerator.java").read_text(encoding="utf-8")
        generated = (GODOT / "src/generated/classes/mindustry/world/blocks/power/PowerGenerator.gd").read_text(encoding="utf-8")
        state = (GODOT / "src/game/SourcePowerGeneratorState.gd").read_text(encoding="utf-8")
        self.assertIn("public boolean outputsItems(){", upstream)
        self.assertIn("return false;", upstream)
        self.assertIn("return source_power_generator_state.outputs_items_state()", generated)
        self.assertIn("static func outputs_items_state() -> Dictionary:", state)
        self.assertIn('"outputs_items": false', state)

        parity = source_parity.verify_power_generator_outputs_items_source(ROOT / "mindustry-upstream")
        self.assertEqual(parity["missing"], [])

        contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
        schemas = source_symbols.load_source_state_schema(GODOT)["schemas"]
        owner = "PortGame.source_power_generator_outputs_items_state"
        self.assertEqual(set(contracts[owner]["return_keys"]) - set(schemas["source_power_generator_outputs_items_result"]["keys"]), set())


if __name__ == "__main__":
    unittest.main()
