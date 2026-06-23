# Generated from Mindustry upstream.
# Source: mindustry/mod/data/PatchAsset.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod.data"
const JAVA_KIND := "class"
const JAVA_NAME := "PatchAsset"
const JAVA_EXTENDS := "DataAsset"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "emptyValue", "type": "JsonValue"}, {"modifiers": ["public"], "name": "patch", "type": "String"}, {"modifiers": ["public"], "name": "json", "type": "JsonValue"}, {"modifiers": ["public"], "name": "error", "type": "boolean"}, {"modifiers": ["public"], "name": "warnings", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PatchAsset", "parameters": [{"name": "patch", "type": "String", "varargs": false}]}, {"modifiers": [], "name": "PatchAsset", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getData", "parameters": [], "return_type": "byte"}, {"modifiers": ["public"], "name": "readFromZip", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readOverride", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getType", "parameters": [], "return_type": "DataAssetType"}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getData_0(_args: Array = []) -> Variant:
	return null

func java_method_readFromZip_1(_args: Array = []) -> Variant:
	return null

func java_method_readOverride_2(_args: Array = []) -> Variant:
	return null

func java_method_getType_3(_args: Array = []) -> Variant:
	return null

func java_method_read_4(_args: Array = []) -> Variant:
	return null

func java_method_write_5(_args: Array = []) -> Variant:
	return null

func java_method_toString_6(_args: Array = []) -> Variant:
	return null
