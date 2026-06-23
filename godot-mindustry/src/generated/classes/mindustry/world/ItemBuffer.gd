# Generated from Mindustry upstream.
# Source: mindustry/world/ItemBuffer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemBuffer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "buffer", "type": "long"}, {"modifiers": ["private"], "name": "index", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemBuffer", "parameters": [{"name": "capacity", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "accepts", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "accept", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "data", "type": "short", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "accept", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "poll", "parameters": [{"name": "speed", "type": "float", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
