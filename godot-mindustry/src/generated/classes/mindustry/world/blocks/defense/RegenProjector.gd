# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/RegenProjector.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense"
const JAVA_KIND := "class"
const JAVA_NAME := "RegenProjector"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "taken", "type": "IntSet"}, {"modifiers": ["final", "private", "static"], "name": "mendMap", "type": "IntFloatMap"}, {"modifiers": ["private", "static"], "name": "lastUpdateFrame", "type": "long"}, {"modifiers": ["public"], "name": "range", "type": "int"}, {"modifiers": ["public"], "name": "healPercent", "type": "float"}, {"modifiers": ["public"], "name": "optionalMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "optionalUseTime", "type": "float"}, {"modifiers": ["public"], "name": "drawer", "type": "DrawBlock"}, {"modifiers": ["public"], "name": "effectChance", "type": "float"}, {"modifiers": ["public"], "name": "baseColor", "type": "Color"}, {"modifiers": ["public"], "name": "effect", "type": "Effect"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "RegenProjector", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_drawPlace_0(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_1(_args: Array = []) -> Variant:
	return null

func java_method_outputsItems_2(_args: Array = []) -> Variant:
	return null

func java_method_icons_3(_args: Array = []) -> Variant:
	return null

func java_method_load_4(_args: Array = []) -> Variant:
	return null

func java_method_setStats_5(_args: Array = []) -> Variant:
	return null
