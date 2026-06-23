# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/production/GenericCrafter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.production"
const JAVA_KIND := "class"
const JAVA_NAME := "GenericCrafter"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "outputItem", "type": "ItemStack"}, {"modifiers": ["public"], "name": "outputItems", "type": "ItemStack"}, {"modifiers": ["public"], "name": "outputLiquid", "type": "LiquidStack"}, {"modifiers": ["public"], "name": "outputLiquids", "type": "LiquidStack"}, {"modifiers": ["public"], "name": "liquidOutputDirections", "type": "int"}, {"modifiers": ["public"], "name": "dumpExtraLiquid", "type": "boolean"}, {"modifiers": ["public"], "name": "ignoreLiquidFullness", "type": "boolean"}, {"modifiers": ["public"], "name": "craftTime", "type": "float"}, {"modifiers": ["public"], "name": "craftEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "updateEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "updateEffectChance", "type": "float"}, {"modifiers": ["public"], "name": "updateEffectSpread", "type": "float"}, {"modifiers": ["public"], "name": "warmupSpeed", "type": "float"}, {"modifiers": ["public"], "name": "legacyReadWarmup", "type": "boolean"}, {"modifiers": ["public"], "name": "drawer", "type": "DrawBlock"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "GenericCrafter", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "fromX", "type": "int", "varargs": false}, {"name": "fromY", "type": "int", "varargs": false}, {"name": "destination", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawOverlay", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	return null

func java_method_setBars_1(_args: Array = []) -> Variant:
	return null

func java_method_rotatedOutput_2(_args: Array = []) -> Variant:
	return null

func java_method_load_3(_args: Array = []) -> Variant:
	return null

func java_method_init_4(_args: Array = []) -> Variant:
	return null

func java_method_afterPatch_5(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_6(_args: Array = []) -> Variant:
	return null

func java_method_icons_7(_args: Array = []) -> Variant:
	return null

func java_method_outputsItems_8(_args: Array = []) -> Variant:
	return null

func java_method_getRegionsToOutline_9(_args: Array = []) -> Variant:
	return null

func java_method_drawOverlay_10(_args: Array = []) -> Variant:
	return null
