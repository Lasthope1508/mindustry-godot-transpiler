# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/production/Pump.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.production"
const JAVA_KIND := "class"
const JAVA_NAME := "Pump"
const JAVA_EXTENDS := "LiquidBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "pumpAmount", "type": "float"}, {"modifiers": ["public"], "name": "consumeTime", "type": "float"}, {"modifiers": ["public"], "name": "warmupSpeed", "type": "float"}, {"modifiers": ["public"], "name": "drawer", "type": "DrawBlock"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Pump", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "canPump", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_1(_args: Array = []) -> Variant:
	return null

func java_method_load_2(_args: Array = []) -> Variant:
	return null

func java_method_icons_3(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_4(_args: Array = []) -> Variant:
	return null

func java_method_setBars_5(_args: Array = []) -> Variant:
	return null

func java_method_canPump_6(_args: Array = []) -> Variant:
	return null
