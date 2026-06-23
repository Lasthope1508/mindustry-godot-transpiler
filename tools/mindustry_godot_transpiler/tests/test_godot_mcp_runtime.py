import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class GodotMcpRuntimeTests(unittest.TestCase):
    def test_runtime_addon_is_installed_and_enabled(self):
        project_config = (PROJECT / "project.godot").read_text(encoding="utf-8")
        runtime_dir = PROJECT / "addons" / "godot_mcp_runtime"

        self.assertTrue((runtime_dir / "plugin.cfg").exists())
        self.assertTrue((runtime_dir / "godot_mcp_runtime.gd").exists())
        self.assertTrue((runtime_dir / "mcp_runtime_autoload.gd").exists())
        self.assertIn('"res://addons/godot_mcp_runtime/plugin.cfg"', project_config)


if __name__ == "__main__":
    unittest.main()
