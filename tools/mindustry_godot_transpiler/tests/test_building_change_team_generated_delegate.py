import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingChangeTeamGeneratedDelegateTests(unittest.TestCase):
    def test_generated_change_team_delegate_uses_canonical_lifecycle_state(self):
        source = GENERATED.read_text(encoding="utf-8")
        body = source.split("func java_method_changeTeam_180", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_lifecycle_state.change_team_delegate_state(next_team)", body)
        self.assertNotIn('return {"source_owner":', body)


if __name__ == "__main__":
    unittest.main()
