# Generated from Mindustry upstream.
# Source: mindustry/core/FileTree.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "class"
const JAVA_NAME := "FileTree"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["FileHandleResolver"]
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "files", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "loadedSounds", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "loadedMusic", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addFile", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "f", "type": "Fi", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "path", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "path", "type": "String", "varargs": false}, {"name": "safe", "type": "boolean", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resolve", "parameters": [{"name": "fileName", "type": "String", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "loadSound", "parameters": [{"name": "soundName", "type": "String", "varargs": false}], "return_type": "Sound"}, {"modifiers": ["public"], "name": "loadMusic", "parameters": [{"name": "musicName", "type": "String", "varargs": false}], "return_type": "Music"}, {"modifiers": ["private", "static"], "name": "getAudioPath", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addFile_0(_args: Array = []) -> Variant:
	return null

func java_method_get_1(_args: Array = []) -> Variant:
	return null

func java_method_get_2(_args: Array = []) -> Variant:
	return null

func java_method_clear_3(_args: Array = []) -> Variant:
	return null

func java_method_resolve_4(_args: Array = []) -> Variant:
	return null

func java_method_loadSound_5(_args: Array = []) -> Variant:
	return null

func java_method_loadMusic_6(_args: Array = []) -> Variant:
	return null

func java_method_getAudioPath_7(_args: Array = []) -> Variant:
	return null
