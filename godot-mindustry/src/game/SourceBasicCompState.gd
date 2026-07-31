extends RefCounted
class_name SourceBasicCompState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func pos_set_state(x_value: float, y_value: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POS_SET_STATE, "method": "void set(float x, float y){", "x_assign_expr": "this.x = x;", "y_assign_expr": "this.y = y;", "x": x_value, "y": y_value}

static func shielder_absorb_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SHIELDER_ABSORB_STATE, "method": "void absorb(){", "empty_body": "void absorb(){\n\n    }", "no_op": true}

static func generated_pos_set_bridge_state(x_value: float, y_value: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/PosComp.gd", "java_method_set_0", [x_value, y_value], null)
	var canonical = pos_set_state(x_value, y_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POS_SET_STATE,
		"generated_owner": "pos_comp.java_method_set_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("x", null) == canonical.get("x", null) and result.get("y", null) == canonical.get("y", null),
	}

static func generated_shielder_absorb_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/ShielderComp.gd", "java_method_absorb_0", [], null)
	var canonical = shielder_absorb_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SHIELDER_ABSORB_STATE,
		"generated_owner": "shielder_comp.java_method_absorb_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}
