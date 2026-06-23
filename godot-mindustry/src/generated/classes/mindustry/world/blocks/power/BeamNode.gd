# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/BeamNode.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "BeamNode"
const JAVA_EXTENDS := "PowerBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "maxRange", "type": "int"}, {"modifiers": ["public"], "name": "range", "type": "int"}, {"modifiers": ["public"], "name": "laser", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEnd", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserColor1", "type": "Color"}, {"modifiers": ["public"], "name": "laserColor2", "type": "Color"}, {"modifiers": ["public"], "name": "pulseScl", "type": "float"}, {"modifiers": ["public"], "name": "pulseMag", "type": "float"}, {"modifiers": ["public"], "name": "laserWidth", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BeamNode", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "changePlacementPath", "parameters": [{"name": "points", "type": "Seq", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "diagonal", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "getNodeLinks", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "others", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawLaser", "parameters": [{"name": "x1", "type": "float", "varargs": false}, {"name": "y1", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "size1", "type": "int", "varargs": false}, {"name": "size2", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setBars_0(_args: Array = []) -> Variant:
	return null

func java_method_setStats_1(_args: Array = []) -> Variant:
	return null

func java_method_init_2(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_3(_args: Array = []) -> Variant:
	return null

func java_method_changePlacementPath_4(_args: Array = []) -> Variant:
	return null

func java_method_getNodeLinks_5(_args: Array = []) -> Variant:
	return null

func java_method_drawLaser_6(_args: Array = []) -> Variant:
	return null
