# Generated from Mindustry upstream.
# Source: annotations/src/main/java/mindustry/annotations/remote/MethodEntry.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.annotations.remote"
const JAVA_KIND := "class"
const JAVA_NAME := "MethodEntry"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "className", "type": "String"}, {"modifiers": ["final", "public"], "name": "targetMethod", "type": "String"}, {"modifiers": ["final", "public"], "name": "packetClassName", "type": "String"}, {"modifiers": ["final", "public"], "name": "where", "type": "Loc"}, {"modifiers": ["final", "public"], "name": "target", "type": "Variant"}, {"modifiers": ["final", "public"], "name": "local", "type": "Loc"}, {"modifiers": ["final", "public"], "name": "unreliable", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "forward", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "id", "type": "int"}, {"modifiers": ["final", "public"], "name": "element", "type": "Smethod"}, {"modifiers": ["final", "public"], "name": "priority", "type": "PacketPriority"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MethodEntry", "parameters": [{"name": "className", "type": "String", "varargs": false}, {"name": "targetMethod", "type": "String", "varargs": false}, {"name": "packetClassName", "type": "String", "varargs": false}, {"name": "where", "type": "Loc", "varargs": false}, {"name": "target", "type": "Variant", "varargs": false}, {"name": "local", "type": "Loc", "varargs": false}, {"name": "unreliable", "type": "boolean", "varargs": false}, {"name": "forward", "type": "boolean", "varargs": false}, {"name": "id", "type": "int", "varargs": false}, {"name": "element", "type": "Smethod", "varargs": false}, {"name": "priority", "type": "PacketPriority", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "hashCode", "parameters": [], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_hashCode_0(_args: Array = []) -> Variant:
	return null
