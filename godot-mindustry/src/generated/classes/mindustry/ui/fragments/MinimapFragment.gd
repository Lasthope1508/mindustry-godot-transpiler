# Generated from Mindustry upstream.
# Source: mindustry/ui/fragments/MinimapFragment.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.fragments"
const JAVA_KIND := "class"
const JAVA_NAME := "MinimapFragment"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "shown", "type": "boolean"}, {"modifiers": [], "name": "panx", "type": "float"}, {"modifiers": [], "name": "pany", "type": "float"}, {"modifiers": [], "name": "zoom", "type": "float"}, {"modifiers": [], "name": "lastZoom", "type": "float"}, {"modifiers": ["private"], "name": "baseSize", "type": "float"}, {"modifiers": ["public"], "name": "elem", "type": "Element"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "getRectBounds", "parameters": [], "return_type": "Rect"}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "parent", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "panTo", "parameters": [{"name": "relativeX", "type": "float", "varargs": false}, {"name": "relativeY", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "convert", "parameters": [{"name": "relativeX", "type": "float", "varargs": false}, {"name": "relativeY", "type": "float", "varargs": false}], "return_type": "Vec2"}, {"modifiers": ["public"], "name": "shown", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hide", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "toggle", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
