# Generated from Mindustry upstream.
# Source: mindustry/type/PayloadStack.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "PayloadStack"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Comparable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "item", "type": "UnlockableContent"}, {"modifiers": ["public"], "name": "amount", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PayloadStack", "parameters": [{"name": "item", "type": "UnlockableContent", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}]}, {"modifiers": ["public"], "name": "PayloadStack", "parameters": [{"name": "item", "type": "UnlockableContent", "varargs": false}]}, {"modifiers": ["public"], "name": "PayloadStack", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "with", "parameters": [{"name": "items", "type": "Object", "varargs": true}], "return_type": "PayloadStack"}, {"modifiers": ["public", "static"], "name": "list", "parameters": [{"name": "items", "type": "Object", "varargs": true}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "compareTo", "parameters": [{"name": "stack", "type": "PayloadStack", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "equals", "parameters": [{"name": "o", "type": "Object", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []
