# Generated from Mindustry upstream.
# Source: mindustry/logic/LogicScript.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LogicScript"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["JsonSerializable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "defaultTimeoutMs", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "maxTimeoutMs", "type": "int"}, {"modifiers": [], "name": "timeout", "type": "int"}, {"modifiers": [], "name": "executor", "type": "LExecutor"}, {"modifiers": [], "name": "resetVars", "type": "boolean"}, {"modifiers": [], "name": "script", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LogicScript", "parameters": [{"name": "script", "type": "String", "varargs": false}]}, {"modifiers": [], "name": "LogicScript", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "run", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "json", "type": "Json", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "json", "type": "Json", "varargs": false}, {"name": "jsonData", "type": "JsonValue", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
