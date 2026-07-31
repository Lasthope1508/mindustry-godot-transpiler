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
        self.assertIn('config/icon="res://assets/core/assets/icons/icon_64.png"', project_config)
        self.assertTrue((PROJECT / "assets" / "core" / "assets" / "icons" / "icon_64.png").exists())

    def test_runtime_addon_deserializes_typed_float_nan_for_source_proofs(self):
        source = (PROJECT / "addons" / "godot_mcp_runtime" / "mcp_runtime_autoload.gd").read_text(encoding="utf-8")

        self.assertIn('"Float":', source)
        self.assertIn('var float_value = value.get("value", 0.0)', source)
        self.assertIn('return NAN', source)
        self.assertIn('return float(float_value)', source)

    def test_input_and_display_runtime_proofs_emit_aggregate_matches_json(self):
        for proof_name in ["ControlInputModuleProof", "DisplayProfileRuntimeModuleProof"]:
            proof_source = (PROJECT / "tools" / "runtime_proofs" / f"{proof_name}.gd").read_text(encoding="utf-8")

            self.assertIn('proof["matches"] =', proof_source)
            self.assertIn(f'res://tools/runtime_proofs/{proof_name}.json', proof_source)
            self.assertIn("proof_file.store_string(proof_json)", proof_source)
            self.assertIn("proof_file.flush()", proof_source)


if __name__ == "__main__":
    unittest.main()
