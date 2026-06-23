# Generated from Mindustry upstream.
# Source: mindustry/net/NetConnection.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.net"
const JAVA_KIND := "class"
const JAVA_NAME := "NetConnection"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "address", "type": "String"}, {"modifiers": ["public"], "name": "uuid", "type": "String"}, {"modifiers": ["public"], "name": "usid", "type": "String"}, {"modifiers": ["public"], "name": "mobile", "type": "boolean"}, {"modifiers": ["public"], "name": "modclient", "type": "boolean"}, {"modifiers": ["public"], "name": "player", "type": "Player"}, {"modifiers": ["public"], "name": "kicked", "type": "boolean"}, {"modifiers": ["public"], "name": "syncTime", "type": "long"}, {"modifiers": ["public"], "name": "connectTime", "type": "long"}, {"modifiers": ["public"], "name": "lastReceivedClientSnapshot", "type": "int"}, {"modifiers": ["public"], "name": "snapshotsSent", "type": "int"}, {"modifiers": ["public"], "name": "lastReceivedClientTime", "type": "long"}, {"modifiers": ["public"], "name": "rejectedRequests", "type": "Seq"}, {"modifiers": ["public"], "name": "chatRate", "type": "Ratekeeper"}, {"modifiers": ["public"], "name": "packetRate", "type": "Ratekeeper"}, {"modifiers": ["public"], "name": "hasConnected", "type": "boolean"}, {"modifiers": ["public"], "name": "hasBegunConnecting", "type": "boolean"}, {"modifiers": ["public"], "name": "determiningAssets", "type": "boolean"}, {"modifiers": ["public"], "name": "receivingAssets", "type": "boolean"}, {"modifiers": ["public"], "name": "hasDisconnected", "type": "boolean"}, {"modifiers": ["public"], "name": "viewWidth", "type": "float"}, {"modifiers": ["public"], "name": "viewHeight", "type": "float"}, {"modifiers": ["public"], "name": "viewX", "type": "float"}, {"modifiers": ["public"], "name": "viewY", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "NetConnection", "parameters": [{"name": "address", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "kick", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "kick", "parameters": [{"name": "reason", "type": "KickReason", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "kick", "parameters": [{"name": "reason", "type": "KickReason", "varargs": false}, {"name": "kickDuration", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "kick", "parameters": [{"name": "reason", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "kick", "parameters": [{"name": "reason", "type": "String", "varargs": false}, {"name": "duration", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "kick", "parameters": [{"name": "reason", "type": "String", "varargs": false}, {"name": "kickType", "type": "KickReason", "varargs": false}, {"name": "kickDuration", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "kickDisconnect", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isConnected", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "sendStreamAsync", "parameters": [{"name": "stream", "type": "Streamable", "varargs": false}, {"name": "data", "type": "ByteArrayOutputStream", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sendStream", "parameters": [{"name": "stream", "type": "Streamable", "varargs": false}, {"name": "data", "type": "ByteArrayOutputStream", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sendStream", "parameters": [{"name": "stream", "type": "Streamable", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "send", "parameters": [{"name": "object", "type": "Object", "varargs": false}, {"name": "reliable", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "close", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_kick_0(_args: Array = []) -> Variant:
	return null

func java_method_kick_1(_args: Array = []) -> Variant:
	return null

func java_method_kick_2(_args: Array = []) -> Variant:
	return null

func java_method_kick_3(_args: Array = []) -> Variant:
	return null

func java_method_kick_4(_args: Array = []) -> Variant:
	return null

func java_method_kick_5(_args: Array = []) -> Variant:
	return null

func java_method_kickDisconnect_6(_args: Array = []) -> Variant:
	return null

func java_method_isConnected_7(_args: Array = []) -> Variant:
	return null

func java_method_sendStreamAsync_8(_args: Array = []) -> Variant:
	return null

func java_method_sendStream_9(_args: Array = []) -> Variant:
	return null

func java_method_sendStream_10(_args: Array = []) -> Variant:
	return null

func java_method_send_11(_args: Array = []) -> Variant:
	return null

func java_method_close_12(_args: Array = []) -> Variant:
	return null
