# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/production/Drill.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.production"
const JAVA_KIND := "class"
const JAVA_NAME := "Drill"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "hardnessDrillMultiplier", "type": "float"}, {"modifiers": ["final", "protected"], "name": "oreCount", "type": "ObjectIntMap"}, {"modifiers": ["final", "protected"], "name": "itemArray", "type": "Seq"}, {"modifiers": ["public"], "name": "tier", "type": "int"}, {"modifiers": ["public"], "name": "drillTime", "type": "float"}, {"modifiers": ["public"], "name": "liquidBoostIntensity", "type": "float"}, {"modifiers": ["public"], "name": "warmupSpeed", "type": "float"}, {"modifiers": ["public"], "name": "blockedItem", "type": "Item"}, {"modifiers": ["public"], "name": "blockedItems", "type": "Seq"}, {"modifiers": ["protected"], "name": "returnItem", "type": "Item"}, {"modifiers": ["protected"], "name": "returnCount", "type": "int"}, {"modifiers": ["public"], "name": "drawMineItem", "type": "boolean"}, {"modifiers": ["public"], "name": "drillEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "drillEffectRnd", "type": "float"}, {"modifiers": ["public"], "name": "drillEffectChance", "type": "float"}, {"modifiers": ["public"], "name": "rotateSpeed", "type": "float"}, {"modifiers": ["public"], "name": "updateEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "updateEffectChance", "type": "float"}, {"modifiers": ["public"], "name": "drillMultipliers", "type": "ObjectFloatMap"}, {"modifiers": ["public"], "name": "drawRim", "type": "boolean"}, {"modifiers": ["public"], "name": "drawSpinSprite", "type": "boolean"}, {"modifiers": ["public"], "name": "heatColor", "type": "Color"}, {"modifiers": ["public"], "name": "rimRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "rotatorRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "topRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "itemRegion", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Drill", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanConfig", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getDrop", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getDrillTime", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["protected"], "name": "countOre", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canMine", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanConfig_1(_args: Array = []) -> Variant:
	return null

func java_method_setBars_2(_args: Array = []) -> Variant:
	return null

func java_method_getDrop_3(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_5(_args: Array = []) -> Variant:
	return null

func java_method_getDrillTime_6(_args: Array = []) -> Variant:
	var drill_time: float = float(_args[0] if _args.size() > 0 else 0.0)
	var hardness_drill_multiplier: float = float(_args[1] if _args.size() > 1 else 50.0)
	var item_hardness: float = float(_args[2] if _args.size() > 2 else 0.0)
	var drill_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)
	var drill_time_result: float = (drill_time + hardness_drill_multiplier * item_hardness) / drill_multiplier
	return {"source_owner": "PortGame.source_drill_delay", "source": "core/src/mindustry/world/blocks/production/Drill.java", "method": "public float getDrillTime(Item item){", "result_expr": "return (drillTime + hardnessDrillMultiplier * item.hardness) / drillMultipliers.get(item, 1f);", "drillTime": drill_time_result, "hardnessDrillMultiplier": hardness_drill_multiplier, "itemHardness": item_hardness, "drillMultiplier": drill_multiplier}

func java_method_setStats_7(_args: Array = []) -> Variant:
	return null

func java_method_icons_8(_args: Array = []) -> Variant:
	return null

func java_method_countOre_9(_args: Array = []) -> Variant:
	return null

func java_method_canMine_10(_args: Array = []) -> Variant:
	return null
