# Generated from Mindustry upstream.
# Source: mindustry/editor/WaveGraph.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "WaveGraph"
const JAVA_EXTENDS := "Table"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "groups", "type": "Seq"}, {"modifiers": ["private"], "name": "mode", "type": "Mode"}, {"modifiers": ["private"], "name": "values", "type": "int"}, {"modifiers": ["private"], "name": "used", "type": "OrderedSet"}, {"modifiers": ["private"], "name": "max", "type": "int"}, {"modifiers": ["private"], "name": "maxTotal", "type": "int"}, {"modifiers": ["private"], "name": "maxHealth", "type": "float"}, {"modifiers": ["private"], "name": "colors", "type": "Table"}, {"modifiers": ["private"], "name": "hidden", "type": "ObjectSet"}, {"modifiers": ["private"], "name": "countStr", "type": "StringBuilder"}, {"modifiers": ["private"], "name": "pan", "type": "float"}, {"modifiers": ["private"], "name": "zoom", "type": "float"}, {"modifiers": ["private"], "name": "from", "type": "int"}, {"modifiers": ["private"], "name": "to", "type": "int"}, {"modifiers": ["private"], "name": "lastFrom", "type": "int"}, {"modifiers": ["private"], "name": "lastTo", "type": "int"}, {"modifiers": ["private"], "name": "lastZoom", "type": "float"}, {"modifiers": ["private"], "name": "defaultSpace", "type": "float"}, {"modifiers": ["private"], "name": "points", "type": "FloatSeq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "WaveGraph", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["private"], "name": "clampZoom", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "linePoint", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "beginLine", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "endLine", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "rebuild", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "color", "parameters": [{"name": "type", "type": "UnitType", "varargs": false}], "return_type": "Color"}, {"modifiers": [], "name": "nextStep", "parameters": [{"name": "value", "type": "float", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []
