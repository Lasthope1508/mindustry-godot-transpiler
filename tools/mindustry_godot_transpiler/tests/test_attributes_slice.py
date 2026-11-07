import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class AttributesSliceTests(unittest.TestCase):
    def test_generated_attributes_methods_delegate_to_one_canonical_module(self):
        source = (PROJECT / "src/generated/classes/mindustry/world/blocks/Attributes.gd").read_text(encoding="utf-8")
        self.assertIn('const source_attributes_state := preload("res://src/game/SourceAttributesState.gd")', source)
        for method_name, index in (
            ("clear", 0), ("get", 1), ("set", 2), ("add", 3), ("add", 4),
            ("write", 5), ("read", 6), ("check", 7), ("toString", 8),
        ):
            body = re.search(
                rf"func java_method_{method_name}_{index}\(_args: Array = \[\]\) -> Variant:\n(?P<body>.*?)(?=\nfunc |\Z)",
                source,
                re.S,
            )
            self.assertIsNotNone(body)
            self.assertIn("source_attributes_state.", body.group("body"))
            self.assertNotIn("return null", body.group("body"))

    def test_canonical_attributes_state_preserves_java_container_semantics(self):
        source_text = (PROJECT / "src/game/SourceAttributesSourceTextState.gd").read_text(encoding="utf-8")
        state = (PROJECT / "src/game/SourceAttributesState.gd").read_text(encoding="utf-8")
        bridge = (PROJECT / "src/game/SourceBlockRuntimePortBridge.gd").read_text(encoding="utf-8")
        for literal in (
            'const SOURCE := "core/src/mindustry/world/blocks/Attributes.java"',
            'const CHECK_RESIZE := "arr = new float[Attribute.all.length];"',
            'const CHECK_COPY := "System.arraycopy(last, 0, arr, 0, Math.min(last.length, arr.length));"',
            'const WRITE_NONZERO := "if(arr[at.id] != 0){"',
            'const READ_DEFAULT := "arr[at.id] = data.getFloat(at.name, 0);"',
        ):
            self.assertIn(literal, source_text)
        for function_name in (
            "clear_state", "get_state", "set_state", "add_state", "write_state",
            "read_state", "check_state", "to_string_state",
        ):
            self.assertIn(f"static func {function_name}", state)
        self.assertIn("resized.resize(attribute_all.size())", state)
        self.assertIn("float(data.get(str(attribute.get(\"name\", \"\")), 0.0))", state)
        self.assertIn("func source_attributes_to_string_state", bridge)

    def test_attributes_registry_and_slice_are_source_backed(self):
        import json

        registry = json.loads((PROJECT / "src/generated/source_symbol_registry.json").read_text(encoding="utf-8"))
        ledger = json.loads((PROJECT / "src/generated/source_slice_ledger.json").read_text(encoding="utf-8"))
        for symbol in (
            "attributes.clear", "attributes.get", "attributes.set", "attributes.add",
            "attributes.add_scaled", "attributes.write", "attributes.read",
            "attributes.check", "attributes.to_string",
        ):
            entry = registry["symbols"][symbol]
            self.assertEqual(entry["status"], "source-backed")
            self.assertEqual(entry["java_source"], "core/src/mindustry/world/blocks/Attributes.java")
            self.assertEqual(entry["source_slice"], "N1783")
        slice_entry = ledger["slices"]["N1783"]
        self.assertEqual(slice_entry["status"], "done")
        self.assertEqual(slice_entry["java_class"], "mindustry.world.blocks.Attributes")
        self.assertEqual(slice_entry["java_method"], "Attributes container methods")
        self.assertIn("attributes.check", slice_entry["source_symbols"])


if __name__ == "__main__":
    unittest.main()
