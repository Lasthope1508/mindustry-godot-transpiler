# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/distribution/Duct.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.distribution"
const JAVA_KIND := "class"
const JAVA_NAME := "Duct"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := ["Autotiler"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "speed", "type": "float"}, {"modifiers": ["public"], "name": "armored", "type": "boolean"}, {"modifiers": ["public"], "name": "topRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "botRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "bridgeReplacement", "type": "Block"}, {"modifiers": ["public"], "name": "junctionReplacement", "type": "Block"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Duct", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "blendsArmored", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "otherx", "type": "int", "varargs": false}, {"name": "othery", "type": "int", "varargs": false}, {"name": "otherrot", "type": "int", "varargs": false}, {"name": "otherblock", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "blends", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "otherx", "type": "int", "varargs": false}, {"name": "othery", "type": "int", "varargs": false}, {"name": "otherrot", "type": "int", "varargs": false}, {"name": "otherblock", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getReplacement", "parameters": [{"name": "req", "type": "BuildPlan", "varargs": false}, {"name": "plans", "type": "Seq", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public"], "name": "handlePlacementLine", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	return null

func java_method_init_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_2(_args: Array = []) -> Variant:
	return null

func java_method_blendsArmored_3(_args: Array = []) -> Variant:
	return null

func java_method_blends_4(_args: Array = []) -> Variant:
	return null

func java_method_icons_5(_args: Array = []) -> Variant:
	return null

func java_method_getReplacement_6(_args: Array = []) -> Variant:
	return null

func java_method_handlePlacementLine_7(_args: Array = []) -> Variant:
	return null
