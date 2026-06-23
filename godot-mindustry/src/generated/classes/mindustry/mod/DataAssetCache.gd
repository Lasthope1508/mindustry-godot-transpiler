# Generated from Mindustry upstream.
# Source: mindustry/mod/DataAssetCache.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod"
const JAVA_KIND := "class"
const JAVA_NAME := "DataAssetCache"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "base32Alphabet", "type": "char"}, {"modifiers": ["private"], "name": "hashToFile", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public", "synchronized"], "name": "addOverride", "parameters": [{"name": "hash", "type": "String", "varargs": false}, {"name": "source", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "synchronized"], "name": "add", "parameters": [{"name": "bytes", "type": "byte", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "has", "parameters": [{"name": "hash", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "synchronized"], "name": "get", "parameters": [{"name": "shaHash", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "shaHash", "type": "byte", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public", "static"], "name": "encodeHash", "parameters": [{"name": "data", "type": "byte", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_load_0(_args: Array = []) -> Variant:
	return null

func java_method_addOverride_1(_args: Array = []) -> Variant:
	return null

func java_method_add_2(_args: Array = []) -> Variant:
	return null

func java_method_has_3(_args: Array = []) -> Variant:
	return null

func java_method_get_4(_args: Array = []) -> Variant:
	return null

func java_method_get_5(_args: Array = []) -> Variant:
	return null

func java_method_encodeHash_6(_args: Array = []) -> Variant:
	return null
