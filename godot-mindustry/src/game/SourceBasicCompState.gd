extends RefCounted
class_name SourceBasicCompState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func pos_set_state(x_value: float, y_value: float) -> Dictionary:
	return {"source_owner": "PortGame.source_pos_set_state", "method": "void set(float x, float y){", "x_assign_expr": "this.x = x;", "y_assign_expr": "this.y = y;", "x": x_value, "y": y_value}

static func shielder_absorb_state() -> Dictionary:
	return {"source_owner": "PortGame.source_shielder_absorb_state", "method": "void absorb(){", "empty_body": "void absorb(){\n\n    }", "no_op": true}

static func generated_pos_set_bridge_state(x_value: float, y_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/PosComp.gd", "java_method_set_0", [x_value, y_value], null)
	var canonical = pos_set_state(x_value, y_value)
	return {
		"source_owner": "PortGame.source_pos_set_state",
		"generated_owner": "PosComp.java_method_set_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("x", null) == canonical.get("x", null) and result.get("y", null) == canonical.get("y", null),
	}

static func generated_shielder_absorb_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/ShielderComp.gd", "java_method_absorb_0", [], null)
	var canonical = shielder_absorb_state()
	return {
		"source_owner": "PortGame.source_shielder_absorb_state",
		"generated_owner": "ShielderComp.java_method_absorb_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}
