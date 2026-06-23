# Generated from Mindustry upstream.
# Source: mindustry/mod/DataManager.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod"
const JAVA_KIND := "class"
const JAVA_NAME := "DataManager"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "patcher", "type": "DataPatcher"}, {"modifiers": ["private"], "name": "packer", "type": "DataImagePacker"}, {"modifiers": ["private"], "name": "soundLoader", "type": "DataAudioLoader"}, {"modifiers": ["private"], "name": "bundleLoader", "type": "DataBundleLoader"}, {"modifiers": ["private"], "name": "assets", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "orderedAssets", "type": "Seq"}, {"modifiers": ["private"], "name": "orderedExternalAssets", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "reloadContent", "parameters": [{"name": "reloadArrays", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "regenerateContentSprites", "parameters": [{"name": "forcePack", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "reloadPatches", "parameters": [{"name": "patches", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "reloadImages", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reloadImages", "parameters": [{"name": "images", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "reloadAudio", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "newAssets", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "unload", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "rebuildOrderedAssets", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getMissingAssets", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getAllAssets", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "hasAssetPath", "parameters": [{"name": "type", "type": "DataAssetType", "varargs": false}, {"name": "path", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hasAssetName", "parameters": [{"name": "type", "type": "DataAssetType", "varargs": false}, {"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hasAssetNameOrPath", "parameters": [{"name": "type", "type": "DataAssetType", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "path", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "hasExternalAssets", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getAllExternalAssets", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "isPatched", "parameters": [{"name": "content", "type": "Object", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getAssets", "parameters": [{"name": "type", "type": "DataAssetType", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "clearGeneratedImages", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getImages", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getPatches", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getMusic", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getSounds", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getBundles", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getContent", "parameters": [], "return_type": "Seq"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_reloadContent_0(_args: Array = []) -> Variant:
	return null

func java_method_regenerateContentSprites_1(_args: Array = []) -> Variant:
	return null

func java_method_reloadPatches_2(_args: Array = []) -> Variant:
	return null

func java_method_reloadImages_3(_args: Array = []) -> Variant:
	return null

func java_method_reloadImages_4(_args: Array = []) -> Variant:
	return null

func java_method_reloadAudio_5(_args: Array = []) -> Variant:
	return null

func java_method_load_6(_args: Array = []) -> Variant:
	return null

func java_method_unload_7(_args: Array = []) -> Variant:
	return null

func java_method_rebuildOrderedAssets_8(_args: Array = []) -> Variant:
	return null

func java_method_getMissingAssets_9(_args: Array = []) -> Variant:
	return null

func java_method_getAllAssets_10(_args: Array = []) -> Variant:
	return null

func java_method_hasAssetPath_11(_args: Array = []) -> Variant:
	return null

func java_method_hasAssetName_12(_args: Array = []) -> Variant:
	return null

func java_method_hasAssetNameOrPath_13(_args: Array = []) -> Variant:
	return null

func java_method_hasExternalAssets_14(_args: Array = []) -> Variant:
	return null

func java_method_getAllExternalAssets_15(_args: Array = []) -> Variant:
	return null

func java_method_isPatched_16(_args: Array = []) -> Variant:
	return null

func java_method_getAssets_17(_args: Array = []) -> Variant:
	return null

func java_method_clearGeneratedImages_18(_args: Array = []) -> Variant:
	return null

func java_method_getImages_19(_args: Array = []) -> Variant:
	return null

func java_method_getPatches_20(_args: Array = []) -> Variant:
	return null

func java_method_getMusic_21(_args: Array = []) -> Variant:
	return null

func java_method_getSounds_22(_args: Array = []) -> Variant:
	return null

func java_method_getBundles_23(_args: Array = []) -> Variant:
	return null

func java_method_getContent_24(_args: Array = []) -> Variant:
	return null
