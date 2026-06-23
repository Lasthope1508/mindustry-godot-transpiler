# Generated from Mindustry upstream.
# Source: mindustry/ClientLauncher.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry"
const JAVA_KIND := "class"
const JAVA_NAME := "ClientLauncher"
const JAVA_EXTENDS := "ApplicationCore"
const JAVA_IMPLEMENTS := ["Platform"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "loadingFPS", "type": "int"}, {"modifiers": ["private"], "name": "nextFrame", "type": "long"}, {"modifiers": ["private"], "name": "beginTime", "type": "long"}, {"modifiers": ["private"], "name": "lastTargetFps", "type": "long"}, {"modifiers": ["private"], "name": "finished", "type": "boolean"}, {"modifiers": ["private"], "name": "loader", "type": "LoadRenderer"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "module", "type": "ApplicationListener", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "resize", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "exit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resume", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "pause", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "fileDropped", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setup_0(_args: Array = []) -> Variant:
	return null

func java_method_add_1(_args: Array = []) -> Variant:
	return null

func java_method_resize_2(_args: Array = []) -> Variant:
	return null

func java_method_update_3(_args: Array = []) -> Variant:
	return null

func java_method_exit_4(_args: Array = []) -> Variant:
	return null

func java_method_init_5(_args: Array = []) -> Variant:
	return null

func java_method_resume_6(_args: Array = []) -> Variant:
	return null

func java_method_pause_7(_args: Array = []) -> Variant:
	return null

func java_method_fileDropped_8(_args: Array = []) -> Variant:
	return null
