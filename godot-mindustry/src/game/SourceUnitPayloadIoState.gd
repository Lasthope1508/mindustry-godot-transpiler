extends RefCounted
class_name SourceUnitPayloadIoState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")

const SOURCE_UNIT_PAYLOAD_GENERATED_CLASS := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_GENERATED_CLASS

const SOURCE_UNIT_PAYLOAD_WRITE_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_WRITE_METHOD
const SOURCE_UNIT_PAYLOAD_WRITE_PAYLOAD_UNIT_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_WRITE_PAYLOAD_UNIT_EXPR
const SOURCE_UNIT_PAYLOAD_WRITE_CLASS_ID_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_WRITE_CLASS_ID_EXPR
const SOURCE_UNIT_PAYLOAD_WRITE_UNIT_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_WRITE_UNIT_EXPR
const SOURCE_UNIT_PAYLOAD_SET_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SET_METHOD
const SOURCE_UNIT_PAYLOAD_SET_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SET_EXPR
const SOURCE_UNIT_PAYLOAD_SET_ROTATION_ASSIGN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SET_ROTATION_ASSIGN_EXPR
const SOURCE_UNIT_PAYLOAD_X_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_X_METHOD
const SOURCE_UNIT_PAYLOAD_X_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_X_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_Y_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_Y_METHOD
const SOURCE_UNIT_PAYLOAD_Y_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_Y_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_ROTATION_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_ROTATION_METHOD
const SOURCE_UNIT_PAYLOAD_ROTATION_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_ROTATION_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_SIZE_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SIZE_METHOD
const SOURCE_UNIT_PAYLOAD_SIZE_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_SIZE_RETURN_EXPR

static func _unit_payload_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_GENERATED_CLASS, generated_method, generated_args, null)

static func write_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	var write_calls: Array = [
		{"call": SOURCE_UNIT_PAYLOAD_WRITE_PAYLOAD_UNIT_EXPR, "method": "write.b", "value": payload_unit},
		{"call": SOURCE_UNIT_PAYLOAD_WRITE_CLASS_ID_EXPR, "method": "write.b", "value": unit_class_id},
		{"call": SOURCE_UNIT_PAYLOAD_WRITE_UNIT_EXPR, "method": "unit.write", "called": true},
	]
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_WRITE_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_WRITE_METHOD,
		"payload_unit_write_expr": SOURCE_UNIT_PAYLOAD_WRITE_PAYLOAD_UNIT_EXPR,
		"unit_class_id_write_expr": SOURCE_UNIT_PAYLOAD_WRITE_CLASS_ID_EXPR,
		"unit_write_expr": SOURCE_UNIT_PAYLOAD_WRITE_UNIT_EXPR,
		"payload_unit": payload_unit,
		"unit_class_id": unit_class_id,
		"unit_write_called": true,
		"write_calls": write_calls,
	}

static func generated_write_bridge_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	var result = _unit_payload_call("java_method_write_7", [payload_unit, unit_class_id])
	var canonical = write_state(payload_unit, unit_class_id)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_WRITE_STATE,
		"generated_owner": "unit_payload.java_method_write_7",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	var set_call: Dictionary = {"call": SOURCE_UNIT_PAYLOAD_SET_EXPR, "x": x, "y": y}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SET_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_SET_METHOD,
		"set_expr": SOURCE_UNIT_PAYLOAD_SET_EXPR,
		"rotation_assign_expr": SOURCE_UNIT_PAYLOAD_SET_ROTATION_ASSIGN_EXPR,
		"x": x,
		"y": y,
		"rotation": rotation_value,
		"set_called": true,
		"set_call": set_call,
	}

static func generated_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	var result = _unit_payload_call("java_method_set_8", [x, y, rotation_value])
	var canonical = set_state(x, y, rotation_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SET_STATE,
		"generated_owner": "unit_payload.java_method_set_8",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func x_state(unit_x: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_X_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_X_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_X_RETURN_EXPR,
		"unit_x": unit_x,
		"x": unit_x,
	}

static func generated_x_bridge_state(unit_x: float) -> Dictionary:
	var result = _unit_payload_call("java_method_x_9", [unit_x])
	var canonical = x_state(unit_x)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_X_STATE,
		"generated_owner": "unit_payload.java_method_x_9",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func y_state(unit_y: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_Y_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_Y_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_Y_RETURN_EXPR,
		"unit_y": unit_y,
		"y": unit_y,
	}

static func generated_y_bridge_state(unit_y: float) -> Dictionary:
	var result = _unit_payload_call("java_method_y_10", [unit_y])
	var canonical = y_state(unit_y)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_Y_STATE,
		"generated_owner": "unit_payload.java_method_y_10",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func rotation_state(unit_rotation: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_ROTATION_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_ROTATION_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_ROTATION_RETURN_EXPR,
		"unit_rotation": unit_rotation,
		"rotation": unit_rotation,
	}

static func generated_rotation_bridge_state(unit_rotation: float) -> Dictionary:
	var result = _unit_payload_call("java_method_rotation_11", [unit_rotation])
	var canonical = rotation_state(unit_rotation)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_ROTATION_STATE,
		"generated_owner": "unit_payload.java_method_rotation_11",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func size_state(unit_hit_size: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SIZE_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_SIZE_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_SIZE_RETURN_EXPR,
		"unit_hit_size": unit_hit_size,
		"size": unit_hit_size,
	}

static func generated_size_bridge_state(unit_hit_size: float) -> Dictionary:
	var result = _unit_payload_call("java_method_size_12", [unit_hit_size])
	var canonical = size_state(unit_hit_size)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_SIZE_STATE,
		"generated_owner": "unit_payload.java_method_size_12",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
