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
