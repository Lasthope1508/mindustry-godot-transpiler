extends RefCounted
class_name SourceBuildingMetaState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_meta_source_text_state := preload("res://src/game/SourceBuildingMetaSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS

const SOURCE_BUILDING_CURSOR_JAVA_METHOD := source_building_meta_source_text_state.SOURCE_BUILDING_CURSOR_JAVA_METHOD
const SOURCE_BUILDING_CURSOR_GENERATED_OWNER := source_building_meta_source_text_state.SOURCE_BUILDING_CURSOR_GENERATED_OWNER
const SOURCE_BUILDING_HEALTH_CHANGED_JAVA_METHOD := source_building_meta_source_text_state.SOURCE_BUILDING_HEALTH_CHANGED_JAVA_METHOD
const SOURCE_BUILDING_HEALTH_CHANGED_GENERATED_OWNER := source_building_meta_source_text_state.SOURCE_BUILDING_HEALTH_CHANGED_GENERATED_OWNER
const SOURCE_BUILDING_TO_STRING_JAVA_METHOD := source_building_meta_source_text_state.SOURCE_BUILDING_TO_STRING_JAVA_METHOD
const SOURCE_BUILDING_TO_STRING_GENERATED_OWNER := source_building_meta_source_text_state.SOURCE_BUILDING_TO_STRING_GENERATED_OWNER
const SOURCE_BUILDING_HEALTH_CHANGED_METHOD := source_building_meta_source_text_state.SOURCE_BUILDING_HEALTH_CHANGED_METHOD
const SOURCE_BUILDING_TO_STRING_OVERRIDE := source_building_meta_source_text_state.SOURCE_BUILDING_TO_STRING_OVERRIDE
const SOURCE_BUILDING_TO_STRING_REPLACE := source_building_meta_source_text_state.SOURCE_BUILDING_TO_STRING_REPLACE
const SOURCE_BUILDING_TO_STRING_METHOD := source_building_meta_source_text_state.SOURCE_BUILDING_TO_STRING_METHOD
const SOURCE_BUILDING_TO_STRING_RETURN := source_building_meta_source_text_state.SOURCE_BUILDING_TO_STRING_RETURN

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func cursor_state(block_configurable: bool, interactable_player_team: bool) -> String:
	return "hand" if block_configurable and interactable_player_team else "arrow"

static func generated_cursor_bridge_state(block_configurable: bool, interactable_player_team: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CURSOR_JAVA_METHOD, [block_configurable, interactable_player_team])
	var canonical = cursor_state(block_configurable, interactable_player_team)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CURSOR_STATE,
		"generated_owner": SOURCE_BUILDING_CURSOR_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func health_changed_state(net_server: bool, self_state := {}) -> Dictionary:
	var build_health_update = self_state
	if not net_server:
		build_health_update = null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEALTH_CHANGED_STATE, "method": SOURCE_BUILDING_HEALTH_CHANGED_METHOD, "build_health_update_called": net_server, "build_health_update": build_health_update, "notify_health_changed": self_state}

static func generated_health_changed_bridge_state(net_server: bool, self_state := {}) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_HEALTH_CHANGED_JAVA_METHOD, [net_server, self_state])
	var canonical = health_changed_state(net_server, self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEALTH_CHANGED_STATE,
		"generated_owner": SOURCE_BUILDING_HEALTH_CHANGED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func to_string_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> String:
	return "Building#" + str(id_value) + "[" + str(tile_x_value) + "," + str(tile_y_value) + "]:" + str(block_value)

static func generated_to_string_bridge_state(id_value: int, tile_x_value: int, tile_y_value: int, block_value: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TO_STRING_JAVA_METHOD, [id_value, tile_x_value, tile_y_value, block_value])
	var canonical = to_string_state(id_value, tile_x_value, tile_y_value, block_value)
	var generated_to_string = result.get("to_string", "") if result is Dictionary else str(result)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TO_STRING_STATE,
		"generated_owner": SOURCE_BUILDING_TO_STRING_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"generated_to_string": generated_to_string,
		"matches": generated_to_string == canonical,
	}
