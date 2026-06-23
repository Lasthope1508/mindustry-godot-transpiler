# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/production/WallCrafter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.production"
const JAVA_KIND := "class"
const JAVA_NAME := "WallCrafter"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["static"], "name": "idx", "type": "int"}, {"modifiers": ["public"], "name": "topRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "rotatorBottomRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "rotatorRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "drillTime", "type": "float"}, {"modifiers": ["public"], "name": "liquidBoostIntensity", "type": "float"}, {"modifiers": ["public"], "name": "updateEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "updateEffectChance", "type": "float"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "attribute", "type": "Attribute"}, {"modifiers": ["public"], "name": "output", "type": "Item"}, {"modifiers": ["public"], "name": "boostItemUseTime", "type": "float"}, {"modifiers": ["public"], "name": "itemBoostIntensity", "type": "float"}, {"modifiers": ["public"], "name": "itemConsumer", "type": "Consume"}, {"modifiers": ["public"], "name": "hasLiquidBooster", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "timerUse", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "WallCrafter", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "getEfficiency", "parameters": [{"name": "tx", "type": "int", "varargs": false}, {"name": "ty", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "ctile", "type": "Cons", "varargs": false}, {"name": "cpos", "type": "Intc2", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setBars_0(_args: Array = []) -> Variant:
	return null

func java_method_setStats_1(_args: Array = []) -> Variant:
	return null

func java_method_init_2(_args: Array = []) -> Variant:
	return null

func java_method_outputsItems_3(_args: Array = []) -> Variant:
	return null

func java_method_rotatedOutput_4(_args: Array = []) -> Variant:
	return null

func java_method_icons_5(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_6(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_7(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_8(_args: Array = []) -> Variant:
	return null

func java_method_getEfficiency_9(_args: Array = []) -> Variant:
	return null
