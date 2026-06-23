# Generated from Mindustry upstream.
# Source: mindustry/type/LiquidStack.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "LiquidStack"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "empty", "type": "LiquidStack"}, {"modifiers": ["public"], "name": "liquid", "type": "Liquid"}, {"modifiers": ["public"], "name": "amount", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LiquidStack", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}]}, {"modifiers": ["protected"], "name": "LiquidStack", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "set", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": "LiquidStack"}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "LiquidStack"}, {"modifiers": ["public"], "name": "equals", "parameters": [{"name": "other", "type": "LiquidStack", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "mult", "parameters": [{"name": "stacks", "type": "LiquidStack", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": "LiquidStack"}, {"modifiers": ["public", "static"], "name": "with", "parameters": [{"name": "items", "type": "Object", "varargs": true}], "return_type": "LiquidStack"}, {"modifiers": ["public", "static"], "name": "list", "parameters": [{"name": "items", "type": "Object", "varargs": true}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "liquidStack", "type": "LiquidStack", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "equals", "parameters": [{"name": "o", "type": "Object", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_set_0(_args: Array = []) -> Variant:
	return null

func java_method_copy_1(_args: Array = []) -> Variant:
	return null

func java_method_equals_2(_args: Array = []) -> Variant:
	return null

func java_method_mult_3(_args: Array = []) -> Variant:
	return null

func java_method_with_4(_args: Array = []) -> Variant:
	return null

func java_method_list_5(_args: Array = []) -> Variant:
	return null

func java_method_compareTo_6(_args: Array = []) -> Variant:
	return null

func java_method_equals_7(_args: Array = []) -> Variant:
	return null

func java_method_toString_8(_args: Array = []) -> Variant:
	return null
