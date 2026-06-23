# Generated from Mindustry upstream.
# Source: mindustry/net/CrashHandler.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.net"
const JAVA_KIND := "class"
const JAVA_NAME := "CrashHandler"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "createReport", "parameters": [{"name": "exception", "type": "Throwable", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "log", "parameters": [{"name": "exception", "type": "Throwable", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "handle", "parameters": [{"name": "exception", "type": "Throwable", "varargs": false}, {"name": "writeListener", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "getModCause", "parameters": [{"name": "e", "type": "Throwable", "varargs": false}], "return_type": "LoadedMod"}, {"modifiers": ["private", "static"], "name": "getMatches", "parameters": [{"name": "name1", "type": "String", "varargs": false}, {"name": "name2", "type": "String", "varargs": false}], "return_type": "int"}, {"modifiers": ["private", "static"], "name": "writeException", "parameters": [{"name": "e", "type": "Throwable", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_createReport_0(_args: Array = []) -> Variant:
	return null

func java_method_log_1(_args: Array = []) -> Variant:
	return null

func java_method_handle_2(_args: Array = []) -> Variant:
	return null

func java_method_getModCause_3(_args: Array = []) -> Variant:
	return null

func java_method_getMatches_4(_args: Array = []) -> Variant:
	return null

func java_method_writeException_5(_args: Array = []) -> Variant:
	return null
