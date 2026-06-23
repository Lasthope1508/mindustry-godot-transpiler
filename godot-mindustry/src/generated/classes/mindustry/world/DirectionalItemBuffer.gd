# Generated from Mindustry upstream.
# Source: mindustry/world/DirectionalItemBuffer.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "DirectionalItemBuffer"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "buffers", "type": "long"}, {"modifiers": ["final", "public"], "name": "indexes", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DirectionalItemBuffer", "parameters": [{"name": "capacity", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "accepts", "parameters": [{"name": "buffer", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "accept", "parameters": [{"name": "buffer", "type": "int", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "poll", "parameters": [{"name": "buffer", "type": "int", "varargs": false}, {"name": "speed", "type": "float", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "buffer", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "legacy", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_accepts_0(_args: Array = []) -> Variant:
	return null

func java_method_accept_1(_args: Array = []) -> Variant:
	return null

func java_method_poll_2(_args: Array = []) -> Variant:
	return null

func java_method_remove_3(_args: Array = []) -> Variant:
	return null

func java_method_write_4(_args: Array = []) -> Variant:
	return null

func java_method_read_5(_args: Array = []) -> Variant:
	return null

func java_method_read_6(_args: Array = []) -> Variant:
	return null
