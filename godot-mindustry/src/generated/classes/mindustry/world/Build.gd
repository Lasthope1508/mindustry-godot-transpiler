# Generated from Mindustry upstream.
# Source: mindustry/world/Build.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "Build"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tmp", "type": "IntSet"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "beginBreak", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "beginPlace", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "result", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "placeConfig", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "validPlace", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "validPlace", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "checkVisible", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "validPlace", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "checkVisible", "type": "boolean", "varargs": false}, {"name": "checkCoreRadius", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "checkNoUnitOverlap", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "validPlaceIgnoreUnits", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "checkVisible", "type": "boolean", "varargs": false}, {"name": "checkCoreRadius", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "getEnemyOverlap", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public", "static"], "name": "contactsGround", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "contactsShallows", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "validBreak", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
const source_building_destruction_state := preload("res://src/game/SourceBuildingDestructionState.gd")

func java_method_beginBreak_0(_args: Array = []) -> Variant:
	var valid_break: bool = bool(_args[0] if _args.size() > 0 else false)
	var tile_has_building: bool = bool(_args[1] if _args.size() > 1 else false)
	var prev_healthf: float = float(_args[2] if _args.size() > 2 else 1.0)
	var previous_rotation: int = int(_args[3] if _args.size() > 3 else 0)
	var previous_instant_deconstruct: bool = bool(_args[4] if _args.size() > 4 else false)
	var previous_size: int = int(_args[5] if _args.size() > 5 else 1)
	var unit_has_controller_name: bool = bool(_args[6] if _args.size() > 6 else false)
	var controller_name: String = str(_args[7] if _args.size() > 7 else "")
	return source_building_destruction_state.begin_break_state(valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name)

func java_method_beginPlace_1(_args: Array = []) -> Variant:
	return null

func java_method_validPlace_2(_args: Array = []) -> Variant:
	return null

func java_method_validPlace_3(_args: Array = []) -> Variant:
	return null

func java_method_validPlace_4(_args: Array = []) -> Variant:
	return null

func java_method_checkNoUnitOverlap_5(_args: Array = []) -> Variant:
	return null

func java_method_validPlaceIgnoreUnits_6(_args: Array = []) -> Variant:
	return null

func java_method_getEnemyOverlap_7(_args: Array = []) -> Variant:
	return null

func java_method_contactsGround_8(_args: Array = []) -> Variant:
	return null

func java_method_contactsShallows_9(_args: Array = []) -> Variant:
	return null

func java_method_validBreak_10(_args: Array = []) -> Variant:
	return null
