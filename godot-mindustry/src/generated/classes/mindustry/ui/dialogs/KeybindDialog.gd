# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/KeybindDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "KeybindDialog"
const JAVA_EXTENDS := "Dialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["protected"], "name": "rebindKey", "type": "KeyBind"}, {"modifiers": ["protected"], "name": "rebindAxis", "type": "boolean"}, {"modifiers": ["protected"], "name": "rebindMin", "type": "boolean"}, {"modifiers": ["protected"], "name": "minKey", "type": "KeyCode"}, {"modifiers": ["protected"], "name": "rebindDialog", "type": "Dialog"}, {"modifiers": ["protected"], "name": "bindsTable", "type": "Table"}, {"modifiers": ["private"], "name": "searchText", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "KeybindDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addCloseButton", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "rebuildBinds", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "rebind", "parameters": [{"name": "bind", "type": "KeyBind", "varargs": false}, {"name": "newKey", "type": "KeyCode", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "openDialog", "parameters": [{"name": "name", "type": "KeyBind", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addCloseButton_0(_args: Array = []) -> Variant:
	return null

func java_method_rebuildBinds_1(_args: Array = []) -> Variant:
	return null

func java_method_rebind_2(_args: Array = []) -> Variant:
	return null

func java_method_openDialog_3(_args: Array = []) -> Variant:
	return null
