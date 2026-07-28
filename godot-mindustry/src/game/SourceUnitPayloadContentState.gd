extends RefCounted
class_name SourceUnitPayloadContentState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceUnitPayloadBasicState := preload("res://src/game/SourceUnitPayloadBasicState.gd")

const SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_METHOD := "public boolean contentEquals(Payload other){"
const SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR := "return other instanceof UnitPayload up && up.unit.type == unit.type;"
const SOURCE_UNIT_PAYLOAD_UPDATE_METHOD := "public void update(@Nullable Unit unitHolder, @Nullable Building buildingHolder){"
const SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR := "unit.type.updatePayload(unit, unitHolder, buildingHolder);"
const SOURCE_UNIT_PAYLOAD_CONTENT_METHOD := "public UnlockableContent content(){"
const SOURCE_UNIT_PAYLOAD_CONTENT_RETURN_EXPR := "return unit.type;"

static func content_equals_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	var content_equals: bool = other_is_unit_payload and other_unit_type == unit_type
	return {
		"source_owner": "PortGame.source_unit_payload_content_equals_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_CONTENT_EQUALS_RETURN_EXPR,
		"other_is_unit_payload": other_is_unit_payload,
		"other_unit_type": other_unit_type,
		"unit_type": unit_type,
		"content_equals": content_equals,
	}

static func generated_content_equals_bridge_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_contentEquals_2", [other_is_unit_payload, other_unit_type, unit_type], null)
	var canonical = content_equals_state(other_is_unit_payload, other_unit_type, unit_type)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_content_equals_state",
		"generated_owner": "UnitPayload.java_method_contentEquals_2",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func update_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var update_payload_called: bool = true
	var update_payload_call: Dictionary = {"call": SOURCE_UNIT_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unit_type": unit_type, "unit": unit, "unitHolder": unit_holder, "buildingHolder": building_holder}
	return {
		"source_owner": "PortGame.source_unit_payload_update_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
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
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_update_3", [unit_type, unit, unit_holder, building_holder], null)
	var canonical = update_state(unit_type, unit, unit_holder, building_holder)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_update_state",
		"generated_owner": "UnitPayload.java_method_update_3",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func content_state(unit_type: Variant) -> Dictionary:
	return {
		"source_owner": "PortGame.source_unit_payload_content_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_CONTENT_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_CONTENT_RETURN_EXPR,
		"unit_type": unit_type,
		"content": unit_type,
	}

static func generated_content_bridge_state(unit_type: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_content_4", [unit_type], null)
	var canonical = content_state(unit_type)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_content_state",
		"generated_owner": "UnitPayload.java_method_content_4",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
