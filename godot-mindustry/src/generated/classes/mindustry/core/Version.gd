# Generated from Mindustry upstream.
# Source: mindustry/core/Version.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "class"
const JAVA_NAME := "Version"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "type", "type": "String"}, {"modifiers": ["public", "static"], "name": "modifier", "type": "String"}, {"modifiers": ["public", "static"], "name": "commitHash", "type": "String"}, {"modifiers": ["public", "static"], "name": "buildDate", "type": "String"}, {"modifiers": ["public", "static"], "name": "number", "type": "int"}, {"modifiers": ["public", "static"], "name": "build", "type": "int"}, {"modifiers": ["public", "static"], "name": "revision", "type": "int"}, {"modifiers": ["public", "static"], "name": "isSteam", "type": "boolean"}, {"modifiers": ["public", "static"], "name": "enabled", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "isAtLeast", "parameters": [{"name": "str", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "isAtLeast", "parameters": [{"name": "build", "type": "int", "varargs": false}, {"name": "revision", "type": "int", "varargs": false}, {"name": "str", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "buildString", "parameters": [], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "combined", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
