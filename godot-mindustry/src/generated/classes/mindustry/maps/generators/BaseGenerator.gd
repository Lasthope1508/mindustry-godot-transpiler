# Generated from Mindustry upstream.
# Source: mindustry/maps/generators/BaseGenerator.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.maps.generators"
const JAVA_KIND := "class"
const JAVA_NAME := "BaseGenerator"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "axis", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "rotator", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "range", "type": "int"}, {"modifiers": ["private", "static"], "name": "insanity", "type": "boolean"}, {"modifiers": ["private"], "name": "tiles", "type": "Tiles"}, {"modifiers": ["private"], "name": "cores", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "getDifficultyWall", "parameters": [{"name": "size", "type": "int", "varargs": false}, {"name": "difficulty", "type": "float", "varargs": false}], "return_type": "Block"}, {"modifiers": ["public"], "name": "generate", "parameters": [{"name": "tiles", "type": "Tiles", "varargs": false}, {"name": "cores", "type": "Seq", "varargs": false}, {"name": "spawn", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "sector", "type": "Sector", "varargs": false}, {"name": "difficulty", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "postGenerate", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "pass", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "tryPlace", "parameters": [{"name": "part", "type": "BasePart", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rand", "type": "Rand", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "tryPlace", "parameters": [{"name": "part", "type": "BasePart", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "random", "type": "Rand", "varargs": false}, {"name": "posc", "type": "Intc2", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["static"], "name": "set", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "item", "type": "Item", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "isTaken", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["static"], "name": "overlaps", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getDifficultyWall_0(_args: Array = []) -> Variant:
	return null

func java_method_generate_1(_args: Array = []) -> Variant:
	return null

func java_method_postGenerate_2(_args: Array = []) -> Variant:
	return null

func java_method_pass_3(_args: Array = []) -> Variant:
	return null

func java_method_tryPlace_4(_args: Array = []) -> Variant:
	return null

func java_method_tryPlace_5(_args: Array = []) -> Variant:
	return null

func java_method_set_6(_args: Array = []) -> Variant:
	return null

func java_method_isTaken_7(_args: Array = []) -> Variant:
	return null

func java_method_overlaps_8(_args: Array = []) -> Variant:
	return null
