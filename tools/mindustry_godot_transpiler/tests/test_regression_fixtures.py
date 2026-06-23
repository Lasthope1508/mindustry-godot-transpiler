import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
FIXTURES = ROOT / "tools" / "mindustry_godot_transpiler" / "tests" / "fixtures"
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.content_registry import UPSTREAM_COMMIT, write_gdscript_registry


class RegressionFixtureTests(unittest.TestCase):
    def test_generated_content_registry_gdscript_matches_fixture(self):
        registry = {
            "upstream_commit": UPSTREAM_COMMIT,
            "counts": {"blocks": 1, "items": 1, "liquids": 0, "units": 1},
            "items": [{"color": "d99d73", "field": "copper", "id": "copper", "implementation": "Item", "properties": {"hardness": 1}, "texture": "res://assets/core/assets-raw/sprites/items/item-copper.png"}],
            "liquids": [],
            "blocks": [{"field": "duo", "id": "duo", "implementation": "ItemTurret", "properties": {"ammo": [{"damage": 9, "item": "copper", "lifetime": 60.0, "speed": 2.5}], "range": 110.0, "reload": 20.0}, "texture": "res://assets/core/assets-raw/sprites/blocks/turrets/duo.png"}],
            "units": [{"field": "dagger", "id": "dagger", "implementation": "UnitType", "properties": {"health": 150, "hitSize": 8.0, "speed": 0.5}, "texture": "res://assets/core/assets-raw/sprites/units/dagger.png"}],
            "waves": {"groups": [{"end": 10, "max": 30, "unit": "dagger", "unitScaling": 2.0}], "version": 7},
        }
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "MindustryContentRegistry.gd"

            write_gdscript_registry(registry, output)

            self.assertEqual(output.read_text(encoding="utf-8"), (FIXTURES / "expected_content_registry.gd").read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
