import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MAPPING = ROOT / "tools" / "mindustry_godot_transpiler" / "mapping" / "java_to_gdscript.json"


class MappingTests(unittest.TestCase):
    def test_mapping_table_covers_required_constructs(self):
        mapping = json.loads(MAPPING.read_text(encoding="utf-8"))
        required = [
            "package_path",
            "imports",
            "class",
            "enum",
            "field",
            "method",
            "constructor",
            "static_initializer",
            "overload",
        ]
        for key in required:
            self.assertIn(key, mapping)
            self.assertIsInstance(mapping[key], dict)
            self.assertIn("gdscript", mapping[key])


if __name__ == "__main__":
    unittest.main()
