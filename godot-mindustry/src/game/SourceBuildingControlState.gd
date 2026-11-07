extends RefCounted
class_name SourceBuildingControlState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_CONTROL_ENABLED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONTROL_ENABLED_JAVA_METHOD
const SOURCE_BUILDING_CONTROL_ENABLED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONTROL_ENABLED_GENERATED_OWNER
const SOURCE_BUILDING_CONTROL_CONFIG_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONTROL_CONFIG_JAVA_METHOD
const SOURCE_BUILDING_CONTROL_CONFIG_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONTROL_CONFIG_GENERATED_OWNER
const SOURCE_BUILDING_CAN_CONTROL_SELECT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CAN_CONTROL_SELECT_JAVA_METHOD
const SOURCE_BUILDING_CAN_CONTROL_SELECT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CAN_CONTROL_SELECT_GENERATED_OWNER
const SOURCE_BUILDING_ON_CONTROL_SELECT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_ON_CONTROL_SELECT_JAVA_METHOD
const SOURCE_BUILDING_ON_CONTROL_SELECT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_ON_CONTROL_SELECT_GENERATED_OWNER
const SOURCE_BUILDING_ON_COMMAND_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_ON_COMMAND_JAVA_METHOD
const SOURCE_BUILDING_ON_COMMAND_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_ON_COMMAND_GENERATED_OWNER
const SOURCE_BUILDING_GET_COMMAND_POSITION_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_GET_COMMAND_POSITION_JAVA_METHOD
const SOURCE_BUILDING_GET_COMMAND_POSITION_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_GET_COMMAND_POSITION_GENERATED_OWNER

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func control_enabled_state(current_enabled: bool, control_type: String, p1: float, source_float_rounding_error: float) -> Dictionary:
	var next_enabled: bool = current_enabled
	if control_type == "enabled":
		next_enabled = not absf(p1) <= source_float_rounding_error
	return {"enabled": next_enabled}

static func generated_control_enabled_bridge_state(current_enabled: bool, control_type: String, p1: float, source_float_rounding_error: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONTROL_ENABLED_JAVA_METHOD, [current_enabled, control_type, p1])
	var canonical = control_enabled_state(current_enabled, control_type, p1, source_float_rounding_error)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONTROL_ENABLED_STATE,
		"generated_owner": SOURCE_BUILDING_CONTROL_ENABLED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func control_config_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	if control_type == "config" and block_logic_configurable and not p1_is_logic_build:
		return {"configured_called": true, "builder": null, "value": p1_value}
	return {"configured_called": false, "builder": null, "value": null}

static func generated_control_config_bridge_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONTROL_CONFIG_JAVA_METHOD, [control_type, block_logic_configurable, p1_is_logic_build, p1_value])
	var canonical = control_config_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONTROL_CONFIG_STATE,
		"generated_owner": SOURCE_BUILDING_CONTROL_CONFIG_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func can_control_select_state(_player_state: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_CONTROL_SELECT_STATE, "can_control_select": false}

static func generated_can_control_select_bridge_state(player_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CAN_CONTROL_SELECT_JAVA_METHOD, [player_state])
	var canonical = can_control_select_state(player_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_CONTROL_SELECT_STATE, "generated_owner": SOURCE_BUILDING_CAN_CONTROL_SELECT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func on_control_select_state(player_state: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONTROL_SELECT_STATE, "player": player_state, "handled": false}

static func generated_on_control_select_bridge_state(player_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_ON_CONTROL_SELECT_JAVA_METHOD, [player_state])
	var canonical = on_control_select_state(player_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_CONTROL_SELECT_STATE, "generated_owner": SOURCE_BUILDING_ON_CONTROL_SELECT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func on_command_state(target_state: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_COMMAND_STATE, "target": target_state, "handled": false}

static func generated_on_command_bridge_state(target_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_ON_COMMAND_JAVA_METHOD, [target_state])
	var canonical = on_command_state(target_state)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_COMMAND_STATE, "generated_owner": SOURCE_BUILDING_ON_COMMAND_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func get_command_position_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_GET_COMMAND_POSITION_STATE, "command_position": null}

static func generated_get_command_position_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_GET_COMMAND_POSITION_JAVA_METHOD, [])
	var canonical = get_command_position_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_GET_COMMAND_POSITION_STATE, "generated_owner": SOURCE_BUILDING_GET_COMMAND_POSITION_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
