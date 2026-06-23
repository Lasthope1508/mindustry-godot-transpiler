# Generated from Mindustry upstream.
# Source: mindustry/logic/LParser.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LParser"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tokens", "type": "String"}, {"modifiers": ["final", "private", "static"], "name": "maxJumps", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "opNameChanges", "type": "StringMap"}, {"modifiers": ["final", "private", "static"], "name": "jumps", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "jumpLocations", "type": "ObjectIntMap"}, {"modifiers": [], "name": "statements", "type": "Seq"}, {"modifiers": [], "name": "chars", "type": "char"}, {"modifiers": [], "name": "pos", "type": "int"}, {"modifiers": [], "name": "line", "type": "int"}, {"modifiers": [], "name": "tok", "type": "int"}, {"modifiers": [], "name": "privileged", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "LParser", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "privileged", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": [], "name": "comment", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "error", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "string", "parameters": [], "return_type": "String"}, {"modifiers": [], "name": "token", "parameters": [], "return_type": "String"}, {"modifiers": [], "name": "checkRead", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "statement", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "parse", "parameters": [], "return_type": "Seq"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_comment_0(_args: Array = []) -> Variant:
	return null

func java_method_error_1(_args: Array = []) -> Variant:
	return null

func java_method_string_2(_args: Array = []) -> Variant:
	return null

func java_method_token_3(_args: Array = []) -> Variant:
	return null

func java_method_checkRead_4(_args: Array = []) -> Variant:
	return null

func java_method_statement_5(_args: Array = []) -> Variant:
	return null

func java_method_parse_6(_args: Array = []) -> Variant:
	return null
