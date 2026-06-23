# Generated from Mindustry upstream.
# Source: mindustry/logic/LCategory.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LCategory"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "all", "type": "Seq"}, {"modifiers": ["final", "public", "static"], "name": "unknown", "type": "LCategory"}, {"modifiers": ["final", "public", "static"], "name": "io", "type": "LCategory"}, {"modifiers": ["final", "public", "static"], "name": "block", "type": "LCategory"}, {"modifiers": ["final", "public", "static"], "name": "operation", "type": "LCategory"}, {"modifiers": ["final", "public", "static"], "name": "control", "type": "LCategory"}, {"modifiers": ["final", "public", "static"], "name": "unit", "type": "LCategory"}, {"modifiers": ["final", "public", "static"], "name": "world", "type": "LCategory"}, {"modifiers": ["final", "public"], "name": "name", "type": "String"}, {"modifiers": ["final", "public"], "name": "id", "type": "int"}, {"modifiers": ["final", "public"], "name": "color", "type": "Color"}, {"modifiers": ["final", "public"], "name": "icon", "type": "Drawable"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LCategory", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}]}, {"modifiers": ["public"], "name": "LCategory", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "icon", "type": "Drawable", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "localized", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "description", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "o", "type": "LCategory", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
