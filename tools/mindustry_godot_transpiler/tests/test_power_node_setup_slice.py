import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from mindustry_port import source_parity, source_symbols


ROOT = Path(__file__).resolve().parents[3]
GODOT = ROOT / "godot-mindustry"


class PowerNodeSetupSliceTests(unittest.TestCase):
    def test_power_node_setup_matches_upstream_source(self):
        upstream = ROOT / "mindustry-upstream"
        for verify in (
            source_parity.verify_power_node_set_stats_source,
            source_parity.verify_power_node_init_source,
            source_parity.verify_power_node_plan_config_clip_size_source,
        ):
            self.assertEqual(verify(upstream)["missing"], [])
        generated = (GODOT / "src/generated/classes/mindustry/world/blocks/power/PowerNode.gd").read_text(encoding="utf-8")
        for call in (
            "source_power_node_state.set_stats_state(laser_range, max_nodes, super_set_stats_state)",
            "source_power_node_state.init_state(clip_size, laser_range, tilesize, super_init_state)",
            "source_power_node_state.plan_config_clip_size_state(laser_range, tilesize, size)",
        ):
            self.assertIn(call, generated)
        contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
        schemas = source_symbols.load_source_state_schema(GODOT)["schemas"]
        for name in ("set_stats", "init", "plan_config_clip_size"):
            owner = "PortGame.source_power_node_" + name + "_state"
            self.assertFalse(set(contracts[owner]["return_keys"]) - set(schemas["source_power_node_" + name + "_result"]["keys"]))
        self.assertEqual(source_symbols.validate_source_catalog(GODOT)["errors"], [])


if __name__ == "__main__":
    unittest.main()
