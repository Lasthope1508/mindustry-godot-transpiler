# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/distribution/StackConveyor.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.distribution"
const JAVA_KIND := "class"
const JAVA_NAME := "StackConveyor"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := ["Autotiler"]
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "stateMove", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "stateLoad", "type": "int"}, {"modifiers": ["final", "protected", "static"], "name": "stateUnload", "type": "int"}, {"modifiers": ["public"], "name": "regions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "edgeRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "stackRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "glowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "edgeGlowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "glowAlpha", "type": "float"}, {"modifiers": ["public"], "name": "glowColor", "type": "Color"}, {"modifiers": ["public"], "name": "baseEfficiency", "type": "float"}, {"modifiers": ["public"], "name": "speed", "type": "float"}, {"modifiers": ["public"], "name": "outputRouter", "type": "boolean"}, {"modifiers": ["public"], "name": "recharge", "type": "float"}, {"modifiers": ["public"], "name": "loadEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "unloadEffect", "type": "Effect"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "StackConveyor", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "blends", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "otherx", "type": "int", "varargs": false}, {"name": "othery", "type": "int", "varargs": false}, {"name": "otherrot", "type": "int", "varargs": false}, {"name": "otherblock", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	return null

func java_method_blends_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_2(_args: Array = []) -> Variant:
	return null

func java_method_rotatedOutput_3(_args: Array = []) -> Variant:
	return null
