# Generated from Mindustry upstream.
# Source: mindustry/mod/Scripts.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.mod"
const JAVA_KIND := "class"
const JAVA_NAME := "Scripts"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Disposable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "context", "type": "Context"}, {"modifiers": ["final", "public"], "name": "scope", "type": "Scriptable"}, {"modifiers": ["private"], "name": "errored", "type": "boolean"}, {"modifiers": [], "name": "currentMod", "type": "LoadedMod"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Scripts", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "hasErrored", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "runConsole", "parameters": [{"name": "text", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["private"], "name": "getError", "parameters": [{"name": "t", "type": "Throwable", "varargs": false}, {"name": "log", "type": "boolean", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "log", "parameters": [{"name": "source", "type": "String", "varargs": false}, {"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "log", "parameters": [{"name": "level", "type": "LogLevel", "varargs": false}, {"name": "source", "type": "String", "varargs": false}, {"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "newFloats", "parameters": [{"name": "capacity", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "getClass", "parameters": [{"name": "object", "type": "Object", "varargs": false}], "return_type": "Class"}, {"modifiers": ["public"], "name": "run", "parameters": [{"name": "mod", "type": "LoadedMod", "varargs": false}, {"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "run", "parameters": [{"name": "script", "type": "String", "varargs": false}, {"name": "file", "type": "String", "varargs": false}, {"name": "wrap", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_hasErrored_0(_args: Array = []) -> Variant:
	return null

func java_method_runConsole_1(_args: Array = []) -> Variant:
	return null

func java_method_getError_2(_args: Array = []) -> Variant:
	return null

func java_method_log_3(_args: Array = []) -> Variant:
	return null

func java_method_log_4(_args: Array = []) -> Variant:
	return null

func java_method_newFloats_5(_args: Array = []) -> Variant:
	return null

func java_method_getClass_6(_args: Array = []) -> Variant:
	return null

func java_method_run_7(_args: Array = []) -> Variant:
	return null

func java_method_run_8(_args: Array = []) -> Variant:
	return null

func java_method_dispose_9(_args: Array = []) -> Variant:
	return null
