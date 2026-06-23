# Generated from Mindustry upstream.
# Source: mindustry/logic/GlobalVars.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "GlobalVars"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "ctrlProcessor", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "ctrlPlayer", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "ctrlCommand", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "lookableContent", "type": "ContentType"}, {"modifiers": ["final", "public", "static"], "name": "writableLookableContent", "type": "ContentType"}, {"modifiers": ["final", "public", "static"], "name": "rand", "type": "Rand"}, {"modifiers": ["private", "static"], "name": "varTime", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varTick", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varSecond", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varMinute", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varWave", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varWaveTime", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varMapW", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varMapH", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varWait", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varServer", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varClient", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varClientLocale", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varClientUnit", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varClientName", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varClientTeam", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varClientMobile", "type": "LVar"}, {"modifiers": ["private", "static"], "name": "varClientMusicPlaying", "type": "LVar"}, {"modifiers": ["private"], "name": "vars", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "varEntries", "type": "Seq"}, {"modifiers": ["private"], "name": "privilegedNames", "type": "ObjectSet"}, {"modifiers": ["private"], "name": "logicIdToContent", "type": "UnlockableContent"}, {"modifiers": ["private"], "name": "contentIdToLogicId", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "soundNames", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "waitVar", "parameters": [], "return_type": "LVar"}, {"modifiers": ["public"], "name": "getEntries", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "lookupContent", "parameters": [{"name": "type", "type": "ContentType", "varargs": false}, {"name": "id", "type": "int", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "lookupLogicId", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "LVar"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "privileged", "type": "boolean", "varargs": false}], "return_type": "LVar"}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "value", "type": "double", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "put", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}, {"name": "privileged", "type": "boolean", "varargs": false}], "return_type": "LVar"}, {"modifiers": ["public"], "name": "put", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}, {"name": "privileged", "type": "boolean", "varargs": false}, {"name": "hidden", "type": "boolean", "varargs": false}], "return_type": "LVar"}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "lvar", "type": "LVar", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "put", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": "LVar"}, {"modifiers": ["public"], "name": "putEntry", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}], "return_type": "LVar"}, {"modifiers": ["public"], "name": "putEntry", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "value", "type": "Object", "varargs": false}, {"name": "privileged", "type": "boolean", "varargs": false}], "return_type": "LVar"}, {"modifiers": ["public"], "name": "putEntryOnly", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_update_1(_args: Array = []) -> Variant:
	return null

func java_method_waitVar_2(_args: Array = []) -> Variant:
	return null

func java_method_getEntries_3(_args: Array = []) -> Variant:
	return null

func java_method_lookupContent_4(_args: Array = []) -> Variant:
	return null

func java_method_lookupLogicId_5(_args: Array = []) -> Variant:
	return null

func java_method_get_6(_args: Array = []) -> Variant:
	return null

func java_method_get_7(_args: Array = []) -> Variant:
	return null

func java_method_set_8(_args: Array = []) -> Variant:
	return null

func java_method_put_9(_args: Array = []) -> Variant:
	return null

func java_method_put_10(_args: Array = []) -> Variant:
	return null

func java_method_remove_11(_args: Array = []) -> Variant:
	return null

func java_method_put_12(_args: Array = []) -> Variant:
	return null

func java_method_putEntry_13(_args: Array = []) -> Variant:
	return null

func java_method_putEntry_14(_args: Array = []) -> Variant:
	return null

func java_method_putEntryOnly_15(_args: Array = []) -> Variant:
	return null
