# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/LoadDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "LoadDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": [], "name": "slots", "type": "Table"}, {"modifiers": [], "name": "searchString", "type": "String"}, {"modifiers": [], "name": "hidden", "type": "Seq"}, {"modifiers": [], "name": "searchField", "type": "TextField"}, {"modifiers": [], "name": "pane", "type": "ScrollPane"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LoadDialog", "parameters": []}, {"modifiers": ["public"], "name": "LoadDialog", "parameters": [{"name": "title", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "rebuild", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addSetup", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "runLoadSave", "parameters": [{"name": "slot", "type": "SaveSlot", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "modifyButton", "parameters": [{"name": "button", "type": "TextButton", "varargs": false}, {"name": "slot", "type": "SaveSlot", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [], "return_type": "Dialog"}]
const JAVA_ENUM_CONSTANTS := []
