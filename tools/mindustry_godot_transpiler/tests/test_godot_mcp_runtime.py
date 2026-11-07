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
        autoload_uid = (runtime_dir / "mcp_runtime_autoload.gd.uid").read_text(encoding="utf-8").strip()
        self.assertTrue(
            'MCPRuntime="*res://addons/godot_mcp_runtime/mcp_runtime_autoload.gd"' in project_config
            or f'MCPRuntime="*{autoload_uid}"' in project_config
        )
        self.assertIn('config/icon="res://assets/core/assets/icons/icon_64.png"', project_config)
        self.assertTrue((PROJECT / "assets" / "core" / "assets" / "icons" / "icon_64.png").exists())

    def test_runtime_addon_deserializes_typed_float_nan_for_source_proofs(self):
        source = (PROJECT / "addons" / "godot_mcp_runtime" / "mcp_runtime_autoload.gd").read_text(encoding="utf-8")

        self.assertIn('"Float":', source)
        self.assertIn('var float_value = value.get("value", 0.0)', source)
        self.assertIn('return NAN', source)
        self.assertIn('return float(float_value)', source)

    def test_input_and_display_runtime_proofs_emit_aggregate_matches_json(self):
        control_proof_source = (PROJECT / "tools" / "runtime_proofs" / "ControlInputModuleProof.gd").read_text(encoding="utf-8")
        display_proof_source = (PROJECT / "tools" / "runtime_proofs" / "DisplayProfileRuntimeModuleProof.gd").read_text(encoding="utf-8")

        self.assertIn('proof["matches"] =', control_proof_source)
        self.assertIn('const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")', control_proof_source)
        self.assertIn('runtime_proof_state.write_proof("ControlInputModuleProof", proof)', control_proof_source)
        self.assertIn("get_tree().quit(runtime_proof_state.exit_code(proof))", control_proof_source)

        self.assertIn('proof["matches"] =', display_proof_source)
        self.assertIn('const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")', display_proof_source)
        self.assertIn('runtime_proof_state.write_proof("DisplayProfileRuntimeModuleProof", proof)', display_proof_source)
        self.assertIn("get_tree().quit(runtime_proof_state.exit_code(proof))", display_proof_source)


if __name__ == "__main__":
    unittest.main()
