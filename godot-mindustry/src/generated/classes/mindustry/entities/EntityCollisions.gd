# Generated from Mindustry upstream.
# Source: mindustry/entities/EntityCollisions.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities"
const JAVA_KIND := "class"
const JAVA_NAME := "EntityCollisions"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "seg", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "maxDelta", "type": "float"}, {"modifiers": ["private"], "name": "vector", "type": "Vec2"}, {"modifiers": ["private"], "name": "l1", "type": "Vec2"}, {"modifiers": ["private"], "name": "r1", "type": "Rect"}, {"modifiers": ["private"], "name": "r2", "type": "Rect"}, {"modifiers": ["private"], "name": "tmp", "type": "Rect"}, {"modifiers": ["private"], "name": "arrOut", "type": "Seq"}, {"modifiers": ["private"], "name": "hitCons", "type": "Cons"}, {"modifiers": ["private"], "name": "treeCons", "type": "Cons"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "moveCheck", "parameters": [{"name": "entity", "type": "Hitboxc", "varargs": false}, {"name": "deltax", "type": "float", "varargs": false}, {"name": "deltay", "type": "float", "varargs": false}, {"name": "solidCheck", "type": "SolidPred", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "move", "parameters": [{"name": "entity", "type": "Hitboxc", "varargs": false}, {"name": "deltax", "type": "float", "varargs": false}, {"name": "deltay", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "move", "parameters": [{"name": "entity", "type": "Hitboxc", "varargs": false}, {"name": "deltax", "type": "float", "varargs": false}, {"name": "deltay", "type": "float", "varargs": false}, {"name": "solidCheck", "type": "SolidPred", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "moveDelta", "parameters": [{"name": "entity", "type": "Hitboxc", "varargs": false}, {"name": "deltax", "type": "float", "varargs": false}, {"name": "deltay", "type": "float", "varargs": false}, {"name": "r", "type": "int", "varargs": false}, {"name": "x", "type": "boolean", "varargs": false}, {"name": "solidCheck", "type": "SolidPred", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "overlapsTile", "parameters": [{"name": "rect", "type": "Rect", "varargs": false}, {"name": "solidChecker", "type": "SolidPred", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "updatePhysics", "parameters": [{"name": "group", "type": "EntityGroup", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "legsSolid", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "waterSolid", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "solid", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "checkCollide", "parameters": [{"name": "a", "type": "Hitboxc", "varargs": false}, {"name": "b", "type": "Hitboxc", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "collide", "parameters": [{"name": "x1", "type": "float", "varargs": false}, {"name": "y1", "type": "float", "varargs": false}, {"name": "w1", "type": "float", "varargs": false}, {"name": "h1", "type": "float", "varargs": false}, {"name": "vx1", "type": "float", "varargs": false}, {"name": "vy1", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}, {"name": "w2", "type": "float", "varargs": false}, {"name": "h2", "type": "float", "varargs": false}, {"name": "vx2", "type": "float", "varargs": false}, {"name": "vy2", "type": "float", "varargs": false}, {"name": "out", "type": "Vec2", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "collide", "parameters": [{"name": "groupa", "type": "EntityGroup", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "updateCollision", "parameters": [{"name": "solid", "type": "Hitboxc", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_moveCheck_0(_args: Array = []) -> Variant:
	return null

func java_method_move_1(_args: Array = []) -> Variant:
	return null

func java_method_move_2(_args: Array = []) -> Variant:
	return null

func java_method_moveDelta_3(_args: Array = []) -> Variant:
	return null

func java_method_overlapsTile_4(_args: Array = []) -> Variant:
	return null

func java_method_updatePhysics_5(_args: Array = []) -> Variant:
	return null

func java_method_legsSolid_6(_args: Array = []) -> Variant:
	return null

func java_method_waterSolid_7(_args: Array = []) -> Variant:
	return null

func java_method_solid_8(_args: Array = []) -> Variant:
	return null

func java_method_checkCollide_9(_args: Array = []) -> Variant:
	return null

func java_method_collide_10(_args: Array = []) -> Variant:
	return null

func java_method_collide_11(_args: Array = []) -> Variant:
	return null

func java_method_updateCollision_12(_args: Array = []) -> Variant:
	return null
