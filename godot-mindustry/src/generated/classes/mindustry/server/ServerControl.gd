# Generated from Mindustry upstream.
# Source: server/src/mindustry/server/ServerControl.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.server"
const JAVA_KIND := "class"
const JAVA_NAME := "ServerControl"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["ApplicationListener"]
const JAVA_FIELDS := [{"modifiers": ["protected", "static"], "name": "tags", "type": "String"}, {"modifiers": ["protected", "static"], "name": "dateTime", "type": "DateTimeFormatter"}, {"modifiers": ["protected", "static"], "name": "autosaveDate", "type": "DateTimeFormatter"}, {"modifiers": ["final", "static"], "name": "defaultRuleString", "type": "String"}, {"modifiers": ["public", "static"], "name": "instance", "type": "ServerControl"}, {"modifiers": ["final", "public"], "name": "handler", "type": "CommandHandler"}, {"modifiers": ["final", "public"], "name": "logFolder", "type": "Fi"}, {"modifiers": ["final", "private"], "name": "autosaveCount", "type": "Interval"}, {"modifiers": ["public"], "name": "currentLogFile", "type": "Fi"}, {"modifiers": ["public"], "name": "inGameOverWait", "type": "boolean"}, {"modifiers": ["public"], "name": "lastMode", "type": "Gamemode"}, {"modifiers": ["private"], "name": "lastTask", "type": "Task"}, {"modifiers": ["private"], "name": "socketThread", "type": "Thread"}, {"modifiers": ["private"], "name": "serverSocket", "type": "ServerSocket"}, {"modifiers": ["private"], "name": "socketOutput", "type": "PrintWriter"}, {"modifiers": ["private"], "name": "suggested", "type": "String"}, {"modifiers": ["private"], "name": "autoPaused", "type": "boolean"}, {"modifiers": ["private"], "name": "dataAssetDirectory", "type": "Fi"}, {"modifiers": ["private"], "name": "rulesFile", "type": "Fi"}, {"modifiers": ["private"], "name": "dataAssets", "type": "Seq"}, {"modifiers": ["private"], "name": "lineReader", "type": "LineReader"}, {"modifiers": ["public"], "name": "serverInput", "type": "Runnable"}, {"modifiers": ["public"], "name": "gameOverListener", "type": "Cons"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ServerControl", "parameters": [{"name": "args", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "setup", "parameters": [{"name": "args", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "readRulesFile", "parameters": [], "return_type": "JsonValue"}, {"modifiers": [], "name": "loadDataAssets", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "registerCommands", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "handleCommandString", "parameters": [{"name": "line", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "cancelPlayTask", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "play", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "play", "parameters": [{"name": "wait", "type": "boolean", "varargs": false}, {"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "logToFile", "parameters": [{"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toggleSocket", "parameters": [{"name": "on", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setup_0(_args: Array = []) -> Variant:
	return null

func java_method_readRulesFile_1(_args: Array = []) -> Variant:
	return null

func java_method_loadDataAssets_2(_args: Array = []) -> Variant:
	return null

func java_method_registerCommands_3(_args: Array = []) -> Variant:
	return null

func java_method_handleCommandString_4(_args: Array = []) -> Variant:
	return null

func java_method_cancelPlayTask_5(_args: Array = []) -> Variant:
	return null

func java_method_play_6(_args: Array = []) -> Variant:
	return null

func java_method_play_7(_args: Array = []) -> Variant:
	return null

func java_method_logToFile_8(_args: Array = []) -> Variant:
	return null

func java_method_toggleSocket_9(_args: Array = []) -> Variant:
	return null
