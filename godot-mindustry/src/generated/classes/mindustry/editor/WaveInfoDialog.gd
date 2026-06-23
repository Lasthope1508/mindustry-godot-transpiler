# Generated from Mindustry upstream.
# Source: mindustry/editor/WaveInfoDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "WaveInfoDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": [], "name": "groups", "type": "Seq"}, {"modifiers": ["private"], "name": "expandedGroup", "type": "SpawnGroup"}, {"modifiers": ["private"], "name": "table", "type": "Table"}, {"modifiers": ["private"], "name": "search", "type": "int"}, {"modifiers": ["private"], "name": "filterType", "type": "UnitType"}, {"modifiers": ["private"], "name": "sort", "type": "Sort"}, {"modifiers": ["private"], "name": "reverseSort", "type": "boolean"}, {"modifiers": ["private"], "name": "checkedSpawns", "type": "boolean"}, {"modifiers": ["private"], "name": "graph", "type": "WaveGraph"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "WaveInfoDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "buildGroups", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "showUnits", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}, {"name": "reset", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "showEffects", "parameters": [{"name": "group", "type": "SpawnGroup", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateWaves", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
