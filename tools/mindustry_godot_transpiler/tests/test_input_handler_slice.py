import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PROJECT = ROOT / "godot-mindustry"


class InputHandlerSliceTests(unittest.TestCase):
    def test_source_text_ssot_contains_exact_upstream_boundaries(self):
        source = (PROJECT / "src/game/SourceInputHandlerSourceTextState.gd").read_text(encoding="utf-8")
        upstream = (ROOT / "mindustry-upstream/core/src/mindustry/input/InputHandler.java").read_text(encoding="utf-8")
        expressions = [
            "public float getMouseX(){",
            "return Core.input.mouseX();",
            "public float getMouseY(){",
            "return Core.input.mouseY();",
            "public void panCamera(Vec2 position){",
            "if(!locked())",
            "camera.position.set(position);",
            "public boolean selectedBlock(){",
            "return isPlacing();",
            "public boolean isPlacing(){",
            "return block != null;",
            "public boolean isBreaking(){",
            "return false;",
            "public float mouseAngle(float x, float y){",
            "return Core.input.mouseWorld(getMouseX(), getMouseY()).sub(x, y).angle();",
        ]
        for expression in expressions:
            with self.subTest(expression=expression):
                self.assertIn(expression, upstream)
                self.assertIn(expression, source)

    def test_generated_input_handler_delegates_the_query_camera_cluster(self):
        generated = (PROJECT / "src/generated/classes/mindustry/input/InputHandler.gd").read_text(encoding="utf-8")
        expected = {
            "getMouseX_50": "source_input_handler_state.get_mouse_x_state",
            "getMouseY_51": "source_input_handler_state.get_mouse_y_state",
            "panCamera_121": "source_input_handler_state.pan_camera_state",
            "selectedBlock_122": "source_input_handler_state.selected_block_state",
            "isPlacing_123": "source_input_handler_state.is_placing_state",
            "isBreaking_124": "source_input_handler_state.is_breaking_state",
            "mouseAngle_126": "source_input_handler_state.mouse_angle_state",
        }
        for method, delegate in expected.items():
            with self.subTest(method=method):
                start = generated.index(f"func java_method_{method}(_args: Array = []) -> Variant:")
                end = generated.find("\nfunc ", start + 1)
                body = generated[start:] if end == -1 else generated[start:end]
                self.assertIn(delegate, body)
                self.assertNotIn("\n\treturn null", body)

    def test_registry_has_one_canonical_owner_per_input_handler_method(self):
        registry = (PROJECT / "src/game/SourceRuntimeOwnerGameplayRegistry.gd").read_text(encoding="utf-8")
        owners = [
            "PORT_GAME_SOURCE_INPUT_HANDLER_GET_MOUSE_X_STATE",
            "PORT_GAME_SOURCE_INPUT_HANDLER_GET_MOUSE_Y_STATE",
            "PORT_GAME_SOURCE_INPUT_HANDLER_PAN_CAMERA_STATE",
            "PORT_GAME_SOURCE_INPUT_HANDLER_SELECTED_BLOCK_STATE",
            "PORT_GAME_SOURCE_INPUT_HANDLER_IS_PLACING_STATE",
            "PORT_GAME_SOURCE_INPUT_HANDLER_IS_BREAKING_STATE",
            "PORT_GAME_SOURCE_INPUT_HANDLER_MOUSE_ANGLE_STATE",
        ]
        for owner in owners:
            self.assertEqual(registry.count(f"const {owner} :="), 1)

    def test_runtime_proof_is_registered_shape(self):
        proof = (PROJECT / "tools/runtime_proofs/InputHandlerQueryModuleProof.gd").read_text(encoding="utf-8")
        self.assertIn('const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")', proof)
        self.assertIn('runtime_proof_state.write_proof("InputHandlerQueryModuleProof", proof)', proof)
        self.assertIn("get_tree().quit(runtime_proof_state.exit_code(proof))", proof)


if __name__ == "__main__":
    unittest.main()
