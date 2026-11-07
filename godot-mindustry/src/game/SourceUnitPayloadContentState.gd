extends RefCounted
class_name SourceUnitPayloadContentState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")
const SOURCE_UNIT_PAYLOAD_GENERATED_CLASS := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_GENERATED_CLASS

static func _unit_payload_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_GENERATED_CLASS, generated_method, generated_args, null)

const SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_METHOD
const SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_JAVA_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_JAVA_METHOD
const SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_GENERATED_OWNER := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_GENERATED_OWNER
const SOURCE_UNIT_PAYLOAD_UPDATE_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_UPDATE_METHOD
const SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR
const SOURCE_UNIT_PAYLOAD_UPDATE_JAVA_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_UPDATE_JAVA_METHOD
const SOURCE_UNIT_PAYLOAD_UPDATE_GENERATED_OWNER := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_UPDATE_GENERATED_OWNER
const SOURCE_UNIT_PAYLOAD_CONTENT_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_METHOD
const SOURCE_UNIT_PAYLOAD_CONTENT_RETURN_EXPR := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_RETURN_EXPR
const SOURCE_UNIT_PAYLOAD_CONTENT_JAVA_METHOD := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_JAVA_METHOD
const SOURCE_UNIT_PAYLOAD_CONTENT_GENERATED_OWNER := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_CONTENT_GENERATED_OWNER

static func content_equals_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	var content_equals: bool = other_is_unit_payload and other_unit_type == unit_type
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR,
		"other_is_unit_payload": other_is_unit_payload,
		"other_unit_type": other_unit_type,
		"unit_type": unit_type,
		"content_equals": content_equals,
	}

static func generated_content_equals_bridge_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	var result = _unit_payload_call(SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_JAVA_METHOD, [other_is_unit_payload, other_unit_type, unit_type])
	var canonical = content_equals_state(other_is_unit_payload, other_unit_type, unit_type)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func update_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var update_payload_called: bool = true
	var update_payload_call: Dictionary = {"call": SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_UPDATE_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_UPDATE_METHOD,
		"update_payload_expr": SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR,
		"unit_type": unit_type,
		"unit": unit,
		"unitHolder": unit_holder,
		"buildingHolder": building_holder,
		"update_payload_called": update_payload_called,
		"update_payload_call": update_payload_call,
	}

static func generated_update_bridge_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var result = _unit_payload_call(SOURCE_UNIT_PAYLOAD_UPDATE_JAVA_METHOD, [unit_type, unit, unit_holder, building_holder])
	var canonical = update_state(unit_type, unit, unit_holder, building_holder)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_UPDATE_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_UPDATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func content_state(unit_type: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_CONTENT_STATE,
		"source": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": source_unit_payload_basic_state.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_CONTENT_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_CONTENT_RETURN_EXPR,
		"unit_type": unit_type,
		"content": unit_type,
	}

static func generated_content_bridge_state(unit_type: Variant) -> Dictionary:
	var result = _unit_payload_call(SOURCE_UNIT_PAYLOAD_CONTENT_JAVA_METHOD, [unit_type])
	var canonical = content_state(unit_type)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_CONTENT_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_CONTENT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
