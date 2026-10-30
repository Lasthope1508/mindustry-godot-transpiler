import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingUpdateConsumptionGeneratedDelegateTests(unittest.TestCase):
    def _body(self) -> str:
        source = GENERATED.read_text(encoding="utf-8")
        return source.split("func java_method_updateConsumption_194", 1)[1].split("\nfunc ", 1)[0]

    def test_initial_and_disabled_branches_use_canonical_state(self):
        body = self._body()
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_initial_state(has_consumers, cheating, enabled_state, production_valid, should_consume_state, efficiency_scale)",
            body,
        )
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_disabled_state(enabled_state)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_initial_state"', body)
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_disabled_state"', body)

    def test_setup_branch_uses_canonical_state(self):
        body = self._body()
        self.assertIn("if _args.size() <= 6:", body)
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_setup_state(should_consume_state, production_valid)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_setup_state"', body)

    def test_non_optional_branch_uses_canonical_state(self):
        body = self._body()
        self.assertIn("if _args.size() <= 7:", body)
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_non_optional_pass_state(non_optional_consumer_results)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_non_optional_pass_state"', body)

    def test_optional_branch_uses_canonical_state(self):
        body = self._body()
        self.assertIn("if _args.size() <= 8:", body)
        self.assertIn(
            "return source_building_efficiency_state.update_consumption_optional_pass_state(optional_consumer_results)",
            body,
        )
        self.assertNotIn('"source_owner": "port_game.source_building_update_consumption_optional_pass_state"', body)


if __name__ == "__main__":
    unittest.main()
