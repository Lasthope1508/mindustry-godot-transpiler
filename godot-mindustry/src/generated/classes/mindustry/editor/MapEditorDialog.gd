# Generated from Mindustry upstream.
# Source: mindustry/editor/MapEditorDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "MapEditorDialog"
const JAVA_EXTENDS := "Dialog"
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "view", "type": "MapView"}, {"modifiers": ["private"], "name": "infoDialog", "type": "MapInfoDialog"}, {"modifiers": ["private"], "name": "loadDialog", "type": "MapLoadDialog"}, {"modifiers": ["private"], "name": "resizeDialog", "type": "MapResizeDialog"}, {"modifiers": ["private"], "name": "generateDialog", "type": "MapGenerateDialog"}, {"modifiers": ["private"], "name": "sectorGenDialog", "type": "SectorGenerateDialog"}, {"modifiers": ["private"], "name": "playtestDialog", "type": "MapPlayDialog"}, {"modifiers": ["private"], "name": "pane", "type": "ScrollPane"}, {"modifiers": ["private"], "name": "menu", "type": "BaseDialog"}, {"modifiers": ["private"], "name": "blockSelection", "type": "Table"}, {"modifiers": ["private"], "name": "lastSavedRules", "type": "Rules"}, {"modifiers": ["private"], "name": "saved", "type": "boolean"}, {"modifiers": ["private"], "name": "shownWithMap", "type": "boolean"}, {"modifiers": ["private"], "name": "blocksOut", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapEditorDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "resumeEditing", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "editInGame", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resumeAfterPlaytest", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "playtest", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "save", "parameters": [], "return_type": "Map"}, {"modifiers": ["protected"], "name": "handleSaveBuiltin", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "createDialog", "parameters": [{"name": "title", "type": "String", "varargs": false}, {"name": "arguments", "type": "Object", "varargs": true}], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [], "return_type": "Dialog"}, {"modifiers": ["public"], "name": "hide", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "beginEditMap", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getView", "parameters": [], "return_type": "MapView"}, {"modifiers": ["public"], "name": "getGenerateDialog", "parameters": [], "return_type": "MapGenerateDialog"}, {"modifiers": ["public"], "name": "resetSaved", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hasPane", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "build", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "doInput", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "tryExit", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "addBlockSelection", "parameters": [{"name": "cont", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rebuildBlockSelection", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "rebuildBlockSelection", "parameters": [{"name": "searchText", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_resumeEditing_0(_args: Array = []) -> Variant:
	return null

func java_method_editInGame_1(_args: Array = []) -> Variant:
	return null

func java_method_resumeAfterPlaytest_2(_args: Array = []) -> Variant:
	return null

func java_method_playtest_3(_args: Array = []) -> Variant:
	return null

func java_method_save_4(_args: Array = []) -> Variant:
	return null

func java_method_handleSaveBuiltin_5(_args: Array = []) -> Variant:
	return null

func java_method_createDialog_6(_args: Array = []) -> Variant:
	return null

func java_method_show_7(_args: Array = []) -> Variant:
	return null

func java_method_hide_8(_args: Array = []) -> Variant:
	return null

func java_method_dispose_9(_args: Array = []) -> Variant:
	return null

func java_method_beginEditMap_10(_args: Array = []) -> Variant:
	return null

func java_method_getView_11(_args: Array = []) -> Variant:
	return null

func java_method_getGenerateDialog_12(_args: Array = []) -> Variant:
	return null

func java_method_resetSaved_13(_args: Array = []) -> Variant:
	return null

func java_method_hasPane_14(_args: Array = []) -> Variant:
	return null

func java_method_build_15(_args: Array = []) -> Variant:
	return null

func java_method_doInput_16(_args: Array = []) -> Variant:
	return null

func java_method_tryExit_17(_args: Array = []) -> Variant:
	return null

func java_method_addBlockSelection_18(_args: Array = []) -> Variant:
	return null

func java_method_rebuildBlockSelection_19(_args: Array = []) -> Variant:
	return null

func java_method_rebuildBlockSelection_20(_args: Array = []) -> Variant:
	return null
