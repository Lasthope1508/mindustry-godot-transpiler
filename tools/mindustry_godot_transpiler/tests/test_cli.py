import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
CLI = ROOT / "tools" / "mindustry_godot_transpiler" / "transpile.py"


def run_cli(*args):
    return subprocess.run([sys.executable, str(CLI), *args], cwd=ROOT, text=True, capture_output=True)


class CliTests(unittest.TestCase):
    def test_cli_help_lists_commands(self):
        result = run_cli("--help")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("scan", result.stdout)
        self.assertIn("assets", result.stdout)
        self.assertIn("report", result.stdout)
        self.assertIn("content", result.stdout)
        self.assertIn("all", result.stdout)

    def test_all_command_writes_manifests_and_report(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            upstream = root / "mindustry-upstream"
            source = upstream / "core" / "src" / "mindustry" / "content"
            asset = upstream / "core" / "assets" / "sprites"
            source.mkdir(parents=True)
            asset.mkdir(parents=True)
            (source / "Items.java").write_text("package mindustry.content;\npublic class Items {}\n", encoding="utf-8")
            (asset / "logo.png").write_bytes(b"logo")
            godot = root / "godot-mindustry"

            result = run_cli("all", "--upstream", str(upstream), "--godot", str(godot))

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((godot / "src" / "generated" / "source_manifest.json").exists())
            self.assertTrue((godot / "src" / "generated" / "asset_manifest.json").exists())
            self.assertTrue((godot / "src" / "generated" / "port_report.md").exists())

    def test_parse_command_writes_ast_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            upstream = root / "mindustry-upstream"
            source = upstream / "core" / "src" / "mindustry" / "content"
            source.mkdir(parents=True)
            (source / "Items.java").write_text("package mindustry.content;\npublic class Items {}\n", encoding="utf-8")
            godot = root / "godot-mindustry"

            result = run_cli("parse", "--upstream", str(upstream), "--godot", str(godot), "--limit", "10")

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((godot / "src" / "generated" / "ast_manifest.json").exists())


    def test_playable_command_writes_playable_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            godot = root / "godot-mindustry"
            assets = godot / "assets"
            required = [
                "core/assets-raw/sprites/items/item-copper.png",
                "core/assets-raw/sprites/blocks/environment/ore-copper1.png",
                "core/assets-raw/sprites/blocks/environment/stone1.png",
                "core/assets-raw/sprites/blocks/drills/mechanical-drill.png",
                "core/assets-raw/sprites/blocks/distribution/conveyors/conveyor-0-0.png",
                "core/assets-raw/sprites/blocks/storage/core-shard.png",
            ]
            for rel in required:
                path = assets / rel
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"asset")

            result = run_cli("playable", "--godot", str(godot))

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue((godot / "src" / "generated" / "playable_content.json").exists())


    def test_content_command_writes_json_and_gdscript_registry(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            upstream = root / "mindustry-upstream"
            source = upstream / "core" / "src" / "mindustry" / "content"
            source.mkdir(parents=True)
            (source / "Items.java").write_text(
                'package mindustry.content; import arc.graphics.*; import mindustry.type.*; public class Items{ public static Item copper; public static void load(){ copper = new Item("copper", Color.valueOf("d99d73")); } }',
                encoding="utf-8",
            )
            (source / "Liquids.java").write_text(
                'package mindustry.content; import arc.graphics.*; import mindustry.type.*; public class Liquids{ public static Liquid water; public static void load(){ water = new Liquid("water", Color.valueOf("596ab8")); } }',
                encoding="utf-8",
            )
            (source / "Blocks.java").write_text(
                'package mindustry.content; public class Blocks{ public static Block conveyor; public static void load(){ conveyor = new Conveyor("conveyor"); } }',
                encoding="utf-8",
            )
            godot = root / "godot-mindustry"

            result = run_cli("content", "--upstream", str(upstream), "--godot", str(godot))

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("content items=1 liquids=1 blocks=1 units=0", result.stdout)
            self.assertTrue((godot / "src" / "generated" / "content_registry.json").exists())
            self.assertTrue((godot / "src" / "generated" / "MindustryContentRegistry.gd").exists())


if __name__ == "__main__":
    unittest.main()
