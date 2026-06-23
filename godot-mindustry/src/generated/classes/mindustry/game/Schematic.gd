# Generated from Mindustry upstream.
# Source: mindustry/game/Schematic.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "Schematic"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Publishable", "Comparable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "tiles", "type": "Seq"}, {"modifiers": ["public"], "name": "labels", "type": "Seq"}, {"modifiers": ["public"], "name": "tags", "type": "StringMap"}, {"modifiers": ["public"], "name": "width", "type": "int"}, {"modifiers": ["public"], "name": "height", "type": "int"}, {"modifiers": ["public"], "name": "file", "type": "Fi"}, {"modifiers": ["public"], "name": "mod", "type": "LoadedMod"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Schematic", "parameters": [{"name": "tiles", "type": "Seq", "varargs": false}, {"name": "tags", "type": "StringMap", "varargs": false}, {"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "powerProduction", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "powerConsumption", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "requirements", "parameters": [], "return_type": "ItemSeq"}, {"modifiers": ["public"], "name": "hasCore", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findCore", "parameters": [], "return_type": "CoreBlock"}, {"modifiers": ["public"], "name": "name", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "description", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "save", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getSteamID", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "addSteamID", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeSteamID", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "steamTitle", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "steamDescription", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "steamTag", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "createSteamFolder", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "createSteamPreview", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_powerProduction_0(_args: Array = []) -> Variant:
	return null

func java_method_powerConsumption_1(_args: Array = []) -> Variant:
	return null

func java_method_requirements_2(_args: Array = []) -> Variant:
	return null

func java_method_hasCore_3(_args: Array = []) -> Variant:
	return null

func java_method_findCore_4(_args: Array = []) -> Variant:
	return null

func java_method_name_5(_args: Array = []) -> Variant:
	return null

func java_method_description_6(_args: Array = []) -> Variant:
	return null

func java_method_save_7(_args: Array = []) -> Variant:
	return null

func java_method_getSteamID_8(_args: Array = []) -> Variant:
	return null

func java_method_addSteamID_9(_args: Array = []) -> Variant:
	return null

func java_method_removeSteamID_10(_args: Array = []) -> Variant:
	return null

func java_method_steamTitle_11(_args: Array = []) -> Variant:
	return null

func java_method_steamDescription_12(_args: Array = []) -> Variant:
	return null

func java_method_steamTag_13(_args: Array = []) -> Variant:
	return null

func java_method_createSteamFolder_14(_args: Array = []) -> Variant:
	return null

func java_method_createSteamPreview_15(_args: Array = []) -> Variant:
	return null

func java_method_compareTo_16(_args: Array = []) -> Variant:
	return null
