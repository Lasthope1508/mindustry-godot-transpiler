import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.reports import scan_unsupported_features, write_report


class ReportTests(unittest.TestCase):
    def test_scan_unsupported_features_records_path_line_and_feature(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "core" / "src"
            source = root / "mindustry" / "Example.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                "\n".join([
                    "package mindustry;",
                    "public class Example{",
                    "  void run(){ items.each(item -> item.enabled = true); }",
                    "  Object block = new Block(\"x\"){{ health = 10; }};",
                    "}",
                ]),
                encoding="utf-8",
            )

            features = scan_unsupported_features(root)

        self.assertEqual(features, [
            {"path": "mindustry/Example.java", "line": 3, "feature": "lambda", "snippet": "void run(){ items.each(item -> item.enabled = true); }"},
            {"path": "mindustry/Example.java", "line": 4, "feature": "anonymous_double_brace_initializer", "snippet": "Object block = new Block(\"x\"){{ health = 10; }};"},
        ])

    def test_write_report_persists_unsupported_features_with_exact_locations(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source_root = root / "upstream" / "core" / "src"
            source = source_root / "mindustry" / "Example.java"
            source.parent.mkdir(parents=True)
            source.write_text(
                "package mindustry;\npublic class Example{\n  void run(){ Runnable r = () -> {}; }\n}\n",
                encoding="utf-8",
            )
            generated = root / "godot" / "src" / "generated"

            report = write_report(generated, source_manifest={"java_file_count": 1}, asset_manifest={"asset_count": 0}, source_root=source_root)

            self.assertEqual(report["unsupported_features"], [{"path": "mindustry/Example.java", "line": 3, "feature": "lambda", "snippet": "void run(){ Runnable r = () -> {}; }"}])
            self.assertIn("mindustry/Example.java:3", (generated / "port_report.md").read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
