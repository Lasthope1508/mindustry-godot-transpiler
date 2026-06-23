# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/SettingsMenuDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "SettingsMenuDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "graphics", "type": "SettingsTable"}, {"modifiers": ["public"], "name": "game", "type": "SettingsTable"}, {"modifiers": ["public"], "name": "sound", "type": "SettingsTable"}, {"modifiers": ["public"], "name": "dev", "type": "SettingsTable"}, {"modifiers": ["public"], "name": "main", "type": "SettingsTable"}, {"modifiers": ["private"], "name": "prefs", "type": "Table"}, {"modifiers": ["private"], "name": "menu", "type": "Table"}, {"modifiers": ["private"], "name": "dataDialog", "type": "BaseDialog"}, {"modifiers": ["private"], "name": "planetDataDialog", "type": "BaseDialog"}, {"modifiers": ["private"], "name": "planet", "type": "Planet"}, {"modifiers": ["private"], "name": "categories", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SettingsMenuDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": [], "name": "getLogs", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "addCategory", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "region", "type": "String", "varargs": false}, {"name": "builder", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addCategory", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "icon", "type": "Drawable", "varargs": false}, {"name": "builder", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addCategory", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "builder", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getCategories", "parameters": [], "return_type": "Seq"}, {"modifiers": [], "name": "rebuildMenu", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addSettings", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "exportData", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "importData", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "back", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "visible", "parameters": [{"name": "index", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addCloseButton", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getLogs_0(_args: Array = []) -> Variant:
	return null

func java_method_addCategory_1(_args: Array = []) -> Variant:
	return null

func java_method_addCategory_2(_args: Array = []) -> Variant:
	return null

func java_method_addCategory_3(_args: Array = []) -> Variant:
	return null

func java_method_getCategories_4(_args: Array = []) -> Variant:
	return null

func java_method_rebuildMenu_5(_args: Array = []) -> Variant:
	return null

func java_method_addSettings_6(_args: Array = []) -> Variant:
	return null

func java_method_exportData_7(_args: Array = []) -> Variant:
	return null

func java_method_importData_8(_args: Array = []) -> Variant:
	return null

func java_method_back_9(_args: Array = []) -> Variant:
	return null

func java_method_visible_10(_args: Array = []) -> Variant:
	return null

func java_method_addCloseButton_11(_args: Array = []) -> Variant:
	return null
