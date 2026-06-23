# Generated from Mindustry upstream.
# Source: mindustry/type/Item.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "Item"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := ["Senseable"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "explosiveness", "type": "float"}, {"modifiers": ["public"], "name": "flammability", "type": "float"}, {"modifiers": ["public"], "name": "radioactivity", "type": "float"}, {"modifiers": ["public"], "name": "charge", "type": "float"}, {"modifiers": ["public"], "name": "hardness", "type": "int"}, {"modifiers": ["public"], "name": "cost", "type": "float"}, {"modifiers": ["public"], "name": "healthScaling", "type": "float"}, {"modifiers": ["public"], "name": "lowPriority", "type": "boolean"}, {"modifiers": ["public"], "name": "frames", "type": "int"}, {"modifiers": ["public"], "name": "transitionFrames", "type": "int"}, {"modifiers": ["public"], "name": "frameTime", "type": "float"}, {"modifiers": ["public"], "name": "buildable", "type": "boolean"}, {"modifiers": ["public"], "name": "hidden", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Item", "parameters": [{"name": "name", "type": "String", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}]}, {"modifiers": ["public"], "name": "Item", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "isOnPlanet", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "loadIcon", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}, {"modifiers": ["public"], "name": "createIcons", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sense", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "double"}, {"modifiers": ["public"], "name": "senseObject", "parameters": [{"name": "sensor", "type": "LAccess", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public", "static"], "name": "getAllOres", "parameters": [], "return_type": "Seq"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_isOnPlanet_0(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_1(_args: Array = []) -> Variant:
	return null

func java_method_loadIcon_2(_args: Array = []) -> Variant:
	return null

func java_method_setStats_3(_args: Array = []) -> Variant:
	return null

func java_method_toString_4(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_5(_args: Array = []) -> Variant:
	return null

func java_method_createIcons_6(_args: Array = []) -> Variant:
	return null

func java_method_sense_7(_args: Array = []) -> Variant:
	return null

func java_method_senseObject_8(_args: Array = []) -> Variant:
	return null

func java_method_getAllOres_9(_args: Array = []) -> Variant:
	return null
