# Generated from Mindustry upstream.
# Source: mindustry/logic/LogicDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LogicDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "canvas", "type": "LCanvas"}, {"modifiers": [], "name": "consumer", "type": "Cons"}, {"modifiers": [], "name": "privileged", "type": "boolean"}, {"modifiers": [], "name": "executor", "type": "LExecutor"}, {"modifiers": [], "name": "globalsDialog", "type": "GlobalVarsDialog"}, {"modifiers": [], "name": "wasRows", "type": "boolean"}, {"modifiers": [], "name": "wasPortrait", "type": "boolean"}, {"modifiers": [], "name": "forceRestart", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LogicDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "typeColor", "parameters": [{"name": "s", "type": "LVar", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": "Color"}, {"modifiers": ["public", "static"], "name": "typeName", "parameters": [{"name": "s", "type": "LVar", "varargs": false}], "return_type": "String"}, {"modifiers": ["private"], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "shouldShowVariables", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "showAddDialog", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "showAddDialog", "parameters": [{"name": "position", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "show", "parameters": [{"name": "code", "type": "String", "varargs": false}, {"name": "executor", "type": "LExecutor", "varargs": false}, {"name": "privileged", "type": "boolean", "varargs": false}, {"name": "modified", "type": "Cons", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
