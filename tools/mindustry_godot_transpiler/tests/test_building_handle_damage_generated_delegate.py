import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]


class BuildingHandleDamageGeneratedDelegateTests(unittest.TestCase):
    def test_generated_handle_damage_delegates_to_canonical_state(self):
        source = (ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd").read_text(encoding="utf-8")
        body = source.split("func java_method_handleDamage_173", 1)[1].split("\nfunc ", 1)[0]
        self.assertIn("return source_building_damage_state.handle_damage_state(amount)", body)
        self.assertNotIn('return {"source_owner": "port_game.source_building_handle_damage_state"', body)

    def test_parity_bridge_wraps_direct_scalar_result(self):
        source = (ROOT / "godot-mindustry/src/game/SourceBuildingDamageState.gd").read_text(encoding="utf-8")
        body = source.split("static func generated_handle_damage_bridge_state", 1)[1].split("\nstatic func ", 1)[0]
        self.assertIn("if result is float or result is int:", body)
        self.assertIn('"handled_damage": result', body)


if __name__ == "__main__":
    unittest.main()
