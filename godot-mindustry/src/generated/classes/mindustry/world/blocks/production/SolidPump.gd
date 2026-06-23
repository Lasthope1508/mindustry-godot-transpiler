# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/production/SolidPump.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.production"
const JAVA_KIND := "class"
const JAVA_NAME := "SolidPump"
const JAVA_EXTENDS := "Pump"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "result", "type": "Liquid"}, {"modifiers": ["public"], "name": "updateEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "updateEffectChance", "type": "float"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "baseEfficiency", "type": "float"}, {"modifiers": ["public"], "name": "attribute", "type": "Attribute"}, {"modifiers": ["public"], "name": "rotatorRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SolidPump", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "canPump", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_drawPlace_0(_args: Array = []) -> Variant:
	return null

func java_method_setBars_1(_args: Array = []) -> Variant:
	return null

func java_method_setStats_2(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_3(_args: Array = []) -> Variant:
	return null

func java_method_outputsItems_4(_args: Array = []) -> Variant:
	return null

func java_method_canPump_5(_args: Array = []) -> Variant:
	return null

func java_method_icons_6(_args: Array = []) -> Variant:
	return null
