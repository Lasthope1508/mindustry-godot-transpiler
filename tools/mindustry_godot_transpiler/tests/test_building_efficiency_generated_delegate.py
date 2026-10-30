import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingEfficiencyGeneratedDelegateTests(unittest.TestCase):
    def _body(self, method_name: str) -> str:
        source = GENERATED.read_text(encoding="utf-8")
        return source.split(f"func {method_name}", 1)[1].split("\nfunc ", 1)[0]

    def test_consume_uses_canonical_state(self):
        body = self._body("java_method_consume_188")
        self.assertIn(
            "return source_building_efficiency_state.consume_state(consumers, self_state)",
            body,
        )
        self.assertNotIn("var triggered: Array = []", body)

    def test_can_consume_uses_canonical_state(self):
        body = self._body("java_method_canConsume_189")
        self.assertIn(
            "return source_building_efficiency_state.can_consume_state(potential_efficiency)",
            body,
        )
        self.assertNotIn("var can_consume := potential_efficiency > 0.0", body)


if __name__ == "__main__":
    unittest.main()
