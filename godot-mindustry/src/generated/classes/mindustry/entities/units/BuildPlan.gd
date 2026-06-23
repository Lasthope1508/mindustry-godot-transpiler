# Generated from Mindustry upstream.
# Source: mindustry/entities/units/BuildPlan.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.units"
const JAVA_KIND := "class"
const JAVA_NAME := "BuildPlan"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Position", "QuadTreeObject"]
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "x", "type": "int"}, {"modifiers": ["public"], "name": "y", "type": "int"}, {"modifiers": ["public"], "name": "rotation", "type": "int"}, {"modifiers": ["public"], "name": "block", "type": "Block"}, {"modifiers": ["public"], "name": "breaking", "type": "boolean"}, {"modifiers": ["public"], "name": "config", "type": "Object"}, {"modifiers": ["public"], "name": "progress", "type": "float"}, {"modifiers": ["public"], "name": "initialized", "type": "boolean"}, {"modifiers": ["public"], "name": "stuck", "type": "boolean"}, {"modifiers": ["public"], "name": "cachedValid", "type": "boolean"}, {"modifiers": ["public"], "name": "worldContext", "type": "boolean"}, {"modifiers": ["public"], "name": "animScale", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BuildPlan", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}]}, {"modifiers": ["public"], "name": "BuildPlan", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}]}, {"modifiers": ["public"], "name": "BuildPlan", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}]}, {"modifiers": ["public"], "name": "BuildPlan", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "placeable", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isRotation", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isDerelictRepair", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "samePos", "parameters": [{"name": "other", "type": "BuildPlan", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "pointConfig", "parameters": [{"name": "block", "type": "Block", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": "Object"}, {"modifiers": ["public"], "name": "pointConfig", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "copy", "parameters": [], "return_type": "BuildPlan"}, {"modifiers": ["public"], "name": "bounds", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}], "return_type": "Rect"}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}], "return_type": "BuildPlan"}, {"modifiers": ["public"], "name": "drawx", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "drawy", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "isDone", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "tile", "parameters": [], "return_type": "Tile"}, {"modifiers": ["public"], "name": "build", "parameters": [], "return_type": "Building"}, {"modifiers": ["public"], "name": "hitbox", "parameters": [{"name": "out", "type": "Rect", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getX", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getY", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_placeable_0(_args: Array = []) -> Variant:
	return null

func java_method_isRotation_1(_args: Array = []) -> Variant:
	return null

func java_method_isDerelictRepair_2(_args: Array = []) -> Variant:
	return null

func java_method_samePos_3(_args: Array = []) -> Variant:
	return null

func java_method_pointConfig_4(_args: Array = []) -> Variant:
	return null

func java_method_pointConfig_5(_args: Array = []) -> Variant:
	return null

func java_method_copy_6(_args: Array = []) -> Variant:
	return null

func java_method_bounds_7(_args: Array = []) -> Variant:
	return null

func java_method_set_8(_args: Array = []) -> Variant:
	return null

func java_method_drawx_9(_args: Array = []) -> Variant:
	return null

func java_method_drawy_10(_args: Array = []) -> Variant:
	return null

func java_method_isDone_11(_args: Array = []) -> Variant:
	return null

func java_method_tile_12(_args: Array = []) -> Variant:
	return null

func java_method_build_13(_args: Array = []) -> Variant:
	return null

func java_method_hitbox_14(_args: Array = []) -> Variant:
	return null

func java_method_getX_15(_args: Array = []) -> Variant:
	return null

func java_method_getY_16(_args: Array = []) -> Variant:
	return null

func java_method_toString_17(_args: Array = []) -> Variant:
	return null
