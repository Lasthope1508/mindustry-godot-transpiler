# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/logic/LogicBlock.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LogicBlock"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "maxByteLen", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "maxCompressedLen", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "maxLinks", "type": "int"}, {"modifiers": ["final", "public", "static"], "name": "maxNameLength", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "usedBuildings", "type": "IntSet"}, {"modifiers": ["final", "private", "static"], "name": "waitIndices", "type": "IntSeq"}, {"modifiers": ["final", "private", "static"], "name": "waitValues", "type": "FloatSeq"}, {"modifiers": ["public"], "name": "maxInstructionScale", "type": "int"}, {"modifiers": ["public"], "name": "instructionsPerTick", "type": "int"}, {"modifiers": ["public"], "name": "maxInstructionsPerTick", "type": "int"}, {"modifiers": ["public"], "name": "range", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LogicBlock", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "checkForceDark", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "accessible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canBreak", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "getLinkName", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "String"}, {"modifiers": ["public", "static"], "name": "compress", "parameters": [{"name": "code", "type": "String", "varargs": false}, {"name": "links", "type": "Seq", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public", "static"], "name": "compress", "parameters": [{"name": "bytes", "type": "byte", "varargs": false}, {"name": "links", "type": "Seq", "varargs": false}], "return_type": "byte"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "pointConfig", "parameters": [{"name": "config", "type": "Object", "varargs": false}, {"name": "transformer", "type": "Cons", "varargs": false}], "return_type": "Object"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_checkForceDark_0(_args: Array = []) -> Variant:
	return null

func java_method_accessible_1(_args: Array = []) -> Variant:
	return null

func java_method_canBreak_2(_args: Array = []) -> Variant:
	return null

func java_method_getLinkName_3(_args: Array = []) -> Variant:
	return null

func java_method_compress_4(_args: Array = []) -> Variant:
	return null

func java_method_compress_5(_args: Array = []) -> Variant:
	return null

func java_method_setStats_6(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_7(_args: Array = []) -> Variant:
	return null

func java_method_pointConfig_8(_args: Array = []) -> Variant:
	return null
