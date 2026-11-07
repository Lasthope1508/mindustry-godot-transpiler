import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
GENERATED = ROOT / "godot-mindustry/src/generated/classes/mindustry/entities/comp/BuildingComp.gd"


class BuildingConfigureCallbacksGeneratedSliceTests(unittest.TestCase):
    def _body(self, method_name: str) -> str:
        source = GENERATED.read_text(encoding="utf-8")
        return source.split(f"func {method_name}", 1)[1].split("\nfunc ", 1)[0]

    def test_on_configure_tapped_delegates_to_canonical_state(self):
        body = self._body("java_method_onConfigureTapped_167(_args: Array = []) -> Variant:")
        self.assertIn("source_building_configure_state.on_configure_tapped_state(x, y)", body)
        self.assertNotIn('"source_owner": "port_game.source_building_on_configure_tapped_state"', body)

    def test_on_configure_closed_delegates_to_canonical_state(self):
        body = self._body("java_method_onConfigureClosed_168(_args: Array = []) -> Variant:")
        self.assertIn("source_building_configure_state.on_configure_closed_state()", body)
        self.assertNotIn('"source_owner": "port_game.source_building_on_configure_closed_state"', body)

    def test_should_show_configure_delegates_to_canonical_state(self):
        body = self._body("java_method_shouldShowConfigure_169(_args: Array = []) -> Variant:")
        self.assertIn("source_building_configure_state.should_show_configure_state(player)", body)
        self.assertNotIn('"source_owner": "port_game.source_building_should_show_configure_state"', body)

    def test_should_hide_configure_delegates_to_canonical_state(self):
        body = self._body("java_method_shouldHideConfigure_170(_args: Array = []) -> Variant:")
        self.assertIn("source_building_configure_state.should_hide_configure_state(player)", body)
        self.assertNotIn('"source_owner": "port_game.source_building_should_hide_configure_state"', body)


if __name__ == "__main__":
    unittest.main()
