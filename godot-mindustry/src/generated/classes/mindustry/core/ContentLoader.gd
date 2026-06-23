# Generated from Mindustry upstream.
# Source: mindustry/core/ContentLoader.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "class"
const JAVA_NAME := "ContentLoader"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "contentNameMap", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "contentMap", "type": "Seq"}, {"modifiers": ["private"], "name": "nameMap", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "temporaryMapper", "type": "MappableContent"}, {"modifiers": ["private"], "name": "currentMod", "type": "LoadedMod"}, {"modifiers": ["private"], "name": "lastAdded", "type": "Content"}, {"modifiers": ["private"], "name": "initialization", "type": "ObjectSet"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ContentLoader", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "ContentLoader"}, {"modifiers": ["public"], "name": "createBaseContent", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "createModContent", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "logContent", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "initialize", "parameters": [{"name": "callable", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "loadColors", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getLastAdded", "parameters": [], "return_type": "Content"}, {"modifiers": ["public"], "name": "removeLast", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "handleContent", "parameters": [{"name": "content", "type": "Content", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setCurrentMod", "parameters": [{"name": "mod", "type": "LoadedMod", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "transformName", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "handleMappableContent", "parameters": [{"name": "content", "type": "MappableContent", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setTemporaryMapper", "parameters": [{"name": "temporaryMapper", "type": "MappableContent", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "byName", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "MappableContent"}, {"modifiers": ["public"], "name": "getContentMap", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "each", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getByName", "parameters": [{"name": "type", "type": "ContentType", "varargs": false}, {"name": "name", "type": "String", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "getByID", "parameters": [{"name": "type", "type": "ContentType", "varargs": false}, {"name": "id", "type": "int", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "getBy", "parameters": [{"name": "type", "type": "ContentType", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getNamesBy", "parameters": [{"name": "type", "type": "ContentType", "varargs": false}], "return_type": "ObjectMap"}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "content", "type": "Content", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "blocks", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "block", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public"], "name": "block", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public"], "name": "items", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "item", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public"], "name": "item", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public"], "name": "liquids", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "liquid", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "Liquid"}, {"modifiers": ["public"], "name": "liquid", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Liquid"}, {"modifiers": ["public"], "name": "bullets", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "bullet", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "BulletType"}, {"modifiers": ["public"], "name": "statusEffects", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "statusEffect", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "StatusEffect"}, {"modifiers": ["public"], "name": "sectors", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "sector", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "SectorPreset"}, {"modifiers": ["public"], "name": "units", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "unit", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "UnitType"}, {"modifiers": ["public"], "name": "unit", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "UnitType"}, {"modifiers": ["public"], "name": "planets", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "planet", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Planet"}, {"modifiers": ["public"], "name": "weathers", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "weather", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Weather"}, {"modifiers": ["public"], "name": "unitStances", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "unitStance", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "UnitStance"}, {"modifiers": ["public"], "name": "unitStance", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "UnitStance"}, {"modifiers": ["public"], "name": "unitCommands", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "unitCommand", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "UnitCommand"}, {"modifiers": ["public"], "name": "unitCommand", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "UnitCommand"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_copy_0(_args: Array = []) -> Variant:
	return null

func java_method_createBaseContent_1(_args: Array = []) -> Variant:
	return null

func java_method_createModContent_2(_args: Array = []) -> Variant:
	return null

func java_method_logContent_3(_args: Array = []) -> Variant:
	return null

func java_method_init_4(_args: Array = []) -> Variant:
	return null

func java_method_load_5(_args: Array = []) -> Variant:
	return null

func java_method_initialize_6(_args: Array = []) -> Variant:
	return null

func java_method_loadColors_7(_args: Array = []) -> Variant:
	return null

func java_method_getLastAdded_8(_args: Array = []) -> Variant:
	return null

func java_method_removeLast_9(_args: Array = []) -> Variant:
	return null

func java_method_handleContent_10(_args: Array = []) -> Variant:
	return null

func java_method_setCurrentMod_11(_args: Array = []) -> Variant:
	return null

func java_method_transformName_12(_args: Array = []) -> Variant:
	return null

func java_method_handleMappableContent_13(_args: Array = []) -> Variant:
	return null

func java_method_setTemporaryMapper_14(_args: Array = []) -> Variant:
	return null

func java_method_byName_15(_args: Array = []) -> Variant:
	return null

func java_method_getContentMap_16(_args: Array = []) -> Variant:
	return null

func java_method_each_17(_args: Array = []) -> Variant:
	return null

func java_method_getByName_18(_args: Array = []) -> Variant:
	return null

func java_method_getByID_19(_args: Array = []) -> Variant:
	return null

func java_method_getBy_20(_args: Array = []) -> Variant:
	return null

func java_method_getNamesBy_21(_args: Array = []) -> Variant:
	return null

func java_method_remove_22(_args: Array = []) -> Variant:
	return null

func java_method_blocks_23(_args: Array = []) -> Variant:
	return null

func java_method_block_24(_args: Array = []) -> Variant:
	return null

func java_method_block_25(_args: Array = []) -> Variant:
	return null

func java_method_items_26(_args: Array = []) -> Variant:
	return null

func java_method_item_27(_args: Array = []) -> Variant:
	return null

func java_method_item_28(_args: Array = []) -> Variant:
	return null

func java_method_liquids_29(_args: Array = []) -> Variant:
	return null

func java_method_liquid_30(_args: Array = []) -> Variant:
	return null

func java_method_liquid_31(_args: Array = []) -> Variant:
	return null

func java_method_bullets_32(_args: Array = []) -> Variant:
	return null

func java_method_bullet_33(_args: Array = []) -> Variant:
	return null

func java_method_statusEffects_34(_args: Array = []) -> Variant:
	return null

func java_method_statusEffect_35(_args: Array = []) -> Variant:
	return null

func java_method_sectors_36(_args: Array = []) -> Variant:
	return null

func java_method_sector_37(_args: Array = []) -> Variant:
	return null

func java_method_units_38(_args: Array = []) -> Variant:
	return null

func java_method_unit_39(_args: Array = []) -> Variant:
	return null

func java_method_unit_40(_args: Array = []) -> Variant:
	return null

func java_method_planets_41(_args: Array = []) -> Variant:
	return null

func java_method_planet_42(_args: Array = []) -> Variant:
	return null

func java_method_weathers_43(_args: Array = []) -> Variant:
	return null

func java_method_weather_44(_args: Array = []) -> Variant:
	return null

func java_method_unitStances_45(_args: Array = []) -> Variant:
	return null

func java_method_unitStance_46(_args: Array = []) -> Variant:
	return null

func java_method_unitStance_47(_args: Array = []) -> Variant:
	return null

func java_method_unitCommands_48(_args: Array = []) -> Variant:
	return null

func java_method_unitCommand_49(_args: Array = []) -> Variant:
	return null

func java_method_unitCommand_50(_args: Array = []) -> Variant:
	return null
