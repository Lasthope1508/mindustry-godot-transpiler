# Generated from Mindustry upstream.
# Source: mindustry/net/Packet.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.net"
const JAVA_KIND := "class"
const JAVA_NAME := "Packet"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "protected", "static"], "name": "NODATA", "type": "byte"}, {"modifiers": ["final", "protected", "static"], "name": "BAIS", "type": "ReusableByteInStream"}, {"modifiers": ["final", "protected", "static"], "name": "READ", "type": "Reads"}, {"modifiers": ["final", "public", "static"], "name": "priorityLow", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "priorityNormal", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "priorityHigh", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "allow", "parameters": [{"name": "server", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "length", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "handled", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getPriority", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "handleClient", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "handleServer", "parameters": [{"name": "con", "type": "NetConnection", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
