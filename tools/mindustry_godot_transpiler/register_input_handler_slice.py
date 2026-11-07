from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/input/InputHandler.java"
PROOF = "/root/Main.source_input_handler_query_state"
TESTS = ["test_input_handler_slice.py", "test_emitter.py", "test_source_parity.py"]


def key(type_name: str, status: str, expression: str, rule: str, *, java_source: str = SOURCE) -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": java_source,
        "java_expr": expression,
        "rule": rule,
    }


def register_contract(
    slice_id: str,
    owner: str,
    method: str,
    expressions: list[str],
    params: list[dict],
    result_name: str,
    result_keys: dict[str, dict],
    symbol_prefix: str,
) -> None:
    symbols = {
        f"{symbol_prefix}.{name}": {
            "status": entry.get("status", "source-backed"),
            "godot_owner": owner,
            "godot_symbol": f"{result_name}.{name}",
            "rule": entry.get("rule", "Canonical InputHandler source contract."),
            "tests": TESTS,
            "runtime_proof": PROOF,
            "java_source": entry.get("java_source", SOURCE),
            "java_method": method,
            "java_expr": entry.get("java_expr", ""),
            "source_slice": slice_id,
        }
        for name, entry in result_keys.items()
    }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "status": "done",
        "java_source": SOURCE,
        "java_class": "mindustry.input.InputHandler",
        "java_method": method,
        "godot_owner": owner,
        "exact_exprs": expressions,
        "source_symbols": list(symbols),
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Source-backed InputHandler query/camera boundary with explicit engine inputs.",
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "status": "active",
        "source_slice": slice_id,
        "java_source": SOURCE,
        "source_method": method,
        "params": params,
        "return_keys": list(result_keys),
        "tests": TESTS,
        "runtime_proof": PROOF,
        "rule": "Canonical InputHandler runtime contract; unavailable Core/camera state remains explicit input.",
    })
    source_symbols.upsert_source_state_schema(GODOT, result_name, {
        "status": "active",
        "owner": owner,
        "runtime_proof": PROOF,
        "source_slice": slice_id,
        "keys": result_keys,
    })


