# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/production/BeamDrill.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.production"
const JAVA_KIND := "class"
const JAVA_NAME := "BeamDrill"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["protected"], "name": "rand", "type": "Rand"}, {"modifiers": ["public"], "name": "laser", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEnd", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserCenter", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserBoost", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEndBoost", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserCenterBoost", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "topRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "glowRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "drillTime", "type": "float"}, {"modifiers": ["public"], "name": "range", "type": "int"}, {"modifiers": ["public"], "name": "tier", "type": "int"}, {"modifiers": ["public"], "name": "laserWidth", "type": "float"}, {"modifiers": ["public"], "name": "optionalBoostIntensity", "type": "float"}, {"modifiers": ["public"], "name": "drillMultipliers", "type": "ObjectFloatMap"}, {"modifiers": ["public"], "name": "blockedItem", "type": "Item"}, {"modifiers": ["public"], "name": "blockedItems", "type": "Seq"}, {"modifiers": ["public"], "name": "sparkColor", "type": "Color"}, {"modifiers": ["public"], "name": "glowColor", "type": "Color"}, {"modifiers": ["public"], "name": "glowIntensity", "type": "float"}, {"modifiers": ["public"], "name": "pulseIntensity", "type": "float"}, {"modifiers": ["public"], "name": "glowScl", "type": "float"}, {"modifiers": ["public"], "name": "sparks", "type": "int"}, {"modifiers": ["public"], "name": "sparkRange", "type": "float"}, {"modifiers": ["public"], "name": "sparkLife", "type": "float"}, {"modifiers": ["public"], "name": "sparkRecurrence", "type": "float"}, {"modifiers": ["public"], "name": "sparkSpread", "type": "float"}, {"modifiers": ["public"], "name": "sparkSize", "type": "float"}, {"modifiers": ["public"], "name": "boostHeatColor", "type": "Color"}, {"modifiers": ["public"], "name": "heatColor", "type": "Color"}, {"modifiers": ["public"], "name": "heatPulse", "type": "float"}, {"modifiers": ["public"], "name": "heatPulseScl", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BeamDrill", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getDrillTime", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_setBars_1(_args: Array = []) -> Variant:
	return null

func java_method_outputsItems_2(_args: Array = []) -> Variant:
	return null

func java_method_rotatedOutput_3(_args: Array = []) -> Variant:
	return null

func java_method_icons_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_5(_args: Array = []) -> Variant:
	return null

func java_method_setStats_6(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_7(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_8(_args: Array = []) -> Variant:
	return null

func java_method_getDrillTime_9(_args: Array = []) -> Variant:
	return null
