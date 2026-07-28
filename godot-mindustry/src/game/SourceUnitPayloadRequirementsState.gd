extends RefCounted
class_name SourceUnitPayloadRequirementsState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceUnitPayloadBasicState := preload("res://src/game/SourceUnitPayloadBasicState.gd")

const SOURCE_UNIT_PAYLOAD_REQUIREMENTS_METHOD := "public ItemStack[] requirements(){"
const SOURCE_UNIT_PAYLOAD_REQUIREMENTS_RETURN_EXPR := "return unit.type.getTotalRequirements();"
const SOURCE_UNIT_PAYLOAD_REQUIREMENTS_CALL_EXPR := "unit.type.getTotalRequirements();"
const SOURCE_UNIT_PAYLOAD_BUILD_TIME_METHOD := "public float buildTime(){"
const SOURCE_UNIT_PAYLOAD_BUILD_TIME_RETURN_EXPR := "return unit.type.getBuildTime();"
const SOURCE_UNIT_PAYLOAD_BUILD_TIME_CALL_EXPR := "unit.type.getBuildTime();"

static func requirements_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	var get_total_requirements_call: Dictionary = {"call": SOURCE_UNIT_PAYLOAD_REQUIREMENTS_CALL_EXPR, "unit_type": unit_type, "requirements": total_requirements}
	return {
		"source_owner": "PortGame.source_unit_payload_requirements_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_REQUIREMENTS_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_REQUIREMENTS_RETURN_EXPR,
		"unit_type": unit_type,
		"requirements": total_requirements,
		"get_total_requirements_call": get_total_requirements_call,
	}

static func generated_requirements_bridge_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_requirements_5", [unit_type, total_requirements], null)
	var canonical = requirements_state(unit_type, total_requirements)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_requirements_state",
		"generated_owner": "UnitPayload.java_method_requirements_5",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func build_time_state(unit_type: Variant, build_time: float) -> Dictionary:
	var get_build_time_call: Dictionary = {"call": SOURCE_UNIT_PAYLOAD_BUILD_TIME_CALL_EXPR, "unit_type": unit_type, "buildTime": build_time}
	return {
		"source_owner": "PortGame.source_unit_payload_build_time_state",
		"source": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_SOURCE,
		"class_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_CLASS_EXPR,
		"field_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_UNIT_FIELD_EXPR,
		"override_expr": SourceUnitPayloadBasicState.SOURCE_UNIT_PAYLOAD_OVERRIDE_EXPR,
		"method": SOURCE_UNIT_PAYLOAD_BUILD_TIME_METHOD,
		"return_expr": SOURCE_UNIT_PAYLOAD_BUILD_TIME_RETURN_EXPR,
		"unit_type": unit_type,
		"buildTime": build_time,
		"get_build_time_call": get_build_time_call,
	}

static func generated_build_time_bridge_state(unit_type: Variant, build_time: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/UnitPayload.gd", "java_method_buildTime_6", [unit_type, build_time], null)
	var canonical = build_time_state(unit_type, build_time)
	var matches: bool = SourceGeneratedClassRuntime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": "PortGame.source_unit_payload_build_time_state",
		"generated_owner": "UnitPayload.java_method_buildTime_6",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
