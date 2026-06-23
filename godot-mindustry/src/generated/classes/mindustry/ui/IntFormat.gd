# Generated from Mindustry upstream.
# Source: mindustry/ui/IntFormat.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui"
const JAVA_KIND := "class"
const JAVA_NAME := "IntFormat"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private"], "name": "builder", "type": "StringBuilder"}, {"modifiers": ["final", "private"], "name": "text", "type": "String"}, {"modifiers": ["private"], "name": "lastValue", "type": "int"}, {"modifiers": ["private"], "name": "lastValue2", "type": "int"}, {"modifiers": ["private"], "name": "converter", "type": "Func"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "IntFormat", "parameters": [{"name": "text", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "IntFormat", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "converter", "type": "Func", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "get", "parameters": [{"name": "value", "type": "int", "varargs": false}], "return_type": "CharSequence"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "value1", "type": "int", "varargs": false}, {"name": "value2", "type": "int", "varargs": false}], "return_type": "CharSequence"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_get_0(_args: Array = []) -> Variant:
	return null

func java_method_get_1(_args: Array = []) -> Variant:
	return null
