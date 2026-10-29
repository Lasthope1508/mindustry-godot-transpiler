import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingChangeTeamPowerLinksFinalGeneratedDelegateTests(unittest.TestCase):
    def _body(self):
        source = GENERATED.read_text(encoding="utf-8")
        return source.split("func java_method_changeTeam_181", 1)[1].split("\nfunc ", 1)[0]

    def test_change_team_power_links_uses_canonical_state(self):
        body = self._body()
        self.assertIn("var power_links = source_building_lifecycle_state.change_team_power_links_state(link_count if power_present and update_power else 0, next_team, old_graph)", body)
        self.assertIn('power_links["source_owner"] = "port_game.source_building_change_team_power_links_state"', body)
        self.assertNotIn('var power_links = {"source_owner":', body)

    def test_change_team_final_uses_canonical_state(self):
        body = self._body()
        self.assertIn("var final_state = source_building_lifecycle_state.change_team_final_state(was_valid, last_team)", body)
        self.assertIn('final_state["source_owner"] = "port_game.source_building_change_team_final_state"', body)
        self.assertNotIn('var final_state = {"source_owner":', body)


if __name__ == "__main__":
    unittest.main()
