extends RefCounted
class_name SourceBasicCompState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_entity_comp_source_text_state := preload("res://src/game/SourceEntityCompSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_POS_COMP_GENERATED_CLASS := source_entity_comp_source_text_state.SOURCE_POS_COMP_GENERATED_CLASS
const SOURCE_SHIELDER_COMP_GENERATED_CLASS := source_entity_comp_source_text_state.SOURCE_SHIELDER_COMP_GENERATED_CLASS
const SOURCE_POS_COMP_SET_METHOD := source_entity_comp_source_text_state.SOURCE_POS_COMP_SET_METHOD
const SOURCE_POS_COMP_SET_X_ASSIGN_EXPR := source_entity_comp_source_text_state.SOURCE_POS_COMP_SET_X_ASSIGN_EXPR
const SOURCE_POS_COMP_SET_Y_ASSIGN_EXPR := source_entity_comp_source_text_state.SOURCE_POS_COMP_SET_Y_ASSIGN_EXPR
const SOURCE_POS_COMP_SET_JAVA_METHOD := source_entity_comp_source_text_state.SOURCE_POS_COMP_SET_JAVA_METHOD
const SOURCE_POS_COMP_SET_GENERATED_OWNER := source_entity_comp_source_text_state.SOURCE_POS_COMP_SET_GENERATED_OWNER
const SOURCE_SHIELDER_COMP_ABSORB_METHOD := source_entity_comp_source_text_state.SOURCE_SHIELDER_COMP_ABSORB_METHOD
const SOURCE_SHIELDER_COMP_ABSORB_EMPTY_BODY := source_entity_comp_source_text_state.SOURCE_SHIELDER_COMP_ABSORB_EMPTY_BODY
const SOURCE_SHIELDER_COMP_ABSORB_JAVA_METHOD := source_entity_comp_source_text_state.SOURCE_SHIELDER_COMP_ABSORB_JAVA_METHOD
const SOURCE_SHIELDER_COMP_ABSORB_GENERATED_OWNER := source_entity_comp_source_text_state.SOURCE_SHIELDER_COMP_ABSORB_GENERATED_OWNER

static func _pos_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_POS_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func _shielder_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_SHIELDER_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func pos_set_state(x_value: float, y_value: float) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POS_SET_STATE, "method": SOURCE_POS_COMP_SET_METHOD, "x_assign_expr": SOURCE_POS_COMP_SET_X_ASSIGN_EXPR, "y_assign_expr": SOURCE_POS_COMP_SET_Y_ASSIGN_EXPR, "x": x_value, "y": y_value}

static func shielder_absorb_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SHIELDER_ABSORB_STATE, "method": SOURCE_SHIELDER_COMP_ABSORB_METHOD, "empty_body": SOURCE_SHIELDER_COMP_ABSORB_EMPTY_BODY, "no_op": true}

static func generated_pos_set_bridge_state(x_value: float, y_value: float) -> Dictionary:
	var result = _pos_comp_call(SOURCE_POS_COMP_SET_JAVA_METHOD, [x_value, y_value])
	var canonical = pos_set_state(x_value, y_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POS_SET_STATE,
		"generated_owner": SOURCE_POS_COMP_SET_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("x", null) == canonical.get("x", null) and result.get("y", null) == canonical.get("y", null),
	}

static func generated_shielder_absorb_bridge_state() -> Dictionary:
	var result = _shielder_comp_call(SOURCE_SHIELDER_COMP_ABSORB_JAVA_METHOD, [])
	var canonical = shielder_absorb_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SHIELDER_ABSORB_STATE,
		"generated_owner": SOURCE_SHIELDER_COMP_ABSORB_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}
