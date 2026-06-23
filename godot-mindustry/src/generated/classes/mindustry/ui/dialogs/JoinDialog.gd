# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/JoinDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "JoinDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": [], "name": "tmpServers", "type": "Seq"}, {"modifiers": [], "name": "servers", "type": "Seq"}, {"modifiers": [], "name": "add", "type": "Dialog"}, {"modifiers": [], "name": "renaming", "type": "Server"}, {"modifiers": [], "name": "local", "type": "Table"}, {"modifiers": [], "name": "remote", "type": "Table"}, {"modifiers": [], "name": "global", "type": "Table"}, {"modifiers": [], "name": "hosts", "type": "Table"}, {"modifiers": [], "name": "totalHosts", "type": "int"}, {"modifiers": [], "name": "refreshes", "type": "int"}, {"modifiers": [], "name": "showHidden", "type": "boolean"}, {"modifiers": [], "name": "style", "type": "TextButtonStyle"}, {"modifiers": [], "name": "fontIgnoreDirtyTask", "type": "Task"}, {"modifiers": [], "name": "lastIp", "type": "String"}, {"modifiers": [], "name": "lastPort", "type": "int"}, {"modifiers": [], "name": "lastColumns", "type": "int"}, {"modifiers": [], "name": "ping", "type": "Task"}, {"modifiers": [], "name": "serverSearch", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "JoinDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": [], "name": "refreshAll", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "setupRemote", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "moveRemote", "parameters": [{"name": "server", "type": "Server", "varargs": false}, {"name": "sign", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "refreshRemote", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "refreshServer", "parameters": [{"name": "server", "type": "Server", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "setupServer", "parameters": [{"name": "server", "type": "Server", "varargs": false}, {"name": "host", "type": "Host", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "buildServer", "parameters": [{"name": "host", "type": "Host", "varargs": false}, {"name": "content", "type": "Table", "varargs": false}, {"name": "local", "type": "boolean", "varargs": false}, {"name": "addName", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "section", "parameters": [{"name": "label", "type": "String", "varargs": false}, {"name": "servers", "type": "Table", "varargs": false}, {"name": "eye", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "refreshLocal", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "refreshCommunity", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addHeader", "parameters": [{"name": "groupTable", "type": "Table", "varargs": false}, {"name": "group", "type": "ServerGroup", "varargs": false}, {"name": "hidden", "type": "boolean", "varargs": false}, {"name": "favorite", "type": "boolean", "varargs": false}, {"name": "doInit", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "columns", "parameters": [], "return_type": "int"}, {"modifiers": [], "name": "addCommunityHost", "parameters": [{"name": "host", "type": "Host", "varargs": false}, {"name": "container", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "finishLocalHosts", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addLocalHost", "parameters": [{"name": "host", "type": "Host", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "connect", "parameters": [{"name": "ip", "type": "String", "varargs": false}, {"name": "port", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "reconnect", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "safeConnect", "parameters": [{"name": "ip", "type": "String", "varargs": false}, {"name": "port", "type": "int", "varargs": false}, {"name": "version", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "targetWidth", "parameters": [], "return_type": "float"}, {"modifiers": ["private"], "name": "loadServers", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "fetchServers", "parameters": [], "return_type": ""}, {"modifiers": ["private", "static"], "name": "fetchServers", "parameters": [{"name": "urls", "type": "String", "varargs": false}, {"name": "index", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "parseServerString", "parameters": [{"name": "str", "type": "String", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["private"], "name": "saveServers", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "getVersionString", "parameters": [{"name": "host", "type": "Host", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_refreshAll_0(_args: Array = []) -> Variant:
	return null

func java_method_setupRemote_1(_args: Array = []) -> Variant:
	return null

func java_method_moveRemote_2(_args: Array = []) -> Variant:
	return null

func java_method_refreshRemote_3(_args: Array = []) -> Variant:
	return null

func java_method_refreshServer_4(_args: Array = []) -> Variant:
	return null

func java_method_setupServer_5(_args: Array = []) -> Variant:
	return null

func java_method_buildServer_6(_args: Array = []) -> Variant:
	return null

func java_method_setup_7(_args: Array = []) -> Variant:
	return null

func java_method_section_8(_args: Array = []) -> Variant:
	return null

func java_method_refreshLocal_9(_args: Array = []) -> Variant:
	return null

func java_method_refreshCommunity_10(_args: Array = []) -> Variant:
	return null

func java_method_addHeader_11(_args: Array = []) -> Variant:
	return null

func java_method_columns_12(_args: Array = []) -> Variant:
	return null

func java_method_addCommunityHost_13(_args: Array = []) -> Variant:
	return null

func java_method_finishLocalHosts_14(_args: Array = []) -> Variant:
	return null

func java_method_addLocalHost_15(_args: Array = []) -> Variant:
	return null

func java_method_connect_16(_args: Array = []) -> Variant:
	return null

func java_method_reconnect_17(_args: Array = []) -> Variant:
	return null

func java_method_safeConnect_18(_args: Array = []) -> Variant:
	return null

func java_method_targetWidth_19(_args: Array = []) -> Variant:
	return null

func java_method_loadServers_20(_args: Array = []) -> Variant:
	return null

func java_method_fetchServers_21(_args: Array = []) -> Variant:
	return null

func java_method_fetchServers_22(_args: Array = []) -> Variant:
	return null

func java_method_parseServerString_23(_args: Array = []) -> Variant:
	return null

func java_method_saveServers_24(_args: Array = []) -> Variant:
	return null

func java_method_getVersionString_25(_args: Array = []) -> Variant:
	return null
