# Generated from Mindustry upstream.
# Source: mindustry/type/MapLocales.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "MapLocales"
const JAVA_EXTENDS := "ObjectMap"
const JAVA_IMPLEMENTS := ["JsonSerializable"]
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "write", "parameters": [{"name": "json", "type": "Json", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "json", "type": "Json", "varargs": false}, {"name": "jsonData", "type": "JsonValue", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "MapLocales"}, {"modifiers": ["public"], "name": "getProperty", "parameters": [{"name": "key", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["private"], "name": "getProperty", "parameters": [{"name": "locale", "type": "String", "varargs": false}, {"name": "key", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "containsProperty", "parameters": [{"name": "key", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "containsProperty", "parameters": [{"name": "locale", "type": "String", "varargs": false}, {"name": "key", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getFormatted", "parameters": [{"name": "key", "type": "String", "varargs": false}, {"name": "args", "type": "Object", "varargs": true}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "currentLocale", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
