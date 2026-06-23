# Generated from Mindustry upstream.
# Source: mindustry/editor/EditorTool.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "enum"
const JAVA_NAME := "EditorTool"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "all", "type": "EditorTool"}, {"modifiers": ["final", "public"], "name": "altModes", "type": "String"}, {"modifiers": ["public"], "name": "key", "type": "KeyCode"}, {"modifiers": ["public"], "name": "mode", "type": "int"}, {"modifiers": ["public"], "name": "edit", "type": "boolean"}, {"modifiers": ["public"], "name": "draggable", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "EditorTool", "parameters": []}, {"modifiers": [], "name": "EditorTool", "parameters": [{"name": "code", "type": "KeyCode", "varargs": false}]}, {"modifiers": [], "name": "EditorTool", "parameters": [{"name": "altModes", "type": "String", "varargs": true}]}, {"modifiers": [], "name": "EditorTool", "parameters": [{"name": "code", "type": "KeyCode", "varargs": false}, {"name": "altModes", "type": "String", "varargs": true}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "touched", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "touchedLine", "parameters": [{"name": "x1", "type": "int", "varargs": false}, {"name": "y1", "type": "int", "varargs": false}, {"name": "x2", "type": "int", "varargs": false}, {"name": "y2", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := ["zoom", "pick", "line", "pencil", "eraser", "fill", "spray"]
