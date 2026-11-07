extends RefCounted
class_name SourceAttributeState

const source_text := preload("res://src/game/SourceAttributeSourceTextState.gd")
const owner_registry := preload("res://src/game/SourceRuntimeOwnerGameplayRegistry.gd")
const generated_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

const GENERATED_SCRIPT := source_text.GENERATED_SCRIPT

static func _base(owner: String, method: String, all_attributes: Array, attribute_map: Dictionary) -> Dictionary:
	return {"source_owner": owner, "source": source_text.SOURCE, "method": method, "all": all_attributes, "map": attribute_map}

static func env_state(state_present: bool, env_value: float) -> Dictionary:
	var value := env_value if state_present else 0.0
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTE_ENV_STATE, source_text.METHOD_ENV, [], {})
	result["state_present"] = state_present
	result["env_value"] = env_value
	result["value"] = value
	result["guard_expr"] = source_text.ENV_GUARD
	return result

static func to_string_state(attribute: Dictionary) -> Dictionary:
	var name := str(attribute.get("name", ""))
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTE_TO_STRING_STATE, source_text.METHOD_TO_STRING, [], {})
	result["attribute"] = attribute
	result["name"] = name
	result["value"] = name
	result["return_expr"] = "return name;"
	return result

static func get_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	var found: Variant = attribute_map.get(name, null)
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTE_GET_STATE, source_text.METHOD_GET, all_attributes, attribute_map)
	result["name"] = name
	result["found"] = found
	result["exists"] = found != null
	result["throw_if_missing"] = found == null
	result["throw_expr"] = source_text.GET_THROW
	return result

static func get_or_null_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	var found: Variant = attribute_map.get(name, null)
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTE_GET_OR_NULL_STATE, source_text.METHOD_GET_OR_NULL, all_attributes, attribute_map)
	result["name"] = name
	result["value"] = found
	result["found"] = found != null
	result["return_expr"] = "return map.get(name);"
	return result

static func exists_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTE_EXISTS_STATE, source_text.METHOD_EXISTS, all_attributes, attribute_map)
	result["name"] = name
	result["exists"] = attribute_map.has(name)
	result["return_expr"] = "return map.containsKey(name);"
	return result

static func add_state(all_attributes: Array, attribute_map: Dictionary, name: String) -> Dictionary:
	var result_all := all_attributes.duplicate(true)
	var result_map := attribute_map.duplicate(true)
	var attribute := {"id": result_all.size(), "name": name}
	result_all.append(attribute)
	result_map[name] = attribute
	var result := _base(owner_registry.PORT_GAME_SOURCE_ATTRIBUTE_ADD_STATE, source_text.METHOD_ADD, result_all, result_map)
	result["name"] = name
	result["attribute"] = attribute
	result["previous_all"] = all_attributes
	result["previous_map"] = attribute_map
	result["id_expr"] = source_text.ADD_ID
	result["map_expr"] = source_text.ADD_MAP
	return result

static func generated_bridge(method: String, args: Array, canonical: Dictionary) -> Dictionary:
	var result = generated_runtime.call_java_method(GENERATED_SCRIPT, method, args)
	return {"result": result, "canonical": canonical, "matches": generated_runtime.generated_state_matches_canonical_subset(result, canonical)}
