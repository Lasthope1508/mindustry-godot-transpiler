# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/FileChooserDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "FileChooserDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "homeDirectory", "type": "Fi"}, {"modifiers": ["static"], "name": "lastDirectory", "type": "Fi"}, {"modifiers": [], "name": "directory", "type": "Fi"}, {"modifiers": ["private"], "name": "files", "type": "Table"}, {"modifiers": ["private"], "name": "pane", "type": "ScrollPane"}, {"modifiers": ["private"], "name": "navigation", "type": "TextField"}, {"modifiers": ["private"], "name": "filefield", "type": "TextField"}, {"modifiers": ["private"], "name": "ok", "type": "TextButton"}, {"modifiers": ["private"], "name": "stack", "type": "FileHistory"}, {"modifiers": ["private"], "name": "filter", "type": "Boolf"}, {"modifiers": ["private"], "name": "selectListener", "type": "Cons"}, {"modifiers": ["private"], "name": "open", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "FileChooserDialog", "parameters": [{"name": "title", "type": "String", "varargs": false}, {"name": "filter", "type": "Boolf", "varargs": false}, {"name": "open", "type": "boolean", "varargs": false}, {"name": "result", "type": "Cons", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["private"], "name": "setupWidgets", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "updateFileFieldStatus", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "getFileNames", "parameters": [], "return_type": "Fi"}, {"modifiers": [], "name": "updateFiles", "parameters": [{"name": "push", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static", "synchronized"], "name": "setLastDirectory", "parameters": [{"name": "directory", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static", "synchronized"], "name": "getLastDirectory", "parameters": [], "return_type": "Fi"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setupWidgets_0(_args: Array = []) -> Variant:
	return null

func java_method_updateFileFieldStatus_1(_args: Array = []) -> Variant:
	return null

func java_method_getFileNames_2(_args: Array = []) -> Variant:
	return null

func java_method_updateFiles_3(_args: Array = []) -> Variant:
	return null

func java_method_setLastDirectory_4(_args: Array = []) -> Variant:
	return null

func java_method_getLastDirectory_5(_args: Array = []) -> Variant:
	return null
