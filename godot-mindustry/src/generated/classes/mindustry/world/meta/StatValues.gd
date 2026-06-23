# Generated from Mindustry upstream.
# Source: mindustry/world/meta/StatValues.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.meta"
const JAVA_KIND := "class"
const JAVA_NAME := "StatValues"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "string", "parameters": [{"name": "value", "type": "String", "varargs": false}, {"name": "args", "type": "Object", "varargs": true}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "bool", "parameters": [{"name": "value", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "fixValue", "parameters": [{"name": "value", "type": "float", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "squared", "parameters": [{"name": "value", "type": "float", "varargs": false}, {"name": "unit", "type": "StatUnit", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "number", "parameters": [{"name": "value", "type": "float", "varargs": false}, {"name": "unit", "type": "StatUnit", "varargs": false}, {"name": "merge", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "number", "parameters": [{"name": "value", "type": "float", "varargs": false}, {"name": "unit", "type": "StatUnit", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "multiplierModifier", "parameters": [{"name": "value", "type": "float", "varargs": false}, {"name": "unit", "type": "StatUnit", "varargs": false}, {"name": "merge", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "multiplierModifier", "parameters": [{"name": "value", "type": "float", "varargs": false}, {"name": "unit", "type": "StatUnit", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "multiplierModifier", "parameters": [{"name": "value", "type": "float", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "percentModifier", "parameters": [{"name": "value", "type": "float", "varargs": false}, {"name": "unit", "type": "StatUnit", "varargs": false}, {"name": "merge", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "percentModifier", "parameters": [{"name": "value", "type": "float", "varargs": false}, {"name": "unit", "type": "StatUnit", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "percentModifier", "parameters": [{"name": "value", "type": "float", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "liquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "perSecond", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "liquids", "parameters": [{"name": "filter", "type": "Boolf", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "perSecond", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "liquids", "parameters": [{"name": "timePeriod", "type": "float", "varargs": false}, {"name": "stacks", "type": "LiquidStack", "varargs": true}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "liquids", "parameters": [{"name": "timePeriod", "type": "float", "varargs": false}, {"name": "perSecond", "type": "boolean", "varargs": false}, {"name": "stacks", "type": "LiquidStack", "varargs": true}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "items", "parameters": [{"name": "stacks", "type": "ItemStack", "varargs": true}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "items", "parameters": [{"name": "displayName", "type": "boolean", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": true}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "items", "parameters": [{"name": "timePeriod", "type": "float", "varargs": false}, {"name": "stacks", "type": "ItemStack", "varargs": true}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "items", "parameters": [{"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "items", "parameters": [{"name": "timePeriod", "type": "float", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "displayLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "perSecond", "type": "boolean", "varargs": false}], "return_type": "Table"}, {"modifiers": ["public", "static"], "name": "withTooltip", "parameters": [{"name": "element", "type": "T", "varargs": false}, {"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "tooltip", "type": "boolean", "varargs": false}], "return_type": "T"}, {"modifiers": ["public", "static"], "name": "withTooltip", "parameters": [{"name": "element", "type": "T", "varargs": false}, {"name": "content", "type": "UnlockableContent", "varargs": false}], "return_type": "T"}, {"modifiers": ["private", "static"], "name": "stack", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "content", "type": "UnlockableContent", "varargs": false}, {"name": "tooltip", "type": "boolean", "varargs": false}], "return_type": "Stack"}, {"modifiers": ["private", "static"], "name": "stack", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "content", "type": "UnlockableContent", "varargs": false}], "return_type": "Stack"}, {"modifiers": ["public", "static"], "name": "stack", "parameters": [{"name": "stack", "type": "ItemStack", "varargs": false}], "return_type": "Stack"}, {"modifiers": ["public", "static"], "name": "stack", "parameters": [{"name": "item", "type": "UnlockableContent", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "Stack"}, {"modifiers": ["public", "static"], "name": "stack", "parameters": [{"name": "item", "type": "UnlockableContent", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "tooltip", "type": "boolean", "varargs": false}], "return_type": "Stack"}, {"modifiers": ["public", "static"], "name": "stack", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "Stack"}, {"modifiers": ["public", "static"], "name": "stack", "parameters": [{"name": "stack", "type": "PayloadStack", "varargs": false}], "return_type": "Stack"}, {"modifiers": ["public", "static"], "name": "displayItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "Table"}, {"modifiers": ["public", "static"], "name": "displayItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "showName", "type": "boolean", "varargs": false}], "return_type": "Table"}, {"modifiers": ["public", "static"], "name": "displayItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "Table"}, {"modifiers": ["public", "static"], "name": "displayItem", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}, {"name": "timePeriod", "type": "float", "varargs": false}, {"name": "showName", "type": "boolean", "varargs": false}], "return_type": "Table"}, {"modifiers": ["public", "static"], "name": "displayItemPercent", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "percent", "type": "int", "varargs": false}, {"name": "showName", "type": "boolean", "varargs": false}], "return_type": "Table"}, {"modifiers": ["public", "static"], "name": "content", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "blockEfficiency", "parameters": [{"name": "floor", "type": "Block", "varargs": false}, {"name": "multiplier", "type": "float", "varargs": false}, {"name": "startZero", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "blocks", "parameters": [{"name": "attr", "type": "Attribute", "varargs": false}, {"name": "floating", "type": "boolean", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}, {"name": "startZero", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "blocks", "parameters": [{"name": "attr", "type": "Attribute", "varargs": false}, {"name": "floating", "type": "boolean", "varargs": false}, {"name": "scale", "type": "float", "varargs": false}, {"name": "startZero", "type": "boolean", "varargs": false}, {"name": "checkFloors", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "content", "parameters": [{"name": "list", "type": "Seq", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "content", "parameters": [{"name": "list", "type": "Seq", "varargs": false}, {"name": "check", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "content", "parameters": [{"name": "list", "type": "Seq", "varargs": false}, {"name": "check", "type": "Boolf", "varargs": false}, {"name": "noneText", "type": "String", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "blocks", "parameters": [{"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "blocks", "parameters": [{"name": "list", "type": "Seq", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "statusEffects", "parameters": [{"name": "list", "type": "Seq", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "drillables", "parameters": [{"name": "drillTime", "type": "float", "varargs": false}, {"name": "drillMultiplier", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}, {"name": "multipliers", "type": "ObjectFloatMap", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "boosters", "parameters": [{"name": "reload", "type": "float", "varargs": false}, {"name": "maxUsed", "type": "float", "varargs": false}, {"name": "multiplier", "type": "float", "varargs": false}, {"name": "baseReload", "type": "boolean", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "itemEffMultiplier", "parameters": [{"name": "efficiency", "type": "Floatf", "varargs": false}, {"name": "timePeriod", "type": "float", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "itemEffMultiplier", "parameters": [{"name": "efficiency", "type": "Floatf", "varargs": false}, {"name": "timePeriod", "type": "float", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}, {"name": "itemDurationMultipliers", "type": "ObjectFloatMap", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "liquidEffMultiplier", "parameters": [{"name": "efficiency", "type": "Floatf", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "speedBoosters", "parameters": [{"name": "unit", "type": "String", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "speed", "type": "float", "varargs": false}, {"name": "strength", "type": "boolean", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "itemBoosters", "parameters": [{"name": "unit", "type": "String", "varargs": false}, {"name": "timePeriod", "type": "float", "varargs": false}, {"name": "speedBoost", "type": "float", "varargs": false}, {"name": "rangeBoost", "type": "float", "varargs": false}, {"name": "items", "type": "ItemStack", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "weapons", "parameters": [{"name": "unit", "type": "UnitType", "varargs": false}, {"name": "weapons", "type": "Seq", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "abilities", "parameters": [{"name": "abilities", "type": "Seq", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "ammo", "parameters": [{"name": "map", "type": "ObjectMap", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "ammo", "parameters": [{"name": "map", "type": "ObjectMap", "varargs": false}, {"name": "showUnit", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "ammo", "parameters": [{"name": "map", "type": "ObjectMap", "varargs": false}, {"name": "blockName", "type": "String", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "ammo", "parameters": [{"name": "map", "type": "ObjectMap", "varargs": false}, {"name": "showUnit", "type": "boolean", "varargs": false}, {"name": "blockName", "type": "String", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "ammo", "parameters": [{"name": "map", "type": "ObjectMap", "varargs": false}, {"name": "nested", "type": "boolean", "varargs": false}, {"name": "showUnit", "type": "boolean", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["public", "static"], "name": "ammo", "parameters": [{"name": "map", "type": "ObjectMap", "varargs": false}, {"name": "nested", "type": "boolean", "varargs": false}, {"name": "showUnit", "type": "boolean", "varargs": false}, {"name": "blockName", "type": "String", "varargs": false}], "return_type": "StatValue"}, {"modifiers": ["private", "static"], "name": "sep", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "text", "type": "String", "varargs": false}], "return_type": "Cell"}, {"modifiers": ["private", "static"], "name": "note", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "text", "type": "String", "varargs": false}], "return_type": "Cell"}, {"modifiers": ["private", "static"], "name": "ammoStat", "parameters": [{"name": "val", "type": "float", "varargs": false}], "return_type": "String"}, {"modifiers": ["private", "static"], "name": "multStat", "parameters": [{"name": "val", "type": "float", "varargs": false}], "return_type": "String"}, {"modifiers": ["private", "static"], "name": "icon", "parameters": [{"name": "t", "type": "UnlockableContent", "varargs": false}], "return_type": "TextureRegion"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_string_0(_args: Array = []) -> Variant:
	return null

func java_method_bool_1(_args: Array = []) -> Variant:
	return null

func java_method_fixValue_2(_args: Array = []) -> Variant:
	return null

func java_method_squared_3(_args: Array = []) -> Variant:
	return null

func java_method_number_4(_args: Array = []) -> Variant:
	return null

func java_method_number_5(_args: Array = []) -> Variant:
	return null

func java_method_multiplierModifier_6(_args: Array = []) -> Variant:
	return null

func java_method_multiplierModifier_7(_args: Array = []) -> Variant:
	return null

func java_method_multiplierModifier_8(_args: Array = []) -> Variant:
	return null

func java_method_percentModifier_9(_args: Array = []) -> Variant:
	return null

func java_method_percentModifier_10(_args: Array = []) -> Variant:
	return null

func java_method_percentModifier_11(_args: Array = []) -> Variant:
	return null

func java_method_liquid_12(_args: Array = []) -> Variant:
	return null

func java_method_liquids_13(_args: Array = []) -> Variant:
	return null

func java_method_liquids_14(_args: Array = []) -> Variant:
	return null

func java_method_liquids_15(_args: Array = []) -> Variant:
	return null

func java_method_items_16(_args: Array = []) -> Variant:
	return null

func java_method_items_17(_args: Array = []) -> Variant:
	return null

func java_method_items_18(_args: Array = []) -> Variant:
	return null

func java_method_items_19(_args: Array = []) -> Variant:
	return null

func java_method_items_20(_args: Array = []) -> Variant:
	return null

func java_method_displayLiquid_21(_args: Array = []) -> Variant:
	return null

func java_method_withTooltip_22(_args: Array = []) -> Variant:
	return null

func java_method_withTooltip_23(_args: Array = []) -> Variant:
	return null

func java_method_stack_24(_args: Array = []) -> Variant:
	return null

func java_method_stack_25(_args: Array = []) -> Variant:
	return null

func java_method_stack_26(_args: Array = []) -> Variant:
	return null

func java_method_stack_27(_args: Array = []) -> Variant:
	return null

func java_method_stack_28(_args: Array = []) -> Variant:
	return null

func java_method_stack_29(_args: Array = []) -> Variant:
	return null

func java_method_stack_30(_args: Array = []) -> Variant:
	return null

func java_method_displayItem_31(_args: Array = []) -> Variant:
	return null

func java_method_displayItem_32(_args: Array = []) -> Variant:
	return null

func java_method_displayItem_33(_args: Array = []) -> Variant:
	return null

func java_method_displayItem_34(_args: Array = []) -> Variant:
	return null

func java_method_displayItemPercent_35(_args: Array = []) -> Variant:
	return null

func java_method_content_36(_args: Array = []) -> Variant:
	return null

func java_method_blockEfficiency_37(_args: Array = []) -> Variant:
	return null

func java_method_blocks_38(_args: Array = []) -> Variant:
	return null

func java_method_blocks_39(_args: Array = []) -> Variant:
	return null

func java_method_content_40(_args: Array = []) -> Variant:
	return null

func java_method_content_41(_args: Array = []) -> Variant:
	return null

func java_method_content_42(_args: Array = []) -> Variant:
	return null

func java_method_blocks_43(_args: Array = []) -> Variant:
	return null

func java_method_blocks_44(_args: Array = []) -> Variant:
	return null

func java_method_statusEffects_45(_args: Array = []) -> Variant:
	return null

func java_method_drillables_46(_args: Array = []) -> Variant:
	return null

func java_method_boosters_47(_args: Array = []) -> Variant:
	return null

func java_method_itemEffMultiplier_48(_args: Array = []) -> Variant:
	return null

func java_method_itemEffMultiplier_49(_args: Array = []) -> Variant:
	return null

func java_method_liquidEffMultiplier_50(_args: Array = []) -> Variant:
	return null

func java_method_speedBoosters_51(_args: Array = []) -> Variant:
	return null

func java_method_itemBoosters_52(_args: Array = []) -> Variant:
	return null

func java_method_weapons_53(_args: Array = []) -> Variant:
	return null

func java_method_abilities_54(_args: Array = []) -> Variant:
	return null

func java_method_ammo_55(_args: Array = []) -> Variant:
	return null

func java_method_ammo_56(_args: Array = []) -> Variant:
	return null

func java_method_ammo_57(_args: Array = []) -> Variant:
	return null

func java_method_ammo_58(_args: Array = []) -> Variant:
	return null

func java_method_ammo_59(_args: Array = []) -> Variant:
	return null

func java_method_ammo_60(_args: Array = []) -> Variant:
	return null

func java_method_sep_61(_args: Array = []) -> Variant:
	return null

func java_method_note_62(_args: Array = []) -> Variant:
	return null

func java_method_ammoStat_63(_args: Array = []) -> Variant:
	return null

func java_method_multStat_64(_args: Array = []) -> Variant:
	return null

func java_method_icon_65(_args: Array = []) -> Variant:
	return null
