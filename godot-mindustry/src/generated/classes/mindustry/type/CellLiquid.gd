# Generated from Mindustry upstream.
# Source: mindustry/type/CellLiquid.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "CellLiquid"
const JAVA_EXTENDS := "Liquid"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "colorFrom", "type": "Color"}, {"modifiers": ["public"], "name": "colorTo", "type": "Color"}, {"modifiers": ["public"], "name": "cells", "type": "int"}, {"modifiers": ["public"], "name": "spreadTarget", "type": "Liquid"}, {"modifiers": ["public"], "name": "maxSpread", "type": "float"}, {"modifiers": ["public"], "name": "spreadConversion", "type": "float"}, {"modifiers": ["public"], "name": "spreadDamage", "type": "float"}, {"modifiers": ["public"], "name": "removeScaling", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "CellLiquid", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}]}, {"modifiers": ["public"], "name": "CellLiquid", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [{"name": "puddle", "type": "Puddle", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "react", "parameters": [{"name": "other", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "drawPuddle", "parameters": [{"name": "puddle", "type": "Puddle", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_update_0(_args: Array = []) -> Variant:
	return null

func java_method_react_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPuddle_2(_args: Array = []) -> Variant:
	return null
