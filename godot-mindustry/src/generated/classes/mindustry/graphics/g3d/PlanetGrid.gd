# Generated from Mindustry upstream.
# Source: mindustry/graphics/g3d/PlanetGrid.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.graphics.g3d"
const JAVA_KIND := "class"
const JAVA_NAME := "PlanetGrid"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "cache", "type": "PlanetGrid"}, {"modifiers": ["final", "private", "static"], "name": "x", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "z", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "iTiles", "type": "Vec3"}, {"modifiers": ["final", "private", "static"], "name": "iTilesP", "type": "int"}, {"modifiers": ["public"], "name": "size", "type": "int"}, {"modifiers": ["public"], "name": "tiles", "type": "Ptile"}, {"modifiers": ["public"], "name": "corners", "type": "Corner"}, {"modifiers": ["public"], "name": "edges", "type": "Edge"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["protected"], "name": "PlanetGrid", "parameters": [{"name": "size", "type": "int", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static", "synchronized"], "name": "create", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "PlanetGrid"}, {"modifiers": ["public", "static"], "name": "initialGrid", "parameters": [], "return_type": "PlanetGrid"}, {"modifiers": ["public", "static"], "name": "subdividedGrid", "parameters": [{"name": "prev", "type": "PlanetGrid", "varargs": false}], "return_type": "PlanetGrid"}, {"modifiers": ["static"], "name": "addCorner", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "grid", "type": "PlanetGrid", "varargs": false}, {"name": "t1", "type": "int", "varargs": false}, {"name": "t2", "type": "int", "varargs": false}, {"name": "t3", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "addEdge", "parameters": [{"name": "id", "type": "int", "varargs": false}, {"name": "grid", "type": "PlanetGrid", "varargs": false}, {"name": "t1", "type": "int", "varargs": false}, {"name": "t2", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "pos", "parameters": [{"name": "t", "type": "Ptile", "varargs": false}, {"name": "n", "type": "Ptile", "varargs": false}], "return_type": "int"}, {"modifiers": ["static"], "name": "pos", "parameters": [{"name": "t", "type": "Ptile", "varargs": false}, {"name": "c", "type": "Corner", "varargs": false}], "return_type": "int"}, {"modifiers": ["static"], "name": "pos", "parameters": [{"name": "c", "type": "Corner", "varargs": false}, {"name": "n", "type": "Corner", "varargs": false}], "return_type": "int"}, {"modifiers": ["static"], "name": "tileCount", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["static"], "name": "cornerCount", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "int"}, {"modifiers": ["static"], "name": "edgeCount", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": "int"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_create_0(_args: Array = []) -> Variant:
	return null

func java_method_initialGrid_1(_args: Array = []) -> Variant:
	return null

func java_method_subdividedGrid_2(_args: Array = []) -> Variant:
	return null

func java_method_addCorner_3(_args: Array = []) -> Variant:
	return null

func java_method_addEdge_4(_args: Array = []) -> Variant:
	return null

func java_method_pos_5(_args: Array = []) -> Variant:
	return null

func java_method_pos_6(_args: Array = []) -> Variant:
	return null

func java_method_pos_7(_args: Array = []) -> Variant:
	return null

func java_method_tileCount_8(_args: Array = []) -> Variant:
	return null

func java_method_cornerCount_9(_args: Array = []) -> Variant:
	return null

func java_method_edgeCount_10(_args: Array = []) -> Variant:
	return null
