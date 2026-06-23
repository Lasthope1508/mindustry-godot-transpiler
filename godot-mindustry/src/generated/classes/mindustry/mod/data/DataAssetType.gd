# Generated from Mindustry upstream.
# Source: mindustry/mod/data/DataAssetType.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod.data"
const JAVA_KIND := "enum"
const JAVA_NAME := "DataAssetType"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "folder", "type": "String"}, {"modifiers": ["final", "public"], "name": "extensions", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "constructor", "type": "Prov"}, {"modifiers": ["final", "public"], "name": "embedded", "type": "boolean"}, {"modifiers": ["final", "public", "static"], "name": "all", "type": "DataAssetType"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "DataAssetType", "parameters": [{"name": "folder", "type": "String", "varargs": false}, {"name": "extensions", "type": "Seq", "varargs": false}, {"name": "constructor", "type": "Prov", "varargs": false}, {"name": "embedded", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "create", "parameters": [], "return_type": "DataAsset"}, {"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := ["patch", "content", "bundle", "image", "sound", "music"]
