# Generated from Mindustry upstream.
# Source: mindustry/graphics/Trail.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics"
const JAVA_KIND := "class"
const JAVA_NAME := "Trail"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "length", "type": "int"}, {"modifiers": ["protected"], "name": "points", "type": "FloatSeq"}, {"modifiers": ["protected"], "name": "lastX", "type": "float"}, {"modifiers": ["protected"], "name": "lastY", "type": "float"}, {"modifiers": ["protected"], "name": "lastAngle", "type": "float"}, {"modifiers": ["protected"], "name": "counter", "type": "float"}, {"modifiers": ["protected"], "name": "lastW", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Trail", "parameters": [{"name": "length", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "Trail"}, {"modifiers": ["public"], "name": "width", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "drawCap", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "width", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "width", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "shorten", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "width", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
