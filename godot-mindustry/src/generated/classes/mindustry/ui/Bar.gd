# Generated from Mindustry upstream.
# Source: mindustry/ui/Bar.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui"
const JAVA_KIND := "class"
const JAVA_NAME := "Bar"
const JAVA_EXTENDS := "Element"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "scissor", "type": "Rect"}, {"modifiers": ["private"], "name": "fraction", "type": "Floatp"}, {"modifiers": ["private"], "name": "name", "type": "CharSequence"}, {"modifiers": ["private"], "name": "value", "type": "float"}, {"modifiers": ["private"], "name": "lastValue", "type": "float"}, {"modifiers": ["private"], "name": "blink", "type": "float"}, {"modifiers": ["private"], "name": "outlineRadius", "type": "float"}, {"modifiers": ["private"], "name": "blinkColor", "type": "Color"}, {"modifiers": ["private"], "name": "outlineColor", "type": "Color"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Bar", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "fraction", "type": "Floatp", "varargs": false}]}, {"modifiers": ["public"], "name": "Bar", "parameters": [{"name": "name", "type": "Prov", "varargs": false}, {"name": "color", "type": "Prov", "varargs": false}, {"name": "fraction", "type": "Floatp", "varargs": false}]}, {"modifiers": ["public"], "name": "Bar", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "reset", "parameters": [{"name": "value", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "name", "type": "Prov", "varargs": false}, {"name": "fraction", "type": "Floatp", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "snap", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "outline", "parameters": [{"name": "color", "type": "Color", "varargs": false}, {"name": "stroke", "type": "float", "varargs": false}], "return_type": "Bar"}, {"modifiers": ["public"], "name": "flash", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "blink", "parameters": [{"name": "color", "type": "Color", "varargs": false}], "return_type": "Bar"}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
