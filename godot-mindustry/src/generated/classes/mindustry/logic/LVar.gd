# Generated from Mindustry upstream.
# Source: mindustry/logic/LVar.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LVar"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "name", "type": "String"}, {"modifiers": ["public"], "name": "id", "type": "int"}, {"modifiers": ["public"], "name": "isobj", "type": "boolean"}, {"modifiers": ["public"], "name": "constant", "type": "boolean"}, {"modifiers": ["public"], "name": "objval", "type": "Object"}, {"modifiers": ["public"], "name": "numval", "type": "double"}, {"modifiers": ["public"], "name": "syncTime", "type": "long"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LVar", "parameters": [{"name": "name", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "LVar", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "id", "type": "int", "varargs": false}]}, {"modifiers": ["public"], "name": "LVar", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "id", "type": "int", "varargs": false}, {"name": "constant", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "building", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "obj", "parameters": [], "return_type": "Object"}, {"modifiers": ["public"], "name": "team", "parameters": [], "return_type": "Team"}, {"modifiers": ["public"], "name": "bool", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "num", "parameters": [], "return_type": "double"}, {"modifiers": ["public"], "name": "numOrNan", "parameters": [], "return_type": "double"}, {"modifiers": ["public"], "name": "numf", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "numfWorld", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "numfOrNan", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "numi", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "setbool", "parameters": [{"name": "value", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setnum", "parameters": [{"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setobj", "parameters": [{"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setconst", "parameters": [{"name": "value", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "other", "type": "LVar", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "invalid", "parameters": [{"name": "d", "type": "double", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_building_0(_args: Array = []) -> Variant:
	return null

func java_method_obj_1(_args: Array = []) -> Variant:
	return null

func java_method_team_2(_args: Array = []) -> Variant:
	return null

func java_method_bool_3(_args: Array = []) -> Variant:
	return null

func java_method_num_4(_args: Array = []) -> Variant:
	return null

func java_method_numOrNan_5(_args: Array = []) -> Variant:
	return null

func java_method_numf_6(_args: Array = []) -> Variant:
	return null

func java_method_numfWorld_7(_args: Array = []) -> Variant:
	return null

func java_method_numfOrNan_8(_args: Array = []) -> Variant:
	return null

func java_method_numi_9(_args: Array = []) -> Variant:
	return null

func java_method_setbool_10(_args: Array = []) -> Variant:
	return null

func java_method_setnum_11(_args: Array = []) -> Variant:
	return null

func java_method_setobj_12(_args: Array = []) -> Variant:
	return null

func java_method_setconst_13(_args: Array = []) -> Variant:
	return null

func java_method_set_14(_args: Array = []) -> Variant:
	return null

func java_method_invalid_15(_args: Array = []) -> Variant:
	return null

func java_method_toString_16(_args: Array = []) -> Variant:
	return null
