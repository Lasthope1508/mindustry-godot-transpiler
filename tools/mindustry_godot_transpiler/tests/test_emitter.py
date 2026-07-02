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
    private void enabled(){ }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            manifest = emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "content" / "Sample.gd"
            registry = output_root.parent / "GeneratedClassRegistry.gd"
            self.assertEqual(manifest["emitted_file_count"], 1)
            self.assertEqual(manifest["skipped_failure_count"], 0)
            self.assertEqual(manifest["files"], ["mindustry/content/Sample.gd"])
            self.assertEqual(manifest["registry"], "GeneratedClassRegistry.gd")
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
const JAVA_METHODS := [{"modifiers": ["public"], "name": "enabled", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "enabled", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_enabled_0(_args: Array = []) -> Variant:
	return null

func java_method_enabled_1(_args: Array = []) -> Variant:
	return null
""")
            self.assertEqual(registry.read_text(encoding="utf-8"), """# Generated from Mindustry upstream.
# Source: emitted_classes.json
# Do not edit by hand.
extends RefCounted
class_name MindustryGeneratedClassRegistry

const CLASS_COUNT := 1
const CLASSES := [{"gdscript_path": "res://src/generated/classes/mindustry/content/Sample.gd", "java_kind": "class", "java_name": "Sample", "java_package": "mindustry.content", "java_path": "mindustry/content/Sample.java"}]

static func count() -> int:
	return CLASS_COUNT

static func all_classes() -> Array:
	return CLASSES

static func find_by_java_name(java_name: String) -> Dictionary:
	for class_entry in CLASSES:
		if class_entry.get("java_name", "") == java_name:
			return class_entry
	return {}
""")


    def test_emit_bridges_building_comp_get_progress_increase_to_source_formula(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "core" / "src"
            source = source_root / "mindustry" / "entities" / "comp" / "BuildingComp.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                """
package mindustry.entities.comp;
public class BuildingComp{
    public float getProgressIncrease(float baseTime){
        return 1f / baseTime * edelta();
    }
}
""",
                encoding="utf-8",
            )
            output_root = root / "godot" / "src" / "generated" / "classes"

            emit_gdscript_classes(source_root, output_root)

            emitted = output_root / "mindustry" / "entities" / "comp" / "BuildingComp.gd"
            source_text = emitted.read_text(encoding="utf-8")
            self.assertIn("func java_method_getProgressIncrease_0(_args: Array = []) -> Variant:", source_text)
            self.assertIn("var base_time := float(_args[0] if _args.size() > 0 else 1.0)", source_text)
            self.assertIn("var edelta_value := float(_args[1] if _args.size() > 1 else 1.0)", source_text)
            self.assertIn("return 1.0 / base_time * edelta_value", source_text)

if __name__ == "__main__":
    unittest.main()
