import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.emitter import emit_gdscript_classes


class EmitterTests(unittest.TestCase):
    def test_emit_gdscript_class_skeleton_from_java_ast(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "content" / "Sample.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.content;
import mindustry.type.Item;
public class Sample extends BaseSample implements Named{
    public int health;
    private String displayName;
    public Sample(int health){}
    public boolean enabled(Item item){ return true; }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            manifest = emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "content" / "Sample.gd"
            self.assertEqual(manifest["emitted_file_count"], 1)
            self.assertEqual(manifest["skipped_failure_count"], 0)
            self.assertEqual(manifest["files"], ["mindustry/content/Sample.gd"])
            self.assertEqual(emitted.read_text(encoding="utf-8"), """# Generated from Mindustry upstream.
# Source: mindustry/content/Sample.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.content"
const JAVA_KIND := "class"
const JAVA_NAME := "Sample"
const JAVA_EXTENDS := "BaseSample"
const JAVA_IMPLEMENTS := ["Named"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "health", "type": "int"}, {"modifiers": ["private"], "name": "displayName", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Sample", "parameters": [{"name": "health", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "enabled", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
""")


if __name__ == "__main__":
    unittest.main()
