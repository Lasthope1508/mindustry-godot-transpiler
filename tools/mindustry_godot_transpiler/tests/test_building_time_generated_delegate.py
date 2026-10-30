import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingTimeGeneratedDelegateTests(unittest.TestCase):
    def _body(self, method_name: str) -> str:
        source = GENERATED.read_text(encoding="utf-8")
        return source.split(f"func {method_name}", 1)[1].split("\nfunc ", 1)[0]

    def test_delta_uses_canonical_state(self):
        body = self._body("java_method_delta_190")
        self.assertIn("return source_building_time_state.delta(source_delta, time_scale)", body)
        self.assertNotIn("var delta := source_delta * time_scale", body)

    def test_edelta_uses_canonical_state(self):
        body = self._body("java_method_edelta_191")
        self.assertIn("return source_building_time_state.edelta(source_delta, time_scale, efficiency)", body)
        self.assertNotIn("var delta_result = java_method_delta_190([source_delta, time_scale])", body)


if __name__ == "__main__":
    unittest.main()
