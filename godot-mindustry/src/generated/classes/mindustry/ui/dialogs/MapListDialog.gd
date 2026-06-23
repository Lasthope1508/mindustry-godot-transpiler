# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/MapListDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "MapListDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": [], "name": "activeDialog", "type": "BaseDialog"}, {"modifiers": ["private"], "name": "searchString", "type": "String"}, {"modifiers": ["private"], "name": "modes", "type": "Seq"}, {"modifiers": ["private"], "name": "availablePlanets", "type": "Seq"}, {"modifiers": ["private"], "name": "mapTable", "type": "Table"}, {"modifiers": ["private"], "name": "searchField", "type": "TextField"}, {"modifiers": ["private"], "name": "rulesCache", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "showBuiltIn", "type": "boolean"}, {"modifiers": ["private"], "name": "showCustom", "type": "boolean"}, {"modifiers": ["private"], "name": "showModded", "type": "boolean"}, {"modifiers": ["private"], "name": "searchAuthor", "type": "boolean"}, {"modifiers": ["private"], "name": "searchDescription", "type": "boolean"}, {"modifiers": ["private"], "name": "searchModname", "type": "boolean"}, {"modifiers": ["private"], "name": "prioritizeModded", "type": "boolean"}, {"modifiers": ["private"], "name": "prioritizeCustom", "type": "boolean"}, {"modifiers": ["private"], "name": "displayType", "type": "boolean"}, {"modifiers": ["private"], "name": "planets", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapListDialog", "parameters": [{"name": "title", "type": "String", "varargs": false}, {"name": "displayType", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": [], "name": "buildButtons", "parameters": [], "return_type": ""}, {"modifiers": ["abstract"], "name": "showMap", "parameters": [{"name": "map", "type": "Map", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "rebuildMaps", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "showMapFilters", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [], "return_type": "Dialog"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_buildButtons_0(_args: Array = []) -> Variant:
	return null

func java_method_showMap_1(_args: Array = []) -> Variant:
	return null

func java_method_setup_2(_args: Array = []) -> Variant:
	return null

func java_method_rebuildMaps_3(_args: Array = []) -> Variant:
	return null

func java_method_showMapFilters_4(_args: Array = []) -> Variant:
	return null

func java_method_show_5(_args: Array = []) -> Variant:
	return null
