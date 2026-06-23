# Generated from Mindustry upstream.
# Source: mindustry/type/ItemSeq.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemSeq"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Iterable", "JsonSerializable"]
const JAVA_FIELDS := [{"modifiers": ["final", "protected"], "name": "values", "type": "int"}, {"modifiers": ["public"], "name": "total", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemSeq", "parameters": []}, {"modifiers": ["public"], "name": "ItemSeq", "parameters": [{"name": "stacks", "type": "Seq", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "checkNegative", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "ItemSeq"}, {"modifiers": ["public"], "name": "each", "parameters": [{"name": "cons", "type": "ItemConsumer", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "toSeq", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "toArray", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "min", "parameters": [{"name": "number", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "has", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "has", "parameters": [{"name": "seq", "type": "ItemSeq", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "has", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "itemModule", "type": "ItemModule", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "seq", "type": "ItemSeq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "stack", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "stack", "type": "ItemStack", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "json", "type": "Json", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "json", "type": "Json", "varargs": false}, {"name": "jsonData", "type": "JsonValue", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "iterator", "parameters": [], "return_type": "Iterator"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_checkNegative_0(_args: Array = []) -> Variant:
	return null

func java_method_copy_1(_args: Array = []) -> Variant:
	return null

func java_method_each_2(_args: Array = []) -> Variant:
	return null

func java_method_clear_3(_args: Array = []) -> Variant:
	return null

func java_method_toSeq_4(_args: Array = []) -> Variant:
	return null

func java_method_toArray_5(_args: Array = []) -> Variant:
	return null

func java_method_min_6(_args: Array = []) -> Variant:
	return null

func java_method_has_7(_args: Array = []) -> Variant:
	return null

func java_method_has_8(_args: Array = []) -> Variant:
	return null

func java_method_has_9(_args: Array = []) -> Variant:
	return null

func java_method_get_10(_args: Array = []) -> Variant:
	return null

func java_method_set_11(_args: Array = []) -> Variant:
	return null

func java_method_add_12(_args: Array = []) -> Variant:
	return null

func java_method_add_13(_args: Array = []) -> Variant:
	return null

func java_method_add_14(_args: Array = []) -> Variant:
	return null

func java_method_add_15(_args: Array = []) -> Variant:
	return null

func java_method_add_16(_args: Array = []) -> Variant:
	return null

func java_method_add_17(_args: Array = []) -> Variant:
	return null

func java_method_remove_18(_args: Array = []) -> Variant:
	return null

func java_method_remove_19(_args: Array = []) -> Variant:
	return null

func java_method_remove_20(_args: Array = []) -> Variant:
	return null

func java_method_write_21(_args: Array = []) -> Variant:
	return null

func java_method_read_22(_args: Array = []) -> Variant:
	return null

func java_method_toString_23(_args: Array = []) -> Variant:
	return null

func java_method_iterator_24(_args: Array = []) -> Variant:
	return null
