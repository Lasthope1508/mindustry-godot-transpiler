# Generated from Mindustry upstream.
# Source: mindustry/world/Tiles.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world"
const JAVA_KIND := "class"
const JAVA_NAME := "Tiles"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Iterable"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "width", "type": "int"}, {"modifiers": ["final", "public"], "name": "height", "type": "int"}, {"modifiers": ["final"], "name": "array", "type": "Tile"}, {"modifiers": ["final"], "name": "puddles", "type": "Puddle"}, {"modifiers": ["final"], "name": "fires", "type": "Fire"}, {"modifiers": [], "name": "tmpFloorState", "type": "long"}, {"modifiers": [], "name": "tmpBlockState", "type": "long"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Tiles", "parameters": [{"name": "width", "type": "int", "varargs": false}, {"name": "height", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getTmpFloorState", "parameters": [{"name": "pos", "type": "int", "varargs": false}], "return_type": "long"}, {"modifiers": ["public"], "name": "setTmpFloorState", "parameters": [{"name": "pos", "type": "int", "varargs": false}, {"name": "value", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getTmpBlockState", "parameters": [{"name": "pos", "type": "int", "varargs": false}], "return_type": "long"}, {"modifiers": ["public"], "name": "setTmpBlockState", "parameters": [{"name": "pos", "type": "int", "varargs": false}, {"name": "value", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getPuddle", "parameters": [{"name": "pos", "type": "int", "varargs": false}], "return_type": "Puddle"}, {"modifiers": ["public"], "name": "setPuddle", "parameters": [{"name": "pos", "type": "int", "varargs": false}, {"name": "p", "type": "Puddle", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getFire", "parameters": [{"name": "pos", "type": "int", "varargs": false}], "return_type": "Fire"}, {"modifiers": ["public"], "name": "setFire", "parameters": [{"name": "pos", "type": "int", "varargs": false}, {"name": "f", "type": "Fire", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "each", "parameters": [{"name": "cons", "type": "Intc2", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "fill", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "seti", "parameters": [{"name": "i", "type": "int", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "in", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "getn", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "getc", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "geti", "parameters": [{"name": "idx", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "getp", "parameters": [{"name": "pos", "type": "int", "varargs": false}], "return_type": "Tile"}, {"modifiers": ["public"], "name": "eachTile", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "iterator", "parameters": [], "return_type": "Iterator"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getTmpFloorState_0(_args: Array = []) -> Variant:
	return null

func java_method_setTmpFloorState_1(_args: Array = []) -> Variant:
	return null

func java_method_getTmpBlockState_2(_args: Array = []) -> Variant:
	return null

func java_method_setTmpBlockState_3(_args: Array = []) -> Variant:
	return null

func java_method_getPuddle_4(_args: Array = []) -> Variant:
	return null

func java_method_setPuddle_5(_args: Array = []) -> Variant:
	return null

func java_method_getFire_6(_args: Array = []) -> Variant:
	return null

func java_method_setFire_7(_args: Array = []) -> Variant:
	return null

func java_method_each_8(_args: Array = []) -> Variant:
	return null

func java_method_fill_9(_args: Array = []) -> Variant:
	return null

func java_method_set_10(_args: Array = []) -> Variant:
	return null

func java_method_seti_11(_args: Array = []) -> Variant:
	return null

func java_method_in_12(_args: Array = []) -> Variant:
	return null

func java_method_get_13(_args: Array = []) -> Variant:
	return null

func java_method_getn_14(_args: Array = []) -> Variant:
	return null

func java_method_getc_15(_args: Array = []) -> Variant:
	return null

func java_method_geti_16(_args: Array = []) -> Variant:
	return null

func java_method_getp_17(_args: Array = []) -> Variant:
	return null

func java_method_eachTile_18(_args: Array = []) -> Variant:
	return null

func java_method_iterator_19(_args: Array = []) -> Variant:
	return null
