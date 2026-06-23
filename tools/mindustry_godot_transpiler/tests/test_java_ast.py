import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.java_ast import parse_java_file


class JavaAstTests(unittest.TestCase):
    def test_parser_extracts_class_shape(self):
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "core" / "src" / "mindustry" / "type"
            src.mkdir(parents=True)
            java_file = src / "Item.java"
            java_file.write_text(
                """
                package mindustry.type;
                import arc.graphics.Color;
                public class Item extends UnlockableContent implements Comparable<Item> {
                    public int hardness = 0;
                    public Item(String name, Color color) { super(name); }
                    public int compareTo(Item other) { return 0; }
                }
                """,
                encoding="utf-8",
            )

            parsed = parse_java_file(java_file, Path(tmp) / "core" / "src")

        self.assertEqual(parsed["package"], "mindustry.type")
        self.assertEqual(parsed["imports"], ["arc.graphics.Color"])
        self.assertEqual(parsed["types"][0]["kind"], "class")
        self.assertEqual(parsed["types"][0]["name"], "Item")
        self.assertEqual(parsed["types"][0]["extends"], "UnlockableContent")
        self.assertEqual(parsed["types"][0]["implements"], ["Comparable"])
        self.assertEqual(parsed["types"][0]["fields"][0]["name"], "hardness")
        self.assertEqual(parsed["types"][0]["constructors"][0]["name"], "Item")
        self.assertEqual(parsed["types"][0]["methods"][0]["name"], "compareTo")

    def test_parser_extracts_enum_constants(self):
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "core" / "src" / "mindustry" / "ctype"
            src.mkdir(parents=True)
            java_file = src / "ContentType.java"
            java_file.write_text(
                """
                package mindustry.ctype;
                public enum ContentType { item, liquid, block }
                """,
                encoding="utf-8",
            )

            parsed = parse_java_file(java_file, Path(tmp) / "core" / "src")

        self.assertEqual(parsed["types"][0]["kind"], "enum")
        self.assertEqual(parsed["types"][0]["enum_constants"], ["item", "liquid", "block"])

    def test_parser_tolerates_switch_arrow_in_method_body(self):
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "core" / "src" / "mindustry" / "graphics"
            src.mkdir(parents=True)
            java_file = src / "Renderer.java"
            java_file.write_text(
                """
                package mindustry.graphics;
                public class Renderer{
                    public String message(int error){
                        return switch(error){
                            case 1 -> "one";
                            default -> "other";
                        };
                    }
                }
                """,
                encoding="utf-8",
            )

            parsed = parse_java_file(java_file, Path(tmp) / "core" / "src")

        self.assertEqual(parsed["types"][0]["name"], "Renderer")
        self.assertEqual(parsed["types"][0]["methods"][0]["name"], "message")

    def test_parser_tolerates_pattern_instanceof_in_method_body(self):
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "core" / "src" / "mindustry" / "ai"
            src.mkdir(parents=True)
            java_file = src / "BaseBuilderAI.java"
            java_file.write_text(
                """
                package mindustry.ai;
                public class BaseBuilderAI{
                    public boolean enemy(Object build){
                        return build instanceof CoreBuild b && b.team != null;
                    }
                }
                """,
                encoding="utf-8",
            )

            parsed = parse_java_file(java_file, Path(tmp) / "core" / "src")

        self.assertEqual(parsed["types"][0]["name"], "BaseBuilderAI")
        self.assertEqual(parsed["types"][0]["methods"][0]["return_type"], "boolean")

    def test_parser_tolerates_text_blocks_in_method_body(self):
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "core" / "src" / "mindustry" / "content"
            src.mkdir(parents=True)
            java_file = src / "Blocks.java"
            java_file.write_text('package mindustry.content; public class Blocks{ public void load(){ setPaletteFromString("""\nabc\ndef\n"""); } }', encoding="utf-8")

            parsed = parse_java_file(java_file, Path(tmp) / "core" / "src")

        self.assertEqual(parsed["types"][0]["name"], "Blocks")
    def test_parser_tolerates_instanceof_text_in_method_comment(self):
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "core" / "src" / "mindustry" / "entities"
            src.mkdir(parents=True)
            java_file = src / "Damage.java"
            java_file.write_text(
                """
                package mindustry.entities;
                public class Damage{
                    public void applySuppression(){
                        run(first -> true, second -> {
                            // TODO maybe should be block field instead of instanceof check
                            if(second != null){
                                second.toString();
                            }
                        });
                    }
                    public void next(){}
                }
                """,
                encoding="utf-8",
            )

            parsed = parse_java_file(java_file, Path(tmp) / "core" / "src")

        self.assertEqual([method["name"] for method in parsed["types"][0]["methods"]], ["applySuppression", "next"])


if __name__ == "__main__":
    unittest.main()
