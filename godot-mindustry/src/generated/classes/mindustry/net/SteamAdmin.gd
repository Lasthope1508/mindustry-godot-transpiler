# Generated from Mindustry upstream.
# Source: mindustry/net/SteamAdmin.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.net"
const JAVA_KIND := "class"
const JAVA_NAME := "SteamAdmin"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private", "static"], "name": "scheduled", "type": "boolean"}, {"modifiers": ["private", "static"], "name": "data", "type": "SteamAdminData"}, {"modifiers": ["final", "private", "static"], "name": "checkInterval", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "fetch", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "fetch", "parameters": [{"name": "cacheBust", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "fetchImpl", "parameters": [{"name": "githubURL", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "fetch", "parameters": [{"name": "url", "type": "String", "varargs": false}, {"name": "fail", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "isBanned", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "isAdmin", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_fetch_0(_args: Array = []) -> Variant:
	return null

func java_method_fetch_1(_args: Array = []) -> Variant:
	return null

func java_method_fetchImpl_2(_args: Array = []) -> Variant:
	return null

func java_method_fetch_3(_args: Array = []) -> Variant:
	return null

func java_method_isBanned_4(_args: Array = []) -> Variant:
	return null

func java_method_isAdmin_5(_args: Array = []) -> Variant:
	return null
