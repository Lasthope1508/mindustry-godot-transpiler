# Generated from Mindustry upstream.
# Source: mindustry/service/GameService.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.service"
const JAVA_KIND := "class"
const JAVA_NAME := "GameService"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "tmpTiles", "type": "Seq"}, {"modifiers": ["private"], "name": "blocksBuilt", "type": "ObjectSet"}, {"modifiers": ["private"], "name": "unitsBuilt", "type": "ObjectSet"}, {"modifiers": ["private"], "name": "t5s", "type": "ObjectSet"}, {"modifiers": ["private"], "name": "checked", "type": "IntSet"}, {"modifiers": ["private"], "name": "allTransportSerpulo", "type": "Block"}, {"modifiers": ["private"], "name": "allTransportErekir", "type": "Block"}, {"modifiers": ["private"], "name": "allErekirBlocks", "type": "Block"}, {"modifiers": ["private"], "name": "allSerpuloBlocks", "type": "Block"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "enabled", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "completeAchievement", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clearAchievement", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isAchieved", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getStat", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "def", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "setStat", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "storeStats", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "checkAllBlocks", "parameters": [{"name": "ach", "type": "Achievement", "varargs": false}, {"name": "blocks", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "registerEvents", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "checkUpdate", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "save", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "trigger", "parameters": [{"name": "trigger", "type": "Trigger", "varargs": false}, {"name": "ach", "type": "Achievement", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "campaign", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_enabled_1(_args: Array = []) -> Variant:
	return null

func java_method_completeAchievement_2(_args: Array = []) -> Variant:
	return null

func java_method_clearAchievement_3(_args: Array = []) -> Variant:
	return null

func java_method_isAchieved_4(_args: Array = []) -> Variant:
	return null

func java_method_getStat_5(_args: Array = []) -> Variant:
	return null

func java_method_setStat_6(_args: Array = []) -> Variant:
	return null

func java_method_storeStats_7(_args: Array = []) -> Variant:
	return null

func java_method_checkAllBlocks_8(_args: Array = []) -> Variant:
	return null

func java_method_registerEvents_9(_args: Array = []) -> Variant:
	return null

func java_method_checkUpdate_10(_args: Array = []) -> Variant:
	return null

func java_method_save_11(_args: Array = []) -> Variant:
	return null

func java_method_trigger_12(_args: Array = []) -> Variant:
	return null

func java_method_campaign_13(_args: Array = []) -> Variant:
	return null
