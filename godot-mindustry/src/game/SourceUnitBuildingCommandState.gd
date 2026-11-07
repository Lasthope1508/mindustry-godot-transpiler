extends RefCounted
class_name SourceUnitBuildingCommandState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_text := preload("res://src/game/SourceUnitBuildingCommandSourceTextState.gd")

static func _generated_class(class_name_value: String) -> String:
	return "res://src/generated/classes/mindustry/world/blocks/units/%s.gd" % class_name_value

static func _inner_class(class_name_value: String) -> String:
	return str(source_text.SOURCE_UNIT_BUILDING_INNER_CLASS_DECLARATIONS.get(class_name_value, ""))

static func command_position_state(class_name_value: String, source_path: String, command_position: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_BUILDING_GET_COMMAND_POSITION_STATE,
		"source": source_path,
		"inner_class": _inner_class(class_name_value),
		"method": source_text.SOURCE_UNIT_BUILDING_COMMAND_POSITION_METHOD,
		"return_expr": source_text.SOURCE_UNIT_BUILDING_COMMAND_POSITION_RETURN_EXPR,
		"command_position": command_position,
	}

static func on_command_state(class_name_value: String, source_path: String, target: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_BUILDING_ON_COMMAND_STATE,
		"source": source_path,
		"inner_class": _inner_class(class_name_value),
		"method": source_text.SOURCE_UNIT_BUILDING_ON_COMMAND_METHOD,
		"assignment_expr": source_text.SOURCE_UNIT_BUILDING_ON_COMMAND_ASSIGNMENT_EXPR,
		"target": target,
		"command_position": target,
	}

static func generated_command_position_bridge_state(class_name_value: String, source_path: String, command_position: Variant) -> Dictionary:
	var generated_method: String = str(source_text.SOURCE_UNIT_BUILDING_COMMAND_POSITION_GENERATED_METHODS.get(class_name_value, ""))
	var result = source_generated_class_runtime.call_java_method(_generated_class(class_name_value), generated_method, [command_position], null)
	var canonical := command_position_state(class_name_value, source_path, command_position)
	return {"source_owner": canonical["source_owner"], "generated_owner": "%s.%sBuild.getCommandPosition" % [class_name_value, class_name_value], "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_on_command_bridge_state(class_name_value: String, source_path: String, target: Variant) -> Dictionary:
	var generated_method: String = str(source_text.SOURCE_UNIT_BUILDING_ON_COMMAND_GENERATED_METHODS.get(class_name_value, ""))
	var result = source_generated_class_runtime.call_java_method(_generated_class(class_name_value), generated_method, [target], null)
	var canonical := on_command_state(class_name_value, source_path, target)
	return {"source_owner": canonical["source_owner"], "generated_owner": "%s.%sBuild.onCommand" % [class_name_value, class_name_value], "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}
