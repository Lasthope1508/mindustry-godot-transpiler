# Generated from Mindustry upstream.
# Source: mindustry/game/Team.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "Team"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable", "Senseable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "id", "type": "int"}, {"modifiers": ["final", "public"], "name": "color", "type": "Color"}, {"modifiers": ["final", "public"], "name": "palette", "type": "Color"}, {"modifiers": ["final", "public"], "name": "palettei", "type": "int"}, {"modifiers": ["public"], "name": "ignoreUnitCap", "type": "boolean"}, {"modifiers": ["public"], "name": "emoji", "type": "String"}, {"modifiers": ["public"], "name": "hasPalette", "type": "boolean"}, {"modifiers": ["public"], "name": "name", "type": "String"}, {"modifiers": ["final", "public", "static"], "name": "all", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "baseTeams", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "derelict", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "sharded", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "crux", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "malis", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "green", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "blue", "type": "Team"}, {"modifiers": ["final", "public", "static"], "name": "neoplastic", "type": "Team"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["protected"], "name": "Team", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}]}, {"modifiers": ["protected"], "name": "Team", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "pal1", "type": "Color", "varargs": false}, {"name": "pal2", "type": "Color", "varargs": false}, {"name": "pal3", "type": "Color", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "get", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "Team"}, {"modifiers": ["public"], "name": "items", "parameters": [], "return_type": "ItemModule"}, {"modifiers": ["public"], "name": "rules", "parameters": [], "return_type": "TeamRule"}, {"modifiers": ["public"], "name": "data", "parameters": [], "return_type": "TeamData"}, {"modifiers": ["public"], "name": "core", "parameters": [], "return_type": "CoreBuild"}, {"modifiers": ["public"], "name": "active", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isAlive", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isAI", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isOnlyAI", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "needsFlowField", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "activateUnitFactories", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "cores", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "coloredName", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "setPalette", "parameters": [{"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setPalette", "parameters": [{"name": "pal1", "type": "Color", "varargs": false}, {"name": "pal2", "type": "Color", "varargs": false}, {"name": "pal3", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_get_0(_args: Array = []) -> Variant:
	return null

func java_method_items_1(_args: Array = []) -> Variant:
	return null

func java_method_rules_2(_args: Array = []) -> Variant:
	return null

func java_method_data_3(_args: Array = []) -> Variant:
	return null

func java_method_core_4(_args: Array = []) -> Variant:
	return null

func java_method_active_5(_args: Array = []) -> Variant:
	return null

func java_method_isAlive_6(_args: Array = []) -> Variant:
	return null

func java_method_isAI_7(_args: Array = []) -> Variant:
	return null

func java_method_isOnlyAI_8(_args: Array = []) -> Variant:
	return null

func java_method_needsFlowField_9(_args: Array = []) -> Variant:
	return null

func java_method_activateUnitFactories_10(_args: Array = []) -> Variant:
	return null

func java_method_cores_11(_args: Array = []) -> Variant:
	return null

func java_method_localized_12(_args: Array = []) -> Variant:
	return null

func java_method_coloredName_13(_args: Array = []) -> Variant:
	return null

func java_method_setPalette_14(_args: Array = []) -> Variant:
	return null

func java_method_setPalette_15(_args: Array = []) -> Variant:
	return null

func java_method_compareTo_16(_args: Array = []) -> Variant:
	return null

func java_method_toString_17(_args: Array = []) -> Variant:
	return null

func java_method_sense_18(_args: Array = []) -> Variant:
	return null

func java_method_senseObject_19(_args: Array = []) -> Variant:
	return null
