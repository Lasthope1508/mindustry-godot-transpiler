# Generated from Mindustry upstream.
# Source: annotations/src/main/java/mindustry/annotations/remote/CallGenerator.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.annotations.remote"
const JAVA_KIND := "class"
const JAVA_NAME := "CallGenerator"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "generate", "parameters": [{"name": "serializer", "type": "ClassSerializer", "varargs": false}, {"name": "methods", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "makeWriter", "parameters": [{"name": "typespec", "type": "TypeSpec", "varargs": false}, {"name": "ent", "type": "MethodEntry", "varargs": false}, {"name": "serializer", "type": "ClassSerializer", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "makeReader", "parameters": [{"name": "typespec", "type": "TypeSpec", "varargs": false}, {"name": "ent", "type": "MethodEntry", "varargs": false}, {"name": "serializer", "type": "ClassSerializer", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "writeCallMethod", "parameters": [{"name": "classBuilder", "type": "TypeSpec", "varargs": false}, {"name": "ent", "type": "MethodEntry", "varargs": false}, {"name": "toAll", "type": "boolean", "varargs": false}, {"name": "forwarded", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "getCheckString", "parameters": [{"name": "loc", "type": "Loc", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "writeHandleMethod", "parameters": [{"name": "ent", "type": "MethodEntry", "varargs": false}, {"name": "isClient", "type": "boolean", "varargs": false}], "return_type": "MethodSpec"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_generate_0(_args: Array = []) -> Variant:
	return null

func java_method_makeWriter_1(_args: Array = []) -> Variant:
	return null

func java_method_makeReader_2(_args: Array = []) -> Variant:
	return null

func java_method_writeCallMethod_3(_args: Array = []) -> Variant:
	return null

func java_method_getCheckString_4(_args: Array = []) -> Variant:
	return null

func java_method_writeHandleMethod_5(_args: Array = []) -> Variant:
	return null
