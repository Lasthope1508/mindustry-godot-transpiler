# Generated from Mindustry upstream.
# Source: mindustry/mod/data/DataAsset.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod.data"
const JAVA_KIND := "class"
const JAVA_NAME := "DataAsset"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable"]
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "overrideCacheFile", "type": "Fi"}, {"modifiers": ["public"], "name": "path", "type": "String"}, {"modifiers": ["public"], "name": "name", "type": "String"}, {"modifiers": ["public"], "name": "byteHash", "type": "byte"}, {"modifiers": ["public"], "name": "stringHash", "type": "String"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "updateData", "parameters": [{"name": "data", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setHash", "parameters": [{"name": "value", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setPath", "parameters": [{"name": "path", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "getType", "parameters": [], "return_type": "DataAssetType"}, {"modifiers": ["public"], "name": "getFullPath", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getData", "parameters": [], "return_type": "byte"}, {"modifiers": ["public"], "name": "isAlwaysEmbedded", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isCached", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getCacheFileNoNull", "parameters": [], "return_type": "Fi"}, {"modifiers": ["public"], "name": "getCacheFile", "parameters": [], "return_type": "Fi"}, {"modifiers": ["public"], "name": "readFromZip", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "readOverride", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "asset", "type": "DataAsset", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_updateData_0(_args: Array = []) -> Variant:
	return null

func java_method_setHash_1(_args: Array = []) -> Variant:
	return null

func java_method_setPath_2(_args: Array = []) -> Variant:
	return null

func java_method_getType_3(_args: Array = []) -> Variant:
	return null

func java_method_getFullPath_4(_args: Array = []) -> Variant:
	return null

func java_method_getData_5(_args: Array = []) -> Variant:
	return null

func java_method_isAlwaysEmbedded_6(_args: Array = []) -> Variant:
	return null

func java_method_isCached_7(_args: Array = []) -> Variant:
	return null

func java_method_getCacheFileNoNull_8(_args: Array = []) -> Variant:
	return null

func java_method_getCacheFile_9(_args: Array = []) -> Variant:
	return null

func java_method_readFromZip_10(_args: Array = []) -> Variant:
	return null

func java_method_readOverride_11(_args: Array = []) -> Variant:
	return null

func java_method_read_12(_args: Array = []) -> Variant:
	return null

func java_method_write_13(_args: Array = []) -> Variant:
	return null

func java_method_toString_14(_args: Array = []) -> Variant:
	return null

func java_method_compareTo_15(_args: Array = []) -> Variant:
	return null
