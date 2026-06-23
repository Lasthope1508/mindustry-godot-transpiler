# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/BaseDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "BaseDialog"
const JAVA_EXTENDS := "Dialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["protected"], "name": "wasPaused", "type": "boolean"}, {"modifiers": ["protected"], "name": "shouldPause", "type": "boolean"}, {"modifiers": ["protected"], "name": "titleImage", "type": "Image"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BaseDialog", "parameters": [{"name": "title", "type": "String", "varargs": false}, {"name": "style", "type": "DialogStyle", "varargs": false}]}, {"modifiers": ["public"], "name": "BaseDialog", "parameters": [{"name": "title", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setTitleColor", "parameters": [{"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "makeButtonOverlay", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "onResize", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addCloseListener", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addCloseButton", "parameters": [{"name": "width", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addCloseButton", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
