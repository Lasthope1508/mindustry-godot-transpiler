extends RefCounted
class_name SourceBuildingControlState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func control_enabled_state(current_enabled: bool, control_type: String, p1: float, source_float_rounding_error: float) -> Dictionary:
	var next_enabled: bool = current_enabled
	if control_type == "enabled":
		next_enabled = not absf(p1) <= source_float_rounding_error
	return {"enabled": next_enabled}

static func generated_control_enabled_bridge_state(current_enabled: bool, control_type: String, p1: float, source_float_rounding_error: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_control_209", [current_enabled, control_type, p1], null)
	var canonical = control_enabled_state(current_enabled, control_type, p1, source_float_rounding_error)
	return {
		"source_owner": "PortGame.source_building_control_enabled_state",
		"generated_owner": "BuildingComp.java_method_control_209",
		"result": result,
		"canonical": canonical,
	}

static func control_config_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	if control_type == "config" and block_logic_configurable and not p1_is_logic_build:
		return {"configured_called": true, "builder": null, "value": p1_value}
	return {"configured_called": false, "builder": null, "value": null}

static func generated_control_config_bridge_state(control_type: String, block_logic_configurable: bool, p1_is_logic_build: bool, p1_value: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_control_210", [control_type, block_logic_configurable, p1_is_logic_build, p1_value], null)
	var canonical = control_config_state(control_type, block_logic_configurable, p1_is_logic_build, p1_value)
	return {
		"source_owner": "PortGame.source_building_control_config_state",
		"generated_owner": "BuildingComp.java_method_control_210",
		"result": result,
		"canonical": canonical,
	}
