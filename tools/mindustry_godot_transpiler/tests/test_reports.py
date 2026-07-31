import tempfile
import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port.reports import scan_port_game_bridge_surface, scan_port_game_footprint, scan_unsupported_features, write_report


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

    def test_scan_port_game_footprint_counts_lines_functions_preloads_and_wrappers(self):
        with tempfile.TemporaryDirectory() as tmp:
            godot_root = Path(tmp) / "godot"
            port_game = godot_root / "src" / "game" / "PortGame.gd"
            port_game.parent.mkdir(parents=True)
            port_game.write_text(
                "\n".join([
                    "extends Node2D",
                    'const source_runtime := preload("res://src/game/SourceRuntime.gd")',
                    "",
                    "func source_alpha_state() -> Dictionary:",
                    "\treturn source_runtime.alpha_state()",
                    "",
                    "func generated_alpha_bridge_state() -> Dictionary:",
                    "\treturn source_runtime.generated_alpha_bridge_state()",
                    "",
                ]),
                encoding="utf-8",
            )

            footprint = scan_port_game_footprint(godot_root)

        self.assertEqual(footprint["path"], "src/game/PortGame.gd")
        self.assertTrue(footprint["exists"])
        self.assertEqual(footprint["line_count"], 8)
        self.assertEqual(footprint["preload_count"], 1)
        self.assertEqual(footprint["function_count"], 2)
        self.assertEqual(footprint["source_function_count"], 1)
        self.assertEqual(footprint["generated_bridge_function_count"], 1)
        self.assertEqual(footprint["max_function_lines"], 3)

    def test_write_report_persists_port_game_footprint(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            godot_root = root / "godot"
            port_game = godot_root / "src" / "game" / "PortGame.gd"
            port_game.parent.mkdir(parents=True)
            port_game.write_text("extends Node2D\nfunc update_hud() -> void:\n\tpass\n", encoding="utf-8")
            generated = godot_root / "src" / "generated"

            report = write_report(generated, godot_root=godot_root)

            self.assertEqual(report["port_game_footprint"]["line_count"], 3)
            self.assertEqual(report["port_game_footprint"]["function_count"], 1)
            self.assertIn("PortGame lines: 3", (generated / "port_report.md").read_text(encoding="utf-8"))

    def test_scan_port_game_bridge_surface_groups_delegates_by_module(self):
        with tempfile.TemporaryDirectory() as tmp:
            godot_root = Path(tmp) / "godot"
            port_game = godot_root / "src" / "game" / "PortGame.gd"
            port_game.parent.mkdir(parents=True)
            port_game.write_text(
                "\n".join([
                    "extends Node2D",
                    'const source_alpha_state_module := preload("res://src/game/SourceAlphaStateModule.gd")',
                    'const source_beta_runtime_state := preload("res://src/game/SourceBetaRuntimeState.gd")',
                    "",
                    "func source_alpha_state() -> Dictionary:",
                    "\treturn source_alpha_state_module.alpha_state()",
                    "",
                    "func generated_alpha_bridge_state() -> Dictionary:",
                    "\treturn source_alpha_state_module.generated_alpha_bridge_state()",
                    "",
                    "func update_beta() -> void:",
                    "\tsource_beta_runtime_state.update_beta(self)",
                    "",
                ]),
                encoding="utf-8",
            )
            (godot_root / "src" / "game" / "SourceAlphaStateModule.gd").write_text(
                "extends RefCounted\nclass_name SourceAlphaStateModule\n",
                encoding="utf-8",
            )
            (godot_root / "src" / "game" / "SourceBetaRuntimeState.gd").write_text(
                "extends RefCounted\nclass_name SourceBetaRuntimeState\n",
                encoding="utf-8",
            )

            surface = scan_port_game_bridge_surface(godot_root)

        self.assertEqual(surface["path"], "src/game/PortGame.gd")
        self.assertTrue(surface["exists"])
        self.assertEqual(surface["delegating_function_count"], 3)
        self.assertEqual(surface["source_delegating_function_count"], 1)
        self.assertEqual(surface["generated_bridge_delegating_function_count"], 1)
        self.assertEqual(surface["delegate_module_count"], 2)
        self.assertEqual(surface["top_delegate_modules"][0]["module"], "source_alpha_state_module")
        self.assertEqual(surface["top_delegate_modules"][0]["function_count"], 2)
        self.assertEqual(surface["top_delegate_modules"][0]["module_path"], "res://src/game/SourceAlphaStateModule.gd")
        self.assertEqual(surface["top_delegate_modules"][0]["class_name"], "SourceAlphaStateModule")
        self.assertEqual(surface["top_delegate_modules"][0]["canonical_owner_target"], "SourceAlphaStateModule")
        self.assertEqual(surface["top_delegate_modules"][0]["compatibility_surface"], "PortGame")
        self.assertEqual(surface["top_delegate_modules"][1]["module"], "source_beta_runtime_state")
        self.assertEqual(surface["top_delegate_modules"][1]["function_count"], 1)
        self.assertEqual(surface["largest_delegate_module"]["module"], "source_alpha_state_module")

    def test_write_report_persists_port_game_bridge_surface(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            godot_root = root / "godot"
            port_game = godot_root / "src" / "game" / "PortGame.gd"
            port_game.parent.mkdir(parents=True)
            port_game.write_text(
                "extends Node2D\nfunc generated_alpha_bridge_state() -> Dictionary:\n\treturn source_alpha_state_module.generated_alpha_bridge_state()\n",
                encoding="utf-8",
            )
            generated = godot_root / "src" / "generated"

            report = write_report(generated, godot_root=godot_root)

            self.assertEqual(report["port_game_bridge_surface"]["delegating_function_count"], 1)
            self.assertIn("PortGame delegating functions: 1", (generated / "port_report.md").read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