def main() -> None:
    source_symbols.upsert_source_state_schema(GODOT, "source_input_handler_mouse_input", {
        "status": "active",
        "owner": "PortGame.source_input_handler_get_mouse_x_state",
        "runtime_proof": PROOF,
        "keys": {
            "mouse_x": key("float", "explicit-input", "Core.input.mouseX()", "Core input mouse X supplied by runtime."),
            "mouse_y": key("float", "explicit-input", "Core.input.mouseY()", "Core input mouse Y supplied by runtime."),
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_input_handler_camera_input", {
        "status": "active",
        "owner": "PortGame.source_input_handler_pan_camera_state",
        "runtime_proof": PROOF,
        "keys": {
            "position": key("Vector2", "explicit-input", "camera.position.set(position);", "Requested camera position."),
            "locked": key("bool", "explicit-input", "if(!locked())", "Input lock state from InputHandler."),
            "camera_position_before": key("Vector2", "explicit-input", "camera.position.set(position);", "Current camera position before the operation."),
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_input_handler_block_input", {
        "status": "active",
        "owner": "PortGame.source_input_handler_selected_block_state",
        "runtime_proof": PROOF,
        "keys": {
            "block_present": key("bool", "explicit-input", "return block != null;", "Whether InputHandler.block is non-null."),
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_input_handler_mouse_angle_input", {
        "status": "active",
        "owner": "PortGame.source_input_handler_mouse_angle_state",
        "runtime_proof": PROOF,
        "keys": {
            "x": key("float", "explicit-input", "sub(x, y)", "World-space origin X."),
            "y": key("float", "explicit-input", "sub(x, y)", "World-space origin Y."),
            "mouse_world": key("Vector2", "explicit-input", "Core.input.mouseWorld(getMouseX(), getMouseY())", "World-space pointer position."),
        },
    })

    register_contract(
        "N1941", "PortGame.source_input_handler_get_mouse_x_state", "InputHandler.getMouseX()",
        ["public float getMouseX(){", "return Core.input.mouseX();"],
        [{"name": "mouse_x", "type": "float", "schema": "source_input_handler_mouse_input.mouse_x"}],
        "source_input_handler_get_mouse_x_result",
        {
            "source_owner": key("String", "source-backed", "return Core.input.mouseX();", "Canonical runtime owner."),
            "source": key("String", "generated", "public float getMouseX(){", "Upstream source path marker."),
            "method": key("String", "source-backed", "public float getMouseX(){", "Upstream method boundary."),
            "return_expr": key("String", "source-backed", "return Core.input.mouseX();", "Canonical return expression."),
            "mouse_x": key("float", "generated", "Core.input.mouseX()", "Explicit runtime value returned by the source method."),
            "generated_owner": key("String", "generated", "java_method_getMouseX_50", "Generated method marker."),
            "generated_method": key("String", "generated", "java_method_getMouseX_50", "Generated method marker."),
        }, "input_handler_get_mouse_x"
    )
    register_contract(
        "N1942", "PortGame.source_input_handler_get_mouse_y_state", "InputHandler.getMouseY()",
        ["public float getMouseY(){", "return Core.input.mouseY();"],
        [{"name": "mouse_y", "type": "float", "schema": "source_input_handler_mouse_input.mouse_y"}],
        "source_input_handler_get_mouse_y_result",
        {
            "source_owner": key("String", "source-backed", "return Core.input.mouseY();", "Canonical runtime owner."),
            "source": key("String", "generated", "public float getMouseY(){", "Upstream source path marker."),
            "method": key("String", "source-backed", "public float getMouseY(){", "Upstream method boundary."),
            "return_expr": key("String", "source-backed", "return Core.input.mouseY();", "Canonical return expression."),
            "mouse_y": key("float", "generated", "Core.input.mouseY()", "Explicit runtime value returned by the source method."),
            "generated_owner": key("String", "generated", "java_method_getMouseY_51", "Generated method marker."),
            "generated_method": key("String", "generated", "java_method_getMouseY_51", "Generated method marker."),
        }, "input_handler_get_mouse_y"
    )
    register_contract(
        "N1943", "PortGame.source_input_handler_pan_camera_state", "InputHandler.panCamera(Vec2)",
        ["public void panCamera(Vec2 position){", "if(!locked())", "camera.position.set(position);"],
        [{"name": "position", "type": "Vector2", "schema": "source_input_handler_camera_input.position"}, {"name": "locked", "type": "bool", "schema": "source_input_handler_camera_input.locked"}, {"name": "camera_position_before", "type": "Vector2", "schema": "source_input_handler_camera_input.camera_position_before"}],
        "source_input_handler_pan_camera_result",
        {
            "source_owner": key("String", "source-backed", "camera.position.set(position);", "Canonical runtime owner."),
            "source": key("String", "generated", "public void panCamera(Vec2 position){", "Upstream source path marker."),
            "method": key("String", "source-backed", "public void panCamera(Vec2 position){", "Upstream method boundary."),
            "guard_expr": key("String", "source-backed", "if(!locked())", "Lock guard."),
            "assignment_expr": key("String", "source-backed", "camera.position.set(position);", "Camera assignment."),
            "position": key("Vector2", "generated", "camera.position.set(position);", "Requested camera position."),
            "locked": key("bool", "generated", "if(!locked())", "Lock state."),
            "camera_position_before": key("Vector2", "generated", "camera.position.set(position);", "Pre-operation camera position."),
            "camera_position_after": key("Vector2", "generated", "camera.position.set(position);", "Post-operation camera position."),
            "camera_updated": key("bool", "generated", "if(!locked())", "Whether the guard permits the assignment."),
            "generated_owner": key("String", "generated", "java_method_panCamera_121", "Generated method marker."),
            "generated_method": key("String", "generated", "java_method_panCamera_121", "Generated method marker."),
        }, "input_handler_pan_camera"
    )
    register_contract(
        "N1944", "PortGame.source_input_handler_selected_block_state", "InputHandler.selectedBlock()",
        ["public boolean selectedBlock(){", "return isPlacing();"],
        [{"name": "block_present", "type": "bool", "schema": "source_input_handler_block_input.block_present"}],
        "source_input_handler_selected_block_result",
        {
            "source_owner": key("String", "source-backed", "return isPlacing();", "Canonical runtime owner."),
            "source": key("String", "generated", "public boolean selectedBlock(){", "Upstream source path marker."),
            "method": key("String", "source-backed", "public boolean selectedBlock(){", "Upstream method boundary."),
            "return_expr": key("String", "source-backed", "return isPlacing();", "Canonical return expression."),
            "block_present": key("bool", "generated", "return isPlacing();", "InputHandler block presence."),
            "selected_block": key("bool", "generated", "return isPlacing();", "Selected block predicate."),
            "generated_owner": key("String", "generated", "java_method_selectedBlock_122", "Generated method marker."),
            "generated_method": key("String", "generated", "java_method_selectedBlock_122", "Generated method marker."),
        }, "input_handler_selected_block"
    )
    register_contract(
        "N1945", "PortGame.source_input_handler_is_placing_state", "InputHandler.isPlacing()",
        ["public boolean isPlacing(){", "return block != null;"],
        [{"name": "block_present", "type": "bool", "schema": "source_input_handler_block_input.block_present"}],
        "source_input_handler_is_placing_result",
        {
            "source_owner": key("String", "source-backed", "return block != null;", "Canonical runtime owner."),
            "source": key("String", "generated", "public boolean isPlacing(){", "Upstream source path marker."),
            "method": key("String", "source-backed", "public boolean isPlacing(){", "Upstream method boundary."),
            "return_expr": key("String", "source-backed", "return block != null;", "Canonical return expression."),
            "block_present": key("bool", "generated", "return block != null;", "InputHandler block presence."),
            "is_placing": key("bool", "generated", "return block != null;", "Placement predicate."),
            "generated_owner": key("String", "generated", "java_method_isPlacing_123", "Generated method marker."),
            "generated_method": key("String", "generated", "java_method_isPlacing_123", "Generated method marker."),
        }, "input_handler_is_placing"
    )
    register_contract(
        "N1946", "PortGame.source_input_handler_is_breaking_state", "InputHandler.isBreaking()",
        ["public boolean isBreaking(){", "return false;"],
        [],
        "source_input_handler_is_breaking_result",
        {
            "source_owner": key("String", "source-backed", "return false;", "Canonical runtime owner."),
            "source": key("String", "generated", "public boolean isBreaking(){", "Upstream source path marker."),
            "method": key("String", "source-backed", "public boolean isBreaking(){", "Upstream method boundary."),
            "return_expr": key("String", "source-backed", "return false;", "Canonical return expression."),
            "is_breaking": key("bool", "generated", "return false;", "Breaking predicate."),
            "generated_owner": key("String", "generated", "java_method_isBreaking_124", "Generated method marker."),
            "generated_method": key("String", "generated", "java_method_isBreaking_124", "Generated method marker."),
        }, "input_handler_is_breaking"
    )
    register_contract(
        "N1947", "PortGame.source_input_handler_mouse_angle_state", "InputHandler.mouseAngle(float,float)",
        ["public float mouseAngle(float x, float y){", "return Core.input.mouseWorld(getMouseX(), getMouseY()).sub(x, y).angle();"],
        [{"name": "x", "type": "float", "schema": "source_input_handler_mouse_angle_input.x"}, {"name": "y", "type": "float", "schema": "source_input_handler_mouse_angle_input.y"}, {"name": "mouse_world", "type": "Vector2", "schema": "source_input_handler_mouse_angle_input.mouse_world"}],
        "source_input_handler_mouse_angle_result",
        {
            "source_owner": key("String", "source-backed", "return Core.input.mouseWorld(getMouseX(), getMouseY()).sub(x, y).angle();", "Canonical runtime owner."),
            "source": key("String", "generated", "public float mouseAngle(float x, float y){", "Upstream source path marker."),
            "method": key("String", "source-backed", "public float mouseAngle(float x, float y){", "Upstream method boundary."),
            "return_expr": key("String", "source-backed", "return Core.input.mouseWorld(getMouseX(), getMouseY()).sub(x, y).angle();", "Canonical return expression."),
            "x": key("float", "generated", "sub(x, y)", "World-space origin X."),
            "y": key("float", "generated", "sub(x, y)", "World-space origin Y."),
            "mouse_world": key("Vector2", "generated", "Core.input.mouseWorld(getMouseX(), getMouseY())", "World-space pointer position."),
            "delta": key("Vector2", "generated", ".sub(x, y)", "Pointer delta."),
            "mouse_angle": key("float", "generated", ".angle()", "Pointer angle."),
            "generated_owner": key("String", "generated", "java_method_mouseAngle_126", "Generated method marker."),
            "generated_method": key("String", "generated", "java_method_mouseAngle_126", "Generated method marker."),
        }, "input_handler_mouse_angle"
    )
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
