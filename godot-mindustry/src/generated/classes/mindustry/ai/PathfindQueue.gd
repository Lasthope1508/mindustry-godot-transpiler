# Generated from Mindustry upstream.
# Source: mindustry/ai/PathfindQueue.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai"
const JAVA_KIND := "class"
const JAVA_NAME := "PathfindQueue"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "CAPACITY_RATIO_LOW", "type": "double"}, {"modifiers": ["final", "private", "static"], "name": "CAPACITY_RATIO_HI", "type": "double"}, {"modifiers": ["public"], "name": "queue", "type": "int"}, {"modifiers": ["public"], "name": "weights", "type": "float"}, {"modifiers": ["public"], "name": "size", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PathfindQueue", "parameters": []}, {"modifiers": ["public"], "name": "PathfindQueue", "parameters": [{"name": "initialCapacity", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "empty", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "e", "type": "int", "varargs": false}, {"name": "weight", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "peek", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "poll", "parameters": [], "return_type": "int"}, {"modifiers": ["private"], "name": "siftUp", "parameters": [{"name": "k", "type": "int", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "weight", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "siftDown", "parameters": [{"name": "k", "type": "int", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "weight", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "growToSize", "parameters": [{"name": "minCapacity", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_empty_0(_args: Array = []) -> Variant:
	return null

func java_method_add_1(_args: Array = []) -> Variant:
	return null

func java_method_peek_2(_args: Array = []) -> Variant:
	return null

func java_method_clear_3(_args: Array = []) -> Variant:
	return null

func java_method_poll_4(_args: Array = []) -> Variant:
	return null

func java_method_siftUp_5(_args: Array = []) -> Variant:
	return null

func java_method_siftDown_6(_args: Array = []) -> Variant:
	return null

func java_method_growToSize_7(_args: Array = []) -> Variant:
	return null
