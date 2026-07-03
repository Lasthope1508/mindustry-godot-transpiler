# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/BuilderComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "BuilderComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Statusc", "Teamc", "Rotc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "buildSpeedMultiplier", "type": "float"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "plans", "type": "Queue"}, {"modifiers": [], "name": "updateBuilding", "type": "boolean"}, {"modifiers": ["private", "transient"], "name": "buildCounter", "type": "float"}, {"modifiers": ["private", "transient"], "name": "lastActive", "type": "BuildPlan"}, {"modifiers": ["private", "transient"], "name": "lastSize", "type": "int"}, {"modifiers": ["transient"], "name": "buildAlpha", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "canBuild", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterRead", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "validatePlans", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateBuildLogic", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "drawPlanTop", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "shouldSkip", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "core", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "removeBuild", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "breaking", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "isBuilding", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "clearBuilding", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addBuild", "parameters": [{"name": "place", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "addBuild", "parameters": [{"name": "place", "type": "BuildPlan", "varargs": false}, {"name": "tail", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "activelyBuilding", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "buildPlan", "parameters": [], "return_type": "BuildPlan"}, {"modifiers": ["public"], "name": "drawBuilding", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawBuildingBeam", "parameters": [{"name": "px", "type": "float", "varargs": false}, {"name": "py", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_canBuild_0(_args: Array = []) -> Variant:
	var type_build_speed: float = float(_args[0] if _args.size() > 0 else 0.0)
	var build_speed_multiplier: float = float(_args[1] if _args.size() > 1 else 0.0)
	var type_build_speed_positive: bool = type_build_speed > 0
	var build_speed_multiplier_positive: bool = build_speed_multiplier > 0
	var can_build: bool = type_build_speed_positive and build_speed_multiplier_positive
	return {"source_owner": "PortGame.source_builder_can_build_state", "method": "public boolean canBuild(){", "return_expr": "return type.buildSpeed > 0 && buildSpeedMultiplier > 0;", "type_build_speed": type_build_speed, "build_speed_multiplier": build_speed_multiplier, "type_build_speed_positive": type_build_speed_positive, "build_speed_multiplier_positive": build_speed_multiplier_positive, "can_build": can_build}

func java_method_update_1(_args: Array = []) -> Variant:
	var update_build_logic_call: String = "updateBuildLogic();"
	var update_build_logic_called: bool = true
	return {"source_owner": "PortGame.source_builder_update_state", "method": "public void update(){", "update_build_logic_call": update_build_logic_call, "update_build_logic_called": update_build_logic_called}

func java_method_afterRead_2(_args: Array = []) -> Variant:
	return null

func java_method_validatePlans_3(_args: Array = []) -> Variant:
	return null

func java_method_updateBuildLogic_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_5(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanTop_6(_args: Array = []) -> Variant:
	return null

func java_method_shouldSkip_7(_args: Array = []) -> Variant:
	return null

func java_method_removeBuild_8(_args: Array = []) -> Variant:
	return null

func java_method_isBuilding_9(_args: Array = []) -> Variant:
	return null

func java_method_clearBuilding_10(_args: Array = []) -> Variant:
	return null

func java_method_addBuild_11(_args: Array = []) -> Variant:
	return null

func java_method_addBuild_12(_args: Array = []) -> Variant:
	return null

func java_method_activelyBuilding_13(_args: Array = []) -> Variant:
	return null

func java_method_buildPlan_14(_args: Array = []) -> Variant:
	return null

func java_method_drawBuilding_15(_args: Array = []) -> Variant:
	return null

func java_method_drawBuildingBeam_16(_args: Array = []) -> Variant:
	return null
