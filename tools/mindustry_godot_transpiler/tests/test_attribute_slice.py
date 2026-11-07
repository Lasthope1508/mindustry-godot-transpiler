import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class AttributeSliceTests(unittest.TestCase):
    def test_generated_methods_delegate_to_canonical_attribute_module(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/meta/Attribute.gd").read_text(encoding="utf-8")
        self.assertIn('const source_attribute_state := preload("res://src/game/SourceAttributeState.gd")', source)
        for name, index in (("env", 0), ("toString", 1), ("get", 2), ("getOrNull", 3), ("exists", 4), ("add", 5)):
            body = re.search(rf"func java_method_{name}_{index}\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)", source, re.S)
            self.assertIsNotNone(body)
            self.assertIn("source_attribute_state.", body.group("body"))
            self.assertNotIn("return null", body.group("body"))

    def test_source_text_preserves_attribute_catalog_contract(self):
        source = (PROJECT / "src/game/SourceAttributeSourceTextState.gd").read_text(encoding="utf-8")
        for literal in (
            'const SOURCE := "core/src/mindustry/world/meta/Attribute.java"',
            'const ENV_GUARD := "if(Vars.state == null) return 0;"',
            'const GET_THROW := "return map.getThrow(name, () -> new IllegalArgumentException(\\"Unknown Attribute type: \\" + name));"',
            'const ADD_ID := "new Attribute(all.length, name)"',
            'const ADD_MAP := "map.put(name, a);"',
        ):
            self.assertIn(literal, source)

    def test_attribute_slice_registry_is_source_backed(self):
        import json

        generated = PROJECT / "src/generated"
        registry = json.loads((generated / "source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((generated / "source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol in ("attribute.env", "attribute.to_string", "attribute.get", "attribute.get_or_null", "attribute.exists", "attribute.add"):
            entry = registry["symbols"][symbol]
            self.assertEqual(entry["java_source"], "core/src/mindustry/world/meta/Attribute.java")
            self.assertEqual(entry["source_slice"], "N1784")
            self.assertEqual(entry["status"], "source-backed")
        self.assertEqual(ledger["slices"]["N1784"]["status"], "done")
        self.assertEqual(ledger["slices"]["N1784"]["java_class"], "mindustry.world.meta.Attribute")


if __name__ == "__main__":
    unittest.main()
