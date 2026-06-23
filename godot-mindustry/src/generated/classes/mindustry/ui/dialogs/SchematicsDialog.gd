# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/SchematicsDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "SchematicsDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tagh", "type": "float"}, {"modifiers": ["private"], "name": "info", "type": "SchematicInfoDialog"}, {"modifiers": ["private"], "name": "firstSchematic", "type": "Schematic"}, {"modifiers": ["private"], "name": "search", "type": "String"}, {"modifiers": ["private"], "name": "searchField", "type": "TextField"}, {"modifiers": ["private"], "name": "rebuildPane", "type": "Runnable"}, {"modifiers": ["private"], "name": "rebuildTags", "type": "Runnable"}, {"modifiers": ["private"], "name": "ignoreSymbols", "type": "Pattern"}, {"modifiers": ["private"], "name": "tags", "type": "Seq"}, {"modifiers": ["private"], "name": "selectedTags", "type": "Seq"}, {"modifiers": ["private"], "name": "checkedTags", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SchematicsDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "showInfo", "parameters": [{"name": "schematic", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showImport", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "showExport", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showEdit", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "checkTags", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "checkTags", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "tagsChanged", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addTag", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}, {"name": "tag", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "removeTag", "parameters": [{"name": "s", "type": "Schematic", "varargs": false}, {"name": "tag", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "showNewTag", "parameters": [{"name": "result", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "showNewIconTag", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "showAllTags", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "buildTags", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "t", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "buildTags", "parameters": [{"name": "schem", "type": "Schematic", "varargs": false}, {"name": "t", "type": "Table", "varargs": false}, {"name": "name", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [], "return_type": "Dialog"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setup_0(_args: Array = []) -> Variant:
	return null

func java_method_showInfo_1(_args: Array = []) -> Variant:
	return null

func java_method_showImport_2(_args: Array = []) -> Variant:
	return null

func java_method_showExport_3(_args: Array = []) -> Variant:
	return null

func java_method_showEdit_4(_args: Array = []) -> Variant:
	return null

func java_method_checkTags_5(_args: Array = []) -> Variant:
	return null

func java_method_checkTags_6(_args: Array = []) -> Variant:
	return null

func java_method_tagsChanged_7(_args: Array = []) -> Variant:
	return null

func java_method_addTag_8(_args: Array = []) -> Variant:
	return null

func java_method_removeTag_9(_args: Array = []) -> Variant:
	return null

func java_method_showNewTag_10(_args: Array = []) -> Variant:
	return null

func java_method_showNewIconTag_11(_args: Array = []) -> Variant:
	return null

func java_method_showAllTags_12(_args: Array = []) -> Variant:
	return null

func java_method_buildTags_13(_args: Array = []) -> Variant:
	return null

func java_method_buildTags_14(_args: Array = []) -> Variant:
	return null

func java_method_show_15(_args: Array = []) -> Variant:
	return null
