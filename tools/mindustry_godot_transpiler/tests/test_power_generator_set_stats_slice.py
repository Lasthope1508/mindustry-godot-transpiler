import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))
from mindustry_port import source_parity, source_symbols


class PowerGeneratorSetStatsSliceTests(unittest.TestCase):
    def test_power_generator_set_stats_matches_upstream_source(self):
        upstream = (ROOT / "mindustry-upstream/core/src/mindustry/world/blocks/power/PowerGenerator.java").read_text(encoding="utf-8")
        generated = (ROOT / "godot-mindustry/src/generated/classes/mindustry/world/blocks/power/PowerGenerator.gd").read_text(encoding="utf-8")
        state = (ROOT / "godot-mindustry/src/game/SourcePowerGeneratorState.gd").read_text(encoding="utf-8")
        self.assertIn("public void setStats(){", upstream)
        self.assertIn("super.setStats();", upstream)
        self.assertIn("stats.add(generationType, powerProduction * 60.0f, StatUnit.powerSecond);", upstream)
        self.assertIn("return source_power_generator_state.set_stats_state(power_production, super_set_stats_state)", generated)
        self.assertIn("static func set_stats_state(power_production: float, super_set_stats_state: Dictionary)", state)
        self.assertIn("power_production * source_time_defaults.TICK_RATE", state)
        parity = source_parity.verify_power_generator_set_stats_source(ROOT / "mindustry-upstream")
        self.assertEqual(parity["missing"], [])
        report = source_symbols.validate_source_catalog(ROOT / "godot-mindustry")
        self.assertEqual(report["errors"], [])


if __name__ == "__main__":
    unittest.main()
