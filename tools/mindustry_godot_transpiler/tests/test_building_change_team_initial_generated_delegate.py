import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingChangeTeamInitialGeneratedDelegateTests(unittest.TestCase):
    def test_change_team_initial_state_is_canonical_before_power_branches(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_changeTeam_181", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("var initial_state = source_building_lifecycle_state.change_team_initial_state(current_team, next_team, force_team, was_valid)", body)
        self.assertIn("if bool(initial_state.get(\"returned\", false)):", body)
        self.assertIn("var result = initial_state", body)
        self.assertNotIn("if current_team == next_team:", body)
        self.assertNotIn("var team_after_force = force_team if force_team != null else current_team", body)


if __name__ == "__main__":
    unittest.main()
