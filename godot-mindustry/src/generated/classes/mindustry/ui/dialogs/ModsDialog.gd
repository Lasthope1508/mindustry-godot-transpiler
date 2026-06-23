# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/ModsDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "ModsDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "textureCache", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "modImportProgress", "type": "float"}, {"modifiers": ["private"], "name": "cancelledImport", "type": "boolean"}, {"modifiers": ["private"], "name": "searchtxt", "type": "String"}, {"modifiers": ["private"], "name": "modList", "type": "Seq"}, {"modifiers": ["private"], "name": "orderDate", "type": "boolean"}, {"modifiers": ["private"], "name": "currentContent", "type": "BaseDialog"}, {"modifiers": ["private"], "name": "browser", "type": "BaseDialog"}, {"modifiers": ["private"], "name": "browserTable", "type": "Table"}, {"modifiers": ["private"], "name": "scroll", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ModsDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": [], "name": "modError", "parameters": [{"name": "error", "type": "Throwable", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "getModList", "parameters": [{"name": "listener", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "getModList", "parameters": [{"name": "index", "type": "int", "varargs": false}, {"name": "listener", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "getStateText", "parameters": [{"name": "item", "type": "LoadedMod", "varargs": false}], "return_type": "String"}, {"modifiers": ["private"], "name": "getStateDetails", "parameters": [{"name": "item", "type": "LoadedMod", "varargs": false}], "return_type": "String"}, {"modifiers": ["private"], "name": "showMod", "parameters": [{"name": "mod", "type": "LoadedMod", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "showModBrowser", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "rebuildBrowser", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "handleMod", "parameters": [{"name": "repo", "type": "String", "varargs": false}, {"name": "result", "type": "HttpResponse", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "importFail", "parameters": [{"name": "t", "type": "Throwable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "githubImportMod", "parameters": [{"name": "repo", "type": "String", "varargs": false}, {"name": "isJava", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "githubImportMod", "parameters": [{"name": "repo", "type": "String", "varargs": false}, {"name": "isJava", "type": "boolean", "varargs": false}, {"name": "release", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "importDependencies", "parameters": [{"name": "dependencies", "type": "Seq", "varargs": false}, {"name": "done", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "githubImportJavaMod", "parameters": [{"name": "repo", "type": "String", "varargs": false}, {"name": "release", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "githubImportBranch", "parameters": [{"name": "branch", "type": "String", "varargs": false}, {"name": "repo", "type": "String", "varargs": false}, {"name": "release", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_modError_0(_args: Array = []) -> Variant:
	return null

func java_method_getModList_1(_args: Array = []) -> Variant:
	return null

func java_method_getModList_2(_args: Array = []) -> Variant:
	return null

func java_method_setup_3(_args: Array = []) -> Variant:
	return null

func java_method_getStateText_4(_args: Array = []) -> Variant:
	return null

func java_method_getStateDetails_5(_args: Array = []) -> Variant:
	return null

func java_method_showMod_6(_args: Array = []) -> Variant:
	return null

func java_method_showModBrowser_7(_args: Array = []) -> Variant:
	return null

func java_method_rebuildBrowser_8(_args: Array = []) -> Variant:
	return null

func java_method_handleMod_9(_args: Array = []) -> Variant:
	return null

func java_method_importFail_10(_args: Array = []) -> Variant:
	return null

func java_method_githubImportMod_11(_args: Array = []) -> Variant:
	return null

func java_method_githubImportMod_12(_args: Array = []) -> Variant:
	return null

func java_method_importDependencies_13(_args: Array = []) -> Variant:
	return null

func java_method_githubImportJavaMod_14(_args: Array = []) -> Variant:
	return null

func java_method_githubImportBranch_15(_args: Array = []) -> Variant:
	return null
