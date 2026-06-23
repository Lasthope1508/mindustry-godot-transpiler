# Generated from Mindustry upstream.
# Source: mindustry/type/ItemStack.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "ItemStack"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "empty", "type": "ItemStack"}, {"modifiers": ["public"], "name": "item", "type": "Item"}, {"modifiers": ["public"], "name": "amount", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ItemStack", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}]}, {"modifiers": ["public"], "name": "ItemStack", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "set", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "equals", "parameters": [{"name": "other", "type": "ItemStack", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "mult", "parameters": [{"name": "stacks", "type": "ItemStack", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": "ItemStack"}, {"modifiers": ["public", "static"], "name": "with", "parameters": [{"name": "items", "type": "Object", "varargs": true}], "return_type": "ItemStack"}, {"modifiers": ["public", "static"], "name": "list", "parameters": [{"name": "items", "type": "Object", "varargs": true}], "return_type": "Seq"}, {"modifiers": ["public", "static"], "name": "copy", "parameters": [{"name": "stacks", "type": "ItemStack", "varargs": false}], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "itemStack", "type": "ItemStack", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "equals", "parameters": [{"name": "o", "type": "Object", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
