# Generated from Mindustry upstream.
# Source: mindustry/net/NetworkIO.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.net"
const JAVA_KIND := "class"
const JAVA_NAME := "NetworkIO"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "writeWorld", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "os", "type": "OutputStream", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadWorld", "parameters": [{"name": "is", "type": "InputStream", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "writeRequiredAssets", "parameters": [{"name": "os", "type": "OutputStream", "varargs": false}, {"name": "assets", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readRequiredAssets", "parameters": [{"name": "is", "type": "InputStream", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public", "static"], "name": "writeAssets", "parameters": [{"name": "os", "type": "OutputStream", "varargs": false}, {"name": "assets", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "loadAssets", "parameters": [{"name": "is", "type": "InputStream", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "writeServerData", "parameters": [], "return_type": "ByteBuffer"}, {"modifiers": ["public", "static"], "name": "readServerData", "parameters": [{"name": "ping", "type": "int", "varargs": false}, {"name": "hostAddress", "type": "String", "varargs": false}, {"name": "buffer", "type": "ByteBuffer", "varargs": false}], "return_type": "Host"}, {"modifiers": ["private", "static"], "name": "writeString", "parameters": [{"name": "buffer", "type": "ByteBuffer", "varargs": false}, {"name": "string", "type": "String", "varargs": false}, {"name": "maxlen", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "writeString", "parameters": [{"name": "buffer", "type": "ByteBuffer", "varargs": false}, {"name": "string", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "readString", "parameters": [{"name": "buffer", "type": "ByteBuffer", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_writeWorld_0(_args: Array = []) -> Variant:
	return null

func java_method_loadWorld_1(_args: Array = []) -> Variant:
	return null

func java_method_writeRequiredAssets_2(_args: Array = []) -> Variant:
	return null

func java_method_readRequiredAssets_3(_args: Array = []) -> Variant:
	return null

func java_method_writeAssets_4(_args: Array = []) -> Variant:
	return null

func java_method_loadAssets_5(_args: Array = []) -> Variant:
	return null

func java_method_writeServerData_6(_args: Array = []) -> Variant:
	return null

func java_method_readServerData_7(_args: Array = []) -> Variant:
	return null

func java_method_writeString_8(_args: Array = []) -> Variant:
	return null

func java_method_writeString_9(_args: Array = []) -> Variant:
	return null

func java_method_readString_10(_args: Array = []) -> Variant:
	return null
