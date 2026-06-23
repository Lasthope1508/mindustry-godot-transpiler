# Generated from Mindustry upstream.
# Source: mindustry/type/PayloadSeq.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "PayloadSeq"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "payloads", "type": "ObjectIntMap"}, {"modifiers": ["private"], "name": "total", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "isEmpty", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "any", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "total", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "stacks", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeAll", "parameters": [{"name": "pred", "type": "Boolf", "varargs": false}], "return_type": "PayloadSeq"}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "contains", "parameters": [{"name": "stacks", "type": "Seq", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "contains", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "contains", "parameters": [{"name": "block", "type": "UnlockableContent", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "contains", "parameters": [{"name": "stack", "type": "PayloadStack", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_isEmpty_0(_args: Array = []) -> Variant:
	return null

func java_method_any_1(_args: Array = []) -> Variant:
	return null

func java_method_total_2(_args: Array = []) -> Variant:
	return null

func java_method_add_3(_args: Array = []) -> Variant:
	return null

func java_method_add_4(_args: Array = []) -> Variant:
	return null

func java_method_remove_5(_args: Array = []) -> Variant:
	return null

func java_method_remove_6(_args: Array = []) -> Variant:
	return null

func java_method_remove_7(_args: Array = []) -> Variant:
	return null

func java_method_removeAll_8(_args: Array = []) -> Variant:
	return null

func java_method_clear_9(_args: Array = []) -> Variant:
	return null

func java_method_get_10(_args: Array = []) -> Variant:
	return null

func java_method_contains_11(_args: Array = []) -> Variant:
	return null

func java_method_contains_12(_args: Array = []) -> Variant:
	return null

func java_method_contains_13(_args: Array = []) -> Variant:
	return null

func java_method_contains_14(_args: Array = []) -> Variant:
	return null

func java_method_write_15(_args: Array = []) -> Variant:
	return null

func java_method_read_16(_args: Array = []) -> Variant:
	return null
