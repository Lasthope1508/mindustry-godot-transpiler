# Generated from Mindustry upstream.
# Source: mindustry/editor/DrawOperation.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "DrawOperation"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "opFloor", "type": "byte"}, {"modifiers": ["final", "static"], "name": "opBlock", "type": "byte"}, {"modifiers": ["final", "static"], "name": "opRotation", "type": "byte"}, {"modifiers": ["final", "static"], "name": "opTeam", "type": "byte"}, {"modifiers": ["final", "static"], "name": "opOverlay", "type": "byte"}, {"modifiers": ["final", "static"], "name": "opData", "type": "byte"}, {"modifiers": ["final", "static"], "name": "opDataExtra", "type": "byte"}, {"modifiers": ["private"], "name": "array", "type": "LongSeq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "isEmpty", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "size", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addOperation", "parameters": [{"name": "op", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "undo", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "redo", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "updateTile", "parameters": [{"name": "i", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "getTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "type", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": [], "name": "setTile", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "type", "type": "int", "varargs": false}, {"name": "to", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_isEmpty_0(_args: Array = []) -> Variant:
	return null

func java_method_size_1(_args: Array = []) -> Variant:
	return null

func java_method_remove_2(_args: Array = []) -> Variant:
	return null

func java_method_addOperation_3(_args: Array = []) -> Variant:
	return null

func java_method_undo_4(_args: Array = []) -> Variant:
	return null

func java_method_redo_5(_args: Array = []) -> Variant:
	return null

func java_method_updateTile_6(_args: Array = []) -> Variant:
	return null

func java_method_getTile_7(_args: Array = []) -> Variant:
	return null

func java_method_setTile_8(_args: Array = []) -> Variant:
	return null
