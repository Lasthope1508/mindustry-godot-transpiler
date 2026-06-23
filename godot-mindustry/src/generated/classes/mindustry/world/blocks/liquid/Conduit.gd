# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/liquid/Conduit.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.liquid"
const JAVA_KIND := "class"
const JAVA_NAME := "Conduit"
const JAVA_EXTENDS := "LiquidBlock"
const JAVA_IMPLEMENTS := ["Autotiler"]
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "rotatePad", "type": "float"}, {"modifiers": ["final", "static"], "name": "hpad", "type": "float"}, {"modifiers": ["final", "static"], "name": "rotateOffsets", "type": "float"}, {"modifiers": ["final", "public"], "name": "timerFlow", "type": "int"}, {"modifiers": ["public"], "name": "botColor", "type": "Color"}, {"modifiers": ["public"], "name": "topRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "botRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "capRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "rotateRegions", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "padCorners", "type": "boolean"}, {"modifiers": ["public"], "name": "leaks", "type": "boolean"}, {"modifiers": ["public"], "name": "junctionReplacement", "type": "Block"}, {"modifiers": ["public"], "name": "bridgeReplacement", "type": "Block"}, {"modifiers": ["public"], "name": "rotBridgeReplacement", "type": "Block"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Conduit", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getReplacement", "parameters": [{"name": "req", "type": "BuildPlan", "varargs": false}, {"name": "plans", "type": "Seq", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public"], "name": "blends", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "otherx", "type": "int", "varargs": false}, {"name": "othery", "type": "int", "varargs": false}, {"name": "otherrot", "type": "int", "varargs": false}, {"name": "otherblock", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "handlePlacementLine", "parameters": [{"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_load_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_2(_args: Array = []) -> Variant:
	return null

func java_method_getReplacement_3(_args: Array = []) -> Variant:
	return null

func java_method_blends_4(_args: Array = []) -> Variant:
	return null

func java_method_handlePlacementLine_5(_args: Array = []) -> Variant:
	return null

func java_method_icons_6(_args: Array = []) -> Variant:
	return null
