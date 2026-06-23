# Generated from Mindustry upstream.
# Source: mindustry/type/TeamEntry.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "TeamEntry"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "team", "type": "Team"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "TeamEntry", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}]}, {"modifiers": ["public"], "name": "TeamEntry", "parameters": [{"name": "team", "type": "Team", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "displayExtra", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_displayExtra_0(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_1(_args: Array = []) -> Variant:
	return null
