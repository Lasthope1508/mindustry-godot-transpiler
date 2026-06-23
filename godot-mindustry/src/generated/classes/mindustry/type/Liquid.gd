# Generated from Mindustry upstream.
# Source: mindustry/type/Liquid.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "Liquid"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := ["Senseable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "animationFrames", "type": "int"}, {"modifiers": ["public", "static"], "name": "animationScaleGas", "type": "float"}, {"modifiers": ["public", "static"], "name": "animationScaleLiquid", "type": "float"}, {"modifiers": ["final", "protected", "static"], "name": "rand", "type": "Rand"}, {"modifiers": ["public"], "name": "gas", "type": "boolean"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "gasColor", "type": "Color"}, {"modifiers": ["public"], "name": "barColor", "type": "Color"}, {"modifiers": ["public"], "name": "lightColor", "type": "Color"}, {"modifiers": ["public"], "name": "flammability", "type": "float"}, {"modifiers": ["public"], "name": "temperature", "type": "float"}, {"modifiers": ["public"], "name": "heatCapacity", "type": "float"}, {"modifiers": ["public"], "name": "viscosity", "type": "float"}, {"modifiers": ["public"], "name": "explosiveness", "type": "float"}, {"modifiers": ["public"], "name": "blockReactive", "type": "boolean"}, {"modifiers": ["public"], "name": "coolant", "type": "boolean"}, {"modifiers": ["public"], "name": "moveThroughBlocks", "type": "boolean"}, {"modifiers": ["public"], "name": "incinerable", "type": "boolean"}, {"modifiers": ["public"], "name": "effect", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "particleEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "particleSpacing", "type": "float"}, {"modifiers": ["public"], "name": "boilPoint", "type": "float"}, {"modifiers": ["public"], "name": "capPuddles", "type": "boolean"}, {"modifiers": ["public"], "name": "vaporEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "hidden", "type": "boolean"}, {"modifiers": ["public"], "name": "canStayOn", "type": "ObjectSet"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Liquid", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}]}, {"modifiers": ["public"], "name": "Liquid", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getAnimationFrame", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "willBoil", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canExtinguish", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "barColor", "parameters": [], "return_type": "Color"}, {"modifiers": ["public"], "name": "drawPuddle", "parameters": [{"name": "puddle", "type": "Puddle", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "puddle", "type": "Puddle", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "react", "parameters": [{"name": "other", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_1(_args: Array = []) -> Variant:
	return null

func java_method_getAnimationFrame_2(_args: Array = []) -> Variant:
	return null

func java_method_willBoil_3(_args: Array = []) -> Variant:
	return null

func java_method_canExtinguish_4(_args: Array = []) -> Variant:
	return null

func java_method_barColor_5(_args: Array = []) -> Variant:
	return null

func java_method_drawPuddle_6(_args: Array = []) -> Variant:
	return null

func java_method_update_7(_args: Array = []) -> Variant:
	return null

func java_method_react_8(_args: Array = []) -> Variant:
	return null

func java_method_setStats_9(_args: Array = []) -> Variant:
	return null

func java_method_sense_10(_args: Array = []) -> Variant:
	return null

func java_method_senseObject_11(_args: Array = []) -> Variant:
	return null

func java_method_toString_12(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_13(_args: Array = []) -> Variant:
	return null
