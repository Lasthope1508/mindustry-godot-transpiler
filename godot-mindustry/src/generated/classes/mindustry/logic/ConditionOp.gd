# Generated from Mindustry upstream.
# Source: mindustry/logic/ConditionOp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "enum"
const JAVA_NAME := "ConditionOp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "all", "type": "ConditionOp"}, {"modifiers": ["final", "public"], "name": "objFunction", "type": "CondObjOpLambda"}, {"modifiers": ["final", "public"], "name": "function", "type": "CondOpLambda"}, {"modifiers": ["final", "public"], "name": "symbol", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "ConditionOp", "parameters": [{"name": "symbol", "type": "String", "varargs": false}, {"name": "function", "type": "CondOpLambda", "varargs": false}]}, {"modifiers": [], "name": "ConditionOp", "parameters": [{"name": "symbol", "type": "String", "varargs": false}, {"name": "function", "type": "CondOpLambda", "varargs": false}, {"name": "objFunction", "type": "CondObjOpLambda", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "test", "parameters": [{"name": "va", "type": "LVar", "varargs": false}, {"name": "vb", "type": "LVar", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := ["equal", "notEqual", "lessThan", "lessThanEq", "greaterThan", "greaterThanEq", "strictEqual", "always"]

func java_method_test_0(_args: Array = []) -> Variant:
	return null

func java_method_toString_1(_args: Array = []) -> Variant:
	return null
