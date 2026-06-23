import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.scanner import scan_source_tree


class ScannerTests(unittest.TestCase):
    def test_scanner_extracts_package_types_and_hash(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            src = root / "core" / "src" / "mindustry" / "content"
            src.mkdir(parents=True)
            java_file = src / "Items.java"
            java_file.write_text("package mindustry.content;\npublic class Items {\n}\n", encoding="utf-8")

            manifest = scan_source_tree(root / "core" / "src")

        self.assertEqual(manifest["java_file_count"], 1)
        self.assertEqual(manifest["files"][0]["package"], "mindustry.content")
        self.assertEqual(manifest["files"][0]["types"], ["Items"])
        self.assertEqual(len(manifest["files"][0]["sha256"]), 64)


if __name__ == "__main__":
    unittest.main()
