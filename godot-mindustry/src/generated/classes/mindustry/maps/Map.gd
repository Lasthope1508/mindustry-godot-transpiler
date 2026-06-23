# Generated from Mindustry upstream.
# Source: mindustry/maps/Map.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps"
const JAVA_KIND := "class"
const JAVA_NAME := "Map"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable", "Publishable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "custom", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "tags", "type": "StringMap"}, {"modifiers": ["final", "public"], "name": "file", "type": "Fi"}, {"modifiers": ["final", "public"], "name": "version", "type": "int"}, {"modifiers": ["public"], "name": "workshop", "type": "boolean"}, {"modifiers": ["public"], "name": "width", "type": "int"}, {"modifiers": ["public"], "name": "height", "type": "int"}, {"modifiers": ["public"], "name": "texture", "type": "Texture"}, {"modifiers": ["public"], "name": "build", "type": "int"}, {"modifiers": ["public"], "name": "teams", "type": "IntSet"}, {"modifiers": ["public"], "name": "spawns", "type": "int"}, {"modifiers": ["public"], "name": "mod", "type": "LoadedMod"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Map", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}, {"name": "tags", "type": "StringMap", "varargs": false}, {"name": "custom", "type": "boolean", "varargs": false}, {"name": "version", "type": "int", "varargs": false}, {"name": "build", "type": "int", "varargs": false}]}, {"modifiers": ["public"], "name": "Map", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}, {"name": "tags", "type": "StringMap", "varargs": false}, {"name": "custom", "type": "boolean", "varargs": false}, {"name": "version", "type": "int", "varargs": false}]}, {"modifiers": ["public"], "name": "Map", "parameters": [{"name": "file", "type": "Fi", "varargs": false}, {"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}, {"name": "tags", "type": "StringMap", "varargs": false}, {"name": "custom", "type": "boolean", "varargs": false}]}, {"modifiers": ["public"], "name": "Map", "parameters": [{"name": "tags", "type": "StringMap", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getHightScore", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "safeTexture", "parameters": [], "return_type": "Texture"}, {"modifiers": ["public"], "name": "previewFile", "parameters": [], "return_type": "Fi"}, {"modifiers": ["public"], "name": "cacheFile", "parameters": [], "return_type": "Fi"}, {"modifiers": ["public"], "name": "setHighScore", "parameters": [{"name": "score", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "applyRules", "parameters": [{"name": "mode", "type": "Gamemode", "varargs": false}], "return_type": "Rules"}, {"modifiers": ["public"], "name": "rules", "parameters": [], "return_type": "Rules"}, {"modifiers": ["public"], "name": "rules", "parameters": [{"name": "base", "type": "Rules", "varargs": false}], "return_type": "Rules"}, {"modifiers": ["public"], "name": "filters", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "name", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "author", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "description", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "plainName", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "plainAuthor", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "plainDescription", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "tag", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "hasTag", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getSteamID", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "addSteamID", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeSteamID", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "steamTitle", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "steamDescription", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "steamTag", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "createSteamFolder", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "createSteamPreview", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "extraTags", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "prePublish", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getHightScore_0(_args: Array = []) -> Variant:
	return null

func java_method_safeTexture_1(_args: Array = []) -> Variant:
	return null

func java_method_previewFile_2(_args: Array = []) -> Variant:
	return null

func java_method_cacheFile_3(_args: Array = []) -> Variant:
	return null

func java_method_setHighScore_4(_args: Array = []) -> Variant:
	return null

func java_method_applyRules_5(_args: Array = []) -> Variant:
	return null

func java_method_rules_6(_args: Array = []) -> Variant:
	return null

func java_method_rules_7(_args: Array = []) -> Variant:
	return null

func java_method_filters_8(_args: Array = []) -> Variant:
	return null

func java_method_name_9(_args: Array = []) -> Variant:
	return null

func java_method_author_10(_args: Array = []) -> Variant:
	return null

func java_method_description_11(_args: Array = []) -> Variant:
	return null

func java_method_plainName_12(_args: Array = []) -> Variant:
	return null

func java_method_plainAuthor_13(_args: Array = []) -> Variant:
	return null

func java_method_plainDescription_14(_args: Array = []) -> Variant:
	return null

func java_method_tag_15(_args: Array = []) -> Variant:
	return null

func java_method_hasTag_16(_args: Array = []) -> Variant:
	return null

func java_method_getSteamID_17(_args: Array = []) -> Variant:
	return null

func java_method_addSteamID_18(_args: Array = []) -> Variant:
	return null

func java_method_removeSteamID_19(_args: Array = []) -> Variant:
	return null

func java_method_steamTitle_20(_args: Array = []) -> Variant:
	return null

func java_method_steamDescription_21(_args: Array = []) -> Variant:
	return null

func java_method_steamTag_22(_args: Array = []) -> Variant:
	return null

func java_method_createSteamFolder_23(_args: Array = []) -> Variant:
	return null

func java_method_createSteamPreview_24(_args: Array = []) -> Variant:
	return null

func java_method_extraTags_25(_args: Array = []) -> Variant:
	return null

func java_method_prePublish_26(_args: Array = []) -> Variant:
	return null

func java_method_compareTo_27(_args: Array = []) -> Variant:
	return null

func java_method_toString_28(_args: Array = []) -> Variant:
	return null
