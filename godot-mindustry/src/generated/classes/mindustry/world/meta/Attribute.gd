# Generated from Mindustry upstream.
# Source: mindustry/world/meta/Attribute.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.meta"
const JAVA_KIND := "class"
const JAVA_NAME := "Attribute"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "all", "type": "Attribute"}, {"modifiers": ["public", "static"], "name": "map", "type": "ObjectMap"}, {"modifiers": ["final", "public", "static"], "name": "heat", "type": "Attribute"}, {"modifiers": ["final", "public", "static"], "name": "spores", "type": "Attribute"}, {"modifiers": ["final", "public", "static"], "name": "water", "type": "Attribute"}, {"modifiers": ["final", "public", "static"], "name": "oil", "type": "Attribute"}, {"modifiers": ["final", "public", "static"], "name": "light", "type": "Attribute"}, {"modifiers": ["final", "public", "static"], "name": "sand", "type": "Attribute"}, {"modifiers": ["final", "public", "static"], "name": "steam", "type": "Attribute"}, {"modifiers": ["final", "public"], "name": "id", "type": "int"}, {"modifiers": ["final", "public"], "name": "name", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "Attribute", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "env", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "get", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Attribute"}, {"modifiers": ["public", "static"], "name": "getOrNull", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Attribute"}, {"modifiers": ["public", "static"], "name": "exists", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "add", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Attribute"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_env_0(_args: Array = []) -> Variant:
	return null

func java_method_toString_1(_args: Array = []) -> Variant:
	return null

func java_method_get_2(_args: Array = []) -> Variant:
	return null

func java_method_getOrNull_3(_args: Array = []) -> Variant:
	return null

func java_method_exists_4(_args: Array = []) -> Variant:
	return null

func java_method_add_5(_args: Array = []) -> Variant:
	return null
