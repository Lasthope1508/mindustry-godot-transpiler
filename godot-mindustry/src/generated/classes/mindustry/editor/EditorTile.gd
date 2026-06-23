# Generated from Mindustry upstream.
# Source: mindustry/editor/EditorTile.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "EditorTile"
const JAVA_EXTENDS := "Tile"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "EditorTile", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "floor", "type": "int", "varargs": false}, {"name": "overlay", "type": "int", "varargs": false}, {"name": "wall", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setFloor", "parameters": [{"name": "type", "type": "Floor", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isEditorTile", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setBlock", "parameters": [{"name": "type", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "entityprov", "type": "Prov", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setTeam", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setOverlay", "parameters": [{"name": "overlay", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "fireChanged", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "firePreChanged", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "recache", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "changed", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "changeBuild", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "entityprov", "type": "Prov", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isDarkened", "parameters": [], "return_type": "boolean"}, {"modifiers": ["private"], "name": "requiresBlockUpdate", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "updateStatic", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "skip", "parameters": [], "return_type": "boolean"}, {"modifiers": ["private"], "name": "op", "parameters": [{"name": "type", "type": "int", "varargs": false}, {"name": "value", "type": "short", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
