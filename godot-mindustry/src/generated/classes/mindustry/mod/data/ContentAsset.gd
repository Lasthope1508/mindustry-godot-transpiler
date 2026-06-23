# Generated from Mindustry upstream.
# Source: mindustry/mod/data/ContentAsset.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod.data"
const JAVA_KIND := "class"
const JAVA_NAME := "ContentAsset"
const JAVA_EXTENDS := "DataAsset"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "loadableContent", "type": "ContentType"}, {"modifiers": ["public"], "name": "type", "type": "ContentType"}, {"modifiers": ["public"], "name": "data", "type": "String"}, {"modifiers": ["public"], "name": "warnings", "type": "Seq"}, {"modifiers": ["public"], "name": "content", "type": "Content"}, {"modifiers": ["public"], "name": "errored", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ContentAsset", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "type", "type": "ContentType", "varargs": false}, {"name": "data", "type": "String", "varargs": false}]}, {"modifiers": ["public"], "name": "ContentAsset", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "hashData", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "readOverride", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}, {"name": "type", "type": "ContentType", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getFullPath", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getData", "parameters": [], "return_type": "byte"}, {"modifiers": ["public"], "name": "getType", "parameters": [], "return_type": "DataAssetType"}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "asset", "type": "DataAsset", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
