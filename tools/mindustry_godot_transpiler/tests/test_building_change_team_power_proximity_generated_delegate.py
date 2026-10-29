import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingChangeTeamPowerProximityGeneratedDelegateTests(unittest.TestCase):
    def test_change_team_power_proximity_uses_canonical_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_changeTeam_181", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("var power_proximity = source_building_lifecycle_state.change_team_power_proximity_state(power_present, update_power, old_graph, next_team)", body)
        self.assertIn('power_proximity["source_owner"] = "port_game.source_building_change_team_power_proximity_state"', body)
        self.assertNotIn('var power_proximity = {"source_owner":', body)
        self.assertNotIn('"proximity_reflow": power_present and update_power', body)


if __name__ == "__main__":
    unittest.main()
