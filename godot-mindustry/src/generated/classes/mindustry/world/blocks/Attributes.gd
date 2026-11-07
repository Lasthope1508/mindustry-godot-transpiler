# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/Attributes.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks"
const JAVA_KIND := "class"
const JAVA_NAME := "Attributes"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["JsonSerializable"]
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "arr", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "attr", "type": "Attribute", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "attr", "type": "Attribute", "varargs": false}, {"name": "value", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "other", "type": "Attributes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "other", "type": "Attributes", "varargs": false}, {"name": "scl", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "json", "type": "Json", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "json", "type": "Json", "varargs": false}, {"name": "data", "type": "JsonValue", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "check", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
const source_attributes_state := preload("res://src/game/SourceAttributesState.gd")

func java_method_clear_0(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	return source_attributes_state.clear_state(attribute_all, arr)

func java_method_get_1(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var attr_id := int(_args[2] if _args.size() > 2 else -1)
	return source_attributes_state.get_state(attribute_all, arr, attr_id)

func java_method_set_2(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var attr_id := int(_args[2] if _args.size() > 2 else -1)
	var value := float(_args[3] if _args.size() > 3 else 0.0)
	return source_attributes_state.set_state(attribute_all, arr, attr_id, value)

func java_method_add_3(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var other_arr: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	return source_attributes_state.add_state(attribute_all, arr, other_arr)

func java_method_add_4(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var other_arr: Array = _args[2] if _args.size() > 2 and _args[2] is Array else []
	var scale := float(_args[3] if _args.size() > 3 else 1.0)
	return source_attributes_state.add_state(attribute_all, arr, other_arr, scale)

func java_method_write_5(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	return source_attributes_state.write_state(attribute_all, arr)

func java_method_read_6(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var data: Dictionary = _args[2] if _args.size() > 2 and _args[2] is Dictionary else {}
	return source_attributes_state.read_state(attribute_all, arr, data)

func java_method_check_7(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	return source_attributes_state.check_state(attribute_all, arr)

func java_method_toString_8(_args: Array = []) -> Variant:
	var attribute_all: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var arr: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	return source_attributes_state.to_string_state(attribute_all, arr)
