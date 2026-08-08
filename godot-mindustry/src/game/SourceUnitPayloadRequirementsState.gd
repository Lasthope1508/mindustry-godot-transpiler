extends RefCounted
class_name SourceUnitPayloadRequirementsState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")

const SOURCE_UNIT_PAYLOAD_GENERATED_CLASS := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_GENERATED_CLASS
const SOURCE_UNIT_PAYLOAD_REQUIREMENTS_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_REQUIREMENTS_METHOD
const SOURCE_UNIT_PAYLOAD_REQUIREMENTS_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_REQUIREMENTS_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_REQUIREMENTS_CALL_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_REQUIREMENTS_CALL_EXPR
const SOURCE_UNIT_PAYLOAD_BUILD_TIME_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_BUILD_TIME_METHOD
const SOURCE_UNIT_PAYLOAD_BUILD_TIME_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_BUILD_TIME_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_BUILD_TIME_CALL_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_BUILD_TIME_CALL_EXPR

static func _unit_payload_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_GENERATED_CLASS, generated_method, generated_args, null)

static func requirements_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	var get_total_requirements_call: Dictionary = {"call": SOURCE_UNIT_PAYLOAD_REQUIREMENTS_CALL_EXPR, "unit_type": unit_type, "requirements": total_requirements}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_REQUIREMENTS_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_REQUIREMENTS_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_REQUIREMENTS_RETURN_EXPR,
		"unit_type": unit_type,
		"requirements": total_requirements,
		"get_total_requirements_call": get_total_requirements_call,
	}

static func generated_requirements_bridge_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	var result = _unit_payload_call("java_method_requirements_5", [unit_type, total_requirements])
	var canonical = requirements_state(unit_type, total_requirements)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_REQUIREMENTS_STATE,
		"generated_owner": "unit_payload.java_method_requirements_5",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func build_time_state(unit_type: Variant, build_time: float) -> Dictionary:
	var get_build_time_call: Dictionary = {"call": SOURCE_UNIT_PAYLOAD_BUILD_TIME_CALL_EXPR, "unit_type": unit_type, "buildTime": build_time}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_BUILD_TIME_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_BUILD_TIME_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_BUILD_TIME_RETURN_EXPR,
		"unit_type": unit_type,
		"buildTime": build_time,
		"get_build_time_call": get_build_time_call,
	}

static func generated_build_time_bridge_state(unit_type: Variant, build_time: float) -> Dictionary:
	var result = _unit_payload_call("java_method_buildTime_6", [unit_type, build_time])
	var canonical = build_time_state(unit_type, build_time)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_BUILD_TIME_STATE,
		"generated_owner": "unit_payload.java_method_buildTime_6",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
