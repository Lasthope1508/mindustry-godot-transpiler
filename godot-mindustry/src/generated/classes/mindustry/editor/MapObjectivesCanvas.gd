# Generated from Mindustry upstream.
# Source: mindustry/editor/MapObjectivesCanvas.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "MapObjectivesCanvas"
const JAVA_EXTENDS := "WidgetGroup"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "objWidth", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "objHeight", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "bounds", "type": "int"}, {"modifiers": ["final", "public"], "name": "unitSize", "type": "float"}, {"modifiers": ["public"], "name": "objectives", "type": "Seq"}, {"modifiers": ["public"], "name": "tilemap", "type": "ObjectiveTilemap"}, {"modifiers": ["protected"], "name": "query", "type": "MapObjective"}, {"modifiers": ["private"], "name": "pressed", "type": "boolean"}, {"modifiers": ["private"], "name": "visualPressed", "type": "long"}, {"modifiers": ["private"], "name": "queryX", "type": "int"}, {"modifiers": ["private"], "name": "queryY", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapObjectivesCanvas", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "clearObjectives", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "stopQuery", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "query", "parameters": [{"name": "obj", "type": "MapObjective", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "placeQuery", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isQuerying", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isVisualPressed", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_clearObjectives_0(_args: Array = []) -> Variant:
	return null

func java_method_stopQuery_1(_args: Array = []) -> Variant:
	return null

func java_method_query_2(_args: Array = []) -> Variant:
	return null

func java_method_placeQuery_3(_args: Array = []) -> Variant:
	return null

func java_method_isQuerying_4(_args: Array = []) -> Variant:
	return null

func java_method_isVisualPressed_5(_args: Array = []) -> Variant:
	return null
