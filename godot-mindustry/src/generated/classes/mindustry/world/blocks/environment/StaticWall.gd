# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/environment/StaticWall.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.environment"
const JAVA_KIND := "class"
const JAVA_NAME := "StaticWall"
const JAVA_EXTENDS := "Prop"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "large", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "split", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "autotile", "type": "boolean"}, {"modifiers": ["public"], "name": "autotileMidVariants", "type": "int"}, {"modifiers": ["protected"], "name": "autotileRegions", "type": "TextureRegion"}, {"modifiers": ["protected"], "name": "autotileMidRegions", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "StaticWall", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawBase", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "variant", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "max", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "checkAutotileSame", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "other", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "canReplace", "parameters": [{"name": "other", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "eq", "parameters": [{"name": "rx", "type": "int", "varargs": false}, {"name": "ry", "type": "int", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_drawBase_0(_args: Array = []) -> Variant:
	return null

func java_method_variant_1(_args: Array = []) -> Variant:
	return null

func java_method_checkAutotileSame_2(_args: Array = []) -> Variant:
	return null

func java_method_load_3(_args: Array = []) -> Variant:
	return null

func java_method_canReplace_4(_args: Array = []) -> Variant:
	return null

func java_method_eq_5(_args: Array = []) -> Variant:
	return null
