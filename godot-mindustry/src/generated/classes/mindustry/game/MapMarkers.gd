# Generated from Mindustry upstream.
# Source: mindustry/game/MapMarkers.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "MapMarkers"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Iterable"]
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "map", "type": "IntMap"}, {"modifiers": ["private"], "name": "all", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "add", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "marker", "type": "ObjectiveMarker", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "ObjectiveMarker"}, {"modifiers": ["public"], "name": "has", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "stream", "type": "DataOutput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "stream", "type": "DataInput", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "iterator", "parameters": [], "return_type": "Iterator"}]
const JAVA_ENUM_CONSTANTS := []
