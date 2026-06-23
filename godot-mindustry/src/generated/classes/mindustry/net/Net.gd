# Generated from Mindustry upstream.
# Source: mindustry/net/Net.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.net"
const JAVA_KIND := "class"
const JAVA_NAME := "Net"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "packetIdAssetStream", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "packetIdWorldStream", "type": "int"}, {"modifiers": ["private", "static"], "name": "packetProvs", "type": "Seq"}, {"modifiers": ["private", "static"], "name": "packetClasses", "type": "Seq"}, {"modifiers": ["private", "static"], "name": "packetToId", "type": "ObjectIntMap"}, {"modifiers": ["private"], "name": "server", "type": "boolean"}, {"modifiers": ["private"], "name": "active", "type": "boolean"}, {"modifiers": ["private"], "name": "clientLoaded", "type": "boolean"}, {"modifiers": ["private"], "name": "currentStream", "type": "StreamBuilder"}, {"modifiers": ["final", "private"], "name": "packetQueue", "type": "Seq"}, {"modifiers": ["final", "private"], "name": "clientListeners", "type": "ObjectMap"}, {"modifiers": ["final", "private"], "name": "serverListeners", "type": "ObjectMap"}, {"modifiers": ["final", "private"], "name": "streams", "type": "IntMap"}, {"modifiers": ["final", "private"], "name": "pingExecutor", "type": "ExecutorService"}, {"modifiers": ["final", "private"], "name": "provider", "type": "NetProvider"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Net", "parameters": [{"name": "provider", "type": "NetProvider", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "registerPacket", "parameters": [{"name": "cons", "type": "Prov", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "getPacketClassId", "parameters": [{"name": "c", "type": "Class", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public", "static"], "name": "getPacketId", "parameters": [{"name": "packet", "type": "Packet", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public", "static"], "name": "newPacket", "parameters": [{"name": "id", "type": "byte", "varargs": false}], "return_type": "T"}, {"modifiers": ["public"], "name": "handleException", "parameters": [{"name": "e", "type": "Throwable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showError", "parameters": [{"name": "e", "type": "Throwable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setClientLoaded", "parameters": [{"name": "loaded", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setClientConnected", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "connect", "parameters": [{"name": "ip", "type": "String", "varargs": false}, {"name": "port", "type": "int", "varargs": false}, {"name": "success", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "host", "parameters": [{"name": "port", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "closeServer", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "disconnect", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "discoverServers", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}, {"name": "done", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getConnections", "parameters": [], "return_type": "Iterable"}, {"modifiers": ["public"], "name": "send", "parameters": [{"name": "object", "type": "Object", "varargs": false}, {"name": "reliable", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sendExcept", "parameters": [{"name": "except", "type": "NetConnection", "varargs": false}, {"name": "object", "type": "Object", "varargs": false}, {"name": "reliable", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getCurrentStream", "parameters": [], "return_type": "StreamBuilder"}, {"modifiers": ["public"], "name": "handleClient", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "listener", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "handleServer", "parameters": [{"name": "type", "type": "Class", "varargs": false}, {"name": "listener", "type": "Cons2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "handleClientReceived", "parameters": [{"name": "object", "type": "Packet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "handleServerReceived", "parameters": [{"name": "connection", "type": "NetConnection", "varargs": false}, {"name": "object", "type": "Packet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setConnectFilter", "parameters": [{"name": "filter", "type": "ServerConnectFilter", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getConnectFilter", "parameters": [], "return_type": "ServerConnectFilter"}, {"modifiers": ["public"], "name": "pingHost", "parameters": [{"name": "address", "type": "String", "varargs": false}, {"name": "port", "type": "int", "varargs": false}, {"name": "valid", "type": "Cons", "varargs": false}, {"name": "failed", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "active", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "server", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "client", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_registerPacket_0(_args: Array = []) -> Variant:
	return null

func java_method_getPacketClassId_1(_args: Array = []) -> Variant:
	return null

func java_method_getPacketId_2(_args: Array = []) -> Variant:
	return null

func java_method_newPacket_3(_args: Array = []) -> Variant:
	return null

func java_method_handleException_4(_args: Array = []) -> Variant:
	return null

func java_method_showError_5(_args: Array = []) -> Variant:
	return null

func java_method_setClientLoaded_6(_args: Array = []) -> Variant:
	return null

func java_method_setClientConnected_7(_args: Array = []) -> Variant:
	return null

func java_method_connect_8(_args: Array = []) -> Variant:
	return null

func java_method_host_9(_args: Array = []) -> Variant:
	return null

func java_method_closeServer_10(_args: Array = []) -> Variant:
	return null

func java_method_reset_11(_args: Array = []) -> Variant:
	return null

func java_method_disconnect_12(_args: Array = []) -> Variant:
	return null

func java_method_discoverServers_13(_args: Array = []) -> Variant:
	return null

func java_method_getConnections_14(_args: Array = []) -> Variant:
	return null

func java_method_send_15(_args: Array = []) -> Variant:
	return null

func java_method_sendExcept_16(_args: Array = []) -> Variant:
	return null

func java_method_getCurrentStream_17(_args: Array = []) -> Variant:
	return null

func java_method_handleClient_18(_args: Array = []) -> Variant:
	return null

func java_method_handleServer_19(_args: Array = []) -> Variant:
	return null

func java_method_handleClientReceived_20(_args: Array = []) -> Variant:
	return null

func java_method_handleServerReceived_21(_args: Array = []) -> Variant:
	return null

func java_method_setConnectFilter_22(_args: Array = []) -> Variant:
	return null

func java_method_getConnectFilter_23(_args: Array = []) -> Variant:
	return null

func java_method_pingHost_24(_args: Array = []) -> Variant:
	return null

func java_method_active_25(_args: Array = []) -> Variant:
	return null

func java_method_server_26(_args: Array = []) -> Variant:
	return null

func java_method_client_27(_args: Array = []) -> Variant:
	return null

func java_method_dispose_28(_args: Array = []) -> Variant:
	return null
