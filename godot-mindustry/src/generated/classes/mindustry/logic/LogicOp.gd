# Generated from Mindustry upstream.
# Source: mindustry/logic/LogicOp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "enum"
const JAVA_NAME := "LogicOp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "all", "type": "LogicOp"}, {"modifiers": ["final", "public"], "name": "objFunction2", "type": "OpObjLambda2"}, {"modifiers": ["final", "public"], "name": "function2", "type": "OpLambda2"}, {"modifiers": ["final", "public"], "name": "function1", "type": "OpLambda1"}, {"modifiers": ["final", "public"], "name": "unary", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "func", "type": "boolean"}, {"modifiers": ["final", "public"], "name": "symbol", "type": "String"}]
const JAVA_CONSTRUCTORS := [{"modifiers": [], "name": "LogicOp", "parameters": [{"name": "symbol", "type": "String", "varargs": false}, {"name": "function", "type": "OpLambda2", "varargs": false}]}, {"modifiers": [], "name": "LogicOp", "parameters": [{"name": "symbol", "type": "String", "varargs": false}, {"name": "func", "type": "boolean", "varargs": false}, {"name": "function", "type": "OpLambda2", "varargs": false}]}, {"modifiers": [], "name": "LogicOp", "parameters": [{"name": "symbol", "type": "String", "varargs": false}, {"name": "function", "type": "OpLambda2", "varargs": false}, {"name": "objFunction", "type": "OpObjLambda2", "varargs": false}]}, {"modifiers": [], "name": "LogicOp", "parameters": [{"name": "symbol", "type": "String", "varargs": false}, {"name": "function", "type": "OpLambda1", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := ["add", "sub", "mul", "div", "idiv", "mod", "emod", "pow", "equal", "notEqual", "land", "lessThan", "lessThanEq", "greaterThan", "greaterThanEq", "strictEqual", "shl", "shr", "ushr", "or", "and", "xor", "not", "max", "min", "angle", "angleDiff", "len", "noise", "abs", "sign", "log", "logn", "log10", "floor", "ceil", "round", "sqrt", "rand", "sin", "cos", "tan", "asin", "acos", "atan"]

func java_method_toString_0(_args: Array = []) -> Variant:
	return null
